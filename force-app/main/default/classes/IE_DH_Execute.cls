/** 
* @author	Reply
* @date	04/2023
* @description Execution of DH Integration
*/
public with sharing class IE_DH_Execute {
    
    /** 
    * @param numeroPolizza numero della polizza
    * @param personId id della persona
    * @return response wrapper
    * @description execute integration
    */    
        public static IE_DH_ResponseWrapper executeDH(String numeroPolizza, String personId) {
            IE_DH_ResponseWrapper rw;
            Map<String, String> headerAttributes = new Map<string,string>();
            IE_Integration_Record__c integrationRecord;
            try{
                integrationRecord = getIntegrationRecord(headerAttributes, numeroPolizza, personId);
                IE_Engine iEInstance = new IE_Engine(integrationRecord);
                iEInstance.compileRequest();
                iEInstance.sendRequest(headerAttributes);
                iEInstance.interpretResponse();
                rw = getResponse(iEInstance);
            } catch (Exception e){
                throw new DHException(e.getMessage());
            }
            return rw;        
        }
        
    /** 
    * @param headerAttributes call attributes
    * @param numeroPolizza numero della polizza
    * @param personId id della persona
    * @return integration record
    * @description return integration record with call's description
    */       
        private static IE_Integration_Record__c getIntegrationRecord(Map<String, String> headerAttributes, String numeroPolizza, String personId) {
            IE_Integration_Record__c integrationRecord = new IE_Integration_Record__c();
            String configurationName = 'DHPolicy';
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
                
            configuration.EndPoint__c += '/' + numeroPolizza;
                    
            integrationRecord.IE_Configuration__c = configuration.Id;
            integrationRecord.URLRequest__c = configuration.EndPoint__c;
            integrationRecord.RequestBody__c = configuration.EndPoint__c; 
            
            headerAttributes.put('userId','dummy');
            headerAttributes.put('personId',personId);
            headerAttributes.put('Content-Type', 'application/json');
                
            }
                    
            return integrationRecord;
        }
        
    /** 
    * @param iEInstance IE_Engine object
    * @return Response wrapper
    * @description return integration response
    */  
        private static IE_DH_ResponseWrapper getResponse(IE_Engine iEInstance) {
            String json = iEInstance.JSONResponse;
            
            return (IE_DH_ResponseWrapper) System.JSON.deserialize(json, IE_DH_ResponseWrapper.class);
        }
     
/** 
* @author	Reply
* @date	04/2023
* @description Exception class
*/    
        public class DHException extends Exception{}
        
        
    }