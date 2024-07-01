@isTest
public class SelfQaDVIntegrationTest {
    
    @testSetup
    static void createTestData() {
        
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        
        IE_Configuration__c conf = new IE_Configuration__c(
            Name = 'Auth0',
            ClientId__c = '12345',
            Client_Secret__c = '12345',
            EndPoint__c = 'https://',
            Silva_Token_Expiration_DateTime__c = (System.now() - 1),
            Request_Compiler__c = 'IE_Auth0_Request',
            Response_Parser__c = 'IE_Auth0_Response',
            Type__c = 'WebService_rest',
            HTTPMethod__c = 'GET',
            Silva_Access_Token__c = '1234'
        );
        insert conf;
        
        IE_Configuration__c conf3 = new IE_Configuration__c(
            Name = 'Auth0_Get_Token',
            ClientId__c = '12345',
            Client_Secret__c = '12345',
            EndPoint__c = 'https://',
            Silva_Token_Expiration_DateTime__c = (System.now() - 1),
            Request_Compiler__c = 'IE_Auth0_Request',
            Response_Parser__c = 'IE_Auth0_Response',
            Type__c = 'WebService_rest',
            HTTPMethod__c = 'GET',
            Silva_Access_Token__c = '1234'
        );
        insert conf3;

        
        IE_Configuration__c conf2 = new IE_Configuration__c(
            Name = 'DHPolicy',
            ClientId__c = '12345',
            Client_Secret__c = '12345',
            EndPoint__c = 'https://',
            Silva_Token_Expiration_DateTime__c = (System.now() - 1),
            Request_Compiler__c = 'IE_DH_Request',
            Response_Parser__c = 'IE_DH_Response',
            Type__c = 'WebService_rest',
            HTTPMethod__c = 'GET',
            Silva_Access_Token__c = '1234'
        );
        insert conf2;
        
        Case c = new Case(
        Description = 'Test',
        SuppliedEmail = 'd.venanzi@reply.com'            
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
    }
    
     @isTest
    static void testCalloutAuth0() {
        IE_Auth0_RequestWrapper req = new IE_Auth0_RequestWrapper();
		req.name = 'Giorgio';
		req.surname = 'Giorgi';
		req.email = 'giorgio.giorgi@gmail.com';
        Test.setMock(HttpCalloutMock.class, new SelfQaDVIntegrationMock());
        Test.startTest();
        IE_Auth0_Execute.executeAuth0(req);
        Test.stopTest();
    }
    
    @isTest
    static void testCalloutDh() {
        Test.setMock(HttpCalloutMock.class, new SelfQaDVIntegrationMock());
        Test.startTest();
        IE_DH_Execute.ExecuteDH('DAOL-0011070000100795-82663253', 'GSTSFN61S47F158N');
        Test.stopTest();
    }
    
    
    
}