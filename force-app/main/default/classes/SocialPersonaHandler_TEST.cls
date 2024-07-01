/*------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         SocialPersonaHandler_TEST
Description:   Apex class used to simulate all the events related to the DML 
			   operations related to Social Personas

History

21/07/2017     Created - Marco Moscatelli.
----------------------------------------------------------------------------*/
@isTest
private class SocialPersonaHandler_TEST 
{
	static Account TestAccount;
	static SocialPost TestPost;
	static SocialPost TestPost2;
	static SocialPersona TestPersona;
	static SocialPersona TestPersona2;
	static User AdminUser;
	static String ContactId;

	static
	{
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

		TestAccount = new Account(FirstName='AccName',LastName='AccSurname');

		insert TestAccount;

		ContactId = [Select Id from Contact where FirstName='AccName'].Id;

		TestPersona = new SocialPersona(ParentId=ContactId,Provider='Twitter',ProfileUrl='www.twitter.com/test',Name='AccName AccSurname');
		insert TestPersona;

		TestPersona2 = new SocialPersona(ParentId=ContactId,Provider='Facebook',ProfileUrl='www.Facebook.com/test',Name='AccName AccSurname');
		insert TestPersona2;
	}

	@isTest static void test_method_InsertPost() 
	{
		system.runAs(AdminUser)
		{
			Test.startTest();
			TestPost = new SocialPost(WhoId=ContactId,Name='TWEET FROM: AccName AccSurname',Posted = system.today(),Provider='Twitter',PersonaId=TestPersona.Id,PostUrl='https://twitter.com/Test/status/887677932331823104',Content='Test');
			insert TestPost;

			system.assertEquals(TestPost.PersonaId,TestPersona.Id);
			system.assertEquals(TestPost.WhoId,ContactId);
			TestPersona.ParentId = TestAccount.Id;
			TestPost2 = new SocialPost(Name='TWEET FROM: AccName AccSurname',Posted = system.today(),Provider='Facebook',PersonaId=TestPersona2.Id,PostUrl='https://Facebook.com/Test/status/887677932331823104',Content='Test');
			insert TestPost2;			
			update TestPersona;
			TestPersona2.ParentId = TestAccount.Id;
			update TestPersona2;

			Test.stopTest();
		}
	}	
}