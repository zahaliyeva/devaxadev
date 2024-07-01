@isTest
public class MassiveCommunicationsBatch2_Test {
	@TestSetup
    static void testSetup() {
        Account a = new Account(FirstName = 'test', LastName = 'Test');
        insert a;
        insert new Massive_Communication__c(Type__c = 'Digital',Status__c='Pending',Tech_status_update_date__c=system.today().addDays(-7), Account__c = a.id);

    }
    
    @IsTest
    static void TestBatch(){
        test.startTest();
        database.executeBatch(new MassiveCommunicationBatch2());
        test.stopTest();
        List<Massive_Communication__c> tempList = [Select Status__c,Send_Error_Detail__c from Massive_Communication__c limit 1];
        system.assertEquals('KO digital sending', tempList[0].Status__c);
        system.assertEquals('mancata elaborazione Digital', tempList[0].Send_Error_Detail__c);
    }
}