@istest
public class OpportunityInsert_TEST {
    
    static list<Opportunity> oppList;
    static User userAdmin;
    static map<String,Id> opportunity_developerIdMap;
    static id recordtypeOpp {get;set;}
    
    
    @testSetup static void setup() {

        //CAPOBIANCO_A 05/01/2018 -- START

        Id sysAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' ].Id; 
        Id aaiRole = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'].Id;

        User userAdmin = new User(Username = 'testOppInsert@italy.axa.test.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = sysAdminProfileId,
                            UserRoleId = aaiRole,
                            UserPermissionsKnowledgeUser=true);
        insert userAdmin;


        System.runAs(userAdmin)
        {
        //CAPOBIANCO_A 05/01/2018 -- END
            Account myAccount = new Account();
            
            myAccount.NDG__c='0008280000001138';
            RecordType PF_RT = [SELECT Id from RecordType where DeveloperName ='B2C_Client' Limit 1];
            myAccount.RecordTypeId = PF_RT.Id;
            myAccount.LastName = 'Rossi';
            myAccount.FirstName = 'Maria';
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
            Date myDate = Date.newInstance(2019, 2, 17); 
            
            Database.insert(myAccount);
            
            
            
            Contact myContact = new Contact();
            
            myContact.LastName = 'Serger';
            RecordType ContactRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2B_Contacts' Limit 1];
            myContact.RecordTypeId = ContactRT.Id;
            
            Database.insert(myContact);
            
            
            
            RecordType CampaignRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Performa_campaign' Limit 1];
            
            
            Campaign myCampaign = new Campaign();
            
            myCampaign.Name = 'myTestCampaign';
            myCampaign.Status = 'Planned';
            myCampaign.Type = 'TCM';
            myCampaign.RecordTypeId = CampaignRT.Id;
            
            Database.insert(myCampaign);
            
            
            Campaign myCampaign2 = new Campaign();
            
            myCampaign2.Name = 'myTestCampaign2';
            myCampaign2.Status = 'Planned';
            myCampaign2.Type = 'TCM';
            myCampaign2.ASA__c = '2 - Salute';
            myCampaign2.RecordTypeId = CampaignRT.Id;
            
            Database.insert(myCampaign2);
            
            
            //fill custom setting MappingASA__c
            MappingASA__c mapASA = new MappingASA__c();
            mapASA.Name = '2';
            mapASA.ASA__c ='Salute';
            mapASA.Codice_ASA__c = 2;
            mapASA.ASA_Description__c ='2 - Salute';
            
            Database.insert(mapASA);
        }
    }
    
    
    static testmethod void OpportunityInsertGetters(){

        system.debug('#### Start of method OpportunityInsertGetters');
        
        PageReference pageRef = Page.OpportunityInsert;       
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.getASAList();
            
            system.assertEquals(null, ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void OpportunityInsertVoids(){
        system.debug('#### Start of method OpportunityInsertVoids');
        
        PageReference pageRef = Page.OpportunityInsert;       
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Name FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.saveAccountId();
            ctrl.deleteAccountId();
            OpportunityInsertCtrl.getAccountObjectKey();
            OpportunityInsertCtrl.searchAccount(a.Name);
            
            test.stopTest();
        }
    }
	
    
    static testmethod void fromOpportunityPage_1(){
        
        system.debug('#### Start of method fromOpportunityPage_1');

        PageReference pageRef = Page.OpportunityInsert;
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.OppToInsert.AccountId = a.Id;
            ctrl.OppToInsert.ASA_Description__c = '2 - Salute';
            ctrl.SaveOpportunity();
            
            system.assertEquals(null, ctrl.pageMessage);
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromOpportunityPage_2(){
        
        system.debug('#### Start of method fromOpportunityPage_2');
        
        PageReference pageRef = Page.OpportunityInsert;       
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.OppToInsert.AccountId = a.Id;
            ctrl.OppToInsert.ASA_Description__c = '0';
            ctrl.SaveOpportunity();
            
            system.assertEquals('Compilare tutti i campi obbligatori: ASA', ctrl.pageMessage);
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromOpportunityPage_3(){
        
        system.debug('#### Start of method fromOpportunityPage_3');
        
        PageReference pageRef = Page.OpportunityInsert;       
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.OppToInsert.AccountId = a.Id;
            ctrl.OppToInsert.ASA_Description__c = null;
            ctrl.SaveOpportunity();
            
            system.assertEquals('Compilare tutti i campi obbligatori: ASA', ctrl.pageMessage);
            
            test.stopTest();
        }
    }
 
    
    static testmethod void fromOpportunityPage_4(){
        
        system.debug('#### Start of method fromOpportunityPage_4');

        PageReference pageRef = Page.OpportunityInsert;       
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        System.runAs(theAgent) {
            test.starttest();

            ctrl.OppToInsert.AccountId = null;
            ctrl.OppToInsert.ASA_Description__c = '2 - Salute';
            ctrl.SaveOpportunity();
            
            system.assertEquals('Compilare tutti i campi obbligatori: Nome Cliente', ctrl.pageMessage);
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromOpportunityPage_5(){
        
        system.debug('#### Start of method fromOpportunityPage_5');
        
        PageReference pageRef = Page.OpportunityInsert;       
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.OppToInsert.AccountId = null;
            ctrl.OppToInsert.ASA_Description__c = '0';
            ctrl.SaveOpportunity();
            
            system.assertEquals('Compilare tutti i campi obbligatori: Nome Cliente - ASA', ctrl.pageMessage);
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromOpportunityPage_6(){
        
        system.debug('#### Start of method fromOpportunityPage_6');
        
        PageReference pageRef = Page.OpportunityInsert;       
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.OppToInsert.AccountId = null;
            ctrl.OppToInsert.ASA_Description__c = null;
            ctrl.SaveOpportunity();
            
            system.assertEquals('Compilare tutti i campi obbligatori: Nome Cliente - ASA', ctrl.pageMessage);
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromOpportunityPage_7(){
        
        system.debug('#### Start of method fromOpportunityPage_7');

        PageReference pageRef = Page.OpportunityInsert;
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.OppToInsert.AccountId = a.Id;
            ctrl.OppToInsert.ASA_Description__c = '2 - Salute';
            ctrl.SaveOpportunity();
            ctrl.SaveOpportunity();
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromAccountPage_1(){
        
        system.debug('#### Start of method fromAccountPage_1');
        
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        string URL = '/apex/OpportunityInsert?accid=' + a.Id;
        PageReference pageRef2 = new PageReference(URL);
        Test.setCurrentPage(pageRef2);
                
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.NewOpportunityfromAccount();
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromAccountPage_2(){
        
        system.debug('#### Start of method fromAccountPage_2');
        
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        string URL = '/apex/OpportunityInsert?accid=' + a.Id;
        PageReference pageRef2 = new PageReference(URL);
        Test.setCurrentPage(pageRef2);
                
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.NewOpportunityfromAccount();
            ctrl.NewOpportunityfromAccount();
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromAccountPage_3(){
        
        system.debug('#### Start of method fromAccountPage_3');
        
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE FirstName = 'Maria' LIMIT 1];
        
        string URL = '/apex/OpportunityInsert?accid=' + a.Id;
        PageReference pageRef2 = new PageReference(URL);
        Test.setCurrentPage(pageRef2);
                
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        ctrl.AccountId = null;
        ctrl.CampaignId = null;
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.NewOpportunityfromAccount();
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromCampaignPage_1(){
        
        system.debug('#### Start of method fromCampaignPage_1');
        
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Contact myContact = [SELECT Id FROM Contact WHERE LastName = 'Serger' LIMIT 1];
        Campaign myCampaign = [SELECT Id FROM Campaign WHERE Name = 'myTestCampaign' LIMIT 1];
        
        PageReference pageRef = Page.OpportunityInsert;
        pageRef.getParameters().put('ContactId',myContact.Id);
        pageRef.getParameters().put('CampaignId',myCampaign.Id);
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.NewOpportunityfromAccount();
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromCampaignPage_2(){
        
        system.debug('#### Start of method fromCampaignPage_2');
        
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Contact myContact = [SELECT Id FROM Contact WHERE LastName = 'Serger' LIMIT 1];
        Campaign myCampaign = [SELECT Id FROM Campaign WHERE Name = 'myTestCampaign2' LIMIT 1];
        
        PageReference pageRef = Page.OpportunityInsert;
        pageRef.getParameters().put('ContactId',myContact.Id);
        pageRef.getParameters().put('CampaignId',myCampaign.Id);
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.NewOpportunityfromAccount();
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromCampaignPage_3(){
        
        system.debug('#### Start of method fromCampaignPage_2');
        
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testOppInsert@italy.axa.test.com' LIMIT 1];
        Contact myContact = [SELECT Id FROM Contact WHERE LastName = 'Serger' LIMIT 1];
        Campaign myCampaign = [SELECT Id FROM Campaign WHERE Name = 'myTestCampaign' LIMIT 1];
        
        PageReference pageRef = Page.OpportunityInsert;
        pageRef.getParameters().put('ContactId',myContact.Id);
        pageRef.getParameters().put('CampaignId',myCampaign.Id);
        Test.setCurrentPage(pageRef);
        
        Opportunity emptyOpp = new Opportunity();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyOpp);
        OpportunityInsertCtrl ctrl = new OpportunityInsertCtrl(mycontroller);
        
        
        System.runAs(theAgent) {
            test.starttest();
            
            ctrl.NewOpportunityfromAccount();
            ctrl.NewOpportunityfromAccount();
            
            test.stopTest();
        }
    }
    
}