@isTest
private class FindAssociateClientCTRL_TEST 
{
	static Map<String,Id> mapAccountRecordtype; 
	static Account acc;
	static Account acc2;
	static Account acc3;
	static InsurancePolicy__c pol;
	static InsurancePolicy__c pol2;	

	static
	{
		mapAccountRecordtype = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc );

		acc = new Account(FirstName='TestName',
						 LastName='TestSurname',
						 Fiscal_ID__c='Fiscal1',
						 PersonBirthDate=Date.valueOf('1986-01-01'),
						 RecordtypeId = mapAccountRecordtype.get(AP_Constants.rtAccIndividualClient));
		insert acc;

		acc2 = new Account(FirstName='TestName\'s 2',
						 LastName='TestSurname\'s 2',
						 Fiscal_ID__c='Fiscal2',
						 PersonBirthDate=Date.valueOf('1986-01-01'),
						 RecordtypeId = mapAccountRecordtype.get(AP_Constants.rtAccIndividualClient));
		insert acc2;

		acc3 = new Account(Name='Company',
							Partita_IVA__c='IVA1',
						 	RecordtypeId = mapAccountRecordtype.get(AP_Constants.rtAccCorporateClient));
		insert acc3;


		pol = new InsurancePolicy__c(Name='pol1',
								Targa_veicolo__c='targa',
								CUID__c=acc.Id);
		insert pol;

		pol2 = new InsurancePolicy__c(Name='pol2',
								CUID__c=acc.Id);
		insert pol2;		

	}

	static testmethod void test_searchCustomer_1() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName','TestSurname','','Fiscal1','','1986-01-01');
		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
		test.StopTest();
		system.debug(AccL);

	}

	static testmethod void test_searchCustomer_2() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName','','','','','');
		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
		test.StopTest();
		system.debug(AccL);

	}	

	static testmethod void test_searchCustomer_3() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName','','','','','1986-01-01');
		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
		test.StopTest();
		system.debug(AccL);

	}	

	static testmethod void test_searchCustomer_4() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('','','','Fiscal1','','');
		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
		test.StopTest();
		system.debug(AccL);
	}	

	static testmethod void test_searchCustomer_5() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc2.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName\'s 2','TestSurname\'s 2','','','','');
		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName\'s 2',AccL[0].FirstName);
		test.StopTest();
		system.debug(AccL);
	}

	static testmethod void test_searchCustomer_6() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc2.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('','TestSurname\'s 2','','','','');
		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName\'s 2',AccL[0].FirstName);
		test.StopTest();
		system.debug(AccL);
	}

	static testmethod void test_searchCustomer_7() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc3.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaGiuridicaListCTRL('Company','','IVA1');
		//system.assertEquals(1,AccL.size());
		//system.assertEquals('Company',AccL[0].Name);
		test.StopTest();
		system.debug(AccL);
	}

	static testmethod void test_searchCustomer_8() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc3.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaGiuridicaListCTRL('Company','','');
		system.assertEquals(1,AccL.size());
		system.assertEquals('Company',AccL[0].Name);
		test.StopTest();
		system.debug(AccL);
	}	

	static testmethod void test_searchCustomer_9() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = acc3.Id;
	    Test.setFixedSearchResults(fixedSearchResults);
		AccL = FindAssociateClientCTRL.findPersonaGiuridicaListCTRL('Company','pol2','IVA');
		//system.assertEquals(1,AccL.size());
		//system.assertEquals('Company',AccL[0].Name);
		test.StopTest();
		system.debug(AccL);
	}	

	static testmethod void test_searchPolicy_1() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = pol.Id;
	    Test.setFixedSearchResults(fixedSearchResults);		
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('','','pol1','','targa','');
		test.StopTest();

		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
	}

	static testmethod void test_searchPolicy_2() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = pol.Id;
	    Test.setFixedSearchResults(fixedSearchResults);		
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('','','','','targa','');
		test.StopTest();

		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
	}	

	static testmethod void test_searchPolicy_3() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = pol.Id;
	    Test.setFixedSearchResults(fixedSearchResults);		
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName','','','','targa','');
		test.StopTest();

		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
	}

	static testmethod void test_searchPolicy_4() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = pol.Id;
	    Test.setFixedSearchResults(fixedSearchResults);		
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName','TestSurname','','','targa','');
		test.StopTest();

		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
	}	

	static testmethod void test_searchPolicy_5() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = pol.Id;
	    Test.setFixedSearchResults(fixedSearchResults);		
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName','TestSurname','','Fiscal1','targa','');
		test.StopTest();

		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
	}

	static testmethod void test_searchPolicy_6() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = pol.Id;
	    Test.setFixedSearchResults(fixedSearchResults);		
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('TestName','TestSurname','','Fiscal1','targa','1986-01-01');
		test.StopTest();

		system.assertEquals(1,AccL.size());
		system.assertEquals('TestName',AccL[0].FirstName);
	}

	static testmethod void test_searchPolicy_7() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = pol2.Id;
	    Test.setFixedSearchResults(fixedSearchResults);		
		AccL = FindAssociateClientCTRL.findPersonaGiuridicaListCTRL('','pol2','');
		test.StopTest();

		//system.assertEquals(1,AccL.size());
		//system.assertEquals('Company',AccL[0].FirstName);
	}	

	static testmethod void test_searchDataNascita() 
	{
		List<Account> AccL = new List<Account>();
		test.StartTest();	
		Id [] fixedSearchResults= new Id[1];
	    fixedSearchResults[0] = null;
	    Test.setFixedSearchResults(fixedSearchResults);	
		AccL = FindAssociateClientCTRL.findPersonaFisicaListCTRL('','','','','','1986-01-01');
		test.StopTest();

		system.assertEquals(0,AccL.size());
	}										
}