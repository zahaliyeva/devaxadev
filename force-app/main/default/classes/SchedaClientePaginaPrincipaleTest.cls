@isTest
public class SchedaClientePaginaPrincipaleTest {
    
    @TestSetup
    public static void makeData(){ 
        SchedaClienteControllerTest.makeData();
    }

    @isTest
    public static void testController(){
        Test.startTest();
        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.stopTest();
        SchedaClientePaginaPrincipaleController.getPolizze(account.Id, new List<String>{'1'}, 'New');
    }

}