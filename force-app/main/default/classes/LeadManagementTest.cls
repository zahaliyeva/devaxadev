/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         LeadManagementTest
Description:   Test for the trigger of lead assignment
History

 15/07/2015     Dario Bovolenta    
----------------------------------------------------------------------------*/


@isTest
private class LeadManagementTest{

    static Id AgentProfileId= [Select Id from Profile where name = 'NFE - AAI - Vendite Avanzato'].Id;
    static User Agent = new User();
    static List<User> userAdmin = new List<User>();
    static Contact AgentContact = new Contact();
    static Id AccB2CRecTyp = [Select Id from Recordtype where Name='B2C Client'].id;
/*
    static
    {
        userAdmin = new List<User>{
                            new User(Username = 'testclassldmgmt2017@italy.AXA.com',
                             LastName = 'testuser',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test',
                             Email = 'test@test.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId()),        
                            new User(Username = 'testclassldmgmt20172@italy.AXA.com',
                             LastName = 'testuser2',
                             LanguageLocaleKey = 'it',
                             FirstName = 'test2',
                             Email = 'test2@test.com',
                             Alias = 'test2',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'it',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId())};
        
        insert userAdmin;


        AgentContact = new Contact(FirstName = 'Test',
                                    Lastname = 'McTesty',
                                    Email = System.now().millisecond() + 'test@test.com');
        system.runAs(userAdmin[0])
        {
            insert AgentContact;
        }

    }*/

    @testSetup static void setup() {


        userAdmin = new List<User>{
                            new User(Username = 'testclassldmgmt2017@italy.AXA.com',
                             LastName = 'testuser',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test',
                             Email = 'test@test.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId()),        
                            new User(Username = 'testclassldmgmt20172@italy.AXA.com',
                             LastName = 'testuser2',
                             LanguageLocaleKey = 'it',
                             FirstName = 'test2',
                             Email = 'test2@test.com',
                             Alias = 'test2',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'it',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId())};
        
        insert userAdmin;


        AgentContact = new Contact(FirstName = 'Test',
                                    Lastname = 'McTesty',
                                    Email = System.now().millisecond() + 'test@test.com');
        system.runAs(userAdmin[0])
        {
            insert AgentContact;
        }

      List<Account> Listacc = new list<Account>{
                                new Account(
                                FirstName = 'LeadTest',
                                LastName = 'Test',
                                AAI_Codice_Fiscale__c='123456789012345P',
                                RecordtypeId = AccB2CRecTyp,
                                PersonMailingPostalCode = '00155'),
                                new Account(
                                FirstName = 'LeadTest',
                                LastName = 'Test',
                                AAI_Codice_Fiscale__c='123456789012345R',
                                RecordtypeId = AccB2CRecTyp,
                                PersonMailingPostalCode = '00155')};                                
      insert Listacc;

              
     Lead ld = new Lead (
        FirstName = 'LeadTest0001',
        LastName = 'Test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Agency_Code__c = '666666',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        IsConverted = false,
        PostalCode='00155');
     insert ld; 
        
         //fill custom setting MappingASA__c
        MappingASA__c mapASA = new MappingASA__c();
        mapASA.Name = '3';
        mapASA.ASA__c ='Famiglia';
        mapASA.Codice_ASA__c = 3;
        mapASA.ASA_Description__c ='3 - Famiglia';
        
        Database.insert(mapASA);
        
        //fill custom setting MappingSottoASA__c
        MappingSottoASA__c mapSottoASA = new MappingSottoASA__c();
        mapSottoASA.Name = '3.1';
        mapSottoASA.Sotto_ASA__c ='Abitazione';
        mapSottoASA.Codice_Sotto_ASA__c = 1;
        mapSottoASA.Sotto_ASA_Description__c ='3.1 Abitazione';
        
        Database.insert(mapSottoASA);
        
       List <LeadAssignmentConfiguration__c> configuration = new List<LeadAssignmentConfiguration__c>();
        
        //fill custom setting  LeadAssignmentConfiguration__c
        LeadAssignmentConfiguration__c confido = new LeadAssignmentConfiguration__c();
        confido.Name = 'ConFido';
        confido.ASA__c = 3;
        confido.Sub_ASA__c = 1;
        
        configuration.add(confido);
        
        //fill custom setting  LeadAssignmentConfiguration__c
        LeadAssignmentConfiguration__c LastndaysforLeadduplication = new LeadAssignmentConfiguration__c();
        LastndaysforLeadduplication.Name = 'Last n days for Lead duplication';
        LastndaysforLeadduplication.DaysLimit__c = 7;
        
        configuration.add(LastndaysforLeadduplication);
        
        
         //fill custom setting  LeadAssignmentConfiguration__c
        LeadAssignmentConfiguration__c LastndaysforduplicationMupload = new LeadAssignmentConfiguration__c();
        LastndaysforduplicationMupload.Name = 'Last n days for duplication M upload';
        LastndaysforduplicationMupload.DaysLimit__c = 7;
        
        configuration.add(LastndaysforduplicationMupload );  
        
        //CAPOBIANCO_A 19/01/2018: SPRINT 59 -- START
        //fill custom setting  LeadAssignmentConfiguration__c
        LeadAssignmentConfiguration__c paginaProdotto = new LeadAssignmentConfiguration__c();
        paginaProdotto.Name = 'Pagina Prodotto AXA';
        paginaProdotto.ASA__c = 3;
        paginaProdotto.Sub_ASA__c = 1;
        paginaProdotto.Ranking__c = 'QUOTATORE RETAIL';
        paginaProdotto.Prodotto__c = 'Nuova Protezione Casa';
        configuration.add(paginaProdotto );  
        //CAPOBIANCO_A 19/01/2018: SPRINT 59 -- END

        Database.insert(configuration);  
    }

    static testMethod void CreateLead() {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; /*
        Test.startTest();
        
         

        Node__c FIRST = new Node__c();
        FIRST.Node_unique_code__c='6666';
        FIRST.Parent_node_unique_code__c='66';
        FIRST.Tree_Name__c='DIF';
        FIRST.Node_level__c=7;
        FIRST.Node_description__c='test'; 
        FIRST.Management_type__c='test';
        FIRST.Intermediary_type__c='test';
        insert FIRST;
        Test.stopTest();       */
//Select g.Type, g.Name,g.developername, g.Id, g.Email, g.DoesSendEmailToMembers, g.DoesIncludeBosses From Group g where g.type = 'Queue'
        
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345',
            MobilePhone = '3333333333', 
            Landing_page__c = 'Confido',
            Postalcode = '20090');
            insert ld;   
    
            
            
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c ='666666',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true);
        insert ag;
        
        Group g =new Group (Type = 'Queue',Name = 'Coda_Agenzia_666666',DeveloperName = 'Coda_Agenzia_666666');
        insert g;

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=g.Id);
            insert q;
            GroupMember gm = new groupMember (GroupId= g.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm; 
        }

        Test.startTest();
         
        Lead ld2 = new Lead(FirstName = 'Test', LastName = 'LeadTest',Email = 'lead@mail.test', Agency_Code__c ='666666',TECH_Company__c ='AAI',TECH_Send_Email_Notification__c = false,IsConverted = false,PostalCode='00155');
        insert ld2;
        Lead ld3 = new Lead(FirstName = 'Test', LastName = 'LeadTest',Email = 'lead@mail.test', landing_page__c ='ConFido',Agency_Code__c ='32c42c',TECH_Company__c ='AAI',LeadSource='External List');
        insert ld3;

      //  insert ld3;

      /* moved to test setup 
      List<Account> Listacc = new list<Account>{
                                new Account(
                                FirstName = 'LeadTest',
                                LastName = 'Test',
                                AAI_Codice_Fiscale__c='123456789012345P',
                                RecordtypeId = AccB2CRecTyp,
                                PersonMailingPostalCode = '00155'),
                                new Account(
                                FirstName = 'LeadTest',
                                LastName = 'Test',
                                AAI_Codice_Fiscale__c='123456789012345R',
                                RecordtypeId = AccB2CRecTyp,
                                PersonMailingPostalCode = '00155')};                                
      insert Listacc;

              
     Lead ld = new Lead (
        FirstName = 'LeadTest',
        LastName = 'Test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Agency_Code__c = '666666',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        IsConverted = false,
        PostalCode='00155');
     insert ld;  

      Lead ld5 = new Lead (
        FirstName = 'LeadTest',
        LastName = 'Test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Agency_Code__c = '666666',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        IsConverted = false,
        PostalCode='00155'); 


*/
      
    /* moved to other test method
     LeadManagement.verifyDuplicateLead(ld);
     ld.Fiscal_ID__c = '123456789012345P';
     update ld;   
     LeadManagement.verifyDuplicateLead(ld);*/
     

        Test.stopTest(); 
//insert ld5;
//LeadManagement.verifyDuplicateLead(ld5); 
    }
    static testMethod void verifyDuplicates1() {
        Test.startTest();
        Lead ld = [Select FirstName,LastName,Email,Phone,MobilePhone,Agency_Code__c,Provincia_di_nascita__c,Birth_Place__c,Gender__c,PostalCode,Landing_page__c,AAI_Partita_IVA__c,Fiscal_ID__c,Company from Lead where FirstName = 'LeadTest0001'];
        LeadManagement.verifyDuplicateLead(ld);
        ld.Fiscal_ID__c = '123456789012345P';
        update ld;   
        LeadManagement.verifyDuplicateLead(ld);
        Test.stopTest();
    }

    static testMethod void verifyDuplicates2() {
        Test.startTest();
        
        Lead ld5 = new Lead (
        FirstName = 'LeadTest0005',
        LastName = 'Test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Agency_Code__c = '666666',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        IsConverted = false,
        PostalCode='00155'); 

       insert ld5;
       Test.stopTest();

        LeadManagement.verifyDuplicateLead(ld5);
    }

    //CAPOBIANCO_A 19/01/2018: SPRINT 59 - START
    static testMethod void verifyDuplicates3() {
        Test.startTest();
        
        Lead ld6 = new Lead (
        FirstName = 'LeadTest0005',
        LastName = 'Test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Agency_Code__c = '666666',
        Provincia_di_nascita__c = 'MI',
        AAI_Partita_IVA__c = '12345678911',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        Landing_page__c = 'Pagina Prodotto AXA',
        Prodotto__c = 'Nuova Protezione Casa',
        Company = 'Beppola',
        IsConverted = false,
        PostalCode='00155'); 

       insert ld6;
       Test.stopTest();

        LeadManagement.verifyDuplicateLead(ld6);
    }

    static testMethod void verifyDuplicates4() {
        Test.startTest();
        
        Lead ld7 = new Lead (
        FirstName = 'LeadTest0005',
        LastName = 'Test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Agency_Code__c = '666666',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        Landing_page__c = 'Pagina Prodotto AXA',
        Prodotto__c = 'Nuova Protezione Casa',
        Company = 'Beppola',
        IsConverted = false,
        PostalCode='00155'); 

       insert ld7;
       Test.stopTest();

        LeadManagement.verifyDuplicateLead(ld7);
    }
    //CAPOBIANCO_A 19/01/2018: SPRINT 59 - END
}