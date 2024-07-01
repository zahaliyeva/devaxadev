/*------------------------------------------------------------------------
Author:        Tugal Serger
Company:       Deloitte
Class:         deleteCampaignMembersBatch_TEST
Description:   Test class of deleteCampaignMembersBatch class
            
History

12/04/2018     Tugal Serger - Created
----------------------------------------------------------------------------*/

@istest
public class deleteCampaignMembersBatch_TEST{

    @testSetup	//preparing test database
    static void setup() {
        
        List<CampaignMember> campaignmembers = new List<CampaignMember>();
        List<Account> accounts = new List<Account>();
        
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        RecordType accRT = [SELECT Id,IsPersonType FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'B2C_Client' ];
        
        //insert 100 person accounts
        for(integer i=0;i<100;i++) {
            accounts.add(new Account(FirstName = 'TestAccount ' + i,
                                     LastName = 'AccountTest ' + i,
                                     PersonEmail = 'account_' + i + '_md3@mail.test',
                                     Phone = '0333333333',
                                     PersonMobilePhone = '3333333333',
                                     Nodes__c = '5014',
                                     AAI_Agency_Reference_Code__c = '005014',
                                     RecordTypeID = accRT.id));
        }
        insert accounts;
        
        //insert a Lead
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName = 'test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            MobilePhone = '3333333333'
        );
        insert ld;
        
        List<CampaignMembStatus__c> cms = new List<CampaignMembStatus__c>{
            new CampaignMembStatus__c(
                Name = 'Interested',
                Status_Name__c = 'Interessato',
                SortOrder__c = 3,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'
            ),
            new CampaignMembStatus__c(
                Name = 'In preparation',
                Status_Name__c = 'In preparazione',
                SortOrder__c = 4,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'
            ),
            new CampaignMembStatus__c(
                Name = 'Call again',
                Status_Name__c = 'Da ricontattare',
                SortOrder__c = 5,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'
            ),
            new CampaignMembStatus__c(
                Name = 'Not interested',
                Status_Name__c = 'Non interessato',
                SortOrder__c = 6,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'
            )
        };
        insert cms;
        
        //insert a campaign
        Campaign camp = new Campaign(name='TestCampaign',
                                     isActive = true,
                                     status = 'On-going',
                                     RecordTypeID = cpRT.Id,
                                     StartDate = Date.today(),
                                     EndDate = Date.today() + 3
                                    );
        insert camp;
        
        //insert 100 campaignmembers
        for (Account acc : [SELECT Id, PersonContactId FROM Account]) {
            campaignMembers.add(new CampaignMember(LeadId = ld.Id, 
                                                   ContactId = acc.PersonContactId,
                                                   CampaignId = camp.Id,
                                                   Owner__c = userinfo.getUserId(),
                                                   Status = 'In preparazione'
                                                  ));
        }
        insert campaignmembers;
        
    }
    
    
    static testmethod void test() {
        Campaign myCampaign = [SELECT Id FROM Campaign WHERE name='TestCampaign' LIMIT 1];
        string myCampID = myCampaign.Id;
        Test.startTest();
        deleteCampaignMembersBatch dCMB = new deleteCampaignMembersBatch(myCampID);
        Id batchId = Database.executeBatch(dCMB);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [select count() from campaignmember where Status = 'In preparazione']);
    }
    
}