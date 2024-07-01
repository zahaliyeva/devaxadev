@isTest
public class CloseCaseTest {
    
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
        Id conId    = con.Id;
        
        User newAgent = new User(Username                    = 'agente@axa.test.com',
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
                                 OwnerId   = newAgent.Id);
        insert caseObj1;
        
        Case caseObj2 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id);
        insert caseObj2;
    }
    
    static testMethod void CloseCase() 
    {
        test.StartTest();
        
        User    agent      = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 2];
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        System.runAs(agent)
        {
            CloseCaseServer testClass = new CloseCaseServer(stcctrl);
            
            String comm      = 'Commento di prova';
            String ident1    = caseobj[0].Id;
            String ident2    = caseobj[1].Id;
            
            String errorMsg1 = CloseCaseServer.closeCase(comm, ident1,AP_Constants.caseStatusSoluzioneProposta);
            
            CloseCaseServer.doInitResults dir1 = CloseCaseServer.getOrgURL(ident1);
            CloseCaseServer.doInitResults dir2 = CloseCaseServer.getOrgURL(ident2);
        }
        
        test.stopTest();
    } 
   
}