@isTest
public class MobilityCampaignMarketingTest {
    @testSetup private static void createData(){
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1',
                                      Startdate = system.today()-1,
                                      enddate = system.today()+2,
                                      Type = 'Cross Selling',
                                      Status = 'On-going');
        insert camp1;
        Campaign camp2 = new Campaign(Name = 'Test Campaign 2',
                                      Startdate = system.today()-1,
                                      enddate = system.today()+2,
                                      Type = 'Conference',
                                      Status = 'On-going');
        insert camp2;
        
        
        Account acc1 = new Account( 
            FirstName = 'Sheldon',
            LastName = 'Last',
            Nodes__c = '001622,001622000124',
            PersonEmail = 'account@mail.test1',
            Ccod_Produttore__c='001622000124',
            RecordTypeID = account_B2C);
        
        insert acc1;
        
        Account acc2 = new Account( 
            FirstName = 'Leonard',
            LastName = 'Last',
            Nodes__c = '001622,001622000123',
            Ccod_Produttore__c='001622000123',
            RecordTypeID = account_B2C);
        
        insert acc2;
        List <contact> c=[select id, accountid from contact limit 2];
        
        CampaignMember campm1 = new campaignMember(  
            Status='Da assegnare',
            CampaignId=camp1.id,
            Stato_Adesione__c = 'ESCLUSO',
            ContactId=c[0].id,
            NeedAsyncBatchExecution__c=true);
        insert campm1;
    }
    
    @isTest static void test() {
        Test.startTest();
        CampaignMember campm1 = [SELECT id FROM CampaignMember LIMIT 1];
        Account acct1 = [SELECT Id FROM Account LIMIT 1];
        Campaign camp1 = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 1' LIMIT 1];
        Campaign camp2 = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign 2' LIMIT 1];
        List< Object> ids = new List< Object>();
        ids.add(camp1.id);
        List< Object> ids2 = new List< Object>();
        ids2.add(camp2.id);
        Map<String,List< Object>> map2 = new Map<String,List< Object>>();
        map2.put('CampaignId',ids);
        Map<String,List< Object>> map3 = new Map<String,List< Object>>();
        map3.put('CampaignId',ids2);
        MobilityCampaignMarketing.getMarketing(10,2,map2,'Sottostato__c','ASC','Sottostato__c');
        MobilityCampaignMarketing.getMarketing(10,2,map3,'Sottostato__c','ASC','Sottostato__c');
        
        Test.stopTest();          
    }
}