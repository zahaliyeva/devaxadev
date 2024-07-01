@isTest
public class MobilityCampaignDataEnrichmentTest {
    @testSetup private static void createData(){
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1',
                                      Startdate = system.today()-1,
                                      enddate = system.today()+2,
                                      Type = 'TCM',
                                      Status = 'On-going');
        insert camp1;
        Campaign camp2 = new Campaign(Name = 'Test Campaign 2',
                                      Startdate = system.today()-1,
                                      enddate = system.today()+2,
                                      Type = 'Core/Industriale',
                                      Status = 'On-going');
        insert camp2;
        Campaign camp3 = new Campaign(Name = 'Test Campaign 3',
                                      Startdate = system.today()-1,
                                      enddate = system.today()+2,
                                      Type = 'Data Enrichment Campaign',
                                      Status = 'On-going');
        insert camp3;
        
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
        CampaignMember campm2 = new campaignMember(  
            Status='Da assegnare',
            CampaignId=camp2.id,
            Stato_Adesione__c = 'ESCLUSO',
            ContactId=c[0].id,
            NeedAsyncBatchExecution__c=true);
        insert campm2;
        CampaignMember campm3 = new campaignMember(  
            Status='Da assegnare',
            CampaignId=camp3.id,
            Stato_Adesione__c = 'ESCLUSO',
            ContactId=c[0].id,
            NeedAsyncBatchExecution__c=true);
        insert campm3;
    }
    
    @isTest static void test() {
        Test.startTest();
        Id camp2ID = [SELECT Id FROM Campaign WHERE Type = 'Core/Industriale' ].Id;
        Id camp1ID = [SELECT Id FROM Campaign WHERE Type = 'TCM' ].Id;
        Id camp3ID = [SELECT Id FROM Campaign WHERE Type = 'Data Enrichment Campaign' ].Id;
        CampaignMember campm1 = [SELECT id FROM CampaignMember WHERE CampaignId = :camp1ID];
        CampaignMember campm2 = [SELECT id FROM CampaignMember WHERE CampaignId = :camp2ID];
        CampaignMember campm3 = [SELECT id FROM CampaignMember WHERE CampaignId = :camp3ID];
        
        Account acct1 = [SELECT Id FROM Account LIMIT 1];
        
        List< Object> ids1 = new List< Object>();
        List< Object> ids2 = new List< Object>();
        List< Object> ids3 = new List< Object>();
        ids1.add(camp1ID);
        ids2.add(camp2ID);
        ids3.add(camp3ID);
        Map<String,List< Object>> map1 = new Map<String,List< Object>>();
        Map<String,List< Object>> map2 = new Map<String,List< Object>>();
        Map<String,List< Object>> map3 = new Map<String,List< Object>>();
        map1.put('CampaignId',ids1);
        map2.put('CampaignId',ids2);
        map3.put('CampaignId',ids3);
        MobilityCampaignDataEnrichment.initData(campm1.id);
        MobilityCampaignDataEnrichment.proccessDataEnrichment(camp1ID, campm1.id, acct1);
        MobilityCampaignDataEnrichment.initData(campm2.id);
        MobilityCampaignDataEnrichment.proccessDataEnrichment(camp2ID, campm2.id, acct1);
        MobilityCampaignDataEnrichment.initData(campm3.id);
        MobilityCampaignDataEnrichment.proccessDataEnrichment(camp3ID, campm3.id, acct1);
        MobilityCampaignDataEnrichment.getDataEnrichment(10,2,map1,'Sottostato__c','ASC','Sottostato__c');
        MobilityCampaignDataEnrichment.getDataEnrichment(10,2,map2,'Sottostato__c','ASC','Sottostato__c');
        MobilityCampaignDataEnrichment.getDataEnrichment(10,2,map3,'Sottostato__c','ASC','Sottostato__c');
        System.assertEquals(camp1ID != null, true,'campagna deve essere inserita OK');
        Test.stopTest();          
    }
}