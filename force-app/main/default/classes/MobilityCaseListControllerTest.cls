@IsTest
public class MobilityCaseListControllerTest {

	static testMethod void testCaseList() {
     	
        ServiceUtilsClass.populateCustomSettingsForTests();

        Case ca = new Case();
        insert ca;
        String caseId = String.valueOf(ca.Id);
        
        Test.startTest();
        MobilityCaseListController.getCase();
        MobilityCaseListController.getCase(10);
        MobilityCaseListController.getCounterCloseTheLoop();
        MobilityCaseListController.getAssistanceUser();
        MobilityCaseListController.getCaseById(caseId);
		MobilityCaseListController.getCaseDetail(caseId);
        Test.stopTest();
        
    }
}