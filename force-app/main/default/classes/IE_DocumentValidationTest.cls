/**
 * Created by francesco on 2019-07-03.
 */

@IsTest
private class IE_DocumentValidationTest {

    @TestSetup
    static void setup() {

        ServiceUtilsClass.populateCustomSettingsForTests();

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
                TECH_Company__c = 'AMF',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId());
        insert acc;

        //TECH_Company__c
        InsurancePolicy__c p = new InsurancePolicy__c(
                Name = '23245365432',
                TECH_Company__c = 'AXA MPS ASSICURAZIONI DANNI',
                CUID__c = acc.Id
        );

        insert p;

    }


    static String generateJSONErrorResponse(String id, String status, String code, String title, String detail, String pointer, String parameter) {
        JSONGenerator generator = JSON.createGenerator(true);

        generator.writeStartObject();
        generator.writeFieldName('errors');
        generator.writeStartArray();
        generator.writeStartObject();
        generator.writeStringField('id', id);
        generator.writeStringField('status', status);
        generator.writeStringField('code', code);
        generator.writeStringField('title', title);
        generator.writeStringField('detail', detail);
        generator.writeFieldName('source');
        generator.writeStartObject();
        generator.writeStringField('pointer', pointer);
        generator.writeStringField('parameter', parameter);
        generator.writeEndObject();
        generator.writeEndObject();
        generator.writeEndArray();

        String result = generator.getAsString();

        return result;
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


    private class InternalServerError implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody(generateJSONErrorResponse('123456789', 'errorStatus', '777', 'errorTitle', 'errorDetail', 'errorPointer', 'errorParameter'));
            res.setStatusCode(500);

            return res;
        }
    }

    @IsTest
    static void missingArgumentErrorTest() {
        InsurancePolicy__c p = [SELECT Id, CUID__c FROM InsurancePolicy__c WHERE Name = '23245365432' LIMIT 1];
        Case c = new Case(
                AccountId = p.CUID__c,
                Status = 'Open',
                LinkToPolicy__c = p.Id
        );

        insert c;

        Test.startTest();
        IE_DocumentValidation.ResponseDto response = IE_DocumentValidation.sendRequest(c.Id);
        Test.stopTest();

        System.assert(!response.isSuccess);
        System.assertEquals(999, response.statusCode);

    }


    @IsTest
    static void internalServerErrorTest() {
        InsurancePolicy__c p = [SELECT Id, CUID__c FROM InsurancePolicy__c WHERE Name = '23245365432' LIMIT 1];
        Case c = new Case(
                AccountId = p.CUID__c,
                Status = 'Open',
                SuppliedEmail = 'email@test.com',
                LinkToPolicy__c = p.Id
        );

        insert c;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InternalServerError());
        IE_DocumentValidation.ResponseDto response = IE_DocumentValidation.sendRequest(c.Id);
        Test.stopTest();

        System.assert(!response.isSuccess);
        System.assertEquals(500, response.statusCode);

        IE_Integration_Record__c integrationRecord = [SELECT Id FROM IE_Integration_Record__c WHERE ScopeID__c = :c.Id];
        System.assertNotEquals(null, integrationRecord);

    }

    @IsTest
    static void createdTest() {
        InsurancePolicy__c p = [SELECT Id, CUID__c FROM InsurancePolicy__c WHERE Name = '23245365432' LIMIT 1];
        Case c = new Case(
                AccountId = p.CUID__c,
                Status = 'Open',
                SuppliedEmail = 'email@test.com',
                LinkToPolicy__c = p.Id
        );

        insert c;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Created());
        IE_DocumentValidation.ResponseDto response = IE_DocumentValidation.sendRequest(c.Id);
        Test.stopTest();

        System.assert(response.isSuccess);
        System.assertEquals(201, response.statusCode);

        IE_Integration_Record__c integrationRecord = [SELECT Id FROM IE_Integration_Record__c WHERE ScopeID__c = :c.Id];
        System.assertNotEquals(null, integrationRecord);

    }

    @IsTest
    static void exceptionTest() {

        Test.startTest();
        IE_DocumentValidation.ResponseDto response = IE_DocumentValidation.sendRequest('5006E000ZZZZZZZZZZ');
        Test.stopTest();

        System.assert(!response.isSuccess);
        System.assertEquals(111, response.statusCode);

    }

}