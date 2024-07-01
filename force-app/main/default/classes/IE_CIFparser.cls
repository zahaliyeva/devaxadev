/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_CIFparser 
Description:   Class with the Parser methods used by the IntegrationEngine.
               The Parser takes the XML response convert it in a JSON object.
               The objects and field to be searched are specified in the Resposnse type placeholders.

History
 -04/01/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/

public class IE_CIFparser implements IE_ResponseParser {


    public string ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
        String parsedResponse = 'ECHO from CIFparse'+RawResponse;
        
        //these should be retrieved from placeholders, or junctionObj. TO BE DONE
        Set<String> Objs = new Set<String>();
        Set<String> Fields = new Set<String>();
        Set<String> Lists = new Set<String>();

        Lists.add('soggettoEsistente');
        Lists.add('codiceSubAgenzia');

        Objs.add('soggettoEsistente');
        Objs.add('soggettoFisico');
        Objs.add('soggettoGiuridico');
        Objs.add('datiDocumento');
        Objs.add('datiIndirizzo');

        Fields.add('totaleOccorrenze');
        Fields.add('tipoSoggetto');
        Fields.add('esitoElaborazione');
        Fields.add('cognome');
        Fields.add('nome');
        Fields.add('Ndg');
        Fields.add('soggettoEstero');
        Fields.add('codiceFiscale');
        Fields.add('sesso');
        Fields.add('localiaNascita');
        Fields.add('provinciaNascita');
        Fields.add('dataNascita');
        Fields.add('tipoDoc');
        Fields.add('numeroDoc');
        Fields.add('dataRilascio');
        Fields.add('dataScadenza');
        Fields.add('autoritaRilascio');
        Fields.add('siglaNazione');
        Fields.add('provincia');
        Fields.add('localita');
        Fields.add('indirizzo');
        Fields.add('codiceProfessione');
        Fields.add('codiceAgenzia');
        Fields.add('codiceSubAgenzia');
        Fields.add('messaggioErrore');
        Fields.add('timestampCif');
        Fields.add('denominazione');
        Fields.add('partitaIva');
        
        //FIRST ATTEMPT WITH XML READER///////////////////////////////
        /*
        //instantiate the XML reader
        XmlStreamReader reader = new XmlStreamReader(RawResponse);
        //instantiate the Json generator
        JSONGenerator JSgen = JSON.createGenerator(true);
        
        JSgen.writeStartObject();
        map<String,integer> MapListTag_to_ListCountTOT =  new map<String,integer> ();
        map<String,integer> MapListTag_to_ListCount =  new map<String,integer> ();

        for (string thisobj : OBjs) {
            if (thisobj=='soggettoEsistente') {
                MapListTag_to_ListCountTOT.put(thisobj,RawResponse.countMatches('<'+thisobj+'>'));
                system.debug('++++found'+MapListTag_to_ListCountTOT.get(thisobj)+thisobj);
                MapListTag_to_ListCount.put(thisobj,0);
            }
        }
        while(reader.hasNext()) {
            //system.debug('+++++readerhasnext??'+reader.hasNext());
            //system.debug('+++++reader localname'+reader.getLocalName());
            //system.debug('+++++reader event'+reader.getEventType());
            string thistag = reader.getLocalName();
            
            //here a tag containing other objects is starting
           if (Objs.contains(thistag) && reader.getEventType() == XmlTag.START_ELEMENT) {
               system.debug('++++starting obj'+thistag);
                if (MapListTag_to_ListCountTOT.containskey(thistag)){
                system.debug('+++current count for '+thistag+'IS  '+MapListTag_to_ListCount.get(thistag));
                    if (MapListTag_to_ListCount.get(thistag)>0) { //the list was already started, so just keep adding elements
                        integer currentCount = MapListTag_to_ListCount.get(thistag);
                        MapListTag_to_ListCount.put(thistag,currentCount+1); 
                        JSgen.writeStartObject();     
                        system.debug('++++starting'+currentCount+1+' obj'+thistag);
                    } else {//start list and write object
                        system.debug('++++starting FIRST'+thistag);
                        system.debug('+++current count for '+thistag+'IS  '+MapListTag_to_ListCount.get(thistag));
                        JSgen.writeFieldName(thistag);
                        JSgen.writeStartArray();
                        JSgen.writeStartObject(); 
                        MapListTag_to_ListCount.put(thistag,1); 
                    }
                } else { //object is not in a list, just write it
                    JSgen.writeFieldName(thistag);
                    JSgen.writeStartObject();        
                }
            }
            //here a tag containing other objects is ending
            if (Objs.contains(thistag) && reader.getEventType() == XmlTag.END_ELEMENT) {
               system.debug('++++ending obj'+thistag);
                if (MapListTag_to_ListCountTOT.containskey(thistag)){ //must check if i am at the end of the list
                    if (MapListTag_to_ListCountTOT.get(thistag)==MapListTag_to_ListCount.get(thistag)){ // I am at the end
                    JSgen.writeEndObject();
                    JSgen.writeEndArray();
                    } else { //not the end of the list, just close this item
                        JSgen.writeEndObject();
                    }
                } else {//was a normal object
                    JSgen.writeEndObject();
                }
            }
            
            //here I get the value of an attribute
           if (Fields.contains(thistag) && reader.getEventType() == XmlTag.START_ELEMENT) {
               system.debug('++++writing field'+thistag);
                JSgen.writeStringField(thistag,getValueFromTag(reader));
            }
            //system.debug('+++theJSONstring SO FAR'+JSgen.getAsString() );
            reader.next();
        }
        JSgen.writeEndObject();
        
        parsedResponse = JSgen.getAsString();
        */
        
        //second attempt with dom
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
            
            /*if (OBjs.contains(xmlnodeobj.getName())) {
                JSgen.writeFieldName(xmlnodeobj.getName());
                if (Lists.contains(xmlnodeobj.getName())) {
                        JSgen.writeStartArray();
                }
                system.debug('+++++opening obj'+xmlnodeobj.getName());
                JSgen.writeStartObject(); 

            }*/
            
           loadChilds(xmlnodeobj, OBjs, Fields,JSgen);   
           
            /*if (OBjs.contains(xmlnodeobj.getName())) {
                system.debug('+++++Closing obj'+xmlnodeobj.getName());
                JSgen.writeEndObject(); 
                if (Lists.contains(xmlnodeobj.getName())) {
                        JSgen.writeEndArray();
                }
            }*/
           
        }
        
        JSgen.writeEndObject(); //close root object
        parsedResponse = JSgen.getAsString();

        return parsedResponse ;
    }
    
    //loading the child elements
    private void loadChilds(DOM.XMLNode xmlnode, Set<String> Objs,Set<String> Fields, JSONGenerator JSgen)  {
        // I must check if i get a list of things (same name element will end up in an array)
        List<Dom.XMLNode> ChildNodes = xmlnode.getChildElements();
        map<string,integer> MapTag_to_TOT = new Map<string, integer>();
        map<string,integer> MapTag_to_counting = new Map<string, integer>();

        
        //in this first loop i check how many items each array has
        for(Dom.XMLNode child : ChildNodes)  {
            integer currentCount = MapTag_to_TOT.get(child.getName());
            if (currentCount>0) {
                MapTag_to_TOT.put(child.getName(),currentCount+1);
            } else {
                MapTag_to_TOT.put(child.getName(),1);
                MapTag_to_counting.put(child.getName(),0);
            }
        }
        //system.debug('+++++++++++counted this many childs'+MapTag_to_TOT);
        
        //in this second loop i populate the JSON
        for(Dom.XMLNode child : ChildNodes)  {
            system.debug('+++++NESTED level------------XMLNODE getName()'+child.getName());
            system.debug('+++++NESTED level------------XMLNODE getNodeType()'+child.getNodeType());
            system.debug('+++++NESTED level------------XMLNODE getText()'+child.getText());
            
            //Sorting out the structure of the objects
            integer current = MapTag_to_counting.get(child.getName());
            integer tot = MapTag_to_TOT.get(child.getName());

            if (OBjs.contains(child.getName())) {
                //system.debug('+++++opening obj'+child.getName());
                
                if (current==0){ //write the field name only the first time
                    JSgen.writeFieldName(child.getName());
                    if (tot>1 ) {// if i need to write more than one open array
                            //system.debug('++++++opened array for '+MapTag_to_TOT.get(child.getName())+ '--'+child.getName());
                            JSgen.writeStartArray();
                    }
                }

                //system.debug('+++++WRITING' +current+1+'of'+tot+' ELEMENTS');
                JSgen.writeStartObject(); 
                MapTag_to_counting.put(child.getName(),current+1);
                current = MapTag_to_counting.get(child.getName());
            } 
            
            //Now that the structure is sorted out I can populate the fields
            if  (Fields.contains(child.getName())) {
                if (current==0){
                    JSgen.writeFieldName(child.getName());
                    if(tot>1){
                        JSgen.writeStartArray();
                    }
                }
                
                //system.debug('+++++WRITING' +current+1+'of'+tot+' ELEMENTS');
                JSgen.writeString(child.getText());
                //system.debug('+++++WRITTEN' +current+1+'of'+tot+' ELEMENTS');
                MapTag_to_counting.put(child.getName(),current+1);
                current = MapTag_to_counting.get(child.getName());
                
                if(tot>1 && current==tot){
                    JSgen.writeEndArray();
                }
            }
            
            
            
            
            
            loadChilds(child,Objs,Fields,JSgen);    
            
            if (OBjs.contains(child.getName())) {
                system.debug('+++++Closing obj'+child.getName());
                system.debug('+++++WRITTEN' +current+'of'+tot+' ELEMENTS');
                JSgen.writeEndObject(); 
                
                if (tot>1 && current==tot) {//should close the array
                        system.debug('++++++CLOSED array for '+MapTag_to_TOT.get(child.getName())+ '--'+child.getName());
                        JSgen.writeEndArray();
                }
            }
        }
    }
    // This is an extra function to read data between opening and closing tag. 
    // It will return the string of value from between tags
    public string getValueFromTag(XMLStreamReader reader) {
        String DataValue='';
    
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                DataValue = reader.getText();
            }
            reader.next();
        }
    
        return DataValue;
    }
    
    
  
}