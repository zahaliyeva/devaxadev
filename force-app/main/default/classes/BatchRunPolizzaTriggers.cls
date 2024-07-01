/*------------------------------------------------------------------------
Author:        --
Company:       --
Class:         BatchRunPolizzaTriggers
Description:   Class for update Polizza that were Insert but without Trigger Before or After INSERT, class
               RUNs a batch schedule for X min searching for Polizza with NeedAsyncTriggerExecution__c = true

ND:             Importan field --NeedAsyncTriggerExecution__c-- if true RUN into Batch, false already RAN it.

25/11/2021     Created - *-+
----------------------------------------------------------------------------*/
global class BatchRunPolizzaTriggers implements Database.Batchable<sObject>, Database.Stateful {
 
    private integer contTotalRecordsKO = 0;
    private integer contTotalRecordsRan = 0;
    private integer scopeSize ;
    private String  query ;
    private integer minutesRange ;
    private boolean isAutoSchedulable ;
    private boolean needInfoLogWrite ;
    String BATCH_NAME = 'Polizza Batch';
    private static integer counter = 0;

   //constructor 
    public BatchRunPolizzaTriggers() {
        try {

            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
            ScopeSize__c,Query__c,Need_Information_Log__c 
            from BatchSetting__mdt 
            where DeveloperName = 'Run_Batch_Polizza'];

            this.scopeSize =(integer) batchSettings.ScopeSize__c ;
            this.minutesRange = (integer) batchSettings.MinutesRange__c ;
            this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
            this.query = batchSettings.Query__c ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunPolizzaTriggers', e.getMessage(), e.getStackTraceString()); 
        }
 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        Database.QueryLocator qlocator ;
        try {
            qlocator = Database.getQueryLocator(this.query);
        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunPolizzaTriggers', e.getMessage(), e.getStackTraceString()); 
        }
        return qlocator ;
    }
    
    global void execute(Database.BatchableContext BC, List<InsurancePolicy__c> scope){   
        
        try {
            
            PolizzaHandler_Helper Polizza_helper = new PolizzaHandler_Helper();
        	
            List<InsurancePolicy__c> newScope = Polizza_helper.BeforeOperationsPolizza(scope);
    		if(!newScope.isEmpty())
            	Polizza_helper.AfterOperationsPolizza(newScope);
    
            //pasando la var a true ..analizatto tutti
            for(InsurancePolicy__c polizza_pivot: scope){
                counter++;
                //cambiare a false for non see it again
                polizza_pivot.Last_Node_Modify_Date__c = null;
                polizza_pivot.NeedAsyncTriggerExecution__c = false ;
    
            }
            //Update but first telling InsurancePolicy__cHandler thats is setDeactivateTrigger for this Batch
            PolizzaHandler.setDeactivateTrigger(true);
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
                Errors.add(new ApplicationLogHelper.ErrorWrapper('Error Updating Polizza-'+result.getId(), result.getErrors().toString()));
                contTempPerBatchKO++;
                }
            }
            contTotalRecordsRan += contTempPerBatchOK ;
            contTotalRecordsKO  += contTempPerBatchKO ;
            if(!Errors.isEmpty())
            ApplicationLogHelper.LogErrors('BatchRunPolizzaTriggers', Errors);    

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunPolizzaTriggers', e.getMessage(), e.getStackTraceString()); 
        }

    }
    
    global void finish(Database.BatchableContext BC){

        try {
                //code here
            System.debug('### Total di InsurancePolicy__c Ran per il Batch OK : '+ contTotalRecordsRan);
            System.debug('### Total di InsurancePolicy__c Non Ran il Batch KO : '+ contTotalRecordsKO);
            if(needInfoLogWrite)
                ApplicationLogHelper.INFO('BatchRunPolizzaTriggers', 'Batch Polizza finish at: '+System.now(), 'Total OK : '+ contTotalRecordsRan+' '+
                                                                                            'Total KO : '+ contTotalRecordsKO );

            System.debug('FINISH -- Scheduling new Batch in-'+this.minutesRange+':min');
            if(this.isAutoSchedulable && !Test.isRunningTest()) {
                Integer minutes = (this.contTotalRecordsRan + this.contTotalRecordsKO) == 15000 ? 1 : this.minutesRange; 
                System.scheduleBatch(new BatchRunPolizzaTriggers(), BATCH_NAME, 
                                    minutes,this.scopeSize);
            }

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchRunPolizzaTriggers', e.getMessage(), e.getStackTraceString()); 
        }
        
    }
}