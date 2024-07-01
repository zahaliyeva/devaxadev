global class DeleteBatch implements Database.Batchable<sObject> {

    private String sObjectName;
    private Datetime dateFrom;
    private Datetime dateTo;
    private List<String> ids = new List<Id>();
    private String query;

    public DeleteBatch() {
        DeleteBatch__c configuration = [SELECT sObject__c,  Data_Creazione_Da__c, Data_Creazione_A__c, Lista_Id__c from DeleteBatch__c LIMIT 1];
        this.sObjectName = configuration.sObject__c;
        this.dateFrom = configuration.Data_Creazione_Da__c;
        this.dateTo = configuration.Data_Creazione_A__c;
        this.ids = configuration.Lista_Id__c != null ? configuration.Lista_Id__c.split(',') : ids;
        query = 'SELECT Id FROM ' + sObjectName + ' WHERE ';
        if(!ids.isEmpty()){ 
            query += 'Id = :ids';
        } else if(dateFrom != null && dateTo != null){ 
             query += 'CreatedDate >= :dateFrom and CreatedDate <= :dateTo';
        } else if(dateFrom != null){
            query += 'CreatedDate >= :dateFrom';
        } else if(dateTo != null){
            query += 'CreatedDate <= :dateTo';
        }
        System.debug('DeleteBatch.constructor query' + query);
    }
  
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('DeleteBatch.start start');
        return Database.getQueryLocator(this.query);
    } 

    global void execute(Database.BatchableContext bc, List<SObject> records){
        System.debug('DeleteBatch.execute start');
        delete records;
        System.debug('DeleteBatch.execute end');
    } 

    global void finish(Database.BatchableContext bc){
        System.debug('DeleteBatch.finish start');
        System.debug('DeleteBatch.finish end');
    }


}