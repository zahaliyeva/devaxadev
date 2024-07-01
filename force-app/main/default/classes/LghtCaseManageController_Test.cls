@IsTest
public class LghtCaseManageController_Test {
@testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        List<MPS_Code_Variables__c> codeVariables = new List<MPS_Code_Variables__c>();
        MPS_Code_Variables__c caRT = new MPS_Code_Variables__c(name = 'RecordTypeCaringAngel', value__c = 'Caring_Angel;');
        codeVariables.add(caRT);
        MPS_Code_Variables__c SLAMA = new MPS_Code_Variables__c(name = 'ModelloDiAssistenzaSLADefault', value__c = '99');
        codeVariables.add(SLAMA);
        MPS_Code_Variables__c SLACA = new MPS_Code_Variables__c(name = 'CaringAngelSLADefault', value__c = '99');
        codeVariables.add(SLACA);
        insert codeVariables;
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('Caring Angel - Supporto HD1','HD2 Caring Angel')];
        Id pCAHD1;
        Id pCAHD2;
        
        if (profiles.size() > 0)
        {
            for(Profile p: profiles)
            {
                if(p.Name == 'Caring Angel - Supporto HD1')
                {
                    pCAHD1 = p.Id;
                }
                else if(p.Name == 'HD2 Caring Angel')
                {
                    pCAHD2 = p.Id;
                }
            }
        } 
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
                            ProfileId                    = pCAHD1,
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
                            ProfileId                    = pCAHD2,
                            UserPermissionsKnowledgeUser = true);
        insert HD2;
        userToShare.add(HD2.Id);
        
    }
    
    
    static testMethod void testmethod1(){
        test.StartTest();
        
        User    HD1      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'advisorHD1@axa.test.com' LIMIT 1];
        User    HD2      = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Username = 'supportHD2@axa.test.com' LIMIT 1];
        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
        Case caseObj1 = new Case();
        System.runAs(uteTec)
        {
            Group g = new Group(Name = 'HD1 - Caring Angel');
            insert g;
            
            GroupMember gm= new GroupMember(); 
            gm.GroupId=g.id;
            gm.UserOrGroupId = HD1.id;
            insert gm; 
        }
        System.runAs(uteTec)                   
        {
            Configurazione_SLA_Case__c sla = new Configurazione_SLA_Case__c(Category__c ='Sinistro Caring Angel',
                                                                            Sub_Category__c = 'Denuncia sinistro',
                                                                            Case_Origin__c = 'All',
                                                                            Customer_Service_Type__c = 'All',
                                                                            Distribution_Network__c = 'All',
                                                                            Case_Record_Type__c = 'Caring_Angel',
                                                                            SLA__c = 3);
            caseObj1 = new Case(
                Status    = 'Open',
                Origin    = 'Phone',
                LOB__c = 'Motor',
                OwnerId = HD1.Id,
                Category__c = 'Sinistro Caring Angel',
                SubCategory__c = 'Denuncia sinistro',
                Subject = 'test',
                Description = 'test',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Caring Angel').getRecordTypeId());
            CaseHandler.AfterUpdateNotDone = false;
            CaseManagement.runCaseManagementAfterUpdateFROMtest = true;
            insert caseObj1;
            system.debug('CASEOBJ ID : '+caseObj1);
            system.runAs(HD1)
            {
                Milestone_Tracking__c mlt = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                      CaseStatus__c = 'Open',
                                                                      UserProfile__c = 'Coda HD1',
                                                                      UserRole__c = '',
                                                                      Owner__c = HD1.Id,
                                                                      SupportStartDate__c = system.now(),
                                                                      RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
                insert mlt;
                Milestone_Tracking__c mlt2 = new Milestone_Tracking__c(Case__c = caseObj1.Id,
                                                                       CaseStatus__c = 'Open',
                                                                       UserProfile__c = 'Coda HD2',
                                                                       UserRole__c = '',
                                                                       Owner__c = HD2.Id,
                                                                       SupportStartDate__c = system.now(),
                                                                       RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda);
                insert mlt2;
                Questionario_CA__c q = new Questionario_CA__c();
                q.Case__c = caseObj1.Id;
                insert q;
                
                LghtCaseManageController.caseCreateContext(); 

                
                test.stopTest();
                
                
                
                
            }
        }
    }
}