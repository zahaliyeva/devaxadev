@IsTest 
public class NFE_CrmChiudiCaseControllerTest {

    @TestSetup
    public static void makeData(){
        SchedaClienteControllerTest.makeData();
    }

    @isTest
    public static void testController(){
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        NFE_CrmChiudiCaseController.getCase(c.Id);
        Test.stopTest();
    }
}