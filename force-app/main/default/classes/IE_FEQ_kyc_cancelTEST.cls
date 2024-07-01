@isTest
public class IE_FEQ_kyc_cancelTEST {
    @TestSetup
    static void setup() {

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

    }

    public class KycCancelMock implements HttpCalloutMock {

        /**
         * @description execute integration test
         * @param req request
         * @return  `HttpResponse` response
         */
        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            JSONGenerator generator = JSON.createGenerator(true);
            generator.writeStartObject();
            generator.writeNumberField('errorCode', 0);
            generator.writeStringField('errorMessage', 'Successo');
            generator.writeStringField('deticaId', 'O3000277555');
            generator.writeEndObject();

            String body = generator.getAsString();
            res.setBody(body);
            res.setStatusCode(200);

            return res;
        }
    }

    @IsTest
    static void testBehaviour() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new KycCancelMock());
        IE_FEQ_kyc_cancel.ResponseDto response = IE_FEQ_kyc_cancel.cancelKyc('O3000277555', 'A');
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(0, response.body.errorCode);
        System.assertEquals('O3000277555', response.body.deticaId);
    }

}