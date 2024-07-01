public class CAISicAniaService {
    
    public static CAIServiceWrapper invoke(CAIServiceWrapper wrapper){
        try{
            wrapper = requestToken(wrapper);
            if( wrapper.status != 'OK'){
                return wrapper;
            }
            
            wrapper = validateToken(wrapper);
            if ( wrapper.status != 'OK'){
                return wrapper;
            } 
            
            wrapper = counterParties(wrapper);
            
            return wrapper;
        }catch( Exception e ){
            System.debug('### exception '+e.getStackTraceString()+ '\n'+e.getLineNumber()+'\n'+e.getCause());
            wrapper.status = 'KO';
            wrapper.errorType = 'exception';
            return wrapper;
        }
    }
    
    public static CAIServiceWrapper requestToken(CAIServiceWrapper wrapper){
        SICANIAIntegration__c sicaniaIntegration = SICANIAIntegration__c.getOrgDefaults();
        
        Http call = new Http();         
        HttpRequest request = new HttpRequest();
        request.setEndpoint(sicaniaIntegration.RequestTokenEndpoint__c);
        request.setMethod('POST');
        System.debug('### '+JSON.serialize(wrapper.tokenRequestWrapper));
        request.setBody(JSON.serialize(wrapper.tokenRequestWrapper));
        if(String.isNotBlank(sicaniaIntegration.CertificateName__c))
        	request.setClientCertificateName(sicaniaIntegration.CertificateName__c);
        request.setHeader('Accept','application/json'); 
        request.setHeader('Content-type', 'application/json;charset=UTF-8');
        request.setHeader('Connection','Keep-Alive');
		request.setHeader('Accept-Encoding','gzip,deflate');
        HttpResponse response = call.send(request);
        
        wrapper.tokenResponseWrapper.statusCode = response.getStatusCode();
        wrapper.tokenResponseWrapper.body = response.getBody();
        wrapper.tokenResponseWrapper.status = 'OK';
        wrapper.status = 'OK';
        
        
        if (response.getStatusCode() != 201 ){
            wrapper.tokenResponseWrapper.status = 'KO';
            wrapper.errorType = 'exception';
            wrapper.status = 'KO';
            return wrapper;
        }
        
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        wrapper.tokenResponseWrapper.token = (String) result.get('token');
        System.debug('***** token: '+result.get('token'));
        
        return wrapper;
        
    }
    
    public static CAIServiceWrapper validateToken( CAIServiceWrapper wrapper){
        SICANIAIntegration__c sicaniaIntegration = SICANIAIntegration__c.getOrgDefaults();
        Http call = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(sicaniaIntegration.ValidateTokenEndpoint__c);
        request.setMethod('GET');
        request.setHeader('x-token', wrapper.tokenResponseWrapper.token);
        if(String.isNotBlank(sicaniaIntegration.CertificateName__c))
        	request.setClientCertificateName(sicaniaIntegration.CertificateName__c);
        HttpResponse response = call.send(request);
        
        wrapper.validatetokenResponseWrapper.statusCode = response.getStatusCode();
        wrapper.validatetokenResponseWrapper.body = response.getBody();
        wrapper.validatetokenResponseWrapper.status = 'OK';
        wrapper.status = 'OK';
        
        if (response.getStatusCode() != 200 ){
            wrapper.tokenResponseWrapper.status = 'KO';
            wrapper.status = 'KO';
            wrapper.errorType = 'exception';
            return wrapper;
        }
        
        return wrapper;
    }
    
    public static CAIServiceWrapper counterParties( CAIServiceWrapper wrapper){
        SICANIAIntegration__c sicaniaIntegration = SICANIAIntegration__c.getOrgDefaults();
        Http call = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(sicaniaIntegration.counterPartiesEndpoint__c+'?plate='+wrapper.counterPartiesRequestWrapper.plateCounterParties);
        request.setMethod('GET');
        request.setHeader('x-token', wrapper.tokenResponseWrapper.token);
        request.setHeader('Accept','application/json'); 
        request.setHeader('Content-type', 'application/json;charset=UTF-8');
        request.setHeader('Connection','Keep-Alive');
		request.setHeader('Accept-Encoding','gzip,deflate');
        if(String.isNotBlank(sicaniaIntegration.CertificateName__c))
        	request.setClientCertificateName(sicaniaIntegration.CertificateName__c);
       
        System.debug('####: '+request);
        HttpResponse response = call.send(request);
        System.debug('### '+response.getBody());
        
        if( response.getStatusCode() == 200 ){
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
             wrapper.counterPartiesResponseWrapper.insuranceCompanyDni = (String) result.get('insuranceCompanyDni');
             wrapper.counterPartiesResponseWrapper.make = (String) result.get('make');
             wrapper.counterPartiesResponseWrapper.model = (String) result.get('model');
             wrapper.counterPartiesResponseWrapper.vehicleProvenance = (String) result.get('vehicleProvenance');
             wrapper.counterPartiesResponseWrapper.vehicleType = (String) result.get('vehicleType');
            //wrapper.counterPartiesResponseWrapper = (CAIServiceWrapper.CAICounterPartiesServiceResponseWrapper)JSON.deserialize(response.getBody(),CAIServiceWrapper.CAICounterPartiesServiceResponseWrappe.class);
        }
        
        wrapper.counterPartiesResponseWrapper.statusCode = response.getStatusCode();
        wrapper.counterPartiesResponseWrapper.body = response.getBody();
        wrapper.counterPartiesResponseWrapper.status = 'OK';
        wrapper.status = 'OK';
        
        if (response.getStatusCode() != 200 ){
            wrapper.counterPartiesResponseWrapper.status = 'KO';
            wrapper.status = 'KO';
            wrapper.errorType = 'exception';
            return wrapper;
        }
        
        return wrapper;
    }
    
    @auraEnabled
    public static CAIServiceWrapper invokeSicAnia(String plate, String policyId, String publicId, String personId, String userId, String plateCounterParties ){
        CAIServiceWrapper wrapper = new CAIServiceWrapper();
        wrapper.tokenRequestWrapper.plate = plate;
        wrapper.tokenRequestWrapper.policyId = policyId;
        wrapper.tokenRequestWrapper.publicId = publicId;
        wrapper.tokenRequestWrapper.personId = personId;
        wrapper.tokenRequestWrapper.userId = userId; 
		
        wrapper.counterPartiesRequestWrapper.plateCounterParties = plateCounterParties; 
        
        CAIServiceWrapper wrapperResponse = invoke(wrapper);
        System.debug('###:'+wrapper);
        return wrapperResponse;
        

    } 
}