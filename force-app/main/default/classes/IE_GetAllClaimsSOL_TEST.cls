@isTest(seeAllData=false)
private class IE_GetAllClaimsSOL_TEST {
    
    
    //POSITIVE MOCK
    public class Test_MockIE_GetAllClaimsPositiveResponse implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"Claims":[{"channel":"SOL","claimNumber":"1.7504.99.011268","claimId":12777216,"claimNumberEfnol":"","fiscalYear":"99","isIncompleteClaim":false,"idCase":"","policy":{"policyAgencyCode":"7504","policyNumber":"1.7504.5.238344972","branchCode":"5","policyProgressive":"238344972"},"companyCode":"1","companyDescription":"AXA Assicurazioni","agencyCode":"7504","agencySubCode":"","producerCode":"","productCode":"AUTO15","productDescription":"Nuova Protezione AUTO","commercialTypeCode":"AUTO_PRODUCT","plateNumber":"DX936AA","claimCategory":{"code":1,"description":"Auto"},"claimType":{"code":"20","description":"DD_RCA CID DEBITORE"},"claimDamageType":{"code":1,"description":"AUTO"},"insuredAsset":"DX936AA","claimEventDate":"29/08/2018","claimTimeEvent":"","claimNotificationDate":"21/09/2018","claimClosingDate":"05/10/2018","claimEventPlace":{"placeAddress":"--","latitude":null,"longitude":null,"nation":"IT","province":"TA","city":"TARANTO","zipCode":"-- ","address":""},"claimState":{"code":3,"description":"Pagato Totalmente","isOpen":false,"currentStep":"Auto Debitore"},"claimBaseCoverage":{"code":"RCA","description":"RESPONSABILITACIVILE AUTO"},"claimEvent":{"code":"EV000424","description":"INCIDENTE STRADALE"},"claimEventCategories":{"code":"GE000051","description":"INCIDENTE STRADALE"},"policyHolder":{"policyHolderId":31400030,"status":{"code":4,"description":"Senza Seguito"},"name":"GIOVANNI","surname":"CIANCIARUSO","email":null,"phone":null},"links":[{"rel":"ClaimHistory","self":"claims/12777216?trackingProcess=true","method":{"Method":"GET"}}]}],"IncompleteReports":[]}');
            res.setStatusCode(200);
            return res;
        }  
    }
    
    
      static testMethod void IE_GetAllClaimsSOL_method1_Positive(){
        IE_Configuration__c IE_conf = new IE_Configuration__c( Name = 'SOL_GetAllClaims', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllClaims', Response_parser__c = 'IE_Parser_GetAllClaims',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-claims-vs/claims');
        insert IE_conf;
          
    
        User uteTec = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        String userId = uteTec.Id;
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllClaimsPositiveResponse());
        IE_GetAllClaimsSOL.ResponseDto response = new IE_GetAllClaimsSOL.ResponseDto();
        response = IE_GetAllClaimsSOL.sendRequest(acct.AAI_Codice_fiscale__c, '1234', '4',acct.id,false);
        IE_GetAllClaimsSOL.ResponseDto response2  = new IE_GetAllClaimsSOL.ResponseDto(false,'test');
        Test.stopTest();
    }
}