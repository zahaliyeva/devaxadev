@IsTest
public class MilestoneDurationCalculator_TEST {
    
    
    @testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        insert new MPS_Code_Variables__c(Name = 'ModelloDiAssistenzaSLADefault', value__c = '99');
        //OAVERSANO 27/03/2019 : AXA Assistance -- START
        insert new MPS_Code_Variables__c(Name = 'CaringAngelSLADefault', value__c = '99');
        insert new MPS_Code_Variables__c(Name = 'SinistriSLADefault', value__c = '99');
        //OAVERSANO 27/03/2019 : AXA Assistance -- END
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
        
        
        
    }
    
    
    static testMethod void testMilestoneTimeCalculator() {        
        
        Test.startTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        Configurazione_SLA_Case__c sla2 = new Configurazione_SLA_Case__c(Category__c ='AUTO',
                                                                         Sub_Category__c = 'Annullamenti',
                                                                         Case_Origin__c = 'Portale Assistenza',
                                                                         Customer_Service_Type__c = 'All',
                                                                         Distribution_Network__c = 'All',
                                                                         Case_Record_Type__c = 'Assistenza Agenti',
                                                                         SLA__c = 3,
                                                                         Rule_Active__c= true,
                                                                         SLA_for_Private_Customers__c = 4);
        insert sla2;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        System.runAs(uteTec)
        {
            RecordType ReId = [SELECT id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Assistenza_Agenti' AND SobjectType='Case' LIMIT 1];
            system.debug('ReId: '+reId);
            Case caseObj1 = new Case(ContactId = con.Id,
                                     AccountId = currentAcc.Id,
                                     Status    = 'Open',
                                     Origin    = 'Portale Assistenza',
                                     User__c = agent.Id,
                                     LOB__c = 'IT',
                                     OwnerId = HD1.Id,
                                     Category__c = 'AUTO',
                                     SubCategory__c = 'Annullamenti',
                                     Subject = 'test',
                                     Description = 'test',
                                     RecordTypeId = ReId.Id);
            insert caseObj1;
            Case cs = [SELECT id, RecordType.Name, Category__c, SubCategory__c, Customer_Service_Model__c, Distribution_Network__c, 
                       Origin
                       FROM Case WHERE Id = :caseObj1.Id];  
            system.debug('cs: '+cs.RecordType.Name);
            
            MilestoneDurationCalculator calculator = new MilestoneDurationCalculator();
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            
        }
        Test.stopTest();
        
    }
    
    static testMethod void testMilestoneTimeCalculator2() {        
        
        Test.startTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='AUTO',
                                                                        Sub_Category__c = 'Annullamenti',
                                                                        Case_Origin__c = 'All',
                                                                        Customer_Service_Type__c = 'All',
                                                                        Distribution_Network__c = 'All',
                                                                        Case_Record_Type__c = 'Assistenza Agenti',
                                                                        SLA__c = 3,
                                                                        Rule_Active__c = true,
                                                                        SLA_for_Private_Customers__c = 4);
        insert sla;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        System.runAs(uteTec)
        {
            RecordType ReId = [SELECT id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Assistenza_Agenti' AND SobjectType='Case' LIMIT 1];
            system.debug('ReId: '+reId);
            Case caseObj1 = new Case(ContactId = con.Id,
                                     AccountId = currentAcc.Id,
                                     Status    = 'Open',
                                     Origin    = 'Portale Assistenza',
                                     User__c = agent.Id,
                                     LOB__c = 'IT',
                                     OwnerId = HD1.Id,
                                     Category__c = 'AUTO',
                                     SubCategory__c = 'Annullamenti',
                                     Subject = 'test',
                                     Description = 'test',
                                     RecordTypeId = ReId.Id);
            insert caseObj1;
            Case cs = [SELECT id, RecordType.Name, Category__c, SubCategory__c, Customer_Service_Model__c, Distribution_Network__c, 
                       Origin
                       FROM Case WHERE Id = :caseObj1.Id];  
            system.debug('cs: '+cs.RecordType.Name);
            
            MilestoneDurationCalculator calculator = new MilestoneDurationCalculator();
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            
        }
        Test.stopTest();
        
    }
    
    static testMethod void testMilestoneTimeCalculator3() {        
        
        Test.startTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='AUTO',
                                                                        Sub_Category__c = 'Annullamenti',
                                                                        Case_Origin__c = 'All',
                                                                        Customer_Service_Type__c = 'All',
                                                                        Distribution_Network__c = 'MPS',
                                                                        Case_Record_Type__c = 'Assistenza Agenti',
                                                                        SLA__c = 3,
                                                                        Rule_Active__c = true,
                                                                        SLA_for_Private_Customers__c = 4);
        insert sla;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        System.runAs(uteTec)
        {
            RecordType ReId = [SELECT id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Assistenza_Agenti' AND SobjectType='Case' LIMIT 1];
            system.debug('ReId: '+reId);
            Case caseObj1 = new Case(ContactId = con.Id,
                                     AccountId = currentAcc.Id,
                                     Status    = 'Open',
                                     Origin    = 'Portale Assistenza',
                                     User__c = agent.Id,
                                     LOB__c = 'IT',
                                     OwnerId = HD1.Id,
                                     Category__c = 'AUTO',
                                     SubCategory__c = 'Annullamenti',
                                     Subject = 'test',
                                     Description = 'test',
                                     Distribution_Network__c='MPS',
                                     RecordTypeId = ReId.Id);
            insert caseObj1;
            Case cs = [SELECT id, RecordType.Name, Category__c, SubCategory__c, Customer_Service_Model__c, Distribution_Network__c, 
                       Origin
                       FROM Case WHERE Id = :caseObj1.Id];  
            system.debug('cs: '+cs.RecordType.Name);
            
            MilestoneDurationCalculator calculator = new MilestoneDurationCalculator();
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            
        }
        Test.stopTest();
        
    }
    
    static testMethod void testMilestoneTimeCalculator4() {        
        
        Test.startTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='AUTO',
                                                                        Sub_Category__c = 'Annullamenti',
                                                                        Case_Origin__c = 'Portale Assistenza',
                                                                        Customer_Service_Type__c = 'All',
                                                                        Distribution_Network__c = 'MPS',
                                                                        Case_Record_Type__c = 'Assistenza Agenti',
                                                                        SLA__c = 3,
                                                                        Rule_Active__c = true,
                                                                        SLA_for_Private_Customers__c = 4);
        insert sla;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        System.runAs(uteTec)
        {
            RecordType ReId = [SELECT id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Assistenza_Agenti' AND SobjectType='Case' LIMIT 1];
            system.debug('ReId: '+reId);
            Case caseObj1 = new Case(ContactId = con.Id,
                                     AccountId = currentAcc.Id,
                                     Status    = 'Open',
                                     Origin    = 'Portale Assistenza',
                                     User__c = agent.Id,
                                     LOB__c = 'IT',
                                     OwnerId = HD1.Id,
                                     Category__c = 'AUTO',
                                     SubCategory__c = 'Annullamenti',
                                     Subject = 'test',
                                     Description = 'test',
                                     Distribution_Network__c = 'MPS',
                                     RecordTypeId = ReId.Id);
            insert caseObj1;
            Case cs = [SELECT id, RecordType.Name, Category__c, SubCategory__c, Customer_Service_Model__c, Distribution_Network__c, 
                       Origin
                       FROM Case WHERE Id = :caseObj1.Id];  
            system.debug('cs: '+cs.RecordType.Name);
            
            MilestoneDurationCalculator calculator = new MilestoneDurationCalculator();
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            
        }
        Test.stopTest();
        
    }
    
    static testMethod void testMilestoneTimeCalculator5() {        
        
        Test.startTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        System.runAs(uteTec)
        {
            RecordType ReId = [SELECT id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Assistenza_Agenti' AND SobjectType='Case' LIMIT 1];
            system.debug('ReId: '+reId);
            Case caseObj1 = new Case(ContactId = con.Id,
                                     AccountId = currentAcc.Id,
                                     Status    = 'Open',
                                     Origin    = 'Portale Assistenza',
                                     User__c = agent.Id,
                                     LOB__c = 'IT',
                                     OwnerId = HD1.Id,
                                     Category__c = 'AUTO',
                                     SubCategory__c = 'Annullamenti',
                                     Subject = 'test',
                                     Description = 'test',
                                     Distribution_Network__c = 'MPS',
                                     RecordTypeId = ReId.Id);
            insert caseObj1;
            Case cs = [SELECT id, RecordType.Name, Category__c, SubCategory__c, Customer_Service_Model__c, Distribution_Network__c, 
                       Origin
                       FROM Case WHERE Id = :caseObj1.Id];  
            system.debug('cs: '+cs.RecordType.Name);
            
            MilestoneDurationCalculator calculator = new MilestoneDurationCalculator();
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            
        }
        Test.stopTest();
        
    }
    
    //OAVERSANO 03/12/2018 : Caring Angel -- START
    static testMethod void testMilestoneTimeCalculator6() {        
        
        Test.startTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        System.runAs(uteTec)
        {
            RecordType ReId = [SELECT id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Caring_Angel' AND SobjectType='Case' LIMIT 1];
            system.debug('ReId: '+reId);
            Case caseObj1 = new Case(ContactId = con.Id,
                                     AccountId = currentAcc.Id,
                                     Status    = 'Open',
                                     Origin    = 'Phone',
                                     User__c = agent.Id,
                                     OwnerId = HD1.Id,
                                     Category__c = 'AUTO',
                                     SubCategory__c = 'Annullamenti',
                                     Subject = 'test',
                                     Description = 'test',
                                     Distribution_Network__c = 'MPS',
                                     RecordTypeId = ReId.Id);
            insert caseObj1;
            Case cs = [SELECT id, RecordType.Name, Category__c, SubCategory__c, Customer_Service_Model__c, Distribution_Network__c, 
                       Origin
                       FROM Case WHERE Id = :caseObj1.Id];  
            system.debug('cs: '+cs.RecordType.Name);
            
            MilestoneDurationCalculator calculator = new MilestoneDurationCalculator();
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            
        }
        Test.stopTest();
        
    }
    //OAVERSANO 03/12/2018 : Caring Angel -- END
    
    //OAVERSANO 27/03/2019 : AXA Assistance -- START
    static testMethod void testMilestoneTimeCalculator7() {        
        
        Test.startTest();
        MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
        if(mtLst.size() == 0) { return; }
        MilestoneType mt = mtLst[0];
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        System.runAs(uteTec)
        {
            RecordType ReId = [SELECT id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Sinistri_AAI' AND SobjectType='Case' LIMIT 1];
            system.debug('ReId: '+reId);
            Case caseObj1 = new Case(ContactId = con.Id,
                                     AccountId = currentAcc.Id,
                                     Status    = 'Open',
                                     Origin    = 'Phone',
                                     User__c = agent.Id,
                                     OwnerId = HD1.Id,
                                     Category__c = 'AUTO',
                                     SubCategory__c = 'Annullamenti',
                                     Subject = 'test',
                                     Description = 'test',
                                     Distribution_Network__c = 'MPS',
                                     RecordTypeId = ReId.Id);
            insert caseObj1;
            Case cs = [SELECT id, RecordType.Name, Category__c, SubCategory__c, Customer_Service_Model__c, Distribution_Network__c, 
                       Origin
                       FROM Case WHERE Id = :caseObj1.Id];  
            system.debug('cs: '+cs.RecordType.Name);
            
            MilestoneDurationCalculator calculator = new MilestoneDurationCalculator();
            Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(cs.Id, mt.Id);
            
        }
        Test.stopTest();
        
    }
    //OAVERSANO 27/03/2019 : AXA Assistance -- END
}