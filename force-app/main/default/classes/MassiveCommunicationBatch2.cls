global class MassiveCommunicationBatch2 implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    
    public String query = 	'SELECT id, Status__c, Send_Error_Detail__c, TECH_Status_Update_Date__c'+ 
        					' FROM Massive_Communication__c '+
        				  	'WHERE Type__c = \'Digital\' AND Status__c not in'+
        					' (\'Sent\',\'Sent by mail\',\'KO digital sending\') AND '+
        					'Tech_status_update_date__c < LAST_N_DAYS:5';
    public Integer batchSize = 200;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Massive_Communication__c> scope) {
        this.UpdateMassiveCommunication(scope);
    }
    global void finish(Database.BatchableContext bc){
        
    }
    global void execute(SchedulableContext SC) {
        MassiveCommunicationBatch2 mcb = new MassiveCommunicationBatch2();
        Database.executeBatch(mcb, this.batchSize);
    }
    
    private void updateMassiveCommunication(List<Massive_Communication__c> communications) {
        for(Massive_Communication__c temp : communications){
            temp.Status__c = 'KO digital sending';
            temp.Send_Error_Detail__c = 'mancata elaborazione Digital';
            temp.TECH_Status_Update_Date__c = system.now();
        }
        
        
        update communications;
        
        
    }
}