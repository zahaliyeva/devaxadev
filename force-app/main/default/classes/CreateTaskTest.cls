@isTest
private class CreateTaskTest {

	@isTest
	private static void createTask(){ 
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'BusinessHours_Default', Value__c = [Select id from businesshours where isDefault = true limit 1].Id));
        insert listCustomSetting;
		Account acct = new Account(Name = 'Test Account');
		insert acct;
		Contact con = new Contact(FirstName = 'Test',
								  LastName  = 'Contact',
								  AccountId = acct.Id);
		insert con;
		Case c = new Case(ContactId = con.Id,
						  AccountId = acct.Id,
                          Status    = 'Open',
                          RecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Case', 'Motor'),
                          Origin    = 'APP My Axa',
                          CreatedById = UserInfo.getUserId());
        insert c;
		Test.startTest();
		CreateTask.insertTask(new List<Case>{c});
        Test.stopTest();
	}
}