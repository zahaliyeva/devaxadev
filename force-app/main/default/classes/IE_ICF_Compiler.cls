/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_ICF_Compiler 
Description:   Class with the Static Compiler methods used by the IntegrationEngine.

History
-30/12/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class IE_ICF_Compiler {}
    /** PURE IT
public class IE_ICF_Compiler implements IE_RequestCompiler {

    Public IE_Integration_Record__c IR;
    public List<IE_CR2PH_junction__c> JRs;


 public string compileRequest(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs) 
    {
        //VARIABLES RELATED TO ALL IE_REQUEST
        this.JRs=JRs;
        this.IR=IR;
        //VARIABLES RELATED TO ALL IE_REQUEST
        
        String compiledrequest = 'IE_ICF_Compiler';


    
        
        //initialise writer
        XmlStreamWriter w = new XmlStreamWriter();

        //w.writeStartDocument('UTF-8', '1.0'); removed D.F 20161229
        //envelope and body
        w.writeStartElement('', 'Envelope','');
        w.writeStartElement('', 'Body','');

        
        //Root
        w.writeStartElement('', 'Root','');
      
            //Surveys
            w.writeStartElement('', 'Surveys', ''); 
            
            
                   List<String> scopeIds = new List <String>();
                   
                   scopeIds.addAll(IR.ScopeID__c.split(';'));

                  
                   List<Interazione__c> myRecords = [SELECT Id, Account__r.NDG__c, Account__r.CIF_PersonEmail__c, Account__r.CIF_PersonMobilePhone__c, Account__r.Gender__c, Account__r.Age__c,Account__r.FirstName, Account__r.LastName, Account__r.Promotional_privacy__c, Account__r.Market_research_privacy__c,Account__r.AAI_Codice_fiscale__c, Account__r.AAI_Agency_Reference_Code__c, CreatedDate, Tipologia__c, CreatedById, TECH_Da_inviare__c, Stato__c 
                   FROM Interazione__c 
                    
                   
                  WHERE Id IN :scopeIds   //WHERE id = :IR.ScopeID__c        
                    
                  limit 10];
          
          
        
                for(Interazione__c r : myRecords)
                {
                    WriteSurvey(w, r);
                }
                
        
        
         
            //Surveys
            w.writeEndElement();
        
        //Root
        w.writeEndElement();

        //Envelope and body
        w.writeEndElement();
        w.writeEndElement();
        
       
        compiledrequest = w.getXmlString();
        
        return compiledRequest ;
    }

   private void WriteSurvey(XmlStreamWriter w, Interazione__c myR) 
    {
        
        list<Interazione__c> myRecords = new list<Interazione__c>();
        myRecords.add(myR);

        //Survey
        w.writeStartElement('', 'Survey', ''); 

        
        List<String> Tags = getTags('REQUEST', 'Interazione__c');
        Map<String, IE_CR2PH_junction__c > TagToFieldValue = getTagToFieldValue('REQUEST', 'Interazione__c');
        WriteRecords('Survey', w, myRecords, Tags, TagToFieldValue, '', '', false, false );
        
        ICFManagement.XMLInformation a = new ICFManagement.XMLInformation(myR);
       
       
         w.writeStartElement('', 'Id_Feedback','');
          w.writeCharacters(''+a.LogicKeyFeedback);
         w.writeEndElement();
         
         w.writeStartElement('', 'Language','');
          w.writeCharacters(''+a.Language);
         w.writeEndElement();
         
         w.writeStartElement('', 'Survey_Id','');
          w.writeCharacters(''+a.Survey_Id);
         w.writeEndElement();
         
         w.writeStartElement('', 'Address','');
          w.writeCharacters(''+a.Address);
         w.writeEndElement();  
         
         
        //Survey
        w.writeEndElement();
        

    }    PURE IT */

    

    //-------------- GENERIC METHODS------------------------------------------------------------------------
    
    /*
    
    sobject mycontact = [select name, Account.Name, Account.Owner.ProfileId,Account.Owner.Profile.Name from contact limit 1];
    string a = mycontact.getSobject('Account').get('name')+'';
    string b = mycontact.getSobject('Account').getSobject('Owner').get('ProfileId')+'';
    string c = mycontact.getSobject('Account').getSobject('Owner').getSobject('Profile').get('Name')+'';
    system.debug(a);
    system.debug(b);
    system.debug(c);

    */
    
    
    /* */
    /** PURE IT
    public void WriteRecords(String SingleRecordContainerTag, XmlStreamWriter w, List<Sobject> recL, List<String> Tags, Map<String,IE_CR2PH_junction__c>TagToFieldValue, String NameSpaceNameToUse, String StringNameSpaceUriToUse, Boolean writeStartElement, Boolean writeEndElement) 
    {
    
        for (Sobject sobj : recL) 
        {
            if (writeStartElement) 
            {
                w.writeStartElement(NameSpaceNameToUse, SingleRecordContainerTag, StringNameSpaceUriToUse);
            }
            for (string thisTag : Tags) 
            {
                String valueOfField = 
                    (
                     IE_Engine.getValueOfField(sobj,(TagToFieldValue.get(thisTag).FieldToUse__c+''))==''
                    ) ? 
                    '' : 
                    IE_Engine.getValueOfField(sobj,(TagToFieldValue.get(thisTag).FieldToUse__c+''));
                
                if ( valueOfField == '' && TagToFieldValue.get(thisTag).is_Nillable__c == true || valueOfField != '' ) 
                {
                
                    w.writeStartElement(NameSpaceNameToUse, thisTag, StringNameSpaceUriToUse);  
                    
                    
                    String myFinalValue = valueOfField;
                    PURE IT */

                    /*
                    if (TagToFieldValue.get(thisTag).ApexClass__c != null )
                    {
                        ClassFactoryManager cfm = new ClassFactoryManager();
                        myFinalValue = cfm.newClassInstance(TagToFieldValue.get(thisTag).ApexClass__c).run(valueOfField);
                    }
                    */
/** PURE IT
                    w.writeCharacters(''+myFinalValue);
                    w.writeEndElement(); 
PURE IT */
                    
                 /*   if (IR.Required_Configuration__c != null) 
                    {
                        Boolean requiredInFlow = TagToFieldValue.get(thisTag).get(IR.Required_Configuration__c) == true ? true : false ;
                        if (requiredInFlow && valueOfField=='')
                        {
                            system.debug('++++++++++++++++++++++++++++++requiredInFlow '+requiredInFlow);
                            //IR.RequiredFieldsErrors__c += thisTag + ';';
                            IR.RequiredFieldsErrors__c += sobj.id+':'+ thisTag + ':'+TagToFieldValue.get(thisTag).SObject_Type__c+'.'+TagToFieldValue.get(thisTag).FieldToUse__c+'\n';    
                        }
                    }*/
                    /**PURE IT
                }
        
            }
            if (writeEndElement) 
            {
                w.writeEndElement();
            }
        }
            
    }
        
 
    
    private List<String> getTags(String type, String SObjectType)
    {
        List<String> Tags = new List<String>();
        for(IE_CR2PH_junction__c thisJ : JRs) 
        {
            if (thisJ.Type__c == type && thisJ.SObject_Type__c == SObjectType) 
            {
                Tags.add(thisJ.Tag__c);
            }
        } 
        return Tags;
    }
    
    
    private Map<String, IE_CR2PH_junction__c > getTagToFieldValue(String type, String SObjectType)
    {
        Map<String, IE_CR2PH_junction__c > TagToFieldValue = new Map<String, IE_CR2PH_junction__c>();
        for(IE_CR2PH_junction__c thisJ : JRs) 
        {
            if (thisJ.Type__c == type && thisJ.SObject_Type__c == SObjectType) 
            {
                TagToFieldValue.put(thisJ.Tag__c,thisJ);    
            }

        }
        
        return TagToFieldValue;
    
    }
    
    
    //-------------- GENERIC METHODS------------------------------------------------------------------------
    
}  
    
PURE IT */