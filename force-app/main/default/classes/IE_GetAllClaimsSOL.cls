/*------------------------------------------------------------------------------------------
Company:       Reply
Class:         IE_GetAllClaimsSOL
Description:   Apex class used to execute all the logics internal to the 
rest Callout on SOL

History

28/4/2020     Created 
-------------------------------------------------------------------------------------------*/
public class IE_GetAllClaimsSOL {


    public static IE_Integration_Record__c PopulateIErecord_GetAllClaims( IE_Configuration__c theConfig, String fiscalCode, String identifiedId, String policyNumber, Boolean incompleteReports) {

        IE_Integration_Record__c theResult  = new IE_Integration_Record__c();  
      
        theResult.IE_Configuration__c = theConfig.id;
        
        
       if(String.isNotBlank(policyNumber))
    		theConfig.Endpoint__c = theConfig.Endpoint__c+'?policyNumber='+policyNumber;
        
        theConfig.Endpoint__c =  incompleteReports == false ? theConfig.Endpoint__c+'?incompleteReports=false' : theConfig.Endpoint__c+'?incompleteReports=true';
    	
		
        // <-- REAL REQUEST 
        theResult.RequestBody__c = theConfig.Endpoint__c;
        theResult.URLRequest__c = theConfig.Endpoint__c;
        theResult.ScopeID__c = identifiedId; 
        
        return theResult;
    }
    
    

    @AuraEnabled
    public static ResponseDto sendRequest(String fiscalCode, String policyNumber, String kpi, String identifiedId,Boolean incompleteReports ) {
        String confName = 'SOL_GetAllClaims';
        IE_Configuration__c theConfig = [SELECT id, SignedCertificatedSFDC__c, ClientId__c, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c, NameSpaceUri2__c, 
                                               Type__c, Endpoint__c, Certificate__c, Timeout__c, Name, Insert_IR_WS__c, HTTPMethod__c 
                                               FROM IE_Configuration__c 
                                               WHERE Name =: ConfName LIMIT 1];
        ResponseDto res = new ResponseDto();
        if(String.isNotBlank(fiscalCode))
        {
	        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
	  
			myIR = PopulateIErecord_GetAllClaims(theConfig,fiscalCode, identifiedId, policyNumber, incompleteReports);
	        IE_Engine myIE = new IE_Engine(myIR);
	        Map<String,String> headerAttributes = new Map<String,String>();
            
       
            
            Map<String,String> claims = new Map<String,String>();
            claims.put('client_id', theConfig.ClientId__c);
            if(!Test.isRunningTest()){ 
            Auth.JWT jwt = new Auth.JWT();
            // add standard claims
            jwt.setIss(URL.getSalesforceBaseUrl().toExternalForm());
     
             // add custom claims
            jwt.setAdditionalClaims(claims);
            Auth.JWS signedToken = new Auth.JWS(jwt, theConfig.SignedCertificatedSFDC__c);
            String serializedToken = signedToken.getCompactSerialization();
            System.debug(serializedToken);
	
            headerAttributes.put('x-axa-context',serializedToken);
            }    
            headerAttributes.put('x-axa-initialmsgid',identifiedId);
	        headerAttributes.put('personId',fiscalCode);
            headerAttributes.put('kpi',kpi); 
	        headerAttributes.put('Accept','application/json');
	        headerAttributes.put('Content-type','application/json');
	        
	        try {
	            myIE.compileRequest();
       
	        } catch (exception e) {
	            String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Si è verificato un errore nel compilare la richiesta verso ESG".\n Se il problema persiste contatta il tuo referente AXA.';
	            system.debug('Exception = '+e.getStackTraceString());
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	            
	        }
	        
	        try {
                for(String headerAttributeKey : headerAttributes.keySet()) {
        	        System.debug('Header Attribute Key: ' + headerAttributeKey + ' Value: ' + headerAttributes.get(headerAttributeKey));
                }
	            myIE.sendRequest(headerAttributes);
	        } catch (exception e) {
	            system.debug('Exception = '+e.getStackTraceString());
	            upsert myIR;
	            String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Si è verificato un errore nell\'inviare la richiesta verso ESG".\n Se il problema persiste contatta il tuo referente AXA.';
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	            
	        }
	        
	        try {
	            myIE.interpretResponse();
	            system.debug('*** GET ALL CLAIMS SOL json response'+myIE.JSONResponse);
	            
	
	           res = manageResponse_GetAllClaims(myIE); 
	            
	            
	        } catch (exception e) {
                system.debug('Exception = '+e.getStackTraceString());
                String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Si è verificato un errore nella ricezione della risposta da ESG".\n Se il problema persiste contatta il tuo referente AXA.';
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	        }
        }
        else
    	{
    		res.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Il codice fiscale è vuoto".\n Se il problema persiste contatta il tuo referente AXA.';
    	}
        return res;
    }
    
    
    public static ResponseDto manageResponse_GetAllClaims(IE_Engine IEInstance) {
        ResponseDto results = new ResponseDto();
        
        system.debug('****** IEInstance =' + IEInstance);
        GetAllClaims_deserializedResults formattedResponse = mapResponse_GetAllClaims(IEInstance.JSONResponse);
		
		if (formattedResponse == null)
        {
            results.isSuccess = False;
            results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA.'; 
        }
		else if(!formattedResponse.isArray && formattedResponse.deserializedObject != null ){
			if (formattedResponse.deserializedObject.errors != null)
			{
				//GESTIONE ERRORE
				results.isSuccess = False;
				results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "'+formattedResponse.deserializedObject.errors[0].detail+'".\n Se il problema persiste contatta il tuo referente AXA.'; 
				results.values.put('code',formattedResponse.deserializedObject.errors[0].code);
		
	           
			}
			else
			{
               system.debug ('******SUCCESS');
               results.isSuccess = True; 
               results.deserializedResult = formattedResponse.deserializedObject;
			}
			system.debug('results --> '+results);
		}
		
        else if(formattedResponse.isArray)
        {
            results.deserializedResults = formattedResponse.deserializedArray;                 
            results.isSuccess = false; 
            results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Risposta non gestita".\n Se il problema persiste contatta il tuo referente AXA.';

        }
       
        return results;

    }

     static GetAllClaims_deserializedResults  mapResponse_GetAllClaims (String JSONResponse) {
    	system.debug('JSONResponse : '+JSONResponse);

        Type typeInstance = Type.forName('GetAllClaimsSOLResponse');
        GetAllClaims_deserializedResults deserializedResponse = new GetAllClaims_deserializedResults();
        deserializedResponse.deserializedArray = new List<GetAllClaimsSOLResponse>();
        deserializedResponse.deserializedObject = new GetAllClaimsSOLResponse();
        deserializedResponse.isArray = false;
        try
		{
			deserializedResponse.deserializedArray = GetAllClaimsSOLResponse.parseList(JSONResponse);
			deserializedResponse.isArray = true;
			System.debug('***************deserialize(ARRAY) results = ' + deserializedResponse.deserializedArray);
		}  
		catch(exception ex)
		{
			deserializedResponse.deserializedObject = GetAllClaimsSOLResponse.parse(JSONResponse);
			deserializedResponse.isArray = false;
			System.debug('***************deserialize(OBJECT) result = ' + deserializedResponse.deserializedObject);
		}      	
        
        return deserializedResponse;
    }
    
    public class GetAllClaims_deserializedResults{
    	@AuraEnabled public List<GetAllClaimsSOLResponse> deserializedArray;
    	@AuraEnabled public GetAllClaimsSOLResponse deserializedObject;
    	@AuraEnabled public Boolean isArray;
    	
    	public GetAllClaims_deserializedResults(){}
    }


   
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<String, String> values { get; set; }
        @AuraEnabled public GetAllClaimsSOLResponse deserializedResult { get; set; }
        @AuraEnabled public GetAllClaimsSOLResponse[] deserializedResults { get; set; }
        
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<String, String>();
            this.deserializedResult = new GetAllClaimsSOLResponse();
            this.deserializedResults = new List<GetAllClaimsSOLResponse>(); 
        }   
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<String, String>();
        }       
    }
    
}