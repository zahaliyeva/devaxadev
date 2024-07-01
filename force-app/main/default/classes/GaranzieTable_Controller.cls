/** 
* @author	Deloitte
* @date	Unknown
* @description GaranzieView.Page controller on integration call out
*/
public with sharing class GaranzieTable_Controller {
     
    /**
     * @description errorMessage wrapper
     */
    public String errorMessage {get;set;}
    /**
     * @description errorcontroller wrapper
     */
    public boolean errorcontroller {get;set;}
    /**
     * @description coverages wrapper
     */
    public VistaGaranzie coverages {get;set;}
    /**
     * @description coverages_string wrapper
     */
    public string coverages_string {get;set;}
   
    /**
     * @description getCalloutResponseContents call out
     * @example public string JSON_INPUT = '{"coverages":[{"name": "RESPONSABILITÀ CIVILE TERZI","id": "COAS","shortDescriptionLines": ["string"],"categoryName": "VIA AURELIA 77 17029 VARIGOTTI (SV)","categoryId":"118134595.000000000000000","riderName": "prova","effectiveDate":"2016-01-15", "clauses": [ "test" ] ,"expirationDate":"2016-01-15", "beneficiaries": [{"BeneficiaryName": "Rossi Marco"},{"BeneficiaryName": "Rossi Maria"}],"restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","applicationCase": "PROVA","description": "500.000 € MASSIMALE PER SINISTRO RCT"},{"type": "MAXLIMIT","value": 260000,"unitCode": "€", "description": "100.000 € MASSIMALE PER SINISTRO RCT"}]},{"name": "INVALIDITÀ PERMANENTE DA MALATTIA","id": "COIPM", "categoryName": "TURA ROBERTO"  ,"categoryId": "118134595.000000000000000","restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","description": "260,000 € SOMMA ASSICURATA"}]},{"name": "GARANZIA GENERICA (CRITERI PER PRODOTTO)","id": "CONTTT","categoryName": "VIA AURELIA 77 17029 VARIGOTTI (SV)","categoryId": "118134595.000000000000000"}]}' ;
     */
    public string JSON_INPUT = HTTP_Rest_Request.getCalloutResponseContents();
    //
 
    /**
     * @description errorMessage wrapper
     * @example JSON_INPUT = '[{"name": "Verifica le condizioni di polizza"}]';
     * @example JSON_INPUT = '{"coverages":[{"name": "RESPONSABILITÀ CIVILE TERZI","id": "COAS","shortDescriptionLines": ["string"],"categoryName": "VIA AURELIA 77 17029 VARIGOTTI (SV)","categoryId":"118134595.000000000000000","riderName": "prova","effectiveDate":"2016-01-15", "clauses": [ "test" ] ,"expirationDate":"2016-01-15", "beneficiaries": [{"BeneficiaryName": "Rossi Marco"},{"BeneficiaryName": "Rossi Maria"}],
     * "restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","applicationCase": "PROVA","description": "500.000 € MASSIMALE PER SINISTRO RCT"},{"type": "MAXLIMIT","value": 260000,"unitCode": "€", "description": "100.000 € MASSIMALE PER SINISTRO RCT"}]},{"name": "INVALIDITÀ PERMANENTE DA MALATTIA","id": "COIPM", "categoryName": "TURA ROBERTO"  ,"categoryId": "118134595.000000000000000",
     * "restrictions": [{"type": "MAXLIMIT","value": 260000,"unitCode": "€","description": "260,000 € SOMMA ASSICURATA"}]},{"name": "GARANZIA GENERICA (CRITERI PER PRODOTTO)","id": "CONTTT","categoryName": "VIA AURELIA 77 17029 VARIGOTTI (SV)","categoryId": "118134595.000000000000000"}]}' ;
     * @param stdController standard controller
     */
    public GaranzieTable_Controller(ApexPages.StandardController stdController) {
  
        JSON_reader(JSON_INPUT); 
    }

    /**
     * @description errorMessage wrapper
     * @param JSON_INPUT json string 
     */
    public void JSON_reader(string JSON_INPUT){    
        JSONparser parser = JSON.createParser(JSON_INPUT );
        while (parser.nextToken() != null) {
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'developerMessage')) {
                 parser.nextToken();                  
                 errorcontroller = true;               
                 error(errorcontroller);  
            }
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Exception')) {
                 parser.nextToken();                  
                 errorcontroller = true;               
                 errormessage = 'Si è verificato un errore.' ;
            }
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'name')) {
                parser.nextToken();       
               if( parser.getText() == 'Verifica le condizioni di polizza'){ 
                     boolean errorcontroller = true;
                     error(errorcontroller); 
               } else {
                    Table();
               } 
            }  
        }
      }   
   
    /**
     * @description errorMessage wrapper
     * @param errorcontroller  if true e errorcode T300 is void response 
     */
    public void error(boolean errorcontroller){
        if ( errorcontroller == true) { 
            string jsonString = JSON_INPUT;
            GaranzieError jtaError;
            jtaError = GaranzieError.parse(jsonString);
            string errorText = jtaError.developerMessage;
            string errorCode = jtaError.code;
            
            if ( errorCode.equals('T300') && errorText.equals('The requested policy does not exist for this digital account') ){
                // Modificare questo messaggio errore T300
                errormessage = 'T300';
                
            } else {
                errormessage =  errorCode +': '+ errorText;
            }
        }  
    }
    
    /**
     * @description VistaGaranzie  supplied json has fields with names that are reserved words in apex
     */
    public void Table(){
        coverages = new VistaGaranzie(JSON_INPUT);
        coverages_string = JSON.serialize(coverages.jta.coverages);   
 
    } 
}