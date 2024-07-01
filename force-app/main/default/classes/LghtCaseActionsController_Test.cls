@IsTest
public class LghtCaseActionsController_Test {
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

        Case caseObj1 = new Case();

        User    uteTec      = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];


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
                
          
                
                
                
                
                
            }
        }
        
        Map<String,Id>  acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);

        list<Account>  AccountList = new list<Account>{
            new Account(FirstName ='Jane',
                        LastName= 'Smith',
                        PersonMobilePhone = '00393408798576',
                        RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                        ShippingStreet='Via Veneziani 20',
                        ShippingCity = 'Roma',
                        ShippingCountry = 'ITALIA',
                        ShippingPostalCode = '00100'
                       ),                                        
            new Account(FirstName ='Test',
                        LastName= 'AAIB2C',
                        RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C),
                        CIF_PersonMobilePhone__c='3396567889',
                        Claim_PersonalMobile__c='03398767889'
                       ),
            new Account(Name ='TestCompanyAAI',
                        RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2B),
                        CIF_MobilePhone__c='3396567889',
                        Claim_PersonalMobile__c='03398767889'                                                   
                       ),										   
            new Account(FirstName ='Test',
                        LastName= 'MPSIndividual',
                        RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                        PersonMobilePhone='01123445',
                        Mobilephone__c = '3534643636',
                        Claim_PersonalMobile__c='03398767889'
                       ),
            new Account(Name ='TestCompanyMPS',
                        RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccCorporateClient),
                        Mobilephone__c = '3534643636',
                        Claim_PersonalMobile__c='03398767889'
                       ),
            new Account(FirstName ='Will',
                        LastName= 'Smith',
                        PersonMobilePhone = '00393408798576',
                        MobilePhone__c='340 7898974',
                        RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccAAFB2C)
                       )                                            
};
     insert AccountList;


    }
    
    
    static testMethod void testmethod1(){

        test.StartTest();
        
      
        Case caseObj1  = [SELECT Id From Case LIMIT 1];
       
        LghtCaseActionsController.getCase(caseObj1.Id); 
        LghtCaseActionsController.takeOver(caseObj1.Id); 
	    LghtCaseActionsController.reopen(caseObj1.Id);
        
		LghtCaseActionsController.backToQueue(caseObj1.Id);

        test.StopTest();

       
    }

    static testMethod void testMethodSendSMSInit(){
        test.StartTest();
        String FolderIdTest = [Select id from Folder where Name = 'SMS Manuali - Case' LIMIT 1].Id;
            
        EmailTemplate TestTemplate = new EmailTemplate(FolderId=FolderIdTest,
                                                       IsActive=true,
                                                       TemplateType='text',
                                                       Name='tsttempl',
                                                       DeveloperName='tsttempl',
                                                       Encoding='ISO-8859-1',
                                                       Subject='test',
                                                       Body='Gentile {!Case.Account}, {!Account.PersonMobilePhone}, {!Case.Linktopolicy__c} {!Case.Createddate} {!Case.NumberOfReopens__c} {!InsurancePolicy__c.Name}');
        insert TestTemplate;
         
        Map<String,Id>  acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);

        Case caseObj1  = [SELECT Id, AccountId From Case LIMIT 1];
        Account acc1  = [SELECT Id From Account where RecordTypeId =: acc_developerIdMap.get(AP_Constants.rtAccIndividualClient) LIMIT 1];
        Account acc2  = [SELECT Id From Account where RecordTypeId =: acc_developerIdMap.get(AP_Constants.rtAccB2C) LIMIT 1];
        Account acc3  = [SELECT Id From Account where RecordTypeId =: acc_developerIdMap.get(AP_Constants.rtAccB2B) LIMIT 1];
        Account acc4  = [SELECT Id From Account where RecordTypeId =: acc_developerIdMap.get(AP_Constants.rtAccCorporateClient) LIMIT 1];
        Account acc5 = [SELECT Id From Account where RecordTypeId =: acc_developerIdMap.get(AP_Constants.rtAccAAFB2C) LIMIT 1];

    
        Map <String,String> urlParameterMap = new Map <String,String> ();
        urlParameterMap.put('CaseId',caseObj1.Id);
        urlParameterMap.put('AccountId',acc1.Id);
        LghtCaseActionsController.sendSMSInit(urlParameterMap);
        
        urlParameterMap.remove('AccountId');

        urlParameterMap.put('CustomerId',acc2.Id);
        LghtCaseActionsController.sendSMSInit(urlParameterMap);

        urlParameterMap.put('CustomerId',acc3.Id);
        LghtCaseActionsController.sendSMSInit(urlParameterMap);
        
        urlParameterMap.put('CustomerId',acc4.Id);
        LghtCaseActionsController.sendSMSInit(urlParameterMap);
        
        urlParameterMap.put('CustomerId',acc5.Id);
	    LghtCaseActionsController.sendSMSInit(urlParameterMap);
        

        test.StopTest();

       
    }

    static testMethod void testMethodSendSMS(){
        test.StartTest();
        String FolderIdTest = [Select id from Folder where Name = 'SMS Manuali - Case' LIMIT 1].Id;
            
        EmailTemplate TestTemplate = new EmailTemplate(FolderId=FolderIdTest,
                                                       IsActive=true,
                                                       TemplateType='text',
                                                       Name='tsttempl',
                                                       DeveloperName='tsttempl',
                                                       Encoding='ISO-8859-1',
                                                       Subject='test',
                                                       Body='Gentile {!Case.Account}, {!Account.PersonMobilePhone}, {!Case.Linktopolicy__c} {!Case.Createddate} {!Case.NumberOfReopens__c} {!InsurancePolicy__c.Name}');
        insert TestTemplate;
         
        Map<String,Id>  acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);

        Case caseObj1  = [SELECT Id, AccountId From Case LIMIT 1];
        Account acc1  =  [SELECT Id From Account where RecordTypeId =: acc_developerIdMap.get(AP_Constants.rtAccIndividualClient) LIMIT 1];
       
        LghtCaseActionsController.sendSMS('test', caseObj1.Id, TestTemplate.Id,acc1.Id , 'MobileNumber');      

        test.StopTest();

       
    }
}