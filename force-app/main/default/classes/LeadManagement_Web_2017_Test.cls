/*
*Class:         LeadManagementTest
*Description:   Class to test the entire process of Web's Lead creation and initial assignation 
*----------------------------------------------------------------------------------------------------------------------------
* History Log
*
* description: Enhancement Lead Management - Sprint 59: Completely restructured the class
* date: 18/01/2018
* author: Andrea Capobianco
*----------------------------------------------------------------------------------------------------------------------------
*/

@isTest
private class LeadManagement_Web_2017_Test {

    @testSetup static void setup()
    {
        //Retrieving informations about profiles and roles
        list<Profile> profiles = [SELECT Id,Name FROM Profile WHERE Name in ('NFE - AAI - Vendite Avanzato','System Administrator') ]; 
        Profile pvendite;
        Profile sadmin;
        for (Profile p :profiles){
            if (p.Name=='NFE - AAI - Vendite Avanzato')
            {
                pvendite=p;
            }
            else if (p.Name=='System Administrator')
            {
                sadmin=p;
            }
        }
        Id pVen = pvendite.Id; 
        Id pSadmin =  sadmin.Id; 
        UserRole role = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'];
        Id pRol = role.Id;

        //Creating the Admin user
        User userAdmin = new User(Username = 'admin@axa.test.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = pSadmin,
                            UserRoleId = pRol,
                            UserPermissionsKnowledgeUser=true);
        insert userAdmin;

        //Retrieving Record Types for Contacts and Accounts
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        
        System.runAs(userAdmin)
        {   
            //Creating the IE Configurations
            List<IE_Configuration__c> configurationsList = new List<IE_Configuration__c>{

                new IE_Configuration__c(Name = 'Integration_LeadAssignment',
                                        Type__c = 'WebService_rest',
                                        Direction__c = 'OUTBOUND',
                                        EndPoint__c = 'http://www.mocky.io/v2/5b486d822f00007d0048188e',
                                        Request_compiler__c = 'IE_Request_LeadAssignment',
                                        Response_parser__c = 'IE_Parser_LeadAssignment',
                                        HTTPMethod__c = 'GET'
                                        )

            };
            insert configurationsList;

            //Creating the Agency Accounts with the relative Contacts
            List<Account> agencyList = new List<Account>
            {
                new Account(Name = 'Agency Test Account 1',
                            RecordTypeId = account_agency,
                            Agency_Code__c = '004610',
                            Active__c = true,
                            Accordo_Digitale__c = true
                            ),

                new Account(Name = 'Agency Test Account 2',
                            RecordTypeId = account_agency,
                            Agency_Code__c = '000828',
                            Active__c = true,
                            Accordo_Digitale__c = true)
            };

            insert agencyList;
            
            List<Contact> contactList = new List<Contact> 
            {          
            
                new Contact(LastName = 'Agency Test Contact 1',
                            RecordtypeId = contact_agency,
                            AccountId = agencyList[0].Id
                            ),

                new Contact(LastName = 'Agency Test Contact 2',
                            RecordtypeId = contact_agency,
                            AccountId = agencyList[1].Id
                            )
            };

            insert contactList;

            //Creating Agency User
            User usr1=new User(FirstName='Marzia',
                               LastName = 'Rossi', 
                               Alias = 'mro666', 
                               Email = 'mrosskmans@deloitte.com', 
                               Username = 'agencyUser828@axa.com.masterdev', 
                               CommunityNickname = 'MarziRo', 
                               LanguageLocaleKey = 'en_US',
                               TimeZoneSidKey='Europe/Rome',
                               Agency_Code__c = '004610',
                               Nodes__c = 'DIF_004610',
                               Profileid = pVen,
                               LocaleSidKey='en_US',
                               EmailEncodingKey='ISO-8859-1',
                               ContactId = contactList[0].Id
                               );
            
            list<User> usrToIn = new list<User>();
            usrToIn.add(usr1);
            insert usrToIn;

            User usrAgent = [Select Id from User where Username='agencyUser828@axa.com.masterdev'];
            Group targetQueue = [SELECT DeveloperName,Id,Type  FROM Group WHERE Type = 'Queue' and DeveloperName = 'Coda_Agenzia_004610' limit 1];
            
            //Creating the Queue Member
            GroupMember queueMember = new GroupMember(GroupId = targetQueue.Id,
                                                    UserOrGroupId = usrAgent.Id 
                                                    );

            insert queueMember;
            system.debug ('******queueMember '+queueMember);

            //Creating the needed Custom Settings
            List<LeadAssignmentConfiguration__c> listCustSett = new List<LeadAssignmentConfiguration__c>
            {
                new LeadAssignmentConfiguration__c(Name='Last n days for Lead duplication',DaysLimit__c=7.0),
                new LeadAssignmentConfiguration__c(Name='Last n days for duplication M upload',DaysLimit__c = 7.0),
                new LeadAssignmentConfiguration__c(Name='Preventivo Impresa',Ranking__c = 'QUOTATORE CL',ASA__c = 4,Sub_ASA__c = 2),
                new LeadAssignmentConfiguration__c(Name='LimitAssignmentNumberToday',DaysLimit__c =10.0),
                new LeadAssignmentConfiguration__c(Name='LimitAssignmentNumberWeek',DaysLimit__c =40.0),
                new LeadAssignmentConfiguration__c(Name='Preventivo veloce',Ranking__c = 'QUOTATORE AUTO', ASA__c = 4, Sub_ASA__c = 2),
                new LeadAssignmentConfiguration__c(Name='Preventivo su misura', ASA__c = 4, Sub_ASA__c = 2)
            };

            insert listCustSett;


            MappingASA__c mapASA = new MappingASA__c( Name = '4',
                                                      ASA__c = 'Attività',
                                                      ASA_Description__c = '4 - Attività',
                                                      Codice_ASA__c = 4);
            insert mapASA;

            MappingSottoASA__c mapSubASA = new MappingSottoASA__c(  Name = '4.2',
                                                                    Codice_Sotto_ASA__c = 2,
                                                                    Sotto_ASA__c = 'ARTIGIANATO',
                                                                    Sotto_ASA_Description__c = '4.2 Artigianato');
            insert mapSubASA;

            Id assegnazioniDefaultRT = [Select Id from Recordtype Where Name = 'Auto' and sObjecttype='Assegnazioni__c'].Id;
            Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;

            List<Assegnazioni_Configuration__c> listAssegnazioniConfig = new List<Assegnazioni_Configuration__c>
            {
                new Assegnazioni_Configuration__c(Name='Default',  
                                                  Record_Type_ID__c = assegnazioniDefaultRT,
                                                  LimitAssignmentNumberToday__c = 10,
                                                  LimitAssignmentNumberWeek__c = 40),

                new Assegnazioni_Configuration__c(Name='QUOTATORE CL',  
                                                  Record_Type_ID__c = assegnazioniCLtRT,
                                                  LimitAssignmentNumberToday__c = 10,
                                                  LimitAssignmentNumberWeek__c = 40),

                new Assegnazioni_Configuration__c(Name='QUOTATORE AUTO',  
                                                  Record_Type_ID__c = assegnazioniDefaultRT,
                                                  LimitAssignmentNumberToday__c = 10,
                                                  LimitAssignmentNumberWeek__c = 40)

            };
            insert listAssegnazioniConfig;

            Id idUtenteTecnico = [SELECT Id FROM User WHERE Name = 'Utente Tecnico' LIMIT 1].Id;
            
            List<AAI_Code_Variables__c> customSettingAAIList = new List<AAI_Code_Variables__c>
            {
                new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID',
                                          Value__c =idUtenteTecnico),

                new AAI_Code_Variables__c(Name='LeadStatusEventError',
                                          Value__c ='Test'),

                new AAI_Code_Variables__c(Name='LeadStatusTaskError',
                                          Value__c ='Test')
            };
            insert customSettingAAIList;

            //Creating the Leads
            Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
            List<Lead> leadsForTest = new List<Lead>{

                new Lead(Salutation = '',
                        LastName = 'LeadTest',
                        FirstName = 'test',
                        Company = 'TestCompany',
                        Email = 'lead@mail.test',
                        Phone = '0333333333',
                        MobilePhone = '3333333333',
                        Fiscal_ID__c = '1234567890abcdez',
                        AAI_Partita_IVA__c = '12345678901'
                        ),

                new Lead(Salutation = '',
                        LastName = 'leadTest2',
                        FirstName = 'test',
                        Email = 'lead2@mail.test',
                        Fiscal_ID__c = '1234567890abcdez',
                        AAI_Partita_IVA__c = '12345678901',
                        LeadSource = 'Web',
                        Dettaglio__c='Salva quotazione',
                        Agency_Code__c = '000828',
                        Privacy_Terms__c= true,
                        Commercial_Activity_Consensus__c = true,
                        TECH_Company__c = 'AAI',
                        Phone='3386754890',
                        PostalCode='105',
                        RecordtypeId = RecordtypeAAI,
                        TECH_Send_Email_Notification__c = false,
                        Landing_Page__c = 'Preventivo Impresa'
                        ),

                new Lead(Salutation = '',
                        LastName = 'leadTest3',
                        FirstName = 'test',
                        Email = 'lead3@mail.test',
                        Fiscal_ID__c = '1234567890abclkj',
                        AAI_Partita_IVA__c = '12345678933',
                        LeadSource = 'Web',
                        Dettaglio__c='Salva quotazione',
                        Agency_Code__c = '000828',
                        Privacy_Terms__c= true,
                        Commercial_Activity_Consensus__c = true,
                        TECH_Company__c = 'AAI',
                        Phone='3386754890',
                        PostalCode='105',
                        RecordtypeId = RecordtypeAAI,
                        TECH_Send_Email_Notification__c = false,
                        Landing_Page__c = 'Siti Agenti'
                        )
            };
            insert leadsForTest;
        }
    }

    //Testing the creation of a Lead that does not have the Phone field populated
    @isTest static void test_method_1()
    {
        User usr1 = [Select Id from User where Username='agencyUser828@axa.com.masterdev'];
        Id NoPhoneGroupId = [select id from group where developername ='Coda_Web_Lead_senza_telefono'].Id;
        
        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {

            Lead leadWithoutPhone = new Lead(Salutation = '',
                                            LastName = 'leadWithoutPhone',
                                            FirstName = 'test',
                                            Email = 'lead@mail.test',
                                            Fiscal_ID__c = '1234567890abcdez',
                                            AAI_Partita_IVA__c = '12345678901',
                                            Agency_Code__c = '000828',
                                            LeadSource = 'Web',
                                            Landing_Page__c = 'Preventivo veloce',
                                            PostalCode = '00100',
                                            Dettaglio__c='Salva quotazione',
                                            Privacy_Terms__c= true,
                                            Commercial_Activity_Consensus__c = true,
                                            TECH_Company__c = 'AAI'
                                            );

            insert leadWithoutPhone;              
        }
        Test.stopTest();
        Lead leadWithoutPhone = [Select Id,OwnerId From Lead Where LastName = 'leadWithoutPhone'];
        Boolean canSee =[SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :usr1.Id AND RecordId = :leadWithoutPhone.Id].HasReadAccess;
        System.assertEquals(canSee,false);
        System.assertEquals(leadWithoutPhone.OwnerId,NoPhoneGroupId);
    }

    //Testing the creation of a Lead that does not have the Phone field populated
    @isTest static void test_list_without_with_phone()
    {
        User usr1 = [Select Id from User where Username='agencyUser828@axa.com.masterdev'];
        Id NoPhoneGroupId = [select id from group where developername ='Coda_Web_Lead_senza_telefono'].Id;
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        
        Test.startTest();

        List<Lead> testLead = new List<Lead>();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {

            Lead leadWithoutPhone = new Lead(Salutation = '',
                                            LastName = 'leadWithoutPhone',
                                            FirstName = 'test',
                                            Email = 'lead@mail.test',
                                            Fiscal_ID__c = '1234567890abcdez',
                                            AAI_Partita_IVA__c = '12345678901',
                                            Agency_Code__c = '000828',
                                            LeadSource = 'Web',
                                            Landing_Page__c = 'Preventivo veloce',
                                            PostalCode = '00100',
                                            Dettaglio__c='Salva quotazione',
                                            Privacy_Terms__c= true,
                                            Commercial_Activity_Consensus__c = true,
                                            TECH_Company__c = 'AAI'
                                            );

            insert leadWithoutPhone;  

            Lead leadWithPhone = new Lead(Salutation = '',
                                        LastName = 'leadTest4',
                                        FirstName = 'test',
                                        Email = 'lead4@mail.test',
                                        Fiscal_ID__c = '1234567890abcdez',
                                        AAI_Partita_IVA__c = '12345678901',
                                        Agency_Code__c = '000828',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Richiedi appuntamento',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Premio_annuo__c = 1,
                                        Landing_Page__c = 'Preventivo Impresa'
            );

            insert leadWithPhone; 

            testLead.add(leadWithoutPhone);
            testLead.add(leadWithPhone);
            
        }

        LeadAssignment.LeadsListsWrapper listWrapper = LeadAssignment.getLeadsWithoutWithPhone(testLead);

        Test.stopTest();
        
        Lead leadWithoutPhone = [Select Id,OwnerId From Lead Where LastName = 'leadWithoutPhone'];
        Lead leadWithPhone = [Select Id,OwnerId From Lead Where LastName = 'leadTest4'];
        
        System.assertEquals(leadWithoutPhone.Id,listWrapper.leadsList1.get(0).Id);
        System.assertEquals(leadWithPhone.Id,listWrapper.leadsList2.get(0).Id);
    }

    //Testing the creation of a Lead that does not have the Phone field populated
    @isTest 
    static void test_getWebVisualizzaQuotazioneLeads()
    {
        User usr1 = [Select Id from User where Username='agencyUser828@axa.com.masterdev'];
        Id NoPhoneGroupId = [select id from group where developername ='Coda_Web_Lead_senza_telefono'].Id;
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        
        Test.startTest();

        List<Lead> testLead = new List<Lead>();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {

            Lead lead1 = new Lead(Salutation = '',
                                            LastName = 'leadWithoutPhone',
                                            FirstName = 'test',
                                            Email = 'lead@mail.test',
                                            Fiscal_ID__c = '1234567890abcdez',
                                            AAI_Partita_IVA__c = '12345678901',
                                            Agency_Code__c = '000828',
                                            LeadSource = 'Web',
                                            Landing_Page__c = 'Preventivo veloce',
                                            PostalCode = '00100',
                                            Dettaglio__c='Visualizza quotazione',
                                            Privacy_Terms__c= true,
                                            Commercial_Activity_Consensus__c = true,
                                            TECH_Company__c = 'AAI',
                                            TECH_Massively_uploaded_web_lead__c = false
                                            );

            insert lead1;  

            Lead lead2 = new Lead(Salutation = '',
                                        LastName = 'leadTest4',
                                        FirstName = 'test',
                                        Email = 'lead4@mail.test',
                                        Fiscal_ID__c = '1234567890abcdez',
                                        AAI_Partita_IVA__c = '12345678901',
                                        Agency_Code__c = '000828',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Richiedi appuntamento',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Premio_annuo__c = 1,
                                        Landing_Page__c = 'Preventivo Impresa'
            );

            insert lead2; 

            testLead.add(lead1);
            testLead.add(lead2);
            
        }

        LeadAssignment.LeadsListsWrapper listWrapper = LeadAssignment.getWebVisualizzaQuotazioneLeads(testLead);

        Test.stopTest();
        
        Lead lead1 = [Select Id,OwnerId From Lead Where LastName = 'leadWithoutPhone'];
        Lead lead2 = [Select Id,OwnerId From Lead Where LastName = 'leadTest4'];
        
        System.assertEquals(lead1.Id,listWrapper.leadsList1.get(0).Id);
        System.assertEquals(lead2.Id,listWrapper.leadsList2.get(0).Id);
    }

    //Testing the creation of a Lead that does not have the Phone field populated
    @isTest 
    static void test_handleNoDataFoundAppointment()
    {
        User usr1 = [Select Id from User where Username='agencyUser828@axa.com.masterdev'];
        Id NoPhoneGroupId = [select id from group where developername ='Coda_Web_Lead_senza_telefono'].Id;
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        
        Test.startTest();

        List<Lead> testLead = new List<Lead>();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {

            Lead lead1 = new Lead(Salutation = '',
                                            LastName = 'leadWithoutPhone',
                                            FirstName = 'test',
                                            Email = 'lead@mail.test',
                                            Fiscal_ID__c = '1234567890abcdez',
                                            AAI_Partita_IVA__c = '12345678901',
                                            Agency_Code__c = '000828',
                                            LeadSource = 'Web',
                                            Landing_Page__c = 'Preventivo veloce',
                                            PostalCode = '00100',
                                            Dettaglio__c='Richiedi appuntamento',
                                            Privacy_Terms__c= true,
                                            Commercial_Activity_Consensus__c = true,
                                            TECH_Company__c = 'AAI',
                                            TECH_Massively_uploaded_web_lead__c = false
                                            );

            insert lead1;
            
        }

        Lead lead1 = [Select Id,Agency_Code__c,OwnerId,Ultima_data_di_riassegnazione__c,Numero_assegnazioni_eseguite__c,TECH_Send_Email_Notification__c,Agenzie_per_riassegnazione__c,Agenzie_per_riassegnazione_riordinata__c,Agenzie_gia_assegnate__c From Lead Where LastName = 'leadWithoutPhone'];

        LeadAssignment.handleNoDataFoundAppointment(lead1);

        Test.stopTest();
        
        //System.assertEquals('trieste,00100,Reggiolo',listWrapper.get('address'));
    }

    //Testing the creation of a Lead that does not have the Phone field populated
    @isTest static void test_getRichiediAppuntamento()
    {
        User usr1 = [Select Id from User where Username='agencyUser828@axa.com.masterdev'];
        Id NoPhoneGroupId = [select id from group where developername ='Coda_Web_Lead_senza_telefono'].Id;
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        
        Test.startTest();

        List<Lead> testLead = new List<Lead>();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {

            Lead lead1 = new Lead(Salutation = '',
                                            LastName = 'leadWithoutPhone',
                                            FirstName = 'test',
                                            Email = 'lead@mail.test',
                                            Fiscal_ID__c = '1234567890abcdez',
                                            AAI_Partita_IVA__c = '12345678901',
                                            Agency_Code__c = '',
                                            LeadSource = 'Web',
                                            Landing_Page__c = 'Preventivo veloce',
                                            PostalCode = '00100',
                                            Dettaglio__c='Richiedi appuntamento',
                                            Privacy_Terms__c= true,
                                            Commercial_Activity_Consensus__c = true,
                                            TECH_Company__c = 'AAI',
                                            TECH_Massively_uploaded_web_lead__c = false
                                            );

            insert lead1;  

            Lead lead2 = new Lead(Salutation = '',
                                        LastName = 'leadTest4',
                                        FirstName = 'test',
                                        Email = 'lead4@mail.test',
                                        Fiscal_ID__c = '1234567890abcdez',
                                        AAI_Partita_IVA__c = '12345678901',
                                        Agency_Code__c = '000828',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Richiedi appuntamento',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Premio_annuo__c = 1,
                                        Landing_Page__c = 'Preventivo Impresa'
            );

            insert lead2; 

            testLead.add(lead1);
            testLead.add(lead2);
            
        }

        LeadAssignment.LeadsListsWrapper listWrapper = LeadAssignment.getRichiediAppuntamento(testLead);

        Test.stopTest();
        
        Lead lead1 = [Select Id,OwnerId From Lead Where LastName = 'leadWithoutPhone'];
        Lead lead2 = [Select Id,OwnerId From Lead Where LastName = 'leadTest4'];
        
        System.assertEquals(lead1.Id,listWrapper.leadsList1.get(0).Id);
       // System.assertEquals(lead2.Id,listWrapper.leadsList2.get(0).Id);
    }
    
    //Testing the creation of a Salva quotazione Lead duplicated with another Lead in the same agency
    @isTest static void test_method_2() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {

            Lead leadDuplicatedWithLead = new Lead(Salutation = '',
                                                    LastName = 'leadTestMethodTwo',
                                                    FirstName = 'test',
                                                    Email = 'lead22@mail.test',
                                                    Fiscal_ID__c = '1234567890abcdez',
                                                    AAI_Partita_IVA__c = '12345678901',
                                                    Agency_Code__c = '000828',
                                                    LeadSource = 'Web',
                                                    Dettaglio__c='Salva quotazione',
                                                    Privacy_Terms__c= true,
                                                    Commercial_Activity_Consensus__c = true,
                                                    TECH_Company__c = 'AAI',
                                                    Phone='3386754890',
                                                    PostalCode='105',
                                                    RecordtypeId = RecordtypeAAI,
                                                    ASA__c = 'Auto',
                                                    Landing_Page__c = 'Preventivo su misura'
                                                );

            insert leadDuplicatedWithLead; 
        }

        Test.stopTest();
        Lead leadDuplicatedWithLead = [Select Id,Deduplication_Required__c From Lead Where Email = 'lead22@mail.test'];
        System.assertEquals(leadDuplicatedWithLead.Deduplication_Required__c,true);
    }

    //Testing the correct working of the deduplication flag
    @isTest static void test_method_3() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id IdB2C = [Select Id from Recordtype Where Name = 'B2C Client' and sObjecttype='Account'].Id;
        Id utenteTecnicoId = [SELECT Id FROM User WHERE Name ='Utente Tecnico'].Id; 

        Test.startTest();

        System.runAs(new User(Id=utenteTecnicoId))
        {

            Account AccWithPhone = new Account(Salutation = '',
                                                LastName = 'leadDuplicatedWithClient',
                                                FirstName = 'test',
                                                PersonEmail = 'lead31@mail.test',
                                                Fiscal_ID__c = '1234567890abcdez',
                                                AAI_Partita_IVA__c = '12345678901',
                                                Agency_Code__c = '000828',
                                                AccountSource = 'Web',
                                                TECH_Company__c = 'AAI',
                                                Phone='3386754890',
                                                PersonMailingPostalCode='105',
                                                RecordtypeId=IdB2C,
                                                Createddate = system.today()-1
                                                );

            insert AccWithPhone;  


            Lead leadDuplicatedWithClient = new Lead(Salutation = '',
                                                    LastName = 'leadDuplicatedWithClient',
                                                    FirstName = 'test',
                                                    Email = 'lead32@mail.test',
                                                    Fiscal_ID__c = '1234567890abcdez',
                                                    AAI_Partita_IVA__c = '12345678901',
                                                    Agency_Code__c = '000828',
                                                    LeadSource = 'Web',
                                                    Dettaglio__c='Richiedi appuntamento',
                                                    Privacy_Terms__c= true,
                                                    Commercial_Activity_Consensus__c = true,
                                                    TECH_Company__c = 'AAI',
                                                    Phone='3386754890',
                                                    PostalCode='105',                
                                                    RecordtypeId = RecordtypeAAI,
                                                    Landing_Page__c = 'Preventivo su misura'
                                                    );

            insert leadDuplicatedWithClient;
        }

        Test.stopTest();

        Lead leadDuplicatedWithClient = [Select Id,Agency_Code__c,OwnerId From Lead Where Email = 'lead32@mail.test'];

        System.assertEquals(leadDuplicatedWithClient.Agency_Code__c,'000828');
    }

    //Testing the success of Noovle's invocation with Richiedi Appuntamento
    @isTest static void test_method_4() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id utenteTecnicoId = [SELECT Id FROM User WHERE Name ='Utente Tecnico'].Id;

        Test.startTest();

        System.runAs(new User(Id=utenteTecnicoId))
        {
            Lead leadToAssign = new Lead(Salutation = '',
                                        LastName = 'leadTest4',
                                        FirstName = 'test',
                                        Email = 'lead4@mail.test',
                                        Fiscal_ID__c = '1234567890abcdez',
                                        AAI_Partita_IVA__c = '12345678901',
                                        Agency_Code__c = '000828',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Richiedi appuntamento',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Premio_annuo__c = 1,
                                        Landing_Page__c = 'Preventivo Impresa'
        );

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);
            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            insert leadToAssign;

        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Agenzie_per_riassegnazione_riordinata__c,Premio_annuo__c From Lead Where Email = 'lead4@mail.test'];
        Quotazione__c quotCreated = [SELECT Premio_annuo__c FROM Quotazione__c WHERE Lead__c =: leadToAssign.Id];

        Set<String> setAgenzieRiassegnazione = new Set<String>();
        for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
        {
            setAgenzieRiassegnazione.add(s);
        }
        
        System.assertEquals(leadToAssign.Agency_Code__c,'000828');
        System.assertEquals(leadToAssign.Agenzie_per_riassegnazione__c,leadToAssign.Agenzie_per_riassegnazione_riordinata__c);
        System.assertEquals(true, setAgenzieRiassegnazione.size()>1);
        System.assertEquals(true, setAgenzieRiassegnazione.contains('000828'));
        System.assertEquals(true, setAgenzieRiassegnazione.contains('004610'));
        System.assertEquals(leadToAssign.Premio_annuo__c, quotCreated.Premio_annuo__c);
    }

    //Testing the success of Noovle's invocation with Richiedi Appuntamento with subagency
    @isTest static void testLeadWithSubagency() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id utenteTecnicoId = [SELECT Id FROM User WHERE Name ='Utente Tecnico'].Id;

        Test.startTest();

        System.runAs(new User(Id=utenteTecnicoId))
        {
            Lead leadToAssign = new Lead(Salutation = '',
                                        LastName = 'leadTest4',
                                        FirstName = 'test',
                                        Email = 'lead4@mail.test',
                                        Fiscal_ID__c = '1234567890abcdez',
                                        AAI_Partita_IVA__c = '12345678901',
                                        Agency_Code__c = '000828',
                                        Codice_Sub_Agenzia__c = '000828000025',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Richiedi appuntamento',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Premio_annuo__c = 1,
                                        Landing_Page__c = 'Preventivo Impresa'
        );

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);
            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            insert leadToAssign;

        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,Tipologie_per_riassegnazione__c,OwnerId,Agenzie_per_riassegnazione_riordinata__c,Premio_annuo__c From Lead Where Email = 'lead4@mail.test'];
        Quotazione__c quotCreated = [SELECT Premio_annuo__c FROM Quotazione__c WHERE Lead__c =: leadToAssign.Id];

        System.debug(' ===> LEAD: ' + leadToAssign);

        Set<String> setAgenzieRiassegnazione = new Set<String>();
        for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
        {
            setAgenzieRiassegnazione.add(s);
        }

        Set<String> setTipologiaAgenzieRiassegnazione = new Set<String>();
        for(String s : (leadToAssign.Tipologie_per_riassegnazione__c).split(';'))
        {
            setTipologiaAgenzieRiassegnazione.add(s);
        }
        
        System.assertEquals(leadToAssign.Agency_Code__c,'000828');
        System.assertEquals(leadToAssign.Agenzie_per_riassegnazione__c,leadToAssign.Agenzie_per_riassegnazione_riordinata__c);
        System.assertEquals(true, setAgenzieRiassegnazione.size()>1);
        System.assertEquals(true, setTipologiaAgenzieRiassegnazione.size()>1);
        System.assertEquals(true, setAgenzieRiassegnazione.contains('000828'));
        System.assertEquals(true, setTipologiaAgenzieRiassegnazione.contains('000828000025'));
        System.assertEquals(true, setAgenzieRiassegnazione.contains('004610'));
        System.assertEquals(leadToAssign.Premio_annuo__c, quotCreated.Premio_annuo__c);
    }

    //Testing the success of Noovle's invocation with Salva Quotazione for an agency that hasn't still reached the daily limit cycle
    @isTest static void test_method_5() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;
        
        Id agencyId = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;

        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
            leadToAssign.Landing_Page__c = 'Preventivo Impresa';

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_1';
            Test.setMock(HttpCalloutMock.class, mockServer);

            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            leadToAssign.TECH_Send_Email_Notification__c = false;
            update leadToAssign;
        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId From Lead Where Email = 'lead2@mail.test'];
        Assegnazioni__c assegnazioniUpdated = [Select Id,Account__c,Numero_Assegnazioni__c,Recordtype.Name From Assegnazioni__c WHERE Account__c =: agencyId];


        Set<String> setAgenzieRiassegnazione = new Set<String>();
        if(String.isNotBlank(leadToAssign.Agenzie_per_riassegnazione__c))
        {
            for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
            {
                setAgenzieRiassegnazione.add(s);
            }
        }   
        
        System.assertEquals(leadToAssign.Agency_Code__c,'004610');
        System.assertEquals(true, setAgenzieRiassegnazione.size()==1);
        System.assertEquals(true, setAgenzieRiassegnazione.contains('004610'));
        System.assertEquals(assegnazioniUpdated.Numero_Assegnazioni__c, 1.0);
        System.assertEquals(assegnazioniUpdated.Recordtype.Name, 'CL');
    }

    //Testing the success of Noovle's invocation with Salva Quotazione for an agency that has not completed the first daily cycle 
    @isTest static void test_method_6() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;

        Id agencyId1 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 2' LIMIT 1].Id;
        Id agencyId2 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;
        
        //Create Assegnazioni
        List<Assegnazioni__c> assegnazioniList = new List<Assegnazioni__c>
        {
            new Assegnazioni__c(Account__c= agencyId1,
                                Numero_Assegnazioni__c=8.0,
                                RecordtypeId = assegnazioniCLtRT
                                ),

            new Assegnazioni__c(Account__c= agencyId2,
                                Numero_Assegnazioni__c=1.0,
                                RecordtypeId = assegnazioniCLtRT
                                )
        };

        insert assegnazioniList;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
            leadToAssign.Landing_Page__c = 'Preventivo Impresa';

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);
            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            leadToAssign.TECH_Send_Email_Notification__c = false;
            update leadToAssign;
        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Owner.Name,Agenzie_per_riassegnazione_riordinata__c From Lead Where Email = 'lead2@mail.test'];
        Assegnazioni__c assegnazioniUpdated1 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId1];
        Assegnazioni__c assegnazioniUpdated2 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId2];

        Set<String> setAgenzieRiassegnazione = new Set<String>();
        Set<String> setAgenzieRiassegnazioneRiord = new Set<String>();

        for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
        {
            setAgenzieRiassegnazione.add(s);
        }

        for(String s : (leadToAssign.Agenzie_per_riassegnazione_riordinata__c).split(';'))
        {
            setAgenzieRiassegnazioneRiord.add(s);
        }
        
        System.assertEquals(leadToAssign.Agency_Code__c,'000828');
        System.assertEquals(setAgenzieRiassegnazione, setAgenzieRiassegnazioneRiord);
        System.assertEquals(assegnazioniUpdated1.Numero_Assegnazioni__c, 9.0);
        System.assertEquals(assegnazioniUpdated2.Numero_Assegnazioni__c, 1.0); //unchanged
    }

    //Testing the success of Noovle's invocation with Salva Quotazione for an agency that has completed the first daily cycle 
    @isTest static void test_method_7() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;

        Id agencyId1 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 2' LIMIT 1].Id;
        Id agencyId2 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;
        
        //Create Assegnazioni
        List<Assegnazioni__c> assegnazioniList = new List<Assegnazioni__c>
        {
            new Assegnazioni__c(Account__c= agencyId1,
                                Numero_Assegnazioni__c=10.0,
                                RecordtypeId = assegnazioniCLtRT
                                )
        };

        insert assegnazioniList;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
            leadToAssign.Landing_Page__c = 'Preventivo Impresa';

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);
            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            leadToAssign.TECH_Send_Email_Notification__c = false;
            update leadToAssign;
        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Owner.Name,Agenzie_per_riassegnazione_riordinata__c From Lead Where Email = 'lead2@mail.test'];
        Assegnazioni__c assegnazioniUpdated1 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId1];
        Assegnazioni__c assegnazioniUpdated2 = [Select Id,Account__c,Numero_Assegnazioni__c,RecordType.Name From Assegnazioni__c Where Account__c =: agencyId2];

        Set<String> setAgenzieRiassegnazione = new Set<String>();
        List<String> listAgenzieRiassegnazione = new List<String>();
        Set<String> setAgenzieRiassegnazioneRiord = new Set<String>();
        List<String> listAgenzieRiassegnazioneRiord = new List<String>();

        for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
        {
            setAgenzieRiassegnazione.add(s);
            listAgenzieRiassegnazione.add(s);
        }

        for(String s : (leadToAssign.Agenzie_per_riassegnazione_riordinata__c).split(';'))
        {
            setAgenzieRiassegnazioneRiord.add(s);
            listAgenzieRiassegnazioneRiord.add(s);
        }
        
        System.assertEquals(leadToAssign.Agency_Code__c,'004610');

        System.assertEquals(true, setAgenzieRiassegnazione.size()==3);
        System.assertEquals(true, setAgenzieRiassegnazioneRiord.size()==3);

        System.assertEquals(true, setAgenzieRiassegnazione.contains('000828'));
        System.assertEquals(true, setAgenzieRiassegnazione.contains('004610'));
        System.assertEquals(true, setAgenzieRiassegnazione.contains('000127'));
        System.assertEquals(true, setAgenzieRiassegnazioneRiord.contains('000828'));
        System.assertEquals(true, setAgenzieRiassegnazioneRiord.contains('004610'));
        System.assertEquals(true, setAgenzieRiassegnazioneRiord.contains('000127'));

        System.assertEquals(listAgenzieRiassegnazione.get(0), listAgenzieRiassegnazioneRiord.get(1));
        System.assertEquals(listAgenzieRiassegnazioneRiord.get(0), listAgenzieRiassegnazione.get(2));
        System.assertEquals(assegnazioniUpdated1.Numero_Assegnazioni__c, 10.0);//unchanged
        System.assertEquals(assegnazioniUpdated2.Numero_Assegnazioni__c, 1.0); //created
        System.assertEquals(assegnazioniUpdated2.Recordtype.Name, 'CL'); //created
    }

    //Testing the success of Noovle's invocation with Salva Quotazione for an agency that has completed the first daily cycle for another Assegnazioni Record Type
    @isTest static void test_method_8() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;

        Id agencyId1 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 2' LIMIT 1].Id;
        Id agencyId2 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;
        
        //Create Assegnazioni
        List<Assegnazioni__c> assegnazioniList = new List<Assegnazioni__c>
        {
            new Assegnazioni__c(Account__c= agencyId1,
                                Numero_Assegnazioni__c=10.0,
                                RecordtypeId = assegnazioniCLtRT //Assegnazioni's RT: CL
                                )
        };

        insert assegnazioniList;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
            leadToAssign.Landing_Page__c = 'Preventivo veloce'; //This Landing Page will trigger the creation of an Assegnazioni Record of Auto RT

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);
            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            leadToAssign.TECH_Send_Email_Notification__c = false;
            update leadToAssign;
        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Owner.Name,Agenzie_per_riassegnazione_riordinata__c From Lead Where Email = 'lead2@mail.test'];
        List<Assegnazioni__c> assegnazioniUpdatedList = [Select Id,Account__c,Numero_Assegnazioni__c,Recordtype.Name From Assegnazioni__c Where Account__c =: agencyId1];

        Set<String> setAgenzieRiassegnazione = new Set<String>();
        Set<String> setAgenzieRiassegnazioneRiord = new Set<String>();

        for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
        {
            setAgenzieRiassegnazione.add(s);
        }

        for(String s : (leadToAssign.Agenzie_per_riassegnazione_riordinata__c).split(';'))
        {
            setAgenzieRiassegnazioneRiord.add(s);
        }
        
        System.assertEquals(leadToAssign.Agency_Code__c,'000828');
        System.assertEquals(setAgenzieRiassegnazione, setAgenzieRiassegnazioneRiord);
        System.assertEquals(assegnazioniUpdatedList.size(), 2);
        System.assertEquals(assegnazioniUpdatedList.get(0).Numero_Assegnazioni__c, 10.0);
        System.assertEquals(assegnazioniUpdatedList.get(1).Numero_Assegnazioni__c, 1.0);
        System.assertEquals(assegnazioniUpdatedList.get(1).Recordtype.Name, 'Auto');
    }

    //Testing the failure of Noovle's invocation
    @isTest static void test_method_9() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = new Lead(Salutation = '',
                                        LastName = 'leadTest9',
                                        FirstName = 'test',
                                        Email = 'lead9@mail.test',
                                        Fiscal_ID__c = '1234567890abcdez',
                                        AAI_Partita_IVA__c = '12345678901',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Salva quotazione',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Landing_Page__c = 'Preventivo Impresa'
                                        );

        LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
        mockServer.TestCase = 'testCase_3';
        Test.setMock(HttpCalloutMock.class, mockServer);

        LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

        insert leadToAssign;

        }

        Test.stopTest();
        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId From Lead Where Email = 'lead9@mail.test'];
        List<Assegnazioni__c> assegnazioniUpdatedList = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c];
        
        System.assertEquals(leadToAssign.Agency_Code__c, null); //not assigned
        System.assertEquals(assegnazioniUpdatedList.size(), 0); //No assignations created
    }

    //Testing the insert of a Lead that is duplicated with a single client and is immediatly assigned to its agency
    @isTest static void test_method_10() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id IdB2C = [Select Id from Recordtype Where Name = 'B2C Client' and sObjecttype='Account'].Id;
        Id agencyId = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;

        Account duplicatedAccount = new Account(FirstName = 'Duplicated',
                                                LastName = 'Account',
                                                RecordtypeId = IdB2C,
                                                AAI_Codice_fiscale__c = '1234567890ZEDABC',
                                                AAI_Agency_Reference_Code__c = '004610',
                                                PersonEmail = 'account@mail.test',
                                                Phone = '0333333333',
                                                PersonMobilePhone = '3333333333',
                                                AAI_Agency__c = agencyId,
                                                State__c = 'ATTIVO');

        insert duplicatedAccount;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadDuplicatedWithClient2 = new Lead(Salutation = '',
                                                    LastName = 'leadWithoutPhone',
                                                    FirstName = 'test',
                                                    Email = 'lead10@mail.test',
                                                    Fiscal_ID__c = '1234567890ZEDABC',
                                                    LeadSource = 'Web',
                                                    Dettaglio__c='Salva quotazione',
                                                    Privacy_Terms__c= true,
                                                    Commercial_Activity_Consensus__c = true,
                                                    TECH_Company__c = 'AAI',
                                                    Phone='3386754890',
                                                    PostalCode='105',
                                                    RecordtypeId = RecordtypeAAI,
                                                    Landing_Page__c = 'Preventivo Impresa'
                                                    );

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);

            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadDuplicatedWithClient2);

            leadDuplicatedWithClient2.TECH_Send_Email_Notification__c = false;

            insert leadDuplicatedWithClient2;
        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId From Lead Where Email = 'lead10@mail.test'];
        List<Assegnazioni__c> assegnazioniUpdatedList = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c];

        System.assertEquals(leadToAssign.Agency_Code__c,'004610');
        System.assertEquals(assegnazioniUpdatedList.size(), 2); //All assignations created anyway
    }

    //Testing the insert of a Lead that is duplicated with more than one client, all belonging to the same agency, and is immediatly assigned to their agency
    @isTest static void test_method_11() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id IdB2C = [Select Id from Recordtype Where Name = 'B2C Client' and sObjecttype='Account'].Id;
        Id agencyId = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;

        List<Account> duplicatedAccountList = new List<Account> {

            new Account(FirstName = 'Duplicated',
                        LastName = 'Account',
                        RecordtypeId = IdB2C,
                        AAI_Codice_fiscale__c = 'BB176176abcdefgh',
                        AAI_Agency_Reference_Code__c = '004610',
                        AAI_Agency__c = agencyId,
                        State__c = 'ATTIVO'),

            new Account(FirstName = 'Duplicated2',
                        LastName = 'Account2',
                        RecordtypeId = IdB2C,
                        AAI_Codice_fiscale__c = 'BB176176abcdefgh',
                        AAI_Agency_Reference_Code__c = '004610',
                        AAI_Agency__c = agencyId,
                        State__c = 'ATTIVO')
        };

        insert duplicatedAccountList;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = new Lead(Salutation = '',
                                        LastName = 'leadWithoutPhone',
                                        FirstName = 'test',
                                        Email = 'lead11@mail.test',
                                        Fiscal_ID__c = 'BB176176abcdefgh',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Salva quotazione',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Massively_uploaded_web_lead__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Landing_Page__c = 'Preventivo Impresa'
                                        );

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);
            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            leadToAssign.TECH_Send_Email_Notification__c = false;
            insert leadToAssign;
        }

        Test.stopTest();
        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId From Lead Where Email = 'lead11@mail.test'];
        List<Assegnazioni__c> assegnazioniUpdatedList = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c];

        System.assertEquals(leadToAssign.Agency_Code__c,'004610');
        System.assertEquals(assegnazioniUpdatedList.size(), 2); //created anyway
    }

    //Testing the insert of a Lead that is duplicated with more than one client, not belonging to the same agency
    @isTest static void test_method_12() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id IdB2C = [Select Id from Recordtype Where Name = 'B2C Client' and sObjecttype='Account'].Id;
        Id PolicyRTId = Schema.SObjectType.InsurancePolicy__c.getRecordTypeInfosByName().get('Non Auto').getRecordTypeId();

        Id agencyId1 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 2' LIMIT 1].Id;
        Id agencyId2 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;

        List<Account> duplicatedAccountList = new List<Account> {

            new Account(FirstName = 'Duplicated',
                        LastName = 'Account',
                        RecordtypeId = IdB2C,
                        AAI_Codice_fiscale__c = 'BB176176abcdefgh',
                        AAI_Agency_Reference_Code__c = '004610',
                        AAI_Agency__c = agencyId2,
                        State__c = 'ATTIVO'),

            new Account(FirstName = 'Duplicated2',
                        LastName = 'Account2',
                        RecordtypeId = IdB2C,
                        AAI_Codice_fiscale__c = 'BB176176abcdefgh',
                        AAI_Agency_Reference_Code__c = '000828',
                        AAI_Agency__c = agencyId1,
                        State__c = 'ATTIVO')
        };

        insert duplicatedAccountList;

        InsurancePolicy__c polizza = new InsurancePolicy__c(Name = '123123123',
                                                            CUID__c = duplicatedAccountList[0].Id,
                                                            Status__c = 'ATTIVO',
                                                            TECH_Company__c = 'AAI',
                                                            Line__c ='1',
                                                            Sub_ASA__c = 'b',
                                                            Last_Premium_Paid__c = 1,
                                                            RecordtypeId = PolicyRTId);
        insert polizza;

        List<InsurancePolicy__c> polizzaPostInsert = new List<InsurancePolicy__c>();
        polizzaPostInsert = [SELECT Id,Name,CUID__c,Line__c,Sub_ASA__c,Status__c,RecordTypeId,Last_Premium_Paid__c From InsurancePolicy__c];

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = new Lead(Salutation = '',
                                        LastName = 'leadWithoutPhone',
                                        FirstName = 'test',
                                        Email = 'lead12@mail.test',
                                        Fiscal_ID__c = 'BB176176abcdefgh',
                                        LeadSource = 'Web',
                                        Dettaglio__c='Salva quotazione',
                                        Privacy_Terms__c= true,
                                        Commercial_Activity_Consensus__c = true,
                                        TECH_Massively_uploaded_web_lead__c = true,
                                        TECH_Company__c = 'AAI',
                                        Phone='3386754890',
                                        PostalCode='105',
                                        RecordtypeId = RecordtypeAAI,
                                        Landing_Page__c = 'Preventivo Impresa'
        );

        LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
        mockServer.TestCase = 'testCase_2';
        Test.setMock(HttpCalloutMock.class, mockServer);    
        LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

        leadToAssign.TECH_Send_Email_Notification__c = false;
        insert leadToAssign;

        }

        Test.stopTest();
        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId From Lead Where Email = 'lead12@mail.test'];

        System.assertEquals(leadToAssign.Agency_Code__c,'000828');
    }

    //Testing the initial assignation with two agencies that have completed the first daily cycle and the first one has not completed the weekly cycle
    @isTest static void test_method_13() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;

        Id agencyId1 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 2' LIMIT 1].Id;
        Id agencyId2 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;
        
        //Create Assegnazioni
        List<Assegnazioni__c> assegnazioniList = new List<Assegnazioni__c>
        {
            new Assegnazioni__c(Account__c= agencyId1,
                                Numero_Assegnazioni__c=10.0,
                                RecordtypeId = assegnazioniCLtRT
                                ),

            new Assegnazioni__c(Account__c= agencyId2,
                                Numero_Assegnazioni__c=10.0,
                                RecordtypeId = assegnazioniCLtRT
                                )
        };

        insert assegnazioniList;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
            leadToAssign.Landing_Page__c = 'Preventivo Impresa';

            LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
            mockServer.TestCase = 'testCase_4';
            Test.setMock(HttpCalloutMock.class, mockServer);
            LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

            leadToAssign.TECH_Send_Email_Notification__c = false;
            update leadToAssign;
        }

        Test.stopTest();

        Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Owner.Name,Agenzie_per_riassegnazione_riordinata__c From Lead Where Email = 'lead2@mail.test'];
        Assegnazioni__c assegnazioniUpdated1 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId1];
        Assegnazioni__c assegnazioniUpdated2 = [Select Id,Account__c,Numero_Assegnazioni__c,RecordType.Name From Assegnazioni__c Where Account__c =: agencyId2];

        Set<String> setAgenzieRiassegnazione = new Set<String>();
        Set<String> setAgenzieRiassegnazioneRiord = new Set<String>();

        for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
        {
            setAgenzieRiassegnazione.add(s);
        }

        for(String s : (leadToAssign.Agenzie_per_riassegnazione_riordinata__c).split(';'))
        {
            setAgenzieRiassegnazioneRiord.add(s);
        }
        
        System.assertEquals(leadToAssign.Agency_Code__c,'000828');
        System.assertEquals(setAgenzieRiassegnazione, setAgenzieRiassegnazioneRiord);
        System.assertEquals(assegnazioniUpdated1.Numero_Assegnazioni__c, 11.0);
        System.assertEquals(assegnazioniUpdated2.Numero_Assegnazioni__c, 10.0); //unchanged
    }

    //Testing the initial assignation with two agencies that have completed the first daily cycle, but only the first one has completed the weekly cycle
    @isTest static void test_method_14() 
    {
        Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;
        Id agencyId1 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 2' LIMIT 1].Id;
        Id agencyId2 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;
        
        Datetime dt = System.now();
        String oggi = dt.format('EEEE');
        if(oggi != 'Monday') //Since the query that retrieves the assegnazioni in the current week, this test scenario can't work on monday since there cannot be an Assegnazioni record created the previous day
        {
            //Create Assegnazioni
            List<Assegnazioni__c> assegnazioniList = new List<Assegnazioni__c>
            {
                new Assegnazioni__c(Account__c= agencyId1,
                                    Numero_Assegnazioni__c=10.0,
                                    RecordtypeId = assegnazioniCLtRT
                                    ),

                new Assegnazioni__c(Account__c= agencyId2,
                                    Numero_Assegnazioni__c=10.0,
                                    RecordtypeId = assegnazioniCLtRT
                                    ),

                new Assegnazioni__c(Account__c= agencyId1,
                                    Numero_Assegnazioni__c=10.0,
                                    RecordtypeId = assegnazioniCLtRT,
                                    CreatedDate = system.today()-1
                                    ),
                
                new Assegnazioni__c(Account__c= agencyId1,
                                    Numero_Assegnazioni__c=10.0,
                                    RecordtypeId = assegnazioniCLtRT,
                                    CreatedDate = system.today()-1
                                    ),
                
                new Assegnazioni__c(Account__c= agencyId1,
                                    Numero_Assegnazioni__c=10.0,
                                    RecordtypeId = assegnazioniCLtRT,
                                    CreatedDate = system.today()-1
                                    )
            };

            insert assegnazioniList;

            Test.startTest();

            System.runAs(new User(Id=UserInfo.getUserId()))
            {
                Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
                leadToAssign.Landing_Page__c = 'Preventivo Impresa';

                LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
                mockServer.TestCase = 'testCase_4';
                Test.setMock(HttpCalloutMock.class, mockServer);
                LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

                leadToAssign.TECH_Send_Email_Notification__c = false;
                update leadToAssign;
            }

            Test.stopTest();

            Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Owner.Name,Agenzie_per_riassegnazione_riordinata__c From Lead Where Email = 'lead2@mail.test'];
            Assegnazioni__c assegnazioniUpdated1 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId1 AND CreatedDate = today];
            Assegnazioni__c assegnazioniUpdated2 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId2];

            Set<String> setAgenzieRiassegnazione = new Set<String>();
            List<String> listAgenzieRiassegnazione = new List<String>();
            Set<String> setAgenzieRiassegnazioneRiord = new Set<String>();
            List<String> listAgenzieRiassegnazioneRiord = new List<String>();

            for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
            {
                setAgenzieRiassegnazione.add(s);
                listAgenzieRiassegnazione.add(s);
            }

            for(String s : (leadToAssign.Agenzie_per_riassegnazione_riordinata__c).split(';'))
            {
                setAgenzieRiassegnazioneRiord.add(s);
                listAgenzieRiassegnazioneRiord.add(s);
            }
            
            System.assertEquals(leadToAssign.Agency_Code__c,'004610');

            System.assertEquals(true, setAgenzieRiassegnazione.size()==3);
            System.assertEquals(true, setAgenzieRiassegnazioneRiord.size()==3);

            System.assertEquals(true, setAgenzieRiassegnazione.contains('000828'));
            System.assertEquals(true, setAgenzieRiassegnazione.contains('004610'));
            System.assertEquals(true, setAgenzieRiassegnazione.contains('000127'));
            System.assertEquals(true, setAgenzieRiassegnazioneRiord.contains('000828'));
            System.assertEquals(true, setAgenzieRiassegnazioneRiord.contains('004610'));
            System.assertEquals(true, setAgenzieRiassegnazioneRiord.contains('000127'));

            System.assertEquals(listAgenzieRiassegnazione.get(0), listAgenzieRiassegnazioneRiord.get(1));
            System.assertEquals(listAgenzieRiassegnazioneRiord.get(0), listAgenzieRiassegnazione.get(2));
            System.assertEquals(assegnazioniUpdated1.Numero_Assegnazioni__c, 10.0);//unchanged
            System.assertEquals(assegnazioniUpdated2.Numero_Assegnazioni__c, 11.0); //+1
        }
    }

    //Testing the initial assignation with two agencies that have completed both the daily and weekly cycle
    @isTest static void test_method_15() 
    {
        Id assegnazioniCLtRT = [Select Id from Recordtype Where Name = 'CL' and sObjecttype='Assegnazioni__c'].Id;
        Id agencyId1 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 2' LIMIT 1].Id;
        Id agencyId2 = [SELECT Id FROM Account WHERE Name = 'Agency Test Account 1' LIMIT 1].Id;

        Datetime dt = System.now();
        String oggi = dt.format('EEEE');
        if(oggi != 'Monday')
        {
            List<Assegnazioni__c> assegnazioniList = new List<Assegnazioni__c>
            {
                
                new Assegnazioni__c(Account__c= agencyId1,
                                    Numero_Assegnazioni__c=30.0,
                                    RecordtypeId = assegnazioniCLtRT,
                                    CreatedDate = System.today()-1
                                    ),

                new Assegnazioni__c(Account__c= agencyId1,
                                    Numero_Assegnazioni__c=10.0,
                                    RecordtypeId = assegnazioniCLtRT
                                    ),

                new Assegnazioni__c(Account__c= agencyId2,
                                    Numero_Assegnazioni__c=30.0,
                                    RecordtypeId = assegnazioniCLtRT,
                                    CreatedDate = System.today()-1
                                    ),

                new Assegnazioni__c(Account__c= agencyId2,
                                    Numero_Assegnazioni__c=10.0,
                                    RecordtypeId = assegnazioniCLtRT
                                    )
            };

            insert assegnazioniList;

            Test.startTest();

            System.runAs(new User(Id=UserInfo.getUserId()))
            {
                Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
                leadToAssign.Landing_Page__c = 'Preventivo Impresa';

                LeadManagementWeb2017_MOCK_Test mockServer = new LeadManagementWeb2017_MOCK_Test();
                mockServer.TestCase = 'testCase_4';
                Test.setMock(HttpCalloutMock.class, mockServer);
                LeadAssignment.ResponseDTo requestOutcome = LeadAssignment.sendRequest(leadToAssign);

                leadToAssign.TECH_Send_Email_Notification__c = false;
                update leadToAssign;
            }

            Test.stopTest();

            Lead leadToAssign = [Select Id,Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Owner.Name,Agenzie_per_riassegnazione_riordinata__c From Lead Where Email = 'lead2@mail.test'];
            Assegnazioni__c assegnazioniUpdated1 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId1 AND CreatedDate = today];
            Assegnazioni__c assegnazioniUpdated2 = [Select Id,Account__c,Numero_Assegnazioni__c From Assegnazioni__c Where Account__c =: agencyId2 AND CreatedDate = today];

            Set<String> setAgenzieRiassegnazione = new Set<String>();
            Set<String> setAgenzieRiassegnazioneRiord = new Set<String>();

            for(String s : (leadToAssign.Agenzie_per_riassegnazione__c).split(';'))
            {
                setAgenzieRiassegnazione.add(s);
            }

            for(String s : (leadToAssign.Agenzie_per_riassegnazione_riordinata__c).split(';'))
            {
                setAgenzieRiassegnazioneRiord.add(s);
            }
            
            System.assertEquals(leadToAssign.Agency_Code__c,'000828');
            System.assertEquals(setAgenzieRiassegnazione, setAgenzieRiassegnazioneRiord);
            System.assertEquals(assegnazioniUpdated1.Numero_Assegnazioni__c, 11.0);
            System.assertEquals(assegnazioniUpdated2.Numero_Assegnazioni__c, 10.0); //unchanged
        }
    }

    //Testing the Lead Ranking Queueable
    @isTest static void test_method_16() 
    {
        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Lead leadToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c,Total_Noovle_callouts__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
            leadToAssign.Total_Noovle_callouts__c = 0;
            LeadRankingQueueable leadRanking = new LeadRankingQueueable(leadToAssign);

            ID jobID = System.enqueueJob(leadRanking);  
        }

        Test.stopTest();
    
        Lead leadToAssign = [Select Azioni_intraprese_sul_Lead__c From Lead Where Email = 'lead2@mail.test'];

        System.assertEquals(leadToAssign.Azioni_intraprese_sul_Lead__c.contains('Chiamata a Noovle fallita:'),true);
    }

    //Richiedi Appuntamento duplicated with a Salva quotazione
    /*@isTest static void test_method_17() 
    {
        Id RecordtypeAAI = [Select id from Recordtype where Name='Lead AXA Assicurazioni' and sObjecttype='Lead'].Id;
        Id utenteTecnicoId = [SELECT Id FROM User WHERE Name ='Utente Tecnico'].Id;

        Test.startTest();

        System.runAs(new User(Id=utenteTecnicoId))
        {
            //First Salva Quotazione Lead
            Lead leadSalvaQuotToAssign = [SELECT City, Street, Prodotto__c, Salutation, LastName, FirstName, Email, Fiscal_ID__c, AAI_Partita_IVA__c, LeadSource, Dettaglio__c, Privacy_Terms__c, Commercial_Activity_Consensus__c, TECH_Company__c, Phone, PostalCode, RecordtypeId, TECH_Send_Email_Notification__c, Landing_Page__c FROM Lead WHERE Email = 'lead2@mail.test' LIMIT 1];
            leadSalvaQuotToAssign.Landing_Page__c = 'Preventivo Impresa';

            LeadManagementWeb2017_MOCK_Test mockServer_1 = new LeadManagementWeb2017_MOCK_Test();
            mockServer_1.TestCase = 'testCase_2';
            Test.setMock(HttpCalloutMock.class, mockServer_1);
            LeadAssignment.ResponseDTo requestOutcome_1 = LeadAssignment.sendRequest(leadSalvaQuotToAssign);

            leadSalvaQuotToAssign.TECH_Send_Email_Notification__c = false;
            update leadSalvaQuotToAssign;

            Lead leadRichiediAppToAssign = new Lead(Salutation = '',
                                                    LastName = 'leadTest2',
                                                    FirstName = 'test',
                                                    Email = 'lead2@mail.test',
                                                    Fiscal_ID__c = '1234567890abcdez',
                                                    AAI_Partita_IVA__c = '12345678901',
                                                    LeadSource = 'Web',
                                                    Dettaglio__c='Richiedi appuntamento',
                                                    Agency_Code__c = '000828',
                                                    Privacy_Terms__c= true,
                                                    Commercial_Activity_Consensus__c = true,
                                                    TECH_Company__c = 'AAI',
                                                    Phone='3386754890',
                                                    PostalCode='105',
                                                    RecordtypeId = RecordtypeAAI,
                                                    TECH_Send_Email_Notification__c = false,
                                                    Landing_Page__c = 'Preventivo Impresa'
                                                    );

            LeadManagementWeb2017_MOCK_Test mockServer_2 = new LeadManagementWeb2017_MOCK_Test();
            mockServer_2.TestCase = 'testCase_2';
            Test.setMock(HttpCalloutMock.class, mockServer_2);
            LeadAssignment.ResponseDTo requestOutcome_2 = LeadAssignment.sendRequest(leadRichiediAppToAssign);

            insert leadRichiediAppToAssign;

        }

        Test.stopTest();

        List<Lead> leadsAssigned = [Select Id,Dettaglio__c, Agency_Code__c,Agenzie_per_riassegnazione__c,OwnerId,Agenzie_per_riassegnazione_riordinata__c,Premio_annuo__c From Lead Where Email = 'lead2@mail.test'];
        Lead leadRichiediAppAssigned = new Lead();
        Lead leadSalvaQuotAssigned = new Lead();

        for(Lead l : leadsAssigned)
        {
            if(l.Dettaglio__c == 'Richiedi appuntamento')
            {
                leadRichiediAppAssigned = l;
            }
            else
            {
                leadSalvaQuotAssigned = l;
            }
        }

        System.assertEquals(leadRichiediAppAssigned.Agency_Code__c,'000828');
        System.assertEquals(leadRichiediAppAssigned.Agenzie_per_riassegnazione__c,leadRichiediAppAssigned.Agenzie_per_riassegnazione_riordinata__c);

    }*/

    //Cannot create a Task for a Lead to be processed
    @isTest static void test_method_18() 
    {
        Id who = [SELECT Id FROM Lead WHERE Email = 'lead@mail.test' LIMIT 1].Id;
        Id taskRT = [Select id from Recordtype where Name='Generico' and sObjecttype='Task'].Id;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Task t = new Task(
                                Subject = 'Test',
                                RecordtypeId = taskRT,
                                OwnerId = UserInfo.getUserId(),
                                WhoId = who,
                                Priority = 'Normal',
                                Status = 'Open'
                            );
            try
            {
                insert t;
            }
            catch(Exception e)
            {
                List<Task> taskList = [SELECT Id FROM Task WHERE WhoId =: who];
                System.assertEquals(taskList.size(),0);
            }
        }
        Test.stopTest();
    }

    //Cannot create an Event for a Lead to be processed
    @isTest static void test_method_19() 
    {
        Id who = [SELECT Id FROM Lead WHERE Email = 'lead@mail.test' LIMIT 1].Id;
        Id taskE = [Select id from Recordtype where DeveloperName='AAI_Event' and sObjecttype='Event'].Id;

        Test.startTest();

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Event e = new Event(
                                Subject = 'Test',
                                RecordtypeId = taskE,
                                OwnerId = UserInfo.getUserId(),
                                WhoId = who,
                                StartDateTime = system.now(),
                                EndDateTime = system.now()+1
                            );
            try
            {
                insert e;
            }
            catch(Exception Ex)
            {
                List<Event> eventList = [SELECT Id FROM Event WHERE WhoId =: who];
                System.assertEquals(eventList.size(),0);
            }
        }
        Test.stopTest();
    }
}