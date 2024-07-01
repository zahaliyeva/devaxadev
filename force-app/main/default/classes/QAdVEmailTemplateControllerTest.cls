@isTest
public class QAdVEmailTemplateControllerTest {
@testSetup
    static void createTestData() {
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        
        Case c = new Case(
        Description = 'Test',
        SuppliedEmail = 'd.venanzi@reply.com',
       	Tipo_Operazione__c = 'A'
        );
        insert c;
        Case thisC = [SELECT id, SuppliedEmail FROM Case WHERE SuppliedEmail = 'd.venanzi@reply.com' LIMIT 1];
        
        DocumentAccount__c da = new DocumentAccount__c(
        CaseId__c = thisC.id,
        SurnameCompanyName__c = 'SurnameTest',
        SubjectType__c = 'PF',
        FirstName__c = 'Mario',
        Role__c = 'Richiedente'
        );
        insert da;
        
        DocumentAccount__c da2 = new DocumentAccount__c(
        CaseId__c = thisC.id,
        SurnameCompanyName__c = 'SurnameTest',
        SubjectType__c = 'PF',
        FirstName__c = 'Mario',
        Role__c = 'Soggetto'
        );
        insert da2;
        
    }
    
    @isTest
    static void testExecute() {
       
        Case thisC = [SELECT id, SuppliedEmail FROM Case WHERE SuppliedEmail = 'd.venanzi@reply.com' LIMIT 1];
        QAdVEmailTemplateController.caseId = thisC.id;
        
        QAdVEmailTemplateController qtc = new QAdVEmailTemplateController();
        
        qtc.getDocumentAccountRichiedente();
        qtc.getDocumentAccounts();
        qtc.getThisCase();

        System.assert(thisC != null);
        
    }
}