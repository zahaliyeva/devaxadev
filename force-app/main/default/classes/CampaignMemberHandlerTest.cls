@isTest
public class CampaignMemberHandlerTest{
    static testmethod void TestCampaignMemberHandler(){
        
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id campaign_agency = UtilityClass.getRTid(rtypes, 'Campaign', 'Agency_campaign');        
        
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        
         // Creation Campaign
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
            ),
            new CampaignMembStatus__c(
                Name = 'Not interested',
                Status_Name__c = 'Non interessato',
                SortOrder__c = 6,
                IsDefault__c = true         
            )
        };
        insert cms;

        Campaign cmp1 = new Campaign(Name = 'Test Campaign 1',
                                     Startdate = system.today()-1,
                                     enddate = system.today(),
                                     Type = 'TCM',
                                     Status = 'On-going');
        insert cmp1;
        
        
        //Creation Campaign Member
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345',
            MobilePhone = '3333333333');
            
         insert ld;      
        
       System.runAs(new User(Id=UserInfo.getUserId()))
       {
                Account acc = new Account(FirstName = 'AccountTest99',
                                          LastName = 'AccountTest00',
                                          PersonEmail = 'account@mail.test',
                                          Phone = '0333333333',
                                          PersonMobilePhone = '3333333333',
                                          Agency_Code__c = '006345',
                                          Nodes__c = '006345',
                                          RecordTypeID = account_B2C);
                insert acc;
        }
        
        account acc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE FirstName = 'AccountTest99' and LastName = 'AccountTest00' ];
       
        Contact ct = new Contact(LastName = 'ContactTest',
            Account = acc);
        insert ct;

        CampaignMember cm = new CampaignMember(
            LeadId = ld.Id, 
            ContactId = acc.PersonContactId,
            CampaignId = cmp1.Id,
            Status = 'Interessato',
            Note__c = 'CM1');
        insert cm;
        
        //Modify Campaign Member
        cm.Status = 'Contato Errato';
        update cm;
        delete cm;
        //undelete cm;
        
    }   
}