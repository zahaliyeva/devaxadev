/*------------------------------------------------------------------------------------------
   Author:        Daniela Pirelli
   Company:       Reply
   Class:         IE_GetAllPoliciesV2
   Description:   Apex class used to execute all the logics internal to the
   rest Callout related to Caring Salute

   History

   03/03/2020     Created
   ----*/
public class IE_GetPolicies {

    private static final String INTEGRATION_CONFIGURATION_NAME_GET_POLICIES = 'GetPolicies';
    private static final String INTEGRATION_CONFIGURATION_NAME_GET_POLICY = 'GetPolicy';

    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<String, String> values { get; set; }
        @AuraEnabled public GetPoliciesResponse deserializedResult { get; set; }
        @AuraEnabled public GetPoliciesResponse[] deserializedResults { get; set; }

        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<String, String>();
            this.deserializedResult = new GetPoliciesResponse();
            this.deserializedResults = new List<GetPoliciesResponse>();
        }
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<String, String>();
        }
    }

    public static IE_Integration_Record__c getIntegrationRecord(String integrationConfigurationName, Map<String,String> parameters) {
        IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();
        IE_Configuration__c integrationConfiguration = null;
        try {
            integrationConfiguration = [SELECT id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c, NameSpaceUri2__c, Endpoint__c, Certificate__c FROM IE_Configuration__c WHERE Name = :integrationConfigurationName LIMIT 1];
        } catch(Exception ex) {
            throw new IllegalArgumentException('Inserire la configurazione del servizio nel Custom Setting IE_Configuration__c');
        }
        System.PageReference pageReference = new System.PageReference('');
        pageReference.getParameters().putAll(parameters);
        if(INTEGRATION_CONFIGURATION_NAME_GET_POLICY.equals(integrationConfigurationName)){
            integrationConfiguration.Endpoint__c = integrationConfiguration.Endpoint__c.replace('{policyId}', parameters.get('policyId'));
            parameters.remove('policyId');
        }
        integrationConfiguration.Endpoint__c = integrationConfiguration.Endpoint__c + pageReference.getUrl();
        integrationRecord.IE_Configuration__c = integrationConfiguration.id;
        integrationRecord.RequestBody__c = integrationConfiguration.Endpoint__c;
        integrationRecord.URLRequest__c = integrationConfiguration.Endpoint__c;
        return integrationRecord;
    }
 

    @AuraEnabled
    public static ResponseDto sendRequestGetPolicies(String fiscalCode, String vatNumber, String portfolio, String startDate, Boolean generateIdSummary, Boolean searchInsured, Boolean showInsured,String targa ) {
        ResponseDto res = new ResponseDto();
        if(String.isBlank(startDate)) {
            res.message = 'Data Inizio obbligatorio';
            return res;
        }
        Map<String,String> parameters = new Map<String,String>();
        //if (String.isNotBlank(fiscalCode)) {parameters.put('fiscal-code', fiscalCode);}
        //if (String.isNotBlank(vatNumber)) {parameters.put('vat-number', vatNumber);}
        if (String.isNotBlank(startDate)) {parameters.put('start-date', startDate);}
        if (String.isNotBlank(portfolio)) {parameters.put('portfolio', portfolio);}
        if (generateIdSummary != null) {parameters.put('generate-id-summary', String.valueOf(generateIdSummary));}
        if (searchInsured != null) {parameters.put('search-insured', String.valueOf(searchInsured));}
        if (showInsured != null) {parameters.put('show-insured', String.valueOf(showInsured));}
        if (String.isNotBlank(targa)) {parameters.put('license-plate', targa);}// *-+ idcrm 028 28-12-2022

        System.debug('Query String Parameters: ' + JSON.serializePretty(parameters));
        IE_Integration_Record__c integrationRecord = getIntegrationRecord(INTEGRATION_CONFIGURATION_NAME_GET_POLICIES, parameters);
        IE_Engine integrationEngine = new IE_Engine(integrationRecord);
        Map<String,String> headerAttributes = new Map<String,String>();
        headerAttributes.put('fiscal-code',fiscalCode);
        headerAttributes.put('vat-number',vatNumber); 
        headerAttributes.put('Accept','application/json');
        System.debug('Header Attributes: ' + JSON.serializePretty(headerAttributes));
        try {
            integrationEngine.compileRequest();
            integrationEngine.sendRequest(headerAttributes);
            integrationEngine.interpretResponse();
            res = manageResponseGetPolicies(integrationEngine); 
            System.debug('Json Response: ' + integrationEngine.JSONResponse);
        } catch (exception e) {
            integrationRecord.ErrorMessage__c = e.getMessage();
            insert integrationRecord;
            return new ResponseDto(false, 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: "Si è verificato un errore nell\'inviare la richiesta verso ESG".\n Se il problema persiste contatta il tuo referente AXA.');
        }
        return res;
    }
    
    @AuraEnabled
    public static ResponseDto sendRequestGetPolicy(String policyId, String startDate, String fiscalCode, String vatNumber, String idAdhesion, String licensePlate, Boolean searchInsured, Boolean showInsured ,String targa ) {
        ResponseDto res = new ResponseDto();
        if(String.isBlank(policyId) ){
            res.message = 'Id Polizza obbligatorio';
            return res;
        }
        if(String.isBlank(startDate)) {
            res.message = 'Data Inizio obbligatorio';
            return res;
        }
        Map<String,String> parameters = new Map<String,String>();
        if (String.isNotBlank(policyId)) {parameters.put('policyId', policyId);}
        if (String.isNotBlank(fiscalCode)) {parameters.put('fiscalCode', fiscalCode);}
        if (String.isNotBlank(vatNumber)) {parameters.put('vatNumber', vatNumber);}
        if (String.isNotBlank(startDate)) {parameters.put('startDate', startDate);}
        if (String.isNotBlank(idAdhesion)) {parameters.put('idAdhesion', idAdhesion);}
        if (String.isNotBlank(licensePlate)) {parameters.put('licensePlate', licensePlate);}
        if (searchInsured != null) {parameters.put('searchInsured', String.valueOf(searchInsured));}
        if (showInsured != null) {parameters.put('showInsured', String.valueOf(showInsured));}
        if (targa != null) {parameters.put('targa', targa);}// *-+ idcrm 028 28-12-2022

        System.debug('Query String Parameters: ' + JSON.serializePretty(parameters));
        IE_Integration_Record__c integrationRecord = getIntegrationRecord(INTEGRATION_CONFIGURATION_NAME_GET_POLICY, parameters);
        IE_Engine integrationEngine = new IE_Engine(integrationRecord);
        Map<String,String> headerAttributes = new Map<String,String>();
        headerAttributes.put('fiscalCode',fiscalCode);
        headerAttributes.put('vatNumber',vatNumber); 
        headerAttributes.put('Accept','application/json');
        System.debug('Header Attributes: ' + JSON.serializePretty(headerAttributes));
        try {
            integrationEngine.compileRequest();
            integrationEngine.sendRequest(headerAttributes);
            integrationEngine.interpretResponse();
            // TODO: implement manageResponseGetPolicy to parse the response 
            //res = manageResponseGetPolicy(integrationEngine); 
            System.debug('Json Response: ' + integrationEngine.JSONResponse);
        } catch (exception e) {
            integrationRecord.ErrorMessage__c = e.getMessage();
            insert integrationRecord;
            return new ResponseDto(false, 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: "Si è verificato un errore nell\'inviare la richiesta verso ESG".\n Se il problema persiste contatta il tuo referente AXA.');
        }
        return res;
    }

    public static ResponseDto manageResponseGetPolicies(IE_Engine IEInstance) {
        ResponseDto results = new ResponseDto();
        
        system.debug('****** IEInstance =' + IEInstance);
        GetPolicies_deserializedResults formattedResponse = mapResponse_GetPolicies(IEInstance.JSONResponse);

        if (formattedResponse == null)
        {
            results.isSuccess = False;
            results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi.\n Se il problema persiste contatta il tuo referente AXA.'; 
        }
        else if(!formattedResponse.isArray){
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
			}
            system.debug('error results --> '+results);
            
        }
        
        else if(formattedResponse.isArray && !formattedResponse.deserializedArray.IsEmpty())
        {
            system.debug ('******SUCCESS');                                 
            results.isSuccess = True;     
            results.deserializedResults = formattedResponse.deserializedArray;     
        }
        else
		{
			results.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi. Di seguito il dettaglio dell\'errore: \n "Lista polizze vuota".\n Se il problema persiste contatta il tuo referente AXA.';
		}
        
        return results;
    }

    public static GetPolicies_deserializedResults  mapResponse_GetPolicies (String JSONResponse) {
        system.debug('JSONResponse : '+JSONResponse);
        GetPoliciesResponse emptyInstance = new GetPoliciesResponse();
        Type typeInstance = Type.forName('GetPoliciesResponse');
        GetPolicies_deserializedResults deserializedResponse = new GetPolicies_deserializedResults();
        deserializedResponse.deserializedArray = new List<GetPoliciesResponse>();
        deserializedResponse.deserializedObject = new GetPoliciesResponse();
        deserializedResponse.isArray = false;
        try
        {
            deserializedResponse.deserializedArray = GetPoliciesResponse.parseList(JSONResponse);
            deserializedResponse.isArray = true;
            System.debug('***************deserialize(ARRAY) results = ' + deserializedResponse.deserializedArray);
        }  
        catch(exception ex)
        {
            deserializedResponse.deserializedObject = GetPoliciesResponse.parse(JSONResponse);
            deserializedResponse.isArray = false;
            System.debug('***************deserialize(OBJECT) result = ' + deserializedResponse.deserializedObject);
        }       
        
        return deserializedResponse;
    }

    class GetPolicies_deserializedResults{
        @AuraEnabled public List<GetPoliciesResponse> deserializedArray;
        @AuraEnabled public GetPoliciesResponse deserializedObject;
        @AuraEnabled public Boolean isArray;
        
        public GetPolicies_deserializedResults(){}
    }

}