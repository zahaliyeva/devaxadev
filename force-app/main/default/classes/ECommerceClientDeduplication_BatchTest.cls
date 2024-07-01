@isTest
public class ECommerceClientDeduplication_BatchTest {
	@testSetup //preparing the test database
	static void setup(){

		Id IdAgency = [Select Id from Recordtype Where Name = 'Agency' and sObjecttype='Account'].Id;
		Id sysAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' ].Id; 
		Id aaiRole = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'].Id;

        User userAdmin = new User(Username = 'admindecisionalmotor@axa.test.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = sysAdminProfileId,
                            UserRoleId = aaiRole,
                            UserPermissionsKnowledgeUser=true);
        insert userAdmin;

        System.runAs(userAdmin){

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

			Apex_Schedulation_Manager__c apexSchedulationManager = new Apex_Schedulation_Manager__c(
																			Name = 'testDeduplicationBatch',
																			Autoschedule__c = true,
																			Frequency__c = 30,
																			Expression__c = '0 0 23 * * ?',
																			Expression_Bis__c = '0 0 23 * * ?',
																			Scope__c = 10);
			insert apexSchedulationManager;

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


		    List<Lead> llist = new List<Lead>();
	    	llist.add(ld);
	    	llist.add(ld1);
	    	llist.add(ld2);

	    	insert llist;

	    	QuotationManagement.setAgencyCode(llist);
		    
		    //Create Quotazione
		    Quotazione__c quot = new Quotazione__c(
		            Name = 'QuotTest',
	            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
					ID_Session__c = 'tt6zst',
		            Lead__c = ld.Id,
		            Price_Quotation_DueDate__c = System.today(),
		            Price_Proposal_DueDate__c = System.today(),
		            Price_policy_DueDate__c = System.today()
		            );

		    Quotazione__c quot1 = new Quotazione__c(
		            Name = 'QuotTest',
	            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
					ID_Session__c = 'tt6zst',
		            Lead__c = ld1.Id,
		            Price_Quotation_DueDate__c = System.today(),
		            Price_Proposal_DueDate__c = System.today(),
		            Price_policy_DueDate__c = System.today()
		            );

		    Quotazione__c quot2 = new Quotazione__c(
		            Name = 'QuotTest',
	            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
					ID_Session__c = 'tt6zst',
		            Lead__c = ld2.Id,
		            Price_Quotation_DueDate__c = System.today(),
		            Price_Proposal_DueDate__c = System.today(),
		            Price_policy_DueDate__c = System.today()
		            );

		    List<Quotazione__c> listQuot = new List<Quotazione__c>();
		    listQuot.add(quot);
		    listQuot.add(quot1);
		    listQuot.add(quot2);

		    insert listQuot;
		}
	}

	static testmethod void testScenario(){

		List<String> sessionIdList = new List<String>{'tt6zst', 'tt6zs5', 'tt6zs6'};

    	List<Lead> batchLead= [SELECT Id, Dettaglio__c, Agency_Code__c, Fiscal_ID__c, AAI_Partita_IVA__c, Company, FirstName, LastName FROM Lead WHERE ID_Session__c IN :sessionIdList]; 

		LeadECommerceClientDeduplication_Batch batch = new LeadECommerceClientDeduplication_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();

	}

	static testmethod void testScheduledJob(){

		List<String> sessionIdList = new List<String>{'tt6zst', 'tt6zs5', 'tt6zs6'};

    	List<Lead> batchLead= [SELECT Id, Dettaglio__c, Agency_Code__c, Fiscal_ID__c, AAI_Partita_IVA__c, Company, FirstName, LastName FROM Lead WHERE ID_Session__c IN :sessionIdList]; 

		Test.startTest();
		LeadECommerceClientDeduplication_Batch sh1 = new LeadECommerceClientDeduplication_Batch();
		String sch = '0 0 23 * * ?';
		System.schedule('Test Territory Check', sch, sh1); 
		Test.stopTest();

	}	
}