/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_Request_CIF_Nodes 

Description:   Class to compile a requesto to be sent to CIF to add 1 Node to a list of NDGs
            No need for attached template, XML streamer used to compile the request
            The info to compile the request are stored in the DevField__c of the Integration record
History
-13/06/2016   Davide Fabris - Created
----------------------------------------------------------------------------*/

public class IE_Request_CIF_NodesOnAccount implements IE_RequestCompiler {
    public string NameSpacePrefixToUse1 ='';
    public string NameSpacePrefixToUse2 ='';
    public string NameSpaceUriToUse1 ='';
    public string NameSpaceUriToUse2 ='';
    
    Public IE_Integration_Record__c IR;
    
    public string compileRequest(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs) {
        // initialise the attributes
        NameSpacePrefixToUse1 = CR.NameSpacePrefix1__c;
        NameSpacePrefixToUse2 = CR.NameSpacePrefix2__c;
        NameSpaceUriToUse1 = CR.NameSpaceUri1__c;
        NameSpaceUriToUse2 = CR.NameSpaceUri2__c;
        this.IR = IR; //passing the IR info to the class instance
        
        //initialise writer
        XmlStreamWriter w = new XmlStreamWriter();
        
        //ENVELOPE
        w.writeStartElement(NameSpacePrefixToUse1, 'Envelope',NameSpaceUriToUse1+'');
        w.writeNamespace(NameSpacePrefixToUse1, NameSpaceUriToUse1+'');
        w.writeNamespace(NameSpacePrefixToUse2, NameSpaceUriToUse2+'');
        
        //HEADER OPEN-CLOSE
        w.writeEmptyElement(CR.NameSpacePrefix1__c, 'Header', CR.NameSpaceUri1__c); 
        
        //BODY
        WriteBody(w);
        
        //ENVELOPE
        w.writeEndElement();
        
        string compiledrequest = w.getXmlString();
        
        return compiledRequest ;
    }
    
    public void WriteBody(XmlStreamWriter w) {
        system.debug('+++++w'+w);
        w.writeStartElement(NameSpacePrefixToUse1, 'Body', NameSpaceUriToUse1);
        w.writeStartElement(NameSpacePrefixToUse2, 'nodiToNdgCrm', NameSpaceUriToUse2);
        WriteOperazione(w);
        WriteNDG(w);
        WriteNodes(w);
        w.writeEndElement();
        w.writeEndElement(); 
    }
    
    public void WriteNDG(XmlStreamWriter w) {
        w.writeStartElement('', 'ndg', '');
        system.debug('+++++'+IR.DevField__c);
        List<string> theNDG=JSONUtility.getField(IR.DevField__c,'NDG');
        w.writeCharacters(''+theNDG[0]);
        w.writeEndElement();
    }
    
    public void WriteOperazione(XmlStreamWriter w) {
        w.writeStartElement('', 'tipoOperazione', '');
        system.debug('+++++'+IR.DevField__c);
        List<string> theOperation=JSONUtility.getField(IR.DevField__c,'tipoOperazione');
        w.writeCharacters(''+theOperation[0]);
        w.writeEndElement();
    }
    
    public void WriteNodes(XmlStreamWriter w) {
        w.writeStartElement('', 'ListaNodi', '');
        
        List<String> theNodes = JSONUtility.getFieldList(IR.DevField__c,'NODEs');

        system.debug('+++++ListaNodi'+theNodes);
        for (String thisNodo: theNodes) {
            w.writeStartElement('', 'nodo', '');
            w.writeCharacters(''+thisNodo);
            w.writeEndElement();
        }
        
        w.writeEndElement();
    }
}