/**
 * Created by Davide(Augens) on 15/10/2018.
 *
 *  How to properly create and configure a record of type 'Contact History Configuration' (Custom Metadata):
 *      -IMPORTANT: every parameter that need to be replaced by a field as result of the query,
 *          must be included between '§§' characters.
 *          e.g.: Query->'SELECT Id, Name FROM Object', Title->'The title is §Name§'
 *      -Label:
 *          syntax must be '{IdTypeUsedInWHERECondition}_{QueryObject}_{IncrementalNumber}'
 *          e.g.(1.1): 'ACCOUNT_TASK_001' has query like 'Select * From TASK Where id in :§ACCOUNTID§'
 *          e.g.(1.2): 'ACCOUNT_CONTACT_EVENT_001' has query like 'Select * From EVENT Where id in :§ACCOUNTID§ OR contactId in :§CONTACTID§'
 *      -Field Type:
 *          must be referred to previous 'IdTypeUsedInWHERECondition' value.
 *          e.g.: for the previous example (1.1 and 1.2) the value to set is Account/Contact
 *      -Query and Query2:
 *          parameter as explained before must be included in '§§' characters.
 *          All the syntax of the query must be clearly written outside of any couple of '§§' characters.
 *          e.g.:   CORRECT -> SELECT * FROM Object WHERE Id IN :§AccountIds§
 *                  WRONG -> SELECT * FROM Object WHERE Id IN §:AccountIds§
 *       -Query2 Field Id:
 *          It's the field of 2nd query in which the condition operates using the parameter get by 1st query.
 *          e.g.:   in this case the value of 'Query2 Field Id' is going to be 'ContactId'
 *                  Query-1 -> 'SELECT Id, WhoId FROM Event'
 *                  Query-2 -> 'SELECT Id, Name, ContactId FROM Task WHERE ContactId IN :§WhoId§
 *       -Query2 Object:
 *          Is the object where the query operates (must be populated with the 'FROM' Object of the query).
 *          e.g.:   Query-2 -> 'SELECT * FROM Task'
 *                  'Query2 Object' = 'Task'
 *       -Link Field (Title Link, Detail 1 Link, etc.):
 *          It should reference an URL or ID of the object.
 *          e.g.: Title Link: §EventId§
 *       -Flag Sent/Open/Click/Bounce:
 *          they all have 3 different fields:
 *              FIELD: should reference a field of the query (e.g.: "§TrackingMessage__c§"). It is what we want to compare.
 *              PARAMETER: target of the comparison. It is what we want to be compared to FIELD (e.g.: true/false/0)
 *              OPERATOR: which operation we want to perform between FIELD and PARAMETER (e.g.: equals, ==, >)
 *
 */

public without sharing class ContactHistoryCTRL {

    private static Boolean fromFunctionReplaceParameter = false;
    public static List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();

    private static final Map<String, List<String>> TIPOLOGIA_COMUNICAZIONE_CONFIGURATION_MAP = new Map<String, List<String>>{
        'Feedback' => new List<String>{
            'ACCOUNT_FEEDBACK_001', 'ACCOUNT_FEEDBACK_003', 'ACCOUNT_FEEDBACK_SINCHECKIN_001','ACCOUNT_FEEDBACK_001_1', 'ACCOUNT_FEEDBACK_003_1', 'ACCOUNT_FEEDBACK_SINCHECKIN_001_1'

        },
        'Comunicazioni Feedback' => new List<String>{
            'CONTACT_TASK_FEEDBACK'
        },
        'Eventi da MyAXA e PCC' => new List<String>{
            'ACCOUNT_CUSTOMEREVENT_001', 'ACCOUNT_CUSTOMEREVENT_003'
        },
        'Comunicazioni su Campagne' => new List<String>{
            'CONTACT_CAMPAIGNMEMBER_001', 'CONTACT_CAMPAIGNMEMBER_002', 'CONTACT_TASK_006', 'CONTACT_TASK_005', 'ACCOUNT_COMM_TO_CUS_MarkCampEmail', 'ACCOUNT_COMM_TO_CUS_MarkCampSMS', 'Push_Commerciale_Agenzia_Campagne','Push_Commerciale_Direzione_Campagne','Push_Commerciale_Sottonodo_Campagne'
        },
        'Comunicazioni Informative' => new List<String>{
            'CONTACT_TASK_004', 'CONTACT_TASK_001', 'CONTACT_INDIVIDUALEMAILRESULT_001','ACCOUNT_COMMUNICATION_TO_CUSTOMER_PIAN_E','Push_Amministrativa_Agenzia_NoContrat',
            'Push_Amministrativa_Direzione_NOContratt','Push_Amministrativa_Sottonodo_NOContratt','Push_Informativa_Agenzia','Push_Informativa_Direzione','Push_Informativa_Sottonodo','SELF_SERVICE_VOICE_BOT'
        
        },
        'Comunicazioni Contrattuali' => new List<String>{
            'ACCOUNT_MASSIVE_COMMUNICATION_002', 'ACCOUNT_MASSIVE_COMMUNICATION_001', 'ACCOUNT_MASSIVE_COMMUNICATION_003', 'Push_Amministrativa_Agenzia_Contrattuali',
            'Push_Amministrativa_Direzione_Contrattua','Push_Amministrativa_Sottonodo_Contrattua'
        },
        'Comunicazioni di Processo' => new List<String>{
            'ACCOUNT_COMMUNICATION_TO_CUSTOMER_EMAIL', 'ACCOUNT_COMMUNICAT_OUT_TO_CUST_EMAIL_ACQ','ACCOUNT_COMMUNICAT_OUT_TO_CUST_EMAIL_INT','ACCOUNT_COMMUNICATION_TO_CUSTOMER_SMS','ACCOUNT_COMMUNICATION_TO_CUSTOMER_PROC_D'
        },
        'Comunicazioni di Agenzia' => new List<String>{
            'ACCOUNT_COMMUNICATION_TO_CUSTOMER_PROC_D'
        },
        'Attività in Agenzia' => new List<String>{
            'ACCOUNT_CONTACT_EVENT_001', 'ACCOUNT_INSURANCEPOLICY_001', 'ACCOUNT_INSURANCEPOLICY_003', 'ACCOUNT_PROPOSTA_001', 'CONTACT_EVENT_001', 'ACCOUNT_TASK_001', 'CONTACT_TASK_003'
        },
        'Acquisti via WEB' => new List<String>{
            'ACCOUNT_INSURANCEPOLICY_002'
        },
        'Richieste Digitali' => new List<String>{
            'CONTACT_TASK_007', 'CONTACT_TASK_004', 'ACCOUNT_UNSUB', 'CONTACT_TASK_008','ACCOUNT_CUSTOMEREVENT_RESETPASSWORD'
        }
    };

    public class HistoryItemWrapper implements Comparable {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String icon { get; set; }
        @AuraEnabled public String iconSVG { get; set; }
        @AuraEnabled public String communicationDirection { get; set; }
        @AuraEnabled public String communicationDirectionIcon { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String titleLink { get; set; }
        @AuraEnabled public String detail1 { get; set; }
        @AuraEnabled public String detail1Link { get; set; }
        @AuraEnabled public String detail1LinkNFE { get; set; }
        @AuraEnabled public String detail2 { get; set; }
        @AuraEnabled public String detail2Link { get; set; }
        @AuraEnabled public String detail2LinkNFE { get; set; }
        @AuraEnabled public String detail3 { get; set; }
        @AuraEnabled public String detail3Link { get; set; }
        @AuraEnabled public String detail3LinkNFE { get; set; }
        @AuraEnabled public String detail4 { get; set; }
        @AuraEnabled public String detail4Link { get; set; }
        @AuraEnabled public String detail4LinkNFE { get; set; }
        @AuraEnabled public String detail5 { get; set; }
        @AuraEnabled public String detail5Link { get; set; }
        @AuraEnabled public String detail5LinkNFE { get; set; }
        @AuraEnabled public Datetime dateAndTime { get; set; }
        @AuraEnabled public Datetime dateAndTimeLink { get; set; }
        @AuraEnabled public Boolean flagSent { get; set; }
        @AuraEnabled public Boolean flagOpen { get; set; }
        @AuraEnabled public Boolean flagClick { get; set; }
        @AuraEnabled public Boolean flagHardBounce { get; set; }
        @AuraEnabled public Boolean flagSoftBounce { get; set; }
        @AuraEnabled public String flagMouseoverSent { get; set; }
        @AuraEnabled public String flagMouseoverOpen { get; set; }
        @AuraEnabled public String flagMouseoverClick { get; set; }
        @AuraEnabled public String flagMouseoverBounce { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public String detailTitle {get;set;}
        @AuraEnabled public Boolean HideInNFE {get;set;}

        public HistoryItemWrapper() {
        }
        public HistoryItemWrapper(String label, String icon, String iconSVG, String communicationDirection, String communicationDirectionIcon, String title, String titleLink, String detail1, String detail1Link, String detail1LinkNFE, String detail2LinkNFE, String detail3LinkNFE, String detail4LinkNFE, 
                String detail2, String detail2Link, String detail3, String detail3Link, string detail4, String detail4Link, Datetime dateAndTime, Datetime dateAndTimeLink,
                Boolean flagSent, Boolean flagOpen, Boolean flagClick, Boolean flagHardBounce, Boolean flagSoftBounce,
                String flagMouseoverSent, String flagMouseoverOpen, String flagMouseoverClick, String flagMouseoverBounce) {
            this.label = label;
            this.icon = icon;
            this.iconSVG = iconSVG;
            this.communicationDirection = communicationDirection;
            this.communicationDirectionIcon = communicationDirectionIcon;
            this.title = title;
            this.titleLink = titleLink;
            this.detail1 = detail1;
            this.detail1Link = detail1Link;
            this.detail1LinkNFE = detail1LinkNFE;
            this.detail2 = detail2;
            this.detail2Link = detail2Link;
            this.detail2LinkNFE = detail2LinkNFE;
            this.detail3 = detail3;
            this.detail4 = detail4;
            this.detail4Link = detail4Link;
            this.detail4LinkNFE = detail4LinkNFE;
            this.detail3Link = detail3Link;
            this.detail3LinkNFE = detail3LinkNFE;
            this.dateAndTime = dateAndTime;
            this.dateAndTimeLink = dateAndTimeLink;
            this.flagSent = flagSent;
            this.flagOpen = flagOpen;
            this.flagClick = flagClick;
            this.flagHardBounce = flagHardBounce;
            this.flagSoftBounce = flagSoftBounce;
            this.flagMouseoverSent = flagMouseoverSent;
            this.flagMouseoverOpen = flagMouseoverOpen;
            this.flagMouseoverClick = flagMouseoverClick;
            this.flagMouseoverBounce = flagMouseoverBounce;
        }


        /** orders descending by 'dateAndTime'
        * if 'dateAndTime' are equals it orders ascending by 'title'
        */
        public Integer compareTo(Object compareTo) {
            HistoryItemWrapper compareToItem = (HistoryItemWrapper) compareTo;
            Integer returnValue = 0;
        if(this.dateAndTime!=null && compareToItem.dateAndTime!=null){
            if (this.dateAndTime > compareToItem.dateAndTime) {
                returnValue = -1; // DESC order
            } else if (this.dateAndTime < compareToItem.dateAndTime) {
                returnValue = 1;
            } else {
                if (this.title > compareToItem.title) {
                    returnValue = 1; // ASC order for title
                } else if (this.title < compareToItem.title) {
                    returnValue = -1;
                }
            }
            //ZA cr push 179
        }else if(this.dateAndTime==null){
            returnValue = 1;
        }else if(compareToItem.dateAndTime==null){
            returnValue = -1;
        }
            return returnValue;
        }
    }

    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<Object, Object> values { get; set; }
        @AuraEnabled public String CRMUrl;
        public ResponseDto(Boolean isSuccess, String msg) {
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
        }

        public ResponseDto() {
            this.isSuccess = false;
            this.message = '';
            this.values = new Map<Object, Object>();
        }
    }

    @AuraEnabled
    public static ResponseDto getHistoryItemWrappers(List<Id> ids, Integer limitResult) {
        return getHistoryItemWrappers(ids, limitResult, null);
    }


    /** Starting from a list of ids (assuming the ids are of the same sobject type),
     *  the method run a specific set of queries
     *  which are retrieved from the Custom Metadata Object 'Contact History Configuration'.
     *  Then it creates a list of standardised object
     *  which are ready to show in the view (lightning component).
     *
     * @param ids   List of ids (of sobject) received from the view
     *
     * @return a list of wrapper items (HistoryItemWrapper type), standardised for the view
     */
    @AuraEnabled
    public static ResponseDto getHistoryItemWrappers(List<Id> ids, Integer limitResult, String filtroTipologia) {
        ResponseDto responseDtoResult = new ResponseDto();
        try {
            if (Site.getSiteId()!= null) {
                String baseUrl = Site.getBaseUrl();
                if(baseUrl.contains('/tabs')){
                    baseUrl = baseUrl.replace('/tabs', '/crm');
                }
                responseDtoResult.CRMUrl = baseUrl;
                
            }
            else
                responseDtoResult.CRMUrl = '';
            System.debug('\n');
            List<Id> accountIds = new List<Id>();
            List<Id> contactIds = new List<Id>();
            List<Id> leadIds = new List<Id>();
            String recordFieldName;
            List<HistoryItemWrapper> historyItems = new List<HistoryItemWrapper>();
             //*-+ 2021
             List<HistoryItemWrapper> tasks_for_contact = new List<HistoryItemWrapper>();


            // retrieving the type of the IDs contained in parameter 'List<Id> ids' (assuming the list contains ids of the same type of object)
            Schema.SObjectType token = ids[0].getSobjectType();
            String sobjectType = token.getDescribe().getName();

            // getting all the record of the Contact History Configuration (Custom Metadata Object)
            String queryContactHistoryMDT = 'SELECT Id, Label, QualifiedApiName, Field_Type__c, ' +
                    'Query__c, Query2__c, Query2_Field_Id__c, Query2_Object__c, ' +
                    'Filter_SOQL_Field__c, Filter_SOQL_Values__c, Filter_SOQL_Operator__c, ' +
                    'Title__c, Title_Link__c, Icon_Component__c, IconSVG_Component__c, Communication_Direction__c, ' +
                    'Detail_1__c, Detail_1_Link__c, Detail_1_Link_NFE__c, Detail_2__c, Detail_2_Link__c, Detail_2_Link_NFE__c, Detail_3__c, Detail_3_Link__c, Detail_3_Link_NFE__c, Detail_4__c, Detail_4_Link__c, Detail_4_Link_NFE__c,' +
                    'Detail_5__c,Detail_5_Link__c,Detail_5_Link_NFE__c,Date_and_Time__c, Date_and_Time_Link__c, Date_Unsubscribed__c, ' +
                    'Flag_Open_Field__c, Flag_Open_Parameter__c, Flag_Open_Operator__c, ' +
                    'Flag_Sent_Field__c, Flag_Sent_Parameter__c, Flag_Sent_Operator__c, Icon__c, ' +
                    'Flag_Click_Field__c, Flag_Click_Parameter__c, Flag_Click_Operator__c, ' +
                    'Flag_Hard_Bounce_Field__c, Flag_Hard_Bounce_Parameter__c, Flag_Hard_Bounce_Operator__c, ' +
                    'Flag_Soft_Bounce_Field__c, Flag_Soft_Bounce_Parameter__c, Flag_Soft_Bounce_Operator__c, ' +
                    'Flag_Mouseover_Sent__c, Flag_Mouseover_Open__c, Flag_Mouseover_Bounce__c, Flag_Mouseover_Click__c, HideInNFE__c ' +
                    'FROM Contact_History_Configuration__mdt ';

            // creating the 'WHERE' conditions due to object type of ids
            // as result it gets only the custom metadata records interested
            switch on sobjectType {
                when 'Contact' {
                    List<SObject> accountList = [SELECT Id, Name FROM Account WHERE PersonContactId IN :ids];
                    if(accountList.size()>0) {
                        accountIds = convertSObjectListToIdList(accountList, 'Id');
                    }
                    SObject tempObj = [SELECT Name FROM Contact WHERE Id IN :ids LIMIT 1];
                    recordFieldName = (String)tempObj.get('Name');
                    contactIds = ids;

                    //checking if the Contact come from a Lead (It means a Lead was converted to Contact, thus its ContactHistoru need to be retrieved
                    List<Lead> convertedLeadList = [SELECT Id FROM Lead WHERE (ConvertedAccountId IN :accountIds) OR (ConvertedContactId IN :contactIds)];
                    if (convertedLeadList.size() > 0) {
                        // if result occurs all Contact_History_Configuration__mdt queries need to be performed
                        leadIds = convertSObjectListToIdList(convertedLeadList, 'Id');
                    } else {
                        // case when NO Lead were converted
                        queryContactHistoryMDT += 'WHERE Field_Type__c = \'Account/Contact\'';
                    }

                }
                when 'Account' {
                    List<SObject> contactList = [SELECT Id, Name FROM Contact WHERE AccountId IN :ids];
                    if(contactList.size()>0){
                        contactIds = convertSObjectListToIdList(contactList, 'Id');
                    }
                    SObject tempObj = [SELECT Name FROM Account WHERE Id IN :ids LIMIT 1];
                    recordFieldName = (String)tempObj.get('Name');
                    accountIds = ids;

                    //checking if the Contact come from a Lead (It means a Lead was converted to Contact, thus its ContactHistoru need to be retrieved
                    List<Lead> convertedLeadList = [SELECT Id FROM Lead WHERE (ConvertedAccountId IN :accountIds) OR (ConvertedContactId IN :contactIds)];
                    if (convertedLeadList.size() > 0) {
                        // if result occurs all Contact_History_Configuration__mdt queries need to be performed
                        leadIds = convertSObjectListToIdList(convertedLeadList, 'Id');
                    } else {
                        // case when NO Lead were converted
                        queryContactHistoryMDT += 'WHERE Field_Type__c = \'Account/Contact\'';
                    }
                }
                when 'Lead' {
                    List<SObject> leadList = [SELECT Id, Name FROM Lead WHERE Id IN :ids];
                    recordFieldName = (String) leadList[0].get('Name');
                    queryContactHistoryMDT += 'WHERE Field_Type__c = \'Lead\'';
                    leadIds = ids;
                }
            }

            System.debug('############### ID in ingresso, CONTACT: ' + contactIds);
            System.debug('############### ID in ingresso, ACCOUNT: ' + accountIds);
            System.debug('############### ID in ingresso, LEAD: ' + leadIds);

            if(String.isNotBlank(filtroTipologia)){
                List<String> tipologie = TIPOLOGIA_COMUNICAZIONE_CONFIGURATION_MAP.get(filtroTipologia);
                queryContactHistoryMDT += ' AND DeveloperName in: tipologie';

            } 

            List<Contact_History_Configuration__mdt> contactHistoryMDT = new List<Contact_History_Configuration__mdt>();

            try {
                contactHistoryMDT = (List<Contact_History_Configuration__mdt>) Database.query(queryContactHistoryMDT);
            } catch (Exception e) {
                System.debug('___________ERRORE ' + e.getMessage());
            }

            System.debug('############### Contact History Metadata for TYPE: ' + sobjectType + ', LIST SIZE: ' + contactHistoryMDT.size());

            // loops each custom metadata record and if result occurs it generates instances of HistoryItemWrapper
            for (Contact_History_Configuration__mdt config : contactHistoryMDT) {

                String query1 = config.Query__c;
                String query2 = config.Query2__c;
                Map <Id, List<SObject>> mapQueryResult = new Map <Id, List<SObject>>();
                List<SObject> query1Result = new List<SObject>();
                List<SObject> query2Result = new List<SObject>();

                //counting the couples of '§' (number of parameters to substitute)
                Integer numOfParams = query1.countMatches('§') / 2;

                if (numOfParams > 0) {
                    for (Integer i = 0; i < numOfParams; i++) {
                        String parameter = searchParameterToReplace(query1);
                        switch on parameter {
                            when 'contactIds' {
                                query1 = query1.replace('§contactIds§', 'contactIds');
                            }
                            when 'accountIds' {
                                query1 = query1.replace('§accountIds§', 'accountIds');
                            }
                            when 'leadIds' {
                                query1 = query1.replace('§leadIds§', 'leadIds');
                            }
                        }
                    }
                }
                System.debug('############### LABEL ' + config.Label);
                System.debug('############### QUERY 1 to run: ' + query1);
                try {
                    query1Result = Database.query(query1);
                    System.debug('############### QUERY 1 RESULT ' + query1Result);
                } catch (Exception e) {
                    System.debug('___________ERRORE ' + e.getMessage());
                }

                if (String.isNotBlank(config.Filter_SOQL_Field__c) && String.isNotBlank(config.Filter_SOQL_Operator__c) && String.isNotBlank(config.Filter_SOQL_Values__c)) {
                    List<String> filterSOQLValues = String.valueOf(config.Filter_SOQL_Values__c).split(';');
                    switch on config.Filter_SOQL_Operator__c {
                        when 'equals' {
                            for (Integer i = 0; i < query1Result.size(); i++) {
                                if (filterSOQLValues.contains((String) query1Result[i].get(config.Filter_SOQL_Field__c))) {
                                    query1Result.remove(i);
                                }
                            }
                        }
                        when 'not equals' {
                            for (Integer i = 0; i < query1Result.size(); i++) {
                                if (!filterSOQLValues.contains((String) query1Result[i].get(config.Filter_SOQL_Field__c))) {
                                    query1Result.remove(i);
                                }
                            }
                        }
                    }
                }
                if (query1Result.size() > 0) {
                    // case when only query1 is run
                    if (query2 == null) {
                        for (SObject sobj1 : query1Result) {
                            System.debug('############### generate ITEM from QUERY 1');
                            HistoryItemWrapper temp1_query1 = generateHistoryItem(config, sobj1, null) ;               
                            if(temp1_query1.recordType == 'Task'|| temp1_query1.recordType == 'Event')
                            tasks_for_contact.add(temp1_query1);
 
                            historyItems.add(temp1_query1);
                        }
                    } else { // query2 != null, thus running query1 and query2
                        String parameterQuery2 = searchParameterToReplace(query2); // = config.Query2_Field_Id__c
                        List<Id> query1IdsResult = new List<Id>();
                        query1IdsResult = convertSObjectListToIdList(query1Result, parameterQuery2);
                        query2 = query2.replace('§' + parameterQuery2 + '§', 'query1IdsResult');
                        System.debug('############### NEW QUERY 2: ' + query2);

                        for (SObject sobj1 : query1Result) {
                            // gets from the record of Query-1 the field to substitute in Query-2 (they have the same label name)
                            // e.g.: Query-1 -> Select WHOID From object, Query-2 -> Select name From object Where id in :WHOID
                            Id currentKey = (Id) sobj1.get(parameterQuery2); // ottengo (da query1) il valore da sostituire nella WHERE della query2
                            Boolean keyUsed = mapQueryResult.containsKey(currentKey);
                            List<SObject> tempList;

                            if (keyUsed) { // if key already used, getting the existing result to later updating
                                tempList = mapQueryResult.get(currentKey);
                            } else {
                                tempList = new List<SObject>(); // no key found, creating new element for the map
                            }
                            tempList.add(sobj1);
                            mapQueryResult.put(currentKey, tempList);
                        }

                        try {
                            query2Result = Database.query(query2); // run Query-2
                            System.debug('############### QUERY 2 RESULT ' + query2Result);
                        } catch (Exception e) {
                            System.debug('___________ERRORE ' + e.getMessage());
                        }

                        // looping through results of Query-2 matching results of Query-1 using the Map
                        for (SObject sobj2 : query2Result) {
                            // 'Query2_Field_Id__c' is the field name of Query-2 where the condition operate on.
                            // e.g.: Query-1 -> Select Id, params From Object1
                            // e.g.: Query-2 -> Select id From Object2 Where LEAD__c in :params -> Query2_Field_Id__c == LEAD__c
                            // e.g.: Query-2 -> Select id From Object2 Where ID in :params -> Query2_Field_Id__c == ID
                            Id currentKey = (Id) sobj2.get(config.Query2_Field_Id__c);
                            Boolean keyUsed = mapQueryResult.containsKey(currentKey);
                            if (keyUsed) {
                                List<SObject> tempList;
                                tempList = mapQueryResult.get(currentKey);
                                for (SObject sobj1 : tempList) {
                                    System.debug('############### generate ITEM from QUERY 1 and QUERY 2');
                                    // object temps == task agginggi lista  generateHistoryItem(config, sobj1, sobj2)
                                    HistoryItemWrapper temp2_query2 = generateHistoryItem(config, sobj1, sobj2) ;

                                    if(temp2_query2.recordType == 'Task'|| temp2_query2.recordType == 'Event')
                                    tasks_for_contact.add(temp2_query2);

                                    historyItems.add(temp2_query2);
 
                                }
                                
                            }
                        }
                    }
                }
            }
            if(!Errors.isEmpty()) {
                ApplicationLogHelper.LogErrors('ContactHistoryCTRL', Errors);
                Errors.clear();
            }
            //su la lista dei task posso chiamare il metodo da fare con query con user 

            // Mapa scorre HsitoryItems prendo id e uso per la mapa , si è falso tolgo detaillink lo faccio NULL 

             if (historyItems.size() > 0) historyItems.sort(); //sorting by field dateAndTime
            //System.debug('\n############### HISTORY ITEMS LIST SORT BY DATE' + JSON.serialize(historyItems));

             //nascondere le task che non sono del Utente attuale. 
             Map<Id,Boolean> TaskVisibility = TasksNonShareToUserAttual(tasks_for_contact); 

             for(HistoryItemWrapper task_pivot: tasks_for_contact)
                 if(TaskVisibility.get(task_pivot.recordId)==false)
                  task_pivot.detailTitle = null ;
    
           
          
            Integer originalResultListSize = historyItems.size();

            // if request is from MOBILE APP, it NEVER cut off the results
            if (UserInfo.getUiThemeDisplayed().equals('Theme4t')) {
                limitResult = 0;
            }
            // if parameter 'limitResult' of current function is greater than 0,
            // then we need to cut off the full result
            if (limitResult > 0) {
                List<HistoryItemWrapper> croppedResultList = new List <HistoryItemWrapper>();
                for (Integer i = 0; i < limitResult && i < historyItems.size(); i++) {
                    croppedResultList.add(historyItems.get(i));
                }
                // updating the returning variable with the cut off list
                historyItems = croppedResultList;
            }

            responseDtoResult.isSuccess = true;
            responseDtoResult.values.put('ContactHistoryList', historyItems);
            responseDtoResult.values.put('ContactHistoryFullListSize', originalResultListSize);
            responseDtoResult.values.put('RecordFieldName', recordFieldName);
            responseDtoResult.values.put('PlatformSource', UserInfo.getUiThemeDisplayed());
//            System.debug(responseDtoResult);
        } catch (Exception e) {
            System.debug(e.getMessage());
            responseDtoResult.message = e.getMessage();
        }
        return responseDtoResult;
    }
    /** It generates a single item of generic type HistoryItemWrapper based on queries results.
     *  If results come from just Query-1, parameter 'sobj2' must be 'NULL'
     *  If results come from Query-1 and Query-2 both parameters must be NOT 'null'
     *
     * @param config    Specific record of the custom metadata type 'Contact History Configuration'
     * @param sobj1     SObject get as result from Query-1
     * @param sobj2     SObject get as result from Query-2 strictly related to 'sobj1'
     *
     * @return an item of generic type HistoryItemWrapper
     */
    @testvisible
    private static HistoryItemWrapper generateHistoryItem(Contact_History_Configuration__mdt config, SObject sobj1, SObject sobj2) {
        List<String> noRedirect = new List<String>{
            'InsurancePolicy__c',
            'Proposta__c',
            'Opportunity'
        };
        String label = config.Label;
        String icon = config.Icon_Component__c;
        String iconSVG = config.IconSVG_Component__c;
        String communicationDirection; 
        String communicationDirectionIcon; 
        String title;
        String titleLink;
        String detail1;
        String detail1Link;
        String detail1LinkNFE;
        String detail2;
        String detail2Link;
        String detail2LinkNFE;
        String detail3;
        String detail4;
        String detail4Link;
        String detail4LinkNFE;
        String detail3Link;
        String detail3LinkNFE;
        String detail5;
        String detail5Link;
        String detail5LinkNFE;
        Datetime dateAndTime;
        Datetime dateAndTimeLink;
        Datetime dateUnsubscribed;
        Boolean flagSent;
        Boolean flagOpen;
        Boolean flagClick;
        Boolean flagHardBounce;
        Boolean flagSoftBounce;
        String flagMouseoverSent;
        String flagMouseoverOpen;
        String flagMouseoverClick;
        String flagMouseoverBounce;
        String fromQuery2Object = config.Query2_Object__c;
        String recordId;
        String recordType;
        String detailTitle;
        // STARTS THE INITIALIZATION of every field of the 'HistoryItemWrapper'

        map<String, String> apiToTitle = new Map<String, String>{
            'et4ae5__IndividualEmailResult__c' => 'Dettaglio comunicazione inviata'
        };
        if(sobj2 != null){
            String rt = sobj2.getSObjectType().getDescribe().getName();
            if(!noRedirect.contains(rt)){
                recordType = rt;
                recordId = sobj2.Id;
                if(apiToTitle.containsKey(rt))
                    detailTitle = apiToTitle.get(rt);
                else
                    detailTitle = sobj2.getSObjectType().getDescribe().getLabel();
            }
            
        }
        else{
            String rt = sobj1.getSObjectType().getDescribe().getName();
            if(!noRedirect.contains(rt)){
                recordId = sobj1.Id;
                recordType = rt;
                if(apiToTitle.containsKey(rt))
                    detailTitle = apiToTitle.get(rt);
                else
                    detailTitle = sobj1.getSObjectType().getDescribe().getLabel();
            }
            
        }
        if (config.Title__c != null) {
            title = config.Title__c;
            if (title.contains('§' + fromQuery2Object + '.')) {
                title = title.replace('§' + fromQuery2Object + '.', '§');
                title = replaceParameter(title, sobj2);
            } else {
                title = replaceParameter(title, sobj1);
            }
        }
        if (config.Title_Link__c != null) {
            titleLink = config.Title_Link__c;
            if (titleLink.contains('§' + fromQuery2Object + '.')) {
                titleLink = titleLink.replace('§' + fromQuery2Object + '.', '§');
                titleLink = replaceParameter(titleLink, sobj2);
            } else {
                titleLink = replaceParameter(titleLink, sobj1);
            }
        }
        if (config.Detail_1__c != null) {
            detail1 = config.Detail_1__c;
            if (detail1.contains('§' + fromQuery2Object + '.')) {
                detail1 = detail1.replace('§' + fromQuery2Object + '.', '§');
                detail1 = replaceParameter(detail1, sobj2);
            } else {
                detail1 = replaceParameter(detail1, sobj1);
            }
        }
        if (config.Detail_1_Link__c != null) {
            detail1Link = config.Detail_1_Link__c;
            if (detail1Link.contains('§' + fromQuery2Object + '.')) {
                detail1Link = detail1Link.replace('§' + fromQuery2Object + '.', '§');
                detail1Link = replaceParameter(detail1Link, sobj2);
            } else {
                detail1Link = replaceParameter(detail1Link, sobj1);
            }
        }
        if (config.Detail_1_Link_NFE__c != null) {
            detail1LinkNFE = config.Detail_1_Link_NFE__c;
            if (detail1LinkNFE.contains('§' + fromQuery2Object + '.')) {
                detail1LinkNFE = detail1LinkNFE.replace('§' + fromQuery2Object + '.', '§');
                detail1LinkNFE = replaceParameter(detail1LinkNFE, sobj2);
            } else {
                detail1LinkNFE = replaceParameter(detail1LinkNFE, sobj1);
            }
        }
        if (config.Detail_2__c != null) {
            detail2 = config.Detail_2__c;
            if (detail2.contains('§' + fromQuery2Object + '.')) {
                detail2 = detail2.replace('§' + fromQuery2Object + '.', '§');
                detail2 = replaceParameter(detail2, sobj2);
            } else {
                detail2 = replaceParameter(detail2, sobj1);
            }
        }
        if (config.Detail_2_Link__c != null) {
            detail2Link = config.Detail_2_Link__c;
            if (detail2Link.contains('§' + fromQuery2Object + '.')) {
                detail2Link = detail2Link.replace('§' + fromQuery2Object + '.', '§');
                detail2Link = replaceParameter(detail2Link, sobj2);
            } else {
                detail2Link = replaceParameter(detail2Link, sobj1);
            }
        }
        if (config.Detail_2_Link_NFE__c != null) {
            detail2LinkNFE = config.Detail_2_Link_NFE__c;
            if (detail2LinkNFE.contains('§' + fromQuery2Object + '.')) {
                detail2LinkNFE = detail2LinkNFE.replace('§' + fromQuery2Object + '.', '§');
                detail2LinkNFE = replaceParameter(detail2LinkNFE, sobj2);
            } else {
                detail2LinkNFE = replaceParameter(detail2LinkNFE, sobj1);
            }
        }
        if (config.Detail_3__c != null) {
            detail3 = config.Detail_3__c;
            if (detail3.contains('§' + fromQuery2Object + '.')) {
                detail3 = detail3.replace('§' + fromQuery2Object + '.', '§');
                detail3 = replaceParameter(detail3, sobj2);
            } else {
                detail3 = replaceParameter(detail3, sobj1);
            }
        }
        if (config.Detail_3_Link__c != null) {
            detail3Link = config.Detail_3_Link__c;
            if (detail3Link.contains('§' + fromQuery2Object + '.')) {
                detail3Link = detail3Link.replace('§' + fromQuery2Object + '.', '§');
                detail3Link = replaceParameter(detail3Link, sobj2);
            } else {
                detail3Link = replaceParameter(detail3Link, sobj1);
            }
        }
        if (config.Detail_3_Link_NFE__c != null) {
            detail3LinkNFE = config.Detail_3_Link_NFE__c;
            if (detail3LinkNFE.contains('§' + fromQuery2Object + '.')) {
                detail3LinkNFE = detail3LinkNFE.replace('§' + fromQuery2Object + '.', '§');
                detail3LinkNFE = replaceParameter(detail3LinkNFE, sobj2);
            } else {
                detail3LinkNFE = replaceParameter(detail3LinkNFE, sobj1);
            }
        }
        if (config.Detail_4__c != null) {
            detail4 = config.Detail_4__c;
            if (detail4.contains('§' + fromQuery2Object + '.')) {
                detail4 = detail4.replace('§' + fromQuery2Object + '.', '§');
                detail4 = replaceParameter(detail4, sobj2);
            } else {
                detail4 = replaceParameter(detail4, sobj1);
            }
        }
        if (config.Detail_4_Link__c != null) {
            detail4Link = config.Detail_4_Link__c;
            if (detail4Link.contains('§' + fromQuery2Object + '.')) {
                detail4Link = detail4Link.replace('§' + fromQuery2Object + '.', '§');
                detail4Link = replaceParameter(detail4Link, sobj2);
            } else {
                detail4Link = replaceParameter(detail4Link, sobj1);
            }
        }
        if (config.Detail_4_Link_NFE__c != null) {
            detail4LinkNFE = config.Detail_4_Link_NFE__c;
            if (detail4LinkNFE.contains('§' + fromQuery2Object + '.')) {
                detail4LinkNFE = detail4LinkNFE.replace('§' + fromQuery2Object + '.', '§');
                detail4LinkNFE = replaceParameter(detail4LinkNFE, sobj2);
            } else {
                detail4LinkNFE = replaceParameter(detail4LinkNFE, sobj1);
            }
        }
        if (config.Detail_5__c != null) {
            detail5 = config.Detail_5__c;
            if (detail5.contains('§' + fromQuery2Object + '.')) {
                detail5 = detail5.replace('§' + fromQuery2Object + '.', '§');
                detail5 = replaceParameter(detail5, sobj2);
            } else {
                detail5 = replaceParameter(detail5, sobj1);
            }
        }
        if (config.Detail_5_Link__c != null) {
            detail5Link = config.Detail_5_Link__c;
            if (detail5Link.contains('§' + fromQuery2Object + '.')) {
                detail5Link = detail5Link.replace('§' + fromQuery2Object + '.', '§');
                detail5Link = replaceParameter(detail5Link, sobj2);
            } else {
                detail5Link = replaceParameter(detail5Link, sobj1);
            }
        }
        if (config.Detail_5_Link_NFE__c != null) {
            detail5LinkNFE = config.Detail_5_Link_NFE__c;
            if (detail5LinkNFE.contains('§' + fromQuery2Object + '.')) {
                detail5LinkNFE = detail5LinkNFE.replace('§' + fromQuery2Object + '.', '§');
                detail5LinkNFE = replaceParameter(detail5LinkNFE, sobj2);
            } else {
                detail5LinkNFE = replaceParameter(detail5LinkNFE, sobj1);
            }
        }
        if (config.Date_and_Time__c != null) {
            String tempDateAndTime = config.Date_and_Time__c;
            if (tempDateAndTime.contains('§' + fromQuery2Object + '.')) {
                tempDateAndTime = tempDateAndTime.replace('§' + fromQuery2Object + '.', '§');
                tempDateAndTime = replaceParameter(tempDateAndTime, sobj2);
            } else {
                tempDateAndTime = replaceParameter(tempDateAndTime, sobj1);
            }
            try { // trying converting a String to Datetime type
                dateAndTime = Datetime.valueOf(tempDateAndTime);

            } catch (Exception e1) {
                try {
                    // if gets an error is possible that input was 'Date' instead of 'Datetime'
                    // then it tries again to convert Date to Datetime (time will be 00:00:00)
                    dateAndTime = Date.valueOf(tempDateAndTime);
                } catch (Exception e2) {
                    if(String.isNotBlank(tempDateAndTime))
                    Errors.add(new ApplicationLogHelper.ErrorWrapper(e2.getMessage(), e2.getStackTraceString()));                    
                }
            }
        }
        if (config.Date_and_Time_Link__c != null) {
            String tempDateAndTimeLink = config.Date_and_Time_Link__c;
            if (tempDateAndTimeLink.contains('§' + fromQuery2Object + '.')) {
                tempDateAndTimeLink = tempDateAndTimeLink.replace('§' + fromQuery2Object + '.', '§');
                tempDateAndTimeLink = replaceParameter(tempDateAndTimeLink, sobj2);
            } else {
                tempDateAndTimeLink = replaceParameter(tempDateAndTimeLink, sobj1);
            }
            try { // trying converting a String to Datetime type
                dateAndTimeLink = Datetime.valueOf(tempDateAndTimeLink);
            } catch (Exception e1) {
                try {
                    // if gets an error is possible that input was 'Date' instead of 'Datetime'
                    // then it tries again to convert Date to Datetime (time will be 00:00:00)
                    dateAndTimeLink = Date.valueOf(tempDateAndTimeLink);
                } catch (Exception e2) {
                    if(String.isNotBlank(tempDateAndTimeLink))
                    Errors.add(new ApplicationLogHelper.ErrorWrapper(e2.getMessage(), e2.getStackTraceString()));
                    
                }
            }
        }
        if (config.Date_Unsubscribed__c != null) {
            String tempDateUnsubscribed = config.Date_Unsubscribed__c;
            if (tempDateUnsubscribed.contains('§' + fromQuery2Object + '.')) {
                tempDateUnsubscribed = tempDateUnsubscribed.replace('§' + fromQuery2Object + '.', '§');
                tempDateUnsubscribed = replaceParameter(tempDateUnsubscribed, sobj2);
            } else {
                tempDateUnsubscribed = replaceParameter(tempDateUnsubscribed, sobj1);
            }
            try { // trying converting a String to Datetime type
                dateUnsubscribed = Datetime.valueOf(tempDateUnsubscribed);
            } catch (Exception e1) {
                try {
                    // if gets an error is possible that input was 'Date' instead of 'Datetime'
                    // then it tries again to convert Date to Datetime (time will be 00:00:00)
                    dateUnsubscribed = Date.valueOf(tempDateUnsubscribed);
                } catch (Exception e2) {
                    if(String.isNotBlank(tempDateUnsubscribed))
                    Errors.add(new ApplicationLogHelper.ErrorWrapper(e2.getMessage(), e2.getStackTraceString())); 
                }
            }
        }
        if (config.Flag_Sent_Field__c != null) {
            String flagSentField = config.Flag_Sent_Field__c;
            if (flagSentField.contains('§' + fromQuery2Object + '.')) {
                flagSentField = flagSentField.replace('§' + fromQuery2Object + '.', '§');
                flagSentField = replaceParameter(flagSentField, sobj2);
            } else {
                flagSentField = replaceParameter(flagSentField, sobj1);
            }
            flagSent = flagComparison(flagSentField, config.Flag_Sent_Operator__c, config.Flag_Sent_Parameter__c);
        }
        if (config.Flag_Open_Field__c != null) {
            String flagOpenField = config.Flag_Open_Field__c;
            if (flagOpenField.contains('§' + fromQuery2Object + '.')) {
                flagOpenField = flagOpenField.replace('§' + fromQuery2Object + '.', '§');
                flagOpenField = replaceParameter(flagOpenField, sobj2);
            } else {
                flagOpenField = replaceParameter(flagOpenField, sobj1);
            }
            flagOpen = flagComparison(flagOpenField, config.Flag_Open_Operator__c, config.Flag_Open_Parameter__c);
        }
        if (config.Flag_Click_Field__c != null) {
            String flagClickField = config.Flag_Click_Field__c;
            if (flagClickField.contains('§' + fromQuery2Object + '.')) {
                flagClickField = flagClickField.replace('§' + fromQuery2Object + '.', '§');
                flagClickField = replaceParameter(flagClickField, sobj2);
            } else {
                flagClickField = replaceParameter(flagClickField, sobj1);
            }
            if (dateUnsubscribed != null ) {
                flagClick = false;
                flagOpen = true;
            } else {
                flagClick = flagComparison(flagClickField, config.Flag_Click_Operator__c, config.Flag_Click_Parameter__c);
            }
        }
        if (config.Flag_Hard_Bounce_Field__c != null) {
            String flagHardBounceField = config.Flag_Hard_Bounce_Field__c;
            if (flagHardBounceField.contains('§' + fromQuery2Object + '.')) {
                flagHardBounceField = flagHardBounceField.replace('§' + fromQuery2Object + '.', '§');
                flagHardBounceField = replaceParameter(flagHardBounceField, sobj2);
            } else {
                flagHardBounceField = replaceParameter(flagHardBounceField, sobj1);
            }
            flagHardBounce = flagComparison(flagHardBounceField, config.Flag_Hard_Bounce_Operator__c, config.Flag_Hard_Bounce_Parameter__c);
        }
        if (config.Flag_Soft_Bounce_Field__c != null) {
            String flagSoftBounceField = config.Flag_Soft_Bounce_Field__c;
            if (flagSoftBounceField.contains('§' + fromQuery2Object + '.')) {
                flagSoftBounceField = flagSoftBounceField.replace('§' + fromQuery2Object + '.', '§');
                flagSoftBounceField = replaceParameter(flagSoftBounceField, sobj2);
            } else {
                flagSoftBounceField = replaceParameter(flagSoftBounceField, sobj1);
            }
            flagSoftBounce = flagComparison(flagSoftBounceField, config.Flag_Soft_Bounce_Operator__c, config.Flag_Soft_Bounce_Parameter__c);
        }
        if (config.Flag_Mouseover_Sent__c != null) {
            flagMouseoverSent = config.Flag_Mouseover_Sent__c;
            if (flagMouseoverSent.contains('§' + fromQuery2Object + '.')) {
                flagMouseoverSent = flagMouseoverSent.replace('§' + fromQuery2Object + '.', '§');
                flagMouseoverSent = replaceParameter(flagMouseoverSent, sobj2);
            } else {
                flagMouseoverSent = replaceParameter(flagMouseoverSent, sobj1);
            }
        }
        if (config.Flag_Mouseover_Open__c != null) {
            flagMouseoverOpen = config.Flag_Mouseover_Open__c;
            if (flagMouseoverOpen.contains('§' + fromQuery2Object + '.')) {
                flagMouseoverOpen = flagMouseoverOpen.replace('§' + fromQuery2Object + '.', '§');
                flagMouseoverOpen = replaceParameter(flagMouseoverOpen, sobj2);
            } else {
                if (flagMouseoverOpen.contains('§')) { // need to split the string, to format properly the result as dd-mm-yyyy hh:mm
                    String openingDate = flagMouseoverOpen.substring(flagMouseoverOpen.indexOf('§'));
                    flagMouseoverOpen = flagMouseoverOpen.remove(openingDate);
                    System.debug('===> sobj1: ' + sobj1);
                    openingDate = replaceParameter(openingDate, sobj1);
                    try {
                        Datetime temp1 = Datetime.valueOfGMT(openingDate);
                        System.debug('===> temp1: ' + temp1);
                        String timeZone = '' + UserInfo.getTimeZone();
                        System.debug('===> timeZone: ' + timeZone);
                        openingDate = temp1.format('dd-MM-yyyy HH:mm', timeZone);
                        System.debug('===> openingDate: ' + openingDate);
                    } catch (Exception e1) {
                        try {
                            Date temp2 = Date.valueOf(openingDate);
                            openingDate = temp2.format();
                        } catch (Exception e2) {
                            System.debug(e2.getMessage());
                            System.debug('Cannot convert the value as Datetime or Date');
                        }
                    }
                    flagMouseoverOpen += openingDate;
                }
            }
        }
        if (config.Flag_Mouseover_Click__c != null) {
            flagMouseoverClick = config.Flag_Mouseover_Click__c;
            if (flagMouseoverClick.contains('§' + fromQuery2Object + '.')) {
                flagMouseoverClick = flagMouseoverClick.replace('§' + fromQuery2Object + '.', '§');
                flagMouseoverClick = replaceParameter(flagMouseoverClick, sobj2);
            } else {
                if (flagMouseoverClick.contains('§')) { // need to split the string, to format properly the result as dd-mm-yyyy hh:mm
                    String openingDate = flagMouseoverClick.substring(flagMouseoverClick.indexOf('§'));
                    flagMouseoverClick = flagMouseoverClick.remove(openingDate);
                    System.debug('===> sobj1: ' + sobj1);
                    openingDate = replaceParameter(openingDate, sobj1);
                    try {
                        Datetime temp1 = Datetime.valueOfGMT(openingDate);
                        System.debug('===> temp1: ' + temp1);
                        String timeZone = '' + UserInfo.getTimeZone();
                        System.debug('===> timeZone: ' + timeZone);
                        openingDate = temp1.format('dd-MM-yyyy HH:mm', timeZone);
                        System.debug('===> openingDate: ' + openingDate);
                    } catch (Exception e1) {
                        try {
                            Date temp2 = Date.valueOf(openingDate);
                            openingDate = temp2.format();
                        } catch (Exception e2) {
                            System.debug(e2.getMessage());
                            System.debug('Cannot convert the value as Datetime or Date');
                        }
                    }
                    flagMouseoverClick += openingDate;
                }
            }
        }
        if (config.Flag_Mouseover_Bounce__c != null) {
            flagMouseoverBounce = config.Flag_Mouseover_Bounce__c;
            if (flagMouseoverBounce.contains('§' + fromQuery2Object + '.')) {
                flagMouseoverBounce = flagMouseoverBounce.replace('§' + fromQuery2Object + '.', '§');
                flagMouseoverBounce = replaceParameter(flagMouseoverBounce, sobj2);
            } else {
                flagMouseoverBounce = replaceParameter(flagMouseoverBounce, sobj1);
            }
        }


        HistoryItemWrapper hstItem = new HistoryItemWrapper(
                label, icon, iconSVG, communicationDirection, communicationDirectionIcon, title, titleLink, detail1, detail1Link, detail1LinkNFE, detail2LinkNFE, detail3LinkNFE, detail4LinkNFE, detail2, detail2Link,
                detail3, detail3Link, detail4, detail4Link,dateAndTime, dateAndTimeLink,
                flagSent, flagOpen, flagClick, flagHardBounce, flagSoftBounce,
                flagMouseoverSent, flagMouseoverOpen, flagMouseoverClick, flagMouseoverBounce);
        System.debug('############### ITEM GENERATED ' + JSON.serialize(hstItem));
        hstItem.recordId = recordId;
        hstItem.recordType = recordType;
        hstItem.detailTitle = detailTitle;
        hstItem.detail5  = detail5;
        hstItem.detail5Link = detail5Link;
        hstItem.detail5LinkNFE = detail5LinkNFE;
        hstItem.HideInNFE = config.HideInNFE__c;
        return hstItem;
    }

    /** It compares a field (of sobject) to a parameter based on a specific operator.
     *  Field: value get from the specific sobject. It is what we want to compare.
     *  Parameter: target of the comparison. It is what  we want to be compared to.
     *  Operator: which operation must be done (e.g.: equals, \<, \>, ==, !=, etc).
     *
     * @param field       value get from the specific sobject. It is what we want to compare.
     * @param operator    which operation must be done (e.g.: equals, \<, \>, ==, !=, etc).
     * @param parameter   target of the comparison. It is what  we want to be compared to.
     *
     * @return true/false based on comparison
     */
    private static Boolean flagComparison(String field, String operator, String parameter) {
        switch on operator {
            when 'equals' {
                if (field.equals(parameter)) {
                    return true;
                }
            }
            /* actually no other case exist, however belowe example explains different operator case
            when '>' {
                if( field > parameter ) {
                    return true;
                }
            */
            when else {
                return false;
            }
        }
        return false;
    }

    /** Giving a content as string and a SObject
     *  the function searches for a parameter (included in '§' character) to be replace
     *  with the corresponding field value contained in the SObject.
     *  e.g.:   content -> This is a test: §field__c§
     *          sobj -> {id: 098, field__c: 'someValueExample'}
     *          result This is a test: someValueExample
     *
     * @param content   string where to look a parameter to be replaced
     * @param sobj      sobject that contains the field value to put in the string
     *
     * @return 'content' with parameter replaced using query result or null if query field has nothing inside
     */
    public static String replaceParameter(String content, SObject sobj) {
        Integer numberOfParams = content.countMatches('§') / 2;

        try {
            // the loop handles generic case for n substitution (ex: 'Detail1 is §Name§ and §Surname§')
            for (Integer i = 0; i < numberOfParams; i++) {
                fromFunctionReplaceParameter = true;
                String parameter = searchParameterToReplace(content);
                String replacingWith = getSObjectFieldValue(parameter, sobj);
                if (replacingWith.equals('')) { // in case the method getSObjectFieldValue(..) has no result, the content will be empty
                    content = '';
                } else {
                    content = content.replace('§' + parameter + '§', replacingWith);
                }
            }
        } catch (Exception e) {
            System.debug(e);
            System.debug(content);
        }
        return content;
    }

    /** It gets a field value stored in a generic object. Counting if dots are contained in 'content'
     *  it understands how many parent relationship are requested.
     *  If not no lookup relationships occur, it gets directly the field in sobject,
     *  otherwise navigate through sobject to reach the last (requested) in hierarchy.
     *  When last parent is reached, it gives back the field value requested.
     *
     *
     * @param content   string specifying the field to read inside the sobj.
     *                  It is possible even to have generic lookup relationship with arbitrary number of parent (e.g. Parent.field)
     * @param sobj      SObject source where to find the value of field read in content
     *
     * @return field value found as result
     */
    private static String getSObjectFieldValue(String content, SObject sobj) {
        Integer numberOfDots = content.countMatches('.');
        // ciclo per ogni '.' (DOPO una stringa), ovvero leggo tutti gli OGGETTI per risalire nella relazione
        // l'ultima sottostringa corrisponde al PARAMETRO e NON ha un '.' successivamente
        // es.: GrandParent.GrandGrandParent.field
        // 1-> 'GrandParent', 2-> 'GrandGrandParent'.
        for (Integer i = 0; i < numberOfDots && sobj != null; i++) {
            String nextParent = content.substring(0, content.indexOf('.'));
            sobj = sobj.getSObject(nextParent);
            if (sobj != null) {
                content = content.remove(nextParent + '.');
            }
        }
        // in questo momento in 'temp' è contenuto l'ultimo PADRE della catena e in 'content' è rimasto solo il FIELD da leggere
        String result = '';
        try {
            // error could be thrown by 'sobj.get(content)' in case sobj is null or content is not found
            if (sobj.get(content) != null) {
                result = '' + sobj.get(content);
            }
        } catch (Exception e) {
            System.debug('_______________ HANDLING ERROR during getSObjectFieldValue(..) ');
            System.debug('_______________ Nothing found to substitute: ');
            System.debug('_______________ ' + e.getMessage());
        }
        return result;
    }

    /** It finds inside a string ('content') the parameter between '§' to be replaced.
     *  The function is usually called by 'replaceParameter(..)' function
     *  which already check if 'content' contains '§'.
     *  In rare case the call come from othe block of code,
     *  then the function checks the boolean value 'fromFunctionReplaceParameter'.
     *  If fromFunctionReplaceParameter is 'FALSE' it needs to check '§' to avoid unexcpected errors.
     *
     *
     * @param content   string which should contains a parameter written between '§' (e.g.: "Check this §field__c§")
     *
     * @return name of parameter found as string, or null if nothing occurs
     */
    private static String searchParameterToReplace(String content) {
        try {
            // static flag to check if the call come from function that already check if 'content' contains'
            if (!fromFunctionReplaceParameter) { // need to check if '§' is presents in 'content'
                if (!content.contains('§')) {
                    return null; // nothing found
                }
            }
            Integer index1 = content.indexOf('§');
            Integer index2 = content.indexOf('§', index1 + 1);
            String parameter = content.substring(index1 + 1, index2);
            fromFunctionReplaceParameter = false;
            return parameter;
        } catch (Exception e) {
            System.debug(e);
            System.debug(content);
            return null;
        }
    }

    /** Read a list of generic objects, getting all the 'idField' of type ID and creates a new list of ids.
     *
     * @param sobjectList   it's the list target of generic objects to convert in id list
     * @param idField       specifies the field where to read the ID value
     *
     * @return new list of ID type
     */
    private static List<Id> convertSObjectListToIdList(List<SObject> sobjectList, String idField) {
        List<Id> result = new List<Id>();
        for (SObject so : sobjectList) {
            try {
                result.add((Id) so.get(idField)); //this casting could cause an error
            } catch (Exception e) {
                // Common error: param 'idField' has not value of type ID inside
                System.debug(e);
            }
        }
        return result;
    }
    //metodo con sharing
     /** Read a list of Ids in this case taks and return a Map of IDs and boolean
      * one id related to his visibility 
     *
     * @param tasks   it's the list target of generic objects to convert in id list
     * 
     *
     * @return new Map of ID and boolean if a tas can see for a user
     */
    private static Map<Id,Boolean> TasksNonShareToUserAttual(List<HistoryItemWrapper> tasks) {
        Map<Id,Boolean> TaskVisibility = new Map<Id,Boolean> ();
        for(HistoryItemWrapper task_visibile : tasks)
        TaskVisibility.put(task_visibile.recordId, false);
  
                List<UserRecordAccess> tasks_userAcc = [SELECT RecordId,HasReadAccess
                                                  FROM UserRecordAccess 
                                                  WHERE 
                                                       UserId=: UserInfo.getUserId()
                                                  AND 
                                                       RecordId in : TaskVisibility.keyset()];
                                                       
            for(UserRecordAccess user_acc:tasks_userAcc)
              if(user_acc.HasReadAccess==true)
                TaskVisibility.put(user_acc.id, true);
                     
        return TaskVisibility;
    }
}