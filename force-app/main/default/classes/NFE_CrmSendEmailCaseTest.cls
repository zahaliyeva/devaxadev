@isTest
public class NFE_CrmSendEmailCaseTest {
    @testSetup private static void createData(){
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        Account a = new Account(Name = 'Test');
        insert a;
        Case c = new Case(AccountId = a.Id);
        insert c;
    }
    
    @isTest static void test() {
        Test.startTest();
        Case c = [SELECT id, SuppliedEmail, AccountId FROM Case LIMIT 1];
        NFE_CrmSendEmailCase.getToAddress(c.Id);
        Test.stopTest();          
    }
}