@isTest
public class LeadAutomatism_BatchTest {

    @TestSetup
    static void makeData(){
        List<Lead> leadToInsert = new List<Lead>();
        Lead l = new Lead(FirstName = 'Test', LastName= 'Test1', Status = 'Appointment', TECH_Company__c = 'MPS', LeadSource = 'Other');
        leadToInsert.add(l);
        Lead l1 = new Lead(FirstName = 'Test2', LastName= 'Test2',Status = 'Call again', TECH_Company__c = 'MPS', LeadSource = 'Other');
        leadToInsert.add(l1);
        insert leadToInsert;
        

        Event e = new Event(WhoId = l.Id, ActivityDate = Date.Today().addDays(-1), DurationInMinutes = 30, ActivityDateTime = DateTime.now().addDays(-1));
        Task t = new Task (WhoId = l1.Id, ActivityDate = Date.Today().addDays(-1));

        insert e;
        insert t;

        List<AAI_Code_Variables__c> confToInsert = new List<AAI_Code_Variables__c>();
        confToInsert.add(new AAI_Code_Variables__c(Name = 'LeadAutomatism_Batch_DaysBefore', value__c = '1'));
        confToInsert.add(new AAI_Code_Variables__c(Name = 'LeadAutomatism_Batch_Hour', value__c = '22'));
        
        insert confToInsert;
    }

    static testmethod void test1(){
        Test.startTest();
        LeadAutomatism_Batch b = new LeadAutomatism_Batch();
        
        Database.executeBatch(b);
        Test.stopTest();
        List<Lead> leadsToCheck = [select id, status, ownerID from Lead];
        List<Group> groups = [Select id from group where developername like 'Coda_Lead_Non_Lavorati_%'];
        List<Id> groupsId = new List<Id>();
        for(group g : groups){
            groupsID.add(g.Id);
        }

        for(Lead l : leadsToCheck){
            
            System.assert(l.Status.equalsIgnoreCase('Non Lavorato'));
            system.assert( groupsId.contains(l.ownerId) );
        }
        String jobID = LeadAutomatism_Batch.schedule(false);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id =: jobID];
        System.assertEquals(0, ct.TimesTriggered); 
        DateTime nextDate = Datetime.newInstance(Date.today().addDays(1), Time.newInstance(22, 0, 0, 0));
        System.assertEquals(nextDate, ct.NextFireTime);
    }
}