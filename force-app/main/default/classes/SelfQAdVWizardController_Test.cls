@isTest
public without sharing class SelfQAdVWizardController_Test {
    @testSetup 
    static void setup(){

        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        AAI_Code_Variables__c modAcc= new AAI_Code_Variables__c();
         modAcc.Name='AccountEdit_IRSavingLink';
         modAcc.Value__c='https://axaitalia--pre.cs80.my.salesforce.com/'; 

         insert modAcc;

        IE_Configuration__c configuration = new IE_Configuration__c();
        configuration.Name = 'IE_FEQ_kyc-cancel';
        configuration.HTTPMethod__c = 'GET';
        configuration.Direction__c = 'OUTBOUND';
        configuration.Type__c = 'WebService_rest';
        configuration.Request_compiler__c = 'IE_FEQ_REQUEST_kyc_cancel';
        configuration.Response_parser__c = 'IE_FEQ_PARSER_kyc_cancel';
        configuration.EndPoint__c = 'https://test/kyc-cancel';
        configuration.log_records_flag__c = true;
        configuration.Silva_Access_Token__c = 'Fake Token';
        insert configuration;

        IE_Configuration__c conf = new IE_Configuration__c(
            Name = 'Auth0',
            ClientId__c = '12345',
            Client_Secret__c = '12345',
            EndPoint__c = 'auth',
            Silva_Token_Expiration_DateTime__c = (System.now() - 1),
            Request_Compiler__c = 'IE_Auth0_Request',
            Response_Parser__c = 'IE_Auth0_Response',
            Type__c = 'WebService_rest',
            HTTPMethod__c = 'POST',
            Silva_Access_Token__c = '1234',
            Insert_IR_WS__c = false,
            log_records_flag__c = false
        );
        insert conf;
        
        IE_Configuration__c conf3 = new IE_Configuration__c(
            Name = 'Auth0_Get_Token',
            ClientId__c = '12345',
            Client_Secret__c = '12345',
            EndPoint__c = 'https://',
            Silva_Token_Expiration_DateTime__c = (System.now() - 1),
            Type__c = 'WebService_rest',
            HTTPMethod__c = 'GET',
            Silva_Access_Token__c = '1234',
            Insert_IR_WS__c = false,
            log_records_flag__c = false
        );
        insert conf3;

        //create whole structure
        AAI_Code_Variables__c custSet = new AAI_Code_Variables__c(
            name = 'CheckWFCL',
            value__c = 'true'
        );

        insert custSet;

        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('Axa_Assicurazioni').getRecordTypeId();
        Case c = new Case (
            RecordtypeId = devRecordTypeId,
            Pratica_Documentale__c = true,
            Origine_Pratica_Documentale__c = 'WFCL',
            SuppliedEmail = 'test.test@test.it'
        );

        insert c;

        

        List<DocumentAccount__c> dAtoInsert = new List<DocumentAccount__c>();

        DocumentAccount__c dA1 = new DocumentAccount__c(
            CaseId__c = c.Id,
            FirstName__c = 'DocumentAccount1',
            Role__c = 'Soggetto;Richiedente',
            Delegate__c = true,
            TECH_RequiredFieldsMissing__c = true
        );
        dAtoInsert.add(dA1);

        DocumentAccount__c dA2 = new DocumentAccount__c(
            CaseId__c = c.Id,
            FirstName__c = 'DocumentAccount2',
            SurnameCompanyName__c = 'DocumentAccount2',
            Role__c = 'Soggetto',
            TECH_RequiredFieldsMissing__c = true
        );
        dAtoInsert.add(dA2);

        insert dAtoInsert;

        List<DocumentChecklistItem__c> dCtoInsert = new List<DocumentChecklistItem__c>();

        DocumentChecklistItem__c dC1 = new DocumentChecklistItem__c(
            TECH_RecordUpdated__c = false,
            CaseID__c = c.Id,
            DocumentAccountId__c = dA1.Id
        );

        dCtoInsert.add(dC1);

        DocumentChecklistItem__c dC2 = new DocumentChecklistItem__c(
            TECH_RecordUpdated__c = true,
            CaseID__c = c.Id,
            DocumentAccountId__c = dA2.Id
        );

        dCtoInsert.add(dC2);

        insert dCtoInsert;
    }

    @isTest
    static void testInit(){
        String richiedenteId = [select id from DocumentAccount__c where FirstName__c = 'DocumentAccount1' limit 1].Id;
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDevelopername().get('Axa_Assicurazioni').getRecordTypeId();
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.init([Select id from case limit 1].Id);
        System.assertEquals(res.disableInputs, true);
        System.assertEquals(res.integrationDone, false);
        System.assertEquals(res.richiedenteId, richiedenteId);
        System.assertEquals(res.recordTypeId, devRecordTypeId);
        System.assertEquals(res.subjects.size(), 2);
    }

    
    @isTest 
    static void testSetRecordUpdatedByDocumentAccount(){
        String richiedenteId = [select id from DocumentAccount__c where FirstName__c = 'DocumentAccount2' limit 1].Id;
        SelfQAdVWizardController.setRecordUpdatedByDocumentAccount(richiedenteId);

        for(DocumentChecklistItem__c dc : [Select TECH_RecordUpdated__c from DocumentChecklistItem__c where DocumentAccountId__c =:richiedenteId ]){
            System.assertEquals(dc.TECH_RecordUpdated__c, false);
        }
       
    }

    @isTest 
    static void testUpdateCaseInfo(){
        
        Case c = [SELECT Id FROM Case LIMIT 1];
        c.SuppliedEmail = 'test.test@test.it';
        c.Tipo_Operazione__c = 'A';
        c.CodiceFiscale_PIVA_Contraente__c = 'AAAAAA00A00A000A';
        
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.UpdateCaseInfo(c);
        System.assertEquals(res.isSuccess, true);

    }

    @isTest 
    static void testErrors(){
        
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.Init('IDErrore');
        System.assertEquals(res.isSuccess, false);
        res = SelfQAdVWizardController.UpdateCaseInfo(null);
        System.assertEquals(res.isSuccess, false);

    }


    @isTest 
    static void testUpdateDocumentAccountInfo_CreateOK(){

        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
        insert contentVersion;
        
        SelfQAdVWizardController.UpdateDocumentAccountWrapper input = new SelfQAdVWizardController.UpdateDocumentAccountWrapper();
        input.subjectInput = new DocumentAccount__c(FirstName__c = 'Test Nuovo', Role__c = 'Richiedente;Soggetto');
        input.caseId = [Select id from Case limit 1].Id;
        input.RuoloInput = 'Richiedente';
        input.documents = new List<selfQAdVWizardManageSubjectController.DocumentWrapper>();
        selfQAdVWizardManageSubjectController.DocumentWrapper temp = new selfQAdVWizardManageSubjectController.DocumentWrapper();
        temp.document = new DocumentChecklistItem__c(Document_Type__c = 'DDI', CaseId__c = input.caseId);
        temp.fileData = new selfQAdVWizardManageSubjectController.fileModel();
        temp.fileData.base64 = EncodingUtil.base64Encode(Blob.valueOf('Test Document 2'));
        temp.fileData.fileName = 'Pic2.jpg';
        temp.fileData.fileType = 'ContentDocumentNew';
        temp.fileData.fileId = [Select id from contentDocument where title = 'a picture' limit 1].Id;
        input.documents.add(temp);
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.UpdateDocumentAccountInfo(input);
        System.assertEquals(res.isSuccess, true);
        

    }

    @isTest 
    static void testUpdateDocumentAccountInfo_CreateKO(){

        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
        insert contentVersion;
        
        SelfQAdVWizardController.UpdateDocumentAccountWrapper input = new SelfQAdVWizardController.UpdateDocumentAccountWrapper();
        input.subjectInput = new DocumentAccount__c(FirstName__c = 'Test Nuovo', Role__c = 'Richiedente;Soggetto');
        input.caseId = [Select id from Case limit 1].Id;
        input.RuoloInput = 'Soggetto';
        input.documents = new List<selfQAdVWizardManageSubjectController.DocumentWrapper>();
        selfQAdVWizardManageSubjectController.DocumentWrapper temp = new selfQAdVWizardManageSubjectController.DocumentWrapper();
        temp.document = new DocumentChecklistItem__c(Document_Type__c = 'DDI');
        temp.fileData = new selfQAdVWizardManageSubjectController.fileModel();
        temp.fileData.base64 = EncodingUtil.base64Encode(Blob.valueOf('Test Document 2'));
        temp.fileData.fileName = 'Pic2.jpg';
        temp.contentDocumentId = [Select id from contentDocument where title = 'a picture' limit 1].Id;
        input.documents.add(temp);
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.UpdateDocumentAccountInfo(input);
        System.assertEquals(res.isSuccess, false);
        

    }

    @isTest 
    static void testUpdateDocumentAccountInfo_UpdateOK(){

        
        
        SelfQAdVWizardController.UpdateDocumentAccountWrapper input = new SelfQAdVWizardController.UpdateDocumentAccountWrapper();
        input.subjectInput = [Select Id, FirstName__c, Role__c, FiscalIdentifier__c, Delegate__c from DocumentAccount__c where FirstName__c = 'DocumentAccount2'];
        input.caseId = [Select id from Case limit 1].Id;
        input.RuoloInput = 'Soggetto';
        input.documents = new List<selfQAdVWizardManageSubjectController.DocumentWrapper>();
        /*selfQAdVWizardManageSubjectController.DocumentWrapper temp = new selfQAdVWizardManageSubjectController.DocumentWrapper();
        temp.document = new DocumentChecklistItem__c(Document_Type__c = 'DDI',);
        temp.fileData = new selfQAdVWizardManageSubjectController.fileModel();
        temp.fileData.base64 = EncodingUtil.base64Encode(Blob.valueOf('Test Document 2'));
        temp.fileData.fileName = 'Pic2.jpg';
        temp.contentDocumentId = [Select id from contentDocument where title = 'a picture' limit 1].Id;
        input.documents.add(temp);*/
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.UpdateDocumentAccountInfo(input);
        System.assertEquals(res.isSuccess, true);
        
        input.RuoloInput = 'Richiedente';
        input.richiedenteId = input.subjectInput.Id;
        res = SelfQAdVWizardController.UpdateDocumentAccountInfo(input);
        System.assertEquals(res.isSuccess, true);
    }

    @isTest 
    static void testGetFile(){

        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
        insert contentVersion;
        String ContentDocumentId = [Select id from ContentDocument limit 1].Id;
        String CaseId = [Select id from Case limit 1].Id;
        contentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = CaseId, contentDocumentId = ContentDocumentId);
        insert cdl;
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=CaseId;
        insert attach;
        test.startTest();
        List<SelfQAdVWizardController.fileWrapper> res = SelfQAdVWizardController.getFiles(CaseId);
        test.stopTest();

        System.assertEquals(res.size(), 2);
    }

    @isTest
    static void testConfirm(){
        Test.setMock(HttpCalloutMock.class, new SelfQaDVIntegrationMock());
        Case caseId = [Select id, SuppliedEmail from Case limit 1];
        DocumentAccount__c subjectInput = [Select Id, FirstName__c, Role__c, FiscalIdentifier__c, Delegate__c, SurnameCompanyName__c from DocumentAccount__c where FirstName__c = 'DocumentAccount2'];
        Test.startTest();
        CaseHandler.RunTrigger = false;
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.confirmQAdV(CaseId, subjectInput);
        Test.stopTest();
        system.assertEquals(res.isSuccess, true);
    }

    @isTest
    static void testConfirmKo1(){
        Test.setMock(HttpCalloutMock.class, new SelfQaDVIntegrationMock());
        Case caseId = [Select id, SuppliedEmail from Case limit 1];
        DocumentAccount__c subjectInput = [Select Id, FirstName__c, Role__c, FiscalIdentifier__c, Delegate__c from DocumentAccount__c where FirstName__c = 'DocumentAccount2'];
        Test.startTest();
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.confirmQAdV(CaseId, subjectInput);
        Test.stopTest();
        system.assertEquals(res.isSuccess, false);
    }
    @isTest
    static void testConfirmKo2(){
        //Test.setMock(HttpCalloutMock.class, new SelfQaDVIntegrationMock());
        Case caseId = [Select id, SuppliedEmail from Case limit 1];
        DocumentAccount__c subjectInput = [Select Id, FirstName__c, Role__c, FiscalIdentifier__c, Delegate__c, SurnameCompanyName__c from DocumentAccount__c where FirstName__c = 'DocumentAccount2'];
        Test.startTest();
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.confirmQAdV(CaseId, subjectInput);
        Test.stopTest();

        system.assertEquals(res.isSuccess, false);
    }

    @isTest
    static void testKyc(){

        Test.setMock(HttpCalloutMock.class, new IE_FEQ_kyc_cancelTEST.KycCancelMock());
        SelfQAdVWizardController.UpdateDocumentAccountWrapper input = new SelfQAdVWizardController.UpdateDocumentAccountWrapper();
        input.subjectInput = [Select Id, FirstName__c, Role__c, FiscalIdentifier__c, Delegate__c from DocumentAccount__c where FirstName__c = 'DocumentAccount2'];
        input.caseId = [Select id from Case limit 1].Id;
        input.RuoloInput = 'Soggetto';
        input.documents = new List<selfQAdVWizardManageSubjectController.DocumentWrapper>();

        selfQAdVWizardManageSubjectController.DocumentWrapper temp = new selfQAdVWizardManageSubjectController.DocumentWrapper();
        temp.document = new DocumentChecklistItem__c(Document_Type__c = 'DDI', Detica_Id__c = '1234', CaseId__c = input.caseId);
        temp.callKyc = true;
        input.documents.add(temp);
        Test.startTest();
        SelfQAdVWizardController.InitWrapper res = SelfQAdVWizardController.UpdateDocumentAccountInfo(input);
        Test.stopTest();
        System.assertEquals(res.isSuccess, true);
        List<DocumentChecklistItem__c> doc = [Select Nome_File__c from DocumentChecklistItem__c where Detica_Id__c = '1234' limit 1];
        //system.assertEquals(SelfQAdVWizardController.NOME_FILE_KYC, doc.get(0).Nome_File__c);

    }
}