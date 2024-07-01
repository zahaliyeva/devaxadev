public class IE_DocumentValidation {

    /*
    [201] -> http://www.mocky.io/v2/5d1b583c3400000f00000728
    [422] -> http://www.mocky.io/v2/5d1b5d263400004c00000756
     */

    private static IE_Integration_Record__c populateIntegrationRecord(Id recordId) {
        IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();
        String configurationName = 'DocumentValidation';
        IE_Configuration__c configuration = [
                SELECT Id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c,
                        NameSpaceUri2__c, Type__c, EndPoint__c, Certificate__c, Timeout__c,
                        Name, Insert_IR_WS__c, HTTPMethod__c
                FROM IE_Configuration__c
                WHERE Name = :configurationName
                LIMIT 1
        ];

        integrationRecord.ScopeID__c = recordId;
        integrationRecord.IE_Configuration__c = configuration.Id;
        integrationRecord.URLRequest__c = configuration.EndPoint__c;
        integrationRecord.RequestBody__c = getRequestBody(recordId);

        return integrationRecord;
    }

    public static ResponseDto sendRequest(Id recordId) {

        ResponseDto response;

        try {
            Map<String, String> headerAttributes = getHeaders();
            IE_Integration_Record__c integrationRecord = populateIntegrationRecord(recordId);
            IE_Engine IEInstance = new IE_Engine(integrationRecord);
            IEInstance.compileRequest();
            IEInstance.sendRequest(headerAttributes);
            IEInstance.interpretResponse();
            response = getResponseDto(IEInstance);

        } catch (MissingArgumentException e) {
            System.debug('MissingArgumentException: ' + e.getMessage() + ' | ' + e.getLineNumber());
            response = new ResponseDto(false, 999, e.getMessage());

        } catch (transcodeException e) {
            System.debug('transcodeException: ' + e.getMessage() + ' | ' + e.getLineNumber());
            response = new ResponseDto(false, 987, e.getMessage());

        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + ' | ' + e.getLineNumber());
            response = new ResponseDto(false, 111, e.getMessage());

        }

        System.debug('DBG - ResponseDto: ' + response);

        return response;
    }

    public static Map<String, String> getHeaders() {
        Map<String, String> headerAttributes = new Map<String, String>();
        String username = UserInfo.getUserName();
        headerAttributes.put('actor', username);

        List<MPS_Code_Utils__mdt> mpsCodeUtils = [
                SELECT Key__c, Value__c
                FROM MPS_Code_Utils__mdt
                WHERE DeveloperName LIKE 'ValidazioneVisuraCameraleHeader%'
                AND Key__c != NULL
                AND Value__c != NULL
        ];

        for (MPS_Code_Utils__mdt mps : mpsCodeUtils) {
            headerAttributes.put(mps.Key__c, mps.Value__c);

        }

        System.debug('DBG - headerAttributes: ' + JSON.serializePretty(headerAttributes));

        return headerAttributes;
    }

    private static String getRequestBody(Id recordId) {

        Case c = [
            SELECT Id, Account.AAI_Partita_IVA__c, SuppliedEmail, LinkToPolicy__r.Name,Compagnia_Polizze__c,
            Polizza_Registrazione_PG__c,Account.TECH_Company__c, LinkToPolicy__r.TECH_Company__c, Account.Partita_IVA__c
            FROM Case
                WHERE Id = :recordId
        ];

        /*String techCompany = '%' + c.Account.TECH_Company__c + '%';

        List<MPS_Code_Utils__mdt> mpsCodeUtils = [
                SELECT Key__c, Value__c
                FROM MPS_Code_Utils__mdt
                WHERE DeveloperName LIKE 'ValidazioneVisuraCameraleLegalEntity%'
                AND Key__c LIKE :techCompany
                AND Value__c != NULL
                LIMIT 1
        ];*/
        Map<String, String> transcodeLegalEntityMap = new Map<String, String>();
        List<MPS_Code_Utils__mdt> mpsCodeUtils = [
                SELECT Key__c, Value__c
                FROM MPS_Code_Utils__mdt
                WHERE DeveloperName LIKE 'ValidazioneVisuraCameraleLegalEntity%'
        ];
		for(MPS_Code_Utils__mdt mps : mpsCodeUtils) {
       		if(mps.Key__c!=null){
       			for(String s:mps.Key__c.split(';')){
                    transcodeLegalEntityMap.put(s, mps.value__c);                
                }
       		}
		}
       		
        String typeHeader = 'user-registration';
        String vatNumber = (String.isNotBlank(c.Account.AAI_Partita_IVA__c))?c.Account.AAI_Partita_IVA__c :c.Account.Partita_IVA__c;
        
        //val *-+ 23-11-2021
        String publicId = (String.isBlank(c.LinkToPolicy__r.Name))?c.Polizza_Registrazione_PG__c:c.LinkToPolicy__r.Name;
        String companyName = (String.isBlank(c.LinkToPolicy__r.TECH_Company__c))?c.Compagnia_Polizze__c:c.LinkToPolicy__r.TECH_Company__c;

        String email = c.SuppliedEmail;
        String legalEntity = '';
        if(transcodeLegalEntityMap.containsKey(c.Account.TECH_Company__c)){
        	legalEntity = transcodeLegalEntityMap.get(c.Account.TECH_Company__c);
        } else if(transcodeLegalEntityMap.containsKey(companyName)){
        	legalEntity = transcodeLegalEntityMap.get(companyName);
        } else{
	        throw new transcodeException('parameter not found');
        }
        return getJSONString(typeHeader, vatNumber, publicId, companyName, email, legalEntity);
    }

    private static String getJSONString(String typeHeader, String vatNumber, String publicId, String companyName, String email, String legalEntity) {

        if (String.isBlank(typeHeader)
                || String.isBlank(vatNumber)
                || String.isBlank(publicId)
                || String.isBlank(companyName)
                || String.isBlank(email)
                || String.isBlank(legalEntity)) {

            throw new MissingArgumentException('one or more arguments are null');
        }

        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('data');
        generator.writeStartObject();
        generator.writeStringField('type', typeHeader);
        generator.writeFieldName('attributes');
        generator.writeStartObject();
        generator.writeStringField('vatNumber', vatNumber);
        generator.writeStringField('publicId', publicId);
        generator.writeStringField('companyName', companyName);
        generator.writeStringField('email', email);
        generator.writeStringField('legalEntity', legalEntity);
        generator.writeEndObject();
        generator.writeEndObject();
        generator.writeEndObject();

        String result = generator.getAsString();
        System.debug('DBG - Body: ' + result);

        return result;
    }

    private static DocumentValidationResponse getDeserializedResponse(IE_Engine IEInstance) {
        String json = IEInstance.JSONResponse;
        system.debug('json: '+json);
        DocumentValidationResponse response = (DocumentValidationResponse) System.JSON.deserialize(json, DocumentValidationResponse.class);
		system.debug('Deserializedresponse: '+response);
        return response;
    }

    private static ResponseDto getResponseDto(IE_Engine IEInstance) {
        Integer statusCode = IEInstance.RawResponse.getStatusCode();
        String status = IEInstance.RawResponse.getStatus();
        DocumentValidationResponse deserializedResponse = getDeserializedResponse(IEInstance);

        Boolean isSuccess = statusCode == 201;
        //String message = isSuccess ? status : status + ' - Errore ' + deserializedResponse.errors[0].status +' | '+ deserializedResponse.errors[0].title;
        String message = isSuccess ? status : status + ' - Errore ' + deserializedResponse.status +' | '+ deserializedResponse.title;

        return new ResponseDto(isSuccess, statusCode, message);
    }

    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled
        public Boolean isSuccess { get; set; }
        @AuraEnabled
        public Integer statusCode { get; set; }
        @AuraEnabled
        public String message { get; set; }

        public ResponseDto() {
        }

        public ResponseDto(Boolean isSuccess, Integer statusCode, String message) {
            this.isSuccess = isSuccess;
            this.statusCode = statusCode;
            this.message = message;
        }
    }

    public class MissingArgumentException extends Exception {
    }
    
    public class transcodeException extends Exception {
    }

}