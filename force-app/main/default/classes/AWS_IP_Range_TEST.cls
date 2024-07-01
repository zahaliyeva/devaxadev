@isTest
private class AWS_IP_Range_TEST {
   @isTest
   static void testParseJSONFromEndpoint() {
       // Setup - configura l'ambiente per il test per chiamare un endpoint
       setupTestEnvironment(false, true, 'http://example.com/aws-ip-ranges.json', 'email@example.com');
       // Mock HttpResponse
       Test.setMock(HttpCalloutMock.class, new AWS_IP_RangeMockHttpResponse());
       // Test
       Test.startTest();
       AWS_IP_Range.chiamaMetedoSincrono();
       Test.stopTest();
       // Verify - Verifica che i record siano stati creati o aggiornati come previsto
       List<IP_Range__c> ipRanges = [SELECT Name, ip_prefix__c, region__c, service__c, network_border_group__c FROM IP_Range__c];
       System.assertNotEquals(0, ipRanges.size(), 'Dovrebbero essere stati creati dei record IP_Range__c.');
       // Asserzione su un campo specifico
       IP_Range__c exampleIpRange = ipRanges[0];
       System.assertEquals('192.168.1.0/24', exampleIpRange.ip_prefix__c, 'L\'IP prefix dovrebbe corrispondere a quello nel mock.');
       System.assertEquals('eu-central-1', exampleIpRange.region__c, 'La regione dovrebbe corrispondere a quella nel mock.');
       System.assertEquals('AMAZON_CONNECT', exampleIpRange.service__c, 'Il servizio dovrebbe corrispondere a quello nel mock.');
   }
   private static void setupTestEnvironment(Boolean fromFile, Boolean sendEmail, String endpoint, String destinatari) {
       // Crea impostazioni fittizie
       AWS_IP_Ranges_Check_Settings__c settings = new AWS_IP_Ranges_Check_Settings__c(
           FromFile__c = fromFile,
           Invia_Mail__c = sendEmail,
           Endpoint__c = endpoint,
           Destinatari_Email__c = destinatari,
           Check_syncToken__c = true
       );
       insert settings;
   }
   // Classe Mock per HttpResponse
   private class AWS_IP_RangeMockHttpResponse implements HttpCalloutMock {
       public HTTPResponse respond(HTTPRequest req) {
           HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           res.setBody('{"syncToken": "token_test", "prefixes": [{"ip_prefix": "192.168.1.0/24", "region": "eu-central-1", "service": "AMAZON_CONNECT", "network_border_group": "eu-central-1"}]}');
           res.setStatusCode(200);
           return res;
       }
   }
}