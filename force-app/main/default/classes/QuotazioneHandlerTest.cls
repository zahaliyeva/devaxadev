@isTest
public class QuotazioneHandlerTest{

    public static Node__c prepareNode(string Name, string Parent, integer level){
        Node__c testNode= new Node__c();    
        testNode.Node_description__c='testdescription'+Name;
        testNode.Node_level__c=level;
        testNode.Node_unique_code__c=Name;
        testNode.Parent_node_unique_code__c='Parent';
        testNode.Tree_name__c='TEST_TREE';
        testNode.Management_type__c='TGest';
        testNode.Intermediary_type__c='TIntermediario';
        return testNode;
    }

    @testSetup static void setup() {

    AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    insert acv;
    
    IE_Configuration__c Integration_record = new IE_Configuration__c();
        Integration_record.Name = 'CIF_Integration_AccountEdit';
        Integration_record.Type__c = 'WebService';
        Integration_record.Direction__c = 'OUTBOUND';
        Integration_record.EndPoint__c = 'https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc';
        Integration_record.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record.Response_parser__c = 'IE_CIFparser_EditAccount';
        Integration_record.NameSpacePrefix1__c = 'soapenv';
        Integration_record.NameSpacePrefix2__c = 'crm';
        Integration_record.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record.NameSpaceUri2__c = 'http://crm.service.rgi.it/';
        insert Integration_record;
        
        IE_Configuration__c Integration_record_gettask = new IE_Configuration__c();
        Integration_record_gettask.Name = 'Integration_TaskSearch';
        Integration_record_gettask.Type__c = 'WebService';
        Integration_record_gettask.Direction__c = 'OUTBOUND';
        Integration_record_gettask.EndPoint__c = 'stop_https://mockbin.org/bin/5e282d3c-cce0-46d3-bd43-e718eb14ee5e'; 
        Integration_record_gettask.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_gettask.Response_parser__c = 'IE_Parser_SearcTaskDaol';
        Integration_record_gettask.NameSpacePrefix1__c = 'soapenv';
        Integration_record_gettask.NameSpacePrefix2__c = 'ws';
        Integration_record_gettask.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_gettask.NameSpaceUri2__c = 'http://rgi.it/WS_REOL_Service/';
        
        insert Integration_record_gettask;
        /** PURE IT Commento per rimuovere referenza di una classe commentata
        IE_Configuration__c Integration_record_getstati = new IE_Configuration__c();
        Integration_record_getstati.Name = 'Integration_getStati';
        Integration_record_getstati.Type__c = 'WebService';
        Integration_record_getstati.Direction__c = 'OUTBOUND';
        Integration_record_getstati.EndPoint__c = '__https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc'; 
        Integration_record_getstati.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_getstati.Response_parser__c = 'IE_CIFparser_GetStati';
        Integration_record_getstati.NameSpacePrefix1__c = 'soapenv';
        Integration_record_getstati.NameSpacePrefix2__c = 'bean';
        Integration_record_getstati.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_getstati.NameSpaceUri2__c = 'http://bean.services.jdna6ws.app.directw.it';
        insert Integration_record_getstati;
        PURE IT Comment closure */
        /** PURE IT Commento per rimuovere referenza di una classe commentata
        IE_Configuration__c Integration_record_getprov = new IE_Configuration__c();
        Integration_record_getprov.Name = 'Integration_getProvince';
        Integration_record_getprov.Type__c = 'WebService';
        Integration_record_getprov.Direction__c = 'OUTBOUND';
        Integration_record_getprov.EndPoint__c = '__https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc'; 
        Integration_record_getprov.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_getprov.Response_parser__c = 'IE_CIFparser_GetProvince';
        Integration_record_getprov.NameSpacePrefix1__c = 'soapenv';
        Integration_record_getprov.NameSpacePrefix2__c = 'bean';
        Integration_record_getprov.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_getprov.NameSpaceUri2__c = 'http://bean.services.jdna6ws.app.directw.it';
        insert Integration_record_getprov;
        PURE IT comment closure */
        
        /** PURE IT Commento per rimuovere referenza di una classe commentata  
        IE_Configuration__c Integration_record_getcomuni = new IE_Configuration__c();
        Integration_record_getcomuni.Name = 'Integration_getComuni';
        Integration_record_getcomuni.Type__c = 'WebService';
        Integration_record_getcomuni.Direction__c = 'OUTBOUND';
        Integration_record_getcomuni.EndPoint__c = '__https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc'; 
        Integration_record_getcomuni.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_getcomuni.Response_parser__c = 'IE_CIFparser_GetComuni';
        Integration_record_getcomuni.NameSpacePrefix1__c = 'soapenv';
        Integration_record_getcomuni.NameSpacePrefix2__c = 'bean';
        Integration_record_getcomuni.NameSpaceUri1__c = 'ttp://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_getcomuni.NameSpaceUri2__c = 'http://bean.services.jdna6ws.app.directw.it';
        insert Integration_record_getcomuni;   
        PURE IT Comment closure */     
    
    Date myDate2 = Date.newInstance(2019, 2, 17);
    
    
    Account myAccount = new Account();
        
        myAccount.NDG__c='0008280000001138';
        RecordType PF_RT = [SELECT Id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        myAccount.RecordTypeId = PF_RT.Id;
        myAccount.Salutation = 'Signora';
        myAccount.LastName = 'Rossi';
        myAccount.FirstName = 'Maria';
        myAccount.AAI_Codice_fiscale__c = '0000000000000000';
        myAccount.CIF_Marital_Status__c = 'Coniugato/a';
        myAccount.CIF_Marital_Status_code__c = '1';
        myAccount.Nodes__c = '000828;000828000033';
        myAccount.AAI_Agency_Reference_Code__c ='000828';
        myAccount.State__c ='ATTIVO';
        myAccount.CIF_Job__c ='Agricoltore';
        myAccount.AAI_Codice_fiscale__c = 'MSSGNN64P24L929I';
        myAccount.CIF_Phone__c ='012345678';
        myAccount.CIF_PersonMobilePhone__c ='023456678';
        myAccount.Fax = '345677891';
        myAccount.CIF_Work_phone__c= '012344444';
        myAccount.CIF_PersonEmail__c = 'mariarossi@email.com';
        myAccount.CIF_Work_email__c = 'test@libero6.it';
        myAccount.AnnualRevenue =  1112132;
        Database.insert(myAccount);



        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');

        //Create Agency
        Account agencyAccount = new Account(Name = 'Agency Test Account',
        RecordTypeId = account_agency,
        Agency_Code__c = '006345',
        Active__c = true);
        insert agencyAccount;
        
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
        RecordtypeId = contact_agency,
        AccountId = agencyAccount.Id);
        insert agencyContact;
        
        Opportunity Opp2 = new Opportunity(
            Name = 'MyOpp2',
            StageName = 'Open',
            AccountId = myAccount.id,
            CloseDate = myDate2
            );
        insert Opp2; 
        
        Contact myContact = new Contact();
        
        myContact.LastName = 'Serger';
        RecordType ContactRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2B_Contacts' Limit 1];
        myContact.RecordTypeId = ContactRT.Id;
        
        Database.insert(myContact);
    
    //fill custom setting MappingASA__c
        List <MappingASA__c> MappingASA = new List<MappingASA__c>();

        MappingASA__c mapASA = new MappingASA__c();
        mapASA.Name = '3';
        mapASA.ASA__c ='Famiglia';
        mapASA.Codice_ASA__c = 3;
        mapASA.ASA_Description__c ='3 - Famiglia';

        MappingASA.add(mapASA);

        MappingASA__c mapASAAuto = new MappingASA__c();
        mapASAAuto.Name = '1';
        mapASAAuto.ASA__c ='Auto';
        mapASAAuto.Codice_ASA__c = 3;
        mapASAAuto.ASA_Description__c ='1 - Auto';

        MappingASA.add(mapASAAuto);
        
        Database.insert(MappingASA);
        
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

        LeadAssignmentConfiguration__c fullquote = new LeadAssignmentConfiguration__c();
        fullquote.Name = 'Full Quote';
        fullquote.ASA__c = 1;

         configuration.add(fullquote);

        
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
          
        Database.insert(configuration);  
        
        
        List <AAI_Code_Variables__c> aaicodevariable  = new List<AAI_Code_Variables__c>();

        //fill custom setting AAI_Code_variables__c to build the DAOL link
        AAI_Code_Variables__c settinglink = new AAI_Code_Variables__c();
        settinglink.Name='AccountEdit_Folderlink';
        settinglink.Value__c='https://daol-pp.axa-italia.it/test';
         
        aaicodevariable.add(settinglink);

         
        AAI_Code_Variables__c leadstatus= new AAI_Code_Variables__c();
        leadstatus.Name='Status';
        leadstatus.Value__c='Appointment';

        aaicodevariable.add(leadstatus);
         
        Database.insert(aaicodevariable);

        //Prepare Nodes and Groups

        Node__c testNode1= new Node__c();
        Node__c testNode2= new Node__c();   
        Node__c testNode3= new Node__c();   
   
        testNode1=prepareNode('006345','z023',7);
        testNode2=prepareNode('00634500002','006345',8);
        testNode3=prepareNode('00634500003','00634500002',9);

        List<Node__c> testNodeList = new List<Node__c>();
        testNodeList.add(testNode1);
        testNodeList.add(testNode2);
        testNodeList.add(testNode3); 
        
        System.runAs(new user(id=UserInfo.GetuserId())) {

             List<Group> myGroups = new List<Group>();

        Group group1 = new Group(
            Name='DIF_'+'006345',
            DeveloperName='DIF_'+'006345'
        );

        myGroups.add(group1);

        Group group2 = new Group(
            Name='DIF_'+'00634500002',
            DeveloperName='DIF_'+'00634500002'
        );

        myGroups.add(group2);

        Group group3 = new Group(
            Name='DIF_'+'00634500003',
            DeveloperName='DIF_'+'00634500003'
        );

        myGroups.add(group3);
        
        insert(myGroups);
        
        insert testNodeList;

        NodeManagementAgency testNMA = new NodeManagementAgency();
        NodeManagement testNM = new NodeManagement();
        List<user> u = new List<user>();
        u = [SELECT id from User where Name LIKE '%D%' AND isActive=true];
        testNM.MapNodesToGroups(testNodeList);
        testNMA.UpsertAgencyAccounts(testNodeList);

       
    }
    
    }
    
    
    static testmethod void TestQuotazioneHandlerfromLead(){
    
    //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    //insert acv;
    
    //Create Lead
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
    
    //Create Quotazione
    Quotazione__c quot = new Quotazione__c(
            Name = 'QuotTest',
            Lead__c = ld.Id
            );
    insert quot;   
    
    //Modify lead
    
    update quot;
    delete quot;
    undelete quot;
    
   
  }
  
  static testmethod void TestQuotazioneHandlerfromLead2(){
     
    Test.startTest(); 
    //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    //insert acv;
    
    
    Account a = [SELECT Id, Name, Salutation FROM Account WHERE FirstName = 'Maria' LIMIT 1];
    Opportunity o = [SELECT Id, Name FROM Opportunity WHERE StageName = 'Open' LIMIT 1];
    
    
    
    //Create Lead
    Lead ld2 = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '',
            MobilePhone = '3333333333', 
            Landing_page__c = 'Confido',
            Postalcode = '20090',
            isConverted = true, 
            ConvertedOpportunityId = o.Id, 
            ConvertedAccountId = a.Id 
            );
    insert ld2;   
    
    ld2.Agency_Code__c = '000828';
    update(ld2);
    
    List<Lead> llist = new List<Lead>();
    llist.add(ld2);
    
    QuotationManagement.setAgencyCode(llist);
        
    //Create Quotazione
    Quotazione__c quot = new Quotazione__c(
            Name = 'QuotTest2',
            Lead__c = ld2.Id
            );
    insert quot;  

       
    
    //Modify lead
    
    update quot;
    delete quot;
    undelete quot;
    Test.stopTest();
    
   
  }
  
   static testmethod void TestQuotazioneHandlerfromLead3(){
     
    Test.startTest(); 
    //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    //insert acv;
    
    
    Account a = [SELECT Id, Name, Salutation FROM Account WHERE FirstName = 'Maria' LIMIT 1];
    Opportunity o = [SELECT Id, Name FROM Opportunity WHERE StageName = 'Open' LIMIT 1];
    
    
    
    //Create Lead
    Lead ld2 = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345',
            MobilePhone = '3333333333', 
            Landing_page__c = 'Confido',
            Postalcode = '20090',
            isConverted = true, 
            ConvertedOpportunityId = o.Id, 
            ConvertedAccountId = a.Id 
            );
    insert ld2;   
    
    ld2.Agency_Code__c = '000828';
    update(ld2);
    
    List<Lead> llist = new List<Lead>();
    llist.add(ld2);
    
    QuotationManagement.setAgencyCode(llist);
        
    //Create Quotazione
    Quotazione__c quot = new Quotazione__c(
            Name = 'QuotTest2',
            Lead__c = ld2.Id
            );
    insert quot;  

       
    
    //Modify lead
    
    update quot;
    delete quot;
    undelete quot;
    Test.stopTest();
    
   
  }
  
  
  static testmethod void TestQuotazioneHandlerfromLead4(){
     
    Test.startTest(); 
    //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    //insert acv;
    
     List<Lead> LeadToInsert = new List<Lead>();   
    
    
    //Create Lead
    Lead ld4 = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345',
            MobilePhone = '3333333333', 
            Landing_page__c = 'Full Quote',
            Postalcode = '20090',
            Prodotto__c = 'Nuova Protezione VAN'           
            );

    
    //Create Lead
    Lead ld5 = new Lead(
            LastName = 'LeadTest2',
            FirstName ='test2',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006346',
            MobilePhone = '3333333333', 
            Landing_page__c = 'Full Quote',
            Postalcode = '20090',
            Prodotto__c = 'Auto Protezione'           
            );


    //Create Lead
    Lead ld6 = new Lead(
            LastName = 'LeadTest3',
            FirstName ='test3',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006347',
            MobilePhone = '3333333333', 
            Landing_page__c = 'Full Quote',
            Postalcode = '20090',
            Prodotto__c = 'Protezione InMoto'           
            );


    //Create Lead
    Lead ld7 = new Lead(
            LastName = 'LeadTest3',
            FirstName ='test3',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006348',
            MobilePhone = '3333333333',
            Landing_page__c = 'Full Quote',
            Postalcode = '20090',
            Prodotto__c = 'Nuova Protezione Auto'           
            );

    LeadToInsert.add(ld4);
    LeadToInsert.add(ld5);
    LeadToInsert.add(ld6);
    LeadToInsert.add(ld7);

    Database.insert(LeadToInsert);

    Test.stopTest();
    
   
  }
  
   static testmethod void TestQuotazioneHandlerfromOpp(){
    
    //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    //insert acv;
    
    Date myDate = Date.newInstance(2019, 2, 17);
    
    Account a = [SELECT Id, Name FROM Account WHERE FirstName = 'Maria' LIMIT 1];
    
    //Create Lead
    Opportunity Opp = new Opportunity(
            Name = 'MyOpp',
            StageName = 'Open',
            AccountId = a.id,
            CloseDate = myDate
            );
    insert Opp;   
    
    //Create Quotazione
    Quotazione__c quot = new Quotazione__c(
            Name = 'QuotTest2',
            Opportunity__c = Opp.Id
            );
    insert quot;   
    
    //Modify lead
    
    update quot;
    delete quot;
    undelete quot;
    
   
  }

  static testmethod void TestQuotazioneHandlerfromOpp2(){
    Test.startTest();
    //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    //insert acv;
    
    Date myDate = Date.newInstance(2019, 2, 17);
    
    Account a = [SELECT Id, Name FROM Account WHERE FirstName = 'Maria' LIMIT 1];

    //Create Lead
    Lead ld4 = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            //Agency_Code__c = '006345',
            MobilePhone = '3333333333', 
            Landing_page__c = 'ConFido',
            Postalcode = '20090',
            isConverted = true,
            ConvertedAccountId = a.Id
            );
    insert ld4;
    
    //Create Lead
    Opportunity Opp = new Opportunity(
            Name = 'MyOpp',
            StageName = 'Open',
            AccountId = a.id,
            CloseDate = myDate, 
            TECH_LeadId__c = ld4.Id
            );
    insert Opp;   
    
   
   Test.stopTest();
    
   
  }
}