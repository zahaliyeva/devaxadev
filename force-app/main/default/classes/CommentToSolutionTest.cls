@isTest
public class CommentToSolutionTest {
   
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
                                 OwnerId   = newAgent.Id);
        insert caseObj1;
        
        Case caseObj2 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Soluzione proposta',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id);
        insert caseObj2;
        
        EmailTemplate t = new EmailTemplate();
        t.DeveloperName = 'Commenta_Soluzione';
        t.Subject       = 'Case: {!Case.CaseNumber}, Stato: {!Case.Status}';
        t.HtmlValue     = '<html><body>{!Case.User__c}, {!Case.CaseNumber}, {!Case.Link}, {!Case.Description}</body></html>';
        t.body          = '{!Case.User__c}, {!Case.CaseNumber}, {!Case.Link}, {!Case.Description}';
        t.name          = 'Commenta Soluzione';
        t.templatetype  = 'custom';
        t.folderid      = UserInfo.getUserId();
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            insert t;  
        }
        /*Modello_di_Assistenza__mdt mdAss = new Modello_di_Assistenza__mdt(DeveloperName='TemplateCommentaSoluzione', Email_Template__c = 'Commenta_Soluzione');
        insert mdAss;*/
    }
    
    static testMethod void CommentToSolution() 
    {
        test.StartTest();
        
        User    agent      = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 2];
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        System.runAs(agent)
        {
            CommentToSolutionServer testClass = new CommentToSolutionServer(stcctrl);
            
            String comm                   = 'Commento di prova';
            String ident1                 = caseobj[0].Id;
            String ident2                 = caseobj[1].Id;
            Boolean err1                  = CommentToSolutionServer.checkError(ident1);
            Boolean err2                  = CommentToSolutionServer.checkError(ident2);
            Storico_conversazioni__c sc1  = CommentToSolutionServer.saveComment(comm, ident1);
            Storico_conversazioni__c sc2  = CommentToSolutionServer.saveComment(comm, ident2);
            
            CommentToSolutionServer.getOrgURL();
        }
        
        test.stopTest();
    } 
   
}