/*------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         SocialPostHandler_TEST
Description:   Apex class used to simulate all the events related to the DML 
			   operations related to Social Posts

History

21/07/2017     Created - Marco Moscatelli.
----------------------------------------------------------------------------*/
@isTest
private class SocialPostHandler_TEST 
{
	static User AdminUser;
	static List<SocialPost> SPostList;
	static List<Case> CaseList;
	static List<SocialPersona> SPersList;
	static List<Account> AccountList;
	static String ContactId;

	static
	{
		//MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
		AdminUser =  new User(Username = UserInfo.getOrganizationId() + String.valueOf(System.now().millisecond()) + '@test' + String.valueof((Math.random() * 1000)) + '.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = AP_Constants.getProfileAdminId());

		insert AdminUser;

		AccountList = new List<Account>{
										new Account(FirstName='AccName',LastName='AccSurname'),
										new Account(FirstName='AccName2',LastName='AccSurname2'),
										new Account(FirstName='AccName3',LastName='AccSurname3')
										};

		insert AccountList;

		ContactId = [Select Id from Contact where FirstName='AccName'].Id;
	
		CaseList = new List<Case>{
									new Case(Category__c= 'Cat1',OwnerId=AdminUser.Id),
									new Case(Category__c= 'Cat2',OwnerId=AdminUser.Id)
								 };
		insert CaseList;


		SPersList = new List<SocialPersona>{
											new SocialPersona(ParentId=AccountList[0].Id,Provider='Facebook',ProfileUrl='www.Facebook.com/test',Name='AccName AccSurname'),
											new SocialPersona(ParentId=AccountList[1].Id,Provider='Twitter',ProfileUrl='www.Twitter.com/test',Name='AccName2 AccSurname2')
										   };
		insert SPersList;

		SPostList = new List<SocialPost>{
										new SocialPost(Name='POST FROM: AccName AccSurname',Posted = system.today(),Provider='Facebook',PersonaId=SPersList[0].Id,PostUrl='https://Facebook.com/Test/status/887677932331823104',Content='Test',ParentId=CaseList[0].Id,WhoId=ContactId),
										new SocialPost(Name='tweet FROM: AccName2 AccSurname2',Posted = system.today(),Provider='Twitter',PersonaId=SPersList[1].Id,PostUrl='https://Twitter.com/Test/status/887677932331823104',Content='Test',ParentId=CaseList[1].Id,WhoId=AccountList[1].Id)
										};
	}

	
	static testMethod void InsertPost() 
	{
		system.runAs(AdminUser)
		{
			Test.startTest();
			insert SPostList;
			//system.assertEquals(CaseList[0].AccountId,AccountList[0].Id);
			//system.assertEquals(CaseList[1].AccountId,AccountList[1].Id);
			Test.stopTest();
		}
	}
	
	static testMethod void UpdatePost() 
	{
		system.runAs(AdminUser)
		{
			Test.startTest();
			insert SPostList;
			SocialPost spo = new SocialPost(Id = SPostList[0].id);
			spo.WhoId=AccountList[2].Id;
			update spo;
			//system.assertEquals(spo.WhoId,AccountList[2].Id);
			Test.stopTest();			
		}
	}
	
}