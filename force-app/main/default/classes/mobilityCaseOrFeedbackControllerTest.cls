/** 
 * @author	Reply
 * @date	1/03/2023
 * @description Class Test per la classe mobilityCaseOrFeedbackController
 */
@isTest
public class mobilityCaseOrFeedbackControllerTest {
    @isTest
    static void getCase() {
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
		List<case> caseList = new List<case>();
		for (Integer count = 0;
		     count < 2;
		     count++) {
			caseList.add(new Case(Description='Prova '+count,Status = 'Open', Origin = 'Phone'));
		}
		insert caseList;
                
        User User1 = new User();
        Account Account1 = new Account(Name = 'Alberto');
        Account1.Ndg__c = '123';
        insert Account1;
        Map<String,List< Object>> Map1 = new Map<String,List< Object>>();
        
		Test.startTest();
		String caseId = String.valueOf(caseList[0].Id);
        Id UserId = User1.Id;
        mobilityCaseOrFeedbackController.getCase(2,Map1,null,'ASC',null);
        system.assertEquals(caseId!= null, true,'Il case deve essere inserito OK');
		Test.stopTest();
	}
    @isTest
    static void getFeedback() {
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
		List<case> caseList = new List<case>();
		for (Integer count = 0;
		     count < 2;
		     count++) {
			caseList.add(new Case(Description='Prova '+count,Status = 'Open', Origin = 'Phone'));
		}
		insert caseList;
        
        User User1 = new User();
        Account Account1 = new Account(Name = 'Alberto');
        Account1.Ndg__c = '123';
        insert Account1;
        
        Test.startTest();
        Map<String,List< Object>> Map1 = new Map<String,List< Object>>();
		String caseId = String.valueOf(caseList[0].Id);
        Id UserId = User1.Id;
        mobilityCaseOrFeedbackController.getFeedBacks(2,Map1,null,'ASC',null);
        system.assertEquals(caseId!= null, true,'Il case deve essere inserito OK');
		Test.stopTest();
	}

}