/** 
* @author	Deloitte
* @date	Unknown
* @description GaranzieView.Page controller on integration call out
* @example public string policyId =  HTTP_Request_Methods.getInsurancePolicy().PolicyID__c ;
* @example public string path = '/policies/'+policyId+'/coverages';
* @example public string url = 'https://esg-pp.axa-medla.com/myaxa-medla-proxy-v1/it/int/it-myaxa-policies-vs'+path;
*/
public with sharing class  HTTP_Rest_Request {
   
    /**
     * @description Pass in the endpoint to be used using the string url
     * @return InputJson json con la informazione della integrazione 
     */
    @SuppressWarnings('PMD.ApexCRUDViolation') // WITH SYSTEM_MODE accepted for IE config
    public static string getCalloutResponseContents(){
        try  {   
            string RecordType_Check = HTTP_Request_Methods.getInsurancePolicy().CUID__r.RecordType.DeveloperName;
            string personID;  
    
            if(RecordType_Check =='B2B_Client'){
             personID = HTTP_Request_Methods.getInsurancePolicy().CUID__r.AAI_Partita_IVA__c;
            }
            if(RecordType_Check =='B2C_Client'){
             personID = HTTP_Request_Methods.getInsurancePolicy().CUID__r.AAI_Codice_fiscale__c;
            }
             if(RecordType_Check =='Client'){
             personID = HTTP_Request_Methods.getInsurancePolicy().CUID__r.Fiscal_ID__c;
            }
            if(RecordType_Check =='Business_Account'){
             personID = HTTP_Request_Methods.getInsurancePolicy().CUID__r.Partita_IVA__c;
            }
            
            // DANTONIO_M 30/11/2018 --> integration engine implementation -- START
            IE_Configuration__c Myconfig = [SELECT EndPoint__c, Certificate__c FROM IE_Configuration__c 
                WHERE Name ='Integrazione_Garanzie' WITH SYSTEM_MODE limit 1 ]  ;
                  // DANTONIO_M 30/11/2018 --> integration engine implementation -- end
            string policyId =  HTTP_Request_Methods.getInsurancePolicy().PolicyID__c ;


            // DANTONIO_M 30/11/2018 --> integration engine implementation -- START
            System.debug(LoggingLevel.DEBUG,'===> policyId: ' + policyId);
            System.debug(LoggingLevel.DEBUG,'===> personID: ' + personID);
            System.debug(LoggingLevel.DEBUG,'===> myconfig: ' + myconfig);

            //*-+ 16.05.2023 #3418 bugFix Vista Garanzie: prima d inviare una rq vuota controllo campi policy id e person id (obligg)
            if(policyId == null || personID == null){
                string JSON_INPUT = '{"code": "System.NonDataCRM",' + 
                '"developerMessage": "Impossibile trovare il CF/PIVA o la polizza ID nel CRM",' +
                '"userMessage": "test"}';
                return JSON_INPUT;
            }
            IE_Integration_Record__c ieRecord = populateIErecord_getGaranzie(personID, policyId, myconfig);

            IE_Engine myIE = new IE_Engine(ieRecord);

            try {
                System.debug(LoggingLevel.DEBUG,'===> compiling request');
                myIE.compileRequest();
            } catch (exception e) {
                System.debug(LoggingLevel.DEBUG,'===> Si è verificato un errore nel compilare la richiesta. Eccezione e ='+e);
            }

            try {
                System.debug(LoggingLevel.DEBUG,'===> sending request');
                Map<String, String> headers = new Map<String, String>();
                headers.put('Connection','Keep-Alive');
                headers.put('userId','usermyaxa2@axa.it');
                headers.put('personId', personID);
                //headers.put('Accept','*/*');
                headers.put('Content-type','application/json');
                headers.put('User-Agent','Apache-HttpClient/4.1.1 (java 1.5)');
                //headers.put('Host','esg.axa-medla.com');

                myIE.sendRequest(headers);
            } catch (exception e) {

                System.debug(LoggingLevel.DEBUG,'===> Si è verificato un errore nell\'inviare la richiesta. Eccezione e ='+e);
                //upsert ieRecord;
            }
            
            try {
                System.debug(LoggingLevel.DEBUG,'===> interprenting response');
                myIE.interpretResponse();
                System.debug(LoggingLevel.DEBUG,'===> json response: '+myIE.JSONResponse);
                System.debug(LoggingLevel.DEBUG,'===> response status code: '+myIE.RawResponse.getStatusCode());
                String check_InputJson = myIe.RawResponse.getBody();
                String InputJson;
                if(myIe.RawResponse.getStatusCode() == 200){
                  InputJson = '{"coverages":' + check_InputJson  + '}' ;  
                }
                else{
                  System.debug(LoggingLevel.DEBUG,'===> RawResponse: '+myIE.RawResponse);
                  InputJson = myIE.RawResponse.getBody();
                }
                
                return InputJson;
            } catch (exception e) {
                System.debug(LoggingLevel.DEBUG,'===> Si è verificato un errore nella ricezione della risposta. Eccezione e ='+e);
            }

            string InputJson = myIe.RawResponse.getBody();
            return InputJson;

        }  
    
        catch(exception e){

          System.debug(LoggingLevel.DEBUG,'===> eccezione: ' + e);
            
           string JSON_INPUT = '{"code": "System.CalloutException",' + 
                                '"developerMessage": "Impossibile accedere al servizio.",' +
                                '"userMessage": "test"}';
           return JSON_INPUT;
        }
    
    }

    /**
     * @description     get Ie configuration record
     * @param personId  
     * @param policyId  
     * @param theConfig 
     * @return          `IE_Integration_Record__c`
     */
    public static IE_Integration_Record__c populateIErecord_getGaranzie(String personId, String  policyId, 
                                                                        IE_Configuration__c theConfig) {
        IE_Integration_Record__c theResult = new IE_Integration_Record__c();
        theResult.IE_Configuration__c = theConfig.id;
        

        String url = theConfig.EndPoint__c + '/policies/' + policyId + '/coverages'; 

        System.debug(LoggingLevel.DEBUG,'===> REQUEST URL'+url);

        
        String compiledrequest = url;
        system.debug ('===> urltosendrequest'+url);
        theResult.RequestBody__c = compiledrequest;
        theResult.URLRequest__c = compiledrequest;
        //theResult.ScopeID__c = personId;

        return theResult;
    }
    // DANTONIO_M 30/11/2018 --> integration engine implementation -- END
}