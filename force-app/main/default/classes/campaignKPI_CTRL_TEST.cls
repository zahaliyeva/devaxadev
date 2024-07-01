@istest

public class campaignKPI_CTRL_TEST {

 @testSetup static void setup() {//preparing test database
     
     //test.startTest();
     
     //Insert custom settings
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='CampaignKPI', Value__c='https://axaitalia--pre.cs80.my.salesforce.com');
        insert acv;
     
    
   List<CampaignMembStatus__c> cms = new List<CampaignMembStatus__c>{
            new CampaignMembStatus__c(
                Name = 'Interested',
                Status_Name__c = 'Interessato',
                SortOrder__c = 3,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            ),
            new CampaignMembStatus__c(
                Name = 'Excluded',
                Status_Name__c = 'Escluso',
                SortOrder__c = 4,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            ),
            new CampaignMembStatus__c(
                Name = 'Call again',
                Status_Name__c = 'Da ricontattare',
                SortOrder__c = 5,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            ),
            new CampaignMembStatus__c(
                Name = 'Not interested',
                Status_Name__c = 'Non interessato',
                SortOrder__c = 6,
                IsDefault__c = true,
                Campaign_Record_Type__c='Agency_campaign'//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti                  
            )
        };
        insert cms;
        
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        RecordType cpMKTG = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Marketing_campaign'];
        
        Campaign cp = new Campaign(
            Name = 'CampagnaTest',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = cpRT.Id,
            StartDate = Date.today(),
            EndDate = Date.today()+3
        );
        insert cp;
     
      Campaign cp2 = new Campaign(
            Name = 'CampagnaTestMKTG',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = cpMKTG.Id,
            StartDate = Date.today(),
            EndDate = Date.today()+3
        );
        insert cp2;
        
        

        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
                
                RecordType accRT = [SELECT Id,IsPersonType FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'B2C_Client' ];
                RecordType agRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'Agency' ];
                List<Account> accountz = new List<Account>{
                 new Account(
                FirstName = 'AccountTest99',
                LastName = 'AccountTest00',
                PersonEmail = 'account@mail.test',
                Phone = '0333333333',
                PersonMobilePhone = '3333333333',
                Nodes__c = '009999',
                AAI_Agency_Reference_Code__c = '009999',
                RecordTypeID = accRT.id
            ),new Account(
                FirstName = 'AccountTest11',
                LastName = 'AccountTest22',
                PersonEmail = 'account@mail.test',
                Phone = '03333333331111',
                PersonMobilePhone = '3333333333111',
                Nodes__c = '009999',
                AAI_Agency_Reference_Code__c = '009999',
                RecordTypeID = accRT.id
            ),new Account(
                Name = 'AgenziaTest',
                Nodes__c = '009999',
                Agency_Code__c = '009999',
                Agency_Holder__c = 'HOLDER TEST',
                Active__c = true, 
                RSAC_Description_Code__c = 'AREA MANAGER',
                RSA_Description_Code__c = 'SALES MANAGER',
                RecordTypeID = agRT.id
            )};
            insert accountz;
            
  
            
        }
            //account acc =  [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE FirstName = 'AccountTest99' and LastName = 'AccountTest00' ];
            List<account> allacc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE PersonEmail= 'account@mail.test'];
        account acc=allacc.get(0);
        account acc2=allacc.get(1);

        
List<CampaignMember> campaignMembers = new List<CampaignMember>{
            new CampaignMember(
                ContactId = acc.PersonContactId,
                CampaignId = cp.Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Interessato',
                Note__c = 'NoteTest'       
            ),
            new CampaignMember(
                ContactId = acc2.PersonContactId,
                CampaignId = cp.Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Escluso',
                Note__c = 'NoteTest2'       
            ),
                new CampaignMember(
                ContactId = acc2.PersonContactId,
                CampaignId = cp2.Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Escluso',
                Note__c = 'NoteTest2'       
            ),
                new CampaignMember(
                ContactId = acc.PersonContactId,
                CampaignId = cp2.Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Interessato',
                Note__c = 'NoteTest'       
            )
                
        };
        insert campaignMembers;

List<Task> campaignTasks = new List<Task>{
            new Task(
                Subject = 'ContattoTEST',
                TECH_SourceId__c = campaignMembers[0].Id       
            ),
            new Task(
                Subject = 'ContattoTEST2',
                TECH_SourceId__c = campaignMembers[1].Id      
            )
        };
        insert campaignTasks;
        
        
        //Creating agent
        UserProvisioningAAI.UserDetailsInput UserInputAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputAgent.Active='0';
        UserInputAgent.FirstName='Agent';
        UserInputAgent.LastName='Agent';
        UserInputAgent.Email='agent@agent.it';
        UserInputAgent.UserName='agent@test.test';
        UserInputAgent.MyriamUserName = 'ag_agent';
        UserInputAgent.AgencyCode = '009999';

        //test.stopTest();
    }

    static testmethod void TEST_campaignKPI(){
        
        test.startTest();
        
         system.runas(new User(id=UserInfo.getuserID())) {
          
             Campaign myCampaign = [SELECT Id FROM Campaign WHERE Name = 'CampagnaTestMKTG' LIMIT 1];
             PageReference acctPage = new PageReference('/' + myCampaign.id);
             acctPage.setRedirect(true);
             String CampaignId = myCampaign.Id;
             String PartnerUrl = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'CampaignKPI' ].Value__c;
             String SessionId = null;
             String UserRole = 'AXA Assicurazioni';
             List<String> AgencyList = new List<String>();
             AgencyList.add('009999');
             AgencyList.add('009998');
             AgencyList.add('001000');
             
             Campaign myCamp = campaignKPI_CTRL.getCampaign(CampaignId);
             
             campaignKPITest_Mock mockServer = new campaignKPITest_Mock();
             mockServer.TestCase = 'ClientiInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiInTarget = campaignKPI_CTRL.ClientiInTarget(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiLavorati';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiLavorati = campaignKPI_CTRL.ClientiLavorati(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiPrioritari';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiPrioritari = campaignKPI_CTRL.ClientiPrioritari(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiPrioritariLavorati';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiPrioritariLavorati = campaignKPI_CTRL.ClientiPrioritariLavorati(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaCreate';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaCreate = campaignKPI_CTRL.OpportunitaCreate(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaVinte';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaVinte = campaignKPI_CTRL.OpportunitaVinte(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaVinteClientiPrioritari';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaVinteClientiPrioritari = campaignKPI_CTRL.OpportunitaVinteClientiPrioritari(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'RevenueOpportunitaVinte';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String RevenueOpportunitaVinte = campaignKPI_CTRL.RevenueOpportunitaVinte(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaIncorso';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaIncorso = campaignKPI_CTRL.OpportunitaIncorso(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'RevenueOpportunitaIncorso';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String RevenueOpportunitaIncorso = campaignKPI_CTRL.RevenueOpportunitaIncorso(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'EmailSMSrecapitati';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String EmailSMSrecapitati = campaignKPI_CTRL.EmailSMSrecapitati(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConEmailSMSInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConEmailSMSInTarget = campaignKPI_CTRL.ClientiConEmailSMSInTarget(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'EmailSMSNonRecapitabili';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String EmailSMSNonRecapitabili = campaignKPI_CTRL.EmailSMSNonRecapitabili(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConEmailInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConEmailInTarget = campaignKPI_CTRL.ClientiConEmailInTarget(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiEmailApertaRichiestaContatto';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiEmailApertaRichiestaContatto = campaignKPI_CTRL.ClientiEmailApertaRichiestaContatto(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConSMSInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConSMSInTarget = campaignKPI_CTRL.ClientiConSMSInTarget(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiSMSApertoRichiestaContatto';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiSMSApertoRichiestaContatto = campaignKPI_CTRL.ClientiSMSApertoRichiestaContatto(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConEmailSMSAperti';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConEmailSMSAperti = campaignKPI_CTRL.ClientiConEmailSMSAperti(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList); 
             
             mockServer.TestCase = 'ClientiPrioritariEmail';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiPrioritariEmail = campaignKPI_CTRL.ClientiPrioritariEmail(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList); 
             
             mockServer.TestCase = 'ClientiPrioritariSMS';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiPrioritariSMS = campaignKPI_CTRL.ClientiPrioritariSMS(CampaignId,'','009999',PartnerUrl,SessionId,AgencyList); 
             
             Map <String,String> myInfosMap = campaignKPI_CTRL.getUserInfos();
             List<CampaignMember> myCM = campaignKPI_CTRL.getCollaboratori(CampaignId, '009999',UserRole); 
             Map <String,String> myAgValues = campaignKPI_CTRL.getAgencyValues();
             List <String> myAgCodes = campaignKPI_CTRL.getAgencyCodes('AREA MANAGER','SALES MANAGER','009999');
             Map <String,String> myPageValues = campaignKPI_CTRL.getPageValues();
             
             test.stopTest();
           
         }
        
    }    
    
      static testmethod void TEST_campaignKPI_AgencyList(){
        
        test.startTest();
        
         system.runas(new User(id=UserInfo.getuserID())) {
          
             Campaign myCampaign = [SELECT Id FROM Campaign WHERE Name = 'CampagnaTestMKTG' LIMIT 1];
             PageReference acctPage = new PageReference('/' + myCampaign.id);
             acctPage.setRedirect(true);
             String CampaignId = myCampaign.Id;
             String PartnerUrl = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'CampaignKPI' ].Value__c;
             String SessionId = null;
             String UserRole = 'AXA Assicurazioni';
             List<String> AgencyList = new List<String>();
             AgencyList.add('009999');
             AgencyList.add('009998');
             AgencyList.add('001000');
             
             Campaign myCamp = campaignKPI_CTRL.getCampaign(CampaignId);
             
             campaignKPITest_Mock mockServer = new campaignKPITest_Mock();
             mockServer.TestCase = 'ClientiInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiInTarget = campaignKPI_CTRL.ClientiInTarget(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiLavorati';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiLavorati = campaignKPI_CTRL.ClientiLavorati(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiPrioritari';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiLPrioritari = campaignKPI_CTRL.ClientiPrioritari(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiPrioritariLavorati';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiPrioritariLavorati = campaignKPI_CTRL.ClientiPrioritariLavorati(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaCreate';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaCreate = campaignKPI_CTRL.OpportunitaCreate(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaVinte';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaVinte = campaignKPI_CTRL.OpportunitaVinte(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaVinteClientiPrioritari';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaVinteClientiPrioritari = campaignKPI_CTRL.OpportunitaVinteClientiPrioritari(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'RevenueOpportunitaVinte';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String RevenueOpportunitaVinte = campaignKPI_CTRL.RevenueOpportunitaVinte(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'OpportunitaIncorso';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String OpportunitaIncorso = campaignKPI_CTRL.OpportunitaIncorso(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'RevenueOpportunitaIncorso';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String RevenueOpportunitaIncorso = campaignKPI_CTRL.RevenueOpportunitaIncorso(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'EmailSMSrecapitati';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String EmailSMSrecapitati = campaignKPI_CTRL.EmailSMSrecapitati(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConEmailSMSInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConEmailSMSInTarget = campaignKPI_CTRL.ClientiConEmailSMSInTarget(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'EmailSMSNonRecapitabili';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String EmailSMSNonRecapitabili = campaignKPI_CTRL.EmailSMSNonRecapitabili(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConEmailInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConEmailInTarget = campaignKPI_CTRL.ClientiConEmailInTarget(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiEmailApertaRichiestaContatto';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiEmailApertaRichiestaContatto = campaignKPI_CTRL.ClientiEmailApertaRichiestaContatto(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConSMSInTarget';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConSMSInTarget = campaignKPI_CTRL.ClientiConSMSInTarget(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiSMSApertoRichiestaContatto';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiSMSApertoRichiestaContatto = campaignKPI_CTRL.ClientiSMSApertoRichiestaContatto(CampaignId,'','',PartnerUrl,SessionId,AgencyList);
             
             mockServer.TestCase = 'ClientiConEmailSMSAperti';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiConEmailSMSAperti = campaignKPI_CTRL.ClientiConEmailSMSAperti(CampaignId,'','',PartnerUrl,SessionId,AgencyList); 
             
             mockServer.TestCase = 'ClientiPrioritariEmail';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiPrioritariEmail = campaignKPI_CTRL.ClientiPrioritariEmail(CampaignId,'','',PartnerUrl,SessionId,AgencyList); 
             
             mockServer.TestCase = 'ClientiPrioritariSMS';
             Test.setMock(HttpCalloutMock.class, mockServer);
             String ClientiPrioritariSMS = campaignKPI_CTRL.ClientiPrioritariSMS(CampaignId,'','',PartnerUrl,SessionId,AgencyList); 
             
             Map <String,String> myInfosMap = campaignKPI_CTRL.getUserInfos();
             List<CampaignMember> myCM = campaignKPI_CTRL.getCollaboratori(CampaignId, '009999',UserRole); 
             Map <String,String> myAgValues = campaignKPI_CTRL.getAgencyValues();
             List <String> myAgCodes = campaignKPI_CTRL.getAgencyCodes('AREA MANAGER','SALES MANAGER','009999');
             Map <String,String> myPageValues = campaignKPI_CTRL.getPageValues();
             
             test.stopTest();
           
         }
        
    }    
}