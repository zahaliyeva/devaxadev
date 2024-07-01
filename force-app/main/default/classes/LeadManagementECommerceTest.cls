@isTest
private class LeadManagementECommerceTest {

	public LeadManagementECommerceTest() {		
	}	

	@testSetup 
	static void setup(){

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
        
		Id leadECommerceRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'eCommerce' AND SobjectType = 'Lead'].Id;
		
		AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    	insert acv;

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

		//Create Lead
	    Lead ld = new Lead(
	            LastName = 'LeadTest',
	            FirstName ='test',
	            Email = 'lead@mail.test',
	            Phone = '0333333333',
	            Agency_Code__c = '006345',
	            MobilePhone = '3333333333', 
	            Landing_page__c = 'Confido',
	            Postalcode = '20090',
	            RecordTypeId = leadECommerceRecordTypeId,
	            ASA__c = 'Famiglia',
	            Sotto_ASA__c = 'ABITAZIONE',
	            LeadSource = 'Web',
	            Dettaglio__c = 'Salva quotazione',
	            ID_Session__c = 'tt6zst'
	            );

	    Lead ld1 = new Lead(
	            LastName = 'LeadTest1',
	            FirstName ='test1',
	            Email = 'lead@mail.test',
	            Phone = '0333333333',
	            Agency_Code__c = '006345',
	            MobilePhone = '3333333333', 
	            Landing_page__c = 'Confido',
	            Postalcode = '20090',
	            RecordTypeId = leadECommerceRecordTypeId,
	            ASA__c = 'Famiglia',
	            Sotto_ASA__c = 'ABITAZIONE',
	            LeadSource = 'Web',
	            Dettaglio__c = 'Salva quotazione',
	            ID_Session__c = 'tt6zs5'
	            );

	    Lead ld2 = new Lead(
	            LastName = 'LeadTest2',
	            FirstName ='test2',
	            Email = 'lead@mail.test',
	            Phone = '0333333333',
	            Agency_Code__c = '006345',
	            MobilePhone = '3333333333', 
	            Landing_page__c = 'Confido',
	            Postalcode = '20090',
	            RecordTypeId = leadECommerceRecordTypeId,
	            ASA__c = 'Famiglia',
	            Sotto_ASA__c = 'ABITAZIONE',
	            LeadSource = 'Web',
	            Dettaglio__c = 'Salva quotazione',
	            ID_Session__c = 'tt6zs6',
	            Prodotto__c = 'ConFido'
	            );

		Lead ld3 = new Lead(
	            LastName = 'LeadTest276',
	            FirstName ='test276',
	            Email = 'lead@mail.test',
	            Phone = '0333333333',
	            Agency_Code__c = '006345',
	            MobilePhone = '3333333333', 
	            Landing_page__c = 'Confido',
	            Postalcode = '20090',
	            RecordTypeId = leadECommerceRecordTypeId,
	            ASA__c = 'Famiglia',
	            Sotto_ASA__c = 'ABITAZIONE',
	            LeadSource = 'Web',
	            Dettaglio__c = 'Salva quotazione',
	            ID_Session__c = 'tt6zs6555',
	            Prodotto__c = 'ConFido'
	            );


	    List<Lead> llist = new List<Lead>();
    	llist.add(ld);
    	llist.add(ld1);
    	llist.add(ld2);
		llist.add(ld3);

    	insert llist;
    
    	QuotationManagement.setAgencyCode(llist);
	    
	    //Create Quotazione
	    Quotazione__c quot = new Quotazione__c(
	            Name = 'QuotTest',
				Lead_Step_Status__c = 'Salva quotazione',
            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
				ID_Session__c = 'tt6zst',
	            Lead__c = ld.Id
	            );

		Quotazione__c quot1 = new Quotazione__c(
	            Name = 'QuotTest',
				Lead_Step_Status__c = 'Salva quotazione',
            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
				ID_Session__c = 'tt6zstwww',
	            Lead__c = ld.Id
	            );
		

		Quotazione__c quot2 = new Quotazione__c(
	            Name = 'QuotTest',
				Lead_Step_Status__c = 'Salva quotazione',
            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
				ID_Session__c = 'tt6zs6555',
	            Lead__c = ld3.Id
	            );

		List<Quotazione__c> qlist = new List<Quotazione__c>();
    	qlist.add(quot);
    	qlist.add(quot1);
    	qlist.add(quot2);

    	insert qlist;

	    Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id insurancePolicy_Motor = UtilityClass.getRTid(rtypes, 'InsurancePolicy__c', 'B2C_Motor');
        id insurancePolicy_No_Motor = UtilityClass.getRTid(rtypes, 'InsurancePolicy__c', 'B2C_No_Motor');

        // Create B2C Account
        Account b2cClient1 = new Account(FirstName = 'test2',
                                        LastName = 'LeadTest2',
                                        RecordTypeId = account_B2C,
                                        Nodes__c = '5014'
                                        );
                                      
        insert b2cClient1;
        
        // Create Polizza Records
        InsurancePolicy__c contract1 = new InsurancePolicy__c(Name = 'Contract 1',
                                               Status__c = 'Active',
                                               Line__c = 'Car',
                                               RecordTypeId = insurancePolicy_Motor,
                                               TECH_Company__c = 'AAI',
                                               CUID__c = b2cClient1.Id);
        //insert contract1;
        
        InsurancePolicy__c contract2 = new InsurancePolicy__c(Name = 'Contract 2',
                                               Status__c = 'Active',
                                               Line__c = 'Savings',
                                               RecordTypeId = insurancePolicy_No_Motor,
                                               TECH_Company__c = 'AAI',
                                               CUID__c = b2cClient1.Id);
        //insert contract2;
        List<InsurancePolicy__c> contractToInsert = new List<InsurancePolicy__c>();
        contractToInsert.add(contract1);
        contractToInsert.add(contract2);
        
        insert contractToInsert;

	}

	static testmethod void testDeduplicateLeadNoSession(){


		String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zstzaaa5555rwfrsfsfarrrr24f0wd14",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);
		List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
        requestList.add(request);

        Test.startTest();
        WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }

    static testmethod void testDeduplicateLeadWithSession(){

		String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zst",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);
		List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
        requestList.add(request);

        Test.startTest();
        WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }

    static testmethod void testDeduplicateWithLead(){

		String reqStr = '{"FirstName": "test2","LastName": "LeadTest2","Company": "","Phone": "0333333333","Email": "lead@mail.test","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zs6",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);
		List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
        requestList.add(request);

        Test.startTest();
        WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }

	
    static testmethod void testDeduplicateWithLead2(){

		String reqStr = '{"FirstName": "test276","LastName": "LeadTest276","Company": "","Phone": "0333333333","Email": "lead@mail.test","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Visualizza quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zs6555",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);
		List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
        requestList.add(request);

        Test.startTest();
        WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }

	static testmethod void testDeduplicateWithLeadAndUpdate(){

		//String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zstwww",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		String reqStr1 = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Visualizza quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zst",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		//WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);
		WS_REST_eCommerce_Wrapper request1 = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr1, WS_REST_eCommerce_Wrapper.class);
		//List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
        //requestList.add(request);
		List<WS_REST_eCommerce_Wrapper> requestList1 = new List<WS_REST_eCommerce_Wrapper>();
        requestList1.add(request1);

        Test.startTest();
        //WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList);
		WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList1);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }
	
	static testmethod void testDeduplicateWithLeadAndUpdateRichiediAppuntamento(){

		//String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zstwww",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		String reqStr1 = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Richiedi appuntamento",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zst",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		//WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);
		WS_REST_eCommerce_Wrapper request1 = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr1, WS_REST_eCommerce_Wrapper.class);
		//List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
        //requestList.add(request);
		List<WS_REST_eCommerce_Wrapper> requestList1 = new List<WS_REST_eCommerce_Wrapper>();
        requestList1.add(request1);

        Test.startTest();
        //WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList);
		WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList1);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }

    static testmethod void testDeduplicateWithLeadRichiediAppuntamento(){

		String reqStr = '{"FirstName": "test2","LastName": "LeadTest2","Company": "","Phone": "0333333333","Email": "lead@mail.test","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Richiedi appuntamento",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zs6",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);
		List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
        requestList.add(request);

        Test.startTest();
        WS_REST_eCommerce_Wrapper.DeduplicateObject result = LeadManagementECommerce.deduplicateLead(requestList);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }

    static testmethod void testCheckBadRequest(){

		String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zst",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';
		WS_REST_eCommerce_Wrapper request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(reqStr, WS_REST_eCommerce_Wrapper.class);

        Test.startTest();
        Boolean result = LeadManagementECommerce.checkBadRequest(request);
        Test.stopTest();
        System.debug(' ===> result: ' + result);
    }

    static testmethod void testCreateJsonResponseAndIntegrationRecord(){

    	String reqStr = '{"FirstName": "TESTCK24","LastName": "QUOZIONE24","Company": "","Phone": "+393272012010","Email": "mail@mail.com","PostalCode": "20090","StateCodeFraud": false,"Notes": "","CountryCode": "ITALY","StateCode": "MI","City": "Segrate","Street": "Via Delle regioni, 36","BirthDate": "1980-01-01","FiscalCode": "","VATNumber": "","Gender": "Male","AlreadyCustomer": false,"BirthCity": "Palermo","BirthStateCode": "PA","NDG": "null","Portals": {  "AXACompany": "AAI",  "LeadSource": "Web",  "LeadStepStatus": "Salva quotazione",  "AgreementCode": "sconto 20% RCA",  "AgencyCode": "000828",  "SubAgencyCode": "000002",  "SessionId": "tt6zst",  "LandingPage": "ConFido",  "isEcommerce": true,  "ProductName": "ConFido",  "ASA": "Famiglia",  "SubASA": "ABITAZIONE",  "OriginUrl": "http://www.google.it",  "Source": "Mondo fatato"},"Quotations": {  "QuotationTimestamp": "2018-10-30T00:00:00.000Z",  "QuotationDate": "2018-10-30",  "QuickQuoteCode": "53453432",  "QuoteCode": "53542334",  "ProposalCode": "32465236423456",  "PolicyCode": "34523452352",  "GoodFactors": [    {      "Name": "Cane",      "Value": "Pippo"    },    {      "Name": "Età",      "Value": "15"    },    {      "Name": "Razza",      "Value": "Pincher"    }  ],  "Premium": "3000.15",  "DiscountedPremium": "2850.21",  "Warranties": [    {      "Name": "Gennaro",      "Limits": "4000",      "Exemption": "2000",      "InsuredQuantity": "3000.18",      "Price": "258.15"    }  ],  "Fractionation": "Semestrale",  "PriceQuotationDueDate": "2020-10-22",  "PriceProposalDueDate": "2020-10-22",  "PricePolicyDueDate": "2020-10-22",  "PaymentResult": "OK"},"Consensus": {  "CommercialActivityConsensus": "Sì",  "MarketResearchConsensus": "Sì",  "PartnerActivityConsensus": "Sì",  "DigitalDocumentationConsensus": "Sì",  "LeadConsensus": true}}';

		WS_REST_eCommerce_Wrapper.Response response = new WS_REST_eCommerce_Wrapper.Response();
		response.UserId = '2345n234523n4523452';
		response.LeadId = '444QQQdde';
		response.StatusCode = '200';
		response.StatusMessage = 'OK';
		response.Timestamp = System.now();

        Test.startTest();
        String jsonReturn = LeadManagementECommerce.createJsonResponse(response.UserId, response.LeadId, response.StatusCode, response.StatusMessage, response.Timestamp);
        IE_Integration_Record__c ieReturn = LeadManagementECommerce.populateIEIntegrationRecordRequest(reqStr);
        Test.stopTest();
        System.debug(' ===> jsonReturn: ' + jsonReturn);
        System.debug(' ===> ieReturn: ' + ieReturn);
    }

    static testmethod void testOtherMethodLead(){   

    	List<Lead> processLead= [SELECT Id, Name, Dettaglio__c, Agency_Code__c, Fiscal_ID__c, AAI_Partita_IVA__c, Company, FirstName, LastName FROM Lead WHERE ID_Session__c = 'tt6zst'];
    	List<Lead> agencyLead= [SELECT Id, Name, Dettaglio__c, Agency_Code__c, Fiscal_ID__c, AAI_Partita_IVA__c, Company, FirstName, LastName FROM Lead WHERE ID_Session__c = 'tt6zs5'];
    	List<Lead> batchLead= [SELECT Id, Name, Dettaglio__c, Agency_Code__c, Fiscal_ID__c, AAI_Partita_IVA__c, Company, FirstName, LastName FROM Lead WHERE ID_Session__c = 'tt6zs6']; 	

        Test.startTest();
        LeadManagementECommerce.assignLeadtoProcessQueue(processLead,new List<String>());
        agencyLead.add(new Lead(
        	Fiscal_ID__c = 'TEST',
        	AAI_Partita_IVA__c = 'TEST',
        	Company = 'AAI',
        	Firstname = 'Test',
            LastName = 'Test'
        	));
        LeadManagementECommerce.assignLeadtoAgencyQueue(agencyLead,new List<Boolean>{true, true});
        agencyLead.get(0).Prodotto__c = 'Protezione Sorriso';
        
        List<LeadManagementECommerce.RequestWrap> QueueableContextVariables = new List<LeadManagementECommerce.RequestWrap>();
        QueueableContextVariables.add(new LeadManagementECommerce.RequestWrap(agencyLead.get(0)));
        LeadManagementEcommerce.queueableSendSms obj = new LeadManagementEcommerce.queueableSendSms(QueueableContextVariables);
        obj.prepareRequest(agencyLead.get(0), null, '3333333333');
	    LeadManagementEcommerce.sendSMSonECommerce(agencyLead);
        LeadManagementECommerce.matchLeadstoAccounts(batchLead);
		LeadManagementECommerce.richiediAppuntamento();
        Test.stopTest();
    }
}