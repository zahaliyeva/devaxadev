@isTest
public class mobilityCreateTaskControllerTest {
    
    static testMethod void getCase() {
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        
        User User1 = new User();
        Account Account1 = new Account(Name = 'Alberto');
        Account1.Ndg__c = '123';
        insert Account1;
        
		Test.startTest();
        mobilityCreateTaskController.getUserName();
        mobilityCreateTaskController.getRecordType('General_RecordType');
        mobilityCreateTaskController.getAccount('123');
		Test.stopTest();
	}

}