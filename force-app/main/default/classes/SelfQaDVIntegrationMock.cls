@isTest
global class SelfQaDVIntegrationMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {        
        String edp = req.getEndpoint(); 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');


        if(edp == 'auth')
		    res.setBody('{"user-created":true}');
        else
		res.setBody('{"access_token": "12345","token_type": "Bearer","expires_in": 3600,"scope": "urn:axa:axa-go:silva:generic-integration-framework"}');
        
		    
        res.setStatusCode(200);
        return res;
    }
}