@isTest(seeAllData=false)
public class IE_GetAllPolicies_TEST {
    
    //FAILURE MOCK T720
    public class Test_MockIE_GetAllPoliciesErrorResponseT720 implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"code" : "T720", "developerMessage" : "test"}');
            res.setStatusCode(500);
            return res;
        }
    } 
    
    //FAILURE MOCK UNHANDLED
    public class Test_MockIE_GetAllPoliciesErrorResponseUnhandled implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"code" : "T222222", "developerMessage" : "test"}');
            res.setStatusCode(500);
            return res;
        }
    } 
    
    //POSITIVE MOCK
    public class Test_MockIE_GetAllPoliciesPositiveResponse implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('[{"policyId":"000001-008382-000005-066791457","commercialTypes":[{"code":"AUTO_PRODUCT"}],"commonData":{"publicId":"066791457","statusCode":"IN_FORCE","statusName":"Polizza valida","effectiveDate":"2016-05-04","initialEffectiveDate":"2015-05-04","expirationDate":"2017-05-04","expirationDescription":"QUIETANZA RINNOVO","productId":"AXASTO","productName":"Auto Storiche - AXA Assicurazioni S.p.A.","accountManagerId":"008382","endCoverageDate":"2017-05-19","policyCommonDataMetadata":{"dataSource":"AAI"}},"insuredVehicle":{"make":"PIAGGIO & C VNX2T VESPA PX 125 E","registration":{"id":"CT132124","typeName":"Targa","typeCode":"VEHICLE_REGISTRATION","startDate":"1980-01-01"}},"links":[{"rel":"PolicyDetail","uri":"/policies/000001-008382-000005-066791457","method":"GET"}]}, {"policyId":"000001-008382-000005-236499739","commercialTypes":[{"code":"AUTO_PRODUCT"}],"commonData":{"publicId":"236499739","statusCode":"IN_FORCE","statusName":"Polizza valida","effectiveDate":"2016-10-03","initialEffectiveDate":"2016-10-03","expirationDate":"2017-10-03","expirationDescription":"EMISSIONE","productId":"CUBA","productName":"Protezione Al Volante - AXA Assicurazioni S.p.A.","accountManagerId":"008382","endCoverageDate":"2017-10-18","policyCommonDataMetadata":{"dataSource":"AMPS"}},"insuredVehicle":{"make":"FIAT","model":"PANDA","registration":{"id":"BF083CT","typeName":"Targa","typeCode":"VEHICLE_REGISTRATION","startDate":"1999-08-01"}},"links":[{"rel":"PolicyDetail","uri":"/policies/000001-008382-000005-236499739","method":"GET"}]}]');
            res.setStatusCode(200);
            return res;
        }
    }  
    
    static {
        MPS_Code_Variables__c code = new MPS_Code_Variables__c(Name = 'CaringAngel_EmailToCallSOL', Value__c = 'salesforce@caringangel.it');
        insert code;
    }
    
    static testMethod void IE_GetAllPolicies_method1(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs/policies');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();
        response = IE_GetAllPolicies.sendRequest('MCCGNN88P14F839W',(String)acct.Id);
        Test.stopTest();
    }
    
    static testMethod void IE_GetAllPolicies_method2_ErrorT720(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs/policies');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllPoliciesErrorResponseT720());
       	IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();
        response = IE_GetAllPolicies.sendRequest('MCCGNN88P14F839W',(String)acct.Id);
        Test.stopTest();
    }
    
    static testMethod void IE_GetAllPolicies_method3_Positive(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs/policies');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllPoliciesPositiveResponse());
        IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();
        response = IE_GetAllPolicies.sendRequest('MCCGNN88P14F839W',(String)acct.Id);
        Test.stopTest();
    }
    
    static testMethod void IE_GetAllPolicies_method4_ErrorUnhandled(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs/policies');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllPoliciesErrorResponseUnhandled());
        IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();
        response = IE_GetAllPolicies.sendRequest('MCCGNN88P14F839W',(String)acct.Id);
        Test.stopTest();
    }
}