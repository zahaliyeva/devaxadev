/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         IE_GetAllClaims_TEST
Description:   Apex test class 

History

01/10/2018     Created 
-------------------------------------------------------------------------------------------*/
@isTest(seeAllData=false)
private class IE_GetAllClaims_TEST {
    
    //FAILURE MOCK T720
    public class Test_MockIE_GetAllClaimsErrorResponseT720 implements HttpCalloutMock 
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
    public class Test_MockIE_GetAllClaimsErrorResponseUnhandled implements HttpCalloutMock 
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
    public class Test_MockIE_GetAllClaimsPositiveResponse implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('[{"id":"1.1807.99.014077","policyId":"1.1807.5.062715027","commercialTypeCodes":["AUTO_PRODUCT"],"lossNotificationDate":"2015-11-13T00:00:00Z","closureDate":"2015-11-13T00:00:00Z","openIndicator":true,"links":[{"rel":"ClaimDetail","uri":"/claims/1.1807.99.014077","method":"GET"}],"idCase":"123","isPreDenunciation":false}]');
            res.setStatusCode(200);
            return res;
        }
    }  
    
    static {
        MPS_Code_Variables__c code = new MPS_Code_Variables__c(Name = 'CaringAngel_EmailToCallSOL', Value__c = 'salesforce@caringangel.it');
        insert code;
    }
    
    static testMethod void IE_GetAllClaims_method1(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllClaims', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllClaims', Response_parser__c = 'IE_Parser_GetAllClaims',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-claims-vs/claims');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        IE_GetAllClaims.ResponseDto response = new IE_GetAllClaims.ResponseDto();
        response = IE_GetAllClaims.sendRequest((String)acct.Id, '', false,'',true);
        Test.stopTest();
    }
    
    static testMethod void IE_GetAllClaims_method2_ErrorT720(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllClaims', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllClaims', Response_parser__c = 'IE_Parser_GetAllClaims',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-claims-vs/claims');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllClaimsErrorResponseT720());
        IE_GetAllClaims.ResponseDto response = new IE_GetAllClaims.ResponseDto();
        response = IE_GetAllClaims.sendRequest((String)acct.Id, '', false,'',true);
        Test.stopTest();
    }
    
    static testMethod void IE_GetAllClaims_method3_Positive(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllClaims', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllClaims', Response_parser__c = 'IE_Parser_GetAllClaims',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-claims-vs/claims');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllClaimsPositiveResponse());
        IE_GetAllClaims.ResponseDto response = new IE_GetAllClaims.ResponseDto();
        response = IE_GetAllClaims.sendRequest((String)acct.Id, '', false,'',true);
        Test.stopTest();
    }
    
    static testMethod void IE_GetAllClaims_method4_ErrorUnhandled(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllClaims', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllClaims', Response_parser__c = 'IE_Parser_GetAllClaims',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-claims-vs/claims');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllClaimsErrorResponseUnhandled());
        IE_GetAllClaims.ResponseDto response = new IE_GetAllClaims.ResponseDto();
        response = IE_GetAllClaims.sendRequest((String)acct.Id, '', false,'',true);
        Test.stopTest();
    }
}