@isTest
public with sharing class selfQAdVWizardManageSubject_Test {
    @testSetup
    static void createTestData() {

        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;

        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('Axa_Assicurazioni').getRecordTypeId();

        Case c = new Case(
        Description = 'Test',
        SuppliedEmail = 'd.venanzi@reply.com',
        Origine_Pratica_Documentale__c = 'WFCL',
        RecordtypeId = devRecordTypeId,
        Pratica_Documentale__c = true
        );
        insert c;
        Case thisC = [SELECT id, SuppliedEmail, Origine_Pratica_Documentale__c , RecordtypeId, Pratica_Documentale__c FROM Case WHERE SuppliedEmail = 'd.venanzi@reply.com' LIMIT 1];
        
        DocumentAccount__c da = new DocumentAccount__c(
        CaseId__c = thisC.id,
        SurnameCompanyName__c = 'SurnameTest',
        SubjectType__c = 'PF',
        FirstName__c = 'Mario',
        Role__c = 'Richiedente'
        );
        insert da;
        DocumentAccount__c thisDa = [SELECT id, CaseId__c, SurnameCompanyName__c, SubjectType__c, FirstName__c, Role__c FROM DocumentAccount__c WHERE FirstName__c = 'Mario'];

        DocumentChecklistItem__c dc = new DocumentChecklistItem__c(
            CaseId__c = thisC.id,
            DocumentAccountId__c = thisDa.id,
            Document_Type__c = 'DDI'
        );
        insert dc;
        //DocumentChecklistItem__c thisDc = [SELECT id, CaseId__c, DocumentAccountId__c, Override__c, ToLabel(Document_Type__c) FROM DocumentChecklistItem__c WHERE Document_Type__c = 'DDI'];
    }
    @IsTest
    static void executeTest() {        
        String operationType = 'Generico_DDI';
        Case thisC = [SELECT id, SuppliedEmail, Origine_Pratica_Documentale__c , RecordtypeId, Pratica_Documentale__c FROM Case WHERE SuppliedEmail = 'd.venanzi@reply.com' LIMIT 1];
        DocumentAccount__c thisDa = [SELECT id, CaseId__c, SurnameCompanyName__c, SubjectType__c, FirstName__c, Role__c FROM DocumentAccount__c WHERE FirstName__c = 'Mario'];
        selfQAdVWizardManageSubjectController.InitWrapper res = selfQAdVWizardManageSubjectController.init(thisDa.id, operationType, thisC.id);
        selfQAdVWizardManageSubjectController.init(thisC.id, operationType, thisC.id);
        
        System.assertEquals(res.isSuccess, true);
    }
}