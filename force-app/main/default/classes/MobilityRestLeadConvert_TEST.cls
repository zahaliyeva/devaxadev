@isTest
private with sharing class MobilityRestLeadConvert_TEST {

	@TestSetup
	static void setup(){

		//insert complete lead
		Lead leadToConvert = new Lead(
			Salutation = '',
			LastName = 'LeadTest',
			FirstName = 'test',
			Company = 'TestCompany',
			Email = 'lead@mail.test',
			Phone = '0333333333',
			MobilePhone = '3333333333',
			Fiscal_ID__c = '1234567890abcdef',
			AAI_Partita_IVA__c = '12345678901'
			);
		insert leadToConvert;
		AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
		insert acv;

		//insert B2C_Account
		Account TheClient = new Account();
		TheClient.NDG__c='0008280000001138';
		RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
		TheClient.RecordTypeId = PF_RT.Id;
		TheClient.Salutation ='';
		TheClient.LastName = 'Rossi';
		TheClient.FirstName = 'Maria';
		TheClient.CIF_Marital_Status__c = 'Convivente';
		TheClient.CIF_Marital_Status_code__c = '7';
		TheClient.Nodes__c = '000828;000828000033';
		TheClient.AAI_Agency_Reference_Code__c ='000828';
		TheClient.State__c ='ATTIVO';
		TheClient.CIF_Job__c ='Agricoltore';
		TheClient.AAI_Codice_fiscale__c = 'MSSGNN64P24L929I';
		TheClient.CIF_Phone__c ='012345678';
		TheClient.CIF_PersonMobilePhone_IntPrefix__c   ='+39';
		TheClient.CIF_PersonMobilePhone__c ='023456678';
		TheClient.Fax = '345677891';
		TheClient.CIF_Work_phone__c= '012344444';
		TheClient.CIF_PersonEmail__c = 'mariarossi@email.com';
		TheClient.CIF_Work_email__c = 'test@libero6.it';
		TheClient.AnnualRevenue =  1112132;
		Date myDate = Date.newInstance(2019, 2, 17);



		AAI_Code_Variables__c leadstatus= new AAI_Code_Variables__c();
		leadstatus.Name='LeadStatus';
		leadstatus.Value__c='Appointment';



		insert leadstatus;




        id contact_agency = UtilityClass.getRTid(UtilityClass.fetchAllRTypes(), 'Contact', 'Agency_Contact');
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
        RecordtypeId = contact_agency,
        AccountId = TheClient.Id);
        insert agencyContact;

		List<Account> lsAccount = new List<Account>();
		lsAccount.add(TheClient);
		List<Database.SaveResult> accSave = database.insert(lsAccount);
	}

	@isTest
	static void testLeadConvert(){
		Test.startTest();
		MobilityRestLeadConvert.RequestConvertLead request = new MobilityRestLeadConvert.RequestConvertLead();
		request.leadId = [SELECT id from Lead LIMIT 1].Id;
		request.accountId = [SELECT id from Account LIMIT 1].Id;
		Test.stopTest();
		MobilityRestLeadConvert.leadConvert(request);
	}
}