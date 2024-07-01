public without sharing class resetPasswordAccountCTRL {
    

    @AuraEnabled
    public static ResponseWrapper init(String personId){
        resetPasswordRequestWrapper req = new resetPasswordRequestWrapper(personId);

        return sendRequest(req);
    }

    @AuraEnabled
    public static ResponseWrapper confirm(String personId, String Email){
        resetPasswordRequestWrapper req = new resetPasswordRequestWrapper(personId, Email);
        ResponseWrapper resp = sendRequest(req);
        CreateCusEvent(personId, resp.isSuccess);
        return resp;
    }
    

    public class ResponseWrapper{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String ErrorMessage;
        @AuraEnabled public List<resetPasswordResponseWrapper.EmailWrapper> emailList;  

        public ResponseWrapper(String ErrorMessage){
            this.isSuccess = false;
            this.ErrorMessage = ErrorMessage;
        }

        public ResponseWrapper(List<resetPasswordResponseWrapper.EmailWrapper> emailList){
            this.emailList = emailList;
            this.isSuccess = true;
        }
        public ResponseWrapper(Boolean isSuccess){
            this.isSuccess = isSuccess;
        }
        public ResponseWrapper(){

        }
    }

    

    private static ResponseWrapper sendRequest(resetPasswordRequestWrapper req){
        ResponseWrapper res;
        Map<String, String> mapReq = new Map<String, String>();
        if(String.isNotBlank(req.personId)){
            mapReq.put('person-id', req.personId);
        }
        if(String.isNotBlank(req.Email)){
            mapReq.put('email', req.Email);
        }

        String req_Body = JSON.serialize(mapReq);
        List<IE_Configuration__c> confList = [SELECT id FROM IE_Configuration__c WHERE Name = 'ResetPassword' limit 1];
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        if(confList != null && !confList.isEmpty()){
            myIR.IE_Configuration__c = confList.get(0).Id;
        }
        else{
            String errorsStr = 'Attenzione: si è verificato un errore. Riprovare più tardi';
            
            return new ResponseWrapper(errorsStr);
        }
        myIR.RequestBody__c = myIR.DevField__c = req_Body;

        IE_Engine myIE = new IE_Engine(myIR);

        //Send Request process

        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Attenzione: si è verificato un errore. Riprovare più tardi';
            system.debug('*********Eccezione e ='+e);
            return new ResponseWrapper(errorsStr);

        }

        try {
            myIE.sendRequest(IE_DocumentValidation.getHeaders());
        } catch (exception e) {

            
            upsert myIR;
            String errorsStr = 'Attenzione: si è verificato un errore. Riprovare più tardi';
            
            return new ResponseWrapper(errorsStr);
            
        }
        
        try {
            myIE.interpretResponse();
            resetPasswordResponseWrapper resp = (resetPasswordResponseWrapper) JSON.deserialize( myIE.JSONResponse, resetPasswordResponseWrapper.class);
            return manageResponse(resp);
            //res = CIF_Communication_Helper.manageEditResponse(myIE,theNewAccount, editedDocuments, editedFieldsMap); // IRENE decommentare-->questo metodo modifica "theNewAccount","EditedDocuments" che tornano disponbile con i nuovi valori recepiti dal servizio
            

        } catch (exception e) {
            String errorsStr = 'Attenzione: si è verificato un errore. Riprovare più tardi';
            return new ResponseWrapper(errorsStr);

        }
        
      

        
    }

    private static ResponseWrapper manageResponse(resetPasswordResponseWrapper resp){
        if(String.isNotBlank(resp.status)){
            if('Unprocessable Entity'.equalsIgnoreCase(resp.status))
            {
                return new ResponseWrapper('Attenzione: si è verificato un errore. Riprovare più tardi');
            }
            if('500'.equalsIgnoreCase(resp.status))
            {
                if('INFRASTRUCTURE_ERROR_E009: UserId not found'.equalsIgnoreCase(resp.detail)){
                return new ResponseWrapper('Attenzione: il cliente non risulta registrato all’Area Clienti');
                }
                return new ResponseWrapper('Attenzione: si è verificato un errore. Riprovare più tardi');
            }
            return new ResponseWrapper('Attenzione: il cliente non risulta registrato all’Area Clienti');
        }
        if(String.isNotBlank(resp.errorCode)){
            return new ResponseWrapper('Attenzione: si è verificato un errore. Riprovare più tardi');
        }
        if(String.isNotBlank(resp.ExceptionMessage)){
            return new ResponseWrapper('Attenzione: si è verificato un errore. Riprovare più tardi');
        }
        if(resp.emailList != null && !resp.emailList.isEmpty()){
            return new ResponseWrapper(resp.emailList);
        }    
        return new ResponseWrapper(true);
    }

    private static void CreateCusEvent(String personId, boolean result){
        try{
            List<Account> accList = [select id from account where AAI_Codice_fiscale__c  = : personId or AAI_Partita_IVA__c = : personId or Fiscal_ID__c = : personId or Partita_IVA__c  = : personId];
            //ResponseWrapper resp = sendRequest(req);
            List <Customer_Event__c> customerEventList = new  List <Customer_Event__c> ();

            if(!accList.isEmpty()){

                for(Account tempAcc: accList){
                    Customer_Event__c cToIns = new Customer_Event__c(
                        RecordtypeId = Schema.SObjectType.Customer_Event__c.getRecordTypeInfosByDeveloperName().get('Customer_Registration').getRecordTypeId(),
                        Account__c = tempAcc.Id,
                        Result__c = result ? 'OK': 'KO',
                        Servizio__c = 'Reset Password'
                    );
                    customerEventList.add(cToIns);
                }

                insert customerEventList;
            }
            else{
                try{
                    ApplicationLogHelper.ERROR('ResetPasswordAccountCTRL', 'Account con CF ' + personId + ' non trovato', '');
                }
                catch(Exception ex){
                    System.debug(System.LoggingLevel.ERROR,'Exception: ' + ex.getmessage() + '\tStackTrace: '+ex.getStackTraceString());
                }
            }
        }
        catch(Exception e){
            try{
                ApplicationLogHelper.ERROR('resetPasswordAccountCTRL', e.getMessage(), e.getStackTraceString());
            }
            catch(Exception ex){
                System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
            }
        }
           
    }
        
    
}