@isTest
private class WS_REST_Lead_eCommerceTest {
	public WS_REST_Lead_eCommerceTest() {		
	}

	static testmethod void doPutTestNoCS(){
        MappingASA__c setting = new MappingASA__c();
        setting.Name = '3';
        setting.ASA__c = 'Famiglia';
        setting.ASA_Description__c = '3 - Famiglia';
        setting.Codice_ASA__c = 1;
        insert setting;
        MappingSottoASA__c setting2 = new MappingSottoASA__c();
        setting2.Name = '3.1';
        setting2.Sotto_ASA__c = 'ABITAZIONE';
        setting2.Sotto_ASA_Description__c = '3.1 Abitazione';
        setting2.Codice_Sotto_ASA__c = 1;
        insert setting2;
        AAI_Code_Variables__c setting3 = new AAI_Code_Variables__c();
        setting3.Name = 'AXA_TECHNICAL_USER_ID';
        setting3.Value__c = '00525000000EgUgAAK';
        insert setting3;
		LeadAssignmentConfiguration__c lac1 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for Lead duplication', 
    											DaysLimit__c=7.0
    											);

    	LeadAssignmentConfiguration__c lac2 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for duplication M upload', 
    											DaysLimit__c=7.0
    											);

    	List<LeadAssignmentConfiguration__c> listLac = new List<LeadAssignmentConfiguration__c>();
    	listLac.add(lac1);
    	listLac.add(lac2);
    	insert listLac;

		System.RestRequest req = new System.RestRequest();
  		System.RestResponse res = new System.RestResponse();

  		req.requestURI = '/services/apexrest/WS_REST_Lead_eCommerce';  //Request URL
		req.httpMethod = 'PUT'; //HTTP Request Type
		String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "IT","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zstzaaa5555rwfrsfsfarrrr24f0wd14",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		Blob reqBlob = Blob.valueof(reqStr);
		req.requestBody = reqBlob;
		RestContext.request = req;
		RestContext.response= res;
		Test.startTest();
		 WS_REST_eCommerce_Wrapper.Response ret = WS_REST_Lead_eCommerce.updateObject();
		Test.stopTest();
 		System.debug('==> ret: ' + ret);
 		System.assertEquals('tt6zstzaaa5555rwfrsfsfarrrr24f0wd14', ret.UserId);
 		System.assertEquals('200', ret.StatusCode);
 		System.assertEquals('OK', ret.StatusMessage);
		System.debug(' ===> response: ' + ret);
		req.requestBody =Blob.valueof('{"FirstName":"MARIO","Lastname":"CARIANI","Phone":"3296634826","Email":"ida23@studiocariani.net","PostalCode":"44124","StateCodeFraud":false,"Notes":"","CountryCode":"IT","StateCode":"FE","City":"FERRARA","Street":"VIA BOVA","BirthDate":"1928-04-11","FiscalCode":"CRNMRA28D12A393H","VATNumber":"","Gender":"Male","AlreadyCustomer":false,"BirthCity":"ARGENTA","BirthStateCode":"IT","NDG":"0034000000111674","Portals":{"AXACompany":"AAI","LeadSource":"Web","LeadStepStatus":"Salva Preventivo","AgreementCode":"WEB","AgencyCode":"003400","SessionId":"26338e01-77e7-42a6-947d-41b613b49eee","LandingPage":"Semplicemente casa","isEcommerce":true,"ProductName":"Nuova Protezione Casa","ASA":"Famiglia","SubASA":"ABITAZIONE","OriginUrl":"assicurazioneonline.axa.it//assicurazione-online-casa/app/resume?urlIntegrator=2c119eaa-583c-47f4-be4f-91a106e27f61"},"Quotations":{"QuotationTimestamp":"2019-09-27T18:54:13.518+02","QuotationDate":"2019-09-27","QuickQuoteCode":"4890352","QuoteCode":"2036501817","ProposalCode":"4890352","GoodFactors":[{"Name":"Tipologia di abitazione","Value":"Tipo B (Villa a schiera / unifamiliare)"},{"Name":"Mq","Value":"150"},{"Name":"Uso dimora","Value":"Abituale"},{"Name":"Provincia ubicazione","Value":"FERRARA"},{"Name":"Comune Ubicazione","Value":"44124"},{"Name":"Assicurato proprietario/affittuario","Value":"Proprietario"},{"Name":"Data di nascita","Value":"1928/04/12"},{"Name":"Risiedi nella casa da assicurare?","Value":"SI"},{"Name":"Hai un cane o un gatto?","Value":"Nessuno"}],"Premium":"161.0","Warranties":[{"Name":"Incendio","Price":"41.26","Limits":"149518"},{"Name":"Danni elettrici","Price":"46.96"},{"Name":"RC Terzi","Price":"57.76","Limits":"1000000"},{"Name":"Assistenza H24","Price":"15.02"}],"Fractionation":"Annual","PriceQuotationDueDate":"2019-10-27","PriceProposalDueDate":"2019-10-27"},"Consensus":{"CommercialActivityConsensus":"Sì","MarketResearchConsensus":"Sì","PartnerActivityConsensus":"Sì","DigitalDocumentationConsensus":"Sì","LeadConsensus":false}}');
		RestContext.request = req;
		RestContext.response= res;
		WS_REST_eCommerce_Wrapper.Response ret2 = WS_REST_Lead_eCommerce.updateObject();
		System.assertEquals('200', ret2.StatusCode);
		System.assertEquals('OK', ret2.StatusMessage);
		req.requestBody =Blob.valueof('{"FirstName":"gianluca","Lastname":"manzo","Phone":"3463444533","Email":"gianlucamanzodiaz@gmail.com","PostalCode":"00139","StateCodeFraud":false,"Notes":"","CountryCode":"IT","StateCode":"RM","City":"ROMA","VATNumber":"","Portals":{"AXACompany":"AAI","LeadSource":"Web","LeadStepStatus":"Acquista","AgreementCode":"WEB","SessionId":"9f04db8d-5430-4749-bc61-f211dc983804","LandingPage":"Semplicemente casa","isEcommerce":true,"ProductName":"Nuova Protezione Casa","ASA":"Famiglia","SubASA":"ABITAZIONE","OriginUrl":"assicurazioneonline.axa.it//assicurazione-online-casa/app/resume?urlIntegrator=54d2fc80-8c0a-4644-8ad6-74b3ab0d6a50"},"Quotations":{"QuotationTimestamp":"2019-09-25T08:46:54.973+02","QuotationDate":"2019-09-25","QuickQuoteCode":"186875","QuoteCode":"340271094","GoodFactors":[{"Name":"Tipologia di abitazione","Value":"Tipo A (Appartamento)"},{"Name":"Mq","Value":"112"},{"Name":"Uso dimora","Value":"Abituale"},{"Name":"Provincia ubicazione","Value":"ROMA"},{"Name":"Comune Ubicazione","Value":"00139"},{"Name":"Assicurato proprietario/affittuario","Value":"Proprietario"},{"Name":"Data di nascita","Value":"1980/10/31"},{"Name":"Risiedi nella casa da assicurare?","Value":"SI"},{"Name":"Hai un cane o un gatto?","Value":"Nessuno"}],"Premium":"131.5","Warranties":[{"Name":"Incendio","Price":"12.16","Limits":"50000"},{"Name":"Danni elettrici","Price":"15.06"},{"Name":"Fuoriuscita di acqua","Price":"13.95"},{"Name":"Eventi atmosferici","Price":"15.32"},{"Name":"Atti vandalici","Price":"1.67"},{"Name":"Rottura Cristalli e Vetri","Price":"0.56"},{"Name":"RC Terzi","Price":"57.76","Limits":"1000000"},{"Name":"Assistenza H24","Price":"15.02"}],"Fractionation":"Annual","PriceQuotationDueDate":"2019-10-25"},"Consensus":{"CommercialActivityConsensus":"","MarketResearchConsensus":"","PartnerActivityConsensus":"","DigitalDocumentationConsensus":"","LeadConsensus":false}}');
		RestContext.request = req;
		RestContext.response= res;
		WS_REST_eCommerce_Wrapper.Response ret3 = WS_REST_Lead_eCommerce.updateObject();
		System.assertEquals('200', ret3.StatusCode);
		System.assertEquals('OK', ret3.StatusMessage);
	}
	static testmethod void doPutTestCS(){
		MappingASA__c setting = new MappingASA__c();
        setting.Name = '3';
        setting.ASA__c = 'Famiglia';
        setting.ASA_Description__c = '3 - Famiglia';
        setting.Codice_ASA__c = 1;
        insert setting;
        MappingSottoASA__c setting2 = new MappingSottoASA__c();
        setting2.Name = '3.1';
        setting2.Sotto_ASA__c = 'ABITAZIONE';
        setting2.Sotto_ASA_Description__c = '3.1 Abitazione';
        setting2.Codice_Sotto_ASA__c = 1;
        insert setting2;
        AAI_Code_Variables__c setting3 = new AAI_Code_Variables__c();
        setting3.Name = 'AXA_TECHNICAL_USER_ID';
        setting3.Value__c = '00525000000EgUgAAK';
        insert setting3;
		LeadAssignmentConfiguration__c lac1 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for Lead duplication', 
    											DaysLimit__c=7.0
    											);

    	LeadAssignmentConfiguration__c lac2 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for duplication M upload', 
    											DaysLimit__c=7.0
    											);

    	List<LeadAssignmentConfiguration__c> listLac = new List<LeadAssignmentConfiguration__c>();
    	listLac.add(lac1);
    	listLac.add(lac2);
		insert listLac;
		
		insert new QueueAssignmentLogicParameters__c(Dettaglio__c='Visualizza quotazione',
													LandingPage__c='ConFido',
													Name='ConFido1',
													ClienteAction__c='AG di appartenenza',
													NotClienteAction__c='Coda default',
													MCEmailClickAction__c='AG Noovle, riassegna',
													CodaDefault__c='Coda_Lead_Visualizza_Quotazione_EC');
		insert new QueueAssignmentLogicParameters__c(Dettaglio__c='Salva preventivo',
													LandingPage__c='ConFido',
													Name='ConFido6',
													ClienteAction__c='AG di appartenenza',
													NotClienteAction__c='AG assegnata');
		System.RestRequest req = new System.RestRequest();
  		System.RestResponse res = new System.RestResponse();

  		req.requestURI = '/services/apexrest/WS_REST_Lead_eCommerce';  //Request URL
		req.httpMethod = 'PUT'; //HTTP Request Type
		RestContext.response= res;		
		req.requestBody = Blob.valueof('{"FirstName":"Chiara","Lastname":"Frigerio","Phone":"3497400507","Email":"chiara.frigerio92@gmail.com","PostalCode":"20900","StateCodeFraud":false,"Notes":"","CountryCode":"IT","StateCode":"MB","City":"MONZA","VATNumber":"","Portals":{"AXACompany":"AAI","LeadSource":"Web","LeadStepStatus":"Visualizza quotazione","SessionId":"109e525b-5a17-4535-bfb8-b1533d62ea0a","LandingPage":"ConFido","isEcommerce":true,"ProductName":"Nuova Protezione Casa","ASA":"Famiglia","SubASA":"ABITAZIONE"},"Quotations":{"QuotationTimestamp":"2019-09-25T11:20:43.409+02","QuotationDate":"2019-09-25","GoodFactors":[{"Name":"Specie","Value":"Cane"},{"Name":"A quale razza appartiene?","Value":"Altro"},{"Name":"Cane classificato ad alta aggressività (come da Ordinanza del 2009)","Value":"No"},{"Name":"Nome","Value":"Argo"},{"Name":"Quanti anni ha?","Value":"Compreso tra 6 Mesi e 10 Anni"}],"Warranties":[{"Name":"Rc cani e gatti","Limits":"1000000"},{"Name":"Tutela legale","Limits":"5000"},{"Name":"RC per i fatti della vostra vita privata","Limits":"1000000"}],"Fractionation":"Annual","PriceQuotationDueDate":"2019-10-25"},"Consensus":{"CommercialActivityConsensus":"","MarketResearchConsensus":"","PartnerActivityConsensus":"","DigitalDocumentationConsensus":"","LeadConsensus":false}}');
		RestContext.request = req;
		Test.startTest();
		WS_REST_eCommerce_Wrapper.Response ret = WS_REST_Lead_eCommerce.updateObject();
		req.requestBody = Blob.valueof('{"FirstName":"Simone","Lastname":"Piunno","Phone":"3351234567","Email":"simonep@gmail.com","PostalCode":"50126","StateCodeFraud":false,"Notes":"","CountryCode":"IT","StateCode":"FI","City":"FIRENZE","Street":"VIA GUIDO GUERRA 18","BirthDate":"1972-04-24","FiscalCode":"PNNSMN72D24D548F","VATNumber":"","Gender":"Male","AlreadyCustomer":false,"BirthCity":"Ferrara","BirthStateCode":"IT","NDG":"0041140000007035","Portals":{"AXACompany":"AAI","LeadSource":"Web","LeadStepStatus":"Salva Preventivo","AgencyCode":"004114","SessionId":"c8e94e09-10bd-4276-b126-962c675d2257","LandingPage":"ConFido","isEcommerce":true,"ProductName":"Nuova Protezione Casa","ASA":"Famiglia","SubASA":"ABITAZIONE","OriginUrl":"assicurazioneonline.axa.it//assicurazione-online-cane-gatto/app/resume?urlIntegrator=eae43346-2ad0-45f9-839d-0408b7aaf526"},"Quotations":{"QuotationTimestamp":"2019-09-25T00:25:06.529+02","QuotationDate":"2019-09-25","QuickQuoteCode":"4862269","QuoteCode":"2642272064","ProposalCode":"4862269","GoodFactors":[{"Name":"Specie","Value":"Cane"},{"Name":"A quale razza appartiene?","Value":"Beagle"},{"Name":"Cane classificato ad alta aggressività (come da Ordinanza del 2009)","Value":"No"},{"Name":"Nome","Value":"Beppe"},{"Name":"Quanti anni ha?","Value":"Compreso tra 6 Mesi e 10 Anni"}],"Premium":"184.0","Warranties":[{"Name":"Rc cani e gatti","Price":"77.23","Limits":"1000000"},{"Name":"Tutela legale","Price":"24.25","Limits":"5000"},{"Name":"RC per i fatti della vostra vita privata","Price":"82.52","Limits":"1000000"}],"Fractionation":"Annual","PriceQuotationDueDate":"2019-10-25","PriceProposalDueDate":"2019-10-25"},"Consensus":{"CommercialActivityConsensus":"No","MarketResearchConsensus":"No","PartnerActivityConsensus":"No","DigitalDocumentationConsensus":"Sì","LeadConsensus":false}}');
		RestContext.request = req;
		WS_REST_eCommerce_Wrapper.Response ret2 = WS_REST_Lead_eCommerce.updateObject();
		Test.stopTest();
		System.debug('==> ret: ' + ret2);
		//System.assertEquals('tt6zstzaaa5555rwfrsfsfarrrr24f0wd14', ret2.UserId);
		System.assertEquals('200', ret2.StatusCode);
		System.assertEquals('OK', ret2.StatusMessage);
	   	System.debug(' ===> response: ' + ret2);	   	
		System.debug('==> ret: ' + ret);
		//System.assertEquals('tt6zstzaaa5555rwfrsfsfarrrr24f0wd14', ret.UserId);
		System.assertEquals('200', ret.StatusCode);
		System.assertEquals('OK', ret.StatusMessage);
	   	System.debug(' ===> response: ' + ret);
	}

	static testmethod void doPutError500Test(){

		LeadAssignmentConfiguration__c lac1 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for Lead duplication', 
    											DaysLimit__c=7.0
    											);

    	LeadAssignmentConfiguration__c lac2 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for duplication M upload', 
    											DaysLimit__c=7.0
    											);

    	List<LeadAssignmentConfiguration__c> listLac = new List<LeadAssignmentConfiguration__c>();
    	listLac.add(lac1);
    	listLac.add(lac2);
    	insert listLac;

		System.RestRequest req = new System.RestRequest();
  		System.RestResponse res = new System.RestResponse();

  		req.requestURI = '/services/apexrest/WS_REST_Lead_eCommerce';  //Request URL
		req.httpMethod = 'PUT'; //HTTP Request Type
		String reqStr = '{"FirstName": "TESTCK24","LastName": "ApexTest01","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zstzaaa5555rwfrsfsfarrrr24f0wd14",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		Blob reqBlob = Blob.valueof(reqStr);
		req.requestBody = reqBlob;

		RestContext.request = req;
		RestContext.response= res;
 		WS_REST_eCommerce_Wrapper.Response ret = WS_REST_Lead_eCommerce.updateObject(); 		

 		System.assertEquals('', ret.UserId);
 		System.assertEquals('500', ret.StatusCode);
 		System.assert(ret.StatusMessage.contains('Internal Server Error'));

 		System.debug(' ===> response: ' + ret);
	}

	static testmethod void doPutInsertErrorTest(){

		LeadAssignmentConfiguration__c lac1 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for Lead duplication', 
    											DaysLimit__c=7.0
    											);

    	LeadAssignmentConfiguration__c lac2 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for duplication M upload', 
    											DaysLimit__c=7.0
    											);

    	List<LeadAssignmentConfiguration__c> listLac = new List<LeadAssignmentConfiguration__c>();
    	listLac.add(lac1);
    	listLac.add(lac2);
    	insert listLac;

		System.RestRequest req = new System.RestRequest();
  		System.RestResponse res = new System.RestResponse();

  		req.requestURI = '/services/apexrest/WS_REST_Lead_eCommerce';  //Request URL
		req.httpMethod = 'PUT'; //HTTP Request Type
		String reqStr = '{"FirstName": "ApexTest01","LastName": "XXXXX","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zstzaaa5555rwfrsfsfarrrr24f0wd14",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		Blob reqBlob = Blob.valueof(reqStr);
		req.requestBody = reqBlob;

		RestContext.request = req;
		RestContext.response= res;
 		WS_REST_eCommerce_Wrapper.Response ret = WS_REST_Lead_eCommerce.updateObject(); 		

 		System.assertEquals('', ret.UserId);
 		System.assertEquals('500', ret.StatusCode);
 		System.assert(ret.StatusMessage.contains('Internal Server Error'));

 		System.debug(' ===> response: ' + ret);
	}

	static testmethod void doPutBadRequestDeserializeTest(){

		System.RestRequest req = new System.RestRequest();
  		System.RestResponse res = new System.RestResponse();

  		req.requestURI = '/services/apexrest/WS_REST_Lead_eCommerce';  //Request URL
		req.httpMethod = 'PUT'; //HTTP Request Type
		String reqStr = 'true';
		Blob reqBlob = Blob.valueof(reqStr);
		req.requestBody = reqBlob;

		RestContext.request = req;
		RestContext.response= res;
 		WS_REST_eCommerce_Wrapper.Response ret = WS_REST_Lead_eCommerce.updateObject(); 		

 		System.assertEquals('', ret.UserId);
 		System.assertEquals('400', ret.StatusCode);
 		System.assert(ret.StatusMessage.contains('Bad Request'));

 		System.debug(' ===> response: ' + ret);
	}

	static testmethod void doPutBadRequestMandatoryTest(){

		System.RestRequest req = new System.RestRequest();
  		System.RestResponse res = new System.RestResponse();

  		req.requestURI = '/services/apexrest/WS_REST_Lead_eCommerce';  //Request URL
		req.httpMethod = 'PUT'; //HTTP Request Type
		String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Maleeee","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zstzaaa5555rwfrsfsfarrrr24f0wd14",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		Blob reqBlob = Blob.valueof(reqStr);
		req.requestBody = reqBlob;

		RestContext.request = req;
		RestContext.response= res;
 		WS_REST_eCommerce_Wrapper.Response ret = WS_REST_Lead_eCommerce.updateObject();		

 		System.assertEquals('', ret.UserId);
 		System.assertEquals('400', ret.StatusCode);
 		System.assert(ret.StatusMessage.contains('Bad Request'));

 		System.debug(' ===> response: ' + ret);
	}
}