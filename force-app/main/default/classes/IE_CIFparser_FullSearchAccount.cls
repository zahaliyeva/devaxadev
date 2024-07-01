public without sharing class IE_CIFparser_FullSearchAccount implements IE_ResponseParser{
    public string ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
       
    String parsedResponse = 'ECHO from CIFparse'+RawResponse;
    
    //these should be retrieved from placeholders, or junctionObj. TO BE DONE
    Set<String> Objs = new Set<String>();
    Set<String> Fields = new Set<String>();
    Set<String> Lists = new Set<String>();

    Lists.add ('aSoggetto');
    Lists.add ('lstDocumenti');
    Lists.add ('lstTelefoni');
    Lists.add ('lstIndirizzi');
    Lists.add ('lstContTelem');
    Lists.add ('lstVisibilita');
    Lists.add ('properties');

    Objs.add ('aSoggetto');
    Objs.add ('soggetto');
    Objs.add ('lstDocumenti');
    Objs.add ('lstTelefoni');
    Objs.add ('lstIndirizzi');
    Objs.add ('lstContTelem');
    Objs.add ('lstVisibilita');
    Objs.add ('soggettoFiscale');
    Objs.add ('soggettoEstensione');
    Objs.add ('properties');
    Objs.add ('objectId');
    
    Fields.add('msgRisposta');
    Fields.add('occorrenzeTrovate');
    Fields.add('codiceEsito');
    Fields.add('sistemaFonte'); 
    Fields.add('cointestazione');   
    Fields.add('codiceTitoloOnorifico');    
    Fields.add('tipoSoggetto'); 
    Fields.add('denominazione');    
    Fields.add('cognome');  
    Fields.add('nome'); 
    Fields.add('soggettoEstero');   
    Fields.add('codiceFiscale');    
    Fields.add('partitaIva');   
    Fields.add('codiceSottotipoSocieta');   
    Fields.add('codiceFormaGiuridica'); 
    Fields.add('societaQuotata');   
    Fields.add('localitaNascita');  
    Fields.add('provinciaNascita'); 
    Fields.add('sesso');    
    Fields.add('dataNascita');  
    Fields.add('collegatoPA');  
    Fields.add('tipoIndirizzo');    
    Fields.add('pressoIndirizzo');  
    Fields.add('paese');    
    Fields.add('locEsteraIndirizzo');   
    Fields.add('provincia');    
    Fields.add('localita'); 
    Fields.add('frazione'); 
    Fields.add('indirizzo');    
    Fields.add('omniaIndirizzo');   
    Fields.add('toponimoIndirizzo');    
    Fields.add('numCivicoIndirizzo');   
    Fields.add('cadCivicoIndirizzo');   
    Fields.add('cap');  
    Fields.add('codIstatIndirizzo');    
    Fields.add('codiceProfessione');    
    Fields.add('codiceScolarita');  
    Fields.add('codiceStatoCivile');    
    Fields.add('codiceHobby');  
    Fields.add('capoFamilia');  
    Fields.add('numeroFigli');  
    Fields.add('codiceTipoAbitazione'); 
    Fields.add('fasciaReddito');    
    Fields.add('codiceTipoAvviso'); 
    Fields.add('Ndg');  
    Fields.add('idSoggetto');   
    Fields.add('cittadinanza'); 
    Fields.add('cittadinanzaSeconda');  
    Fields.add('fasciaFatturato');  
    Fields.add('codiceSettoreAttivita');    
    Fields.add('numeroDipendenti'); 
    Fields.add('sedeLegale');   
    Fields.add('sedeLegaleDirittoEstero');  
    Fields.add('dataRilascioPatente');  
    Fields.add('codiceTipoPatente');    
    Fields.add('numVeicoliFamiglia');   
    Fields.add('numPatentiFamiglia');   
    Fields.add('giovaniPatentatiFamiglia'); 
    Fields.add('Pep');  
    Fields.add('tipologiaPEP'); 
    Fields.add('caricaPEP');    
    Fields.add('ramoAttivita'); 
    Fields.add('codiceAttivita');   
    Fields.add('codiceAteco');  
    Fields.add('cMifid');   
    Fields.add('tipoTelefono'); 
    Fields.add('prefissoTelefono'); 
    Fields.add('numeroTelefono');   
    Fields.add('noteTelefono'); 
    Fields.add('omniaTelefono');    
    Fields.add('tipoEmail');    
    Fields.add('testoEmail');   
    Fields.add('noteEmail');    
    Fields.add('omniaEmail');   
    Fields.add('codiceFormaPago');  
    Fields.add('iban'); 
    Fields.add('ibanPreferito');    
    Fields.add('omniaIban');    
    Fields.add('ibanSistemaFonte'); 
    Fields.add('tipoDocumento');    
    Fields.add('numeroDocumento');  
    Fields.add('dataInizioValidita');   
    Fields.add('dataFineValidita'); 
    Fields.add('autoritaRilascioDocumento');    
    Fields.add('localitaRilascioDocumento');    
    Fields.add('provinciaRilascioDocumento');   
    Fields.add('nazioneRilascioDocumento'); 
    Fields.add('omniaDocumento');   
    Fields.add('tipoDocumentoDue'); 
    Fields.add('numeroDocumentoDue');   
    Fields.add('dataInizioValiditaDue');    
    Fields.add('dataFineValiditaDue');  
    Fields.add('autoritaRilascioDocumentoDue'); 
    Fields.add('localitaRilascioDocumentoDue'); 
    Fields.add('provinciaRilascioDocumentoDue');    
    Fields.add('ramiCollegati');    
    Fields.add('codiceAgenzia');    
    Fields.add('agenziaLight'); 
    Fields.add('codiceSubAgenzia'); 
    Fields.add('presenzaAlert');    
    Fields.add('NdgLife');  
    Fields.add('tipoRelazione');    
    Fields.add('ndgLifeSoggettoRelazionado');   
    Fields.add('bSalvaPrivacy');    
    Fields.add('privacy1'); 
    Fields.add('privacy2'); 
    Fields.add('privacy3'); 
    Fields.add('privacy4'); 
    Fields.add('privacy5'); 
    Fields.add('privacyEmail'); 
    Fields.add('privacyFirma');
    Fields.add('privacyOTP'); 
    Fields.add('telefonoOTP');  
    Fields.add('userAggPrivacyComm');
    Fields.add('userAggPrivacyMail');
    Fields.add('userAggPrivacyFirma');
    Fields.add('userAggPrivacyOTP');
    Fields.add('aggPrivacy1');  
    Fields.add('aggPrivacy2');  
    Fields.add('aggPrivacy3');  
    Fields.add('aggPrivacy4');  
    Fields.add('aggPrivacy5');  
    Fields.add('aggPrivacyEmail');  
    Fields.add('aggPrivacyFirma');  
    Fields.add('aggPrivacyOTP');
    Fields.add('aggByEmailPrivacyEmail');   
    Fields.add('aggIndEmail');
    Fields.add('aggDocumentoPrivacyFirma');
    Fields.add('gestFin');
    Fields.add('firsDAC');
    Fields.add('daggPrivacy1');
    Fields.add('daggPrivacy2');
    Fields.add('daggPrivacy3');
    Fields.add('daggPrivacy4');
    Fields.add('daggPrivacyEmail');
    Fields.add('daggPrivacyFirma');
    Fields.add('daggPrivacyOTP');
    Fields.add('eTipoAggPrivacy1');
    Fields.add('eTipoAggPrivacy2');
    Fields.add('eTipoAggPrivacy3');
    Fields.add('eTipoAggPrivacy4');
    Fields.add('eTipoAggPrivacyMail');
    Fields.add('eTipoAggPrivacyFirma');
    Fields.add('eTipoAggPrivacyOtp');
    Fields.add('sorgenteEst');
    Fields.add('utenteEst');
    Fields.add('daggEst');
    Fields.add('timestampCif');
   
    Fields.add('tipoDoc');  
    Fields.add('siglaNazione'); 
    Fields.add('provincia');    
    Fields.add('localita'); 
    Fields.add('numeroDoc');    
    Fields.add('autoritaRilascio'); 
    Fields.add('dataRilascio'); 
    Fields.add('dataScadenza'); 
    Fields.add('idDocumento'); 
    
    Fields.add('numero');   
    Fields.add('prefissoInternazionale');   
    Fields.add('prefissoLocale');   
    Fields.add('tipoTelefono'); 
    Fields.add('note'); 
    Fields.add('idContatto');   
    Fields.add('timeStamp');
    Fields.add('propagaOmnia');   
    Fields.add('v_long'); 
    Fields.add('chiave');   
    Fields.add('valore');
    Fields.add('opposizione');   
    Fields.add('motivoOpposizione');       
    
    Fields.add('cap');  
    Fields.add('indirizzo');    
    Fields.add('localita'); 
    Fields.add('ndg');  
    Fields.add('paese');    
    Fields.add('provincia');    
    Fields.add('tipoIndirizzo');    
    
    Fields.add('tipoContatto'); 
    Fields.add('testo');    
    Fields.add('note'); 
    Fields.add('idContatto');
    Fields.add('propagaOmnia');   
    Fields.add('timeStamp');  
    Fields.add('opposizione');   
    Fields.add('motivoOpposizione');   
    
    Fields.add('subagenzia');
    
    Fields.add('cognomeSF');    
    Fields.add('nomeSF');   
    Fields.add('codicefiscaleSF');  
    Fields.add('localitaNascitaSF');    
    Fields.add('provNascitaSF');    
    Fields.add('sessoSF');  
    Fields.add('dataNascitaSF');
    
    
    DOM.Document myDOM = new DOM.Document();
    myDOM.load(RawResponse);
    DOM.XMLNode rootElement = myDOM.getRootElement();
    
    //instantiate the Json generator
    JSONGenerator JSgen = JSON.createGenerator(true);
    JSgen.writeStartObject(); //start root object

    
    for(DOM.XMLNode xmlnodeobj :myDOM.getRootElement().getChildElements() ) { //running through first level childs
        system.debug('+++++FIRST level------------XMLNODE getName()'+xmlnodeobj.getName());
        system.debug('+++++FIRST level------------XMLNODE getNodeType()'+xmlnodeobj.getNodeType());
        system.debug('+++++FIRST level------------XMLNODE getText()'+xmlnodeobj.getText());
        
        loadChilds(xmlnodeobj, OBjs, Fields, Lists, JSgen);   
        
    }
    
    JSgen.writeEndObject(); //close root object
    parsedResponse = JSgen.getAsString();

    return parsedResponse ;
    }
    
    //loading the child elements
    public static void loadChilds(DOM.XMLNode xmlnode, Set<String> Objs,Set<String> Fields,Set<String> Lists, JSONGenerator JSgen)  {
        // I must check if i get a list of things (same name element will end up in an array)
        List<Dom.XMLNode> ChildNodes = xmlnode.getChildElements();
        map<string,integer> MapTag_to_TOT = new Map<string, integer>();
        map<string,integer> MapTag_to_counting = new Map<string, integer>();

        
        //in this first loop i check how many items each array has
        for(Dom.XMLNode child : ChildNodes)  {
            system.debug('+++++ Counting NESTED level------------XMLNODE getName()'+child.getName());
            system.debug('+++++ Counting NESTED level------------XMLNODE getNodeType()'+child.getNodeType());
            system.debug('+++++ Counting NESTED level------------XMLNODE getText()'+child.getText());
            integer currentCount = MapTag_to_TOT.get(child.getName());
            if (currentCount>0) {
                MapTag_to_TOT.put(child.getName(),currentCount+1);
            } else {
                MapTag_to_TOT.put(child.getName(),1);
                MapTag_to_counting.put(child.getName(),0);
            }
        }
        system.debug('+++++++++++counted this many childs'+MapTag_to_TOT);
        
        //in this second loop i populate the JSON
        for(Dom.XMLNode child : ChildNodes)  {
            system.debug('+++++NESTED level------------XMLNODE getName()'+child.getName());
            system.debug('+++++NESTED level------------XMLNODE getNodeType()'+child.getNodeType());
            system.debug('+++++NESTED level------------XMLNODE getText()'+child.getText());
            
            //Sorting out the structure of the objects
            integer current = MapTag_to_counting.get(child.getName());
            integer tot = MapTag_to_TOT.get(child.getName());

            if (OBjs.contains(child.getName())) {
                system.debug('+++++opening obj'+child.getName());
                
                if (current==0){ //write the field name only the first time
                    JSgen.writeFieldName(child.getName());
                    if (tot>1 || (tot==1 && Lists.contains(child.getName()))) {// if i need to write more than one open array
                        system.debug('++++++opened array for '+MapTag_to_TOT.get(child.getName())+ '--'+child.getName());
                        JSgen.writeStartArray();
                    }
                }

                system.debug('+++++WRITING' +current+1+'of'+tot+' ELEMENTS');
                JSgen.writeStartObject(); 
                MapTag_to_counting.put(child.getName(),current+1);
                current = MapTag_to_counting.get(child.getName());
            } 
            
            //Now that the structure is sorted out I can populate the fields
            if  (Fields.contains(child.getName())) {
                if (current==0){
                    JSgen.writeFieldName(child.getName());
                    if(tot>1 || Lists.contains(child.getName())){
                        JSgen.writeStartArray();
                    }
                }
                
                system.debug('+++++WRITING' +current+1+'of'+tot+' ELEMENTS');
                JSgen.writeString(child.getText());
                system.debug('+++++WRITTEN' +current+1+'of'+tot+' ELEMENTS');
                MapTag_to_counting.put(child.getName(),current+1);
                current = MapTag_to_counting.get(child.getName());
                
                if((tot>1 && current==tot ) || (tot==1 && Lists.contains(child.getName()))){
                    JSgen.writeEndArray();
                }
            }
            
            loadChilds(child,Objs,Fields, Lists, JSgen);    
            
            if (OBjs.contains(child.getName())) {
                system.debug('+++++Closing obj'+child.getName());
                system.debug('+++++WRITTEN' +current+'of'+tot+' ELEMENTS');
                JSgen.writeEndObject(); 
                
                if ((tot>1 && current==tot) || (tot==1 && Lists.contains(child.getName()))) {//should close the array
                    system.debug('++++++CLOSED array for '+MapTag_to_TOT.get(child.getName())+ '--'+child.getName());
                    JSgen.writeEndArray();
                }
            }
        }
    }   
}