/** 
* @author	Fincons
* @date	04/2024
* @description Execution of SetConsensoProfilazione Integration
*/
public with sharing class IE_ConsProfil_Execute {
    
    /** 
    * @param req integration request
    * @return response wrapper
    * @description execute integration
    */

    @InvocableMethod 
    public static void eseguiRegistrazioneConsenso(List<Communications_to_customer__c> comunicazioni){
        Communications_to_customer__c comunicazione = comunicazioni[0];
        String ndg = comunicazione.ndg__c;
        String user = comunicazione.Email__c;
        String privacyStatus = comunicazione.Consenso_Profilazione__c;
        Datetime lastModifiedDate = comunicazione.Last_Modified_Date_Consenso_Profilazione__c;
        IE_ConsensoProfilazione_Execute(ndg, user, privacyStatus, lastModifiedDate);
    }
        @future (callout=true)
        public static void IE_ConsensoProfilazione_Execute(String ndg, String user, String privacyStatus, Datetime lastModifiedDate ) {
            IE_ConsProfil_ResponseWrapper rw;
            Map<String, String> headerAttributes = new Map<string,string>();
            IE_Integration_Record__c integrationRecord;
            try{
                integrationRecord = getIntegrationRecord(headerAttributes, ndg, user, privacyStatus, lastModifiedDate);
                IE_Engine iEInstance = new IE_Engine(integrationRecord);
                iEInstance.compileRequest();
                iEInstance.sendRequest(headerAttributes);
                iEInstance.interpretResponse();
                rw = getResponse(iEInstance);
                } catch (Exception e){
                throw new ConsProfilException(e.getMessage());
                }
        }
        
    /** 
    * @param headerAttributes call attributes
    * @param req call request
    * @return integration record
    * @description return integration record with call's description
    */    
        private static IE_Integration_Record__c getIntegrationRecord(Map<String, String> headerAttributes, String ndg, String user, String privacyStatus, Datetime lastModifiedDate) {
            IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();
            String configurationName = 'SetConsensoProfilazione';
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
            
            //String authorizationHeader = 'Bearer ' + SelfQAdVIntegrationUtility.getAuthToken();
            String body = IE_ConsProfil_RequestCompiler.buildRequestBody(user, privacyStatus, lastModifiedDate);

            configuration.EndPoint__c =  configuration.EndPoint__c.replace('{ndg}',ndg);
            integrationRecord.IE_Configuration__c = configuration.Id;
            integrationRecord.URLRequest__c = configuration.EndPoint__c;
            integrationRecord.RequestBody__c = body; 
            integrationRecord.DevField__c = body;
            
            headerAttributes.put('Content-Type', 'application/json');
            headerAttributes.put('ndg', ndg);
            //headerAttributes.put('Authorization', authorizationHeader);

            }
       
            return integrationRecord;
        }
        
    /** 
    * @param iEInstance IE_Engine object
    * @return Response wrapper
    * @description return integration response
    */       
        private static IE_ConsProfil_ResponseWrapper getResponse(IE_Engine iEInstance) {
            String json = iEInstance.JSONResponse;
            
            return (IE_ConsProfil_ResponseWrapper) System.JSON.deserialize(json, IE_ConsProfil_ResponseWrapper.class);
        }
        
        /** 
* @author	Fincons
* @date	05/2023
* @description Exception class
*/
        public class ConsProfilException extends Exception{}
        
        
    }