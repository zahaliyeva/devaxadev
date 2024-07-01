@IsTest
public class MobilityCampaignMemberControllerTest {
	static testMethod void testCampaignMemberController() {
        
        Campaign campaign = new Campaign(Name = 'Campagna di Test', Contact_Value__c = '000127;001002');
        Insert campaign;
        
        List<Account> accounts = new List<Account> ();
        for (Integer count = 0; count < 5; count++) {
                accounts.add(new Account(FirstName = 'Paolo',LastName = 'Fermi'));
        }
        Insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer count = 0; count < 5; count++) {
                contacts.add(new Contact(LastName = 'Paoli'));
        }
        Insert contacts;
        
        List<CampaignMember> members = new List<CampaignMember> ();
        for (Integer count = 0; count < 5; count++) {
          	members.add(new CampaignMember(Status = 'Interessato', contactId = contacts[count].Id, CampaignId = campaign.Id));
        }  

        //carico la lista
        insert members;
        String memberId = String.valueOf(members[0].Id);
        
        List<String> Lista = new List<String>();
        Campaign camp = new Campaign();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'standt', Email='test@test.invalid', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com_mobility');

        insert user;
        Id campid = campaign.Id;
        Id userid = user.Id;
        String campaignId = String.valueOf(campid);
        for (Integer count = 0; count < 5; count++) {
            Lista.add(members[count].Id);
        }
        
        Datetime dt = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        Event eventData = new Event(DurationInMinutes = 60,ActivityDateTime = dt); 
        
        Test.startTest();
        MobilityCampaignMemberController.changeStatus(Lista,'Interessato');
        MobilityCampaignMemberController.getMembers(Lista);
        MobilityCampaignMemberController.getMember(memberId);
        MobilityCampaignMemberController.sendEmail(user, camp);
        MobilityCampaignMemberController.assignMembers(campid,Lista,userid,true);
        MobilityCampaignMemberController.getContactValue(campaignId);
        MobilityCampaignMemberController.sendEmailCampaign(user,campaignId);
        MobilityCampaignMemberController.proccessInformative(memberId,'Assicurato in vita','',true,dt);
        MobilityCampaignMemberController.proccessDataEnrichment(campaignId);
        MobilityCampaignMemberController.proccessInterested(memberId,true,true,eventData,false);
        MobilityCampaignMemberController.proccessRecontact(memberId,true,dt);
        MobilityCampaignMemberController.proccessNotInterested(memberId,'ciao');
        Test.stopTest();
    }   
}