global with sharing class BatchArchiveKnowledgeArticle implements Database.Batchable<sObject>, Database.Stateful {

        private integer contTotalRecordsKO = 0;
        private integer contTotalRecordsRan = 0;
        private integer scopeSize ;
        public String  query ;
        private integer minutesRange ;
        public boolean isAutoSchedulable ;
        public boolean needInfoLogWrite ;
        String BATCH_NAME = 'Batch Archive Knowledge Article';


    //constructor with params from MTD -- BatchSetting__mdt
    //Id batchJobId = Database.executeBatch(new BatchArchiveKnowledgeArticle(), 200);
    public BatchArchiveKnowledgeArticle (){
        
        try {
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                                                ScopeSize__c,Query__c,Need_Information_Log__c 
                                                from BatchSetting__mdt
                                                where DeveloperName = 'Run_Batch_Knowledge_kav'];
            
            this.scopeSize =(integer) batchSettings.ScopeSize__c ;
            this.minutesRange = (integer) batchSettings.MinutesRange__c ;
            this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
            this.query = batchSettings.Query__c ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('BatchArchiveKnowledgeArticle', e.getMessage(), e.getStackTraceString()); 
        }
        
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){

        Database.QueryLocator qlocator ;
        try {
            qlocator = Database.getQueryLocator(this.query);
        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('BatchArchiveKnowledgeArticle', e.getMessage(), e.getStackTraceString()); 
        }
        return qlocator ;
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){  
        integer contTempPerBatchOK = 0 ;
        integer contTempPerBatchKO = 0 ;
        List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();
        List<Knowledge__kav> scopeKnow = (List<Knowledge__kav>)scope;

       
            System.debug('Scope enter number '+scope.size());
            for(Knowledge__kav articleTemp : scopeKnow){

                try {
                contTempPerBatchOK++;
                KbManagement.PublishingService.archiveOnlineArticle(articleTemp.knowledgeArticleId,null);
                }catch (Exception e){ 
                    //ApplicationLogHelper.ERROR('BatchArchiveKnowledgeArticle', e.getMessage(), e.getStackTraceString()); 
                    Errors.add(new ApplicationLogHelper.ErrorWrapper( e.getMessage(),'Error BatchArchiveKnowledgeArticle - id:'+articleTemp.knowledgeArticleId+' ms:'+e.getStackTraceString()));
                    contTempPerBatchKO++;
                    contTempPerBatchOK--;
                }
            }
            //ALL logic here

            contTotalRecordsRan += contTempPerBatchOK ;
            contTotalRecordsKO  += contTempPerBatchKO ;

            if(!Errors.isEmpty())
            ApplicationLogHelper.LogErrors('BatchArchiveKnowledgeArticle', Errors);    
 
        }
    
    global void finish(Database.BatchableContext BC){
        //code here
        try {
        
            System.debug('### Total di BatchArchiveKnowledgeArticle Ran per il Batch OK : '+ contTotalRecordsRan);
            System.debug('### Total di BatchArchiveKnowledgeArticle Non Ran il Batch KO : '+ contTotalRecordsKO);
            if(needInfoLogWrite)
            ApplicationLogHelper.INFO('BatchArchiveKnowledgeArticle', 'BatchArchiveKnowledgeArticle finish at: '+System.now(), 'Total OK : '+ contTotalRecordsRan+' '+
                                                                                        'Total KO : '+ contTotalRecordsKO );

            if(this.isAutoSchedulable) {
                System.scheduleBatch(new BatchArchiveKnowledgeArticle(), BATCH_NAME, 
                                    this.minutesRange,this.scopeSize);
                System.debug('FINISH -- Scheduling new Batch in-'+this.minutesRange+':min');
            } 

        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('BatchArchiveKnowledgeArticle', e.getMessage(), e.getStackTraceString()); 
        } 

    }
}