@isTest 
private class SchedaClienteCaseLazyControllerTest {

    @TestSetup
    public static void makeData(){
        SchedaClienteControllerTest.makeData();
    }

    @isTest
    public static void testController(){
        Test.startTest();
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        SchedaClienteCaseLazyController.getRecords(c.AccountId, 1);
        SchedaClienteCaseLazyController.getCount(c.AccountId);
        Test.stopTest();
    }
}