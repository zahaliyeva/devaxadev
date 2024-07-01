@isTest
public class LightningGetAllClaimsCTRL_TEST 
{
	static MPS_Code_Variables__c MCV;
	static IE_Configuration__c IE_conf;

	static
	{
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
		MCV = new MPS_Code_Variables__c(name='Caringangel_LinkToSOL',Value__c='https://precol.axa-italia.it/axa_denunce/Visualizzazione/DettaglioSinistro.aspx?prog_pratica=');
		insert MCV;

		IE_Configuration__c IE_conf = new IE_Configuration__c(Name = 'CaringAngel_GetAllClaims', HTTPMethod__c='GET', Type__c = 'webservice_rest', 
                                                              Request_compiler__c='IE_Request_GetAllClaims', Response_parser__c = 'IE_Parser_GetAllClaims',
                                                              Endpoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-claims-vs/claims');
        insert IE_conf;
	}

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

	static testmethod void GetClaims()
	{
		Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;

		test.StartTest();
		Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllClaimsPositiveResponse());
		IE_GetAllClaims.ResponseDto response = new IE_GetAllClaims.ResponseDto();
		response = LightningGetAllClaimsCTRL.getAllClaimsCTRL('MCCGNN88P14F839W','1.1807.5.062715027',false,acct.id, true);
		system.debug(response);
        
		test.StopTest();
	}	
    
    static testmethod void method2()
	{
		Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
		Case caseObj1 = new Case(AccountId = acct.Id,
                                Status    = 'Open',
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                Category__c = 'Sinistro Motor',
                                SubCategory__c = 'Informazioni Sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());
        insert caseObj1;
		test.StartTest();
        LightningGetAllClaimsCTRL ctrl = new LightningGetAllClaimsCTRL();
		ApexPages.currentPage().getParameters().put('id',caseObj1.Id);
        LightningGetAllClaimsCTRL ctrl2 = new LightningGetAllClaimsCTRL();
        LightningGetAllClaimsCTRL.createCaseMonitoraggio(caseObj1.Id, '', '', 'test', '', '','','','','', false);
        LightningGetAllClaimsCTRL.createCaseMonitoraggio('', caseObj1.Id, 'Phone', 'test', Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId(), 'Customer','111','222','333','', false);
        LightningGetAllClaimsCTRL.createCaseMonitoraggio('', '', 'Phone', 'test', Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId(), 'Customer','111','222','333','', false);
	    LightningGetAllClaimsCTRL.initComponent(caseObj1.Id,'');
	    LightningGetAllClaimsCTRL.getNewCase(new Map<String, String>{'LOB' => 'Sinistri Salute', 'Caller' => 'Dipendente', 'RecordType' => 'AXA_Caring_Salute'}, acct.id);
		test.StopTest();
	}
    
    static testmethod void method3()
	{
		Account acct = new Account(name = 'test',Partita_IVA__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId());
        insert acct;
        
		test.StartTest();
		Test.setMock(HttpCalloutMock.class, new Test_MockIE_GetAllClaimsPositiveResponse());
		IE_GetAllClaims.ResponseDto response = new IE_GetAllClaims.ResponseDto();
		response = LightningGetAllClaimsCTRL.getAllClaimsCTRL('','1.1807.5.062715027',false,acct.id, true);
		system.debug(response);
        
		test.StopTest();
	}
    
    static testmethod void method4()
	{
		Account acct = new Account(FirstName = 'Account', LastName = 'SFDC', AAI_Codice_fiscale__c = 'MCCGNN88P14F839W', Fiscal_ID__c = 'MCCGNN88P14F839W', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId());
        insert acct;
		Case caseObj1 = new Case(AccountId = acct.Id,
                                Status    = 'Open',
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                Category__c = 'Sinistro Motor',
                                SubCategory__c = 'Informazioni Sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());
        insert caseObj1;
        LightningGetAllClaimsCTRL.getClaimRelatedCases(null, caseObj1.Id);
	}

	@IsTest  // FOZDEN 27/06/2019: Axa Assistance Enhancement Fase II
	static void createCaseSenzaSinistroTest() {

		MPS_Code_Variables__c LOB = new MPS_Code_Variables__c(
				Name = 'prepopulatedLOBSenzaSinistro',
				Value__c = 'Sinistri');
		MPS_Code_Variables__c category = new MPS_Code_Variables__c(
				Name = 'prepopulatedCategorySenzaSinistro',
				Value__c = 'Informazioni su sinistro');

		insert new List<MPS_Code_Variables__c>{
				LOB, category
		};

		try {
			LightningGetAllClaimsCTRL.createCaseMonitoraggio('', '', 'Phone', 'test',
					Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId(),
					'Customer', '111', '222', '333', '', true);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false);
		}

	}
}