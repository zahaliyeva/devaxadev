@istest
public class deleteCampaignMembersCTRL_TEST {
    
    @testSetup	//preparing test database
    static void setup() {
        
        List<Campaign> campaigns = new List<Campaign>();
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
        campaigns.add(new Campaign(name='TestCampaign1',
                                   isActive = true,
                                   status = 'On-going',
                                   RecordTypeID = cpRT.Id,
                                   StartDate = Date.today(),
                                   EndDate = Date.today() + 3,
                                   Blacklist_available__c = true,
                                   Blacklist_end_date__c = Date.today() - 1
                                  ));
        
        campaigns.add(new Campaign(name='TestCampaign2',
                                   isActive = true,
                                   status = 'On-going',
                                   RecordTypeID = cpRT.Id,
                                   StartDate = Date.today(),
                                   EndDate = Date.today() + 3,
                                   Blacklist_available__c = false,
                                   Blacklist_end_date__c = Date.today() - 1
                                  ));
        
        campaigns.add(new Campaign(name='TestCampaign3',
                                   isActive = true,
                                   status = 'On-going',
                                   RecordTypeID = cpRT.Id,
                                   StartDate = Date.today(),
                                   EndDate = Date.today() + 3,
                                   Blacklist_available__c = true,
                                   Blacklist_end_date__c = Date.today() + 1
                                  ));
        
        insert campaigns;
        
        
        //insert 100 campaignmembers for each campaign
        for (Campaign camp : campaigns) {
            for (Account acc : [SELECT Id, PersonContactId FROM Account]) {
                campaignMembers.add(new CampaignMember(LeadId = ld.Id, 
                                                       ContactId = acc.PersonContactId,
                                                       CampaignId = camp.Id,
                                                       Owner__c = userinfo.getUserId(),
                                                       Status = 'In preparazione'
                                                      ));
            }
        }
        insert campaignmembers;
        
    }
    
    static testmethod void TestConstructor() {

        Campaign myCampaign = [SELECT Id FROM Campaign WHERE name='TestCampaign1' LIMIT 1];
        string CmpId = myCampaign.Id;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(myCampaign);
        deleteCampaignMembersCTRL dCMC = new deleteCampaignMembersCTRL(sc);
        
        Test.stopTest();
        
    }
    
    static testmethod void TestCampaign1() {
        Campaign myCampaign = [SELECT Id FROM Campaign WHERE name='TestCampaign1' LIMIT 1];
        string CmpId = myCampaign.Id;
        
        Test.startTest();
             
        deleteCampaignMembersCTRL.startDeletion(CmpId);            
            
        Test.stopTest();
        
    }
    
    static testmethod void TestCampaign2() {
        Campaign myCampaign = [SELECT Id FROM Campaign WHERE name='TestCampaign2' LIMIT 1];
        string CmpId = myCampaign.Id;
        
        Test.startTest();
        
        deleteCampaignMembersCTRL.startDeletion(CmpId);
        
        Test.stopTest();
        
    }
    
    static testmethod void TestCampaign3() {
        Campaign myCampaign = [SELECT Id FROM Campaign WHERE name='TestCampaign3' LIMIT 1];
        string CmpId = myCampaign.Id;
        
        Test.startTest();
        
        deleteCampaignMembersCTRL.startDeletion(CmpId);
        
        Test.stopTest();
        
    }

    static testmethod void TestCampaign_Fake() {
        
        string CmpId = 'mfjd73ksjfu74ys';
        
        Test.startTest();
        
        deleteCampaignMembersCTRL.startDeletion(CmpId);
        
        Test.stopTest();
        
    }
}