/*------------------------------------------------------------------------
Author:        Cristina Pardo Fabriguez
Company:       Deloitte
Class:         OpportunityProgressBarCtrl
Description:   A test class created to validate the OpportunityProgressBar VisualForce page
               Tests executed:
               1 - 
History

 18/06/2015     Cristina Pardo   Original version of the test class
 23/06/2015     Dario Bovolenta    v1.1
----------------------------------------------------------------------------*/
@isTest
private class OpportunityProgressBarCtrlTest{
    static testMethod void CreateOpp() {
         AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        
        insert acv;
        
        Date today = date.today();

        
        List<CampaignMembStatus__c> cms = new List<CampaignMembStatus__c>{
            new CampaignMembStatus__c(
                Name = 'Interested',
                Status_Name__c = 'Interessato',
                SortOrder__c = 3,
                IsDefault__c = true         
            ),
            new CampaignMembStatus__c(
                Name = 'Excluded',
                Status_Name__c = 'Escluso',
                SortOrder__c = 4,
                IsDefault__c = true         
            ),
            new CampaignMembStatus__c(
                Name = 'Call again',
                Status_Name__c = 'Da ricontattare',
                SortOrder__c = 5,
                IsDefault__c = true         
            )/*,
            
            new CampaignMembStatus__c(
                Name = 'Not interested',
                Status_Name__c = 'Non interessato',
                SortOrder__c = 6,
                IsDefault__c = true         
            )*/
        };
        
        insert cms;
        
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        
        Campaign cp = new Campaign(
            Name = 'CampagnaTest',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = cpRT.Id
        );
        insert cp;
        
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName = 'Test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            MobilePhone = '3333333333'
        );
        insert ld;
        
        Account acc = new Account(
            FirstName = 'AccountTest',
            LastName = 'AccountTest',
            PersonEmail = 'account@mail.test',
            Phone = '0333333333',
            PersonMobilePhone = '3333333333',
            Nodes__c = 'Node001'
        );
        insert acc;
        
        Contact ct = new Contact(
            LastName = 'ContactTest',
            Account = acc
        );
        insert ct;

        CampaignMember cm = new CampaignMember(
            LeadId = ld.Id, 
            ContactId = ct.Id,
            CampaignId = cp.Id,
            Owner__c = userinfo.getUserId(),
            Status = 'Interessato',
            Note__c = 'NoteTest'
        );
        insert cm;
        
         
        Opportunity o = new Opportunity(Name='TEST_1', StageName='Open', CampaignId=cp.Id, Ownerid=userinfo.getUserId(), TECH_sourceid__c=cm.id, AccountId=acc.id, CloseDate =today);
        Opportunity o1 = new Opportunity(Name='TEST_2', StageName='Closed Won', CampaignId=cp.Id, Ownerid=userinfo.getUserId(), TECH_sourceid__c=cm.id, AccountId=acc.id, CloseDate =today);
        Opportunity o2 = new Opportunity(Name='TEST_3', StageName='Closed Lost', CampaignId=cp.Id, Ownerid=userinfo.getUserId(), TECH_sourceid__c=cm.id, AccountId=acc.id, CloseDate =today);
        list<Opportunity> oppList = new list<Opportunity>();
        oppList.add(o);
        oppList.add(o1);
        oppList.add(o2);
        insert oppList;        
        
        OpportunityProgressBarCtrl controller = new OpportunityProgressBarCtrl (new ApexPages.StandardController(o));
        OpportunityProgressBarCtrl controller1 = new OpportunityProgressBarCtrl (new ApexPages.StandardController(oppList.get(1)));
        OpportunityProgressBarCtrl controller2 = new OpportunityProgressBarCtrl (new ApexPages.StandardController(oppList.get(2)));

    }
}