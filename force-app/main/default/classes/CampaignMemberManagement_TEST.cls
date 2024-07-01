/**
 * Created by Augens on 26/11/2018.
 */

@IsTest
private class CampaignMemberManagement_TEST {
    @IsTest
    static void CommunicationBounceEventsTest() {
        List<CampaignMember> CampaignList = new List<CampaignMember>();
        Account account = new Account(Name ='CampaignAccountTest',AAI_Agency_Reference_Code__c ='000828',NDG__c = '0008280000000424');
        insert account;
        Contact contact = new Contact(LastName = 'CampaignContactTest',AccountId = account.Id);
        insert contact;
        Campaign cmp1 = new campaign(Name ='TestCampaign1');
        insert cmp1;
        Campaign cmp2 = new campaign(Name ='TestCampaign2');
        insert cmp2;
        CampaignMember campaignMember1 = new CampaignMember(CampaignId = cmp1.Id,
                contactId = contact.Id,
                Sottostato__c='SMS non recapitabile');
        CampaignList.add(campaignMember1);
        CampaignMember campaignMember2 = new CampaignMember(CampaignId = cmp2.Id,
                contactId = contact.Id,
                Sottostato__c='Email non recapitabile');
        CampaignList.add(campaignMember2);
        insert CampaignList;
        CampaignMemberManagement.createCommunicationBounceEvents(CampaignList);
    }
}