/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         IE_GetAllClaims
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

27/9/2018     Created 
-------------------------------------------------------------------------------------------*/
public class IE_GetAllClaims {


    public static IE_Integration_Record__c PopulateIErecord_GetAllClaims(String email, String fiscalCode, String accountId, String policyNumber, Boolean showPreDenunciations, Boolean showIncompleteReports) {
        IE_Integration_Record__c theResult  = new IE_Integration_Record__c();
        String confName = 'CaringAngel_GetAllClaims';
        List<IE_Configuration__c> theConfig = [SELECT id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c, NameSpaceUri2__c, 
                                               Type__c, Endpoint__c, Certificate__c, Timeout__c, Name, Insert_IR_WS__c, HTTPMethod__c 
                                               FROM IE_Configuration__c 
                                               WHERE Name =: ConfName LIMIT 1];

        if (!theConfig.isempty()) {
            theResult.IE_Configuration__c = theConfig[0].id;
        }
         // --> REAL REQUEST 
        if(String.isNotBlank(policyNumber) && showPreDenunciations!=null)
        	theConfig[0].Endpoint__c = theConfig[0].Endpoint__c+'?policyNumber='+policyNumber+'&showPreDenunciations='+showPreDenunciations;
    	else if(String.isNotBlank(policyNumber) && showPreDenunciations==null)
    		theConfig[0].Endpoint__c = theConfig[0].Endpoint__c+'?policyNumber='+policyNumber;
		else if(String.isBlank(policyNumber) && showPreDenunciations!=null)
    		theConfig[0].Endpoint__c = theConfig[0].Endpoint__c+'?showPreDenunciations='+showPreDenunciations;
		// <-- REAL REQUEST 
		if(showIncompleteReports!=null)
        	theConfig[0].Endpoint__c = theConfig[0].Endpoint__c+'&showIncompleteReports='+showIncompleteReports;
        theResult.RequestBody__c = theConfig[0].Endpoint__c;//'userId'+''+email+'\n'+'personId'+''+fiscalCode;
        theResult.URLRequest__c = theConfig[0].Endpoint__c;
        theResult.ScopeID__c = accountId; 
        
        return theResult;
    }
    
    
    //* = Required
    //userId *				= 	Indirizzo email dell’utente
    //accountId *			= 	CustomerID utilizzato per il login. Corrisponde al codice fiscale dell’utente
    //policyNumber 			= 	Numero polizza del contraente
    //showPreDenunciations	=	Indica se visualizzare o meno le predenunce
    @AuraEnabled
    public static ResponseDto sendRequest(String fiscalCode, String policyNumber, Boolean showPreDenunciations, String accountId, Boolean showIncompleteReports) {
        
        ResponseDto res = new ResponseDto();
        if(String.isNotBlank(fiscalCode))
        {
	        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
	        String email = '';
	        if(MPS_Code_Variables__c.getValues('CaringAngel_EmailToCallSOL')!=null)
			{
				if(String.isNotBlank(MPS_Code_Variables__c.getValues('CaringAngel_EmailToCallSOL').value__c))
				{
					email = MPS_Code_Variables__c.getValues('CaringAngel_EmailToCallSOL').value__c;
				}
			}
			myIR = PopulateIErecord_GetAllClaims(email, fiscalCode, accountId, policyNumber, showPreDenunciations, showIncompleteReports);
	        IE_Engine myIE = new IE_Engine(myIR);
	        Map<String,String> headerAttributes = new Map<String,String>();
	        
	        headerAttributes.put('userId',email);
	        headerAttributes.put('personId',fiscalCode);
	        headerAttributes.put('Accept','application/json');
	        headerAttributes.put('Content-type','application/json');
	        
	        try {
	            myIE.compileRequest();
	        } catch (exception e) {
	            String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Si è verificato un errore nel compilare la richiesta verso ESG".\n Se il problema persiste contatta il tuo referente AXA.';
	            system.debug('*********Eccezione e ='+e);
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	            
	        }
	        
	        try {
	            myIE.sendRequest(headerAttributes);
	        } catch (exception e) {
	            
	            upsert myIR;
	            String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Si è verificato un errore nell\'inviare la richiesta verso ESG".\n Se il problema persiste contatta il tuo referente AXA.';
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	            
	        }
	        
	        try {
	            myIE.interpretResponse();
	            system.debug('**********json response'+myIE.JSONResponse);
	            
	
	            res = manageResponse_GetAllClaims(myIE); 
	            
	            
	        } catch (exception e) {
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
		else if(!formattedResponse.isArray){
			if (formattedResponse.deserializedObject.code != null)
			{
				//GESTIONE ERRORE
				results.isSuccess = False;
				results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "'+formattedResponse.deserializedObject.developerMessage+'".\n Se il problema persiste contatta il tuo referente AXA.'; 
				results.values.put('code',formattedResponse.deserializedObject.code);
				results.deserializedResult = formattedResponse.deserializedObject;
	           	if (formattedResponse.deserializedObject.code.startsWithIgnoreCase('F110'))
    			{
    				results.values.put('Description','Empty userId in header.');
	            }
	            else if (formattedResponse.deserializedObject.code.startsWithIgnoreCase('T710'))
	            {
	            	results.values.put('Description','EIP Unhandled errors at EIP level');
            	}
	            else if (formattedResponse.deserializedObject.code.startsWithIgnoreCase('T720'))
	            {
	            	results.values.put('Description','Faults returned by the BackEnd services.');
	            }
            	else{
	                //errore risposta non gestita
	                results.isSuccess = False;
                	if(String.isNotBlank(formattedResponse.deserializedObject.developerMessage)){
                    	results.message = formattedResponse.deserializedObject.developerMessage;
                        
    				}
    				else{
                    	results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Codice risposta non gestita".\n Se il problema persiste contatta il tuo referente AXA.';
                	}
            	}
			}
			else
			{
				results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Risposta non gestita".\n Se il problema persiste contatta il tuo referente AXA.';
			}
			system.debug('error results --> '+results);
		}
		
        else if(formattedResponse.isArray && !formattedResponse.deserializedArray.IsEmpty())
        {
            system.debug ('******SUCCESS');                       
            GetAllClaims_setResponse (formattedResponse.deserializedArray);          
            results.isSuccess = True;   
            results.deserializedResults = formattedResponse.deserializedArray;
        }
        else
		{
			results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sui sinistri, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Non è stato possibile recuperare alcun sinistro associato al cliente. ".\n Se il problema persiste contatta il tuo referente AXA.';
		}
        
        return results;

    }

    public static GetAllClaims_deserializedResults  mapResponse_GetAllClaims (String JSONResponse) {
    	system.debug('JSONResponse : '+JSONResponse);
        GetAllClaimsResponse emptyInstance = new GetAllClaimsResponse();
        Type typeInstance = Type.forName('GetAllClaimsResponse');
        GetAllClaims_deserializedResults deserializedResponse = new GetAllClaims_deserializedResults();
        deserializedResponse.deserializedArray = new List<GetAllClaimsResponse>();
        deserializedResponse.deserializedObject = new GetAllClaimsResponse();
        deserializedResponse.isArray = false;
        try
		{
			deserializedResponse.deserializedArray = GetAllClaimsResponse.parseList(JSONResponse);
        	//deserializedResponse.deserializedArray = (List<GetAllClaimsResponse>)JSON.deserialize(JSONResponse, List<GetAllClaimsResponse>.class);
			deserializedResponse.isArray = true;
			System.debug('***************deserialize(ARRAY) results = ' + deserializedResponse.deserializedArray);
		}  
		catch(exception ex)
		{
			deserializedResponse.deserializedObject = GetAllClaimsResponse.parse(JSONResponse);
			//deserializedResponse.deserializedObject = (GetAllClaimsResponse)JSON.deserialize(JSONResponse, GetAllClaimsResponse.class);
			deserializedResponse.isArray = false;
			System.debug('***************deserialize(OBJECT) result = ' + deserializedResponse.deserializedObject);
		}      	
        
        return deserializedResponse;
    }
    
    class GetAllClaims_deserializedResults{
    	@AuraEnabled public List<GetAllClaimsResponse> deserializedArray;
    	@AuraEnabled public GetAllClaimsResponse deserializedObject;
    	@AuraEnabled public Boolean isArray;
    	
    	public GetAllClaims_deserializedResults(){}
    }

     public static void GetAllClaims_setResponse(List<GetAllClaimsResponse> theResponse){
     	system.debug('theResponse -->  '+theResponse);
    }
    
   
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<String, String> values { get; set; }
        @AuraEnabled public GetAllClaimsResponse deserializedResult { get; set; }
        @AuraEnabled public GetAllClaimsResponse[] deserializedResults { get; set; }
        
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<String, String>();
            this.deserializedResult = new GetAllClaimsResponse();
            this.deserializedResults = new List<GetAllClaimsResponse>(); 
        }   
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<String, String>();
        }       
    }
    
}