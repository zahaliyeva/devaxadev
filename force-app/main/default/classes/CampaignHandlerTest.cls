@isTest
public class CampaignHandlerTest{
    static testmethod void TestCampaignHandler(){
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        
        // Create Campaign
        Campaign cmp1 = new Campaign(Name = 'Test Campaign 1',
                                     Startdate = system.today()-1,
                                     enddate = system.today(),
                                     Type = 'TCM',
                                     Status = 'On-going');
        insert cmp1;
        
        // Update Campaign
        cmp1.type = 'LTC';
        update cmp1;
        
        
        //Delete and Undelete Campaign
        delete cmp1;
        undelete cmp1;
    }   
}