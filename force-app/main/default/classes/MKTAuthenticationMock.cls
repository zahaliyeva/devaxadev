@isTest
global class MKTAuthenticationMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"accessToken": "728gTYdZTa3UEbt8GosFG54u","expiresIn": 3478}');
        res.setStatusCode(200);
        return res;
    }
}