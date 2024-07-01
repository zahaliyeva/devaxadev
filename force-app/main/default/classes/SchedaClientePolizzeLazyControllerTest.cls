@isTest 
private class SchedaClientePolizzeLazyControllerTest {

    @TestSetup
    public static void makeData(){
        SchedaClienteControllerTest.makeData();
    }

    @isTest
    public static void testController(){
        Test.startTest();
        InsurancePolicy__c policy = [SELECT Id, CUID__c from InsurancePolicy__c LIMIT 1];
        List<String> asa = new List<String>{'Auto'};
        SchedaClientePolizzeLazyController.getRecords(policy.CUID__c, JSON.serialize(asa), 1, 'New');
        SchedaClientePolizzeLazyController.getCount(policy.Id, JSON.serialize(asa), 'New');
        Test.stopTest();

    }
}