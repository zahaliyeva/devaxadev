@isTest
public class VFC29_ChiudiCaseCTL_TEST {

    @testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
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
        
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id,
                                 User__c =  newAgent.Id,
                                 Last_Advisor__c = newAgent.Id);
        insert caseObj1;
        
        Case caseObj2 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Closed',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id);
        insert caseObj2;
      
        Case caseObj3 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Attesa Info Agente',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id);
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
            VFC29_ChiudiCaseCTL propSol = new VFC29_ChiudiCaseCTL(sc);
            String result = VFC29_ChiudiCaseCTL.UpdateCaseCTL(String.valueOf(caseobj[0].Id),'test');
            VFC29_ChiudiCaseCTL.CloseCaseCTL(String.valueOf(caseobj[0].Id),'test', true);
        }
        
        test.stopTest();
    } 
    
    static testMethod void testMethodGetCase(){
        List<Case> c = [select id from case limit 1];
        VFC29_ChiudiCaseCTL.getCase(c.get(0).id);
        VFC29_ChiudiCaseCTL.isRightCTL(c.get(0).id, true);
    }

}