/** 
 * @author	Reply
 * @date	01/03/2023
 * @description Class InvocableSendSMS chiamata su FLOW SensSMSOnChangeStatusCase.flow per fare integrazione con MC
 */
public with sharing class InvocableSendSMS {
    /** 
    * @param	caseToSend List Case in bulk per SensSMSOnChangeStatusCase.flow
    * @example	integrazione con MC, MTDs popolati in PRD con ids forniti da MC
    * @description prende un MTD e integra con MC
    */
    @InvocableMethod(label='Send SMS from flow')
    public static void sendSms(List<Case> caseToSend){
        Map<String,Id>  case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        String authToken = '';
        Contact conReciver = [ SELECT Id, AccountId FROM Contact where Name = 'Cliente Non Censito'];// NOPMD Contact Fake for SMS informativo 
        SMS_Message__mdt smsMessageMDT;
    try{     
        for(case c : caseToSend){
            // se non possiede account usiamo quello fake qui sopra
            if (c.ContactId == NULL){
                String phoneNumberComplete = c.SuppliedPhone.remove('+');
                system.debug(System.LoggingLevel.DEBUG, c.RecordTypeId);
                system.debug(System.LoggingLevel.DEBUG, AP_Constants.rtCaseMotor);
                if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseMotor) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseNonMotor) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseSinistro) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAMF) ) {
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('M_NM_SC_AMF');
                }else if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseSinistriAAI) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAAI)){
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('AAI_ASS');
                }else if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAssistenzaAgenti)){
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('ASS_AG');
                }else if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAgenziaDipendenti)){
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('AG_DIP');
                    
                }
                
                HttpResponse response = MKT_Utility.getAuthToken();
                if( response.getStatusCode() != 200 ){
                    System.debug(System.LoggingLevel.ERROR, 'CONNECTION ERROR:' + response.getBody());
                }
                Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                authToken = String.valueOf(respMap.get('access_token'));
                string jsonBody = MKT_Utility.getSendSMSWrapperNew(phoneNumberComplete, conReciver.Id,c.Id, conReciver.AccountId);
                
                
                response = MKT_Utility.sendSms(jsonBody,smsMessageMDT.ID_Template__c,authToken);
                System.debug(System.LoggingLevel.DEBUG, 'RESPONSE SEND: '+ response.getBody());
                System.debug(System.LoggingLevel.DEBUG, 'RESPONSE SEND: '+ response.getStatusCode());
                
                    
                
                
                //quando ha un padre associato
            }else{
                String phoneNumberComplete = c.SuppliedPhone.remove('+');
                if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseMotor) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseNonMotor) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseSinistro) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAMF) ) {
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('M_NM_SC_AMF');
                }else if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseSinistriAAI) || c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAAI)){
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('AAI_ASS');
                }else if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAssistenzaAgenti)){
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('ASS_AG');
                }else if(c.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAgenziaDipendenti)){
                    smsMessageMDT = SendSMSCmpController.getSMSMessageMDT('AG_DIP');
                    
                }
                
                HttpResponse response = MKT_Utility.getAuthToken();
                if( response.getStatusCode() != 200 ){
                    System.debug(System.LoggingLevel.ERROR,'CONNECTION ERROR:' + response.getBody());
                }
                Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                authToken = String.valueOf(respMap.get('access_token'));
                string jsonBody = MKT_Utility.getSendSMSWrapperNew(phoneNumberComplete, c.ContactId,c.Id, c.AccountId);
                
                
                response = MKT_Utility.sendSms(jsonBody,smsMessageMDT.ID_Template__c,authToken);
                System.debug(System.LoggingLevel.DEBUG,'RESPONSE SEND: '+ response.getBody());
                System.debug(System.LoggingLevel.DEBUG,'RESPONSE SEND: '+ response.getStatusCode());
                
                
                
            }
            
            
        }//end bulking inputs
        } catch (Exception errorEx) {
            ApplicationLogHelper.ERROR('InvocableSendSMS', errorEx.getMessage(), errorEx.getStackTraceString());
        }
    }
}