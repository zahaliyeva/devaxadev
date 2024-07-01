/**
 * @description PURE IT 22/05 - commentata la classe
 */
public without sharing class DecodeFiscalCode {
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

 	public static ResponseDto sendRequest(String fiscalCode,String lastName,String firstName){
        IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=PopulateIErecord (fiscalCode,lastName,firstName); 
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto res = new ResponseDto();
        
        try {
            myIE.compileRequest();
        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nel compilare la richiesta di decodifica del codice fiscale';
            system.debug('*********Eccezione e ='+e);
            res = new ResponseDto(false, errorsStr);
            return res;
        }

        try {
            myIE.sendRequest();
        } catch (exception e) {

            upsert myIR;
            String errorsStr = 'Si è verificato un errore nell\'inviare la richiesta di decodifica del codice fiscale';
            res = new ResponseDto(false, errorsStr);

            return res;     
        }
        
        try {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            res = manageResponse(myIE); 

        } catch (exception e) {
            String errorsStr = 'Si è verificato un errore nella ricezione della richiesta di decodifica del codice fiscale';
            res = new ResponseDto(false, errorsStr);

            return res;
        }
        
        return res;
    }


    public static IE_Integration_Record__c PopulateIErecord (String fiscalCode,String lastName,String firstName){
        IE_Integration_Record__c theResult = new IE_Integration_Record__c();
        List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='Integration_decodeFiscalCode' LIMIT 1];
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
        w.writeStartElement(NameSpacePrefixToUse2, 'RichiestaCodicePersonale', NameSpaceUriToUse2);


        myGen.writeStartObject();
        myGen.writeFieldName('Generale');
        w.writeStartElement(NameSpacePrefixToUse2, 'Generale', NameSpacePrefixToUse2);

        myGen.writeStartObject();

        
        myGen.writeStringField('CodConfed','1');
        w.writeStartElement(NameSpacePrefixToUse2, 'CodConfed', NameSpacePrefixToUse2);
        w.writeCharacters('1');
        w.writeEndElement();

        myGen.writeStringField('CodStato','380');
        w.writeStartElement(NameSpacePrefixToUse2, 'CodStato', NameSpacePrefixToUse2);
        w.writeCharacters('380');
        w.writeEndElement();
        
        myGen.writeStringField('Config','70005');
        w.writeStartElement(NameSpacePrefixToUse2, 'Config', NameSpacePrefixToUse2);
        w.writeCharacters('70005');
        w.writeEndElement();
        
        myGen.writeStringField('Lingua','ITA');
        w.writeStartElement(NameSpacePrefixToUse2, 'Lingua', NameSpacePrefixToUse2);
        w.writeCharacters('ITA');
        w.writeEndElement();

        
        myGen.writeEndObject();
        w.writeEndElement(); //end Generale
        
        myGen.writeStringField('TipoAzione','6');
        w.writeStartElement(NameSpacePrefixToUse2, 'TipoAzione', NameSpacePrefixToUse2);
        w.writeCharacters('6');
        w.writeEndElement();

        myGen.writeStringField('Cognome',''+lastName);
        w.writeStartElement(NameSpacePrefixToUse2, 'Cognome', NameSpacePrefixToUse2);
        w.writeCharacters(''+lastName);
        w.writeEndElement();

        myGen.writeStringField('Nome',''+firstName);
        w.writeStartElement(NameSpacePrefixToUse2, 'Nome', NameSpacePrefixToUse2);
        w.writeCharacters(''+firstName);
        w.writeEndElement();        

        myGen.writeStringField('CodiceFiscale',''+fiscalCode);
        w.writeStartElement(NameSpacePrefixToUse2, 'CodiceFiscale', NameSpacePrefixToUse2);
        w.writeCharacters(''+fiscalCode);
        w.writeEndElement();        
        
        string jsonString = myGen.getAsString();

        system.debug ('*****json string '+jsonString );
        theresult.DevField__c = jsonString;

        w.writeEndElement(); //end RichiestaCodicePersonale
        w.writeEndElement(); //end body       
        w.writeEndElement(); //end envelope
        
        string compiledrequest = w.getXmlString();
        system.debug ('compiledrequest'+compiledrequest);   
        theresult.RequestBody__c = compiledrequest;

        return theResult;

    }

    public static ResponseDto manageResponse (IE_Engine IEInstance)
    {
        ResponseDto results = new ResponseDto();
        DecodeFiscalCodeResponse formattedResponse = mapResponse (IEInstance.JSONResponse);    
        system.debug('formattedResponse:'+formattedResponse);
        
        if (formattedResponse == null)
        {
            //errore risposta vuota
            results.isSuccess = False;
            results.message = 'Errore risposta vuota';
            return results;
        }
        //successo chiamata
        else if (formattedResponse.esito.codice=='0')
        {
            system.debug ('******SUCCESS formattedResponse ='+formattedResponse);
            Map <String,String> resultsMap = getFiscalCodeInfos(formattedResponse);
            results.isSuccess = True;
            results.values.put ('FiscalCodeInfo',resultsMap);
            
            system.debug ('******FiscalCodeInfo'+results.values.get('FiscalCodeInfo'));
        }
        else if (formattedResponse.esito.codice=='8')
        {
            //errore codice fiscale non validato
            system.debug('******DATA ERROR');
            results.isSuccess = False;
            results.message = 'Errore di decodifica codice fiscale - '+formattedResponse.esito.descrizione;
            for (DecodeFiscalCodeResponse.Errori errorIstance :formattedResponse.errori)
            {
                results.message+=' - '+errorIstance.descrizione;
            }
        }
        else
        {
            //errore risposta non gestita

            system.debug('******FATAL ERROR');
            results.isSuccess = False;
            try
            {
                results.message = 'Errore di decodifica codice fiscale - '+formattedResponse.esito.descrizione;
            }
            catch (Exception e)
            {
                results.message = 'Errore di sistema nella decodifica del codice fiscale';
            } 

            return results;
        }

        return results;
    } 

    public static DecodeFiscalCodeResponse mapResponse (String JSONResponse) {
        DecodeFiscalCodeResponse emptyInstance = new DecodeFiscalCodeResponse();
        System.debug('***************pre deserialize() JSONResponse = ' + JSONResponse);
        Type typeInstance = Type.forName('DecodeFiscalCodeResponse');
        DecodeFiscalCodeResponse deserializeResults = (DecodeFiscalCodeResponse)JSON.deserialize(JSONResponse, typeInstance);
        System.debug('***************deserialize() results = ' + deserializeResults);
        return deserializeResults;
    }

     public static Map<String,String> getFiscalCodeInfos (DecodeFiscalCodeResponse theResponse )
    {
    	Map<String,String> resultMap = new Map<String,String>();
    	String provinceCode = theResponse.SigProvincia;
    	if (provinceCode!=null)
    	{
    		resultMap.put ('provinceCode',''+provinceCode);
    	}
    	String city = theResponse.DesLoc1;
    	if (city!=null)
    	{
    		resultMap.put ('city',''+city);
    	}
    	String gender = theResponse.Sesso;
    	String genderSF = '';
    	if (gender!=null)
    	{
    		if (gender == '1')
    		{
    			genderSF = 'Male';
    		}
    		else
    		{
    			genderSF = 'Female';
    		}
    		resultMap.put ('gender',''+genderSF);
    	}
    	String birthDateStr = theResponse.DataNascita;
    	if (birthDateStr!=null)
    	{
    		String yearStr = birthDateStr.substring(0, 4);
    		String monthStr = birthDateStr.substring(4, 6);
    		String dayStr = birthDateStr.substring(6, 8);
    		Integer year = Integer.valueOf(yearStr);
    		Integer month = Integer.valueOf(monthStr);
    		Integer day = Integer.valueOf(dayStr);
    		Date birthDate = date.newinstance(year, month, day);
    		String birthDateStrFixed = String.valueOf(birthDate); // the birth date is now in SF format
    		resultMap.put ('birthDate',''+birthDateStrFixed);

    	}
    	return resultMap;
    }
PURE IT */
}