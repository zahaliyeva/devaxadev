global without sharing class BatchHidePolizze implements Database.Batchable<sObject>, Database.Stateful {
    
    private integer contTotalRecordsKO = 0;
    private integer contTotalRecordsRan = 0;
    private integer scopeSize ;
    private String  query ;
    private integer minutesRange ;
    private boolean isAutoSchedulable ;
    private boolean needInfoLogWrite ;
    String BATCH_NAME = 'Hide PolizzeAccountClaim Batch';
    private static integer counter = 0;


    public BatchHidePolizze() {
        try {
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
            ScopeSize__c,Query__c,Need_Information_Log__c 
            from BatchSetting__mdt 
            where DeveloperName = 'Run_Batch_Hide_Polizze'];

            this.scopeSize =(integer) batchSettings.ScopeSize__c ;
            this.minutesRange = (integer) batchSettings.MinutesRange__c ;
            this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
            this.query = batchSettings.Query__c ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchHidePolizze', e.getMessage(), e.getStackTraceString()); 
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        Database.QueryLocator qlocator;
        try {
            if (this.query != '' && this.query != null) {
                qlocator = Database.getQueryLocator(this.query, AccessLevel.SYSTEM_MODE);}
            else {
                qlocator = Database.getQueryLocator('select id, isHidden__c, CUID__c from InsurancePolicy__c where datacheck__c != null and isHidden__c = false and CALENDAR_YEAR(datacheck__c) <= '+String.valueOf(System.Today().Year()-3 + ' limit 15000'), AccessLevel.SYSTEM_MODE);
            }
        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchHidePolizze', e.getMessage(), e.getStackTraceString()); 
        }
        return qlocator ;
    }

    global void execute(Database.BatchableContext BC, List<InsurancePolicy__c> scope){   
        
        try {
            List<Id> PolizzeIds = new List<Id>();
            List<Id> AccountsIds = new List<Id>();

            for(InsurancePolicy__c polizza_pivot: scope){
                polizza_pivot.isHidden__c=true;
                PolizzeIds.add(polizza_pivot.id);
                AccountsIds.add(polizza_pivot.CUID__c);
            }
            Database.SaveResult[] PolizzeResult = Database.update(scope,false);

            List<Claim__c> ClaimsToUpdate = [select id, isHidden__c from Claim__c where Polizza__c in :PolizzeIds and isHidden__c = false];
            for (Claim__c c: ClaimsToUpdate) {
                c.isHidden__c = true;
            }
            Database.SaveResult[] ClaimResult = Database.update(ClaimsToUpdate,false);

            List<Account> AccountsToUpdate = new List<Account>();
            List<Account> AccountsToCheck = [select id, isHidden__c, (select id, isHidden__c from Policies__r) from Account where id in :AccountsIds and isHidden__c = false];
            for (Account a: AccountsToCheck) {
                Boolean hasVisiblePolicies = false;
                for (InsurancePolicy__c p: a.Policies__r) {
                    if (p.isHidden__c==false) {
                        hasVisiblePolicies = true;
                    }
                }
                if (!hasVisiblePolicies) {
                    AccountsToUpdate.add(new Account(Id=a.id,isHidden__c=true));
                } 
            }
            Database.SaveResult[] AccountResult = Database.update(AccountsToUpdate,false);

            integer contTempPerBatchOK = 0 ;
            integer contTempPerBatchKO = 0 ;
            List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();

            for(Database.SaveResult result : PolizzeResult) {
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

            for(Database.SaveResult result : ClaimResult) {
                if(result.isSuccess()){
                    system.debug('Aggiornato-'+result.getId());
                    contTempPerBatchOK++;
                }       
                else {  
                system.debug('Non Aggiornato-'+result.getId());
                system.debug('Error Updating because --'+result.getErrors());
                system.debug('Error Updating for --'+System.UserInfo.getName()+'-Profilo-'+System.UserInfo.getProfileId());
                // sending error to ApplicationLog__c 
                Errors.add(new ApplicationLogHelper.ErrorWrapper('Error Updating Sinistro-'+result.getId(), result.getErrors().toString()));
                contTempPerBatchKO++;
                }
            }

            for(Database.SaveResult result : AccountResult) {
                if(result.isSuccess()){
                    system.debug('Aggiornato-'+result.getId());
                    contTempPerBatchOK++;
                }       
                else {  
                system.debug('Non Aggiornato-'+result.getId());
                system.debug('Error Updating because --'+result.getErrors());
                system.debug('Error Updating for --'+System.UserInfo.getName()+'-Profilo-'+System.UserInfo.getProfileId());
                // sending error to ApplicationLog__c 
                Errors.add(new ApplicationLogHelper.ErrorWrapper('Error Updating Account-'+result.getId(), result.getErrors().toString()));
                contTempPerBatchKO++;
                }
            }
            
            contTotalRecordsRan += contTempPerBatchOK ;
            contTotalRecordsKO  += contTempPerBatchKO ;
           
            if(!Errors.isEmpty())
            ApplicationLogHelper.LogErrors('BatchHidePolizze', Errors);    

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchHidePolizze', e.getMessage(), e.getStackTraceString()); 
        }

    }

    global void finish(Database.BatchableContext BC){

        try {
                //code here
            System.debug('### Total di records Ran per il Batch OK : '+ contTotalRecordsRan);
            System.debug('### Total di records Non Ran il Batch KO : '+ contTotalRecordsKO);
            if(needInfoLogWrite)
                ApplicationLogHelper.INFO('BatchHidePolizze', 'Batch Hide PolizzeAccountClaim Batch finish at: '+System.now(), 'Total OK : '+ contTotalRecordsRan+' '+
                                                                                            'Total KO : '+ contTotalRecordsKO );

            System.debug('FINISH');
            if ((this.contTotalRecordsRan + this.contTotalRecordsKO) == 15000) {
                System.debug('FINISH -- Scheduling new Batch in- 1 min');
                System.scheduleBatch(new BatchHidePolizze(), BATCH_NAME, 
                                    1,this.scopeSize);
            } else if(this.isAutoSchedulable && !Test.isRunningTest()) {
                System.debug('FINISH -- Scheduling new Batch in-'+this.minutesRange+':min');
                System.scheduleBatch(new BatchHidePolizze(), BATCH_NAME, 
                                    this.minutesRange,this.scopeSize);
            }            

        }catch (Exception e){ 
             ApplicationLogHelper.ERROR('BatchHidePolizze', e.getMessage(), e.getStackTraceString()); 
        }
        
    }

}