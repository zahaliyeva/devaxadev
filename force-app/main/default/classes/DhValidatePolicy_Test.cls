@isTest
public class DhValidatePolicy_Test {
    
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
            Pratica_Documentale__c = true,
            Compagnia__c = '95',
            CategoriaPolizza__c = '11 - Individuale',
            NumeroPolizza__c = '9123',
            NumeroPolizzaFiglia__c = '456'
        );
        insert c;
        
        Case c2 = new Case(
            Description = 'Test',
            SuppliedEmail = 'd.venanzi@reply.com',
            Origine_Pratica_Documentale__c = 'WFCL',
            RecordtypeId = devRecordTypeId,
            Pratica_Documentale__c = true,
            Compagnia__c = '95',
            CategoriaPolizza__c = '',
            NumeroPolizza__c = '',
            NumeroPolizzaFiglia__c = ''
        );
        insert c2;
        
    }
    @IsTest
    static void executeTest() {        
        Case thisC = [SELECT id, Compagnia__c, CategoriaPolizza__c, NumeroPolizza__c, NumeroPolizzaFiglia__c, SuppliedEmail, Origine_Pratica_Documentale__c , RecordtypeId, Pratica_Documentale__c FROM Case WHERE SuppliedEmail = 'd.venanzi@reply.com' LIMIT 1];
        Case thisC2 = [SELECT id, Compagnia__c, CategoriaPolizza__c, NumeroPolizza__c, NumeroPolizzaFiglia__c, SuppliedEmail, Origine_Pratica_Documentale__c , RecordtypeId, Pratica_Documentale__c FROM Case WHERE SuppliedEmail = 'd.venanzi@reply.com' LIMIT 1];
        
        DhValidatePolicyController.responseWrapper res = DhValidatePolicyController.policyIdFormat(thisC);
        DhValidatePolicyController.responseWrapper res2 = DhValidatePolicyController.policyIdFormat(thisC2);
        DhValidatePolicyController.getConfigurationList();
        
        System.assertEquals(res.isSuccess, true);
        
        
    }
}