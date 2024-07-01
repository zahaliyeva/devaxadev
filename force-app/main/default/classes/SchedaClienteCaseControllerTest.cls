@isTest 
private class SchedaClienteCaseControllerTest {
    
    @TestSetup
    public static void makeData(){
        SchedaClienteControllerTest.makeData();
    }

    @isTest
    public static void testController(){
        Test.startTest();
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        SchedaClienteCaseController.getCases(c.AccountId);
        Test.stopTest();
    }
}