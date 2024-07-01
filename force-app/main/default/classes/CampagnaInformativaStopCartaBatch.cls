global class CampagnaInformativaStopCartaBatch implements Schedulable, Database.Batchable<sObject> {
    
    global CampagnaInformativaStopCartaBatch(){}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('DeleteBatch.start start');
        return Database.getQueryLocator([SELECT Id, Account__c FROM Massive_Communication__c WHERE Type__c = 'Paper' AND PrivacyEmail__c IN ('no', 'nd') AND Contact__c = null AND Log__c = null]);
    } 

    global void execute(Database.BatchableContext bc, List<Massive_Communication__c> records){
        System.debug('DeleteBatch.execute start'); 
        try {
            Map<Id, Id> massiveCommunicationMap = new Map<Id, Id>();
            List<Contact> contacts = new List<Contact>();
            for(Massive_Communication__c record: records){ 
                if(record.Account__c != null ){
                    massiveCommunicationMap.put(record.Id, record.Account__c);
                }
            } 
            contacts = [SELECT Id, AccountId from Contact where AccountId in :massiveCommunicationMap.values()];
            Map<Id, Id> contactAccountMap = new Map<Id, Id>();
            for(Contact record: contacts){ 
                if(record.AccountId != null ){
                    contactAccountMap.put(record.AccountId, record.Id);
                }
            } 
            for(Massive_Communication__c record: records){ 
                    Id contactId = contactAccountMap.get(record.Account__c);
                    if(String.isBlank(contactId)){
                         record.Log__c = 'Campagna Informativa StopCarta: Massive_Communication__c.Account__r.Contact non valorizzato';
                    } else {
                        record.Contact__c = contactId;
                    }
            }
            update records;
        } catch(Exception ex){
            ApplicationLogHelper.ERROR('CampagnaInformativaStopCartaBatch', ex.getMessage(), ex.getStackTraceString());
        }
        System.debug('DeleteBatch.execute end');
    } 

    global void finish(Database.BatchableContext bc){
        System.debug('DeleteBatch.finish start');
        System.debug('DeleteBatch.finish end');
    }
    
    global void execute(SchedulableContext sc) {
        CampagnaInformativaStopCartaBatch batch = new CampagnaInformativaStopCartaBatch();
        database.executebatch(batch, 100);
    }
}