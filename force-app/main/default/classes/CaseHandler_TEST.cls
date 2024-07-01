@isTest
private class CaseHandler_TEST
{
    
    
    static List<MPS_Code_Variables__c> Mpcv; 
    static list <Configurazione_SLA_Case__c> CSLAList;
    static Stop_Status__c StopS;
    static CaseCategoryToCloseTask__c CCCT;
    static Account a;
    static Account a1;
    static case c;
    static Long_Term_Management_Alerts__c ltma;
    static Long_Term_Management_Alerts__c ltma1;
    static Amministrazione_Chiusura_Automatica_Case__c acac;
    static map<String,Id> acc_developerIdMap= AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
    static map<String,Id> cas_developerIdMap= AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
    static Configurazione_attivita_dispositive__c confattd;
    static user userAdmin2;
    static user userAdmin;
    
    static
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        //OAVERSANO 12/07/2018: Close the loop ICF -- START
        List<MPS_Code_Variables__c> settingsList = new List<MPS_Code_Variables__c>();
        MPS_Code_Variables__c setting = new MPS_Code_Variables__c();
        setting.Name = 'LightningAssociateAgentToCaseTask';
        setting.Value__c = 'Close the loop';
        settingsList.add(setting);
        MPS_Code_Variables__c setting2 = new MPS_Code_Variables__c();
        setting2.Name = 'CaseManagementAgentTaskProfile';
        setting2.Value__c = 'NFE - AAI - Vendite Avanzato;NFE - AAI - Vendite Base';
        settingsList.add(setting2);
        
        //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- START
        MPS_Code_Variables__c setting3 = new MPS_Code_Variables__c();
        setting3.Name = 'RecordTypeAssistenzaAgenti';
        setting3.Value__c = 'Assistenza_Agenti;';
        settingsList.add(setting3);
        MPS_Code_Variables__c setting4 = new MPS_Code_Variables__c();
        setting4.Name = 'MilestoneTrackerVisible99H';
        setting4.Value__c = 'true';
        settingsList.add(setting4);
        //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- END
        insert settingsList;
        //OAVERSANO 12/07/2018: Close the loop ICF -- END
        Mpcv = new List<MPS_Code_Variables__c>{
            new MPS_Code_Variables__c(Name='GDPR_Category',Value__c='GDPR'),
                new MPS_Code_Variables__c(Name='Entitlement GDPR',Value__c='Gestione SLA GDPR Smart Center',SLAmax__c=720,SLAmin__c=480),
                new MPS_Code_Variables__c(Name='Entitlement',Value__c='Gestione SLA SmartCenter'),
                /*new MPS_Code_Variables__c(Name='LightningAssociateAgentToCaseTask',Value__c='test1;test2;'),
new MPS_Code_Variables__c(Name='CaseManagementAgentTaskProfile',Value__c='test1;test2;'),*/
                new MPS_Code_Variables__c(Name='DoNotCopyEmail',Value__c='test1;test2;')
                
                };
                    insert Mpcv;
        
        CSLAList = new list<Configurazione_SLA_Case__c>{
            new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL'),
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta di accesso',Case_Origin__c='Email',Case_Record_Type__c='Motor',SLA__c=720,SLA_for_MPS_One_Customers__c=720,SLA_for_Private_Customers__c=720,Customer_Service_Type__c='All'),
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta di portabilità',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=380,SLA_for_MPS_One_Customers__c=380,SLA_for_Private_Customers__c=380,Customer_Service_Type__c='All'),
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta revoca',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=100,SLA_for_MPS_One_Customers__c=100,SLA_for_Private_Customers__c=100,Customer_Service_Type__c='All')
                
                };
                    insert CSLAList; 
        
        LTMA =  new Long_Term_Management_Alerts__c(Configurazione_SLA_Case__c=CSLAList[0].id,Days_number_until_first_alert__c=1,Days_number_until_second_alert__c=2,Days_number_until_third_alert__c=3,Rule_Active__c=true,Caller__c='Customer');
        insert LTMA;
        LTMA1 =  new Long_Term_Management_Alerts__c(Configurazione_SLA_Case__c=CSLAList[1].id,Days_number_until_first_alert__c=1,Days_number_until_second_alert__c=2,Days_number_until_third_alert__c=3,Rule_Active__c=true,Caller__c='Customer');
        insert LTMA1;       
        
        StopS = new Stop_Status__c(Object_Type__c='Case',Name='Pending');
        insert StopS;
        
        CCCT = new CaseCategoryToCloseTask__c(Name='N1',Category__c='Duplicati polizza di risparmio',SubCategory__c='Altro');
        Insert CCCT;
        
        acac = new Amministrazione_Chiusura_Automatica_Case__c(Configurazione_SLA_Case__c=CSLAList[0].id,Days_number_until_first_alert__c=1,Days_number_until_automatic_closure__c=2,Rule_Active__c=true,Caller__c='Customer');
        insert acac;
        Account a = new Account(FirstName='Mario',LastName='test',CIF_PersonEmail__c='test@test.com', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccB2C));
        
        insert a;
        Account a1 = new Account(FirstName='Mario',LastName='test_2',PersonEmail = 'test2@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;/*
Case c = new Case(Complainant__c='Customer',Status = 'Open',Phone_Call_Ids__c='78384',Origin='Phone',Accountid=a.id,Category__c='Duplicati polizza di risparmio',SubCategory__c='Altro',Distribution_Network__c='BNL');
insert c;
List<Task> TasKlst = new List<Task>{
new Task(WhatID = c.id,Subject='Sample Task1',Priority='Normal',HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice',Status='In progress'),
new Task(WhatID = c.id,Subject='Sample Task1',Priority='Normal',HierarchyLevel1__c='GDPR',HierarchyLevel2__c='GDPR1',HierarchyLevel3__c='GDPR2',Status='Open')

};

insert TasKlst; */
        
        confattd = new Configurazione_attivita_dispositive__c(Name='001',Category__c='GDPR',SubCategory__c='Richiesta di accesso',Days_until_verification__c=1);
        insert confattd;
        userAdmin = new User(Username = 'testclassAP01@test.com',
                             LastName = 'testuser',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test',
                             Email = 'test@test.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             HierarchyLevel1__c = 'Underwriting & Portfolio Monitoring',
                             HierarchyLevel2MP__c = 'COMMERCIAL LINE',
                             HierarchyLevel3MP__c = 'Pre-sales Advice',
                             ProfileId = AP_Constants.getProfileAdminId(),
                             ByPassAT__c='AP06');
        
        insert userAdmin;
        
        userAdmin2 = new User(Username = 'testclass2AP01@test.com',
                              LastName = 'testuser2',
                              LanguageLocaleKey = 'it',
                              FirstName = 'test2',
                              Email = 'test2@test.com',
                              Alias = 'test2',
                              TimeZoneSidKey = 'Europe/Dublin',
                              LocaleSidKey = 'it',
                              EmailEncodingKey = 'UTF-8',
                              HierarchyLevel1__c = 'SAVINGS',
                              HierarchyLevel2MP__c = 'Savings Emissioni',
                              HierarchyLevel3MP__c = 'Savings Emissioni',
                              ProfileId = AP_Constants.getProfileAdminId(),
                              ByPassAT__c='AP06');
        
        insert userAdmin2;
        
        
    }
    
    
    /**static testmethod void TestCase() 
    {
        Account a = new Account(FirstName='Mario',LastName='test',CIF_PersonEmail__c='test@test.com', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccB2C));
        
        insert a;
        Account a1 = new Account(FirstName='Mario',LastName='test_2',PersonEmail = 'test2@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        Case c = new Case(Complainant__c='Customer',Status = 'Open',Phone_Call_Ids__c='78384',Origin='Phone',Accountid=a.id,Category__c='Duplicati polizza di risparmio',SubCategory__c='Altro',Distribution_Network__c='BNL');
        insert c;
        //Case c = [Select Id from Case where Category__c='Duplicati polizza di risparmio'];
       // List<Account> AList = [Select id from Account where LastName='test_2'];
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        c.Origin = 'Email';
        //c.Status = 'Pending';
        c.Status = 'Pending';
        update c;
        c.Category__c='GDPR';
        C.SubCategory__c='Richiesta di revoca';
        C.Data_ricezione_richiesta_dpo__c = system.today()-20;
        update c;
        c.AccountId = a1.id;
        update c;
        c.status='Delegated';
        update c;
        c.status = 'Closed';
        update c;
        
        
        test.stoptest();
    } **/
    
        static testmethod void TestCase0() 
    {
        Account a = new Account(FirstName='Mario',LastName='test',CIF_PersonEmail__c='test@test.com', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccB2C));
        Account a1 = new Account(FirstName='Mario',LastName='test_2',PersonEmail = 'test2@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        List<Account> accounts = new List<Account>();
        accounts.add(a);
        accounts.add(a1);
        insert accounts;
        Case c = new Case(All_Tasks_Close_Date__c = system.today() - 1,Complainant__c='Customer',Status = 'Open',Phone_Call_Ids__c='78384',Origin='My AXA Area Preventivi',Accountid=a.id,Category__c='Duplicati polizza di risparmio',SubCategory__c='Altro',Distribution_Network__c='BNL');
        insert c;
        //Case c = [Select Id from Case where Category__c='Duplicati polizza di risparmio'];
       // List<Account> AList = [Select id from Account where LastName='test_2'];
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        c.Origin = 'Email';
        //c.Status = 'Pending';
        c.Status = 'Pending';
        update c;
        c.Category__c='GDPR';
        C.SubCategory__c='Richiesta di revoca';
        C.Data_ricezione_richiesta_dpo__c = system.today()-20;
        c.Origin = 'Chat';
        c.Phone_Call_Ids__c = 'test';
        c.SLAHours__c = 0;
        c.Case_sollecitato__c = true;
        c.All_Tasks_Close_Date__c = system.today();
        c.First_Long_Term_Management_Alert_DT__c =  system.today();
        update c;
        c.AccountId = a1.id;
        update c;
        c.status='Delegated';
        update c;
        c.status = 'Closed';
        update c;
        
        
        test.stoptest();
    }
    
            static testmethod void TestCase() 
    {
        Account a = new Account(FirstName='Mario',LastName='test',CIF_PersonEmail__c='test@test.com', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccB2C));
        Account a1 = new Account(FirstName='Mario',LastName='test_2',PersonEmail = 'test2@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        List<Account> accounts = new List<Account>();
        accounts.add(a);
        accounts.add(a1);
        insert accounts;
        Case c = new Case(Complainant__c='Customer',Status = 'Open',Phone_Call_Ids__c='78384',Origin='Phone',Accountid=a.id,Category__c='Duplicati polizza di risparmio',SubCategory__c='Altro',Distribution_Network__c='BNL');
        insert c;
        //Case c = [Select Id from Case where Category__c='Duplicati polizza di risparmio'];
       // List<Account> AList = [Select id from Account where LastName='test_2'];
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        c.Origin = 'Email';
        //c.Status = 'Pending';
        c.Status = 'Pending';
        update c;
        c.Category__c='GDPR';
        C.SubCategory__c='Richiesta di revoca';
        C.Data_ricezione_richiesta_dpo__c = system.today()-20;
        update c;
        c.AccountId = a1.id;
        update c;
        c.status='Delegated';
        update c;
        c.status = 'Closed';
        update c;
        
        
        test.stoptest();
    }
    
    static testmethod void TestCase2()
    {
        test.starttest();
        Account a = new Account(FirstName='Mario',LastName='test');
        insert a;
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Status = 'Reopened',Origin='Email',SuppliedEmail='webmail@test.it',Accountid=a.id,Category__c='Duplicati polizza di risparmio',SubCategory__c='Altro',Distribution_Network__c='BNL');
        insert c;
        
        
        
        
        c.status = 'Closed';
        update c;
        
        c.Status ='Reopened';
        update c;
        test.stoptest();
        
        
    }
    
    static testmethod void TestCase3()
    {
        
        Account a1 = new Account(FirstName='Mario',LastName='test_3',PersonEmail = 'test3@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        List<Account> AList = [Select id from Account where LastName='test_3'];
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Status = 'Pending',Origin='Email',SuppliedEmail='webmail@test.it',Accountid=AList[0].id,Category__c='Duplicati polizza di risparmio',SubCategory__c='Altro',Distribution_Network__c='BNL');
        insert c;
        test.starttest();
        c.Status ='Delegated';
        update c;
        
        c.Feedback_Provided_to_Customer__c = true;
        c.status = 'Assigned';
        update c;
        //c.status='R'
        test.stoptest();
        
        
    }  
    
    static testmethod void TestCase4()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_4',PersonEmail = 'test4@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        List<Account> AList = [Select id from Account where LastName='test_4'];
        
        Case c = new Case(ownerid=userAdmin.id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status = 'Open',Origin='Email',SuppliedEmail='webmail@test.it',Accountid=AList[0].id,Category__c='GDPR',SubCategory__c='Richiesta revoca',Distribution_Network__c='BNL');
        insert c;
        
        c.TECH_eKomi_comment__c ='113221324432';
        
        
        c.status = 'Pending';
        update c;
        c.ownerid= userAdmin2.id;
        update c;
        //c.Status ='Closed';
        //update c;
        //c.status='R'
        test.stoptest();
        
        
    }    
    
    static testmethod void TestCase5()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_5',PersonEmail = 'test5@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        
        List<Account> AList = [Select id from Account where LastName='test_5'];
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status = 'Open',Origin='Email',SuppliedEmail='webmail@test.it',Accountid=AList[0].id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;
        
        
        
        
        c.status = 'Delegated';
        update c;
        
        c.Status ='Closed';
        update c;
        //c.status='R'
        test.stoptest();
        
        
    }    
    
    static testmethod void TestCase6()
    {
        
        
        Account a = new Account(FirstName='Mario',LastName='test6',PersonEmail='test6@test.com', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        
        insert a;
        
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status = 'Open',Origin='Email',SuppliedEmail='webmail@test.it',Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;
        test.starttest();
        c.AgentName__c =a.id;
        update c;
        
        
        c.status = AP_Constants.caseStatusVerificaAttAntiRic;
        update c;
        
        c.Status =AP_Constants.caseStatusInviataRaccomandata;
        update c;
        // c.Status = AP_Constants.caseStatusAttivitaDispositive;
        // update c;
        //c.status='R'
        test.stoptest();
        
        
    }   
    /*
static testmethod void TestCase7()
{
test.starttest();

Account a = new Account(FirstName='Mario',LastName='test',PersonEmail='test@test.com', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));

insert a;

Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today(),NextStatusDate__c=system.today()+30,Status = 'Open',Origin='Webform pubblico',SuppliedEmail='webmail@test.it',Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
insert c;

c.AgentName__c =a.id;
update c;
c.Phone_Call_Ids__c='78384';
update c;

c.status = AP_Constants.caseStatusVerificaAttAntiRic;
update c;

c.Status =AP_Constants.caseStatusInviataRaccomandata;
update c;
// c.Status = AP_Constants.caseStatusAttivitaDispositive;
//update c;
//c.status='R'
test.stoptest();


}     */  
    
    
    
    //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- START
    static testmethod void TestCase8()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_8',PersonEmail = 'test8@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Status =AP_Constants.caseStatusDelegated,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Status =AP_Constants.caseStatusReopened;
        update c;
    }  
    static testmethod void TestCase9()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_9',PersonEmail = 'test9@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusDelegated,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Status =AP_Constants.caseStatusPending;
        update c;
    } 
    /* static testmethod void TestCase10()
{
Account a1 = new Account(FirstName='Mario',LastName='test_2',PersonEmail = 'test2@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
insert a1;
test.starttest();
ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusDelegated,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
insert c;     
test.stoptest();


c.Status =AP_Constants.caseStatusPending;
update c;
} */
    static testmethod void TestCase11()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_11',PersonEmail = 'test11@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Status =AP_Constants.caseStatusDelegated;
        update c;
    } 
    static testmethod void TestCase12()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_12',PersonEmail = 'test12@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Status = AP_Constants.caseStatusVerificaAttAntiRic;
        update c;
    } 
    static testmethod void TestCase13()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_13',PersonEmail = 'test13@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Status = AP_Constants.caseStatusClosed;
        update c;
    } 
    
    static testmethod void TestCase14()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_4',PersonEmail = 'test4@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(AgentName__c=a1.Id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        Account a2 = new Account(FirstName='Mari1',LastName='test_21',PersonEmail = 'test21@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a2;
        c.AgentName__c=a2.Id;
        c.Accountid=a2.id;
        update c;
    } 
    static testmethod void TestCase15()
    {
        
        Account a1 = new Account(FirstName='Mario',LastName='test_15',PersonEmail = 'test15@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a1;
        test.starttest();
        Case c;
        system.runAs(userAdmin)
        {
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            c = new Case(AgentName__c=a1.Id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
            insert c;     
            test.stoptest();
        }    
        Account a2 = new Account(FirstName='Mari1',LastName='test_225',PersonEmail = 'test225@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a2;
        c.Feedback_Provided_to_Customer__c = true;
        c.OwnerId=userAdmin2.id;
        update c;
    } 
    static testmethod void TestCase16()
    {
        
        Account a1 = new Account(FirstName='Mario',LastName='test_16',PersonEmail = 'test16@test.it',Additional_Email__c='test@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a1;
        test.starttest();
        Case c;
        system.runAs(userAdmin)
        {
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            c = new Case(AgentName__c=a1.Id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
            insert c;     
            test.stoptest();
        }    
        Account a2 = new Account(FirstName='Mari1',LastName='test_216',PersonEmail = 'test216@test.it', Additional_Email__c='testwe@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a2;
        c.AgentName__c=a2.Id;
        update c;
    } 
    static testmethod void TestCase17()
    {
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('NFE - AAI - Vendite Base','AAI - Supporto HD1 - Lightning','AAI - Supporto HD2')];
        Id pAgent;
        Id pHD1;
        Id pHD2;
        if (profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'NFE - AAI - Vendite Base')
                {
                    pAgent = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD1 - Lightning')
                {
                    pHD1 = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD2')
                {
                    pHD2 = p.Id;
                }
            }
        } 
        User newAgent = new User();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            Account agency1 = new Account();
        agency1.Name = 'Test Single Push';
        agency1.MobilePhone__c = '1234';
        agency1.Agency_email__c = 'test@test.com';
        agency1.Agency_Holder__c = 'Test';
        agency1.CIF_Number__c = '12345';
        agency1.Email_Master_AAI__c = 'test@test.com';
        agency1.Mobile_Master_AAI__c = '1234';
        insert agency1;
        Id accId     = agency1.Id;
        
        Contact con = new Contact(FirstName = 'test$$',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'GAETAUtentePartner' Limit 1];
        
        
         newAgent = new User(Username                     = 'agente@axa.test.com',
                                 LastName                     = 'testuser',
                                 LanguageLocaleKey            = 'it',
                                 FirstName                    = 'test',
                                 Email                        = 'test@test.com', 
                                 Alias                        = 'test',
                                 TimeZoneSidKey               = 'Europe/Dublin',
                                 LocaleSidKey                 = 'it_IT',
                                 EmailEncodingKey             = 'UTF-8',
                             	 PortalRole					  = 'Manager',
                                 UserRoleId					  = userrole.Id,
                                 ProfileId                    = pAgent,
                                 ContactId                    = conId,
                                 UserPermissionsKnowledgeUser = true);
        insert newAgent;
		}
        
        Account agency = new Account();      
        agency.Name = 'Test Single Push';
        agency.MobilePhone__c = '1234';
        agency.Agency_email__c = 'test@test.com';
        agency.Agency_Holder__c = 'Test';
        agency.CIF_Number__c = '12345';
        agency.Email_Master_AAI__c = 'test@test.com';
        agency.Mobile_Master_AAI__c = '1234';
        insert agency;
        Id accId2     = agency.Id;
        
        Contact con2 = new Contact(FirstName = 'test$$',
                                   LastName  = 'Smi22th',
                                   Phone     = '415.555.1212',
                                   AccountId = accId2);
        insert con2;
        Id conId2 = con2.Id;
        User newAgent2 = new User(Username                     = 'agente2@axa.test.com',
                                  LastName                     = 'testuser2',
                                  LanguageLocaleKey            = 'it',
                                  FirstName                    = 'test2',
                                  Email                        = 'test2@test.com', 
                                  Alias                        = 'test',
                                  TimeZoneSidKey               = 'Europe/Dublin',
                                  LocaleSidKey                 = 'it_IT',
                                  EmailEncodingKey             = 'UTF-8',
                                  ProfileId                    = pAgent,
                                  ContactId                    = conId2,
                                  UserPermissionsKnowledgeUser = true);
        insert newAgent2;
        Account a1 = new Account(FirstName='Mario',LastName='test_17',PersonEmail = 'test17@test.it',Additional_Email__c='test@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a1;
        test.starttest();
        Case c;
        system.runAs(userAdmin)
        {
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            c = new Case(User__c=newAgent.Id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor),Phone_Call_Ids__c = 'test');
            insert c;     
            c.OwnerId = newAgent.Id;
            c.Origin = 'Chat';
            update c;
            test.stoptest();
        }   
        c.User__c=newAgent2.Id;
        update c;
    } 
    static testmethod void TestCase18()
    {
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('NFE - AAI - Vendite Base','AAI - Supporto HD1 - Lightning','AAI - Supporto HD2')];
        Id pAgent;
        Id pHD1;
        Id pHD2;
        if (profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'NFE - AAI - Vendite Base')
                {
                    pAgent = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD1 - Lightning')
                {
                    pHD1 = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD2')
                {
                    pHD2 = p.Id;
                }
            }
        } 
        
        Account acct = new Account(Name = 'SFDC Account');
        insert acct;
        Id accId     = acct.Id;
        
        Contact con = new Contact(FirstName = 'test$$',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        User HD1 = new User(Username                     = 'advisorHD1@axa.test.com',
                            LastName                     = 'testuserHD1',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD1',
                            Email                        = 'test@testHD1.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pHD1,
                            UserPermissionsKnowledgeUser = true);
        insert HD1;
        
        User HD2 = new User(Username                     = 'supportHD2@axa.test.com',
                            LastName                     = 'testuserHD2',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD2',
                            Email                        = 'test@testHD2.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pHD2,
                            UserPermissionsKnowledgeUser = true);
        insert HD2;
        Account a1 = new Account(FirstName='Mario',LastName='test_18',PersonEmail = 'test18@test.it',Additional_Email__c='test@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a1;
        test.starttest();
        Case c;
        system.runAs(userAdmin)
        {
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            c = new Case(OwnerId= HD1.Id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  [SELECT id from RecordType WHERE DeveloperName = 'Assistenza_Agenti'].Id);
            insert c;     
            test.stoptest();
        }   
        c.OwnerId= HD2.Id;
        update c;
    } 
    static testmethod void TestCase19()
    {
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('NFE - AAI - Vendite Base','AAI - Supporto HD1 - Lightning','AAI - Supporto HD2')];
        Id pAgent;
        Id pHD1;
        Id pHD2;
        if (profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'NFE - AAI - Vendite Base')
                {
                    pAgent = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD1 - Lightning')
                {
                    pHD1 = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD2')
                {
                    pHD2 = p.Id;
                }
            }
        } 
        
        Account acct = new Account(Name = 'SFDC Account');
        insert acct;
        Id accId     = acct.Id;
        
        Contact con = new Contact(FirstName = 'test$$',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        User HD1 = new User(Username                     = 'advisorHD1@axa.test.com',
                            LastName                     = 'testuserHD1',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD1',
                            Email                        = 'test@testHD1.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pHD1,
                            UserPermissionsKnowledgeUser = true);
        insert HD1;
        
        User HD2 = new User(Username                     = 'supportHD2@axa.test.com',
                            LastName                     = 'testuserHD2',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD2',
                            Email                        = 'test@testHD2.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pHD2,
                            UserPermissionsKnowledgeUser = true);
        insert HD2;
        Account a1 = new Account(FirstName='Mario',LastName='test_19',PersonEmail = 'test19@test.it',Additional_Email__c='test@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a1;
        test.starttest();
        Case c;
        system.runAs(userAdmin)
        {
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            c = new Case(OwnerId= HD2.Id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  [SELECT id from RecordType WHERE DeveloperName = 'Assistenza_Agenti'].Id);
            insert c;     
            test.stoptest();
        }   
        c.OwnerId= HD1.Id;
        update c;
    } 
    static testmethod void TestCase20()
    {
        Group testGroup = new Group(Name='HD1 IT', type='Queue');
        insert testGroup;
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        
        system.runAs(userAdmin)
        {
            insert testQueue;
        }
        
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('NFE - AAI - Vendite Base','AAI - Supporto HD1 - Lightning','AAI - Supporto HD2')];
        Id pAgent;
        Id pHD1;
        Id pHD2;
        if (profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'NFE - AAI - Vendite Base')
                {
                    pAgent = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD1 - Lightning')
                {
                    pHD1 = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD2')
                {
                    pHD2 = p.Id;
                }
            }
        } 
        
        Account acct = new Account(Name = 'SFDC Account');
        insert acct;
        Id accId     = acct.Id;
        
        Contact con = new Contact(FirstName = 'test$$',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        User HD1 = new User(Username                     = 'advisorHD1@axa.test.com',
                            LastName                     = 'testuserHD1',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD1',
                            Email                        = 'test@testHD1.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pHD1,
                            UserPermissionsKnowledgeUser = true);
        insert HD1;
        
        User HD2 = new User(Username                     = 'supportHD2@axa.test.com',
                            LastName                     = 'testuserHD2',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD2',
                            Email                        = 'test@testHD2.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pHD2,
                            UserPermissionsKnowledgeUser = true);
        insert HD2;
        Account a1 = new Account(FirstName='Mario',LastName='test_20',PersonEmail = 'test20@test.it',Additional_Email__c='test@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIntermediary));
        insert a1;
        test.starttest();
        Case c;
        system.runAs(userAdmin)
        {
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            c = new Case(OwnerId= testGroup.Id,Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='AUTO',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  [SELECT id from RecordType WHERE DeveloperName = 'Assistenza_Agenti'].Id);
            insert c;     
            test.stoptest();
        }   
        c.OwnerId= HD1.Id;
        update c;
    } 
    static testmethod void TestCase21()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_21',PersonEmail = 'test21@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Data_ricezione_richiesta_dpo__c = system.today();
        update c;
    } 
    static testmethod void TestCase22()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_22',PersonEmail = 'test22@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_ricezione_richiesta_dpo__c=system.today()-1,NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Data_ricezione_richiesta_dpo__c = null;
        update c;
    } 
    
    static testmethod void TestCase23()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_23',PersonEmail = 'test23@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_primo_Task_DPO__c=system.today(),NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Data_completamento_Task_DPO__c = system.today();
        update c;
    } 
    static testmethod void TestCase24()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_24',PersonEmail = 'test24@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(Data_primo_task_interno__c=system.today(),NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        
        
        c.Data_completamento_Task_interni__c = system.today();
        update c;
    } 
    static testmethod void TestCase25()
    {
        Account a1 = new Account(FirstName='Mario',LastName='test_25',PersonEmail = 'test25@test.it', recordtypeid =  acc_developerIdMap.get(AP_Constants.rtAccIndividualClient));
        insert a1;
        test.starttest();
        ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
        Case c = new Case(First_Long_Term_Management_Alert_DT__c = system.today(),NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=a1.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
        insert c;     
        test.stoptest();
        c.Oldest_Task_Creat_Date__c=system.today();
        c.First_Long_Term_Management_Alert_DT__c = system.today();
        c.All_Tasks_Close_Date__c = system.today();
        update c;
    } 
    //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- END
    
    //OAVERSANO 27/11/2018 : ICF Close The Loop -- START
    static testmethod void TestCase26()
    {
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'NFE - AAI - Vendite Base'];
        Profile p;
        Id pAgent;
        if (profiles.size() > 0)
        {
            p      = profiles[0];
            pAgent = p.Id;
        } 
        
       Account acct = new Account(Name = 'SFDC Account 1',
                                    AAI_Agency_Reference_Code__c = 'Test',
                                  	Agency_Email__c = 'test@test.com',
                                    Agency_Code__c = 'Test');
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
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        
        system.runAs(uteTec)
        {
            test.starttest();
            
            ModelloDiAssistenzaUtils.runModelloDiAssistenza = false;
            Case c = new Case(OwnerId =newAgent.Id, First_Long_Term_Management_Alert_DT__c = system.today(),NextStatusDate__c=system.today()+30,Status =AP_Constants.caseStatusPending,Origin='Phone',SuppliedEmail='webmail@test.it',Accountid=acct.id,Category__c='GDPR',SubCategory__c='Richiesta di accesso',Distribution_Network__c='BNL', recordtypeid =  cas_developerIdMap.get(AP_Constants.rtCaseMotor));
            insert c;    
            List<Case> csList = new List<Case>();
            csList.add(c);
            Map<String, String> caseIdOwnerIdMap = new Map<String, String>();
            CaseManagement.caseTeamManagement csteam = new CaseManagement.caseTeamManagement();
            csteam.createCaseTeamMembers(csList, caseIdOwnerIdMap);
            test.stoptest();
            
        } 
    }
        //OAVERSANO 27/11/2018 : ICF Close The Loop -- END
        
        
}