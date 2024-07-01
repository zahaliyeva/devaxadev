public without sharing class AccountSearchCtrl  {   
    
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled
        public Boolean isSuccess { get; set; }
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public Map<Object, Object> values { get; set; }
        
        public ResponseDto (Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
        }   

        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<Object, Object>();
        }       
    }
    
    public class ResponseObj { // Object to better handle responses
        public String identif { get; set; }
        public String name { get; set; }
        public String PersonNome {get;set;}
        public String PersonCognome {get;set;}
        public String cfPiva {get;set;}
        public String NDG { get; set; }
        public Boolean isVisibleOnCRM { get; set; }
        public Boolean isEditableOnCRM { get; set; }
        public Boolean isInCIF { get; set; }

        public ResponseObj(){
            this.isVisibleOnCRM=false;
            this.isInCIF=false;
        }       
    }
    
    public  class RequestObj { // Object to better handle requests
        public string nome {get;set;}
        public string cognome {get;set;}
        public string cf {get;set;}
        public string ragsoc {get;set;}
        public string piva {get;set;}
        
        public string codAg {get;set;}
        
        public RequestObj(){} 
    }
    
   
    
    public static ResponseDto sendRequest (RequestObj req, Boolean isB2C){
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=CIF_Communication_Helper.PopulateIErecord_SearchAccount(req, isB2C);
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto resp = new ResponseDto();
        
        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare la richiesta di ricerca cliente in CIF';
            system.debug('*********Eccezione e ='+e);
            resp = new ResponseDto(false, errorsStr);

            return resp;

        }

        try {
            myIE.sendRequest();
        } catch (exception e) {

            upsert myIR;
            String errorsStr = 'Si è verificato un errore nell\'inviare la richiesta di ricerca cliente in CIF';
            resp = new ResponseDto(false, errorsStr);

            return resp;
            
        }
        
        try {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            
            resp = CIF_Communication_Helper.manageEditResponse_SearchAccount(myIE,req); 

        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore';
            resp = new ResponseDto(false, errorsStr);

            return resp;
        }
        
        return resp;
    }  

    @AuraEnabled
    public static ResponseDto sendRequest_fullsearch (String NDG){
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=CIF_Communication_Helper.PopulateIErecord_FullSearchAccount(NDG); 
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto resp = new ResponseDto();
        
        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare la richiesta di ricerca cliente in CIF';
            system.debug('*********Eccezione e ='+e);
            resp = new ResponseDto(false, errorsStr);

            return resp;

        }

        try {
            myIE.sendRequest();
        } catch (exception e) {

            upsert myIR;
            String errorsStr = 'Si è verificato un errore nell\'inviare la richiesta di ricerca cliente in CIF';
            resp = new ResponseDto(false, errorsStr);

            return resp;
            
        }
        
        try {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            
            resp = CIF_Communication_Helper.manageEditResponse_FullSearchAccount(myIE); 

        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore';
            resp = new ResponseDto(false, errorsStr);

            return resp;
        }
        
        return resp;
    }   
}