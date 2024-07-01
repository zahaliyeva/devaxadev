/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_REOL_Parser
Description:   Class with the Parser methods used by the IntegrationEngine.
            The Parser takes the XML response convert it in a JSON object.
            The objects and field to be searched are specified in the Resposnse type placeholders.

History
-04/01/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/

public class IE_REOL_Parser implements IE_ResponseParser {


    public string ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
        String parsedResponse = 'ECHO from CIFparse'+RawResponse;
        
        //these should be retrieved from placeholders, or junctionObj. TO BE DONE
        Set<String> Objs = new Set<String>();
        Set<String> Fields = new Set<String>();


        Objs.add('elencoProposteAssociabiliSalesForce');//in case of positive response getList
        OBjs.add('input');//in case of positive response associaProposta

        //For getList
        Fields.add('numeroProposta');
        Fields.add('numeroProposta');
        Fields.add('dataEffetto');
        Fields.add('dataScadenza');
        Fields.add('dataFineValidita');
        Fields.add('productCode');
        Fields.add('productName');
        Fields.add('subAsaDesc');
        Fields.add('propostaStatusDesc');
        Fields.add('dataUltimaModifica');
        Fields.add('lastModifiedBy');        

        
        //For Associa
        Objs.add ('Fee');
        Objs.add ('Due');
        Objs.add ('TotalAnnualPremium');
        Objs.add ('Premium');
        
        
        Fields.add('message');
        Fields.add('result');
        Fields.add('AgencyCode');
        Fields.add('Branch');
        Fields.add('DataEffetto');
        Fields.add('DataFineValidita');
        Fields.add('DataScadenza');
        Fields.add('FrazionamentoCode');
        Fields.add('FrazionamentoDesc');
        Fields.add('Holder');
        Fields.add('IdOpp');
        Fields.add('IdProposta');
        Fields.add('LastModifiedBy');
        Fields.add('NDG');
        Fields.add('Node');
        Fields.add('PropostaNum');
        Fields.add('currencyCode');
        Fields.add('amount');
        Fields.add('ProductCode');
        Fields.add('ProductName');
        Fields.add('PropostaStatusCode');
        Fields.add('PropostaStatusDesc');
        Fields.add('SubAsaCode');
        Fields.add('descrizione');//typeOfObject
        //FM --- added for CRM DAOL 2.0 --- START
        Fields.add('BrandCode');//
        Fields.add('ModelCode');
        Fields.add('VersionCode');
        Fields.add('AsaCode');
        Fields.add('VatNumber');
        //FM --- added for CRM DAOL 2.0 --- END
        
        

        //in case of negative response i expect the following 3 info compiled (once only)
        Fields.add('errorType');
        Fields.add('errorDescription');
        Fields.add('errorValue');
        //Fields.add('codeResult');
        //Fields.add('descResult');
        
        
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
            

            loadChilds(xmlnodeobj, OBjs, Fields,JSgen);   
            

            
        }
        
        JSgen.writeEndObject(); //close root object
        parsedResponse = JSgen.getAsString();
        
        system.debug('++++++++++PARSED+++++++++++');
        system.debug(parsedResponse);
        system.debug('++++++++++PARSED+++++++++++');
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
                    if (tot>1 ) {// if i need to write more than one open array
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
            //system.debug('+++++checking if writing'+String.isNotBlank(child.getText()));
            //system.debug('++++++'+child.getText()+'*******');
            
            // if  (Fields.contains(child.getName()) && (String.isNotBlank(child.getText()))) {
            if  (Fields.contains(child.getName())) {
                if ((child.getname()=='result' && string.isNotBlank(child.getText())) || (child.getname()!='result')) {

                    if (current==0){
                        JSgen.writeFieldName(child.getName());
                        if(tot>1){
                            JSgen.writeStartArray();
                        }
                    }
                    
                    system.debug('+++++WRITING' +current+1+'of'+tot+' ELEMENTS');
                    // if(String.isNotBlank(child.getText())) JSgen.writeString(child.getText());
                    JSgen.writeString(child.getText());

                    system.debug('+++++WRITTEN' +current+1+'of'+tot+' ELEMENTS');
                    MapTag_to_counting.put(child.getName(),current+1);
                    current = MapTag_to_counting.get(child.getName());
                    
                    if(tot>1 && current==tot){
                        JSgen.writeEndArray();
                    }
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