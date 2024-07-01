@IsTest
private class IE_GetPolicies_TEST {

    //POSITIVE MOCK
    public class GetPolicies_Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req){

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('[{"number":"string","idPolicy":"string","idAdhesion":"string","portfolio":"string","commonData":{"type":"string","policyEffectDate":"2020-03-10T13:57:47.247Z","policyEndDate":"2020-03-10T13:57:47.247Z","statusCode":"string","mainPolicy":"true","productCode":"string","productName":"string","productVersion":"string","mattoncinoVersion":"string","companyCode":"string","nodeCode":"string","branchCode":"string","personId":"string","name":"string","surname":"string"},"assets":[{"coverages":[{"baseCoverage":"string","specificCoverage":"string"}],"insuredHouseHolder":"false","insuredFiscalCode":"string","insuredBirthDate":"2020-03-10","insuredAssetDescription":"string","insuredCountry":"string","insuredVatNumber":"string","insuredGender":"string","idAsset":"string","assetDescription":"string","assetKey":"string","licensePlate":"string","country":"string","countryCode":"string","province":"string","town":"string","zipCode":"string","address":"string","placeAddress":"string","latitude":"string","longitude":"string","idSummary":"string"}]}]');
            res.setStatusCode(200);
            return res;
        }
    }


    //POSITIVE MOCK
    public class GetPolicy_Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req){

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"number":"string","idPolicy":"string","idAdhesion":"string","portfolio":"string","commonData":{"type":"string","policyEffectDate":"2020-03-10T13:56:18.818Z","policyEndDate":"2020-03-10T13:56:18.818Z","statusCode":"string","mainPolicy":"true","productCode":"string","productName":"string","productVersion":"string","mattoncinoVersion":"string","companyCode":"string","nodeCode":"string","branchCode":"string","personId":"string","name":"string","surname":"string"},"assets":[{"coverages":[{"baseCoverage":"string","specificCoverage":"string"}],"insuredHouseHolder":"false","insuredFiscalCode":"string","insuredBirthDate":"2020-03-10","insuredAssetDescription":"string","insuredCountry":"string","insuredVatNumber":"string","insuredGender":"string","idAsset":"string","assetDescription":"string","assetKey":"string","licensePlate":"string","country":"string","countryCode":"string","province":"string","town":"string","zipCode":"string","address":"string","placeAddress":"string","latitude":"string","longitude":"string","idSummary":"string"}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void testGetPolicies_KO(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'GetPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest',
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/it-esb-aoi-policies-v1-0-0_INT/v2/policies');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        IE_GetPolicies.ResponseDto response = new IE_GetPolicies.ResponseDto();
        response = IE_GetPolicies.sendRequestGetPolicies('MCCGNN88P14F839W', '', 'DAOL', '2020-01-01', false, false, false,'targa' );
        Test.stopTest();
    }

    @isTest
    public static void testGetPolicy_KO(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'GetPolicy', HTTPMethod__c='GET', Type__c = 'webservice_rest',
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/it-esb-aoi-policies-v1-0-0_INT/v2/policies/{policyId}');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        IE_GetPolicies.ResponseDto response = new IE_GetPolicies.ResponseDto();
        response = IE_GetPolicies.sendRequestGetPolicy('012344', '2020-01-01', 'MCCGNN88P14F839W', '', '', '', false, false,'targa');
        Test.stopTest();
    }
    
    @isTest
    public static void testGetPolicies_OK(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'GetPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest',
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/it-esb-aoi-policies-v1-0-0_INT/v2/policies');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetPolicies_Mock());
        IE_GetPolicies.ResponseDto response = new IE_GetPolicies.ResponseDto();
        response = IE_GetPolicies.sendRequestGetPolicies('MCCGNN88P14F839W', '', 'DAOL', '2020-01-01', false, false, false,'targa' );
        Test.stopTest();
    }

    @isTest
    public static void testGetPolicy_OK(){
        IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'GetPolicy', HTTPMethod__c='GET', Type__c = 'webservice_rest',
                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/it-esb-aoi-policies-v1-0-0_INT/v2/policies/{policyId}');
        insert IE_conf;
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetPolicy_Mock());
        IE_GetPolicies.ResponseDto response = new IE_GetPolicies.ResponseDto();
        response = IE_GetPolicies.sendRequestGetPolicy('012344', '2020-01-01', 'MCCGNN88P14F839W', '', '', '', false, false,'targa');
        Test.stopTest();
    }

}