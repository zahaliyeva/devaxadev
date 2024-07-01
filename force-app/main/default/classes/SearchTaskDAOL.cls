public without sharing class SearchTaskDAOL {

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
            this.isSuccess = false;
            this.message = '';
            this.values = new Map<Object, Object>();
        }       
    }
    

 
      public static ResponseDto getTaskResponse(String accountKey){
        ResponseDto requestOutcome = new ResponseDto(true, '');
        //Adding logic to accept both NDG OR ID
        system.debug('+++input accountKey'+accountKey);
        List<Account> scopeAcc = [SELECT Id, NDG__c FROM account where Id=:accountKey OR NDG__c=:accountKey];
        system.debug('++++ found these acc'+scopeAcc );
        if (scopeAcc.isEmpty() || scopeAcc.size()>1) {
            requestOutcome.isSuccess=false;
            requestOutcome.message='Impossibile trovare l\'account di riferimento con codice:'+accountKey;
        } else {

            try{
              requestOutcome = sendRequest(scopeAcc[0].NDG__c);
            } catch(Exception e){
              requestOutcome.isSuccess=false;
              requestOutcome.message='Si è verificato un errore nell\'invio della richiesta - contattare il proprio amministratore: '+e.getmessage();
            }
        }
        return requestOutcome;
    }
    

    public static ResponseDto sendRequest(String NDGCode){
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=PopulateIErecord (NDGCode); 
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto res = new ResponseDto();
        
        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare la richiesta di controllo TASK verso DAOL';
            system.debug('*********Eccezione e ='+e);
            res = new ResponseDto(false, errorsStr);
            return res;
        }

        try {
            myIE.sendRequest();
        } catch (exception e) {

            upsert myIR;
            String errorsStr = 'Si è verificato un errore nell\'inviare la richiesta di controllo TASK verso DAOL';
            res = new ResponseDto(false, errorsStr);

            return res;     
        }
        
        try {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            res = manageResponse(myIE); 

        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nella ricezione della risposta di controllo TASK verso DAOL';
            res = new ResponseDto(false, errorsStr);

            return res;
        }
        
        return res;
    }


    public static IE_Integration_Record__c PopulateIErecord (String NDGCode){
        IE_Integration_Record__c theResult = new IE_Integration_Record__c();
        List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='Integration_TaskSearch' LIMIT 1];
        if (!theConfig.isempty()) {
            theresult.IE_Configuration__c = theConfig[0].id;
        }        
        //Compiling the DevField with the JSON 
        JSONGenerator myGen= JSON.createGenerator(true);
        
        String NameSpacePrefixToUse1 = theConfig[0].NameSpacePrefix1__c;
        String NameSpacePrefixToUse2 = theConfig[0].NameSpacePrefix2__c;
        String NameSpaceUriToUse1 = theConfig[0].NameSpaceUri1__c;
        String NameSpaceUriToUse2 = theConfig[0].NameSpaceUri2__c;
        
        //initialise writer
        XmlStreamWriter w = new XmlStreamWriter();
        
        //ENVELOPE
        w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
        w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
        w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
        
        //HEADER OPEN-CLOSE
        w.writeEmptyElement(NameSpacePrefixToUse1, 'Header', NameSpacePrefixToUse1); 
        
        ///BODY
        w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
        w.writeStartElement(NameSpacePrefixToUse2, 'isFascicoliAnagApertiOrNonConsegnati', NameSpaceUriToUse2);
        w.writeStartElement(NameSpacePrefixToUse2, 'input', NameSpaceUriToUse2);


        myGen.writeStartObject();
        myGen.writeStringField('codeNDG',''+NDGCode);
        w.writeStartElement(NameSpacePrefixToUse2, 'codeNDG', NameSpacePrefixToUse2);
        w.writeCharacters(''+NDGCode);
        w.writeEndElement(); 
        
        string jsonString = myGen.getAsString();

        system.debug ('*****json string '+jsonString );
        theresult.DevField__c = jsonString;

        w.writeEndElement(); //end RichiestaCodiceNDG
        w.writeEndElement(); //end input
        w.writeEndElement(); //end body       
        w.writeEndElement(); //end envelope
        
        string compiledrequest = w.getXmlString();
        system.debug ('compiledrequest'+compiledrequest);   
        theresult.RequestBody__c = compiledrequest;

        return theResult;

    }
    
    public static ResponseDto manageResponse(IE_Engine myIE) {
        system.debug('myIE.JsonResponse-->'+myIE.JSONResponse);
        Map<String, Object> MapStringObj = (Map<String, Object>)JSON.deserializeUntyped(myIE.JSONResponse);
        system.debug('MapStringObj'+MapStringObj);
        system.debug('MapStringObj.get(check)'+MapStringObj.get('check'));
        ResponseDto theResp = new ResponseDto();

        if (MapStringObj.get('check')!=null) {//there is a true/false Answer
            theResp.isSuccess=true;
            system.debug('in the map goes-->'+Boolean.ValueOf(MapStringObj.get('check')));
            theResp.values.put('check',Boolean.ValueOf(MapStringObj.get('check')));   
        } else {
            //there is an error response
            theResp.isSuccess=false;
            theResp.Message = 'SOMETHING IS WRONG';
        }
        
        return theResp;
        
        
    }

}