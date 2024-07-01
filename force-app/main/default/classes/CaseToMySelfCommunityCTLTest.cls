@isTest
public class CaseToMySelfCommunityCTLTest {

    @testSetup static void setup(){

        ServiceUtilsClass.populateCustomSettingsForTests();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('AXA MPS Business Admin','AAI - Supervisor Supporto HD1 - Lightning', 'Coda_Agenzia_Case')];
        Id pCAHD1;
        Id pCAHD2;
        Id pCAHD3;
        
        if (profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'AXA MPS Business Admin')
                {
                    pCAHD1 = p.Id;
                }
                else if(p.Name == 'AAI - Supervisor Supporto HD1 - Lightning')
                {
                    pCAHD2 = p.Id;
                }
                /*nota: non esistono profili con questo nome
                 * else if(p.Name == 'Coda_Agenzia_Case')
                {
                    pCAHD2 = p.Id;
                }*/
            }
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

        

        User user1 = new User      (Username                    = 'supporto1@axa.test.com',
                                   LastName                     = 'testuser1',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test1',
                                   Email                        = 'tes1@test.com', 
                                   Alias                        = 'test1',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pCAHD1
                                   );
                    insert user1;

        User user2 = new User      (Username                    = 'supporto2@axa.test.com',
                                   LastName                     = 'testuser2',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test2',
                                   Email                        = 'tes2@test.com', 
                                   Alias                        = 'test2',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pCAHD2
                                   );  
                    insert user2;
        
        
        /* vedi nota riga 24
         * User user3 = new User      (Username                    = 'supporto3@axa.test.com',
                                   LastName                     = 'testuser3',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test3',
                                   Email                        = 'tes3@test.com', 
                                   Alias                        = 'test3',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pCAHD3
                                   );  
                    insert user3;*/

        
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = user1.Id
                                 );
                                 
        insert caseObj1;                         


        Case caseObj2 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = user2.Id
                                 );
        insert caseObj2;  
        
        /* vedi nota riga 24
        Case caseObj3 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = user3.Id
                                 );
        insert caseObj3;*/ 

        
                

        }

        @isTest
        static void tesmethod2(){

        test.startTest();
        list<User>    agent      = [SELECT Id, ProfileId FROM User WHERE Username in ('supporto1@axa.test.com','supporto2@axa.test.com') LIMIT 2];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, OwnerId, QueueNameOwner__c, Status FROM Case LIMIT 2];
        try{
        CaseToMySelfCommunityCTL.UpdateCase(caseobj[0].id);
        }
        catch(AuraHandledException e){
            System.debug(e.getMessage());
            System.assertEquals('Attenzione ! É possibile prendere in carico il case solo se è in carico alla propria agenzia',e.getMessage());
        }
        
        test.stopTest();

    	} 

        @isTest
        static void testmethod3(){

        test.startTest();
        list<User>    agent      = [SELECT Id, ProfileId FROM User WHERE Username in ('supporto1@axa.test.com','supporto2@axa.test.com') LIMIT 2];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        try{
        CaseToMySelfCommunityCTL.UpdateCase('5006E00000DvIsYQAA');
        }
        catch(AuraHandledException e){
            System.debug(e.getMessage());
            System.assertEquals('Attenzione! Non è possibile prendere in carico il case. Identificativo non corretto.',e.getMessage());
        }
        
        test.stopTest();

        }
    
    	/* vedi nota riga 24
    	@isTest
        static void tesmethod4(){

        test.startTest();
        list<User>    agent      = [SELECT Id, ProfileId FROM User WHERE Username in ('supporto1@axa.test.com','supporto2@axa.test.com','supporto3@axa.test.com') LIMIT 3];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, OwnerId, QueueNameOwner__c, Status FROM Case LIMIT 3];
        try{
        CaseToMySelfCommunityCTL.UpdateCase(caseobj[2].id);
        }
        catch(AuraHandledException e){
            System.debug(e.getMessage());
            System.assertEquals('Attenzione ! É possibile prendere in carico il case solo se è in carico alla propria agenzia',e.getMessage());
        }
        
        test.stopTest();

    	}*/
}