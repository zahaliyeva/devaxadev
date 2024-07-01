/*--------------------------------------------------------------------------------------------------------------
Author:        Moscatelli Marco
Company:       Deloitte
Class:         AP17_STORMSavePhoneRecording_WS_TEST
Description:   Test class used to simulate the callout performed by the class AP17_STORMSavePhoneRecording_WS

History
15/02/2018    Moscatelli Marco: created
----------------------------------------------------------------------------------------------------------------*/
@isTest
private class AP17_STORMSavePhoneRecording_WS_TEST
{/* PURE IT COMMENTO CLASSE
	Static User UserAdmin;
	Static IE_Configuration__c IEC;
	Static List<AAI_Code_Variables__c> ACV = new List<AAI_Code_Variables__c>();
	Static Storico_Chiamate__c StorCall;

	static
	{
		UserAdmin = new User(Username = 'testclassAP17@test.com',
                             LastName = 'testuser',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test',
                             Email = 'test@test.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId()
							);
		insert UserAdmin;
		
		ACV = new List<AAI_Code_Variables__c>{
											new AAI_Code_Variables__c(Name='AccountEdit_IRSavingLink',
								        	Value__c='https://axaitalia--masterdev3.cs86.my.salesforce.com'),
								        	new AAI_Code_Variables__c(Name='STORMRecSaving_AuthKEY',
								        	Value__c='2221313')
								        	};
		insert ACV;

		StorCall = new Storico_Chiamate__c(Call_ID__c='123456',
											PhoneCallIDB__c = '123456',
										  CallDateTime__c='2018-02-14 10:21:02'
										  );
		insert StorCall;
	}
	
	static testmethod void test_one()
	{
		system.runAs(UserAdmin)
		{
			IEC = new IE_Configuration__c(Name = 'STORM Save Recording',
						      Type__c = 'WebService',
						      Direction__c = 'OUTBOUND',
						      EndPoint__c = 'https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc',
						      Insert_IR_WS__c = false,
						      log_records_flag__c = true
						     );
			insert IEC;

			AP17_STORMSavePhoneRecording_Mock_TEST mockServer = new AP17_STORMSavePhoneRecording_Mock_TEST();
        	mockServer.TestCase = 'test_one';
        	Boolean no_error =true;

        	Storico_Chiamate__c ST = [Select Id from Storico_Chiamate__c Where Call_ID__c='123456'];

			Test.setMock(HttpCalloutMock.class, mockServer);

			Test.startTest();
			no_error = AP17_STORMSavePhoneRecording_WS.SaveRecording(ST.Id,'true');
			//system.assertEquals(no_error,true);
		
			Test.stopTest();
		}
	}
	
	static testmethod void test_one_error() 
	{
		system.runAs(UserAdmin)
		{
			IEC = new IE_Configuration__c(Name = 'STORM Save Recording',
						      Type__c = 'WebService',
						      Direction__c = 'OUTBOUND',
						      EndPoint__c = 'https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc',
						      Insert_IR_WS__c = false,
						      log_records_flag__c = true
						     );
			insert IEC;

			AP17_STORMSavePhoneRecording_Mock_TEST mockServer = new AP17_STORMSavePhoneRecording_Mock_TEST();
        	mockServer.TestCase = 'test_two';
        	Boolean no_error =true;

        	Storico_Chiamate__c ST = [Select Id from Storico_Chiamate__c Where Call_ID__c='123456'];

			Test.setMock(HttpCalloutMock.class, mockServer);

			Test.startTest();
			no_error = AP17_STORMSavePhoneRecording_WS.SaveRecording(ST.Id,'true');
			system.assertEquals(no_error,false);
			Test.stopTest();
		}
	}

	static testmethod void test_catch() 
	{
		system.runAs(UserAdmin)
		{
			IEC = new IE_Configuration__c(Name = 'STORM Save Recording',
						      Type__c = 'WebService',
						      Direction__c = 'OUTBOUND',
						      EndPoint__c = 'https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc',
						      Insert_IR_WS__c = false,
						      log_records_flag__c = true
						     );
			insert IEC;

			AP17_STORMSavePhoneRecording_Mock_TEST mockServer = new AP17_STORMSavePhoneRecording_Mock_TEST();
        	mockServer.TestCase = 'test_two';
        	Boolean no_error =true;

        	Storico_Chiamate__c ST = [Select Id from Storico_Chiamate__c Where Call_ID__c='123456'];

			Test.setMock(HttpCalloutMock.class, mockServer);

			Test.startTest();
			Account a = new Account(Name='abc');
			insert a;
			no_error = AP17_STORMSavePhoneRecording_WS.SaveRecording(ST.Id,'true');
			system.assertEquals(no_error,false);
			Test.stopTest();
		}
	}

	static testmethod void test_two()
	{
		system.runAs(UserAdmin)
		{
			IEC = new IE_Configuration__c(Name = 'STORM Save Recording',
						      Type__c = 'WebService',
						      Direction__c = 'OUTBOUND',
						      EndPoint__c = 'https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc',
						      Insert_IR_WS__c = true,
						      log_records_flag__c = true
						     );
			insert IEC;

			AP17_STORMSavePhoneRecording_Mock_TEST mockServer = new AP17_STORMSavePhoneRecording_Mock_TEST();
        	mockServer.TestCase = 'test_one';
        	Boolean no_error =true;

        	Storico_Chiamate__c ST = [Select Id from Storico_Chiamate__c Where Call_ID__c='123456'];

			Test.setMock(HttpCalloutMock.class, mockServer);

			Test.startTest();
			no_error = AP17_STORMSavePhoneRecording_WS.SaveRecording(ST.Id,'true');
			//system.assertEquals(no_error,true); 
		
			Test.stopTest();
		}
	}	PURE IT COMMENT CLOSURE */				
}