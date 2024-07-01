@IsTest
private class DeleteBatchTest {

    @IsTest
    public static void testDeleteById(){
        Test.startTest();
        Lead firstLead = new Lead(LastName = 'First Lead');
        insert firstLead;
        Lead secondLead = new Lead(LastName = 'Second Lead');
        insert secondLead;
        Lead thirdLead = new Lead(LastName = 'Third Lead');
        insert thirdLead;
        DeleteBatch__c configuration = new DeleteBatch__c(
            sObject__c = 'Lead',
            Data_Creazione_Da__c = DateTime.now().addDays(-1),
            Data_Creazione_A__c = DateTime.now(),
            Lista_Id__c = firstLead.Id + ',' + secondLead.Id);
        insert configuration;
        Database.executeBatch(new DeleteBatch());
        Test.stopTest();
        List<Lead> leads = [SELECT Id from Lead];
        System.assertEquals(1, leads.size(), 'Leads First and Lead Second deleted');
    }

    @IsTest
    public static void testDeleteByDateFromAndDateTo(){
        Test.startTest();
        Lead firstLead = new Lead(LastName = 'First Lead');
        insert firstLead;
        Lead secondLead = new Lead(LastName = 'Second Lead');
        insert secondLead;
        Lead thirdLead = new Lead(LastName = 'Third Lead');
        insert thirdLead;
        DeleteBatch__c configuration = new DeleteBatch__c(
            sObject__c = 'Lead',
            Data_Creazione_Da__c = DateTime.now().addDays(-1),
            Data_Creazione_A__c = DateTime.now());
        insert configuration;
        Database.executeBatch(new DeleteBatch());
        Test.stopTest();
        List<Lead> leads = [SELECT Id from Lead];
        System.assertEquals(0, leads.size(), 'Leads deleted');
    }

    @IsTest
    public static void testDeleteByDateFrom(){
        Test.startTest();
        Lead firstLead = new Lead(LastName = 'First Lead');
        insert firstLead;
        Lead secondLead = new Lead(LastName = 'Second Lead');
        insert secondLead;
        Lead thirdLead = new Lead(LastName = 'Third Lead');
        insert thirdLead;
        DeleteBatch__c configuration = new DeleteBatch__c(
            sObject__c = 'Lead',
            Data_Creazione_Da__c = DateTime.now().addSeconds(1));
        insert configuration;
        Database.executeBatch(new DeleteBatch());
        Test.stopTest();
        List<Lead> leads = [SELECT Id from Lead];
        System.assertEquals(3, leads.size(), 'no Leads deleted');
    }

    @IsTest
    public static void testDeleteByDateTo(){
        Test.startTest();
        Lead firstLead = new Lead(LastName = 'First Lead');
        insert firstLead;
        Lead secondLead = new Lead(LastName = 'Second Lead');
        insert secondLead;
        Lead thirdLead = new Lead(LastName = 'Third Lead');
        insert thirdLead;
        DeleteBatch__c configuration = new DeleteBatch__c(
            sObject__c = 'Lead',
            Data_Creazione_A__c = DateTime.now());
        insert configuration;
        Database.executeBatch(new DeleteBatch());
        Test.stopTest();
        List<Lead> leads = [SELECT Id from Lead];
        System.assertEquals(0, leads.size(), 'all Leads deleted');
    }


}