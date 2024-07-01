/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         CampaignMemberManagementTest
Description:   Test for the trigger of the available status off campaign members
               in a new campaign
History

 06/07/2015     Dario Bovolenta    
----------------------------------------------------------------------------*/


@isTest
private class CampaignMemberManagementTest{
    static testMethod void CreateCampaign() {
    AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        list<CampaignMemberStatus> CMStatus = new list<CampaignMemberStatus>();
        Campaign c = new Campaign(Name='TEST_TRIGGER_CAMPAIGN', Status='Planned', Type = 'Other');
        insert c;
        CMStatus = [SELECT Label FROM CampaignMemberStatus WHERE CampaignId =:c.Id];
       // System.debug('Different status after trigger: ' + CMStatus.Label);
        for(CampaignMemberStatus OStat : CMStatus){ 
            System.debug('Status after trigger: ' + OStat.Label);
        }
    }
}