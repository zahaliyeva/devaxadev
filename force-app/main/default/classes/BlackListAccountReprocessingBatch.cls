//BOVOLENTA_D @DELOITTE DIGITAL 15062018
//Batch used to reprocess clients (mostly new clients, input query is customizable) to check if their Blacklist information match the one on their Nodes
global class BlackListAccountReprocessingBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful
{
   /*
    
    //TO SCHEDULE:
    BlackListAccountReprocessingBatch p24 = new BlackListAccountReprocessingBatch();
    String sch = '0 30 01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * ?';
    system.schedule('BlackListAccountReprocessingBatch', sch, p24);
    
    //TO LAUNCH SINGLE EXECUTION:
    BlackListAccountReprocessingBatch b = new BlackListAccountReprocessingBatch();
    

    //b.fullQuery = 'Select id, OwnerId,BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Commerciale__c,BlackList_Infortuni__c,BlackList_Malattia__c,BlackList_Protection__c,BlackList_Rinnovo__c,BlackList_Saving__c,BlackList_Servizio__c,NDG__c,Nodes__c,Ultima_modifica_blacklist__c,AAI_Agency_Reference_Code__c from Account where RecordType.DeveloperName in (\'B2C_Client\',\'B2B_Client\') and CreatedDate = YESTERDAY ORDER BY AAI_Agency_Reference_Code__c'
    //b.NEW_OWNER_ID = '00524000000T5E3';
    Database.ExecuteBatch(b,100);  
    
    */

    public Id NEW_OWNER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();


    public String fullQuery = '';
    public String baseQuery = '';
    public String queryTimeFilter = ' and CreatedDate = YESTERDAY';
    public String queryOrderBy = ' ORDER BY AAI_Agency_Reference_Code__c';
    private list<String> errorList;
    private Long modifiedBLAccounts;
    private Long modifiedBLBAccounts;
    private Long totalAccounts;   
    private Long accountsWithoutNodes;
    private Long errorCount;
    private Long changedOwnerCount;
    private Long successfullyUpdated;
    private Long modifiedMasterContactAccounts;
    private AAI_Code_Variables__c startDateVariable = new AAI_Code_Variables__c(); 
    private AAI_Code_Variables__c endDateVariable= new AAI_Code_Variables__c(); 
    private AAI_Code_Variables__c emailAddressesVariable= new AAI_Code_Variables__c(); 

    //EClemente - 02/05/2024 - Bug Fix: Add autoschedule logic and manage query on metadata BatchSetting
    private integer contTotalRecordsKO = 0;
    private integer contTotalRecordsRan = 0;
    private integer scopeSize ;
    private String limitSize ;
    private String  query ;
    private integer minutesRange ;
    private boolean isAutoSchedulable ;
    private boolean needInfoLogWrite ;
    String BATCH_NAME = 'Blacklist Daily New Account Processing';

    //constructor with params from MTD -- BatchSetting__mdt
    public BlackListAccountReprocessingBatch (){
        
        try {
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                                                ScopeSize__c,Query__c,Need_Information_Log__c,Limit__c
                                                from BatchSetting__mdt
                                                where DeveloperName = 'Run_Batch_BlacklistAccount'];
            
            this.scopeSize =(integer) batchSettings.ScopeSize__c ;
            this.limitSize = batchSettings.Limit__c != null && batchSettings.Limit__c > 0 ? String.valueOf(batchSettings.Limit__c) : '' ;
            this.minutesRange = (integer) batchSettings.MinutesRange__c ;
            this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
            this.baseQuery = batchSettings.Query__c ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BlackListAccountReprocessingBatch', e.getMessage(), e.getStackTraceString()); 
        }
        
    } 
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        errorList = new list<String>();
        modifiedBLAccounts = 0;
        modifiedBLBAccounts = 0;
        totalAccounts = 0;  
        accountsWithoutNodes = 0; 
        errorCount = 0;
        changedOwnerCount = 0;
        successfullyUpdated= 0;
        modifiedMasterContactAccounts = 0;

        initializeLoggingVariables();


        String query = '';
        if (fullQuery=='')
        {
            //dynamic time filter - USING GMT TIME
            if(startDateVariable.value__c != null && endDateVariable.value__c != null)
            {
                DateTime lastStartDT = Datetime.valueOf(startDateVariable.value__c);
                Date lastStartD = lastStartDT.dateGMT(); 
                DateTime lastEndDT = Datetime.valueOf(endDateVariable.value__c);
                Date lastEndD = lastEndDT.dateGMT();
                DateTime yesterdayDT = DateTime.now().addDays(-1);
                Date yesterdayD = yesterdayDT.dateGMT();

                if (!(lastStartD>=yesterdayD) || !(lastEndD>=yesterdayD))
                {//if the batch did not start & end yesterday, get also the records from the day before the last start date
                    Date theDayBeforeLastStartD = lastStartD.addDays(-1);
                    DateTime theDayBeforeLastStartDT = DateTime.newInstance(theDayBeforeLastStartD.year(), theDayBeforeLastStartD.month(), theDayBeforeLastStartD.day());
                    queryTimeFilter = ' and CreatedDate >= '+theDayBeforeLastStartDT.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                }
            }

            query= baseQuery+queryTimeFilter+queryOrderBy;
            //query= baseQuery+queryOrderBy;

            if(String.isNotBlank(this.limitSize)){
                query= query+' LIMIT '+this.limitSize;
            }
        }
        else
        {
            //if the query is received from outside, use it
            query = fullQuery;
        }

        startDateVariable.Name = 'BLAccReprocessingBatchLastStartDate';
        startDateVariable.value__c = ''+DateTime.now();
        upsert startDateVariable;
        system.debug ('FINAL QUERY '+query );
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {   
        this.runJob(scope);
    }

    global void finish(Database.BatchableContext BC)
    {
        endDateVariable.Name = 'BLAccReprocessingBatchLastEndDate';
        endDateVariable.value__c = ''+DateTime.now();
       

        //code here
        try {

            upsert endDateVariable;
            sendEmail();
           
            System.debug('### Total di Accounts Ran per il Batch OK : '+ successfullyUpdated);
            System.debug('### Total di Accounts Non Ran il Batch KO : '+ errorCount);
            if(needInfoLogWrite)
            ApplicationLogHelper.INFO('BlackListAccountReprocessingBatch', 'Batch Account finish at: '+System.now(), 'Total OK : '+ successfullyUpdated+' '+
                                                                                        'Total KO : '+ errorCount );

            System.debug('FINISH -- Scheduling new Batch in-'+this.minutesRange+':min');
            if(this.isAutoSchedulable && !Test.isRunningTest()) {
                System.scheduleBatch(new BlackListAccountReprocessingBatch(), BATCH_NAME, 
                                    this.minutesRange,this.scopeSize);
            } 

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BlackListAccountReprocessingBatch', e.getMessage(), e.getStackTraceString()); 
        } 
 
    }
    

    global void Execute(SchedulableContext SC)
    {  
        System.abortJob(SC.getTriggerId());
        BlackListAccountReprocessingBatch b = new BlackListAccountReprocessingBatch();
        Database.ExecuteBatch(b,this.scopeSize);      
    } 
     

    private void runJob(List<SObject> scope)
    {
        List<Account> rListComplete = (List<Account>) scope; 
        Set<String> nodesSet = new Set<String>();
        List<String> nodesList = new List<String>();
        Map<Id,List<String>> accountToNodesCodesMap = new Map<Id,List<String>>();
        Map <id,Account> accountsForUpdateMasterContact = new  Map<id,Account>(); // for push notification update field contactmaster 1 contact for all same 
        for (Account acc : rListComplete)
        {

            if (acc.Nodes__c!= null && acc.Nodes__c != ''){   
                List <String> tempNodesList = acc.Nodes__c.split(';');
                accountToNodesCodesMap.put(acc.Id,tempNodesList);
                nodesSet.addAll (tempNodesList);
            }
            
            if(acc.Contact_Master_Id__c == null || String.isBlank(acc.Contact_Master_Id__c)){
                if(updateContactMasterID(acc)){
                    accountsForUpdateMasterContact.put(acc.id,acc);
                    modifiedMasterContactAccounts++;
                }
            }
        }

        List <Blacklist_Broker__mdt> blacklistBrokerSettings = [SELECT Intermediary_Type__c FROM Blacklist_Broker__mdt];
        List<String> brokerType = new List<String>();
        for(Blacklist_Broker__mdt b : blacklistBrokerSettings){
            brokerType.add(b.Intermediary_Type__c.toLowerCase());
        }

        List<Node__c> queriedNodes = [SELECT BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Commerciale__c,BlackList_Infortuni__c,BlackList_Malattia__c,BlackList_Protection__c,BlackList_Rinnovo__c,BlackList_Saving__c,BlackList_Servizio__c,Node_unique_code__c,Tutte_le_tipologie__c,Tutti_i_prodotti__c,Ultima_modifica_blacklist__c FROM Node__c WHERE Node_unique_code__c in :nodesSet AND Ultima_modifica_blacklist__c != null ORDER BY Node_unique_code__c];
        List<Node__c> queriedNodesBroker = [SELECT Intermediary_type__c, Node_unique_code__c FROM Node__c WHERE Node_unique_code__c in :nodesSet AND Intermediary_type__c IN :brokerType ORDER BY Node_unique_code__c];
        
        System.debug(' ===> queriedNodes: ' + queriedNodes);
        System.debug(' ===> queriedNodesBroker: ' + queriedNodesBroker);

        Map<String,Node__c> mapNodeCodeToNode = new Map<String,Node__c>();
        Map<String,Node__c> mapNodeBrokerCodeToNodeBroker = new Map<String,Node__c>();

        for (Node__c currentNode :queriedNodes)
        {
            mapNodeCodeToNode.put(currentNode.Node_unique_code__c,currentNode);
        }
        for (Node__c currentNode :queriedNodesBroker)
        {
            mapNodeBrokerCodeToNodeBroker.put(currentNode.Node_unique_code__c,currentNode);
        }

        System.debug(' ===> mapNodeCodeToNode: ' + mapNodeCodeToNode);
        System.debug(' ===> mapNodeBrokerCodeToNodeBroker: ' + mapNodeBrokerCodeToNodeBroker);

        Set<Account> accountsToUpdate = new Set<Account>();
        //CHECK LOGIC
        for (Account acc : rListComplete)
        {
            totalAccounts++;
            Boolean accountToUpdate = false;
            DateTime startingUltimaModificaBlacklist = Datetime.newInstance(1960, 1, 1);
            if ( acc.Ultima_modifica_blacklist__c!= null)
            {
                startingUltimaModificaBlacklist = acc.Ultima_modifica_blacklist__c;
            }

            if (acc.OwnerId!= NEW_OWNER_ID)
            {
                acc.OwnerId =  NEW_OWNER_ID;
                accountToUpdate = true;
                changedOwnerCount++;
            }
            if (acc.Nodes__c!= null && acc.Nodes__c != '')
            {   
                List <String> tempAccNodesList = accountToNodesCodesMap.get(acc.Id);
                for (String currentAccNode :tempAccNodesList)
                {
                    //IF NODE LIST SIZE = 1 we only have the agency node
                    if ((tempAccNodesList.size()>1 && currentAccNode != acc.AAI_Agency_Reference_Code__c)||tempAccNodesList.size()==1){ //IF WE HAVE SUBNODES SKIP THE AGENCY NODE - SUBNODES ONLY (if present)
                        
                        Node__c singleNode = mapNodeCodeToNode.get(currentAccNode);
                        if (singleNode!= null) //the node is blacklisted
                        {
                            if ( startingUltimaModificaBlacklist <=singleNode.Ultima_modifica_blacklist__c)
                            {
                                if (!acc.BlackList_Auto__c && singleNode.BlackList_Auto__c ) acc.BlackList_Auto__c = singleNode.BlackList_Auto__c;
                                if (!acc.BlackList_Abitazione__c && singleNode.BlackList_Abitazione__c ) acc.BlackList_Abitazione__c = singleNode.BlackList_Abitazione__c;
                                if (!acc.BlackList_Infortuni__c && singleNode.BlackList_Infortuni__c ) acc.BlackList_Infortuni__c = singleNode.BlackList_Infortuni__c;
                                if (!acc.BlackList_Malattia__c && singleNode.BlackList_Malattia__c ) acc.BlackList_Malattia__c = singleNode.BlackList_Malattia__c;
                                if (!acc.BlackList_Protection__c && singleNode.BlackList_Protection__c ) acc.BlackList_Protection__c = singleNode.BlackList_Protection__c;
                                if (!acc.BlackList_Saving__c && singleNode.BlackList_Saving__c ) acc.BlackList_Saving__c = singleNode.BlackList_Saving__c;
                                if (!acc.BlackList_Aziende__c && singleNode.BlackList_Aziende__c ) acc.BlackList_Aziende__c = singleNode.BlackList_Aziende__c;
                                if (!acc.BlackList_Rinnovo__c && singleNode.BlackList_Rinnovo__c ) acc.BlackList_Rinnovo__c = singleNode.BlackList_Rinnovo__c;
                                if (!acc.BlackList_Commerciale__c && singleNode.BlackList_Commerciale__c ) acc.BlackList_Commerciale__c = singleNode.BlackList_Commerciale__c;
                                if (!acc.BlackList_Servizio__c && singleNode.BlackList_Servizio__c ) acc.BlackList_Servizio__c = singleNode.BlackList_Servizio__c;   

                                if(acc.Ultima_modifica_blacklist__c == null || acc.Ultima_modifica_blacklist__c <= singleNode.Ultima_modifica_blacklist__c)
                                {
                                    acc.Ultima_modifica_blacklist__c = singleNode.Ultima_modifica_blacklist__c;
                                }
                                modifiedBLAccounts++;
                                accountToUpdate = true;
                            }

                        }

                        Node__c singleNodeBroker = mapNodeBrokerCodeToNodeBroker.get(currentAccNode);
                        System.debug(' ===> singleNodeBroker: ' + singleNodeBroker);
                        /**
                        if(acc.BlackList_Broker__c && singleNode == null && (tempAccNodesList.size() <= 2)){
                            acc.BlackList_Broker__c = false;
                            toAdd = true;
                            accountToUpdate = true;
                        } else if (singleNodeBroker!= null){
                            if (!acc.BlackList_Broker__c && 
                                ('Broker Ratificato'.equalsIgnoreCase(singleNodeBroker.Intermediary_type__c) ||
                                'Broker di direzione'.equalsIgnoreCase(singleNodeBroker.Intermediary_type__c) ||
                                'PTF A con D'.equalsIgnoreCase(singleNodeBroker.Intermediary_type__c))){
                                acc.BlackList_Broker__c = true;
                            }
                            //modifiedBLAccounts++;
                            toAdd = true;
                            accountToUpdate = true;
                        }**/
                        //if ('Broker Ratificato'.equalsIgnoreCase(singleNodeBroker.Intermediary_type__c) ||
                        //    'Broker di direzione'.equalsIgnoreCase(singleNodeBroker.Intermediary_type__c) ||
                        //    'PTF A con D'.equalsIgnoreCase(singleNodeBroker.Intermediary_type__c)){
                        System.debug(' ===> brokerType: ' + brokerType);
                        System.debug(' ===> singleNodeBroker: ' + singleNodeBroker);
                        if(singleNodeBroker != null && brokerType.contains(singleNodeBroker.Intermediary_type__c.toLowerCase())){
                            modifiedBLBAccounts++;
                            acc.BlackList_Broker__c = true;
                            accountToUpdate = true;
                        }
                    }
                }
          
            }
            else
            {
                accountsWithoutNodes++;
            }
            if (accountToUpdate)
            {
                accountsToUpdate.add(acc); 
            }
        }
        List<Account> accountsToUpdateList = new List<Account>(accountsToUpdate);

        //Accounts update the ContactMasterid if was found only 1 Contact #crmid21 ID MyAxa deve aggiornare MasterContact per tutti Accounts
        //Accounts multiNDG(AAI) o stesso Cliente in diverse agenzia(MPS) devo avere lo stesso ContactMasterID
        for(Account accTemp :accountsToUpdateList){
            if(accountsForUpdateMasterContact.containsKey(accTemp.id)){
                accTemp.Contact_Master_Id__c = accountsForUpdateMasterContact.get(accTemp.id).Contact_Master_Id__c;
                accountsForUpdateMasterContact.remove(accTemp.id);
            }
        }
        if(!accountsForUpdateMasterContact.isEmpty())
            accountsToUpdateList.addAll(accountsForUpdateMasterContact.values());

        //ACCOUNTS are updated if either the Blacklist or the Owner has changed
        Database.SaveResult[] drList = Database.update (accountsToUpdateList,false);

        for(Database.SaveResult dr : drList) {
            if (dr.isSuccess()) {
                successfullyUpdated++;
            }
            else {
              errorCount++;
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                  errorList.add('Si è verificato il seguente errore ' + err.getStatusCode()+ ': ' + err.getMessage()+' sui seguenti campi: '+ err.getFields());
                }
            }
        }  

    }

    private void initializeLoggingVariables (){
        List<AAI_Code_Variables__c> variablesList = [SELECT Id, Name, Value__c FROM AAI_Code_Variables__c  WHERE  Name in ('BLAccReprocessingBatchLastStartDate','BLAccReprocessingBatchLastEndDate','BLAccReprocessingBatchEmailAddr')];
        if (variablesList.size()>0)
        {
            for (AAI_Code_Variables__c var :variablesList )
            {
                if (var.Name == 'BLAccReprocessingBatchLastStartDate')
                {
                    startDateVariable = var;
                }
                else if (var.Name == 'BLAccReprocessingBatchLastEndDate')
                {
                    endDateVariable = var;
                }
                else if (var.Name == 'BLAccReprocessingBatchEmailAddr')
                {
                    emailAddressesVariable = var;
                }
            }
        }

    }

    private void sendEmail(){
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        //now do your loop
        List<EmailTemplate> template = new List<EmailTemplate>();
        template = [select id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'Blacklist_Account_Reprocessing_Batch_Notification'];  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String mailName ='Utente';

        system.debug('+++++++thisemailtemplate'+template.get(0));
        mail.setUseSignature(false);
        map<String,String> mapFieldToValue = new Map<String,String>();
        mapFieldToValue.put('{!modifiedBLAccounts}',''+modifiedBLAccounts ); 
        mapFieldToValue.put('{!modifiedBLBAccounts}',''+modifiedBLBAccounts ); 
        mapFieldToValue.put('{!totalAccounts}',''+totalAccounts ); 
        mapFieldToValue.put('{!accountsWithoutNodes}',''+accountsWithoutNodes ); 
        mapFieldToValue.put('{!errorCount}',''+errorCount ); 
        mapFieldToValue.put('{!errorList}',''+errorList );
        mapFieldToValue.put('{!successfullyUpdated}',''+successfullyUpdated );
        mapFieldToValue.put('{!changedOwnerCount}',''+changedOwnerCount );
        //mapFieldToValue.put('{!accountsWithoutMasterC}',''+modifiedMasterContactAccounts ); non autorizato da axa ancora da pushare template in caso richiesta

        String errorsString = '';
        for (String s :errorList)
        {
          errorsString = errorsString+s+'<br/>';
        }
        //   mapFieldToValue.put('{!Link}','https://'+System.URL.getSalesforceBaseUrl().getHost()+'/00Q/o' );
        String tempURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        //String tempURL= System.URL.getCurrentRequestUrl().toExternalForm();
        // mapFieldToValue.put('{!Link}',tempURL.SPLIT('/apex/',-1).get(0)+'/agenzie/00Q/o' );        
        mail = UtilityClass.prepareEmailTemplate(template.get(0),mapFieldToValue );
        list<String> destinations = new list<String>();

        String UserId=UserInfo.GetUserId();
        list<User> AdminUser = new List<User>();
        AdminUser=[SELECT Id FROM User WHERE Username LIKE 'deloitte.admin@italy%' limit 1];
        destinations.add(''+UserId);

        if (AdminUser.size()>0) 
        {
          destinations.add(''+AdminUser.get(0).Id);
        }
        if(emailAddressesVariable!= null && emailAddressesVariable.value__c != null && emailAddressesVariable.value__c != '')
        {
            List <String> tempAddresses = emailAddressesVariable.value__c.split(';');
            Set <String> allAddresses = new Set<String>(tempAddresses);
            destinations.addAll(allAddresses);
        }

        mail.setToAddresses( destinations);

        mail.setSaveAsActivity(false);

        system.debug('+++++++++mail prepared'+mail);
        //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        if (destinations!= null && destinations.size()>0){
            allMails.add(mail);
        }
        try{ 
            if (allMails.size()>0){
                Messaging.sendEmail(allMails);
            }
        } catch (Exception e)
        {
            system.debug('Email Sending Exception');   
        }
        system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());    
    }  
    
    private boolean updateContactMasterID(Account accountWhitNonMasterContact){

        String fiscalCode = String.isNotBlank(accountWhitNonMasterContact.AAI_Codice_fiscale__c)? accountWhitNonMasterContact.AAI_Codice_fiscale__c: accountWhitNonMasterContact.AAI_Partita_IVA__c ;

        if(String.isBlank(fiscalCode) && String.isNotBlank(accountWhitNonMasterContact.Codice_fiscale_ListView__c))
            fiscalCode = accountWhitNonMasterContact.Codice_fiscale_ListView__c;

        List<AggregateResult> ListSameClient = [select max(Id)Id,Contact_Master_Id__c from Account where ID != :accountWhitNonMasterContact.id AND ( AAI_Codice_fiscale__c =:fiscalCode or AAI_Partita_IVA__c  =:fiscalCode )  
        group by Contact_Master_Id__c having Contact_Master_Id__c != null ] ;

        if(ListSameClient.size()==0){
            return false;
        } else if (ListSameClient.size()==1) {
            Account AccMasterCliente = [Select id,Data_Contact_Master_ID__c  from Account where id =:String.valueOf(ListSameClient[0].get('Id'))];
            accountWhitNonMasterContact.Contact_Master_Id__c = (String) ListSameClient[0].get('Contact_Master_Id__c');
            if(AccMasterCliente.Data_Contact_Master_ID__c!= null && String.isNotBlank(String.valueOf(AccMasterCliente.Data_Contact_Master_ID__c)))//IDCRM 047 aggiunta la data
                accountWhitNonMasterContact.Data_Contact_Master_ID__c = AccMasterCliente.Data_Contact_Master_ID__c;
            return true;
        } else {
            return false;
        }
    }
    
    
     
}