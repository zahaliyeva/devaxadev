/** 
* @author	Reply
* @date	04/2023
* @description Execution of FEQ Integration
*/
public with sharing class IE_FEQ_kyc_cancel {
    /** 
    * @param deticaId detica id
    * @param operation Impostare A per annullare il questionario, Impostare V per ripristinare il questionario
    * @return response
    * @description execute integration
    */        
    public static ResponseDto cancelKyc(string deticaId, string operation) {
        ResponseDto rw;
        Map<String, String> headerAttributes = new Map<string,string>();
        IE_Integration_Record__c integrationRecord;
        try{
            integrationRecord = getIntegrationRecord(deticaId, operation, headerAttributes);
            IE_Engine iEInstance = new IE_Engine(integrationRecord);
            IEInstance.compileRequest();
            IEInstance.sendRequest(headerAttributes);
            IEInstance.interpretResponse();  
            rw = getResponseDto(IEInstance);
        } catch (Exception e){
            throw new FeqException(e);
        }
        return rw;
    }
    
    /** 
    * @param deticaId detica id
    * @param operation operation
    * @param headerAttributes call attributes
    * @return integration record
    * @description return integration record with call's description
    */ 
    private static IE_Integration_Record__c getIntegrationRecord(String deticaId, String operation, Map<String, String> headerAttributes) {
        IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();
        String configurationName = 'IE_FEQ_kyc-cancel';
        IE_Configuration__c configuration = [
            SELECT Id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c,
            NameSpaceUri2__c, Type__c, EndPoint__c, Certificate__c, Timeout__c,
            Name, Insert_IR_WS__c, HTTPMethod__c, Silva_Access_Token__c
            FROM IE_Configuration__c
            WHERE Name = :configurationName
            WITH SYSTEM_MODE
            LIMIT 1            
        ];
        
        configuration.EndPoint__c += '/kyc-cancel/99/'+ deticaId +'/'+ operation;
                
        integrationRecord.IE_Configuration__c = configuration.Id;
        integrationRecord.URLRequest__c = configuration.EndPoint__c;
        integrationRecord.RequestBody__c = configuration.EndPoint__c; // avoids null pointer exception
        
        //Set access token in headers
        headerAttributes.put('EXTERNAL-TOKEN', configuration.Silva_Access_Token__c);
        
        return integrationRecord;
    }
    
    /** 
    * @param iEInstance IE_Engine object
    * @return responseDto
    * @description work and return response
    */ 
    private static ResponseDto getResponseDto(IE_Engine iEInstance) {
        Integer statusCode = IEInstance.RawResponse.getStatusCode();
        String json = IEInstance.JSONResponse;
        FEQ_kyc_cancel_Response body = (FEQ_kyc_cancel_Response) System.JSON.deserialize(json, FEQ_kyc_cancel_Response.class);
        return new ResponseDto(statusCode, body);
    }
    
/** 
* @author	Reply
* @date	04/2023
* @description ResponseDto wrapper
*/
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        public Integer statusCode;
        public FEQ_kyc_cancel_Response body;
        
    /** 
    * @param statusCode status code
    * @param body response body
    * @description ResponseDto constructor
    */ 
        public ResponseDto(Integer statusCode, FEQ_kyc_cancel_Response body) {
            this.statusCode = statusCode;
            this.body = body;
        }
    }
    
/** 
* @author	Reply
* @date	04/2023
* @description FEQ_kyc_cancel_Response wrapper
*/
    public class FEQ_kyc_cancel_Response {
        public integer errorCode;
        public string errorMessage;
        public string deticaID;
    }
    
/** 
* @author	Reply
* @date	04/2023
* @description exception class
*/
    public class FeqException extends Exception{}
    
    
    
}