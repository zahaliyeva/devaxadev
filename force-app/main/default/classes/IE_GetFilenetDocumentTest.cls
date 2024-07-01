/**
 * Created by francesco on 2019-07-10.
 */

@IsTest
private class IE_GetFilenetDocumentTest {

    @TestSetup
    static void setup() {

        IE_Configuration__c configuration = new IE_Configuration__c();
        configuration.Name = 'GetFilenetDocument';
        configuration.HTTPMethod__c = 'GET';
        configuration.Direction__c = 'OUTBOUND';
        configuration.Type__c = 'WebService_rest';
        configuration.Request_compiler__c = 'IE_Request_GetFilenetDocument';
        configuration.Response_parser__c = 'IE_Parser_GetFilenetDocument';
        configuration.EndPoint__c = 'https://test/get-filenet-document';
        configuration.log_records_flag__c = true;
        insert configuration;

    }

    private class OK implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String content = 'XG9SFRHik9I6fvM8XL5FnF+IUnFepK39lu4TJcTbFDJpDSR4VFV4CPfDEE2ZhauGv/cIrjdAC2e4Ar0v+3OCbb' +
                    'Hpm364fOQ4WXCeqeXhgGbuX6d9kdIg1a6H6deD+PHzAnB88h0lmlnonZbPUTKJrguCN9Cz3iEUD3/vc04Cmyr9NNJpn9n10' +
                    'bqNQmb0ag0bLZV/Orqdo9FaVGKcU3Btw/oeDQzqPGGefz/Vqty8MTL2MJN9cOPRuM9p/WlijWKL0kgVofc/8707wMoLSj8u' +
                    '0I1P6THJHyXOoLV/kaETZ5BDpjwfU167NyBGNQ7OY7StBYXEshAiPbOSocIU8/k7';

            Integer maxLength = Schema.SObjectType.IE_Integration_Record__c.fields.ResponseBody__c.getLength();
            do {
                content += content;
            } while (content.length() < maxLength);

            JSONGenerator generator = JSON.createGenerator(true);
            generator.writeStartObject();
            generator.writeFieldName('data');
            generator.writeStartObject();
            generator.writeStringField('type', 'document');
            generator.writeStringField('id', '9088515552cb681');
            generator.writeFieldName('attributes');
            generator.writeStartObject();
            generator.writeStringField('fileName', 'document.pdf');
            generator.writeStringField('mimeType', 'application/pdf');
            generator.writeStringField('content', content);
            generator.writeStringField('fileSize', '8000');
            generator.writeEndObject();
            generator.writeEndObject();
            generator.writeEndObject();

            String body = generator.getAsString();
            res.setBody(body);
            res.setStatusCode(200);

            return res;
        }
    }

    @IsTest
    static void testBehaviour() {

        Id scopeId = 'a286E000000gsIIQAY'; // FAKE ID

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OK());
        IE_GetFilenetDocument.ResponseDto response = IE_GetFilenetDocument.getDocument('213h2u4i21h4213', 'FN_LOC', scopeId);
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals('document.pdf', response.body.data.attributes.fileName);
        System.assertEquals(null, response.body.error);

        IE_Integration_Record__c integrationRecord = [
                SELECT Id, ResponseBody__c
                FROM IE_Integration_Record__c
                WHERE ScopeID__c = :scopeId
        ];
        Integer maxLength = Schema.SObjectType.IE_Integration_Record__c.fields.ResponseBody__c.getLength();
        System.assertEquals(maxLength, integrationRecord.ResponseBody__c.length());

    }
}