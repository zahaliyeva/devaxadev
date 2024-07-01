/*------------------------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         IE_GetAllPolicies
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

26/9/2018     Created 
-------------------------------------------------------------------------------------------*/
public class IE_GetAllPolicies {

    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<String, String> values { get; set; }
        //@AuraEnabled public GetAllPoliciesResponse deserializedResult { get; set; } PURE IT RIMOZIONE REFERENZA
        //@AuraEnabled public GetAllPoliciesResponse[] deserializedResults { get; set; } PURE IT RIMOZIONE REFERENZA
        
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<String, String>();
            //this.deserializedResult = new GetAllPoliciesResponse(); PURE IT RIMOZIONE REFERENZA
            //this.deserializedResults = new List<GetAllPoliciesResponse>(); PURE IT RIMOZIONE REFERENZA
        }   
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<String, String>();
        }       
    }

    public static IE_Integration_Record__c PopulateIErecord_GetAllPolicies(String email, String fiscalCode, String accountId) {
        IE_Integration_Record__c theResult  = new IE_Integration_Record__c();
        List<IE_Configuration__c> theConfig = [SELECT id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c, NameSpaceUri2__c, Endpoint__c, Certificate__c FROM IE_Configuration__c WHERE Name = 'CaringAngel_GetAllPolicies' LIMIT 1];
        

        if (!theConfig.isempty()) {
            theResult.IE_Configuration__c = theConfig[0].id;
        }
        
        
 

        /*theResult.RequestBody__c = 'userId'+''+email+'\n'+
                                   'personId'+''+fiscalCode;*/
        theResult.RequestBody__c = theConfig[0].Endpoint__c;                          
        theResult.URLRequest__c = theConfig[0].Endpoint__c;
        theResult.ScopeID__c = accountId;
                                
        
        return theResult;
    }
    
	@AuraEnabled
    public static ResponseDto sendRequest(String fiscalCode, String accountId) {
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
	        myIR = PopulateIErecord_GetAllPolicies(email, fiscalCode, accountId);
	        IE_Engine myIE = new IE_Engine(myIR);
	        Map<String,String> headerAttributes = new Map<String,String>();
	        
	        headerAttributes.put('userId',email);
	        headerAttributes.put('personId',fiscalCode);
	        headerAttributes.put('Accept','application/json');
	        
	        try {
	            myIE.compileRequest();
	        } catch (exception e) {
	            String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: "Si è verificato un errore nel compilare la richiesta verso ESG". \nSe il problema persiste contatta il tuo referente AXA.';
	            system.debug('*********Eccezione e ='+e);
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	            
	        }
	        
	        try {
	            myIE.sendRequest(headerAttributes);
	        } catch (exception e) {
	            
	            upsert myIR;
	            String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: "Si è verificato un errore nell\'inviare la richiesta verso ESG".\n Se il problema persiste contatta il tuo referente AXA.';
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	            
	        }
	        
	        try {
	            myIE.interpretResponse();
	            system.debug('**********json response'+myIE.JSONResponse);
	            
	            
	            res = manageResponse_GetAllPolicies(myIE); 
	            
	            
	        } catch (exception e) {
	            String errorsStr = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: "Si è verificato un errore nella ricezione della risposta da ESG". \nSe il problema persiste contatta il tuo referente AXA.';
	            res = new ResponseDto(false, errorsStr);
	            
	            return res;
	        }
        }
        else
        {
        	res.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: "Il codice fiscale è vuoto".\n Se il problema persiste contatta il tuo referente AXA.';
        }
        return res;
    }
    
    
    public static ResponseDto manageResponse_GetAllPolicies(IE_Engine IEInstance) {
        ResponseDto results = new ResponseDto();
        
        system.debug('****** IEInstance =' + IEInstance);
        GetAllPolicies_deserializedResults formattedResponse = mapResponse_GetAllPolicies(IEInstance.JSONResponse);

        if (formattedResponse == null)
        {
            results.isSuccess = False;
            results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi.\n Se il problema persiste contatta il tuo referente AXA.'; 
        }
        else if(!formattedResponse.isArray){
            /** PURE IT RIMOZIONE REFERENZA 
            if (formattedResponse.deserializedObject.code != null)
            {
				results.isSuccess = False;
				results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n" '+formattedResponse.deserializedObject.developerMessage+'".\n. Se il problema persiste contatta il tuo referente AXA'; 
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
                    	results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Codice risposta non gestita".\n Se il problema persiste contatta il tuo referente AXA.';
                	}
            	}
            }
			else
			{
				results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Risposta non gestita".\n Se il problema persiste contatta il tuo referente AXA.';
			}  PURE IT RIMOZIONE REFERENZA */
            system.debug('error results --> '+results);
            
        }
        /** PURE IT RIMOZIONE REFERENZA 
        else if(formattedResponse.isArray && !formattedResponse.deserializedArray.IsEmpty())
        {
            system.debug ('******SUCCESS');                       
            GetAllPolicies_setResponse (formattedResponse.deserializedArray);          
            results.isSuccess = True;     
            results.deserializedResults = formattedResponse.deserializedArray;     
        } PURE IT RIMOZIONE REFERENZA */
        else
		{
			results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Lista polizze vuota".\n Se il problema persiste contatta il tuo referente AXA.';
		}
        
        return results;
    }

    public static GetAllPolicies_deserializedResults  mapResponse_GetAllPolicies (String JSONResponse) {
        system.debug('JSONResponse : '+JSONResponse);
        //GetAllPoliciesResponse emptyInstance = new GetAllPoliciesResponse(); PURE IT RIMOZIONE REFERENZA
        //Type typeInstance = Type.forName('GetAllPoliciesResponse'); PURE IT RIMOZIONE REFERENZA
        GetAllPolicies_deserializedResults deserializedResponse = new GetAllPolicies_deserializedResults();
        //deserializedResponse.deserializedArray = new List<GetAllPoliciesResponse>(); PURE IT RIMOZIONE REFERENZA
        //deserializedResponse.deserializedObject = new GetAllPoliciesResponse(); PURE IT RIMOZIONE REFERENZA
        deserializedResponse.isArray = false;
        try
        {
            //deserializedResponse.deserializedArray = GetAllPoliciesResponse.parseList(JSONResponse); PURE IT RIMOZIONE REFERENZA
            deserializedResponse.isArray = true;
           // System.debug('***************deserialize(ARRAY) results = ' + deserializedResponse.deserializedArray); PURE IT RIMOZIONE REFERENZA 
        }  
        catch(exception ex)
        {
            //deserializedResponse.deserializedObject = GetAllPoliciesResponse.parse(JSONResponse); PURE IT RIMOZIONE REFERENZA
            deserializedResponse.isArray = false;
            //System.debug('***************deserialize(OBJECT) result = ' + deserializedResponse.deserializedObject); PURE IT RIMOZIONE REFERENZA 
        }       
        
        return deserializedResponse;
    }

   class GetAllPolicies_deserializedResults{
       // @AuraEnabled public List<GetAllPoliciesResponse> deserializedArray; PURE IT RIMOZIONE REFERENZA 
        //@AuraEnabled public GetAllPoliciesResponse deserializedObject; PURE IT RIMOZIONE REFERENZA 
        @AuraEnabled public Boolean isArray;
        
        public GetAllPolicies_deserializedResults(){}
    }
    /* PURE IT RIMOZIONE REFERENZA 
     public static void GetAllPolicies_setResponse(List<GetAllPoliciesResponse> theResponse){

        system.debug('theResponse'+theResponse);
    } PURE IT RIMOZIONE REFERENZA */
    
}