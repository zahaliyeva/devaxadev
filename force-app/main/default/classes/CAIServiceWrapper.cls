public class CAIServiceWrapper {
    @auraEnabled
    public Integer statusCode {get;set;}
    @auraEnabled
    public String status {get;set;}
    @auraEnabled
    public String errorMessage {get;set;}
    @auraEnabled
    public String errorType {get;set;}
    @auraEnabled
    public CAITokenServiceRequestWrapper  tokenRequestWrapper {get;set;}
    @auraEnabled
    public CAITokenServiceResponseWrapper tokenResponseWrapper {get;set;} 
    @auraEnabled
    public CAIValidateTokenServiceResponseWrapper validatetokenResponseWrapper {get;set;} 
    @auraEnabled
    public CAICounterPartiesServiceResponseWrapper counterPartiesResponseWrapper{get;set;}
     @auraEnabled
    public CAICounterPartiesServiceRequestWrapper counterPartiesRequestWrapper{get;set;}
    
    public CAIServiceWrapper(){
        tokenRequestWrapper = new CAITokenServiceRequestWrapper();
        tokenResponseWrapper = new CAITokenServiceResponseWrapper();
        validatetokenResponseWrapper = new CAIValidateTokenServiceResponseWrapper();
        counterPartiesResponseWrapper = new CAICounterPartiesServiceResponseWrapper();
        counterPartiesRequestWrapper = new CAICounterPartiesServiceRequestWrapper();
    }
    
    public class CAITokenServiceRequestWrapper {
        @auraEnabled
        public String plate    {get;set;}
        @auraEnabled
        public String policyId {get;set;}
        @auraEnabled
        public String publicId {get; set;}
        @auraEnabled
        public String personId {get; set;}
        @auraEnabled
        public String userId   {get; set;}
    }
    
    public class CAITokenServiceResponseWrapper {
        @auraEnabled
        public String status {get;set;} 
        @auraEnabled
        public Integer statusCode {get;set;}
        @auraEnabled
        public String body {get;set;}
        @auraEnabled
        public String token {get;set;}
    }
    
    public class CAIValidateTokenServiceResponseWrapper {
        @auraEnabled
        public String status {get;set;}
        @auraEnabled
        public Integer statusCode {get;set;}
        @auraEnabled
        public String body {get;set;}
    }
    public class CAICounterPartiesServiceRequestWrapper{
    	@auraEnabled
        public String plateCounterParties {get;set;}
    }
    
    public class CAICounterPartiesServiceResponseWrapper {
        public String status {get;set;} 
        @auraEnabled
        public Integer statusCode {get;set;}
        @auraEnabled
        public String body {get;set;}
        @auraEnabled
        public String insuranceCompanyDni {get;set;}
        @auraEnabled
        public String make {get;set;}
        @auraEnabled
        public String model {get;set;}
        @auraEnabled
        public String vehicleProvenance {get;set;}
        @auraEnabled
        public String vehicleType {get;set;}
        
    }
    
}