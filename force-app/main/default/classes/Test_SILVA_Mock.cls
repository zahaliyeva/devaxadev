@isTest
global class Test_SILVA_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint() == 'https://maam-stg.axa.com/maam/v2/token') {
            res.setBody('{"access_token": "12345","token_type": "Bearer","expires_in": 3600,"scope": "urn:axa:axa-go:silva:generic-integration-framework"}');
        } else {
            res.setBody('{"error":{"message":"User Not Authenticated","detail":"Required to provide Auth information"},"status":"failure"}');
        }
        res.setStatusCode(200);
        return res;
    }
}