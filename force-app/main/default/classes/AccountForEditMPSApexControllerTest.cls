@isTest
public class AccountForEditMPSApexControllerTest {
    @testSetup private static void createData(){
        Account a = new Account(Name = 'Test');
        insert a;
    }
    
    @isTest static void test() {
        Test.startTest();
        Account a = [SELECT Name, Additional_Email__c, Additional_Phone__c, Additional_Comments__c FROM Account];
        AccountForEditMPSApexController.getAccountData(a.Id);
        Test.stopTest();          
        System.assertEquals('Test', a.Name);
    }
}