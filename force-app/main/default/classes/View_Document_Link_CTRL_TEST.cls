@isTest
private class View_Document_Link_CTRL_TEST {
    

    @testSetup static void setup(){

        ServiceUtilsClass.populateCustomSettingsForTests();
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('AXA MPS Business Admin','AAI - Supervisor Supporto HD1 - Lightning')];
        Id pCAHD1;
        Id pCAHD2;
        
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

        

        
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = user1.Id,
                                 Document_Unique_ID__c= 'OB773052');
                                 
        insert caseObj1;                         


        Case caseObj2 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = user2.Id,
                                 Document_Unique_ID__c= null);
        insert caseObj2;                     

        }
        
        
        
    

    @isTest
    static  void testmethod1(){

        test.startTest();

        View_Document_Link_CTRL.fetchUser();

        test.stopTest();
    }
   
    @isTest
    static void tesmethod2(){

        test.startTest();
        list<User>    agent      = [SELECT Id, ProfileId FROM User WHERE Username in ('supporto1@axa.test.com','supporto2@axa.test.com') LIMIT 2];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 2];
        View_Document_Link_CTRL.checkDocumentId(caseobj[0].id);
        test.stopTest();

    } 
}