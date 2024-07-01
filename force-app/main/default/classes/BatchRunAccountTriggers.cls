/*------------------------------------------------------------------------
Author:        --
Company:       --
Class:         BatchRunAccountTriggers
Description:   Class for update Accounts that were Insert but without Trigger Before or After INSERT, class
               RUNs a batch schedule for X min searching for Accounts with NeedAsyncTriggerExecution__c = false

ND:             Importan field --NeedAsyncTriggerExecution__c-- if true RUN into Batch, false already RAN it.

25/11/2021     Created - *-+
----------------------------------------------------------------------------*/

global class BatchRunAccountTriggers implements Database.Batchable<sObject>, Database.Stateful {
  
        private integer contTotalRecordsKO = 0;
        private integer contTotalRecordsRan = 0;
        private integer scopeSize ;
        private String  query ;
        private integer minutesRange ;
        private boolean isAutoSchedulable ;
        private boolean needInfoLogWrite ;
        String BATCH_NAME = 'Account Batch';

    
    //constructor with params from MTD -- BatchSetting__mdt
    public BatchRunAccountTriggers (){
        
        try {
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                                                ScopeSize__c,Query__c,Need_Information_Log__c 
                                                from BatchSetting__mdt
                                                where DeveloperName = 'Run_Batch_Account'];
            
            this.scopeSize =(integer) batchSettings.ScopeSize__c ;
            this.minutesRange = (integer) batchSettings.MinutesRange__c ;
            this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
            this.query = batchSettings.Query__c ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunAccountTriggers', e.getMessage(), e.getStackTraceString()); 
        }
        
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){

        Database.QueryLocator qlocator ;
        try {
            qlocator = Database.getQueryLocator(this.query);
        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunAccountTriggers', e.getMessage(), e.getStackTraceString()); 
        }
        return qlocator ;
    }
     
    global void execute(Database.BatchableContext BC, List<Account> scope){  
        
        try {
            AccountHandler_Helper Account_helper = new AccountHandler_Helper();
        
            //Account_helper.BeforeOperationsAccounts(scope);
     		Account_helper.linkAgencyToAccount(scope);
            Account_helper.NodoOmnia(scope);
            Account_helper.updateBlackListProcessAccount(scope);
            Account_helper.AfterOperationsAccounts(scope);
    
            //pasando la var a true ..analizatto tutti
            for(Account account_pivot: scope){
    
                //cambiare a false for non see it again
                account_pivot.NeedAsyncTriggerExecution__c = false;
    
            }
            //Update but first telling AccountHandler thats is setDeactivateTrigger for this Batch
            AccountHandler.setDeactivateTrigger(true);
            Database.SaveResult[] drList = Database.update(scope,false);
    
            integer contTempPerBatchOK = 0 ;
            integer contTempPerBatchKO = 0 ;
            List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();
    
            for(Database.SaveResult result : drList) {
                if(result.isSuccess()){
                    system.debug('Aggiornato-'+result.getId());
                    contTempPerBatchOK++;
                }       
                else {  
                   system.debug('Non Aggiornato-'+result.getId());
                   system.debug('Error Updating because --'+result.getErrors());
                   system.debug('Error Updating for --'+System.UserInfo.getName()+'-Profilo-'+System.UserInfo.getProfileId());
                   // sending error to ApplicationLog__c 
                   Errors.add(new ApplicationLogHelper.ErrorWrapper('Error Update Account-'+result.getId(), result.getErrors().toString()));
                   contTempPerBatchKO++;
                }
            }
            contTotalRecordsRan += contTempPerBatchOK ;
            contTotalRecordsKO  += contTempPerBatchKO ;
            if(!Errors.isEmpty())
                ApplicationLogHelper.LogErrors('BatchRunAccountTriggers', Errors);      

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunAccountTriggers', e.getMessage(), e.getStackTraceString()); 
        }

        
    }
     
    global void finish(Database.BatchableContext BC){
        //code here
        try {
           
            System.debug('### Total di Accounts Ran per il Batch OK : '+ contTotalRecordsRan);
            System.debug('### Total di Accounts Non Ran il Batch KO : '+ contTotalRecordsKO);
            if(needInfoLogWrite)
            ApplicationLogHelper.INFO('BatchRunAccountTriggers', 'Batch Account finish at: '+System.now(), 'Total OK : '+ contTotalRecordsRan+' '+
                                                                                        'Total KO : '+ contTotalRecordsKO );

            System.debug('FINISH -- Scheduling new Batch in-'+this.minutesRange+':min');
            if(this.isAutoSchedulable && !Test.isRunningTest()) {
                System.scheduleBatch(new BatchRunAccountTriggers(), BATCH_NAME, 
                                    this.minutesRange,this.scopeSize);
            } 

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunAccountTriggers', e.getMessage(), e.getStackTraceString()); 
        } 
 
    }
}