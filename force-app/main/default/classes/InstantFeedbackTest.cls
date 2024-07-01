@isTest
public class InstantFeedbackTest {
   
    @testSetup static void setup() 
    {
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
                                 Status    = 'Soluzione proposta',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id
                            	 //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                                 //Supporto_HD2_Biz__c = true
                                 //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                                 );
        insert caseObj1;
        
        Case caseObj2 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Closed',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id
                            	 //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                                 //Supporto_HD2_Biz__c = true
                                 //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                                 );
        insert caseObj2;
      
        Case caseObj3 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Attesa Info Agente',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id
                            	 //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                                 //Supporto_HD2_Biz__c = true
                                 //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                                 );
        insert caseObj3;
        
        EmailTemplate t = new EmailTemplate();
        t.DeveloperName = 'Conferma_Soluzione';
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

        MPS_Code_Variables__c setting = new MPS_Code_Variables__c();
        setting.Name = 'SendEmailForAcceptedSolution';
        setting.Value__c = 'TRUE';
        insert setting;
       
    }
    
    static testMethod void InstantFeedback() 
    {
        test.StartTest();
        
        User    agent      = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 3];
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        System.runAs(agent)
        {
            InstantFeedbackServer testClass1 = new InstantFeedbackServer(stcctrl);
           
            String comm                   = 'Commento di prova';
            String ident1                 = caseobj[0].Id;
            String ident2                 = caseobj[1].Id;
            String ident3                 = caseobj[2].Id;
            String origin1                = caseobj[0].Origin;
            String origin2                = caseobj[1].Origin;
            String origin3                = caseobj[2].Origin;
            
            Feedback_Configuration__c f1  = InstantFeedbackServer.getFeedbackConfiguration(origin1, ident1);
                
            InstantFeedbackServer.checkResults cr1 = InstantFeedbackServer.checkError(ident1, origin1);
            InstantFeedbackServer.checkResults cr2 = InstantFeedbackServer.checkError(ident2, origin2);
            InstantFeedbackServer.checkResults cr3 = InstantFeedbackServer.checkError(ident3, origin3);
            
            InstantFeedbackServer.checkResults cr4 = InstantFeedbackServer.saveFeedback(3.0, comm, origin1, 'Front_end_agenti', ident1);
            InstantFeedbackServer.checkResults cr5 = InstantFeedbackServer.saveFeedback(9.0, '', origin2, 'Front_end_agenti', ident2);
            //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- START
            InstantFeedbackServer.checkResults cr6 = InstantFeedbackServer.checkEmailFeedbackCTRL(ident2);
            //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- END
            InstantFeedbackServer.getOrgURL();
            
            PageReference pageRef = ApexPages.currentPage();
            pageRef.getParameters().put('attachedRecords', String.valueOf('{"caseId": 2, "startIndex":0}'));
            test.setCurrentPage(pageRef);
            InstantFeedbackServer testClass2 = new InstantFeedbackServer(stcctrl);
        }
        
        test.stopTest();
    } 
   
}