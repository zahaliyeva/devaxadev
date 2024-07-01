public class UtilityClass {
    
    public static List<RecordType> rcts = new List<RecordType>();
    public static List<Group> queues = new List<Group>();
    public static List<RecordType> rtlist = new List<RecordType>();
    public static boolean isFirstRun = true;  
    
    public class Request {
        @InvocableVariable(
            label = 'Case Record Id'
            description = 'The id of the Case record to change'
            required = true
        )
        public String CaseRecordId;
        @InvocableVariable(
            label = 'Record Type Developer Name'
            description = 'The Developer Name of the Record Type to change the object to'
            required = true
        )
        public String developerName;
    }
    @InvocableMethod(
        label = 'Change Object Record Type'
        description = 'Change Record Type by Developer Name'
    )
    public static void getRTidBySobject(List<Request> requests){
    String DeveloperName =   requests[0].developerName ;
    String CaseRecordId =   requests[0].CaseRecordId ;

    String gsRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(DeveloperName).getRecordTypeId();

    Case caseRT = [Select id,RecordTypeId from case where id =:CaseRecordId ];
    caseRT.RecordTypeId = gsRecordTypeID ;
    update caseRT ;
    }

    public static void fetchRecordTypes(){  
        System.debug('SAN Queried the Utility RecordType');      
        rcts = [Select Id, Name,SObjectType from RecordType];        
    }
    
    public static Map<string,Map<string,string>> fetchAllRTypes(){
         System.debug('================');
         Map<string,Map<string,string>> rtypes = new Map<string,Map<string,string>>();
         rtlist = [Select Id, DeveloperName,SObjectType from RecordType order by SObjectType ];   
         for (RecordType rt : rtList)
         {
             if (!rtypes.containsKey(rt.SObjectType))
             {
                 rtypes.put(rt.SObjectType, new Map<string,string>());
             }
             rtypes.get(rt.SObjectType).put(rt.DeveloperName, rt.id);
         }
         system.debug(rtypes);
         return rtypes;
            
    }
    
   public static id getRTid(Map<string,Map<string,string>>rtypes, String SObjectType, String DeveloperName){
        
        return rtypes.get(SObjectType).get(DeveloperName);
        
       
        //return id;
     }
    
    public static void fetchQueues(){
        System.debug('SAN Queried the Utility Queue');
        queues = [Select Id, Name,DeveloperName from Group Where Type = 'Queue'];
    }
    
    public static Messaging.SingleEmailMessage prepareEmailTemplate(emailtemplate template, map<string, string> fieldsToChange)
    {
        Set<String> FieldsSet = fieldsToChange.keyset();
        string subject=template.Subject;
        string htmlbody=template.HtmlValue;
        string plainbody=template.Body;

        system.debug('+++++++template'+template);
        system.debug('+++++++setof fields'+FieldsSet);
        system.debug('+++++++mapofFields'+fieldsToChange);
        
        for (string thisfield : FieldsSet) {
            // process the merge fields
            system.debug('++++++replacing'+thisfield+'with'+fieldsToChange.get(thisfield));
            string filledField = fieldsToChange.get(thisfield);
            if (String.isempty(filledField) || String.isblank(filledField) || filledField=='null') {
                filledField = 'N.D.';
            }
            
            system.debug('++++++replacing'+thisfield+'with'+fieldsToChange.get(thisfield));
            system.debug('++++++found this subject'+subject);
            subject= subject.replace(thisfield, filledField);
            system.debug('++++++replaced with this subject'+subject);

            system.debug('++++++found this htmlbody'+htmlbody);
            htmlbody=htmlbody.replace(thisfield, filledField);
            system.debug('++++++replaced this htmlbody'+htmlbody);

            system.debug('++++++found this plainbody'+plainbody);
            //plainbody=plainbody.replace(thisfield, fieldsToChange.get(thisfield));
            //system.debug('++++++replaced this plainbody'+plainbody);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setHtmlBody(htmlbody);
        //mail.setPlainTextBody(plainbody);
        //mail.setPlainTextBody(htmlbody);
        return mail;


    }
    
    /**
    * Method that retrieves the group Id according to the given type and group Developer's name
    * @author: Juana Valenzuela
    * @date: 01/06/2017
    * @param
    * groupType: Type of the group. Ex: Queue
    * groupName: group developer name
    *@return groupId
    */
    public static Id retrieveGroupId(String groupType, String groupName){
        Id groupId = [SELECT Id FROM Group WHERE Type = :groupType AND Group.DeveloperName = :groupName].Id;
        return groupId;
    }

    /**
    * Method that given an sObject name and picklist field name returns the values of the picklist to allow the use of API
    * Names instead of Labels names that may vary
    * @author: Juana Valenzuela
    * @date: 22/06/2017
    * @param objectName: sObject for which the picklist value is needed
    *        fieldName: Name of the picklist field for which the value is needed
    * @return  picklistAPILabelMap: Map that contains the picklist values by API Name - Value(UI Label)        
    */
    public static Map<String,String> getPicklistValue(Sobject objectName, String fieldName){
        Map<String,String> picklistAPILabelMap = new Map<String,String>();
        Schema.sObjectType sObject_Type = objectName.getSObjectType();
        Schema.DescribeSObjectResult sobject_Describe = sObject_Type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_Describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry tempPicklistValue:pick_list_values){
            picklistAPILabelMap.put(tempPicklistValue.getValue(),tempPicklistValue.getLabel());
        }
        return picklistAPILabelMap;
    }

      /**
    * Method that given an sObject name and picklist field name returns the values of the picklist to allow the use of API
    * Names instead of Labels names that may vary
    * @author: *-+
    * @date: 07-03-2022
    * @param objectName: sObject for which the picklist value is needed
    *        fieldName: Name of the picklist field for which the value is needed nad ONLY ACTIVE
    * @return  picklistAPILabelMap: Map that contains the picklist values by API Name - Value(UI Label)        
    */
    public static Map<String,String> getPicklistValueOnlyActive(Sobject objectName, String fieldName){
        Map<String,String> picklistAPILabelMap = new Map<String,String>();
        Schema.sObjectType sObject_Type = objectName.getSObjectType();
        Schema.DescribeSObjectResult sobject_Describe = sObject_Type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_Describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry tempPicklistValue:pick_list_values){
            if(tempPicklistValue.isActive())
            picklistAPILabelMap.put(tempPicklistValue.getValue(),tempPicklistValue.getLabel());
        }
        return picklistAPILabelMap;
    }
    public static Map<String,String> getPicklistLabels(Sobject objectName, String fieldName){
        Map<String,String> picklistAPILabelMap = new Map<String,String>();
        Schema.sObjectType sObject_Type = objectName.getSObjectType();
        Schema.DescribeSObjectResult sobject_Describe = sObject_Type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_Describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry tempPicklistValue:pick_list_values){
            if(tempPicklistValue.isActive())
            picklistAPILabelMap.put(tempPicklistValue.getLabel(),tempPicklistValue.getValue());
        }
        return picklistAPILabelMap;
    }
    
    /**
    * Method that reassign a list of records to a new owner and notify with an email the old owner
    * @author: Lorenzo Santoro
    * @date: 08/01/2018
    * @param List<SObject> recs, Id newOnwer, EmailTemplate EmailTemplateName, Boolean OldOwnerNotify, Boolean executeDML
    * @return  void       
    */    
    public static void reassignToUniqueNewOwnerAndNotifyOldOwner (List<SObject> recs, Id newOnwer, String EmailTemplateName, Boolean OldOwnerNotify, Boolean executeDML)
    {
    
        /*
        List<SObject> recs = [Select id, ownerId from Lead where id= '00Q7E00000C5307'];
        Id newOnwer = [select id from User where name = 'Lorenzo Santoro' limit 1].Id;
        String EmailTemplateName = 'CloseCase';
        Boolean OldOwnerNotify = true;
        Boolean executeDML = true;
        */
        
        List<Id> toSobjId = new List<Id>();
        Schema.SObjectType objType = recs[0].getSObjectType();
        for(SObject r : recs)
        {
            toSobjId.add(r.get('OwnerId')+'');
        }
        
        List<SObject> toSobj = getAllUsers(toSobjId);
        
        if(OldOwnerNotify == true && toSobj.size()>0)
        {   
            EmailTemplate et = [select id,Subject,HtmlValue,Body from emailtemplate where developername = :EmailTemplateName ];
            OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'AXA Lead Management']; 
            
            sendMailTemplatedList(toSobj, owa.Address, owa.Address, false, false, et, recs);
        }
    
        for(SObject r : recs)
        {
            r.put('OwnerId',newOnwer); 
            if (''+objType == 'Lead') 
            {
                r.put('TECH_Send_Email_Notification__c', false);
                r.put('Agency_Code__c', ''); 
            }
        }
          
    
        if (executeDML == true && recs.size()>0 )
        {
            update recs;
        }  
    
    } 
    

    /**
    * Method that retrieves the list of users with an input a list of id of users and id of queues
    * @author: Lorenzo Santoro
    * @date: 08/01/2018
    * @param List<Id> inputIdsList
    * @return List<SObject> of type User      
    */    
    public static List<SObject> getAllUsers(List<Id> inputIdsList)
    {
    
        Set<Id> Ids = new Set<Id>();
    
        for(Id i : inputIdsList)
        {
            Ids.add(i);
        }
    
        List<SObject> usersReturn = EmailDelivery.getUsersThatBelongsToGroup(Ids);

    
        return usersReturn;
    
    }      
    
    public static void sendMailTemplatedList(List<SObject> targetObjs, String SenderDisplayName, String ReplyToEmail, boolean saveAsActivity, boolean notifyErrors,
                                            EmailTemplate et, List<SObject> whatIdSobjects)
    {

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        map<String,String> mapFieldToValue = new Map<String,String>();
        Schema.SObjectType objType = whatIdSobjects[0].getSObjectType();
        if (''+objType == 'Lead')
        {
            mapFieldToValue.put('{!Lead.FirstName}',''+whatIdSobjects[0].get('FirstName'));
            mapFieldToValue.put('{!Lead.LastName}',''+whatIdSobjects[0].get('LastName') );  
            mapFieldToValue.put('{!Lead.Dettaglio__c}',''+whatIdSobjects[0].get('Dettaglio__c') );      
        }
        for(SObject targetObj: targetObjs) 
        {
            mapFieldToValue.put('{!User.FirstName}',''+targetObj.get('FirstName'));
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email = UtilityClass.prepareEmailTemplate(et,mapFieldToValue );
            email.setTargetObjectId(targetObj.get('Id')+'');
            //email.setTemplateId(et.id); 
            email.setSenderDisplayName(SenderDisplayName);
            email.setReplyTo(ReplyToEmail);
            email.saveAsActivity = saveAsActivity;  
            //Id theId = '00Q7E00000C6opR';
            //email.setWhatId(theId); SendEmail failed. First exception on row 0; first error: INVALID_ID_FIELD, WhatId is not available for sending emails to UserIds.
            mails.add(email);
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);      
        if (notifyErrors==true) 
        {
            EmailDelivery.notifyDeliveryErrors(r);
        }
             
    }

    public static Map<String,Set<String>> prepareQueueRecipientsMap(Set<String> setQueues){
        System.debug('===> setQueues ' + setQueues);
        List<GroupMember> recipientPersonsG = [SELECT  GroupId, Id, SystemModstamp, UserOrGroupId, Group.DeveloperName 
                                                FROM GroupMember 
                                                WHERE Group.DeveloperName IN :setQueues ];
        System.debug('===> recipientPersonsG ' + recipientPersonsG);
        Map<String,Set<Id>> GroupNametoIds = new Map<String,Set<Id>>();
        List<Id> userIds = new List<Id>();
        for (GroupMember GM :recipientPersonsG){
            if (String.valueOf(GM.UserOrGroupId).left(3)=='005'){ 
                userIds.add(GM.UserOrGroupId);
                Set<Id> tmpidset = new Set<Id>();
                tmpidset = GroupNametoIds.get(GM.Group.DeveloperName);
                if (tmpidset == null){
                    System.debug('===> GM.UserOrGroupId '+GM.UserOrGroupId);
                    tmpidset  = new set<Id>();
                    tmpidset.add(GM.UserOrGroupId);
                    GroupNametoIds.put(GM.group.developername,tmpidset);
                }
                else{
                    tmpidset.add(GM.UserOrGroupId);
                    GroupNametoIds.put(GM.group.developername,tmpidset);
            }
            }
        }

        List<User> recipientPersons=[SELECT id, email FROM User WHERE isactive = true AND id IN :userIds];
        Map<Id, User> mapRecipients = new Map<Id, User>(recipientPersons);
        map<String,Set<String>> groupNametoEmails = new map<String,Set<String>>();
        for(String currentQueue :setQueues){
            Set<Id> tmpidset = new Set<Id>();
            tmpidset = GroupNametoIds.get(currentQueue);
            if (tmpidset != null){
                for (Id currentId :tmpidset){ 
                    Set<String> tmpStringSet = groupNametoEmails.get(currentQueue);
                    System.debug('===> tmpStringSet  '+tmpStringSet );
                    if (tmpStringSet == null){
                        System.debug('===> currentId '+ currentId);
                        System.debug('===> mapRecipients.get(currentId) '+ mapRecipients.get(currentId));
                        tmpStringSet = new Set<String>();
                        if (mapRecipients.get(currentId) != null ){
                            tmpStringSet.add(mapRecipients.get(currentId).email);
                            groupNametoEmails.put(currentQueue,tmpStringSet);
                        }
                    }
                    else{
                        System.debug('===> mapRecipients.get(currentId) '+mapRecipients.get(currentId));
                        
                        if (mapRecipients.get(currentId) != null ){
                            tmpStringSet.add(mapRecipients.get(currentId).email);
                            groupNametoEmails.put(currentQueue,tmpStringSet);
                        }
                    }
                }
            }          
        }
        System.debug('===> GroupNametoEmails '+groupNametoEmails); 

        return groupNametoEmails;
    }

    //public static void sendEmailAlertsForCustomerEvent(List<SObject> sObjList, String s){
    //    System.debug('===> Events List (utility class): ' + sObjList);
    //    System.debug('===> Test string: ' + s);
    //    List<String> ndgsList = new List<String>();
    //    List<String> fiscalCodesList = new List<String>();
    //    List<String> VASNumbersList = new List<String>();
    //    for(SObject so :sObjList)
    //    {
    //        System.debug('===> Event object: ' + so);
    //        String company = (String)so.get('Customer_Company__c');
    //        if(company == 'AAI')
    //        {
    //            ndgsList.add((String)so.get('NDG__c'));
    //        }
    //        else if ( (company == 'AMPS') ||(company == 'MPS') )
    //        {
    //            String fiscalInformation = (String) so.get('Fiscal_Identifier__c');
    //            if (fiscalInformation.length()==16) //Is a fiscal code
    //            {
    //                fiscalCodesList.add(fiscalInformation);
    //            }
    //            else //is a VAS number
    //            {
    //                VASNumbersList.add(fiscalInformation);
    //            }
    //        }
    //    }
    //    System.debug('===> ndgsList: ' + ndgsList);
    //    List<Account> listAccounts = [SELECT Id, Name, NDG__c, Fiscal_ID__c, Partita_IVA__c, AAI_Agency_Reference_Code__c 
    //                                    FROM Account 
    //                                    WHERE NDG__c in :ndgsList 
    //                                        OR Fiscal_ID__c IN :fiscalCodesList 
    //                                        OR Partita_IVA__c in :VASNumbersList];
    //    Map<Id, String> queueMap = new Map<Id, String>();
    //    for(Account a : listAccounts){
    //        queueMap.put(a.Id, 'Coda_Agenzia_' + a.AAI_Agency_Reference_Code__c);
    //    }

    //    System.debug('===> Queue map: ' + queueMap);
    //    Set<Group> queues = new Set<Group>([SELECT Id, Name, DeveloperName 
    //                            FROM Group 
    //                            WHERE Type = 'Queue' and DeveloperName IN :queueMap.values()]);
    //    System.debug('===> Queues involved in email alerts ' + queues);

    //    Set<String> queuesName = new Set<String>();
    //    for(Group g : queues){
    //        queuesName.add(g.DeveloperName);
    //    }
        
    //    Map<String,Set<String>> groupNametoEmails = UtilityClass.prepareQueueRecipientsMap(queuesName);
    //    System.debug('===> groupNametoEmails ' + groupNametoEmails);

    //    sendEmailsForEvent(sObjList, listAccounts, queueMap, groupNametoEmails);
    //}   

    //public static void sendEmailsForEvent(List<sObject> eventsList, List<Account> listAccounts, 
    //    Map<Id, String> queueMap, Map<String,Set<String>> groupNametoEmails){

    //    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    //    String eventType = eventsList[0].getSObjectType().getDescribe().getName();//Get sobject type - the list should be uniform

    //    EmailTemplate et;
    //    switch on eventType {
    //        when 'Customer_Document_Download__e'{
    //            et = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
    //                            WHERE developername = 'AAI_Segnalazione_Customer_Document_Download'];
    //        }
    //        when 'Customer_Email_Unsubscribing__e'{
    //            et = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
    //                            WHERE developername = 'AAI_Segnalazione_Email_Unsubscribe'];
    //        }
    //        when 'Customer_Quotation_Refused__e'{
    //            et = [SELECT id,Subject,HtmlValue,Body FROM emailtemplate 
    //                            WHERE developername = 'AAI_Segnalazione_Quotation_Refused'];
    //        }
    //    }

    //    OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress 
    //                                WHERE DisplayName = 'AXA Lead Management']; 
    //    System.debug('===> owa: ' + owa);

    //    for(Integer i=0; i<listAccounts.size(); i++){
    //        sObject ev = eventsList.get(i);
    //        System.debug('===> Customer event: ' + ev);
    //        Account act = listAccounts.get(i);
    //        System.debug('===> Account: ' + act);
    //        String groupId = queueMap.get(act.Id);
    //        System.debug('===> GroupId: ' + groupId);
    //        Set<String> emails = groupNametoEmails.get(groupId);
    //        System.debug('===> emails: ' + emails);
    //        List<String> toAddresses = new List<String>();
    //        if(emails != null){
    //            toAddresses.addAll(emails);
    //            System.debug('===> Email ' + (i+1) + ' recipients: ' + toAddresses);

    //            Map<String,String> mapFieldToValue = new Map<String,String>();
    //            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

    //            switch on eventType {
    //                when 'Customer_Document_Download__e'{
    //                    mapFieldToValue.put('{!InsurancePolicy__c.Name}', (String)ev.get('Policy_Number__c'));
    //                }
    //                when 'Customer_Quotation_Refused__e'{
    //                    mapFieldToValue.put('{!Customer_Event_c.License_Plate}', (String)ev.get('License_Plate__c'));
    //                    mapFieldToValue.put('{!Customer_Event_c.Model__c}', (String)ev.get('Model__c'));
    //                    mapFieldToValue.put('{!InsurancePolicy__c.EXPIRY_DATE__c}', ((DateTime)ev.get('Policy_Expiry_Date__c')).format('MM/dd/yyyy'));
    //                }
    //            }

    //            mapFieldToValue.put('{!Account.Name}', act.Name);
    //            mapFieldToValue.put('{!Customer_Event__c.Timestamp__c}', ((DateTime)ev.get('Timestamp__c')).format('MM/dd/yyyy'));
    //            email = UtilityClass.prepareEmailTemplate(et,mapFieldToValue);              
    //            email.setToAddresses(toAddresses);
    //            email.setSenderDisplayName(owa.DisplayName);
    //            //email.setOrgWideEmailAddressId(owa.Id);
    //            email.setReplyTo(owa.Address);
    //            mails.add(email);
    //        }
    //    }
    //    if(mails.size() > 0){
    //        Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);      
    //        EmailDelivery.notifyDeliveryErrors(r);
    //    }
    //}
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){

                //if (!sObj.contains('__')) to exclude managed package objects

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
}