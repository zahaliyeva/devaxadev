@isTest
public class ChiudiCaseCmpController_TEST {
    
    static testMethod void method1() {
        Case c = new Case();
        ChiudiCaseCmpController.updateCaseStatus(c.Id, 'Cancelled');
    }
}