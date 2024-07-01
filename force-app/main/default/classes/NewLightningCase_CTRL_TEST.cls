@IsTest
public class NewLightningCase_CTRL_TEST {

    @testSetup static void setup() 
    {
        List<MPS_Code_Variables__c> codeVariables = new List<MPS_Code_Variables__c>();
        MPS_Code_Variables__c mps = new MPS_Code_Variables__c(name = 'TECH Company MPS', value__c = 'AXA MPS;AXA MPS ASSICURAZIONI DANNI');
        codeVariables.add(mps);
        MPS_Code_Variables__c quadra = new MPS_Code_Variables__c(name = 'TECH Company Quadra', value__c = 'Quadra');
        codeVariables.add(quadra);
        //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- START
        MPS_Code_Variables__c lob = new MPS_Code_Variables__c(name = 'prepopulatedLOBSinistri', value__c = 'Sinistri');
        codeVariables.add(lob);
        MPS_Code_Variables__c cate = new MPS_Code_Variables__c(name = 'prepopulatedCategoryOpening', value__c = 'Denuncia Sinistro');
        codeVariables.add(cate);
        MPS_Code_Variables__c recT = new MPS_Code_Variables__c(name = 'RecordTypeSinistriLabel', value__c = 'Sinistri AAI;Sinistri Danni Banca');
        codeVariables.add(recT);
        //OAVERSANO 21/05/2019 : AXA Assistance Enhancement Fase I -- END
        insert codeVariables;
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('Caring Angel - Supporto HD1', 'HD2 Caring Angel')];
        Id pCAHD1;
        Id pCAHD2;
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
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
        User HD1 = new User(Username = 'advisorHD1@axa.test.com',
                LastName = 'testuserHD1',
                LanguageLocaleKey = 'it',
                FirstName = 'testHD1',
                Email = 'test@testHD1.com',
                Alias = 'testd',
                TimeZoneSidKey = 'Europe/Dublin',
                LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'UTF-8',
                ProfileId = pCAHD1,
                UserPermissionsKnowledgeUser = true);
        insert HD1;
        User HD2 = new User(Username = 'supportHD2@axa.test.com',
                LastName = 'testuserHD2',
                LanguageLocaleKey = 'it',
                FirstName = 'testHD2',
                Email = 'test@testHD2.com',
                Alias = 'testd',
                TimeZoneSidKey = 'Europe/Dublin',
                LocaleSidKey = 'it_IT',
                EmailEncodingKey = 'UTF-8',
                ProfileId = pCAHD2,
                UserPermissionsKnowledgeUser = true);
        insert HD2;
        Account acc = new Account(firstname = 'firstname',
                lastname = 'lastname',
                Fiscal_ID__c = 'C1R1M4N1M4L3',
                AAI_Codice_fiscale__c = 'C1R1M4N1M4L3',
                tech_company__c = 'AAI',
                PersonBirthdate = system.now().date().adddays(-1),
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId());
        insert acc;
        InsurancePolicy__c pol = new InsurancePolicy__c(Name = 'CH1M1C4',
                CUID__c = acc.Id,
                Targa_veicolo__c = 'TR456TR'
        );
        insert pol;
        Account acc2 = new Account(Name = 'firstname',
                AAI_Codice_fiscale__c = 'C1R1M4N1M4L3',
                tech_company__c = 'AMF',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId());
        insert acc2;
        InsurancePolicy__c pol2 = new InsurancePolicy__c(Name = 'CH1M1C4',
                CUID__c = acc2.Id,
                Targa_veicolo__c = 'TR123TR'
        );
        insert pol2;

        Account acc3 = new Account(Name = 'azienda',
                Partita_IVA__c = 'IVA123456',
                tech_company__c = 'MPS',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId());
        insert acc3;
        InsurancePolicy__c pol3 = new InsurancePolicy__c(Name = 'CH1M1C5',
                CUID__c = acc3.Id
        );
        insert pol3;
    }

    /*static testMethod void testmethod1()   //covers the LightningCaseEdit_CTLR apex class
    {
        test.StartTest();
        Case cs = new Case();

        ApexPages.StandardController stcctrl = new ApexPages.StandardController(cs);

        PageReference pageRef = Page.LightningCaseEdit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        LightningCaseEdit_CTLR propSol = new LightningCaseEdit_CTLR(sc);

        test.stopTest();
    }*/

    static testMethod void testmethod2()  
    {
        test.StartTest();
        NewLightningCase_CTRL.FoundList foundList = new NewLightningCase_CTRL.FoundList();
        Account acc = [SELECT Id FROM Account WHERE Fiscal_ID__c = 'C1R1M4N1M4L3' LIMIT 1];
        InsurancePolicy__c pol = [SELECT Id FROM InsurancePolicy__c WHERE Targa_veicolo__c = 'TR456TR' LIMIT 1];
        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        foundList = NewLightningCase_CTRL.SearchCustomers('firstname', 'lastname', '', '', 'C1R1M4N1M4L3', String.valueOf(system.now().date().adddays(-1)), '', 'fisica', null);
        NewLightningCase_CTRL.NewCaseOutput newCase = new NewLightningCase_CTRL.NewCaseOutput();
        newCase = NewLightningCase_CTRL.generateNewCase(acc.Id, 'test@test.com', pol.Id, 'TR456TR', Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseSinistro).getRecordTypeId(), null);
        List<Case> caseList = NewLightningCase_CTRL.SearchCases(acc.Id, 'Sinistri');
        test.stopTest();
    }

    static testMethod void testmethod3()  
    {
        test.StartTest();
        NewLightningCase_CTRL.FoundList foundList = new NewLightningCase_CTRL.FoundList();
        InsurancePolicy__c pol = [SELECT Id FROM InsurancePolicy__c WHERE Targa_veicolo__c = 'TR456TR' LIMIT 1];
        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = pol.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        foundList = NewLightningCase_CTRL.SearchCustomers('firstname', 'lastname', 'CH1M1C4', 'TR456TR', 'C1R1M4N1M4L3', String.valueOf(system.now().date().adddays(-1)), '', 'fisica', null);
        test.stopTest();
    }

    static testMethod void testmethod4()  
    {
        test.StartTest();
        NewLightningCase_CTRL.FoundList foundList = new NewLightningCase_CTRL.FoundList();
        InsurancePolicy__c pol = [SELECT Id FROM InsurancePolicy__c WHERE Targa_veicolo__c = 'TR123TR' LIMIT 1];
        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = pol.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        foundList = NewLightningCase_CTRL.SearchCustomers('', '', 'CH1M1C4', 'TR123TR', 'C1R1M4N1M4L3', null, '', 'fisica', null);
        test.stopTest();
    }

    static testMethod void testmethod5()  
    {
        test.StartTest();
        NewLightningCase_CTRL.FoundList foundList = new NewLightningCase_CTRL.FoundList();
        Account acc = [SELECT Id FROM Account WHERE AAI_Codice_fiscale__c = 'C1R1M4N1M4L3' LIMIT 1];
        system.debug('accList: ' + acc);
        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        foundList = NewLightningCase_CTRL.SearchCustomers('', '', '', '', 'C1R1M4N1M4L3', null, '', 'fisica', null);
        test.stopTest();
    }
    static testMethod void testmethod6()  
    {
        User HD1 = [SELECT ID FROM USER where Username = 'advisorHD1@axa.test.com' limit 1];
        test.StartTest();
        NewLightningCase_CTRL.FoundList foundList = new NewLightningCase_CTRL.FoundList();
        Account acc = [SELECT Id FROM Account WHERE Partita_IVA__c = 'IVA123456' LIMIT 1];
        InsurancePolicy__c pol = [SELECT Id FROM InsurancePolicy__c WHERE Name = 'CH1M1C5' LIMIT 1];
        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        system.runAs(HD1)
        {
            NewLightningCase_CTRL.checkRTSelection();
            foundList = NewLightningCase_CTRL.SearchCustomers('azienda', '', '', '', 'IVA123456', String.valueOf(system.now().date().adddays(-1)), '', 'giuridica', null);
            NewLightningCase_CTRL.NewCaseOutput newCase = new NewLightningCase_CTRL.NewCaseOutput();
            newCase = NewLightningCase_CTRL.generateNewCase(acc.Id, 'test@test.com', pol.Id, '', '', null);
            List<Case> caseList = NewLightningCase_CTRL.SearchCases(acc.Id, 'CaringAngel');
        }
        test.stopTest();
    }

    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- START
    @IsTest
    static void searchByClaimTest() {
        Account acc = [SELECT Id, FirstName, LastName FROM Account WHERE Fiscal_ID__c = 'C1R1M4N1M4L3' LIMIT 1];

        InsurancePolicy__c p = new InsurancePolicy__c(Name = '100137', Targa_veicolo__c = 'CV123SH', CUID__c = acc.Id);
        insert p;

        Claim__c c = new Claim__c(Name = '082899000112', Account__c = acc.Id, Polizza__c = p.Id);
        insert c;

        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        NewLightningCase_CTRL.FoundList foundList = NewLightningCase_CTRL.SearchCustomers(acc.FirstName, acc.LastName, '100137', null, null, null, null, 'fisica', '082899000112');

        System.assertEquals(1, foundList.Founds.size());
        System.assertEquals('C1R1M4N1M4L3', foundList.Founds[0].Fiscale);


        foundList = NewLightningCase_CTRL.SearchCustomers(acc.FirstName, acc.LastName, '100138', null, null, null, null, 'fisica', '082899000112');
        System.assert(foundList.Founds.isEmpty());

    }

    @IsTest
    static void getCaseRapidoPrepopulatedFieldsTest() {
        MPS_Code_Variables__c LOB = new MPS_Code_Variables__c(
                Name = 'prepopulatedLOBCaseRapido',
                Value__c = 'Sinistri');
        MPS_Code_Variables__c category = new MPS_Code_Variables__c(
                Name = 'prepopulatedCategoryCaseRapido',
                Value__c = 'Informazioni su sinistro');

        insert new List<MPS_Code_Variables__c>{
                LOB, category
        };

        Map<Object, Object> response = NewLightningCase_CTRL.getCaseRapidoPrepopulatedFields();

        System.assertEquals(2, response.size());
    }
    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- END

    @IsTest
    static void createCaseRapidoTest() {
        NewLightningCase_CTRL.createCaseRapido(RecordTypeUtility.getRecordTypeIdByDeveloperName('Case', 'Motor'));
    }

}