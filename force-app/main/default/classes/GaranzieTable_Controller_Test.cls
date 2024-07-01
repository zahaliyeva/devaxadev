/*------------------------------------------------------------------------
Author:        Anna Riccardi
Company:       Deloitte
Class:         GaranzieTable_Controller_TEST
Description:   Test for the extension of GaranziePage  
History

6/02/2017     Anna Riccardi - Created
----------------------------------------------------------------------------*/


@istest
public class GaranzieTable_Controller_Test{



    @testSetup static void setup() {//preparing test database
        // test.startTest();
        
        //Insert custom settings
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;

        //MDANTONIO - 26/03/2019 - integrazione servizio garanzie - start
        //User_polizze_batch__c setting = new User_polizze_batch__c();
        //setting.Name = 'Trigger execution user';
        //setting.Value__c = 'Utente ETL';
        //insert setting;

        IE_Configuration__c Myconfig = new IE_Configuration__c(Certificate__c = 'AXA_PRE_CA_GENERATED_18', Direction__c = 'OUTBOUND', EndPoint__c = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs', HTTPMethod__c = 'GET', Name = 'Integrazione_Garanzie', Request_compiler__c = 'IE_Request_GetGaranzie', Response_parser__c = 'IE_Parser_GetGaranzie', Type__c = 'WebService_rest');
        insert Myconfig;     

        //MDANTONIO - 26/03/2019 - integrazione servizio garanzie - end
        
        // Insert B2C Client 
        Account TheClient1 = new Account();
        //TheClient.TECH_Company__c = 'AAI';
        TheClient1.NDG__c='0008280000001382';
        //TheClient.Nodes__c='004123;004123000001';
        //TheClient.RecordTypeName='B2B Client';
        RecordType PF_RT1 = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        TheClient1.RecordTypeId = PF_RT1.Id;
        
        TheClient1.LastName = 'Fracassetti';
        TheClient1.FirstName = 'Chiara';
        TheClient1.AAI_Codice_fiscale__c = 'FRCCHR65M51I079V';
        //TheClient1.RecordTypeName = 'B2C Client';
        
        

        List<Sobject> SoList = new List<Sobject>();
        Solist.add(TheClient1);
        Insert Solist;
        System.debug('+++++++RecordTypeDeveloperName' + TheClient1.RecordType.DeveloperName);

        
        //Inserting child records
        List<Sobject> SoList_CHILD = new List<Sobject>();
        //insertPOLIZZA
        InsurancePolicy__c Policy1 = new  InsurancePolicy__c();
        Policy1.Name='066905710';
        Policy1.CUID__c = TheClient1.Id;
        RecordType POL_RE = [SELECT id from RecordType where DeveloperName ='B2C_Motor' AND SobjectType='InsurancePolicy__c' Limit 1];   
        Policy1.RecordTypeId=POL_RE.Id; 
        Policy1.PolicyID__c='000001-000828000033-000005-066905710'; 
        
        
        
        
        SoList_CHILD.add(Policy1);
        
        insert SoList_CHILD;

        
        
        
        
        
    }
    
    static testMethod void checkGaranzieAAI() {
        test.startTest();

        InsurancePolicy__c Policy1 = [SELECT id, CUID__r.RecordType.DeveloperName, CUID__r.RecordType.Name, CUID__r.AAI_Codice_fiscale__c FROM InsurancePolicy__c WHERE PolicyID__c='000001-000828000033-000005-066905710' Limit 1];
        
        HTTP_Rest_Request_Mock_Test mockServer = new HTTP_Rest_Request_Mock_Test();
        mockServer.TestCase = 'Response1';
        Test.setMock(HttpCalloutMock.class, mockServer); 
        
        
        PageReference pageRef = Page.GaranzieView;       
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', Policy1.Id );
        GaranzieTable_Controller controller = new GaranzieTable_Controller(new ApexPages.StandardController(Policy1));    
        
        test.stopTest();
    }
    
    
    static testMethod void checkGaranzieAAI_2() {
        test.startTest();

        InsurancePolicy__c Policy1 = [SELECT id, CUID__r.RecordType.DeveloperName, CUID__r.RecordType.Name, CUID__r.AAI_Codice_fiscale__c FROM InsurancePolicy__c WHERE PolicyID__c='000001-000828000033-000005-066905710' Limit 1];
        
        HTTP_Rest_Request_Mock_Test mockServer = new HTTP_Rest_Request_Mock_Test();
        mockServer.TestCase = 'ERRORT300';
        Test.setMock(HttpCalloutMock.class, mockServer); 
        
        
        PageReference pageRef = Page.GaranzieView;       
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', Policy1.Id );
        GaranzieTable_Controller controller = new GaranzieTable_Controller(new ApexPages.StandardController(Policy1));    
        
        test.stopTest();
    }
    
    
    static testMethod void checkGaranzieAAI3() {
        test.startTest();

        InsurancePolicy__c Policy1 = [SELECT id, CUID__r.RecordType.DeveloperName, CUID__r.RecordType.Name, CUID__r.AAI_Codice_fiscale__c FROM InsurancePolicy__c WHERE PolicyID__c='000001-000828000033-000005-066905710' Limit 1];
        
        HTTP_Rest_Request_Mock_Test mockServer = new HTTP_Rest_Request_Mock_Test();
        mockServer.TestCase = 'Response2';
        Test.setMock(HttpCalloutMock.class, mockServer); 
        
        
        PageReference pageRef = Page.GaranzieView;       
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', Policy1.Id );
        GaranzieTable_Controller controller = new GaranzieTable_Controller(new ApexPages.StandardController(Policy1));    
        
        test.stopTest();
    }
    
}