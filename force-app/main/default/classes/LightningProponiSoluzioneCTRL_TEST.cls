@IsTest
public class LightningProponiSoluzioneCTRL_TEST {

    @testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        insert new MPS_Code_Variables__c(Name = 'ProponiSoluzioneHD2', value__c = 'true');

        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'NFE - AAI - Vendite Base'];
        Profile p;
        Id pAgent;
        if (profiles.size() > 0)
        {
            p      = profiles[0];
            pAgent = p.Id;
        } 
        
        Account acct = new Account(Name = 'SFDC Account');
        insert acct;
        Id accId     = acct.Id;

        Contact con = new Contact(FirstName = 'Joe',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        User newAgent = new User(Username                     = 'agente@axa.test.com',
                                 LastName                     = 'testuser',
                                 LanguageLocaleKey            = 'it',
                                 FirstName                    = 'test',
                                 Email                        = 'test@test.com', 
                                 Alias                        = 'test',
                                 TimeZoneSidKey               = 'Europe/Dublin',
                                 LocaleSidKey                 = 'it_IT',
                                 EmailEncodingKey             = 'UTF-8',
                                 ProfileId                    = pAgent,
                                 ContactId                    = conId,
                                 UserPermissionsKnowledgeUser = true);
        insert newAgent;
        //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- START
        List<Profile> profiles2 = [SELECT Id, Name FROM Profile WHERE Name = 'AAI - Supporto HD1 - Lightning'];
        Profile p2;
        Id pSupport;
        if (profiles2.size() > 0)
        {
            p2       = profiles2[0];
            pSupport = p2.Id;
        } 
        
        User newSupport = new User(Username                     = 'supporto@axa.test.com',
                                   LastName                     = 'testuser2',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test2',
                                   Email                        = 'test2@test.com', 
                                   Alias                        = 'test2',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pSupport,
                                   UserPermissionsKnowledgeUser = true);
        insert newSupport;
		//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- END
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newAgent.Id,
                                 User__c =  newAgent.Id);
        insert caseObj1;
        
        Case caseObj2 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Closed',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newAgent.Id);
        insert caseObj2;
      
        Case caseObj3 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Attesa Info Agente',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newSupport.Id);
        insert caseObj3;
        
        
        
        
        EmailTemplate t = new EmailTemplate();
        t.DeveloperName = 'Invio_Soluzione';
        t.Subject       = 'Case: {!Case.CaseNumber}, Stato: {!Case.Status}';
        t.HtmlValue     = '<html><body>{!Case.User__c}, {!Case.CaseNumber}, {!Case.Link}</body></html>';
        t.body          = '{!Case.User__c}, {!Case.CaseNumber}, {!Case.Link}';
        t.name          = 'Conferma Soluzione';
        t.templatetype  = 'custom';
        t.folderid      = UserInfo.getUserId();
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            insert t;  
        }
       
    }
    
    static testMethod void testmethod1() 
    {
        test.StartTest();
        
        User    agent      = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 3];
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        System.runAs(agent)
        {
			PageReference pageRef = Page.Unsubscribe;
			Test.setCurrentPage(pageRef);
			pageRef.getParameters().put('Id', String.valueOf(caseobj[0].Id));
			ApexPages.StandardController sc = new ApexPages.StandardController(caseobj[0]);
			LightningProponiSoluzioneCTRL propSol = new LightningProponiSoluzioneCTRL(sc);
            Case idCase = LightningProponiSoluzioneCTRL.GetCaseInfo(String.valueOf(caseobj[0].Id));
            LightningProponiSoluzioneCTRL.buttonToReturn btn = LightningProponiSoluzioneCTRL.buttonVisible();
            String result = LightningProponiSoluzioneCTRL.UpdateSolutionDetail(String.valueOf(caseobj[0].Id), 'soluzione');
        }
        
        test.stopTest();
    } 
    
    //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- START
    static testMethod void testmethod2() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case Where OwnerId = :support.Id];
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        System.runAs(support)
        {
			PageReference pageRef = Page.Unsubscribe;
			Test.setCurrentPage(pageRef);
			pageRef.getParameters().put('Id', String.valueOf(caseobj[0].Id));
			ApexPages.StandardController sc = new ApexPages.StandardController(caseobj[0]);
			LightningProponiSoluzioneCTRL propSol = new LightningProponiSoluzioneCTRL(sc);
            Case idCase = LightningProponiSoluzioneCTRL.GetCaseInfo(String.valueOf(caseobj[0].Id));
            LightningProponiSoluzioneCTRL.buttonToReturn btn = LightningProponiSoluzioneCTRL.buttonVisible();
            String result = LightningProponiSoluzioneCTRL.UpdateSolutionDetail(String.valueOf(caseobj[0].Id), 'soluzione');
        }
        
        test.stopTest();
    } 
    //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- END
    
    //OAVERSANO 03/01/2019 : Enhancement NMA Biz III -- START
    static testMethod void testmethod3() 
    {
        test.StartTest();
        
        User    support      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case Where OwnerId = :support.Id];
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        System.runAs(support)
        {
			PageReference pageRef = Page.Unsubscribe;
			Test.setCurrentPage(pageRef);
			pageRef.getParameters().put('Id', String.valueOf(caseobj[0].Id));
			ApexPages.StandardController sc = new ApexPages.StandardController(caseobj[0]);
			LightningProponiSoluzioneCTRL propSol = new LightningProponiSoluzioneCTRL(sc);
            ContentVersion conVer = new ContentVersion();
            conVer.PathOnClient = 'test.CSV';
            conVer.Title = 'test';
            String base64Data = 'prova';
            conVer.VersionData = EncodingUtil.base64Decode(base64Data); 
            conVer.IsMajorVersion = false; 
            insert conVer;
            List<String> attachmentIds = new List<String>{conVer.Id};
            LightningProponiSoluzioneCTRL.deleteAttachments(attachmentIds);
        }
        
        test.stopTest();
    } 
    //OAVERSANO 03/01/2019 : Enhancement NMA Biz III -- END
    
}