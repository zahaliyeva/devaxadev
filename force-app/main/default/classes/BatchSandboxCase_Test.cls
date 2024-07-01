@IsTest
public class BatchSandboxCase_Test{
    @TestSetup
    static void setup() {
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
        
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Caring_Angel']; 
        
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id,
                                 RecordTypeId = rt.Id,
                                 Visualizza_sinistro__c = 'http://sol.axa-italia.it/axa_denunce/Visualizzazione/DettaglioSinistro.aspx?prog_pratica=14517334');
        insert caseObj1;
    }

    @IsTest
    static void execute() {
        Test.startTest();
        BatchSandboxCase obj = new BatchSandboxCase();
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
}