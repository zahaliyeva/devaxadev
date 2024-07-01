/**
 * Created by francesco on 2019-07-04.
 */

@IsTest
private class VFC33_SendDocumentValidationCTRL_TEST {
    @TestSetup
    static void setup() {

        ServiceUtilsClass.populateCustomSettingsForTests();

        insert new MPS_Code_Variables__c(Name = 'SitoImpresa_closedStatusCase', Value__c = 'Closed;Chiuso;');

        IE_Configuration__c configuration = new IE_Configuration__c();
        configuration.Name = 'DocumentValidation';
        configuration.HTTPMethod__c = 'POST';
        configuration.Direction__c = 'OUTBOUND';
        configuration.Type__c = 'WebService_rest';
        configuration.Request_compiler__c = 'IE_Request_DocumentValidation';
        configuration.Response_parser__c = 'IE_Parser_DocumentValidation';
        configuration.EndPoint__c = 'https://test/document-validation';
        configuration.log_records_flag__c = true;
        insert configuration;

        Account acc = new Account(
                Name = 'Azienda',
                Partita_IVA__c = 'IVA123456',
                AAI_Partita_IVA__c = 'IVA123456',
                TECH_Company__c = 'MPS',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId());
        insert acc;
        InsurancePolicy__c p = new InsurancePolicy__c(
                Name = '23245365432',
                TECH_Company__c = 'AXA MPS ASSICURAZIONI DANNI',
                CUID__c = acc.Id
        );

        insert p;

    }

    private class Created implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');

            JSONGenerator generator = JSON.createGenerator(true);
            generator.writeStartObject();
            generator.writeFieldName('data');
            generator.writeStartObject();
            generator.writeStringField('type', 'user-registration');
            generator.writeStringField('id', '9087b97b-d42b-4219-87fe-8515552cb681');
            generator.writeEndObject();
            generator.writeEndObject();

            String body = generator.getAsString();

            res.setBody(body);
            res.setStatusCode(201);

            return res;
        }
    }

    @IsTest
    static void caseFieldFailureTest() {
        IE_DocumentValidation.ResponseDto response = VFC33_SendDocumentValidationCTRL.sendDocumentValidationCTRL('5006E000ZZZZZZZZZZ');
        System.assert(!response.isSuccess);
        System.assertEquals(666, response.statusCode); // CASE NOT FOUND

        response = VFC33_SendDocumentValidationCTRL.sendDocumentValidationCTRL('4006E000ZZZZZZZZZZ');
        System.assert(!response.isSuccess);
        System.assertEquals(555, response.statusCode); // EMPTY CASE

        InsurancePolicy__c p = [SELECT Id, CUID__c FROM InsurancePolicy__c WHERE Name = '23245365432' LIMIT 1];
        Case c = new Case(
                AccountId = p.CUID__c,
                Status = 'Open',
                Category__c = 'Test',
                SuppliedEmail = 'email@test.com',
                LinkToPolicy__c = p.Id
        );

        insert c;

        response = VFC33_SendDocumentValidationCTRL.sendDocumentValidationCTRL(c.Id);
        System.assert(!response.isSuccess); // MISSING SUB-CATEGORY
        System.assertEquals(777, response.statusCode);

        c.Status = 'Closed';
        c.SubCategory__c = 'Test';
        update c;

        response = VFC33_SendDocumentValidationCTRL.sendDocumentValidationCTRL(c.Id);
        System.assert(!response.isSuccess); // ALREADY CLOSED
        System.assertEquals(888, response.statusCode);
    }

    @IsTest
    static void createdTest() {
        InsurancePolicy__c p = [SELECT Id, CUID__c FROM InsurancePolicy__c WHERE Name = '23245365432' LIMIT 1];
        Case c = new Case(
                AccountId = p.CUID__c,
                Status = 'Open',
                Category__c = 'Test',
                SuppliedEmail = 'email@test.com',
                SubCategory__c = 'Test',
                LinkToPolicy__c = p.Id
        );

        insert c;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Created());
        IE_DocumentValidation.ResponseDto response = VFC33_SendDocumentValidationCTRL.sendDocumentValidationCTRL(c.Id);
        Test.stopTest();

        System.assert(response.isSuccess);
        System.assertEquals(201, response.statusCode);

        c = [SELECT IsClosed FROM Case WHERE Id = :c.Id];
        System.assert(c.IsClosed);

    }

    @isTest
    public static void testHasAssociatePolicy(){
        Id caseRecordtypeId = [Select Id from Recordtype Where Name = 'Motor' and sObjecttype='Case'].Id;
        Account acc = [SELECT Id from Account limit 1];
        Case c = new Case(
            AccountId = acc.Id,
            RecordtypeId = caseRecordtypeId);
        insert c;
        Test.startTest();
        VFC33_SendDocumentValidationCTRL.hasAssociatePolicy(c.Id);
        Test.stopTest();
    }

    @isTest
    public static void testAssociatePolicy1(){
        Id caseRecordtypeId = [Select Id from Recordtype Where Name = 'Motor' and sObjecttype='Case'].Id;
        Account acc = [SELECT Id from Account limit 1];
        Case c = new Case(
            AccountId = acc.Id,
            RecordtypeId = caseRecordtypeId);
        insert c;
        Test.startTest();
        try{
            VFC33_SendDocumentValidationCTRL.associatePolicy(c.Id, null, null);
        } catch(Exception ex){
            System.debug(ex.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void testAssociatePolicy2(){
        Id caseRecordtypeId = [Select Id from Recordtype Where Name = 'Motor' and sObjecttype='Case'].Id;
        Account acc = [SELECT Id from Account limit 1];
        Case c = new Case(
            AccountId = acc.Id,
            RecordtypeId = caseRecordtypeId);
        insert c;
        Test.startTest();
        try{
            VFC33_SendDocumentValidationCTRL.associatePolicy(c.Id, '23245365432', null);
        } catch(Exception ex){
            System.debug(ex.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void testAssociatePolicy3(){
        Id caseRecordtypeId = [Select Id from Recordtype Where Name = 'Motor' and sObjecttype='Case'].Id;
        Account acc = [SELECT Id from Account limit 1];
        Case c = new Case(
            AccountId = acc.Id,
            RecordtypeId = caseRecordtypeId);
        insert c;
        Test.startTest();
        VFC33_SendDocumentValidationCTRL.associatePolicy(c.Id, '23245365432', 'AXA MPS ASSICURAZIONI DANNI');
        Test.stopTest();
    }

    @isTest 
    public static void polizzaAndCompanyTest() {

        InsurancePolicy__c p = [SELECT Id, CUID__c FROM InsurancePolicy__c WHERE Name = '23245365432' LIMIT 1];
        Case c = new Case(
                AccountId = p.CUID__c,
                Status = 'Open',
                Category__c = 'Test',
                SuppliedEmail = 'email2@test.com',
                LinkToPolicy__c = p.Id,
                Compagnia_Polizze__c='test',
                Polizza_Registrazione_PG__c='test'
        );

        insert c;

        Test.startTest();
        list<String> res=VFC33_SendDocumentValidationCTRL.polizzaAndCompany(c.id);
        Test.stopTest();

        list<String> exp= new list<String>();
        exp.add('test'); 
        exp.add('test');
        Assert.areEqual(exp, res);

    }
}