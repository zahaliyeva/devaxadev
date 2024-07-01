@IsTest
public class customLookUpController_TEST {

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
        Account acct1 = new Account(Name = 'SFDC Account1');
        insert acct1;
        Account acct = new Account(Name = 'SFDC Account', AAI_Agency__c = acct1.Id);
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
        
        List<customLookUpController.Results> obj = new List<customLookUpController.Results>();
        obj = customLookUpController.fetchLookUpValues('SFDC', 'Account', 'Name = \'SFDC Account\'', '1', 'Name, AAI_Agency__r.Name');
        
        test.stopTest();
    } 
}