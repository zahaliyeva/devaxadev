/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_Request_StaticCompiler 
Description:   Class with the Static Compiler methods used by the IntegrationEngine.
               The compiler takes the template and replaces STATICALLY with the placeholders.

History
 -30/12/2015   Davide Fabris - Created
 -04/01/2016   Davide Fabris -NILLABLE elements are respected
               Davide Fabris -TRANSCODING is respected
----------------------------------------------------------------------------*/

public class IE_Request_StaticCompiler implements IE_RequestCompiler {


    public string compileRequest(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs) {
        String compiledrequest = '';
        
        // retrieving therequest template as stored on the  attachment 
        Attachment template = [SELECT Body, ContentType, Description, ParentId FROM Attachment where ParentId=:CR.Id];
        
        //List<String> scopeSObj = CR.Scope_Sobject__c.split(';'); //getting the objects to handle from the ConfigFile //NOT NECESSARY as tI get this info from the placeholder list
    
        //getting the Ids to handle from the Integrationrecord
        List<Id> scopeIds = new List<id>(); 
        for (String thisIDstring: IR.ScopeID__c.split(';')) {
            scopeIds.add(Id.valueof(thisIDstring));
        }

        //Sorting the Placeholders based on the Sobject they refer to
        // the map contains as key the object name, and as value the lset of fields desired
         Map<String,Set<String>> ObjectANDFieldsName =  getObjectANDFieldsNameMap(PHs);

        //Composing the query dynamiccal to retrieve the field values
        set<String> QueriesToRun = getQueryNoFilter(ObjectANDFieldsName);

        //A list of sobject will contain al records involved in the integration
        List<Sobject> ScopeSobj = new List<Sobject>();
        
        //Performing the query. Inside for loop as one per Sobject type
        for (string thisQUERY : QueriesToRun) {
            List<Sobject> thisList = new List<Sobject>();
            String thisQUERYWithfilter = thisQUERY + ' WHERE Id in :scopeIds';
            system.debug('+++++thisQUERYWithfilter '+thisQUERYWithfilter );
            thisList = Database.Query(thisQUERYWithfilter);
            ScopeSobj.addAll(thisList);
            system.debug('+++++ScopeSobj'+ScopeSobj );
        }
        
        //filling the map placeholder-->value(s). To do this I need  the placeholders and the objects
        Map<String, String> PlaceholderValues  = new Map<String,String>();
        PlaceholderValues = getPlaceholderValues(PHs,ScopeSobj);
        system.debug('++++PlaceholderValues '+PlaceholderValues );
        
        string templateString = template.body.toString();
        compiledRequest = compileTemplate(templateString,PlaceholderValues,JRs );
        
        
        
        return compiledRequest ;
    }
    
    
   public map<String,Set<String> > getObjectANDFieldsNameMap ( List<IE_Placeholder__c> PHs ) {
        Map<String,Set<String>> ObjectANDFieldsName = new Map <String,Set<String>>();
        //running through the placeholders
        for (IE_Placeholder__c thisPH : PHs) {
            if (!ObjectANDFieldsName.containsKey(thisPH.Sobject__c)){
                ObjectANDFieldsName.put(thisPH.Sobject__c,new Set<String>());
            } 
            ObjectANDFieldsName.get(thisPH.Sobject__c).add(thisPH.FieldToUse__c);
        }
        return ObjectANDFieldsName;
   }
   
    public Set<String> getQueryNoFilter (Map <String,Set<String>> ObjectANDFieldsName){
        Set<String> QueriesToRun = new Set<String>();
        for (string thisObj : ObjectANDFieldsName.keyset()) {
            string thisQUERY= 'SELECT ';
            for (string thisfield : ObjectANDFieldsName.get(thisObj)) {
                thisQUERY +=thisfield + ' ,';
            }
            thisQUERY=thisQUERY.removeEnd(',');
            thisQUERY+='FROM ' + thisObj;
            
            QueriesToRun.add(thisQUERY);
        }
        return QueriesToRun;
    }

    public Map<String,String> getPlaceholderValues(List<IE_Placeholder__c > PHs, List<Sobject> ScopeSobj){
        Map<String,String> PlaceholderValue = new Map<String,String>();     
        for (IE_Placeholder__c thisPH : PHs) {
            PlaceholderValue.put(thisPH.Key__c,''); //to begin with set and empty valueOf
            for (Sobject obj : ScopeSobj) {
                if (obj.getSObjectType().getDescribe().getName()==thisPH.Sobject__c){
                    try {
                        if (obj.get(thisPH.FieldToUse__c) instanceof Date) {
                            DateTime DateValue = (DateTime)obj.get(thisPH.FieldToUse__c);
                            String StringValue = DateValue.format('yyyy-MM-dd');
                            PlaceholderValue.put(thisPH.Key__c,StringValue);
                        } else {
                            String StringValue = String.valueOf(obj.get(thisPH.FieldToUse__c));
                            if (StringValue!=null){
                                PlaceholderValue.put(thisPH.Key__c,StringValue);
                            }
                        }
                    } catch (exception e) {
                        system.debug('+++++++++something went wrong'+e);
                    }

                }
            }
        }
        return PlaceholderValue;
    }
    /*public Map<String,List<String>> getPlaceholderValues(List<IE_Placeholder__c > PHs, List<Sobject> ScopeSobj){
        Map<String,List<String>> PlaceholderValue = new Map<String,List<String>>();     
        for (IE_Placeholder__c thisPH : PHs) {
            PlaceholderValue.put(thisPH.Key__c,new List<String>()); //to begin with set and empty valueOf
            for (Sobject obj : ScopeSobj) {
                if (obj.getSObjectType().getDescribe().getName()==thisPH.Sobject__c){
                    List<String> currentList = PlaceholderValue.get(thisPH.Key__c);
                    //updating the list
                    currentList.add(String.valueOf(obj.get(thisPH.FieldToUse__c)));
                    PlaceholderValue.put(thisPH.Key__c,currentList);
                }
            }
        }
        return PlaceholderValue;
    }*/
    public string compileTemplate (string templateString,Map<String,String> PlaceholderValues, List<IE_CR2PH_junction__c> JRs ){
        system.debug('+++++Processing '+ JRs.size() + ' Mappings');
        string compiledTemplate = templateString;
        for (IE_CR2PH_junction__c thisJR : JRs) {
            string tobereplaced = thisJR.IE_Placeholder__r.key__c;
            string replacement = PlaceholderValues.get(thisJR.IE_Placeholder__r.key__c);
            system.debug('+++++replacement before transcoding'+replacement);
            
            //performing transcoding
            if (!String.isempty(thisJR.ExpV_External__c)){
                List<String>  ExpSFDC = thisJR.ExpV_SFDC__c.split(';');
                system.debug('++++expectedSFDC'+ExpSFDC);
                List<String> ExpExt = thisJR.ExpV_External__c.split(';');
                system.debug('++++expectedSFDC'+ExpExt);
                Map<String,string> transcodingSFDC2Ext = new Map<String,string>();
                for (integer i=0; i<ExpSFDC.size(); i++ ) {
                    transcodingSFDC2Ext.put(ExpSFDC[i].tolowercase(),ExpExt[i]);
                }
                system.debug('++++the transcoding'+transcodingSFDC2Ext);
                replacement = transcodingSFDC2Ext.get(replacement.tolowercase());
                if (replacement == null) replacement = '';
            } 
            
            system.debug('+++replacing'+tobereplaced +' with ' +replacement );
            
            if (!thisJR.Is_Nillable__c){
                //Must sort out  the fields that are not populated but not nillable removing the tags
                if (String.isempty(replacement)) {
                    //remove the placeholders
                    compiledTemplate = compiledTemplate.remove(tobereplaced);
                    //remove opening tags
                    compiledTemplate = compiledTemplate.remove('<'+thisJR.tag__c+'>');
                    //remove closing  tags
                    compiledTemplate = compiledTemplate.remove('</'+thisJR.tag__c+'>');
                }
            }
            //string encoded = replacement.escapeUnicode();
            //system.debug('++++++encoded UTF8'+encoded );
            //compiledTemplate = compiledTemplate.replace(tobereplaced, encoded );
            
            String escapedXML = replacement.escapeXml();
            system.debug('++++escaped XML'+ escapedXML);

            compiledTemplate = compiledTemplate.replace(tobereplaced, escapedXML);

            //compiledTemplate = compiledTemplate.replace(tobereplaced, replacement);
        }
        return compiledTemplate;
    }
            

    /*public IE_Request_StaticCompiler init(IE_Integration_Record__c IR) {
        return new IE_Request_StaticCompiler();
    }    public List<IE_CR2PH_junction__c> getJRs (Id ConfigId) {
        List<IE_CR2PH_junction__c> JRs = new list<IE_CR2PH_junction__c>();
        JRs=[SELECT id,IE_Configuration__c,IE_Placeholder__c  from IE_CR2PH_junction__c where IE_Configuration__c=:ConfigId];
        return JRs;
    }
    
    public List<IE_Placeholder__c> getPHs (List<IE_CR2PH_junction__c> JRs) {
        //Getting the list of PH ids
        List<Id> allPHids = new list<Id>();
        for (IE_CR2PH_junction__c thisJR :JRs) {
            allPHids.add(thisJR.IE_Placeholder__c);
        }
        List<IE_Placeholder__c> PHs = new list<IE_Placeholder__c>();
        PHs = [SELECT id from IE_Placeholder__c where id in:allPHids];
        return PHs;
    }*/
}