@isTest
public class LeadInsert_TEST {

    @testSetup static void setup(){
        
        //fill custom setting MappingASA__c
        /*MappingASA__c mapASA = new MappingASA__c();
        mapASA.Name = '2';
        mapASA.ASA__c ='Salute';
        mapASA.Codice_ASA__c = 2;
        mapASA.ASA_Description__c ='2 - Salute';
        
        Database.insert(mapASA);*/

        //CAPOBIANCO_A 05/01/2018 -- START

        Id sysAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' ].Id; 
        Id aaiRole = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'].Id;

        User userAdmin = new User(Username = 'testLeadInsert@italy.axa.test.com',
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

        //fill custom setting MappingASA__c
        System.runAs(userAdmin)
        {
            MappingASA__c mapASA = new MappingASA__c();
            mapASA.Name = '2';
            mapASA.ASA__c ='Salute';
            mapASA.Codice_ASA__c = 2;
            mapASA.ASA_Description__c ='2 - Salute';
            
            Database.insert(mapASA);
        }
        //CAPOBIANCO_A 05/01/2018 -- END
    }
    
    
    static testmethod void LeadInsertGetters(){

        system.debug('#### Start of method LeadInsertGetters');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.getASAList();
            
            system.assertEquals(null, ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void LeadInsertVoids(){
        system.debug('#### Start of method LeadInsertVoids');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.validateFields('phone','123123123');
            ctrl.validateFields('prefix','123');
            
            test.stopTest();
        }
    }
    
    
    static testmethod void fromLeadPage_1(){
        
        system.debug('#### Start of method fromLeadPage_1');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = 'testLastName';
            ctrl.LeadToInsert.Company = 'testCompany';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.SaveLead();
            
            system.assertEquals('', ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_2(){
        
        system.debug('#### Start of method fromLeadPage_2');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = '';
            ctrl.LeadToInsert.LastName = '';
            ctrl.LeadToInsert.Company = '';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.SaveLead();
            
            system.assertEquals(' Compilare almeno uno tra i campi - Nome e Cognome o Ragione Sociale<br/>', ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_3(){
        
        system.debug('#### Start of method fromLeadPage_3');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = 'testLastName';
            ctrl.LeadToInsert.Company = 'testCompany';
            ctrl.LeadToInsert.Phone = '';
            ctrl.LeadToInsert.Email = '';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.SaveLead();
            
            system.assertEquals(' Compilare almeno uno tra i campi - Telefono o Email'+'<br/>', ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_4(){
        
        system.debug('#### Start of method fromLeadPage_4');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = 'testLastName';
            ctrl.LeadToInsert.Company = 'testCompany';
            ctrl.LeadToInsert.Phone = '';
            ctrl.LeadToInsert.Email = 'testEmail';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.SaveLead();
            
            system.assertEquals(' Attenzione: l\'indirizzo email inserito non è scritto in forma corretta'+'<br/>', ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_5(){
        
        system.debug('#### Start of method fromLeadPage_5');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = '';
            ctrl.LeadToInsert.LastName = 'testLastName';
            ctrl.LeadToInsert.Company = '';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.SaveLead();
            
            system.assertEquals('Compilare tutti i campi obbligatori: - Nome', ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_6(){
        
        system.debug('#### Start of method fromLeadPage_6');
        
        PageReference pageRef = Page.LeadInsert;
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = '';
            ctrl.LeadToInsert.Company = '';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '0';
            
            ctrl.SaveLead();
            
            system.assertEquals('Compilare tutti i campi obbligatori: - Cognome - ASA', ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_7(){
        
        system.debug('#### Start of method fromLeadPage_7');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = 'testLastName';
            ctrl.LeadToInsert.Company = 'testCompany';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '0';
            
            ctrl.SaveLead();
            
            system.assertEquals('Compilare tutti i campi obbligatori: - ASA', ctrl.pageMessage);
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_8(){
        
        system.debug('#### Start of method fromLeadPage_8');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = 'testLastName';
            ctrl.LeadToInsert.Company = 'testCompany';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.SaveLead();
            ctrl.SaveLead();
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_9(){
        
        system.debug('#### Start of method fromLeadPage_9');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = 'testLastName';
            ctrl.LeadToInsert.Company = 'testCompany';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.AddFields();
            
            test.stoptest();
        }
    }
    
    
    static testmethod void fromLeadPage_10(){
        
        system.debug('#### Start of method fromLeadPage_10');
        
        PageReference pageRef = Page.LeadInsert;       
        Test.setCurrentPage(pageRef);
        
        Lead emptyLead = new Lead();
        ApexPages.StandardController mycontroller = new ApexPages.StandardController(emptyLead);
        LeadInsertCtrl ctrl = new LeadInsertCtrl(mycontroller);
        
        User theAgent = [SELECT Id FROM User WHERE Username = 'testLeadInsert@italy.axa.test.com' LIMIT 1];
        
        system.runAs(theAgent){
            test.starttest();
            
            ctrl.LeadToInsert.FirstName = 'testFirstName';
            ctrl.LeadToInsert.LastName = '';
            ctrl.LeadToInsert.Company = '';
            ctrl.LeadToInsert.Phone = '334334334';
            ctrl.LeadToInsert.Email = 'test@mail.com';
            ctrl.LeadToInsert.ASA_Description__c = '2 - Salute';
            
            ctrl.AddFields();
            
            test.stoptest();
        }
    }
}