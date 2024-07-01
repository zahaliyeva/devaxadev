@isTest
private class CaseCommentsHandler_TEST 
{
	@testSetup static void setup()
	{
		//MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
		User u = new User(Username = UserInfo.getOrganizationId() + String.valueOf(System.now().millisecond()) + '@test' + String.valueof((Math.random() * 1000)) + '.com',
                             LastName = 'testuser',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test',
                             Email = 'test@test.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId =  AP_Constants.getProfileAdminId());     
        insert u;    

		Case c = new Case(Ownerid =u.id);
		insert c;

		String OrgWideEmail = [Select id from OrgWideEmailAddress limit 1].Id;

		System.runAs(new User(Id=UserInfo.getUserId()))
        {
			MPS_Code_Variables__c Mcv = new MPS_Code_Variables__c(Name='NotifyCaseCommentToAdvisor',Key__c=OrgWideEmail,Value__c='Inserimento_commento_interno');        
			insert Mcv;
		}
	}

	@isTest static void test_method_one() 
	{
		Case c = [Select id from Case limit 1];
		CaseComment comm = new CaseComment(ParentId=c.Id,CommentBody='test');
		insert comm;
		comm.CommentBody='test2';
		update comm;
	}
}