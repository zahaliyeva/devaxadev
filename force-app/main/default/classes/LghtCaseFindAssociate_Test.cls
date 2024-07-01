@IsTest
public class LghtCaseFindAssociate_Test {
    @testSetup static void setup() 
    {
        map<String,Id>    acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        map<String,Id>    case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);      
        
         //account
       list<Account>  accList = new list<Account>
            {
                new Account(FirstName ='John',
                            LastName= 'Smith',
                            PersonEmail = 'john.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                            Fiscal_ID__c = '5645',
                            PersonBirthdate = date.today()
                           ),
                    new Account(FirstName ='Test',
                                LastName= 'Account',
                                PersonEmail = 'test.account@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Fiscal_ID__c = '6789',
                                PersonBirthdate = date.today()
                               ),
                    new Account(FirstName ='Test',
                                LastName= 'Account2',
                                PersonEmail = 'test.account2@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Fiscal_ID__c = '111213',
                                PersonBirthdate = date.today()
                               ),
                    new Account(FirstName ='Test',
                                LastName= 'Account3',
                                PersonEmail = 'test.account3@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccAAFB2C),
                                Fiscal_ID__c = '111213333',
                                PersonBirthdate = date.today()
                               )                    
                    //MOSCATELLI_M 10102016: Family Protect -- END
                    };
                        insert accList;        
            
            //Policies
          list<InsurancePolicy__c> policyList = new list<InsurancePolicy__c>
            {
                new InsurancePolicy__c(
                    Name = 'Polizza1',
                    TECH_Company__c = 'MPS',
                    CUID__c =accList[0].Id,
                    CCDATE__c = date.today()-1,
                    EXPIRY_DATE__c= date.today(),
                    Product__c= 'Mutuo'),
                    new InsurancePolicy__c(
                        Name = 'Polizza2',
                        TECH_Company__c = 'Quadra',
                        CUID__c =accList[0].Id,
                        CCDATE__c = date.today()-1,
                        EXPIRY_DATE__c= date.today(),
                        Product__c= 'Vita'),
                    new InsurancePolicy__c(
                        Name = 'Polizza3',
                        TECH_Company__c = 'Quadra',
                        CUID__c =accList[2].Id,
                        CCDATE__c = date.today()-1,
                        EXPIRY_DATE__c= date.today(),
                        Product__c= 'Vita')
                    };
                        insert policyList;
            
           InsurancePolicyAAF__c  FamilyProtectPolicy = new InsurancePolicyAAF__c(Subscriber_national_identifier__c=accList[3].id,Name='AAF1');
            insert FamilyProtectPolicy;
            
            //case
           list <Case>  caseList = new list <Case>
            {
                new Case(
                    Status = 'Assigned',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                    AccountId=accList[0].Id),
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                        AccountId= accList[1].Id),
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                        LinkToPolicy__c= policyList[2].Id),
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI),
                        Insurance_Policy_AAF__c= FamilyProtectPolicy.Id),
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI),
                        AccountId= accList[3].Id)                    
                    };
                        insert caseList;
           
        
            list<IE_Configuration__c> listConfigs = new list<IE_Configuration__c>();
            IE_Configuration__c search_IEConf = new IE_Configuration__c (
                Request_compiler__c = 'IE_Request_CIF_EditAccount',
                Response_parser__c = 'IE_CIFparser_SearchAccount',
                Type__c = 'WebService',
                Certificate__c = '',
                EndPoint__c = 'STOP__https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
                Name = 'CIF_Integration_AccountSearch',
                log_records_flag__c=false,
                Direction__c='OUTBOUND',
                NameSpacePrefix1__c = 'soapenv',
                NameSpacePrefix2__c = 'cif',
                NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                NameSpaceUri2__c = 'http://cif.service.rgi.it/'
            
                
            );
            IE_Configuration__c FullSearch_IEConf = new IE_Configuration__c (
                Request_compiler__c = 'IE_Request_CIF_EditAccount',
                Response_parser__c = 'IE_CIFparser_FullSearchAccount',
                Type__c = 'WebService',
                Certificate__c = '',
                EndPoint__c = 'STOP__https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
                Name = 'CIF_Integration_AccountFullSearch',
                log_records_flag__c=false,
                Direction__c='OUTBOUND',
                NameSpacePrefix1__c = 'soapenv',
                NameSpacePrefix2__c = 'cif',
                NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                NameSpaceUri2__c = 'http://cif.service.rgi.it/'
            );
            /** PURE IT Commento per rimuovere referenza di una classe commentata
            IE_Configuration__c Integration_decodeFiscalCode = new IE_Configuration__c (
                Request_compiler__c = 'IE_Request_CIF_EditAccount',
                Response_parser__c = 'IE_Parser_decodeFiscalCode',
                Type__c = 'WebService',
                Certificate__c = '',
                EndPoint__c = 'STOP__https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
                Name = 'Integration_decodeFiscalCode',
                log_records_flag__c=false,
                Direction__c='OUTBOUND',
                NameSpacePrefix1__c = 'soapenv',
                NameSpacePrefix2__c = 'bean',
                NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                NameSpaceUri2__c = 'http://bean.services.jdna6hs.app.directw.it'
            
                
            );  
            PURE IT Comment closure */          
            listConfigs.add(search_IEConf);
            listConfigs.add(FullSearch_IEConf);
            //listConfigs.add(Integration_decodeFiscalCode); PURE IT commento per rimuovere referenza di una classe chiamata
            insert listConfigs;

        // popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //popolamento custom settings per classi di test - end
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
                
                LghtCaseFindAssociate.getIstance(caseObj1); 
                LghtCaseFindAssociate.initContext(caseObj1.id,new Map<String,String>()); 
                LghtCaseFindAssociate.searchCustomer(caseObj1.id,new Map<String,String>(), new Account (FirstName ='Mario', LastName='Rossi')); 
                LghtCaseFindAssociate.asociateCustomerToCase(caseObj1.id,new Map<String,String>(), new Account (FirstName ='Mario', LastName='Bianchi')); 
                
                test.stopTest();
            
           
            }
            
            
        }
    }
    
    static testMethod void testmethod2(){
       
        
        test.startTest();
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
                
                LghtCaseFindAssociate.getIstance(caseObj1); 
                
                
                LghtCaseFindAssociate.importAssociateCustomerToCase(caseObj1.Id, new Map<String, String>{ 'NDG'=> 'test'});
                test.stopTest();
            
           
            }
            
            
        }
    }
  
    static testMethod void testMethodSarchAccount(){
        MappingProvince__c mp = new MappingProvince__c(
                name='1',
                SFDCexpected__c='Milano',
                ProvinciaExternalKey__c='MI'
            );
            insert mp;
			MappingProvince__c mp1 = new MappingProvince__c(
                name='1',
                SFDCexpected__c='ROMA',
                ProvinciaExternalKey__c='RM'
            );
            insert mp1;
            SalutationMapping__c sm = new SalutationMapping__c(
                Codice_CIF__c='1',
                Descrizione_CIF__c='Sig.',
                name='1'
            );
            insert sm;
        MappingCountry__c mc = new MappingCountry__c(
                name='1',
                CountryISOcode__c='ITA',
                CountrySFDC__c='Italy'
            );
            insert mc;
         accountSearchMock_Test mockServer1 = new accountSearchMock_Test();
            mockServer1.TestCase = 'B2B';
            Test.setMock(HttpCalloutMock.class, mockServer1);
        test.startTest();
        LghtCaseFindAssociate.doSearchAccounOnCIF(false, new Account (Name='Mario Rossi',FirstName ='Mario', LastName='Rossi', Fiscal_ID__c='1234', Partita_IVA__c = '1234'),'0000'); 
        //LghtCaseFindAssociate.doSearchAccounOnCIF(false, new Account (Name='Mario Rossi', Fiscal_ID__c='1234'),'');
        test.stopTest();
    }
    static testMethod void testMethodSearchAccountB2C(){
            MappingProvince__c mp = new MappingProvince__c(
                name='1',
                SFDCexpected__c='Milano',
                ProvinciaExternalKey__c='MI'
            );
            insert mp;
			MappingProvince__c mp1 = new MappingProvince__c(
                name='1',
                SFDCexpected__c='ROMA',
                ProvinciaExternalKey__c='RM'
            );
            insert mp1;
            SalutationMapping__c sm = new SalutationMapping__c(
                Codice_CIF__c='1',
                Descrizione_CIF__c='Sig.',
                name='1'
            );
            insert sm;
            MappingCountry__c mc = new MappingCountry__c(
                    name='1',
                    CountryISOcode__c='ITA',
                    CountrySFDC__c='Italy'
                );
                insert mc;
             accountSearchMock_Test mockServer1 = new accountSearchMock_Test();
                mockServer1.TestCase = 'B2C';
                Test.setMock(HttpCalloutMock.class, mockServer1);     
        test.startTest();
        LghtCaseFindAssociate.doSearchAccounOnCIF(true, new Account (Name = 'Mario Rossi' , FirstName ='Mario', LastName='Rossi', Fiscal_ID__c='1234'),'');
        test.stopTest();
        
    }
    static testMethod void testmethod3(){
        test.StartTest();
        Map<String,String> params = new Map<String,String>();
        List <Account> accList=   [SELECT ID FROM ACCOUNT];
        List <Case> caseList=   [SELECT ID FROM Case];
        params.put('Account', accList[0].Id);
        LghtCaseFindAssociate.CasePoliciesResult response =  LghtCaseFindAssociate.searchPolicies(params);
        LghtCaseFindAssociate.asociatePolicyToCase(caseList[0].Id, 0, response);
        test.StopTest();        
    }
    static testMethod void testmethod4(){
        test.StartTest();
        Map<String,String> params = new Map<String,String>();
        List <Account> accList=   [SELECT ID FROM ACCOUNT];
        List <Case> caseList=   [SELECT ID FROM Case];
        List <InsurancePolicy__c> policyList = [SELECT ID FROM InsurancePolicy__c];
        params.put('Account', '');
        params.put('Policy',policyList[2].Id);
        LghtCaseFindAssociate.CasePoliciesResult response =  LghtCaseFindAssociate.searchPolicies(params);
        LghtCaseFindAssociate.asociatePolicyToCase(caseList[2].Id, 0, response);
        test.StopTest();        
    }
        static testMethod void testmethod5(){
        test.StartTest();
        Map<String,String> params = new Map<String,String>();
        List <Account> accList=   [SELECT ID FROM ACCOUNT];
        List <Case> caseList=   [SELECT ID FROM Case];
        List <InsurancePolicy__c> policyList = [SELECT ID FROM InsurancePolicy__c];       
        params.put('Account', accList[3].Id);
        LghtCaseFindAssociate.CasePoliciesResult response =  LghtCaseFindAssociate.searchPolicies(params);
        LghtCaseFindAssociate.asociatePolicyToCase(caseList[4].Id, 0, response);
        test.StopTest();        
    }
      static testMethod void testmethod6(){
        test.StartTest();
        Map<String,String> params = new Map<String,String>();
        List <Account> accList=   [SELECT ID FROM ACCOUNT];
        List <Case> caseList=   [SELECT ID FROM Case];
        List <InsurancePolicyAAF__c> policyList = [SELECT ID FROM InsurancePolicyAAF__c];       
        params.put('PolicyAAF',policyList[0].Id);
        LghtCaseFindAssociate.CasePoliciesResult response =  LghtCaseFindAssociate.searchPolicies(params);
        LghtCaseFindAssociate.asociatePolicyToCase(caseList[3].Id, 0, response);
        test.StopTest();        
    }

}