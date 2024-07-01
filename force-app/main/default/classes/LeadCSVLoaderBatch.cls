global class LeadCSVLoaderBatch implements Database.Batchable<sObject>,  Database.Stateful {
    
    String query;
    private Id leadHistoryId;
    private Integer csvStartingRow;
    private Integer nextStartingRow;
    private Boolean finished;
    private Set<String> queues;
    private String leadType;
    private csvProcessingStatus theCsvProcessingStatus;
    global LeadCSVLoaderBatch(Id objId, Integer firstRow, Set<String> oldQueues, String leadtypeToinsert) {
        csvStartingRow = firstRow;
        leadHistoryId = objId;
        query = 'SELECT Body,Id,ParentId FROM Attachment WHERE parentId =\''+objId+'\' and Name like \'%validati%\'';
        queues = oldQueues;
        leadType = leadtypeToinsert;

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    
        theCsvProcessingStatus = processCsv(leadHistoryId,csvStartingRow, leadType,queues);
        system.debug ('*********theCsvProcessingStatus'+theCsvProcessingStatus);
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug ('*********theCsvProcessingStatus'+theCsvProcessingStatus);

        statusUpdate ();
        if (!theCsvProcessingStatus.isFinished)
        {
            //run the next instance
            LeadCSVLoaderBatch newBatch = new LeadCSVLoaderBatch(leadHistoryId, theCsvProcessingStatus.nextStartingRow, theCsvProcessingStatus.impactedQueues, leadType);
            Database.executeBatch(newBatch,50);
        }
        else
        {
            //run the fixing batch
            BatchRunLeadTriggers newBatch = new BatchRunLeadTriggers();
            //Database.executeBatch(newBatch,5); //lowered from 50 due to exception on LeadTrigger: execution of BeforeUpdate caused by: System.QueryException: Non-selective query against large object type
            //FM - 12/01/2018: added in order to share quotations after massively Leads uploading
            BatchSharingQuotazioniMassiveUpload newSharingBatch = new BatchSharingQuotazioniMassiveUpload(theCsvProcessingStatus.IdsInsertedLeads);
            
            //CAPOBIANCO_A 18/07/2017 SPRINT 46 -- START
            if(Test.isRunningTest())
            {
                Database.executeBatch(newBatch,5); 
                Database.executeBatch(newSharingBatch,5);

            }
            else
            {
                Database.executeBatch(newBatch,1); //lowered from 5 to 1 in order to prevent errors because of the logic about the de-duplication of massively uploaded leads
                Database.executeBatch(newSharingBatch,1);
            }
            //CAPOBIANCO_A 18/07/2017 SPRINT 46 -- END
            //emailHandling (theCsvProcessingStatus.impactedQueues);
        }
    }

    public class csvProcessingStatus
    {
        public Integer nextStartingRow;
        public Integer totalSize;
        public Set<String> impactedQueues;
        public boolean isFinished;
        //FM 12/01/2018 -List of Leads'Ids addedd
        public List<Id> IdsInsertedLeads; 
        public csvProcessingStatus()
        {

        }
    }

    public void statusUpdate ()
    //only to give a feedback on the execution status
    {
        Lead_Upload_History__c historyRecord = [Select id,righe_totali__c,righe_processate__c from Lead_Upload_History__c where id = :leadHistoryId];
        historyRecord.righe_totali__c = theCsvProcessingStatus.totalSize;
        historyRecord.righe_processate__c = theCsvProcessingStatus.nextStartingRow;
        update historyRecord;
    }

    public static csvProcessingStatus processCsv (Id leadHistoryId, Integer csvStartingRow, String leadType, Set<String> queues)
    {
        csvProcessingStatus currentStatus = new csvProcessingStatus();
        currentStatus.isFinished = false;
        List<MappingProvince__c> province = [SELECT ProvinciaExternalKey__c, SFDCexpected__c FROM MappingProvince__c];
        Map<String,String> siglaCitta = new Map<String,String>();
        for(MappingProvince__c x : province)
            siglaCitta.put(x.ProvinciaExternalKey__c,x.SFDCexpected__c );


                 List<Attachment> validatiFile;
        
        try{
            validatiFile = [SELECT Body,Id,ParentId FROM Attachment WHERE parentId =:leadHistoryId and Name like '%validati%'];
           }
        catch(Exception e){
                ApplicationLogHelper.ERROR('LeadCSVLoaderBatch', e.getMessage(), e.getStackTraceString());
            
            // Database.DeleteResult MyResult = Database.delete(cc);
            }
        String validati = validatiFile.get(0).body.toString();
        List<String> righe = validati.split('\r\n');

        Integer totalSize = righe.size();
        Integer csvEndRow = csvStartingRow+1;//BOVOLENTA_D 20092017 lowered from 20
        currentStatus.totalSize = totalSize;

        If (csvEndRow>=totalSize)
        {
            csvEndRow = totalSize;
            currentStatus.isFinished = true;
        }
        currentStatus.nextStartingRow = csvEndRow;
        List<Lead> leadsToInsert = new List<Lead>();
        
        System.debug('****************righe.size() '+righe.size());
        System.debug('****************righe '+righe);
        if(leadType == 'Auto'){
            for(Integer k = csvStartingRow; k < csvEndRow; k++){
                System.debug('****************AUTO righe k  '+righe[k]);
                leadsToInsert.add(LeadBuilder.auto(righe[k]));
            }
        }
        if(leadType == 'Rami Elementari'){
            for(Integer k = csvStartingRow; k < csvEndRow; k++){
                System.debug('****************righe k '+righe[k]);
                leadsToInsert.add(LeadBuilder.nonAuto(righe[k],siglaCitta));
            }
        }
        if(leadType == 'Previdenza'){
            for(Integer k = csvStartingRow; k < csvEndRow; k++){
                System.debug('****************righe k '+righe[k]);
                leadsToInsert.add(LeadBuilder.Previdenza(righe[k],siglaCitta));
            }
        }
        if(leadType == 'Protezione'){
            for(Integer k = csvStartingRow; k < csvEndRow; k++){
                System.debug('****************righe k '+righe[k]);
                leadsToInsert.add(LeadBuilder.Protezione(righe[k],siglaCitta));
            }
        }        
        System.debug('****************leadsToInsert '+leadsToInsert);    
        //insert leadsToInsert;
        Database.insert(leadsToInsert,false); //CAPOBIANCO_A 12/07/2017
        System.debug('****************InsertedLeads '+leadsToInsert); // FM - 12/01/2018
        list<String> impactedQueue = new list<String>();
        List<Id> ListIdsInsertedList = new List<Id>();// FM - 12/01/2018
        for (Lead theLead :leadsToInsert)
        {
            impactedQueue.add('Coda_Agenzia_'+theLead.Agency_code__c);
            ListIdsInsertedList.add(theLead.Id);// FM - 12/01/2018
        }
        set<String> setQueue = new Set<String>(impactedQueue);
        system.debug('*******setQueue '+setQueue );
        queues.addAll(setQueue);
        currentStatus.impactedQueues = queues;
        currentStatus.IdsInsertedLeads = ListIdsInsertedList;// FM - 12/01/2018
        system.debug('MY NEW CURRENT STATUS'+currentStatus);
        return currentStatus;
    }

    
    
    
}