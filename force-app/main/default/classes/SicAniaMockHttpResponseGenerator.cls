global class SicAniaMockHttpResponseGenerator implements HttpCalloutMock {
    public String serviceName {get;set;}
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(serviceName == 'requestToken'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token":"test"}');
            res.setStatusCode(201);
            return res;
        }
        
        if(serviceName == 'requestCounterParties'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"insuranceCompanyDni":"test","make":"test","model":"test","make":"test","vehicleType":"test"}');
            res.setStatusCode(200);
            return res;
        }
        return res;
    }

}