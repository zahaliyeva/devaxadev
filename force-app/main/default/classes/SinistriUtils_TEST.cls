@IsTest
public class SinistriUtils_TEST {

    @testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        List<MPS_Code_Variables__c> codeVariables = new List<MPS_Code_Variables__c>();
        MPS_Code_Variables__c caRT = new MPS_Code_Variables__c(name = 'RecordTypeSinitri', value__c = 'Sinistri_AAI;Sinistri_Danni_Banca;');
        codeVariables.add(caRT);
        MPS_Code_Variables__c SLAMA = new MPS_Code_Variables__c(name = 'SinistriSLADefault', value__c = '99');
		codeVariables.add(SLAMA);
        insert codeVariables;
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('AXA Assistance - Lightning','SmartCenter Motor Advisor')];
        Id pAXAAssHD1;
        Id pCoHD1;
        
        if (profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'AXA Assistance - Lightning')
                {
                    pAXAAssHD1 = p.Id;
                }
                else if(p.Name == 'SmartCenter Motor Advisor')
                {
                    pCoHD1 = p.Id;
                }
            }
        } 
        List<String> userToShare = new List<String>();
        User HD1AXA = new User(Username                     = 'advisorHD1AXA@axa.test.com',
                            LastName                     = 'testuserHD1AXA',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD1AXA',
                            Email                        = 'test@testHD1AXA.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pAXAAssHD1,
                            UserPermissionsKnowledgeUser = true);
        insert HD1AXA;
        userToShare.add(HD1AXA.Id);
        User HD1CO = new User(Username                     = 'supportHD1CO@axa.test.com',
                            LastName                     = 'testuserHD1CO',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testHD1CO',
                            Email                        = 'test@testHD1CO.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pCoHD1,
                            UserPermissionsKnowledgeUser = true);
        insert HD1CO;
        userToShare.add(HD1CO.Id);
        
        
        
    }
    
    static testMethod void testmethod1(){
        test.StartTest();
        
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'Sinistri AAI');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='Sinistro Caring Angel',
                                                                            Sub_Category__c = 'Denuncia sinistro',
                                                                            Case_Origin__c = 'All',
                                                                            Customer_Service_Type__c = 'All',
                                                                            Distribution_Network__c = 'All',
                                                                            Case_Record_Type__c = 'Sinistri_AAI',
                                                                            SLA__c = 3);
            caseObj1 = new Case(
                Status    = 'Open',
                Origin    = 'Phone',
                LOB__c = 'Motor',
                OwnerId = HD1AXA.Id,
                Category__c = 'Sinistro Caring Angel',
                SubCategory__c = 'Denuncia sinistro',
                Subject = 'test',
                Description = 'test',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            system.debug('CASEOBJ ID : '+caseObj1);
            system.runAs(HD1AXA)
            {
                Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                      CaseStatus__c = 'Open',
                                                                      UserProfile__c = 'Coda HD1 AXA Assistance',
                                                                      UserRole__c = '',
                                                                      Owner__c = HD1AXA.Id,
                                                                      SupportStartDate__c = system.now(),
                                                                      RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
                insert mlt;
                Milestone_Tracking__c mlt2 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                       CaseStatus__c = 'Open',
                                                                       UserProfile__c = 'Coda HD1 Customer Operation',
                                                                       UserRole__c = '',
                                                                       Owner__c = HD1CO.Id,
                                                                       SupportStartDate__c = system.now(),
                                                                       RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
                insert mlt2;
                
                test.stopTest();
                
                system.debug('hd1Id'+HD1AXA.Id);
                system.debug('hd2Id'+HD1CO.Id);
                system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
                system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
                SinistriUtils.runSinistriUtils = true;
                CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
                caseObj1.OwnerId = HD1CO.Id;
                system.debug('before Update -- ');
                update caseObj1;
            }
            
            
        }
        
    } 
    
    static testMethod void testmethod2(){
        test.StartTest();
        Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='Sinistro Caring Angel',
                                                                        Sub_Category__c = 'Denuncia sinistro',
                                                                        Case_Origin__c = 'All',
                                                                        Customer_Service_Type__c = 'All',
                                                                        Distribution_Network__c = 'All',
                                                                        Case_Record_Type__c = 'Sinistri_AAI',
                                                                        SLA__c = 3);
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'Sinistri AAI');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(
                OwnerId = HD1CO.Id,
                Status    = AP_Constants.caseStatusAssigned,
                Origin    = 'Phone',
                LOB__c = 'Motor',
                Category__c = 'Sinistro Caring Angel',
                SubCategory__c = 'Denuncia sinistro',
                Subject = 'test',
                Description = 'test',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusAssigned,
                                                                  UserProfile__c = 'HD1 AXA Assistance',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1AXA.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            insert mlt;
            
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('hd2Id'+HD1CO.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1AXA.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 

    static testMethod void testmethod3(){
        test.StartTest();
        Group testGroup = new Group(Name='Sinistri Danni Banca', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'Sinistri Danni Banca');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(Status    = AP_Constants.caseStatusAssigned,
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                OwnerId = testGroup.Id,
                                Category__c = 'Sinistro Caring Angel',
                                SubCategory__c = 'Denuncia sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'HD1 Customer Operation',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                            OwnerId = HD1CO.Id);
            insert wrkTime;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusAssigned,
                                                                  UserProfile__c = 'HD1 Customer Operation',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1CO.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                  Working_Time__c = wrkTime.Id);
            insert mlt;
            
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('hd2Id'+HD1CO.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1CO.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod4(){
        test.StartTest();
        Group testGroup = new Group(Name='Sinistri AAI', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'Sinistri AAI');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(Status    = AP_Constants.caseStatusAssigned,
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                OwnerId = testGroup.Id,
                                Category__c = 'Sinistro Caring Angel',
                                SubCategory__c = 'Denuncia sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());            
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusAssigned,
                                                                  UserProfile__c = 'HD1 Customer Operation',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1CO.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            insert mlt;
            
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('hd2Id'+HD1CO.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1CO.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod5(){
        test.StartTest();
        Group testGroup = new Group(Name='Sinistri AAI', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(Status    = AP_Constants.caseStatusassigned,
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                OwnerId = testGroup.Id,
                                Category__c = 'Sinistro Caring Angel',
                                SubCategory__c = 'Denuncia sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId()); 
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'Coda HD1 AXA Assistance',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimCoda).getRecordTypeId(),
                                                            OwnerId = HD1AXA.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusassigned,
                                                                  UserProfile__c = 'Coda HD1 AXA Assistance',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1AXA.Id,
                                                                  TimeSpent__c = 0,
                                                                  SupportStartDate__c = system.now().addHours(-2),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda,
                                                                  Working_Time__c = wrkTime.Id
                                                                 );
            insert mlt;
            Working_Times__c wrkTimeHD1 = new Working_Times__c(Case__c = caseObj1.Id,
                                                               UserRole__c = '',
                                                               UserProfile__c = 'HD1 AXA Assistance',
                                                               Time_Spent__c = 0.034,
                                                               RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                               OwnerId = HD1AXA.Id);
            insert wrkTimeHD1;
            
            
            Milestone_Tracking__c mltHD1 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                     CaseStatus__c = AP_Constants.caseStatusInformationReceived,
                                                                     UserProfile__c = 'HD1 AXA Assistance',
                                                                     UserRole__c = '',
                                                                     Owner__c = HD1AXA.Id,
                                                                     TimeSpent__c = 0,
                                                                     SupportStartDate__c = system.now().addHours(-2),
                                                                     RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                     Working_Time__c = wrkTimeHD1.Id
                                                                    );
            insert mltHD1;
        }
        system.runAs(HD1AXA)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = AP_Constants.caseStatusInformationReceived;
            caseObj1.OwnerId = HD1AXA.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod7(){
        test.StartTest();
        Group testGroup = new Group(Name='Sinistri AAI', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'Sinistri AAI');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(Status    = AP_Constants.caseStatusAssigned,
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                OwnerId = HD1AXA.Id,
                                Category__c = 'Sinistro Caring Angel',
                                SubCategory__c = 'Denuncia sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusInformationReceived,
                                                                  UserProfile__c = 'HD1 Customer Operation',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1CO.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            
            Map<String,Case> OldValues = new Map<String,Case>();
            OldValues.put(String.valueOf(caseObj1.Id),caseObj1);
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('hd2Id'+HD1CO.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = AP_Constants.caseStatusAssigned;
            system.debug('before Update -- ');
            update caseObj1;
            
            Set<id> setId = new Set<Id>(); 
            setId.add(caseObj1.Id);
            Set<String> HD1AXAProfileSet = new Set<String>();
            HD1AXAProfileSet.add('AXA Assistance');
            Set<String> HD1COProfileSet = new Set<String>();
            HD1COProfileSet.add('SmartCenter Motor Advisor');
            System.enqueuejob(new SinistriUtils.updateCase(setId,OldValues,HD1AXAProfileSet,HD1COProfileSet));
        }
    }
    
    static testMethod void testmethod8(){
        test.StartTest();
        Group testGroup = new Group(Name='Sinistri AAI', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'Sinistri AAI');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(Status    = AP_Constants.caseStatusAssigned,
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                OwnerId = HD1AXA.Id,
                                Category__c = 'Sinistro Caring Angel',
                                SubCategory__c = 'Denuncia sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusInformationReceived,
                                                                  UserProfile__c = 'HD1 Customer Operation',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1CO.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            
            Map<String,Case> OldValues = new Map<String,Case>();
            OldValues.put(String.valueOf(caseObj1.Id),caseObj1);
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('hd2Id'+HD1CO.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = AP_Constants.caseStatusAssigned;
            system.debug('before Update -- ');
            update caseObj1;
            
            Set<id> setId = new Set<Id>(); 
            setId.add(caseObj1.Id);
            Set<String> HD1AXAProfileSet = new Set<String>();
            HD1AXAProfileSet.add('AXA Assistance');
            Set<String> HD1COProfileSet = new Set<String>();
            HD1COProfileSet.add('SmartCenter Motor Advisor');
            System.enqueuejob(new SinistriUtils.updateCaseMilestone(setId,OldValues,HD1AXAProfileSet,HD1COProfileSet));
        }
    }
    
    static testMethod void testmethod6(){
        test.StartTest();
        Group testGroup = new Group(Name='Sinistri AAI', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(Status    = AP_Constants.caseStatusAssigned,
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                OwnerId = HD1AXA.Id,
                                Category__c = 'Sinistro Caring Angel',
                                SubCategory__c = 'Denuncia sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId()); 
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
        }
        system.runAs(uteTec)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = testGroup.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod9(){
        test.StartTest();
        Group testGroup = new Group(Name='Sinistri AAI', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    HD1AXA      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1AXA@axa.test.com' LIMIT 1];
        User    HD1CO      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1CO@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1AXA.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(Status    = AP_Constants.caseStatusassigned,
                                Origin    = 'Phone',
                                LOB__c = 'Motor',
                                OwnerId = testGroup.Id,
                                Category__c = 'Sinistro Caring Angel',
                                SubCategory__c = 'Denuncia sinistro',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sinistri AAI').getRecordTypeId()); 
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'Coda HD1 AXA Assistance',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimCoda).getRecordTypeId(),
                                                            OwnerId = HD1AXA.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusassigned,
                                                                  UserProfile__c = 'Coda HD1 AXA Assistance',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1AXA.Id,
                                                                  TimeSpent__c = 0,
                                                                  SupportStartDate__c = system.now().addHours(-2),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda,
                                                                  Working_Time__c = wrkTime.Id
                                                                 );
            insert mlt;
            
        }
        system.runAs(HD1AXA)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1AXA.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            SinistriUtils.runSinistriUtilsFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1AXA.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
   
}