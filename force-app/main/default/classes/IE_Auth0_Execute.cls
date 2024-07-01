/** 
* @author	Reply
* @date	04/2023
* @description Execution of Auth0 Integration
*/
public with sharing class IE_Auth0_Execute {
    
    /** 
    * @param req integration request
    * @return response wrapper
    * @description execute integration
    */
        public static IE_Auth0_ResponseWrapper executeAuth0(IE_Auth0_RequestWrapper req) {
            IE_Auth0_ResponseWrapper rw;
            Map<String, String> headerAttributes = new Map<string,string>();
            IE_Integration_Record__c integrationRecord;
            try{
                integrationRecord = getIntegrationRecord(headerAttributes, req);
                IE_Engine iEInstance = new IE_Engine(integrationRecord);
                iEInstance.compileRequest();
                iEInstance.sendRequest(headerAttributes);
                iEInstance.interpretResponse();
                rw = getResponse(iEInstance);
                SelfQAdVIntegrationUtility.finalize();
            } catch (Exception e){
                throw new Auth0Exception(e);
                }
            return rw;     
        }
        
    /** 
    * @param headerAttributes call attributes
    * @param req call request
    * @return integration record
    * @description return integration record with call's description
    */    
        private static IE_Integration_Record__c getIntegrationRecord(Map<String, String> headerAttributes, IE_Auth0_RequestWrapper req) {
            IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();
            String configurationName = 'Auth0';
            List<IE_Configuration__c> configurationList = [
                SELECT Id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c, ClientId__c, Client_Secret__c,
                NameSpaceUri2__c, Type__c, EndPoint__c, Certificate__c, Timeout__c,
                Name, Insert_IR_WS__c, HTTPMethod__c, Silva_Access_Token__c, Silva_Token_Expiration_DateTime__c
                FROM IE_Configuration__c
                WHERE Name = :configurationName
                WITH SYSTEM_MODE
            ];
            
            if(configurationList.size() > 0){
                
            IE_Configuration__c configuration = configurationList.get(0);
            
            String authorizationHeader = 'Bearer ' + SelfQAdVIntegrationUtility.getAuthToken();
            String body = JSON.serialize(req);
            
            integrationRecord.IE_Configuration__c = configuration.Id;
            integrationRecord.URLRequest__c = configuration.EndPoint__c;
            integrationRecord.RequestBody__c = body; 
            integrationRecord.DevField__c = body;
            
            headerAttributes.put('Content-Type', 'application/json');
            headerAttributes.put('Authorization', authorizationHeader);
            }
       
            return integrationRecord;
        }
        
    /** 
    * @param iEInstance IE_Engine object
    * @return Response wrapper
    * @description return integration response
    */       
        private static IE_Auth0_ResponseWrapper getResponse(IE_Engine iEInstance) {
            String json = iEInstance.JSONResponse;
            
            return (IE_Auth0_ResponseWrapper) System.JSON.deserialize(json, IE_Auth0_ResponseWrapper.class);
        }
        
        /** 
* @author	Reply
* @date	04/2023
* @description Exception class
*/
        public class Auth0Exception extends Exception{}
        
        
    }