@istest
global class BatchRunCampaignMember_Test {

    @IsTest
    static void executeControllingSharingWithBatch() {
        Profile pvendite = [SELECT Id FROM Profile limit 1]; 
        AccountHandler.setDeactivateTrigger(true);
     
        user u1= new user(
                           FirstName='Carl',
            Username='johnsvdsvcsd1@acme.com', 
            LastName='Sistema', 
            Email='automatedcase@00d24000000hjzmeao.ext	', 
            Alias='autocase', 
            TimeZoneSidKey='GMT', 
            LocaleSidKey='it_IT', 
            EmailEncodingKey='ISO-8859-1', 
            ProfileId=pvendite.id, 
            LanguageLocaleKey='it',
                           Main_Node__c='1'
                          );
        insert u1;
        
        user u2= new user(
                           FirstName='Marco',
            Username='johnzvswdv@acme.com', 
            LastName='Sistema', 
            Email='automatedcase@00d24000000hjzmeao.ext22', 
            Alias='autocase', 
            TimeZoneSidKey='GMT', 
            LocaleSidKey='it_IT', 
            EmailEncodingKey='ISO-8859-1', 
            ProfileId=pvendite.id, 
            LanguageLocaleKey='it',
                           Main_Node__c='1'
                          );
        insert u2;
         
        user u3= new user(
                           FirstName='Ale',
            Username='johnzewvswdv@acme.com', 
            LastName='Sistema', 
            Email='automatedcase@00d24000000hjzmeao.ext22', 
            Alias='autocase', 
            TimeZoneSidKey='GMT', 
            LocaleSidKey='it_IT', 
            EmailEncodingKey='ISO-8859-1', 
            ProfileId=pvendite.id, 
            LanguageLocaleKey='it',
                           Main_Node__c='2'
                          );
        insert u3;
        
        user u4= new user(
                           FirstName='Tommaso',
            Username='johnzwefevswdv@acme.com', 
            LastName='Sistema', 
            Email='automatedcase@00d24000000hjzmeao.ext22', 
            Alias='autocase', 
            TimeZoneSidKey='GMT', 
            LocaleSidKey='it_IT', 
            EmailEncodingKey='ISO-8859-1', 
            ProfileId=pvendite.id,
            LanguageLocaleKey='it'
                          );
        insert u4;
        
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
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id campaign_agency = UtilityClass.getRTid(rtypes, 'Campaign', 'Agency_campaign');  
       
        lead l1= new lead(Company='Prova lead1',LastName='Prova lead1');
        insert l1;   
           
        Account acc = new Account(        FirstName = 'AccountTest99',
                                          LastName = 'AccountTest00',
                                          PersonEmail = 'account@mail.test',
                                          Phone = '0333333333',
                                          PersonMobilePhone = '3333333333',
                                          Agency_Code__c = '006345',
                                          Nodes__c = '006345',
                                          Ccod_Produttore__c='2',
                                          RecordTypeID = account_B2C);
                                
        insert acc;
         
        
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1',
                                     Startdate = system.today()-1,
                                     enddate = system.today()+2,
                                     Type = 'TCM',
                                     Status = 'On-going');
        insert camp1;

        contact c=[select id, accountid from contact limit 1];
        
        campaignMember campm1= new campaignMember(  
        											LeadId=ld.id,
                                                    Status='Da assegnare',
                                                    CampaignId=camp1.id,
                                                    ContactId=c.id,
                                                    NeedAsyncBatchExecution__c=true
        
        
        );
           insert campm1;

        Test.startTest();
         
        BatchRunCampaignMember obj = new BatchRunCampaignMember(camp1.id);
        obj.query = 'Select id,Name, Status,CampaignId, Owner__c, ContactId,Nodo_Omnia_produttore__c, Contact.AccountId ,NeedAsyncBatchExecution__c  from CampaignMember';
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }

    }}