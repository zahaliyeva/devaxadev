/**
 * @description Batch per cancellare files vecchi di selfqadv
 * @author  reply    
 * @since   09-05-2023    
 */
public without sharing class SelfQaDVCleanFiles implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private AAI_Code_Variables__c limitDay ;
    private date thatDay ;  
    private String folderId;
    private Integer batchType;
    private Integer batchHour = 4;
    private integer scopeSize;
    private boolean isAutoSchedulable;
    
    String BATCH_NAME = 'SelfQaDVCleanFiles';
    
    /**
     * @description     constructor
     * @param batchType 1 for old files, 2 for orphan files
     */
    public SelfQaDVCleanFiles(Integer batchType){
        try{
            String devToSearch = 'Run_QaDV_Clean_'+batchType;
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                ScopeSize__c,Query__c,Need_Information_Log__c, Daily_Hour_Start__c, Daily_Hour_End__c
                from BatchSetting__mdt
                where DeveloperName =: devToSearch];
            this.batchHour = (Integer) batchSettings.Daily_Hour_Start__c;
            
            this.batchType = batchType;
            if(this.batchType == 2){
                ContentFolder cf = [Select id from ContentFolder where name = 'Staging' WITH SYSTEM_MODE].get(0);
                this.folderId = cf.Id;
            }
            
            else{
                limitDay = [SELECT Value__c, Name FROM AAI_Code_Variables__c WHERE Name =: 'QaDVDeleteLimitDays'  WITH SYSTEM_MODE];
            thatDay = date.Today().addDays(- Integer.valueof(limitDay.Value__c)); 
            }
            
        }catch (Exception errorEx){
            ApplicationLogHelper.ERROR('SelfQaDVCleanFiles', errorEx.getMessage(), errorEx.getStackTraceString());
        } 
    }

    /**
     * @description 
     * @param BC    
     * @return      `database.querylocator`
     */
    public database.querylocator start(Database.BatchableContext BC)
    {
        string query;
        if(this.batchType == 2){
            query = 'Select Id from ContentDocument where id in (Select ChildRecordId from ContentFolderMember where ParentContentFolderId = \'' + folderId +  '\')';
            
        }
        else{
            query = 'select contentDocumentId from contentDocumentLink where linkedEntityId in (select id from documentChecklistItem__c where override__c = false AND FilenetId__c != null AND caseId__r.isClosed = true and caseId__r.closedDate <=: thatDay)';
        }
        
        return Database.getQueryLocator(query);
    }

    /**
     * @description schedule the batch
     * @param SC    
     */
    public void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        SelfQaDVCleanFiles mcb = new SelfQaDVCleanFiles(batchType);
        Database.executeBatch(mcb);
    }

    /**
     * @description 
     * @param BC    
     * @param scope 
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        try{
            
            list<ContentDocument> cdToDelete = new list<ContentDocument>();
            String field;
            if(batchType == 2){
                field = 'Id';
            }  
            else{
                field = 'ContentDocumentId';
            }
            for(sObject link : scope){
                cdToDelete.add(
                    new ContentDocument(
                        Id = (Id) link.get(field)
                    )
                );        
            }   

            delete cdToDelete;
        }catch (Exception errorEx){
            ApplicationLogHelper.ERROR('SelfQaDVCleanFiles', errorEx.getMessage(), errorEx.getStackTraceString());
        } 
    }

    /**
     * @description 
     * @param BC    
     */
    public void finish(Database.BatchableContext BC){       
        DateTime now = DateTime.Now();
        DateTime newSchedule = datetime.newInstance(now.date()+1, time.newInstance(batchHour,0,0,0));
        System.schedule(BATCH_NAME+batchType, this.getCron(newSchedule), new SelfQaDVCleanFiles(batchType));
    }
    
    /**
     * @description  defines the cron expression       
     * @param next_schedule 
     * @return              `String`
     */
    private String getCron(DateTime next_schedule){
        
        String min = String.valueOf(next_schedule.minute());
        String hh = String.valueOf(next_schedule.hour());
        String dd = String.valueOf(next_schedule.day());
        String mm = String.valueOf(next_schedule.month());
        String yy = String.valueOf(next_schedule.year());
             
        return '0 ' + min + ' ' + hh + ' ' + dd + ' ' + mm + ' ? ' + yy;
    }
}