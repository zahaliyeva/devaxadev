//BOVOLENTA_D @Deloitte Digital on 15/11/2018
//Class used to manage all the different platform events regarding the customer
//Utility methods are intended for use inside the handler class
public without sharing class CustomerEventsManagement{

    //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - start
    public static Map<Integer, Customer_Event__c> customerEventsMap = new Map<Integer, Customer_Event__c>();
    //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - end

    //Method to match the event fields and save the event in the history object
    public static void insertEventInHistory (List<SObject> eventsList)
    {
        System.debug('===> Events list: ' + eventsList);
        String eventType = eventsList[0].getSObjectType().getDescribe().getName();//Get sobject type - the list should be uniform

        //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - start
        List<IE_Integration_Record__c> ieRecords = trackEventsOnIERecords(eventsList, eventType.removeEnd('__e'));
        System.debug('===> ieRecords: ' + ieRecords);
        Database.SaveResult[] sr = Database.Insert(ieRecords);
        System.debug('===> customerEventsMap: ' + customerEventsMap);
        //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - end

        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> eventFieldMap = schemaMap.get(eventType).getDescribe().fields.getMap();
        System.debug('===> eventType: ' + eventType);
        System.debug('===> recordType: ' + Schema.SObjectType.Customer_Event__c.getRecordTypeInfosByDeveloperName().get(eventType.removeEnd('__e')));
        Id historyRTid = Schema.SObjectType.Customer_Event__c.getRecordTypeInfosByDeveloperName().get(eventType.removeEnd('__e')).getRecordTypeId();
        List<String> eventFieldApiNames = new List<String>(); //EVENT fields
        for(Schema.SObjectField sfield : eventFieldMap.Values())
        {
            eventFieldApiNames.add(sfield.getDescribe().getname());
        }
        Map <String, Schema.SObjectField> historyFieldMap = schemaMap.get('Customer_Event__c').getDescribe().fields.getMap();
        Map<String,String> historyFieldApiNamesMap = new Map<String,String>(); //History fields
        for(Schema.SObjectField sfield : historyFieldMap.Values())
        {
            historyFieldApiNamesMap.put(sfield.getDescribe().getname(),sfield.getDescribe().getname());
        }
        List<Account> listAccounts = getAccountList(eventsList);
        Map<String,String> ndgsToAccountMap = new Map<String,String>();
        Map<String,String> fiscalCodesToAccountMap = new Map<String,String>();
        Map<String,String> VASNumbersToAccountMap = new Map<String,String>();
        for (Account acn :listAccounts)
        {
            if(acn.NDG__c != '' && acn.NDG__c!= null)
            {
                ndgsToAccountMap.put(acn.NDG__c,acn.Id);
            }
            if(acn.Fiscal_ID__c != '' && acn.Fiscal_ID__c!= null)
            {
                fiscalCodesToAccountMap.put(acn.Fiscal_ID__c,acn.Id);
            }
            if(acn.Partita_IVA__c != '' && acn.Partita_IVA__c!= null)
            {
                VASNumbersToAccountMap.put(acn.Partita_IVA__c,acn.Id);
            }                       
        }
        List<Customer_Event__c> historyList = new List<Customer_Event__c> ();
        //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - start
        Integer i=0;
        //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - end
        //Create history records and populate them with the fields from the events, using the matching API names
        for(SObject so :eventsList)
        {
			String eventName=so.getSObjectType().getDescribe().getName();
            SObject soHistoryRecord = schemaMap.get('Customer_Event__c').newSObject() ;     
            for(String fieldName :eventFieldApiNames)
            {
                if (historyFieldApiNamesMap.containsKey(fieldName))
                {
                    soHistoryRecord.put(fieldName, so.get(fieldName));
                }
            }
            // per l'evento CommunicationToCustomer__e è obbligatorio ricevere l'Account Id
            if('CommunicationToCustomer__e'.equalsIgnoreCase(eventName)
                ||'CommunicationToCustomerNoAAI__e'.equalsIgnoreCase(eventName)){
                soHistoryRecord.put('Account__c', so.get('AccountId__c'));
            } else {
                String currentCompany = (String)so.get('Customer_Company__c');
                if(currentCompany=='AAI')
                {
                    soHistoryRecord.put('Account__c',ndgsToAccountMap.get((String)so.get('NDG__c')));
                }
                else if ( (currentCompany == 'AMPS') ||(currentCompany=='MPS') )
                {
                    String fiscalInformation = (String)so.get('Fiscal_Identifier__c');
                    if ( fiscalInformation.length()==16) //Is a fiscal code
                    {
                        soHistoryRecord.put('Account__c',fiscalCodesToAccountMap.get(fiscalInformation));
                    }
                    else //is a VAS number
                    {
                        soHistoryRecord.put('Account__c',VASNumbersToAccountMap.get(fiscalInformation));
                    }
                }
            }
            soHistoryRecord.put('Timestamp__c', ((DateTime)so.get('Timestamp__c')));
            Customer_Event__c historyRecord = (Customer_Event__c)soHistoryRecord;
            historyRecord.RecordTypeId = historyRTid;
            system.debug ('historyRecord value: '+historyRecord);
            if(historyRecord.Account__c!= null)
            {
                historyList.add(historyRecord);
            }
            //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - start
            customerEventsMap.put(i, historyRecord);
            i++;
            //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - end
        }
        System.debug('===> History list: ' + historyList);
        Database.SaveResult[] historyInsertResults = Database.Insert(historyList);
        
        //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - start
        i=0;
        for(IE_Integration_Record__c ieRecord : ieRecords){
            Id customerEventId = customerEventsMap.get(i).Id;
            System.debug('===> Event ID : ' + customerEventId);
            if(customerEventId != null){
                ieRecord.ScopeID__c = customerEventsMap.get(i).Id;
                ieRecord.Status__c = 'OK';
            }
            
            i++;
        }
        Database.UpsertResult[] ieRecordsInsertResults = Database.Upsert(ieRecords);
        //MDANTONIO 12/04/2019: tracciamento eventi su Integration Record - end
    }



    public static void sendEmailAlertsForCustomerEvent(List<SObject> sObjList){
        System.debug('===> Events List (utility class): ' + sObjList);
        List<Account> listAccounts = getAccountList(sObjList);
        Map<Id, String> queueMap = new Map<Id, String>();
        for(Account a : listAccounts){
            queueMap.put(a.Id, 'Coda_Agenzia_' + a.AAI_Agency_Reference_Code__c);
        }

        System.debug('===> Queue map: ' + queueMap);
        Set<Group> queues = new Set<Group>([SELECT Id, Name, DeveloperName 
                                FROM Group 
                                WHERE Type = 'Queue' and DeveloperName IN :queueMap.values()]);
        System.debug('===> Queues involved in email alerts ' + queues);

        Set<String> queuesName = new Set<String>();
        for(Group g : queues){
            queuesName.add(g.DeveloperName);
        }
        
        Map<String,Set<String>> groupNametoEmails = UtilityClass.prepareQueueRecipientsMap(queuesName);
        System.debug('===> groupNametoEmails ' + groupNametoEmails);

        sendEmailsForEvent(sObjList, listAccounts, queueMap, groupNametoEmails);
    }   

    public static void sendEmailsForEvent(List<sObject> eventsList, List<Account> listAccounts, 
        Map<Id, String> queueMap, Map<String,Set<String>> groupNametoEmails){

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String eventType = eventsList[0].getSObjectType().getDescribe().getName();//Get sobject type - the list should be uniform

        EmailTemplate et;
        switch on eventType {
            when 'Customer_Document_Download__e'{
                et = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
                                WHERE developername = 'AAI_Segnalazione_Customer_Document_Download'];
            }
            when 'Customer_Email_Unsubscribing__e'{
                et = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
                                WHERE developername = 'AAI_Segnalazione_Email_Unsubscribe'];
            }
            when 'Customer_Quotation_Refused__e'{
                et = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
                                WHERE developername = 'AAI_Segnalazione_Quotation_Refused'];
            }
        }

        Domain dom = [SELECT Domain,DomainType FROM Domain LIMIT 1];
        Network net = [SELECT Name,UrlPathPrefix FROM Network WHERE Name ='agenzie' LIMIT 1];

        OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress 
                                    WHERE DisplayName = 'Assistenza Agenti Axa Assicurazioni']; 
        System.debug('===> owa: ' + owa);

        for(Integer i=0; i<listAccounts.size(); i++){
            sObject ev = eventsList.get(i);
            System.debug('===> Customer event: ' + ev);
            Account act = listAccounts.get(i);
            System.debug('===> Account: ' + act);
            String groupId = queueMap.get(act.Id);
            System.debug('===> GroupId: ' + groupId);
            Set<String> emails = groupNametoEmails.get(groupId);
            System.debug('===> emails: ' + emails);
            List<String> toAddresses = new List<String>();
            if(emails != null){
                toAddresses.addAll(emails);
                System.debug('===> Email ' + (i+1) + ' recipients: ' + toAddresses);
                Map<String,String> mapFieldToValue = new Map<String,String>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                switch on eventType {
                    when 'Customer_Document_Download__e'{
                        mapFieldToValue.put('{!InsurancePolicy__c.Name}', (String)ev.get('Policy_Number__c'));
                    }
                    when 'Customer_Quotation_Refused__e'{
                        mapFieldToValue.put('{!Customer_Event__c.License_Plate__c}', (String)ev.get('License_Plate__c'));
                        mapFieldToValue.put('{!Customer_Event__c.Model__c}', (String)ev.get('Model__c'));
                        mapFieldToValue.put('{!InsurancePolicy__c.EXPIRY_DATE__c}', ((DateTime)ev.get('Policy_Expiry_Date__c')).format('dd/MM/yyyy'));
                    }
                }
                String url = '<a href=\'' + dom.Domain + '/' + net.UrlPathPrefix + '/' + act.Id + '\'>' + act.Name + '</a>';
                mapFieldToValue.put('{!Account.Name}', url);
                mapFieldToValue.put('{!Customer_Event__c.Timestamp__c}', ((DateTime)ev.get('Timestamp__c')).format('dd/MM/yyyy'));
                email = UtilityClass.prepareEmailTemplate(et,mapFieldToValue);              
                email.setToAddresses(toAddresses);
                email.setSenderDisplayName(owa.DisplayName);
                //email.setOrgWideEmailAddressId(owa.Id);
                email.setReplyTo(owa.Address);
                mails.add(email);
            }
        }
        if(mails.size() > 0){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);      
            EmailDelivery.notifyDeliveryErrors(r);
        }
    }

    public static List<Account> getAccountList(List<SObject> eventsList){
        List<String> ndgsList = new List<String>();
        List<String> fiscalCodesList = new List<String>();
        List<String> VASNumbersList = new List<String>();
        List<String> accountIds = new List<String>();
        //retrieve data for the account search
        for(SObject so :eventsList)
        {
            // per l'evento CommunicationToCustomer__e è obbligatorio ricevere l'Account Id
            String eventName=so.getSObjectType().getDescribe().getName();
            if('CommunicationToCustomer__e'.equalsIgnoreCase(eventName)
                ||'CommunicationToCustomerNoAAI__e'.equalsIgnoreCase(eventName)){
                accountIds.add((String)so.get('AccountId__c'));
            } else {
                String currentCompany = (String)so.get('Customer_Company__c');
                if(currentCompany=='AAI')
                {
                    ndgsList.add((String)so.get('NDG__c'));
                }
                else if ( (currentCompany == 'AMPS') ||(currentCompany=='MPS') )
                {
                    String fiscalInformation = (String)so.get('Fiscal_Identifier__c');
                    if ( fiscalInformation.length()==16) //Is a fiscal code
                    {
                        fiscalCodesList.add(fiscalInformation);
                    }
                    else //is a VAS number
                    {
                        VASNumbersList.add(fiscalInformation);
                    }
                }
            }
        }
        System.debug('===> ndgsList: ' + ndgsList);
        List<Account> listAccounts = [SELECT Id, Name, NDG__c, Fiscal_ID__c, Partita_IVA__c, AAI_Agency_Reference_Code__c 
                                      FROM Account
                                      WHERE NDG__c in :ndgsList 
                                        OR Fiscal_ID__c IN :fiscalCodesList 
                                        OR Partita_IVA__c IN :fiscalCodesList
                                        OR Partita_IVA__c IN :VASNumbersList
                                        OR Id in :accountIds];
        System.debug('===> listAccounts' + listAccounts);
        return listAccounts;
    }

    public static List<IE_Integration_Record__c> trackEventsOnIERecords(List<sObject> sObjList, String eventType){
        System.debug('===> eventType: ' + eventType);
        IE_Configuration__c config = [SELECT Id,Name,Endpoint__c FROM IE_Configuration__c WHERE Name = :eventType LIMIT 1];
        System.debug('===> config: ' + config);
        List<IE_Integration_Record__c> ieRecords = new List<IE_Integration_Record__c>();
        for(sObject ev : sObjList){
            IE_Integration_Record__c ieRecord = new IE_Integration_Record__c();
            ieRecord.IE_Configuration__c = config.id;
            ieRecord.RequestBody__c = JSON.serialize(ev);
            ieRecord.URLRequest__c = config.Endpoint__c;
            ieRecord.Status__c = 'KO';
            ieRecords.add(ieRecord);
        }
        return ieRecords;
    }
}