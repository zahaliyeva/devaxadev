/*------------------------------------------------------------------------
Author:        Andrea Capobianco
Company:       Deloitte
Class:         LeadDecisionalMotor_BatchTest
Description:   Test class for LeadDecisionalMotor_Batch class

History

18/07/2017     Created - Andrea Capobianco
----------------------------------------------------------------------------*/
@isTest
public class LeadDecisionalMotor_BatchTest {

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

        System.runAs(userAdmin)
        {
        	//CAPOBIANCO_A 26/09/2017 - BUGFIX - START
			Id aaiVenditeProfileId = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato' ].Id;

			Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
	        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');		
			id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact'); 


			Account agencyAccount = new Account(Name = 'Agency Test Account',
	                                            RecordTypeId = account_agency,
	                                            Agency_Code__c = '004610');
	        insert agencyAccount;

	        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
	                                            RecordtypeId = contact_agency,
	                                            AccountId = agencyAccount.Id);
	        insert agencyContact;		
	        
	        User usr1=new User(FirstName='Marzia',
	                            LastName = 'Rossi', 
	                            Alias = 'mro666', 
	                            Email = 'mrosskmans@deloitte.com', 
	                            Username = 'agencyUser4610@axa.com.masterdev', 
	                            CommunityNickname = 'MarziRo', 
	                            LanguageLocaleKey = 'en_US',
	                            TimeZoneSidKey='Europe/Rome',
	                            Agency_Code__c = '004610',
	                            Nodes__c = 'DIF_004610',
	                            Profileid = aaiVenditeProfileId,
	                            LocaleSidKey='en_US',
	                            EmailEncodingKey='ISO-8859-1',
	                            ContactId = agencyContact.Id
	                            );
	        insert usr1;        

	        User usrAgent = [Select Id from User where Username='agencyUser4610@axa.com.masterdev'];
	        Group targetQueue = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Agenzia_004610' limit 1];
	        system.debug ('******targetQueue '+targetQueue);
	        
	        GroupMember queueMember = new GroupMember(GroupId = targetQueue.Id,
	                                                    UserOrGroupId = usrAgent.Id 
	                								);

	        insert queueMember;
	        //CAPOBIANCO_A 26/09/2017 - BUGFIX - END

			List<LeadAssignmentConfiguration__c> leadAssignmentConfigurationList = new List<LeadAssignmentConfiguration__c>
			{
				new LeadAssignmentConfiguration__c(Name = 'LimitAssignmentNumberToday',
													  DaysLimit__c = 10.0),

				new LeadAssignmentConfiguration__c(Name = 'LimitAssignmentNumberWeek',
													  DaysLimit__c = 40.0),

				//negative in order to trigger the batch
				new LeadAssignmentConfiguration__c(Name = 'ToBeProcessedTimeLimitHours',
													  HoursLimit__c = -1.25),

				new LeadAssignmentConfiguration__c(Name = 'ToBeProcessedOutsourceTimeLimitHours',
														HoursLimit__c = -1.25),

				//negative in order to trigger the batch
				new LeadAssignmentConfiguration__c(Name = 'doesNotAnswerFirstTimeLimitHours',
													  HoursLimit__c = -1.58),

				//negative in order to trigger the batch
				new LeadAssignmentConfiguration__c(Name = 'doesNotAnswerSecondTimeLimitHours',
													  HoursLimit__c = -1.11),

				new LeadAssignmentConfiguration__c(Name = 'Last n days for Lead duplication',
													  DaysLimit__c = 7.0),

				new LeadAssignmentConfiguration__c(Name = 'Last n days for duplication M upload',
													  DaysLimit__c = 7.0),
				//CAPOBIANCO_A 15/01/2018 -- Sprint 57 -- START
				new LeadAssignmentConfiguration__c(Name = 'Preventivo su misura',
                                                    ASA__c = 4,
                                                    Sub_ASA__c = 2),
                new LeadAssignmentConfiguration__c(Name = 'Dettagli fonte Lead',
                                                  Lead_Dettaglio__c = '(\'Richiedi appuntamento\', \'Visualizza quotazione\', \'Acquista\', \'Salva quotazione\')')
				//CAPOBIANCO_A 15/01/2018 -- Sprint 57 -- END
			};

			insert leadAssignmentConfigurationList;

			Apex_Schedulation_Manager__c apexSchedulationManager = new Apex_Schedulation_Manager__c(
																			Name = 'testBatch',
																			Autoschedule__c = true,
																			Frequency__c = 30,
																			Scope__c = 10);
			insert apexSchedulationManager;

			List<Account> agenciesList = new List<Account>
			{
				new Account(Name = 'AGENZIA000828',
							Agency_Code__c = '000828',
							Active__c = true,
							Accordo_Digitale__c = true,
							RecordtypeId = IdAgency
							),

				new Account(Name = 'AGENZIA004610',
							Agency_Code__c = '004610',
							Active__c = true,
							Accordo_Digitale__c = true,
							RecordtypeId = IdAgency
							),

				new Account(Name = 'AGENZIA000127',
							Agency_Code__c = '000127',
							Active__c = true,
							Accordo_Digitale__c = true,
							RecordtypeId = IdAgency
							)
			};

			insert agenciesList;

            MappingASA__c mapASA = new MappingASA__c( Name = '4',
                                                      ASA__c = 'Attività',
                                                      ASA_Description__c = '4 - Attività',
                                                      Codice_ASA__c = 4);
            insert mapASA;

            MappingSottoASA__c mapSubASA = new MappingSottoASA__c(  Name = '4.2',
                                                                    Codice_Sotto_ASA__c = 2,
                                                                    Sotto_ASA__c = 'ARTIGIANATO',
                                                                    Sotto_ASA_Description__c = '4.2 Artigianato');
            insert mapSubASA;
		}
	}

	static testmethod void TestScenario1_ToBeProcessedCase1(){

		//CAPOBIANCO_A 05/01/2018 -- START
		//Id RecordtypeNoAuto = [Select id from Recordtype where Name='Non Auto' and sObjecttype='Lead'].Id;
		Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
		//CAPOBIANCO_A 05/01/2018 -- END

		Group targetQueue1 = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Agenzia_004610' limit 1];
		User sysAdminUser = [SELECT Id From User WHERE Username = 'admindecisionalmotor@axa.test.com' LIMIT 1];
		Id userOwnerId = sysAdminUser.Id;


		Lead leadToBeProcessed = new Lead(
											FirstName = 'Test',
											LastName = 'DecisionalMotor',
											Phone = '123123123',
											//CAPOBIANCO_A 05/01/2018 -- START
											//RecordtypeId = RecordtypeNoAuto,
											RecordtypeId = RecordtypeAAI,
											//CAPOBIANCO_A 05/01/2018 -- END
											LeadSource = 'Web',
											Status = 'To be processed',
											OwnerId = userOwnerId,
											Ultima_data_di_riassegnazione__c = system.now(),
											Agenzie_per_riassegnazione__c = '000828;004610;000127;',
											Azioni_intraprese_sul_Lead__c = '',
											Numero_assegnazioni_eseguite__c = 1,
											TECH_Send_Email_Notification__c = false,
											Agenzie_gia_assegnate__c = '000828;',
											Agency_Code__c = '000828',
											Dettaglio__c = 'Richiedi appuntamento',
											Landing_Page__c = 'Preventivo su misura', //CAPOBIANCO_A 15/01/2018 -- Sprint 57
											TECH_Email_Does_Not_Answer__c = false );

		insert leadToBeProcessed;

		LeadDecisionalMotor_Batch batch = new LeadDecisionalMotor_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();
		
		Lead leadToBeProcessedUpdated = [SELECT Id, Agency_Code__c, Agenzie_gia_assegnate__c,OwnerId,Numero_assegnazioni_eseguite__c  FROM Lead WHERE Id =: leadToBeProcessed.Id];

		System.assertEquals(leadToBeProcessedUpdated.OwnerId, targetQueue1.Id);
		System.assertEquals(leadToBeProcessedUpdated.Numero_assegnazioni_eseguite__c, 2);
		System.assertEquals(leadToBeProcessedUpdated.Agency_Code__c, '004610');
		System.assertEquals(leadToBeProcessedUpdated.Agenzie_gia_assegnate__c, '000828;004610;');

	}

	static testmethod void TestScenario2_ToBeProcessedCase2(){

		//CAPOBIANCO_A 05/01/2018 -- START
		//Id RecordtypeNoAuto = [Select id from Recordtype where Name='Non Auto' and sObjecttype='Lead'].Id;
		Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
		//CAPOBIANCO_A 05/01/2018 -- END

		Group targetQueue2 = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Agenzia_004610' limit 1];
		User sysAdminUser = [SELECT Id From User WHERE Username = 'admindecisionalmotor@axa.test.com' LIMIT 1];
		Account agenzia004610 = [SELECT Id FROM Account WHERE Name = 'AGENZIA004610' LIMIT 1];
		Id agenzia004610Id = agenzia004610.Id;
		Id userOwnerId = sysAdminUser.Id;

		Lead leadToBeProcessed = new Lead(
											FirstName = 'Test',
											LastName = 'DecisionalMotor',
											Phone = '123123123',
											//CAPOBIANCO_A 05/01/2018 -- START
											//RecordtypeId = RecordtypeNoAuto,
											RecordtypeId = RecordtypeAAI,
											//CAPOBIANCO_A 05/01/2018 -- END
											LeadSource = 'Web',
											Status = 'To be processed',
											OwnerId = userOwnerId,
											Ultima_data_di_riassegnazione__c = system.now(),
											Agenzie_per_riassegnazione__c = '000828;004610;000127;',
											Numero_assegnazioni_eseguite__c = 1,
											TECH_Send_Email_Notification__c = false,
											Agenzie_gia_assegnate__c = '000828;',
											Agency_Code__c = '000828',
											Dettaglio__c = 'Richiedi appuntamento',
											Landing_Page__c = 'Preventivo su misura', //CAPOBIANCO_A 15/01/2018 -- Sprint 57
											TECH_Email_Does_Not_Answer__c = false );

		insert leadToBeProcessed;

		//DISMISSED
		/*Assegnazioni__c assegnazioni0004610 = new Assegnazioni__c(
														Account__c= agenzia004610Id,
                                                        Numero_Assegnazioni__c=10.0);
        insert assegnazioni0004610;*/

		LeadDecisionalMotor_Batch batch = new LeadDecisionalMotor_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();
		
		Lead leadToBeProcessedUpdated = [SELECT Id, Agency_Code__c, Agenzie_gia_assegnate__c,OwnerId, Numero_assegnazioni_eseguite__c FROM Lead WHERE Id =: leadToBeProcessed.Id];

		System.assertEquals(leadToBeProcessedUpdated.OwnerId, targetQueue2.Id);
		System.assertEquals(leadToBeProcessedUpdated.Numero_assegnazioni_eseguite__c, 2);
		System.assertEquals(leadToBeProcessedUpdated.Agency_Code__c, '004610');
		System.assertEquals(leadToBeProcessedUpdated.Agenzie_gia_assegnate__c, '000828;004610;');

	}

	static testmethod void TestScenario3_ToBeProcessedCase3(){

		//CAPOBIANCO_A 05/01/2018 -- START
		//Id RecordtypeNoAuto = [Select id from Recordtype where Name='Non Auto' and sObjecttype='Lead'].Id;
		Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
		//CAPOBIANCO_A 05/01/2018 -- END

		Group targetQueue3 = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Lead_Da_Processare_Riassegnate' limit 1];
		User sysAdminUser = [SELECT Id From User WHERE Username = 'admindecisionalmotor@axa.test.com' LIMIT 1];
		Account agenzia004610 = [SELECT Id FROM Account WHERE Name = 'AGENZIA004610' LIMIT 1];
		Id agenzia004610Id = agenzia004610.Id;
		Id userOwnerId = sysAdminUser.Id;

		Lead leadToBeProcessed = new Lead(
											FirstName = 'Test',
											LastName = 'DecisionalMotor',
											Phone = '123123123',
											//CAPOBIANCO_A 05/01/2018 -- START
											//RecordtypeId = RecordtypeNoAuto,
											RecordtypeId = RecordtypeAAI,
											//CAPOBIANCO_A 05/01/2018 -- END
											LeadSource = 'Web',
											Status = 'To be processed',
											OwnerId = userOwnerId,
											Ultima_data_di_riassegnazione__c = system.now(),
											Agenzie_per_riassegnazione__c = '000828;',
											Numero_assegnazioni_eseguite__c = 1,
											TECH_Send_Email_Notification__c = false,
											Agenzie_gia_assegnate__c = '000828;',
											Agency_Code__c = '000828',
											Dettaglio__c = 'Richiedi appuntamento',
											Landing_Page__c = 'Preventivo su misura', //CAPOBIANCO_A 15/01/2018 -- Sprint 57											
											TECH_Email_Does_Not_Answer__c = false );

		insert leadToBeProcessed;

		//DISMISSED
		/*Assegnazioni__c assegnazioni0004610 = new Assegnazioni__c(
														Account__c= agenzia004610Id,
                                                        Numero_Assegnazioni__c=10.0);
        insert assegnazioni0004610;*/

		LeadDecisionalMotor_Batch batch = new LeadDecisionalMotor_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();
		
		Lead leadToBeProcessedUpdated = [SELECT Id, Agency_Code__c, Agenzie_gia_assegnate__c,OwnerId, Numero_assegnazioni_eseguite__c FROM Lead WHERE Id =: leadToBeProcessed.Id];

		System.assertEquals(leadToBeProcessedUpdated.OwnerId, targetQueue3.Id);
		System.assertEquals(leadToBeProcessedUpdated.Numero_assegnazioni_eseguite__c, 1);
		System.assertEquals(leadToBeProcessedUpdated.Agency_Code__c, null);
		System.assertEquals(leadToBeProcessedUpdated.Agenzie_gia_assegnate__c, '000828;');

	}

	static testmethod void TestScenario3_ToBeProcessedCase4(){		

		//CAPOBIANCO_A 05/01/2018 -- START
		//Id RecordtypeNoAuto = [Select id from Recordtype where Name='Non Auto' and sObjecttype='Lead'].Id;
		Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
		//CAPOBIANCO_A 05/01/2018 -- END

		Group targetQueue2 = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Agenzia_004610' limit 1];
		User sysAdminUser = [SELECT Id From User WHERE Username = 'admindecisionalmotor@axa.test.com' LIMIT 1];
		Account agenzia004610 = [SELECT Id FROM Account WHERE Name = 'AGENZIA004610' LIMIT 1];
		Id agenzia004610Id = agenzia004610.Id;
		Id userOwnerId = sysAdminUser.Id;

		Lead leadToBeProcessed = new Lead(
											FirstName = 'Test',
											LastName = 'DecisionalMotor',
											Phone = '123123123',
											//CAPOBIANCO_A 05/01/2018 -- START
											//RecordtypeId = RecordtypeNoAuto,
											RecordtypeId = RecordtypeAAI,
											//CAPOBIANCO_A 05/01/2018 -- END
											LeadSource = 'Web',
											Status = 'To be processed',
											OwnerId = userOwnerId,
											Ultima_data_di_riassegnazione__c = system.now(),
											Agenzie_per_riassegnazione__c = '000828;004610;000127;',
											Tipologie_per_riassegnazione__c = '000828000002;004610000234;000127001254;',
											Numero_assegnazioni_eseguite__c = 1,
											TECH_Send_Email_Notification__c = false,
											Agenzie_gia_assegnate__c = '000828;',
											Agency_Code__c = '000828',
											Codice_Sub_Agenzia__c = '000828000002',
											Dettaglio__c = 'Richiedi appuntamento',
											Landing_Page__c = 'Preventivo su misura', //CAPOBIANCO_A 15/01/2018 -- Sprint 57
											TECH_Email_Does_Not_Answer__c = false );

		insert leadToBeProcessed;

		//DISMISSED
		/*Assegnazioni__c assegnazioni0004610 = new Assegnazioni__c(
														Account__c= agenzia004610Id,
                                                        Numero_Assegnazioni__c=10.0);
        insert assegnazioni0004610;*/

		LeadDecisionalMotor_Batch batch = new LeadDecisionalMotor_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();
		
		Lead leadToBeProcessedUpdated = [SELECT Id, Agency_Code__c, Agenzie_gia_assegnate__c,Codice_Sub_Agenzia__c,OwnerId, Numero_assegnazioni_eseguite__c FROM Lead WHERE Id =: leadToBeProcessed.Id];

		System.assertEquals(leadToBeProcessedUpdated.OwnerId, targetQueue2.Id);
		System.assertEquals(leadToBeProcessedUpdated.Numero_assegnazioni_eseguite__c, 2);
		System.assertEquals(leadToBeProcessedUpdated.Agency_Code__c, '004610');
		System.assertEquals(leadToBeProcessedUpdated.Agenzie_gia_assegnate__c, '000828;004610;');
		System.assertEquals(leadToBeProcessedUpdated.Codice_Sub_Agenzia__c, '004610000234');

	}

	static testmethod void TestScenario3_ToBeProcessedCase5(){		

		//CAPOBIANCO_A 05/01/2018 -- START
		//Id RecordtypeNoAuto = [Select id from Recordtype where Name='Non Auto' and sObjecttype='Lead'].Id;
		Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
		//CAPOBIANCO_A 05/01/2018 -- END

		Group targetQueue2 = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Agenzia_000127' limit 1];
		User sysAdminUser = [SELECT Id From User WHERE Username = 'admindecisionalmotor@axa.test.com' LIMIT 1];
		Account agenzia000127 = [SELECT Id FROM Account WHERE Name = 'AGENZIA000127' LIMIT 1];
		Id agenzia004610Id = agenzia000127.Id;
		Id userOwnerId = sysAdminUser.Id;

		Lead leadToBeProcessed = new Lead(
											FirstName = 'Test',
											LastName = 'DecisionalMotor',
											Phone = '123123123',
											//CAPOBIANCO_A 05/01/2018 -- START
											//RecordtypeId = RecordtypeNoAuto,
											RecordtypeId = RecordtypeAAI,
											//CAPOBIANCO_A 05/01/2018 -- END
											LeadSource = 'Web',
											Status = 'To be processed',
											OwnerId = userOwnerId,
											Ultima_data_di_riassegnazione__c = system.now(),
											Agenzie_per_riassegnazione__c = '000828;004610;000127;',
											Tipologie_per_riassegnazione__c = '000828000002;004610000234;000127001254;',
											Agenzie_per_riassegnazione_riordinata__c = '000828;000127;004610;',
											Tipologie_per_riassegnazione_riordinata__c = '000828000002;000127001254;004610000234;',
											Numero_assegnazioni_eseguite__c = 1,
											TECH_Send_Email_Notification__c = false,
											Agenzie_gia_assegnate__c = '000828;',
											Agency_Code__c = '000828',
											Codice_Sub_Agenzia__c = '000828000002',
											Dettaglio__c = 'Richiedi appuntamento',
											Landing_Page__c = 'Preventivo su misura', //CAPOBIANCO_A 15/01/2018 -- Sprint 57
											TECH_Email_Does_Not_Answer__c = false );

		insert leadToBeProcessed;

		//DISMISSED
		/*Assegnazioni__c assegnazioni0004610 = new Assegnazioni__c(
														Account__c= agenzia004610Id,
                                                        Numero_Assegnazioni__c=10.0);
        insert assegnazioni0004610;*/

		LeadDecisionalMotor_Batch batch = new LeadDecisionalMotor_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();
		
		Lead leadToBeProcessedUpdated = [SELECT Id, Agency_Code__c, Agenzie_gia_assegnate__c,Codice_Sub_Agenzia__c,OwnerId, Numero_assegnazioni_eseguite__c FROM Lead WHERE Id =: leadToBeProcessed.Id];

		System.assertEquals(leadToBeProcessedUpdated.OwnerId, targetQueue2.Id);
		System.assertEquals(leadToBeProcessedUpdated.Numero_assegnazioni_eseguite__c, 2);
		System.assertEquals(leadToBeProcessedUpdated.Agency_Code__c, '000127');
		System.assertEquals(leadToBeProcessedUpdated.Agenzie_gia_assegnate__c, '000828;000127;');
		System.assertEquals(leadToBeProcessedUpdated.Codice_Sub_Agenzia__c, '000127001254');

	}

	static testmethod void TestScenario4_DoesNotAnswerCase1(){

		//CAPOBIANCO_A 05/01/2018 -- START
		//Id RecordtypeNoAuto = [Select id from Recordtype where Name='Non Auto' and sObjecttype='Lead'].Id;
		Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
		//CAPOBIANCO_A 05/01/2018 -- END

		Group targetQueue4 = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Lead_Non_Risponde_Riassegnate' limit 1];
		User sysAdminUser = [SELECT Id From User WHERE Username = 'admindecisionalmotor@axa.test.com' LIMIT 1];
		Id userOwnerId = sysAdminUser.Id;


		Lead leadToBeProcessed = new Lead(
											FirstName = 'Test',
											LastName = 'DecisionalMotor',
											Phone = '123123123',
											//CAPOBIANCO_A 05/01/2018 -- START
											//RecordtypeId = RecordtypeNoAuto,
											RecordtypeId = RecordtypeAAI,
											//CAPOBIANCO_A 05/01/2018 -- END
											LeadSource = 'Web',
											Status = 'Does not answer',
											OwnerId = userOwnerId,
											Agenzie_per_riassegnazione__c = '000828;',
											Ultima_data_di_riassegnazione__c = system.now(),
											Numero_assegnazioni_eseguite__c = 1,
											TECH_Send_Email_Notification__c = false,
											Agency_Code__c = '000828',
											Dettaglio__c = 'Richiedi appuntamento',
											Landing_Page__c = 'Preventivo su misura', //CAPOBIANCO_A 15/01/2018 -- Sprint 57											
											TECH_Email_Does_Not_Answer__c = false);

		insert leadToBeProcessed;

		LeadHistory changeStatus = new LeadHistory(
											Field = 'Status',
											LeadId = leadToBeProcessed.Id);

		insert changeStatus;

		LeadDecisionalMotor_Batch batch = new LeadDecisionalMotor_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();
		
		Lead leadToBeProcessedUpdated = [SELECT Id, Agency_Code__c, Agenzie_gia_assegnate__c,OwnerId,Numero_assegnazioni_eseguite__c,TECH_Email_Does_Not_Answer__c  FROM Lead WHERE Id =: leadToBeProcessed.Id];

		System.assertEquals(leadToBeProcessedUpdated.TECH_Email_Does_Not_Answer__c, true);

	}

	static testmethod void TestScenario4_DoesNotAnswerCase2(){

		//CAPOBIANCO_A 05/01/2018 -- START
		//Id RecordtypeNoAuto = [Select id from Recordtype where Name='Non Auto' and sObjecttype='Lead'].Id;
		Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
		//CAPOBIANCO_A 05/01/2018 -- END

		Group targetQueue4 = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Lead_Non_Risponde_Riassegnate' limit 1];
		User sysAdminUser = [SELECT Id From User WHERE Username = 'admindecisionalmotor@axa.test.com' LIMIT 1];
		Id userOwnerId = sysAdminUser.Id;


		Lead leadToBeProcessed = new Lead(
											FirstName = 'Test',
											LastName = 'DecisionalMotor',
											Phone = '123123123',
											//CAPOBIANCO_A 05/01/2018 -- START
											//RecordtypeId = RecordtypeNoAuto,
											RecordtypeId = RecordtypeAAI,
											//CAPOBIANCO_A 05/01/2018 -- END
											LeadSource = 'Web',
											Status = 'Does not answer',
											OwnerId = userOwnerId,
											Agenzie_per_riassegnazione__c = '000828;',
											Ultima_data_di_riassegnazione__c = system.now(),
											Numero_assegnazioni_eseguite__c = 1,
											TECH_Send_Email_Notification__c = false,
											Agency_Code__c = '000828',
											Dettaglio__c = 'Richiedi appuntamento',
											Landing_Page__c = 'Preventivo su misura', //CAPOBIANCO_A 15/01/2018 -- Sprint 57
											TECH_Email_Does_Not_Answer__c = true);

		insert leadToBeProcessed;

		LeadHistory changeStatus = new LeadHistory(
											Field = 'Status',
											LeadId = leadToBeProcessed.Id);

		insert changeStatus;

		LeadDecisionalMotor_Batch batch = new LeadDecisionalMotor_Batch();

		Test.startTest();
		Database.executeBatch(batch,1);
		Test.stopTest();
		
		Lead leadToBeProcessedUpdated = [SELECT Id, Agency_Code__c, Agenzie_gia_assegnate__c,OwnerId,Numero_assegnazioni_eseguite__c,TECH_Email_Does_Not_Answer__c  FROM Lead WHERE Id =: leadToBeProcessed.Id];

		System.assertEquals(leadToBeProcessedUpdated.OwnerId, targetQueue4.Id);
		System.assertEquals(leadToBeProcessedUpdated.Numero_assegnazioni_eseguite__c, 1);
		System.assertEquals(leadToBeProcessedUpdated.Agency_Code__c, '000828');

	}

}