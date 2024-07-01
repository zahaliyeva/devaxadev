@isTest
public class LightningGetAllPoliciesCTRL_TEST 
{

	static
	{
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
		IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
	                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
	                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs/policies');
        insert IE_conf;
        

		IE_Configuration__c IE_conf2 = new IE_Configuration__c(Name = 'Integrazione_Garanzie',  Type__c = 'Webservice',
	                                                           Endpoint__c = 'http://www.mocky.io/v2/5bbc69e13200005b0027ebe6');
        insert IE_conf2;	 
        IE_Configuration__c IE_conf3 = new IE_Configuration__c(Name = 'GetPolicies', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
	                                                              Request_compiler__c='IE_Request_GetAllPolicies', Response_parser__c = 'IE_Parser_GetAllPolicies',
	                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs/policies');
	    insert IE_conf3;   
    }

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

    public class Test_MockIE_GetPoliciesPositiveResponse implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('[{"number":"066427523","idPolicy":"1.001340000012.066427523","portfolio":"DAOL","commonData":{"type":"1","policyEffectDate":"2020-09-10T00:00:00+02:00","policyEndDate":"2021-09-10T00:00:00+02:00","statusCode":"NOT_IN_FORCE","mainPolicy":"false","productCode":"AP","productName":"Auto Protezione","productVersion":"E00001","mattoncinoVersion":"E00001","companyCode":"000001","nodeCode":"001340000012","branchCode":"5","personId":"SPDMSM73D15L219T"},"assets":[{"coverages":[{"baseCoverage":"RCA","specificCoverage":"RCA"},{"baseCoverage":"CVT","specificCoverage":"FUR"},{"baseCoverage":"CVT","specificCoverage":"INC"},{"baseCoverage":"CVT","specificCoverage":"COL"},{"baseCoverage":"CVT","specificCoverage":"ASP"},{"baseCoverage":"ALG","specificCoverage":"ASS"},{"baseCoverage":"ALG","specificCoverage":"INF"}],"idAsset":"1454403085","assetDescription":"BMW 320D CAT CABRIO MSPORT (EW454HM)","assetKey":"1454403085","licensePlate":"EW454HM"}]},{"number":"385001004001004","idPolicy":"1.008985.385001004001004","portfolio":"DAOL","commonData":{"type":"2","policyEffectDate":"2020-01-01T00:00:00+01:00","policyEndDate":"2021-01-01T00:00:00+01:00","statusCode":"NOT_IN_FORCE","mainPolicy":"false","productCode":"ME71","productName":"Malattia Dipendenti","productVersion":"V00001","mattoncinoVersion":"1.0","companyCode":"000001","nodeCode":"008985","branchCode":"M","personId":"12649330151"},"assets":[{"coverages":[{"baseCoverage":"EXO","specificCoverage":"DEN"},{"baseCoverage":"PRE","specificCoverage":"CKUP"},{"baseCoverage":"ASS","specificCoverage":"ASS"}],"insuredHouseHolder":"true","insuredFiscalCode":"SPDMSM73D15L219T","insuredBirthDate":"15/04/1973","insuredAssetDescription":"SPADON MASSIMO","insuredCountry":"IT","insuredGender":"Maschio","idAsset":"2859309061","assetDescription":"SPADON MASSIMO","assetKey":"1"}]},{"number":"385001008001004","idPolicy":"1.008985.385001008001004","portfolio":"DAOL","commonData":{"type":"2","policyEffectDate":"2020-01-01T00:00:00+01:00","policyEndDate":"2021-01-01T00:00:00+01:00","statusCode":"NOT_IN_FORCE","mainPolicy":"false","productCode":"ME71","productName":"Malattia Dipendenti","productVersion":"V00001","mattoncinoVersion":"1.0","companyCode":"000001","nodeCode":"008985","branchCode":"M","personId":"08810960966"},"assets":[{"coverages":[{"baseCoverage":"RI","specificCoverage":"RIC"},{"baseCoverage":"EXO","specificCoverage":"DIGE"},{"baseCoverage":"EXO","specificCoverage":"MED"},{"baseCoverage":"EXO","specificCoverage":"VA"},{"baseCoverage":"EXO","specificCoverage":"TICK"},{"baseCoverage":"EXO","specificCoverage":"PROAC"},{"baseCoverage":"EXO","specificCoverage":"ONCO"},{"baseCoverage":"EXO","specificCoverage":"TFO"},{"baseCoverage":"EXO","specificCoverage":"NORIC"},{"baseCoverage":"EXO","specificCoverage":"PATO"},{"baseCoverage":"ASS","specificCoverage":"ASS"}],"insuredHouseHolder":"true","insuredFiscalCode":"SPDMSM73D15L219T","insuredBirthDate":"15/04/1973","insuredAssetDescription":"SPADON MASSIMO","insuredCountry":"IT","insuredGender":"Maschio","idAsset":"2859309072","assetDescription":"SPADON MASSIMO","assetKey":"1"}]}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class Test_MockIE_GetPoliciesNegativeResponse implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('[{"number":"066427523"}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class Test_MockIE_GetAllGaranziePositiveResponse implements HttpCalloutMock 
    {
        
        public HTTPResponse respond(HTTPRequest req) 
        {  
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('[{"coverages":[{"name": "RESPONSABILITÀ CIVILE TERZI","id": "GASLG6","shortDescriptionLines": ["string"],"categoryName": "VIA AURELIA 77 17029 VARIGOTTI (SV)","categoryId":"118134595.000000000000000","riderName": "prova","effectiveDate":"2016-01-15", "clauses": [ "test" ] ,"expirationDate":"2016-01-15", "beneficiaries": [{"BeneficiaryName": "Rossi Marco"},{"BeneficiaryName": "Rossi Maria"}],"restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","applicationCase": "PROVA","description": "500.000 € MASSIMALE PER SINISTRO RCT"},{"type": "MAXLIMIT","value": 260000,"unitCode": "€", "description": "100.000 € MASSIMALE PER SINISTRO RCT"}]},{"name": "INVALIDITÀ PERMANENTE DA MALATTIA","id": "COIPM", "categoryName": "TURA ROBERTO"  ,"categoryId": "118134595.000000000000000","restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","description": "260,000 € SOMMA ASSICURATA"}]},{"name": "GARANZIA GENERICA (CRITERI PER PRODOTTO)","id": "000336","categoryName": "VIA AURELIA 77 17029 VARIGOTTI (SV)","categoryId": "118134595.000000000000000"}]}]');
            res.setStatusCode(200);
            return res;
        }
    } 	   	
	
	static testmethod void test_Policies() 
	{
		Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;

        Case c = new Case(Accountid=acct.id,RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId());
        insert c;
        test.StartTest();

		IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();
		Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllPoliciesPositiveResponse());
        response = LightningGetAllPoliciesCTRL.getAllPoliciesCTRL('MCCGNN88P14F839W',acct.id,c.id);
		test.StopTest();
		system.debug(response);
    }
    
    
	static testmethod void test_PoliciesWithStartDate() 
	{
		Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;

        Case c = new Case(Accountid=acct.id,RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId());
        insert c;
        test.StartTest();
        LightningGetAllPoliciesCTRL controller = new LightningGetAllPoliciesCTRL();
		IE_GetPolicies.ResponseDto response = new IE_GetPolicies.ResponseDto();
		Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetPoliciesPositiveResponse());
        response = LightningGetAllPoliciesCTRL.getPoliciesCTRL('MCCGNN88P14F839W', '2000-03-01','AA000AA');
		test.StopTest();
		system.debug(response);
    }
    
    
	static testmethod void test_PoliciesWithStartDateNegative() 
	{
		Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;

        Case c = new Case(Accountid=acct.id,RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId());
        insert c;
        test.StartTest();
        LightningGetAllPoliciesCTRL controller = new LightningGetAllPoliciesCTRL();
		IE_GetPolicies.ResponseDto response = new IE_GetPolicies.ResponseDto();
		Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetPoliciesNegativeResponse());
        response = LightningGetAllPoliciesCTRL.getPoliciesCTRL('MCCGNN88P14F839W', '2000-03-01','AA000AA');
		test.StopTest();
		system.debug(response);
	}
	
	static testmethod void test_Garanzie() 
	{
		Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
        Case c = new Case(Accountid=acct.id,RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId());
        insert c;

        test.StartTest();
		Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllGaranziePositiveResponse());
		LightningGetAllPoliciesCTRL.getAllGaranzieCTRL('MCCGNN88P14F839W','000001-008382-000005-066791457');
		test.StopTest();
	}

    static testmethod void test_Policies_2() 
    {
        Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;

        Case c = new Case(Accountid=acct.id,RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sinistri_AAI').getRecordTypeId());
        insert c;

        InsurancePolicy__c p = new InsurancePolicy__c(Cuid__c=Acct.id,Name='000012',CCDATE__c=system.today(),EXPIRY_DATE__c=system.today()+2,Product_Name__c='Prodotto',Tech_company__c='MPS',Status__c='ATTIVA');
        insert p;


        test.StartTest();

        IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();
        response = LightningGetAllPoliciesCTRL.getAllPoliciesCTRL('MCCGNN88P14F839W',acct.id,c.id);
        test.StopTest();
        system.debug(response);
    }   
	
}