@isTest
private class AP01CaseCalculateDueDate_TEST {
    /*
----------------------------------------------------------------------
-- - Name          : AP01CaseCalculateDueDate_TEST
-- - Author        : Spoon Consulting 
-- - Description   : Test class of AP01CaseCalculateDueDate
--                   
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 08-05-2013   YRA    1.0    Intitial version
----------------------------------------------------------------------
**********************************************************************
*/
    static user userAdmin;
    static list <Case> caseList;
    static datetime dueDateValDT,dueDateValDT1;//,ackdueDateValDT,ackdueDateValDT1;
    static date dueDateVal,dueDateVal1;//ackdueDateVal,ackdueDateVal1;
    static BusinessHours defaultHours;
    static BusinessHours GDPR;
    //static Account TestAccount;//MOSCATELLI_M 09112015: EVO-23
    
    //MOSCATELLI_M 28/06/2016: EVO 61 -- START
    static list <Definizione_Modelli_di_Servizio__c> DefModServ;
    static list <Configurazione_SLA_Case__c> CSLAList;
    static list<Account> TestAccount;
    //MOSCATELLI_M 28/06/2016: EVO 61 -- END
    
    //MOSCATELLI_M 19122016:EVO 73 -- START
    static VIPCustomersCharacteristics__c VIPCustSet;
    static VIPCustomersCharacteristics__c VIPCustSet2;
    static InsurancePolicy__c Polizza;
    static Entitlement ent;
    //MOSCATELLI_M 19122016:EVO 73 -- END   
    static list<MPS_Code_Variables__c> mpscodevar;
    
    static{
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        mpscodevar = new list<MPS_Code_Variables__c>{
            new MPS_Code_Variables__c(Name = 'GDPR_Category_001',Value__c='GDPR'),
                new MPS_Code_Variables__c(Name='Entitlement',Value__c='Gestione SLA SmartCenter'),
                new MPS_Code_Variables__c(Name='Entitlement GDPR',Value__c='Gestione SLA GDPR Smart Center',SLAmin__c=480,SLAmax__c=720),
                new MPS_Code_Variables__c(Name='Entitlement GDPR 2',Value__c='Gestione SLA GDPR Smart Center 2',SLAmin__c=120,SLAmax__c=480),
                new MPS_Code_Variables__c(Name='Entitlement GDPR 3',Value__c='Gestione SLA GDPR Smart Center 3',SLAmax__c=120),
                new MPS_Code_Variables__c(Name='ModelloDiAssistenzaSLADefault',Value__c='99'),
                new MPS_Code_Variables__c(Name='MilestoneTrackerVisible99H',Value__c='true'),//OAVERSANO 03/12/2018 : Caring Angel
                new MPS_Code_Variables__c(Name='CAMilestoneTrackerVisible99H',Value__c='true'),//OAVERSANO 03/12/2018 : Caring Angel
                new MPS_Code_Variables__c(Name='devRecordTypeToRecalculateAP01',Value__c='Reclamo'),//OAVERSANO 22/01/2019 : Gestione Reclami
                new MPS_Code_Variables__c(Name='CaringAngelSLADefault',Value__c='99'),//OAVERSANO 22/01/2019 : Gestione Reclami
                new MPS_Code_Variables__c(Name='SinistriMilestoneTrackerVisible99H',Value__c='true'),//OAVERSANO 03/12/2018 : AXA Assistance
                new MPS_Code_Variables__c(Name='SinistriSLADefault',Value__c='99')//OAVERSANO 03/12/2018 : AXA Assistance
                };
                    insert mpscodevar;                                            
        
        //MOSCATELLI_M 19122016:EVO 73 -- START
        VIPCustSet = new VIPCustomersCharacteristics__c(Name='C-001',Case_Category__c='TestProd');
        VIPCustSet2 = new VIPCustomersCharacteristics__c(Name='C-002',Case_Category__c='GDPR'); 
        insert VIPCustSet;
        insert VIPCustSet2;
        //MOSCATELLI_M 19122016:EVO 73 -- END
        
        //MOSCATELLI_M 28/06/2016: EVO 61 --START
        DefModServ = new list<Definizione_Modelli_di_Servizio__c>{
            new Definizione_Modelli_di_Servizio__c(Customer_Typology__c='Standard',Modello_di_Servizio__c='TestST'),
                new Definizione_Modelli_di_Servizio__c(Customer_Typology__c='Private',Modello_di_Servizio__c='TestPVT')
                };
                    insert DefModServ;
        //MOSCATELLI_M 28/06/2016: EVO 61 --END
        
        //MOSCATELLI_M 15012016: EVO-43-----START
        
        //MOSCATELLI_M 28/06/2016: EVO 61 --START
        /*
        Configurazione_SLA_Case__c CSLA1 = new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20);
        Configurazione_SLA_Case__c CSLA2 = new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20);
        Configurazione_SLA_Case__c CSLA3 = new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20);
        Configurazione_SLA_Case__c CSLA4 = new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20);
        Configurazione_SLA_Case__c CSLA5 = new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20);
        Configurazione_SLA_Case__c CSLA6 = new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20);
        Configurazione_SLA_Case__c CSLA7 = new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20);
        Configurazione_SLA_Case__c CSLA8 = new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20); 
        List<Configurazione_SLA_Case__c> CSLAList = new List<Configurazione_SLA_Case__c>();
        CSLAList.add(CSLA1);CSLAList.add(CSLA2);CSLAList.add(CSLA3);CSLAList.add(CSLA4);CSLAList.add(CSLA5);CSLAList.add(CSLA6);CSLAList.add(CSLA7);CSLAList.add(CSLA8);
        insert CSLAList; 
        */
        CSLAList = new list<Configurazione_SLA_Case__c>{
            new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='Phone',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='Motor',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Premi',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Operatività sulla polizza di risparmio',Rule_Active__c=true,Sub_Category__c='',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                //MOSCATELLI_M 19122016:EVO 73 -- START
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='TestProd',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                //FM_24/05/2018 : GDPR -- START 
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta di accesso',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=720,SLA_for_MPS_One_Customers__c=720,SLA_for_Private_Customers__c=720,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta di portabilità',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=380,SLA_for_MPS_One_Customers__c=380,SLA_for_Private_Customers__c=380,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta revoca',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altre compagnie del gruppo AXA',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = 'All'),
                //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- START
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- END
                //FM_24/05/2018 : GDPR -- END   
                //OAVERSANO 21/01/2019 : Gestione Reclami -- START
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta di accesso',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=720,SLA_for_MPS_One_Customers__c=720,SLA_for_Private_Customers__c=720,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta di portabilità',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=380,SLA_for_MPS_One_Customers__c=380,SLA_for_Private_Customers__c=380,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='GDPR',Rule_Active__c=true,Sub_Category__c='Richiesta revoca',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altre compagnie del gruppo AXA',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
				new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altre compagnie del gruppo AXA',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),    
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='Assistenza Agenti',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='Portale Assistenza',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Annullamenti',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = AP_Constants.caseComplainantInt),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='All',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='All',Rule_Active__c=true,Sub_Category__c='All',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='PEC',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='AAI',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='AAI',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='All',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=696,SLA_for_MPS_One_Customers__c=696,SLA_for_Private_Customers__c=696,Customer_Service_Type__c='TestPVT',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='SINISTRI',Rule_Active__c=true,Sub_Category__c='All',Case_Origin__c='PEC',Case_Record_Type__c='Reclamo',SLA__c=696,SLA_for_MPS_One_Customers__c=696,SLA_for_Private_Customers__c=696,Customer_Service_Type__c='TestPVT',Distribution_Network__c='AAI',Complainant__c = 'Customer'),
                 new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='All',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'All'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='MPS',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='Email',Case_Record_Type__c='Reclamo',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Email',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Altro',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=5,SLA_for_MPS_One_Customers__c=5,SLA_for_Private_Customers__c=5,Customer_Service_Type__c='TestST',Distribution_Network__c='All',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='AUTO',Rule_Active__c=true,Sub_Category__c='Consultazioni',Case_Origin__c='PEC',Case_Record_Type__c='Reclamo',SLA__c=696,SLA_for_MPS_One_Customers__c=696,SLA_for_Private_Customers__c=696,Customer_Service_Type__c='All',Distribution_Network__c='AAI',Complainant__c = 'Customer'),
                
                new Configurazione_SLA_Case__c(Category__c='SINISTRI',Rule_Active__c=true,Sub_Category__c='All',Case_Origin__c='PEC',Case_Record_Type__c='Reclamo',SLA__c=696,SLA_for_MPS_One_Customers__c=696,SLA_for_Private_Customers__c=696,Customer_Service_Type__c='All',Distribution_Network__c='AAI',Complainant__c = 'Customer'),
                
                new Configurazione_SLA_Case__c(Category__c='VITA',Rule_Active__c=true,Sub_Category__c='Altro',Case_Origin__c='All',Case_Record_Type__c='Reclamo',SLA__c=696,SLA_for_MPS_One_Customers__c=696,SLA_for_Private_Customers__c=696,Customer_Service_Type__c='All',Distribution_Network__c='AAI',Complainant__c = 'Dipendente'),
        
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='TestST',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c='Estratto conto',Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='Quadra',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='Phone',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='Duplicati polizza di risparmio',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer'),
                new Configurazione_SLA_Case__c(Category__c='TestProd',Rule_Active__c=true,Sub_Category__c=null,Case_Origin__c='All',Case_Record_Type__c='All',SLA__c=10,SLA_for_MPS_One_Customers__c=20,SLA_for_Private_Customers__c=30,Customer_Service_Type__c='All',Distribution_Network__c='BNL',Complainant__c = 'Customer')
                //OAVERSANO 21/01/2019 : Gestione Reclami -- END
                //MOSCATELLI_M 19122016:EVO 73 -- END
                };
                    insert CSLAList;        
        //MOSCATELLI_M 28/06/2016: EVO 61 --END         
        
        Id IdRecMotor = [Select id from RecordType where SObjectType = 'Case' and developername = :AP_Constants.rtCaseMotor].id;
        Id IdRecQuadra = [Select id from RecordType where SObjectType = 'Case' and developername = :AP_Constants.rtCaseQuadra].id;
        //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- START
        Id IdAssAgenti = [Select id from RecordType where SObjectType = 'Case' and developername = :AP_Constants.rtCaseAssistenzaAgenti].id;
        //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- END
        //OAVERSANO 21/01/2019 : Gestione Reclami -- START
        Id IdREclamo = [Select id from RecordType where SObjectType = 'Case' and developername = :AP_Constants.rtCaseReclamo].id;
        Id IDCaringAngel = [Select id from RecordType where SObjectType = 'Case' and developername = :AP_Constants.rtCaseCaringAngel].id;
        Id IDSinistriAAI = [Select id from RecordType where SObjectType = 'Case' and developername = :AP_Constants.rtCaseSinistriAAI].id; //OAVERSANO 27/03/2019 : AXA Assistance
        //OAVERSANO 21/01/2019 : Gestione Reclami -- END
        //MOSCATELLI_M 15012016: EVO-43-----END
        /*
        task tsk = new Task(subject='ss',status='Open',Priority='Normal');
        insert tsk;
		update tsk;*/
        
        //Get the default business hours (we might need it)
        defaultHours = [select Id from BusinessHours where IsDefault=true];
        GDPR = [SELECT Id FROM BusinessHours WHERE Name = 'GDPR']; 
        
        //User
        userAdmin = new User(Username = 'testclassAP01@test.com',
                             LastName = 'testuser',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test',
                             Email = 'test@test.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId());
        
        insert userAdmin;
        
        //MOSCATELLI_M 09112015: EVO-23-----START
        
        //MOSCATELLI_M 28/06/2016: EVO 61 -- START
        /*        
TestAccount = new Account(FirstName = 'test',
LastName  = 'AP01',
PersonEmail = 'test@ap01.com',
RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id
);

insert TestAccount;

id idAccount = [Select Id from Account where PersonEmail = 'test@ap01.com'].Id;
*/
        
        TestAccount = new list<Account>{
            new Account(FirstName = 'test',
                        LastName  = 'AP01',
                        PersonEmail = 'test@ap01.com',
                        RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id,
                        Bank_Service_Model__c = 'TestPVT'
                       ),
                new Account(FirstName = 'test2',
                            LastName  = 'AP01',
                            PersonEmail = 'test2@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id
                           ),
                new Account(FirstName = 'test3',
                            LastName  = 'AP01',
                            PersonEmail = 'test3@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id,
                            Bank_Service_Model__c = 'TestST'
                           ),
                new Account(FirstName = 'test4',
                            LastName  = 'AP01',
                            PersonEmail = 'test4@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id
                           ),
                //MOSCATELLI_M 19122016:EVO 73 -- START
                new Account(FirstName = 'test5',
                            LastName  = 'AP01',
                            PersonEmail = 'test4@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id
                           ),
                new Account(FirstName = 'test6',
                            LastName  = 'AP01',
                            PersonEmail = 'test6@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Intermediary'].Id,
                            Bank_Service_Model__c = 'TestPVT'
                           )          ,
                new Account(FirstName = 'test7',
                            LastName  = 'AP01',
                            PersonEmail = 'test7@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Intermediary'].Id,
                            Bank_Service_Model__c = 'TestST'
                           ),
                new Account(FirstName = 'test8',
                            LastName  = 'AP01',
                            PersonEmail = 'test8@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Intermediary'].Id,
                            Bank_Service_Model__c = 'TestST'
                           ),
                new Account(FirstName = 'test9',
                            LastName  = 'AP01',
                            PersonEmail = 'test9@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Intermediary'].Id,
                            Bank_Service_Model__c = ''
                           )
                //MOSCATELLI_M 19122016:EVO 73 -- END                          
                };
                    insert TestAccount;
        
        //MOSCATELLI_M 19122016:EVO 73 -- START
        Polizza = new InsurancePolicy__c(Name='testpol',CUID__c=TestAccount[4].id,Product__c='TestProd');
        insert Polizza;
        
        ent = new entitlement(Name='Gestione SLA SmartCenter', AccountId=TestAccount[4].Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        Entitlement testing2 = new entitlement(Name='Gestione SLA GDPR Smart Center', AccountId=TestAccount[4].Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert testing2; 
        
        Entitlement testing3 = new entitlement(Name='Gestione SLA GDPR Smart Center 2', AccountId=TestAccount[4].Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert testing3;  
        
        Entitlement testing4 = new entitlement(Name='Gestione SLA GDPR Smart Center 3', AccountId=TestAccount[4].Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert testing4;      
        //MOSCATELLI_M 19122016:EVO 73 -- END
        
        
        //MOSCATELLI_M 28/06/2016: EVO 61 -- END
        
        //caseList = new list <Case>{new Case(Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id),
        //new Case(Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id)};
        //MOSCATELLI_M 15012016: EVO-43-----START                                
        //caseList = new list <Case>{new Case(AccountId = idAccount,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id),
        //new Case(AccountId = idAccount,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id)};                                
        caseList = new list <Case>{new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),     
            //MOSCATELLI_M 28/06/2016: EVO 61 -- START
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[1].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),            
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),            
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Premi',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),
            new Case(Category__c='Operatività sulla polizza di risparmio',SubCategory__c='Variazioni contrattuali',AccountId = TestAccount[3].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Fax'),
            //MOSCATELLI_M 19122016:EVO 73 -- START
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL'),           
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL'),           
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='TestProd',SubCategory__c='Test',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di accesso',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',SLAHours__c =720,Data_ricezione_richiesta_DPO__c = System.today()-40, Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di accesso',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-2,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di accesso',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-40,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-15,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-2,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[0].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL',StatusReopened_Date__c = system.now()),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta revoca',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id) ,     
            new Case(Category__c='Altro',SubCategory__c='Altre compagnie del gruppo AXA',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id),
            //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- START
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdAssAgenti,Origin='Portale Assistenza',Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdRecQuadra,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdRecQuadra,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdRecQuadra,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdAssAgenti,Origin='Portale Assistenza',Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdRecQuadra,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdRecQuadra,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdRecQuadra,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdRecQuadra,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id),
            new Case(Category__c='VITA',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id),
            //OAVERSANO 12/09/2018 : Nuovo Modello di Assistenza -- END
            //OAVERSANO 21/01/2019 : Gestione Reclami -- START
            new Case(Category__c='VITA',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdAssAgenti,Origin='Portale Assistenza',Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Portale Assistenza',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[6].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='VITA',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='SINISTRI',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='SINISTRI',SubCategory__c=null,AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='AUTO',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c=null,AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c=null,AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer', Data_creazione_richiesta_DMR__c=system.today().addDays(-5)),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdCaringAngel,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di accesso',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',SLAHours__c =720,Data_ricezione_richiesta_DPO__c = System.today()-40, Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di accesso',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-2,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di accesso',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-40,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-15,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Data_ricezione_richiesta_DPO__c = System.today()-2,Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email'),
            new Case(Category__c='GDPR',SubCategory__c='Richiesta di portabilità',AccountId = TestAccount[5].id,Complainant__c = AP_Constants.caseComplainantInt,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL',StatusReopened_Date__c = system.now()),
			new Case(Category__c=null,SubCategory__c=null,AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdCaringAngel,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdCaringAngel,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdCaringAngel,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='AUTO',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c='VITA',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            new Case(Category__c=null,SubCategory__c=null,AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdCaringAngel,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdCaringAngel,Distribution_Network__c='MPS',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdCaringAngel,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='AUTO',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='VITA',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='VITA',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='PEC',RecordTypeId =IdReclamo,Distribution_Network__c='AAI',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='VITA',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='AAI',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='VITA',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='VITA',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='SINISTRI',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdCaringAngel,Distribution_Network__c='BNL',AgentName__c =TestAccount[5].id, Complainant__c = 'Dipendente'),
            new Case(Category__c='SINISTRI',SubCategory__c='Consultazioni',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='PEC',RecordTypeId =IdReclamo,Distribution_Network__c='AAI',AgentName__c =TestAccount[5].id, Complainant__c = 'Customer'),
            
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = AP_Constants.caseComplainantInt),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Annullamenti',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c=null,AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c=null,AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdAssAgenti,Distribution_Network__c='BNL',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Email',RecordTypeId =IdReclamo,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer', Data_creazione_richiesta_DMR__c=system.today().addDays(-5)),
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IdCaringAngel,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            
            
            new Case(Category__c='SINISTRI',SubCategory__c='Consultazioni',AccountId = TestAccount[7].id,Status=AP_Constants.caseStatusOpen,Origin='PEC',RecordTypeId =IdReclamo,Distribution_Network__c='AAI',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer'),
            new Case(Category__c='AUTO',SubCategory__c='Consultazioni',Status=AP_Constants.caseStatusOpen,Origin='PEC',RecordTypeId =IdReclamo,Distribution_Network__c='AAI', Complainant__c = 'Customer'),
            
            new Case(Category__c='VITA',SubCategory__c='Altro',Status=AP_Constants.caseStatusOpen,Origin='Other',RecordTypeId =IdReclamo,Distribution_Network__c='AAI', Complainant__c = 'Dipendente'),
            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),           
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[2].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Estratto conto',AccountId = TestAccount[4].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),           
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecQuadra,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),      
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Status=AP_Constants.caseStatusPendingStaff,BusinessHoursId=defaultHours.Id,RecordTypeId =IdRecMotor,Origin='Phone',Distribution_Network__c='BNL', Complainant__c = 'Customer'),            
            new Case(Category__c='Duplicati polizza di risparmio',SubCategory__c='Contratto di polizza',AccountId = TestAccount[0].id,Status=AP_Constants.caseStatusOpen,RecordTypeId =IdRecMotor,Origin='Email',Distribution_Network__c='BNL', Complainant__c = 'Customer'),
            //OAVERSANO 21/01/2019 : Gestione Reclami -- END
            new Case(Category__c='Altro',SubCategory__c='Altro',AccountId = TestAccount[5].id,Status=AP_Constants.caseStatusOpen,Origin='Phone',RecordTypeId =IDSinistriAAI,Distribution_Network__c='MPS',AgentName__c =TestAccount[6].id, Complainant__c = 'Customer') //OAVERSANO 27/03/2019 : AXA Assistance
            //MOSCATELLI_M 19122016:EVO 73 -- END            
            };
                //MOSCATELLI_M 28/06/2016: EVO 61 -- END
                
                //MOSCATELLI_M 15012016: EVO-43-----END
                
                system.debug('caseList :'+caseList+'    '+'TestAccount :'+TestAccount);
        //MOSCATELLI_M 09112015: EVO-23-----END     
    }
    
    /*static testMethod void calDueDateTestOnInsert() {
        System.Debug('>>> Start calDueDateTestOnInsert');
        System.runAs(userAdmin)
        {
            test.starttest(); 
            insert caseList;
            test.stoptest();  
        }//end system.runas
        
        list<Case> caseAssertList = [select DueDate__c, CreatedDate
                                     from Case
                                     where id IN: caseList
                                    ];
        
        system.debug('caseAssertList.size()'+ caseAssertList.size());
        //due date
        dueDateValDT = BusinessHours.add(defaultHours.Id,caseAssertList[0].CreatedDate,AP_Constants.caseSLASevenDays*24*60 * 60 * 1000L);
        dueDateVal = date.newinstance(dueDateValDT.year(),dueDateValDT.month(), dueDateValDT.day());
        
        dueDateValDT1 = BusinessHours.add(defaultHours.Id,caseAssertList[1].CreatedDate,AP_Constants.caseSLAFourteenDays*24*60 * 60 * 1000L);
        dueDateVal1 = date.newinstance(dueDateValDT1.year(),dueDateValDT1.month(), dueDateValDT1.day());
        
        //acknowledge due date
        //ackdueDateValDT = BusinessHours.add(defaultHours.Id,caseAssertList[0].CreatedDate,24*60 * 60 * 1000L);
        //ackdueDateVal = date.newinstance(ackdueDateValDT.year(),ackdueDateValDT.month(), ackdueDateValDT.day());
        
        //ackdueDateValDT1 = BusinessHours.add(defaultHours.Id,caseAssertList[0].CreatedDate,24*60 * 60 * 1000L);
        //ackdueDateVal1 = date.newinstance(ackdueDateValDT1.year(),ackdueDateValDT1.month(), ackdueDateValDT1.day());
        
        //1st case
        /*system.assertEquals(dueDateVal,caseAssertList[0].DueDate__c);
        system.assertEquals(ackdueDateVal,caseAssertList[0].AcknowledgementDueDate__c);
        
        //2nd case
        system.assertEquals(dueDateVal1,caseAssertList[1].DueDate__c);
        system.assertEquals(ackdueDateVal1,caseAssertList[1].AcknowledgementDueDate__c);*/
        
        /*System.Debug('>>> End calDueDateTestOnInsert');
    }*/
    
    /*static testMethod void calTestOnUpdate() {
        System.Debug('>>> Start calDueDateTestOnUpdate');
        System.runAs(userAdmin)
        {
            test.starttest();
            insert caseList;
            
            
            caseList[0].Category__c='1';
            caseList[1].SubCategory__c='2';
            caseList[1].Origin='3';
            update caseList;
            test.stoptest();
        }
        AP_Constants.getIdDeveloperMap( AP_Constants.sobjectCas );
        
        list<Case> caseAssertList = [select DueDate__c, CreatedDate
                                     from Case
                                     where id IN: caseList
                                    ];
        
        system.debug('caseAssertListupdt.size()'+ caseAssertList.size());        
        System.Debug('>>> End calDueDateTestOnUpdate');        
    }
    
    static testMethod void calTestOn4Update() {
        System.Debug('>>> Start calDueDateTestOnUpdate');
        System.runAs(userAdmin)
        {
            test.starttest();
            insert new CaseSLA__c(Category__c ='1',SubCategory__c ='2',name='k',PhoneTotalHours__c=100);
            insert caseList;
            
            
            caseList[1].Category__c='1';
            caseList[1].SubCategory__c='2';
            caseList[1].Origin=AP_Constants.caseOriginPhone;
            caseList[1].SLAHours__c=20;
            update caseList;
            test.stoptest();
        }
        AP_Constants.getIdDeveloperMap( AP_Constants.sobjectCas );
        
        list<Case> caseAssertList = [select DueDate__c, CreatedDate
                                     from Case
                                     where id IN: caseList
                                    ];
        
        system.debug('caseAssertListupdt.size()'+ caseAssertList.size());
        
        System.Debug('>>> End calDueDateTestOnUpdate');        
    }*/
    
    static testMethod void cal1TestOnUpdate() {
        System.runAs(userAdmin)
        {
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusReopened ;
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusAssigned ;
            test.starttest();
            update caseList[0];
            //test.stoptest();//MOSCATELLI_M 21032016: EVO47: commented
            //coverage
            caseList[0].Status = AP_Constants.caseStatusAllTasksClosed ;
            update caseList[0];
            //MOSCATELLI_M 29042016: EVO51--START : commented
            /*
            caseList[0].Status = AP_Constants.caseStatusDelegated ;
            update caseList[0];
            caseList[0].Status = AP_Constants.caseStatusCancelled ;
            update caseList[0];
    		*/
            //MOSCATELLI_M 29042016: EVO51--END : commented
            test.stoptest();//MOSCATELLI_M 21032016: EVO47
        }//end of run as        
    }
    
    //MOSCATELLI_M 29042016: EVO51--START
    static testMethod void cal1TestOnUpdate_1() {
        System.runAs(userAdmin)
        {
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusReopened ;
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusAssigned ;
            test.starttest();
            update caseList[0];
            //coverage
            caseList[0].Status = AP_Constants.caseStatusDelegated ;
            update caseList[0];
            caseList[0].Status = AP_Constants.caseStatusCancelled ;
            update caseList[0];                
            test.stoptest();
        }//end of run as        
    }
    //MOSCATELLI_M 29042016: EVO51--END
    
    static testMethod void cal1TestOnUpdate1() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusReopened ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusAssigned ;
            test.starttest();
            update caseList[0];
            //test.stoptest();//MOSCATELLI_M 21032016: EVO47:commented
            //coverage
            caseList[0].Status = AP_Constants.caseStatusPending ;
            update caseList[0];
            caseList[0].Status = AP_Constants.caseStatusClosed ;
            update caseList[0];                
            test.stoptest();//MOSCATELLI_M 21032016: EVO47
        }//end of run as        
    } 
    
    static testMethod void GDPR() {
        System.runAs(userAdmin)
        {                
            test.starttest();
            
            /*BOVOLENTA_D too many soql
            insert caseList[49];
            insert caseList[50];   
            insert caseList[51];  
            insert caseList[52];  
            insert caseList[53];    
            insert caseList[54]; 
            insert caseList[55];   */
            list<Case> theMegaList = new list<Case>();
            theMegaList.add(caseList[49]);
            theMegaList.add(caseList[50]);   
            theMegaList.add(caseList[51]);  
            theMegaList.add(caseList[52]);  
            theMegaList.add(caseList[53]);    
            theMegaList.add(caseList[54]); 
            theMegaList.add(caseList[55]);    
            test.stoptest();//MOSCATELLI_M 21032016: EVO47
        }//end of run as        
    }
    
    
    /*
    //MOSCATELLI_M 19122016:EVO 73 -- START
    public void ReopenCase()
    {
    Test.setCreatedDate(caseList[32].Id, DateTime.newInstance(2012,12,12));
    test.startTest();
    caseList[32].Accountid=TestAccount[4].id;
    update caseList[32];
    caseList[32].Status=AP_Constants.caseStatusAllTasksClosed;
    update caseList[32];
    caseList[32].Status=AP_Constants.caseStatusClosed;
    Case upd = new Case (id=caseList[32].id,Status=AP_Constants.caseStatusReopened,StatusReopened_Date__c =  DateTime.newInstance(2016,12,11));
    upsert upd;
    test.stopTest();
    }
    //MOSCATELLI_M 19122016:EVO 73 -- END
    */
    
    //OAVERSANO 22/01/2019 : Gestione Reclami -- START
    static testMethod void callTestOnUpdateTest1() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusReopened ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusAllTasksClosed ;
            test.starttest();
            update caseList[0];
            caseList[0].Status = AP_Constants.caseStatusDelegated ;
            update caseList[0];
            caseList[0].Status = AP_Constants.caseStatusCancelled ;
            update caseList[0];                
            test.stoptest();
        }
    } 
    static testMethod void callTestOnUpdateTest2() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusAssigned ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusDelegated ;
            test.starttest();
            update caseList[0];
            test.stoptest();
        }
    } 
    static testMethod void callTestOnUpdateTest3() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusAllTasksClosed ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusDelegated ;
            test.starttest();
            update caseList[0];
            test.stoptest();
        }
    } 
    static testMethod void callTestOnUpdateTest4() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusDelegated ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusCancelled ;
            test.starttest();
            update caseList[0];
            test.stoptest();
        }
    } 
    static testMethod void callTestOnUpdateTest5() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusCancelled ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusReopened ;
            test.starttest();
            update caseList[0];
            test.stoptest();
        }
    } 
    static testMethod void callTestOnUpdateTest6() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusClosed ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusReopened ;
            test.starttest();
            update caseList[0];
            test.stoptest();
        }
    }
    static testMethod void callTestOnUpdateTest7() {
        System.runAs(userAdmin)
        {                
            caseList[0].TECH_LastModifiedDateStatus__c = System.now().addDays(-3);
            caseList[0].Status = AP_Constants.caseStatusPending ;
            caseList[0].NextStatusDate__c = System.now().addDays(3);
            insert caseList[0];
            caseList[0].Status = AP_Constants.caseStatusClosed ;
            test.starttest();
            update caseList[0];
            test.stoptest();
        }
    }
    //OAVERSANO 22/01/2019 : Gestione Reclami -- END
}