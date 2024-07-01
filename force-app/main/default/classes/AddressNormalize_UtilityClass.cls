/**
 * @description PURE IT 23/05 - commentata la classe
 */
public class AddressNormalize_UtilityClass {

/** PURE IT
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        public Boolean isSuccess { get; set; }
        public String message { get; set; }
        public Map<Object, Object> values { get; set; }
        public ResponseDto(Boolean isSuccess, String msg){
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


    // metodo che restituisce la lista degli Stati integrandosi con lo stradario di Axa
    
    public static ResponseDto getStatiList(){
        ResponseDto requestOutcome = new ResponseDto(true, '');
        
        try{
            requestOutcome = sendRequest_stati ();
        }
        catch(Exception e){
            requestOutcome.isSuccess=false;
            requestOutcome.message='Si è verificato un errore nell\'invio della richiesta - contattare il proprio amministratore: '+e.getmessage();
        }
        
        
        return requestOutcome;
    }

    // metodo che restituisce la lista delle province integrandosi con lo stradario di Axa
    
    public static ResponseDto getProvinceList(){
        ResponseDto requestOutcome = new ResponseDto(true, '');
        
        try{
            requestOutcome = sendRequest_province ();
        }
        catch(Exception e){
            requestOutcome.isSuccess=false;
            requestOutcome.message='Si è verificato un errore nell\'invio della richiesta - contattare il proprio amministratore: '+e.getmessage();
        }
        
        
        return requestOutcome;
    }
    
    // metodo che restituisce la lista dei comuni data la provincia integrandosi con lo stradario di Axa
    
    public static ResponseDto getComuniList (String currentProvince){
        ResponseDto requestOutcome = new ResponseDto(true, '');
        
        try{
            requestOutcome = sendRequest_comuni (currentProvince);
        }
        catch(Exception e){
            requestOutcome.isSuccess=false;
            requestOutcome.message='Si è verificato un errore nell\'invio della richiesta - contattare il proprio amministratore: '+e.getmessage();
        }
        
        
        return requestOutcome;
    }
 
    public static ResponseDto sendRequest_stati(){
    
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=CIF_Communication_Helper.PopulateIErecord_stati(); 
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto res = new ResponseDto();
        
        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco degli Stati: '+e.getmessage();
            system.debug('*********Eccezione e ='+e);
            res = new ResponseDto(false, errorsStr);
            return res;
        }

        try {
            myIE.sendRequest();
        } catch (exception e) {

            upsert myIR;
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco degli Stati: '+e.getmessage();
            res = new ResponseDto(false, errorsStr);

            return res;     
        }
        
        try {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            res = CIF_Communication_Helper.manageEditResponse_stati(myIE); 

        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco degli Stati: '+e.getmessage();
            res = new ResponseDto(false, errorsStr);

            return res;
        }
        
        return res;
    }

    public static ResponseDto sendRequest_province(){
    
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=CIF_Communication_Helper.PopulateIErecord_province(); 
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto res = new ResponseDto();
        
        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco delle province: '+e.getmessage();
            system.debug('*********Eccezione e ='+e);
            res = new ResponseDto(false, errorsStr);
            return res;
        }

        try {
            myIE.sendRequest();
        } catch (exception e) {

            upsert myIR;
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco delle province: '+e.getmessage();
            res = new ResponseDto(false, errorsStr);

            return res;     
        }
        
        try {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            res = CIF_Communication_Helper.manageEditResponse_province(myIE); 

        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco delle province: '+e.getmessage();
            res = new ResponseDto(false, errorsStr);

            return res;
        }
        
        return res;
    }
    
    public static ResponseDto sendRequest_comuni(String currentProvince){
    
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=CIF_Communication_Helper.PopulateIErecord_comuni(currentProvince); 
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto res = new ResponseDto();
        
        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco delle province: '+e.getmessage();
            system.debug('*********Eccezione e ='+e);
            res = new ResponseDto(false, errorsStr);
            return res;
        }

        try {
            myIE.sendRequest();
        } catch (exception e) {

            upsert myIR;
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco delle province: '+e.getmessage();
            res = new ResponseDto(false, errorsStr);

            return res;     
        }
        
        try {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            res = CIF_Communication_Helper.manageEditResponse_Comuni(myIE); 

        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare l\'elenco delle province: '+e.getmessage();
            res = new ResponseDto(false, errorsStr);

            return res;
        }
        
        return res;
    }

PURE IT */
}