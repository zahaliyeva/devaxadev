@IsTest
public class ModelloDiAssistenzaUtils_TEST {
    
    @testSetup static void setup() 
    {
      
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('NFE - AAI - Vendite Base','AAI - Supporto HD1 - Lightning','AAI - Supporto HD2','AAI - Supporto HD1 BIZ - Lightning','AAI - Supporto HD2 BIZ','AAI - Supervisor Supporto HD1 Contabilità - Lightning','AAI - Supervisor Supporto HD1 Contabilita - Lightning')];//OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
        Id pAgent;
        Id pHD1;
        Id pHD2;
        Id pHD1BIZ;
        Id pHD2BIZ;
        Id pHD1Contabilita; //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
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
                else if(p.Name == 'AAI - Supporto HD1 BIZ - Lightning')
                {
                    pHD1BIZ = p.Id;
                }
                else if(p.Name == 'AAI - Supporto HD2 BIZ')
                {
                    pHD2BIZ = p.Id;
                }
                //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                else if(p.Name == 'AAI - Supervisor Supporto HD1 Contabilità - Lightning' || p.Name == 'AAI - Supervisor Supporto HD1 Contabilita - Lightning')
                {
                    pHD1Contabilita = p.Id;
                } 
                //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
            }
        } 
        //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        UserRole roleContabilita;
        UserRole roleContenzioso;
        System.runAs(uteTec)
        {
            roleContabilita = new UserRole(Name ='HD1 Contabilita');
            insert roleContabilita;
            roleContenzioso = new UserRole(Name ='HD1 Contenzioso');
            insert roleContenzioso;
            //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        }
        //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        List<String> userToShare = new List<String>();
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
        userToShare.add(HD1.Id);
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
        userToShare.add(HD2.Id);
        User HD1BIZ = new User(Username                     = 'supportHD1BIZ@axa.test.com',
                               LastName                     = 'testuserHD1BIZ',
                               LanguageLocaleKey            = 'it',
                               FirstName                    = 'testHD1BIZ',
                               Email                        = 'test@testHD1BIZ.com', 
                               Alias                        = 'testd',
                               TimeZoneSidKey               = 'Europe/Dublin',
                               LocaleSidKey                 = 'it_IT',
                               EmailEncodingKey             = 'UTF-8',
                               ProfileId                    = pHD1BIZ,
                               UserPermissionsKnowledgeUser = true);
        insert HD1BIZ;
        userToShare.add(HD1BIZ.Id);
        User HD2BIZ = new User(Username                     = 'supportHD2BIZ@axa.test.com',
                               LastName                     = 'testuserHD2BIZ',
                               LanguageLocaleKey            = 'it',
                               FirstName                    = 'testHD2BIZ',
                               Email                        = 'test@testHD2BIZ.com', 
                               Alias                        = 'testd',
                               TimeZoneSidKey               = 'Europe/Dublin',
                               LocaleSidKey                 = 'it_IT',
                               EmailEncodingKey             = 'UTF-8',
                               ProfileId                    = pHD2BIZ,
                               UserPermissionsKnowledgeUser = true);
        insert HD2BIZ;
        userToShare.add(HD2BIZ.Id);
        //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
        User HD1Contabilita = new User(Username                     = 'advisorHD1Contabilita@axa.test.com',
                                       LastName                     = 'testuserHD1Contabilita',
                                       LanguageLocaleKey            = 'it',
                                       FirstName                    = 'testHD1Contabilita',
                                       Email                        = 'test@testHD1Contabilita.com', 
                                       Alias                        = 'testd',
                                       TimeZoneSidKey               = 'Europe/Dublin',
                                       LocaleSidKey                 = 'it_IT',
                                       EmailEncodingKey             = 'UTF-8',
                                       ProfileId                    = pHD1,
                                       UserRoleId 					= roleContabilita.Id,
                                       UserPermissionsKnowledgeUser = true);
        insert HD1Contabilita;
        userToShare.add(HD1Contabilita.Id);
        User HD1ContabilitaSup = new User(Username       = 'supervisorHD1Contabilita@axa.test.com',
                            LastName                     = 'testSuperHD1Contabilita',
                            LanguageLocaleKey            = 'it',
                            FirstName                    = 'testSuperHD1Cont',
                            Email                        = 'Super@testHD1Contabilita.com', 
                            Alias                        = 'testd',
                            TimeZoneSidKey               = 'Europe/Dublin',
                            LocaleSidKey                 = 'it_IT',
                            EmailEncodingKey             = 'UTF-8',
                            ProfileId                    = pHD1Contabilita,
                            UserPermissionsKnowledgeUser = true);
        insert HD1ContabilitaSup;
        userToShare.add(HD1ContabilitaSup.Id);
        User HD1Contenzioso = new User(Username                     = 'advisorHD1Contenzioso@axa.test.com',
                                       LastName                     = 'testuserHD1Contenzioso',
                                       LanguageLocaleKey            = 'it',
                                       FirstName                    = 'testHD1Contenzioso',
                                       Email                        = 'test@testHD1Contenzioso.com', 
                                       Alias                        = 'testd',
                                       TimeZoneSidKey               = 'Europe/Dublin',
                                       LocaleSidKey                 = 'it_IT',
                                       EmailEncodingKey             = 'UTF-8',
                                       ProfileId                    = pHD1,
                                       UserRoleId 					= roleContenzioso.Id,
                                       UserPermissionsKnowledgeUser = true);
        insert HD1Contenzioso;
        userToShare.add(HD1Contenzioso.Id);
        
        MPS_Code_Variables__c assAgent;
        Account acct;
        Contact con;
        System.runAs(uteTec)
        {
            assAgent = new MPS_Code_Variables__c(name = 'RecordTypeAssistenzaAgenti', value__c = 'Assistenza_Agenti;');
            insert assAgent;
            MPS_Code_Variables__c bizsupcode = new MPS_Code_Variables__c(name = 'NMABizSupportoCode', value__c = 'Auto;Famiglia;Salute;Vita Assunzione;Vita Contabilità Previdenza;Vita Liquidazioni;Vita Ptf Collettive;Vita Ptf Individuali Risp e Prot;Vita Ptf Previdenza;Vita Sinistri Risp. e Prot.;');
            insert bizsupcode;
            MPS_Code_Variables__c sollAgenti = new MPS_Code_Variables__c(name = 'NMASollecitiAgenti', value__c = '1;2;3;');
            insert sollAgenti;
            MPS_Code_Variables__c sollsoluzioneAgenti = new MPS_Code_Variables__c(name = 'NMASollecitiSoluzioneAgenti', value__c = '1;');
            insert sollsoluzioneAgenti;
            acct = new Account(Name = 'SFDC Account');
            insert acct;
            Id accId     = acct.Id;
            List<AccountShare> accShareList = new List<AccountShare>();
            for(String s :userToShare )
            {
                AccountShare ashare = new AccountShare();
                ashare.UserOrGroupID = s;
                ashare.AccountId = acct.Id;
                ashare.AccountAccessLevel = 'Edit';
                ashare.OpportunityAccessLevel = 'Read';
                accShareList.add(ashare);
            }
            
            insert accShareList;
            con = new Contact(FirstName = 'test$$',
                              LastName  = 'Smith',
                              Phone     = '415.555.1212',
                              AccountId = accId);
            insert con;
            
        }
        Id conId = con.Id;
        //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        
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
        
    }
    
    static testMethod void testmethod1(){
        test.StartTest();
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='AUTO',
                                                                            Sub_Category__c = 'Annullamenti',
                                                                            Case_Origin__c = 'All',
                                                                            Customer_Service_Type__c = 'All',
                                                                            Distribution_Network__c = 'All',
                                                                            Case_Record_Type__c = 'Assistenza_Agenti',
                                                                            SLA__c = 3);
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Open',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Open',
                                                                  UserProfile__c = 'Coda HD1 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
            insert mlt;
            
            Milestone_Tracking__c mlt2 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                   CaseStatus__c = 'Open',
                                                                   UserProfile__c = 'Coda HD2 IT',
                                                                   UserRole__c = '',
                                                                   Owner__c = HD2.Id,
                                                                   SupportStartDate__c = system.now(),
                                                                   RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
            insert mlt2;
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD2.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod2(){
        test.StartTest();
        Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='AUTO',
                                                                        Sub_Category__c = 'Annullamenti',
                                                                        Case_Origin__c = 'Portale Assistenza',
                                                                        Customer_Service_Type__c = 'All',
                                                                        Distribution_Network__c = 'All',
                                                                        Case_Record_Type__c = 'Assistenza_Agenti',
                                                                        SLA__c = 3);
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Open',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD2.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Risposta Specialista',
                                                                  UserProfile__c = 'HD1 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            insert mlt;
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    static testMethod void testmethod3(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 IT', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = testGroup.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'HD1 IT',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                            OwnerId = HD1.Id);
            insert wrkTime;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Risposta Specialista',
                                                                  UserProfile__c = 'HD1 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                  Working_Time__c = wrkTime.Id);
            insert mlt;
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod4(){
        test.StartTest();
        Group testGroup = new Group(Name='HD2 Auto', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'In gestione Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = testGroup.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'In gestione Specialista',
                                                                  UserProfile__c = 'HD2 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD2.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            insert mlt;
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD2.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    /*static testMethod void testmethod5(){
test.StartTest();
Group testGroup = new Group(Name='HD2 Auto', type='Queue');
insert testGroup;

QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
insert testQueue;
User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
Account currentAcc = [SELECT Id FROM Account LIMIT 1];
Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
Case caseObj1 = new Case();
System.runAs(uteTec)
{
insert new MPS_Code_Variables__c(Name = 'ModelloDiAssistenzaSLADefault', Value__c = '34');
Group g = new Group(Name = 'AXA MPS - Advisors');
insert g;

GroupMember gm= new GroupMember(); 
gm.GroupId=g.id;
gm.UserOrGroupId = HD1.id;
insert gm; 
}
System.runAs(uteTec)                   
{
caseObj1 = new Case(ContactId = con.Id,
AccountId = currentAcc.Id,
Status    = 'Open',
Origin    = 'Portale Assistenza',
User__c =  agent.Id,
LOB__c = 'IT',
OwnerId = HD1.Id,
Category__c = 'AUTO',
SubCategory__c = 'Annullamenti',
Subject = 'test',
Description = 'test',
RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
CaseHandler.AfterUpdateNotDone = false;
CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
insert caseObj1;

Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
CaseStatus__c = 'Attesa Info Agente',
UserProfile__c = 'AGENT',
UserRole__c = '',
Owner__c = HD1.Id,
SupportStartDate__c = system.now(),
RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
insert mlt;

test.stopTest();
system.debug('hd1Id'+HD1.Id);
system.debug('hd2Id'+HD2.Id);
system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
caseObj1.Status = 'Attesa Info Agente';
system.debug('before Update -- ');
update caseObj1;


}

} */
    
    /*static testMethod void testmethod6(){
test.StartTest();
Group testGroup = new Group(Name='HD2 Auto', type='Queue');
insert testGroup;

QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
insert testQueue;
User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
Account currentAcc = [SELECT Id FROM Account LIMIT 1];
Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
Case caseObj1 = new Case();
System.runAs(uteTec)
{
Group g = new Group(Name = 'AXA MPS - Advisors');
insert g;

GroupMember gm= new GroupMember(); 
gm.GroupId=g.id;
gm.UserOrGroupId = HD1.id;
insert gm; 
}
System.runAs(uteTec)                   
{
caseObj1 = new Case(ContactId = con.Id,
AccountId = currentAcc.Id,
Status    = 'Open',
Origin    = 'Portale Assistenza',
User__c =  agent.Id,
LOB__c = 'IT',
OwnerId = HD2.Id,
Category__c = 'AUTO',
SubCategory__c = 'Annullamenti',
Subject = 'test',
Description = 'test',
RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
CaseHandler.AfterUpdateNotDone = false;
CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
insert caseObj1;

Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
CaseStatus__c = AP_Constants.caseStatusGestioneHD3,
UserProfile__c = 'HD3',
UserRole__c = '',
Owner__c = HD2.Id,
SupportStartDate__c = system.now(),
RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
insert mlt;

test.stopTest();
system.debug('hd1Id'+HD1.Id);
system.debug('hd2Id'+HD2.Id);
system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
CaseManagement.runCaseManagementAfterUpdateFROMtest = false;
caseObj1.Status = AP_Constants.caseStatusGestioneHD3;
caseObj1.OwnerId = HD2.Id;
system.debug('before Update -- ');
update caseObj1;


}

} */
    
    
    static testMethod void testmethod7(){
        test.StartTest();
        Group testGroup = new Group(Name='HD2 Auto', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'In gestione all\'HD3',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD2.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTimeHD3 = new Working_Times__c(Case__c = caseObj1.Id,
                                                               UserRole__c = '',
                                                               UserProfile__c = 'HD3',
                                                               Time_Spent__c = 0.034,
                                                               RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                               OwnerId = HD1.Id);
            insert wrkTimeHD3;
            Milestone_Tracking__c mltHD3 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                     CaseStatus__c = 'In gestione all\'HD3',
                                                                     UserProfile__c = 'HD3',
                                                                     UserRole__c = '',
                                                                     Owner__c = HD1.Id,
                                                                     SupportStartDate__c = system.now(),
                                                                     RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                     Working_Time__c = wrkTimeHD3.Id);
            insert mltHD3;
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'In gestione Specialista',
                                                                  UserProfile__c = 'HD2 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD2.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            insert mlt;
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = 'In gestione Specialista';
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod8(){
        test.StartTest();
        Group testGroup = new Group(Name='HD2 Auto', type='Queue');
        insert testGroup;
        
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
         GroupMember gm2= new GroupMember(); 
            gm2.GroupId=testGroup.id;
            gm2.UserOrGroupId = HD1.id;
            insert gm2; 
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'In gestione all\'HD3',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD2.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = testGroup.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod9(){
        test.StartTest();
        Group testGroup = new Group(Name='HD2 Auto', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Open',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD2.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = AP_Constants.caseStatusGestioneHD3;
            caseObj1.OwnerId = HD2.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    }
    
    static testMethod void testmethod10(){
        test.StartTest();
        Group testGroup = new Group(Name='HD2 Auto', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Open',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = 'Attesa Info Agente';
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod11(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 IT', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id, RecordTypeId FROM Account LIMIT 1];
        system.debug('RecordTypeId : '+currentAcc.RecordTypeId);
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = testGroup.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'HD1 IT',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                            OwnerId = HD1.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Risposta Specialista',
                                                                  UserProfile__c = 'Coda HD1 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda
                                                                 );
            insert mlt;
            
            Milestone_Tracking__c mlt2 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                   CaseStatus__c = 'Risposta Specialista',
                                                                   UserProfile__c = 'Coda HD2 IT',
                                                                   UserRole__c = '',
                                                                   Owner__c = HD2.Id,
                                                                   SupportStartDate__c = system.now(),
                                                                   RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
            insert mlt2;
        }
        system.runAs(HD1)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod12(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 IT', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = AP_Constants.caseStatusSoluzioneProposta,
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusSoluzioneRifiutata,
                                                                  UserProfile__c = 'HD1 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
            
            Map<String,Case> OldValues = new Map<String,Case>();
            OldValues.put(String.valueOf(caseObj1.Id),caseObj1);
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = AP_Constants.caseStatusSoluzioneRifiutata;
            system.debug('before Update -- ');
            update caseObj1;
            
            Set<id> setId = new Set<Id>(); 
            setId.add(caseObj1.Id);
            Set<String> AgentProfileSet = new Set<String>(); 
            AgentProfileSet.add('NFE - AAI - Vendite Base');
            Set<String> HD1ProfileSet = new Set<String>();
            HD1ProfileSet.add('AAI - Supporto HD1');
            Set<String> HD2ProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2');
            Set<String> HD1BIZProfileSet = new Set<String>();
            HD1ProfileSet.add('AAI - Supporto HD1 Biz');
            Set<String> HD2BIZProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
            Set<String> HD1ContabilitaProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            Set<String> HD1ContabilitaRoleSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            Set<String> HD1ContenziosoProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            Set<String> HD1ContenziosoRoleSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            //System.enqueuejob(new ModelloDiAssistenzaUtils.updateCase(setId,OldValues,AgentProfileSet,HD1ProfileSet,HD2ProfileSet,HD1BIZProfileSet,HD2BIZProfileSet));
            System.enqueuejob(new ModelloDiAssistenzaUtils.updateCase(setId,OldValues,AgentProfileSet,HD1ProfileSet,HD2ProfileSet,HD1BIZProfileSet,HD2BIZProfileSet,HD1ContabilitaProfileSet, HD1ContabilitaRoleSet, HD1ContenziosoProfileSet, HD1ContenziosoRoleSet));
            //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        }
        
    } 
    
    static testMethod void testmethod13(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 IT', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = AP_Constants.caseStatusSoluzioneProposta,
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTimeAGENT = new Working_Times__c(Case__c = caseObj1.Id,
                                                                 UserRole__c = '',
                                                                 UserProfile__c = 'AGENT',
                                                                 Time_Spent__c = 0.034,
                                                                 RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                                 OwnerId = HD1.Id);
            insert wrkTimeAGENT;
            Milestone_Tracking__c mltAGENT = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                       CaseStatus__c = AP_Constants.caseStatusSoluzioneProposta,
                                                                       UserProfile__c = 'AGENT',
                                                                       UserRole__c = '',
                                                                       Owner__c = HD1.Id,
                                                                       SupportStartDate__c = system.now(),
                                                                       RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                       Working_Time__c = wrkTimeAGENT.Id);
            insert mltAGENT;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'HD1 IT',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                            OwnerId = HD1.Id);
            insert wrkTime;
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = AP_Constants.caseStatusSoluzioneRifiutata,
                                                                  UserProfile__c = 'HD1 IT',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                  Working_Time__c = wrkTime.Id);
            insert mlt;
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = AP_Constants.caseStatusSoluzioneRifiutata;
            system.debug('before Update -- ');
            update caseObj1;
            
        }
        
    } 
    
    static testMethod void testmethod14(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 IT', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'AXA MPS - Advisors');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = AP_Constants.caseStatusSoluzioneProposta,
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Map<String,Case> OldValues = new Map<String,Case>();
            OldValues.put(String.valueOf(caseObj1.Id),caseObj1);
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            system.debug('hd2Id'+HD2.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = AP_Constants.caseStatusSoluzioneRifiutata;
            system.debug('before Update -- ');
            update caseObj1;
            
            Set<id> setId = new Set<Id>(); 
            setId.add(caseObj1.Id);
            Set<String> AgentProfileSet = new Set<String>(); 
            AgentProfileSet.add('NFE - AAI - Vendite Base');
            Set<String> HD1ProfileSet = new Set<String>();
            HD1ProfileSet.add('AAI - Supporto HD1');
            Set<String> HD2ProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2');
            Set<String> HD1BIZProfileSet = new Set<String>();
            HD1ProfileSet.add('AAI - Supporto HD1 Biz');
            Set<String> HD2BIZProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
            Set<String> HD1ContabilitaProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            Set<String> HD1ContabilitaRoleSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            Set<String> HD1ContenziosoProfileSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            Set<String> HD1ContenziosoRoleSet = new Set<String>();
            HD2ProfileSet.add('AAI - Supporto HD2 Biz');
            //System.enqueuejob(new ModelloDiAssistenzaUtils.updateCaseMilestone(setId,OldValues,AgentProfileSet,HD1ProfileSet,HD2ProfileSet,HD1BIZProfileSet,HD2BIZProfileSet));
            System.enqueuejob(new ModelloDiAssistenzaUtils.updateCaseMilestone(setId,OldValues,AgentProfileSet,HD1ProfileSet,HD2ProfileSet,HD1BIZProfileSet,HD2BIZProfileSet,HD1ContabilitaProfileSet, HD1ContabilitaRoleSet, HD1ContenziosoProfileSet, HD1ContenziosoRoleSet));
            //OAVERSANO 18/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
            
        }
        
    } 
    static testMethod void testmethod15(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 Biz Auto', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1BIZ@axa.test.com' LIMIT 1];
        User    HD2BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2BIZ@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1BIZ.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1BIZ.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'Coda HD1 BIZ',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                            OwnerId = HD1BIZ.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Risposta Specialista',
                                                                  UserProfile__c = 'Coda HD1 BIZ',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1BIZ.Id,
                                                                  SupportStartDate__c = system.now(),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda
                                                                 );
            insert mlt;
            
            Milestone_Tracking__c mlt2 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                   CaseStatus__c = 'Risposta Specialista',
                                                                   UserProfile__c = 'Coda HD2 BIZ',
                                                                   UserRole__c = '',
                                                                   Owner__c = HD2BIZ.Id,
                                                                   SupportStartDate__c = system.now(),
                                                                   RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
            insert mlt2;
        }
        system.runAs(HD1BIZ)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1BIZ.Id);
            system.debug('hd2Id'+HD2BIZ.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = 'Risposta Specialista';
            caseObj1.OwnerId = testGroup.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod16(){
        test.StartTest();
        Group testGroup = new Group(Name='HD2 Biz Auto', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1BIZ@axa.test.com' LIMIT 1];
        User    HD2BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2BIZ@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD2BIZ.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'In Gestione Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = testGroup.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'Coda HD2 BIZ',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimCoda).getRecordTypeId(),
                                                            OwnerId = HD2BIZ.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'In Gestione Specialista',
                                                                  UserProfile__c = 'Coda HD2 BIZ',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD2BIZ.Id,
                                                                  TimeSpent__c = 0,
                                                                  SupportStartDate__c = system.now().addHours(-2),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda,
                                                                  Working_Time__c = wrkTime.Id
                                                                 );
            insert mlt;
            Working_Times__c wrkTimeHD2 = new Working_Times__c(Case__c = caseObj1.Id,
                                                               UserRole__c = '',
                                                               UserProfile__c = 'HD2 BIZ',
                                                               Time_Spent__c = 0.034,
                                                               RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                               OwnerId = HD2BIZ.Id);
            insert wrkTimeHD2;
            
            
            Milestone_Tracking__c mltHD2 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                     CaseStatus__c = 'In Gestione Specialista',
                                                                     UserProfile__c = 'HD2 BIZ',
                                                                     UserRole__c = '',
                                                                     Owner__c = HD2BIZ.Id,
                                                                     TimeSpent__c = 0,
                                                                     SupportStartDate__c = system.now().addHours(-2),
                                                                     RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                     Working_Time__c = wrkTimeHD2.Id
                                                                    );
            insert mltHD2;
        }
        system.runAs(HD2BIZ)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1BIZ.Id);
            system.debug('hd2Id'+HD2BIZ.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = 'In Gestione Specialista';
            caseObj1.OwnerId = HD2BIZ.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    static testMethod void testmethod16HD1(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 Biz Auto', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1BIZ@axa.test.com' LIMIT 1];
        User    HD2BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2BIZ@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1BIZ.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = testGroup.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'Coda HD1 BIZ',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimCoda).getRecordTypeId(),
                                                            OwnerId = HD1BIZ.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Risposta Specialista',
                                                                  UserProfile__c = 'Coda HD1 BIZ',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1BIZ.Id,
                                                                  TimeSpent__c = 0,
                                                                  SupportStartDate__c = system.now().addHours(-2),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda,
                                                                  Working_Time__c = wrkTime.Id
                                                                 );
            insert mlt;
            Working_Times__c wrkTimeHD1 = new Working_Times__c(Case__c = caseObj1.Id,
                                                               UserRole__c = '',
                                                               UserProfile__c = 'HD1 BIZ',
                                                               Time_Spent__c = 0.034,
                                                               RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                               OwnerId = HD1BIZ.Id);
            insert wrkTimeHD1;
            
            
            Milestone_Tracking__c mltHD1 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                     CaseStatus__c = 'Risposta Specialista',
                                                                     UserProfile__c = 'HD1 BIZ',
                                                                     UserRole__c = '',
                                                                     Owner__c = HD1BIZ.Id,
                                                                     TimeSpent__c = 0,
                                                                     SupportStartDate__c = system.now().addHours(-2),
                                                                     RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                     Working_Time__c = wrkTimeHD1.Id
                                                                    );
            insert mltHD1;
        }
        system.runAs(HD1BIZ)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1BIZ.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = 'Risposta Specialista';
            caseObj1.OwnerId = HD1BIZ.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod17(){
        test.StartTest();
        
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1BIZ@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            test.stopTest();
            system.debug('hd1Id'+HD1BIZ.Id);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1BIZ.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod18(){
        test.StartTest();
        
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1BIZ@axa.test.com' LIMIT 1];
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1BIZ.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            test.stopTest();
            system.debug('hd1Id'+HD1.Id);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod19(){
        test.StartTest();
        
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1BIZ@axa.test.com' LIMIT 1];
        User    HD2BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2BIZ@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD1BIZ.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            test.stopTest();
            system.debug('hd1Id'+HD2BIZ.Id);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD2BIZ.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    static testMethod void testmethod20(){
        test.StartTest();
        
        
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD1BIZ@axa.test.com' LIMIT 1];
        User    HD2BIZ      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2BIZ@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'IT',
                                OwnerId = HD2BIZ.Id,
                                Category__c = 'AUTO',
                                SubCategory__c = 'Annullamenti',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            
            test.stopTest();
            system.debug('HD1BIZ'+HD1BIZ.Id);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.OwnerId = HD1BIZ.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    }    
    
    static testMethod void testmethod21HD1Contabilita(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 Contabilita', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1Contabilita      = [SELECT Id, ProfileId, Profile.Name, UserRole.Name FROM User WHERE Username = 'advisorHD1Contabilita@axa.test.com' LIMIT 1];
        User    HD1	     = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        ModellodiAssistenzaUtils.getDestinatario(HD1Contabilita.Profile.Name, HD1Contabilita.UserRole.Name, HD1Contabilita.Id);
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1Contabilita.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'Contabilità Danni',
                                OwnerId = testGroup.Id,
                                Category__c = 'AUTO',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'Coda HD1 Contabilita',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimCoda).getRecordTypeId(),
                                                            OwnerId = HD1Contabilita.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Risposta Specialista',
                                                                  UserProfile__c = 'Coda HD1 Contabilita',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1.Id,
                                                                  TimeSpent__c = 0,
                                                                  SupportStartDate__c = system.now().addHours(-2),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda,
                                                                  Working_Time__c = wrkTime.Id
                                                                 );
            insert mlt;
            Working_Times__c wrkTimeHD1 = new Working_Times__c(Case__c = caseObj1.Id,
                                                               UserRole__c = '',
                                                               UserProfile__c = 'HD1 Contabilita',
                                                               Time_Spent__c = 0.034,
                                                               RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                               OwnerId = HD1Contabilita.Id);
            insert wrkTimeHD1;
            
            
            Milestone_Tracking__c mltHD1 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                     CaseStatus__c = 'Risposta Specialista',
                                                                     UserProfile__c = 'HD1 Contabilita',
                                                                     UserRole__c = '',
                                                                     Owner__c = HD1Contabilita.Id,
                                                                     TimeSpent__c = 0,
                                                                     SupportStartDate__c = system.now().addHours(-2),
                                                                     RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                     Working_Time__c = wrkTimeHD1.Id
                                                                    );
            insert mltHD1;
        }
        system.runAs(HD1Contabilita)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1Contabilita.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = 'Risposta Specialista';
            caseObj1.OwnerId = HD1Contabilita.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } 
    
    
     /*static testMethod void testmethod22HD1Contenzioso(){
        test.StartTest();
        Group testGroup = new Group(Name='HD1 Contenzioso', type='Queue');
        insert testGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        User    agent      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User    HD1Contenzioso      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1Contenzioso@axa.test.com' LIMIT 1];
        User    HD1ContaSuper       = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supervisorHD1Contabilita@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'test$$' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=testGroup.id;
            gm.UserOrGroupId = HD1Contenzioso.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            caseObj1 = new Case(ContactId = con.Id,
                                AccountId = currentAcc.Id,
                                Status    = 'Risposta Specialista',
                                Origin    = 'Portale Assistenza',
                                User__c =  agent.Id,
                                LOB__c = 'Contabilità Danni',
                                OwnerId = HD1ContaSuper.Id,
                                Category__c = 'AUTO',
                                Subject = 'test',
                                Description = 'test',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Assistenza Agenti').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            Working_Times__c wrkTime = new Working_Times__c(Case__c = caseObj1.Id,
                                                            UserRole__c = '',
                                                            UserProfile__c = 'HD1 Contabilita',
                                                            Time_Spent__c = 0.034,
                                                            RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimCoda).getRecordTypeId(),
                                                            OwnerId = HD1ContaSuper.Id);
            insert wrkTime;
            
            
            Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                  CaseStatus__c = 'Risposta Specialista',
                                                                  UserProfile__c = 'HD1 Contabilita',
                                                                  UserRole__c = '',
                                                                  Owner__c = HD1ContaSuper.Id,
                                                                  TimeSpent__c = 0,
                                                                  SupportStartDate__c = system.now().addHours(-2),
                                                                  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda,
                                                                  Working_Time__c = wrkTime.Id
                                                                 );
            insert mlt;
            Working_Times__c wrkTimeHD1 = new Working_Times__c(Case__c = caseObj1.Id,
                                                               UserRole__c = '',
                                                               UserProfile__c = 'HD1 Contenzioso',
                                                               Time_Spent__c = 0.034,
                                                               RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(AP_Constants.rtWorkTimUser).getRecordTypeId(),
                                                               OwnerId = HD1Contenzioso.Id);
            insert wrkTimeHD1;
            
            
            Milestone_Tracking__c mltHD1 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                     CaseStatus__c = 'Risposta Specialista',
                                                                     UserProfile__c = 'HD1 Contenzioso',
                                                                     UserRole__c = '',
                                                                     Owner__c = HD1Contenzioso.Id,
                                                                     TimeSpent__c = 0,
                                                                     SupportStartDate__c = system.now().addHours(-2),
                                                                     RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser,
                                                                     Working_Time__c = wrkTimeHD1.Id
                                                                    );
            insert mltHD1;
        }
        system.runAs(HD1ContaSuper)
        {
            test.stopTest();
            system.debug('hd1Id'+HD1Contenzioso.Id);
            system.debug('°°°: '+[SELECT Id, userProfile__c from milestone_TRacking__c]);
            system.debug('°°°: '+[SELECT Id, userProfile__c  from Working_Times__c]);
            ModelloDiAssistenzaUtils.runModelloDiAssistenzaFROMtest = true;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            caseObj1.Status = 'Risposta Specialista';
            caseObj1.OwnerId = HD1Contenzioso.Id;
            system.debug('before Update -- ');
            update caseObj1;
            
            
        }
        
    } */

    @IsTest
    public static void testsetCaseHistory(){
        Case newCase = new Case(Status = AP_Constants.caseStatusOpen, OwnerId = UserInfo.getUserId());
        Case oldCase = new Case();
        Milestone_Tracking__c milestoneTrackingToUpsert = new Milestone_Tracking__c();
        ModelloDiAssistenzaUtils.setCaseHistory(milestoneTrackingToUpsert, newCase, oldCase);
        //System.assertEquals('Case Creato', milestoneTrackingToUpsert.Activity__c, 'Case Creato');
        newCase.Status = AP_Constants.caseStatusGestioneSpecialistica;
        oldCase.Status = AP_Constants.caseStatusAssigned;
        ModelloDiAssistenzaUtils.setCaseHistory(milestoneTrackingToUpsert, newCase, oldCase);
        //System.assertEquals('Cambio Stato e Titolare', milestoneTrackingToUpsert.Activity__c, 'Cambio Stato e Titolare');
        newCase.Status = AP_Constants.caseStatusGestioneHD3;
        oldCase.OwnerId = newCase.OwnerId;
        ModelloDiAssistenzaUtils.setCaseHistory(milestoneTrackingToUpsert, newCase, oldCase);
        //System.assertEquals('Cambio Stato', milestoneTrackingToUpsert.Activity__c, 'Cambio Stato');
        newCase.OwnerId = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1].Id;
        oldCase.Status = newCase.Status;
        ModelloDiAssistenzaUtils.setCaseHistory(milestoneTrackingToUpsert, newCase, oldCase);
        //System.assertEquals('Cambio Titolare', milestoneTrackingToUpsert.Activity__c, 'Cambio Titolare');
        newCase.OwnerId = oldCase.OwnerId;
        newCase.HD3_IT__c = 'TEST';
        ModelloDiAssistenzaUtils.setCaseHistory(milestoneTrackingToUpsert, newCase, oldCase);
        //System.assertEquals('Cambio Gruppo', milestoneTrackingToUpsert.Activity__c, 'Cambio Gruppo');

    }
}