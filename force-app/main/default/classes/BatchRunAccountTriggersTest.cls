/*------------------------------------------------------------------------
Author:        --
Company:       --
Class:         BatchRunAccountTriggersTest
Description:   Test class for BatchRunAccountTriggers class

History

25/11/2021     Created - *-+

----------------------------------------------------------------------------*/

@istest
global without sharing class BatchRunAccountTriggersTest {

    @TestSetup static void setup(){
		Id integrationProfile = [Select id from profile where name = 'Integration ETL'].Id;
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id account_B2B = UtilityClass.getRTid(rtypes, 'Account', 'B2B_Client');
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());

        insert acv;
        
        

         //Create agency user
        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];     
        Id pVen = pvendite.Id;   

        UserRole role = [SELECT Id FROM UserRole where developername = 'MODENAUtentePartner'];
        Id pRol = role.Id;

        Account agencia = new Account (Name='TheBigBanAgenzy',
                                        NeedAsyncTriggerExecution__c=true,
                                        Agency_Code__c  ='123456',
                                        TECH_Company__c = 'AAI',
                                        RecordTypeId =account_agency );
        insert agencia ;

        Contact agencyContact = new Contact(LastName = 'Penny Contact',
                                            RecordtypeId = contact_agency,
                                            AccountId = agencia.Id);
        insert agencyContact;

         //create user and insert
        //User usr1 = null;
        //set true disable trigger for account with Accounthandler
        AccountHandler.setDeactivateTrigger(true);

        Node__c nodo = new Node__c ();
        nodo.Agency_holder__c = 'NODO Holder';
        nodo.Node_unique_code__c= '000024';
        nodo.Parent_node_unique_code__c= 'A001';
        nodo.Tree_name__c= 'DIF';
        nodo.Blacklist_Processi__c= 'Rinnovi';
        nodo.Node_description__c= 'Agency Away from Home';
        nodo.Node_level__c= 8;

        NodeHandler.setDeactivateTrigger(true);//avoid trigger for this node, non rules 
        insert nodo ;

        List<User> usrToIns = new List<User>();
           User usr1=new User(FirstName='Test',
                    LastName = 'Integration',
                    Alias = 'TINTE',
                    Email = 'test.test@test.it',
                    Username = 'test.test@test.it.BatchRunTriggers',
                    CommunityNickname = 'Titan',
                    LanguageLocaleKey = 'en_US',
                    TimeZoneSidKey='Europe/Rome',
                    Profileid = integrationProfile,
                    LocaleSidKey='en_US',
                    EmailEncodingKey='ISO-8859-1'
                    //UserRoleId=pRol,
            );
        usrToIns.add(usr1);
           User usr2=new User(FirstName='Eren',
                    LastName = 'jaeger',
                    Alias = 'atac',
                    Email = 'j.ricardofernandez@reply.it',
                    Username = 'jeren@titan.it.shingeki',
                    CommunityNickname = 'Titan2',
                    LanguageLocaleKey = 'en_US',
                    TimeZoneSidKey='Europe/Rome',
                    Profileid = pVen,
                    LocaleSidKey='en_US',
                    EmailEncodingKey='ISO-8859-1',
                    //UserRoleId=pRol,
                    ContactId = agencyContact.Id
            );
        usrToIns.add(usr2);
            insert usrToIns;// dont used -- just for try GroupMembers
            List<Group> g1 = new List<Group>{
            new Group(DeveloperName='DIF_123456',Name='DIF_123456',Type='Regular'),
            new Group(DeveloperName='DIF_1234567',Name='DIF_1234567',Type='Regular'),
            new Group(DeveloperName='DIF_12345678',Name='DIF_12345678',Type='Regular')
            };
            
            insert g1;
        
        insert new ByPassingTrigger__c (SetupOwnerId=usr1.Id , isTriggerAccount__c = true);

            //User u = [Select id from user where username ='mrosskm11@axa.com.masterdev'];
            //
            
        system.runAs(usr1){
            List<Account> accToIns = new List<Account>{
                new Account (Name='Sheldon Cooper',NeedAsyncTriggerExecution__c=true,TECH_Company__c = 'AAI',
                                           RecordTypeId =account_B2B,Nodes__c = '123456;1234567;12345678'),

            	new Account (Name='Leonard Hofstadter' ,NeedAsyncTriggerExecution__c=true,TECH_Company__c = 'AAI',
                                            AAI_Agency_Reference_Code__c ='123456',
                                            RecordTypeId =account_B2B,Nodes__c = '123456;1234567'),

            	new Account (LastName='Hofstadter' ,FirstName='Leonard',NeedAsyncTriggerExecution__c=true,TECH_Company__c = 'AAI',
                                            AAI_Agency_Reference_Code__c ='123456',
                             RecordTypeId =account_B2C,Nodes__c = '123456;1234567')
                    };

            insert accToIns ;
        }
            

    
         
        //ccountHandler.setDeactivateTrigger(true);//  for disable triggers :)
        

    }

    @IsTest
    static void executeControllingSharingWithBatch() {
        Test.startTest();

        BatchRunAccountTriggers obj = new BatchRunAccountTriggers();
        DataBase.executeBatch(obj);
        
        Test.stopTest();

        list <Id> idGrupos = new list<Id>();
        list <Group> groups = [select id, name  from group where DeveloperName like 'DIF_123456%'] ;

        for (Group grupo : groups)
        idGrupos.add(grupo.id);

        list<AccountShare> accSharebefore = [select  AccountId, UserOrGroupId, 
                                            AccountAccessLevel from AccountShare where RowCause = 'manual'];


        Account accountSheldon = [select id,NeedAsyncTriggerExecution__c from account where name like 'Sheldon %' limit 1] ;
        Account accountLeonard = [select id,NeedAsyncTriggerExecution__c from account where name like 'Leonard %' limit 1] ;

        list<AccountShare> accountShareForSheldon = [select  AccountId, UserOrGroupId, 
                                                AccountAccessLevel from AccountShare where RowCause = 'manual' 
                                                    and AccountId =: accountSheldon.id 
                                                    and UserOrGroupId in :idGrupos];

        list<AccountShare> accountShareForLeonard = [select  AccountId, UserOrGroupId, 
                                                AccountAccessLevel from AccountShare where RowCause = 'manual'
                                                    and AccountId =: accountLeonard.id 
                                                    and UserOrGroupId in :idGrupos];

        System.assertEquals(3, accountShareForSheldon.size());//condiviso con 3 gruppi

        System.assertEquals(2, accountShareForLeonard.size());//condiviso con 2 gruppi

        System.assertEquals(accountSheldon.NeedAsyncTriggerExecution__c,false,
         'Should be Update to FALSE NeedAsyncTriggerExecution__c');
    }

}