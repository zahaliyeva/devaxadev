@IsTest
public class VFC26_AgentCreateCaseLightning_TEST {
    
    @testSetup static void setup() 
    {
        insert new MPS_Code_Variables__c(Name = 'ModelloAssistenzaConfigCHAT1', value__c = 'blabla');
        insert new MPS_Code_Variables__c(Name = 'ModelloAssistenzaConfigCHAT2', value__c = 'blabla');
        insert new MPS_Code_Variables__c(Name = 'ModelloAssistenzaConfigCHAT3', value__c = 'blabla');
        
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];
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
        
        
        
        
    }
    
    static testMethod void testmethod1() 
    {
        test.StartTest();
        
        User    agent      = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 3];
        
        VFC26_AgentCreateCaseLightning.CharacteristicsPicklist obj = new VFC26_AgentCreateCaseLightning.CharacteristicsPicklist();
        obj = VFC26_AgentCreateCaseLightning.SetPicklistInitialValues();
        obj = VFC26_AgentCreateCaseLightning.ChangeDisplayedCategories('IT',JSON.serialize(obj));
        obj = VFC26_AgentCreateCaseLightning.ChangeDisplayedSub_Categories('IT','AUTO',JSON.serialize(obj));
        obj = VFC26_AgentCreateCaseLightning.SelectChatButtonId('IT','AUTO','Annullamenti',JSON.serialize(obj));
        VFC26_AgentCreateCaseLightning.CreateCaseResult obj2 = new VFC26_AgentCreateCaseLightning.CreateCaseResult();
        Case C = new Case(LOB__c = 'IT',Category__c='AUTO', SubCategory__c='Annullamenti');
        obj2 = VFC26_AgentCreateCaseLightning.CreateCase(C);
        Id ido = VFC26_AgentCreateCaseLightning.saveChunk(obj2.CaseId, 'name', 'asas', 'pdf', '');
        test.stopTest();
    } 
}