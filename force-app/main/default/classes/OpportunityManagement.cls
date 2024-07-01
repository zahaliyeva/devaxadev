/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         OpportunityManagement
Description:   Methods used in the OpportunityHandler to centralise trigger execution
History

11/10/2016    Davide Fabris - Created
----------------------------------------------------------------------------*/


public class OpportunityManagement {

    // This method is invoked before insert for Opportunity created from mobile with the quick action "NewOppSF1".
    // The field Opportunity_Record_Type__c stores the selection made for the recordtype

    public static List<Sobject> assignRecordtype(List<Sobject> OppList) {
        //Grab RT
        RecordTypeUtility RTU = new RecordTypeUtility();
        List<SelectOption> theRTOptions = RTU.getRecordTypes('Opportunity');
        Map<String,Id> DevNameToId = new Map<String,Id>();
        for ( SelectOption RTOpt : theRTOptions ){
            DevNameToId.put(RTOpt.getLabel(),RTOpt.getValue());
        }


        // Loop through all new records being created

        for (Sobject obj : OppList) {
            string selectedRT = obj.get('Opportunity_Record_Type__c')+'';
            system.debug('++++selectedRT'+selectedRT);
            if(String.isNotEmpty(selectedRT) && DevNameToId.keyset().contains(selectedRT)) {
                obj.put('RecordtypeId',DevNameToId.get(selectedRT));
            } //no else, if something goes wrong i create the auto Opportunity
        }
        //returning the updated list
        return OppList;
    }
    
    
    //This method is invoked in OpportunityHandler beforeinsert in order to set the correct values of ASA and ASAcode 
    //when ASA Description field is changed on a single Opportunity record during Opportunity creation 
    
    public static List<Sobject> setASAandASAcode(List<sObject> myOpps){
    
    List<Opportunity> Opps = (List<Opportunity>)myOpps; 

    for(Opportunity Opp: Opps){
    
    if(Opp.ASA_Description__c !=null && Opp.ASA_Description__c!=''){
    
            MappingASA__c mapASA = [SELECT ASA__c, Codice_ASA__c, ASA_Description__c FROM MappingASA__c WHERE ASA_Description__c=:Opp.ASA_Description__c LIMIT 1].get(0);
            Opp.ASA__c= mapASA.ASA__c; 
            Opp.Codice_ASA__c= (String.ValueOf(mapASA.Codice_ASA__c)); 
            
       
    }
    
    if(Opp.Sotto_ASA_Description__c != null && Opp.Sotto_ASA_Description__c !=''){
        
        MappingSottoASA__c mapSottoASA = [SELECT Sotto_ASA__c, Codice_Sotto_ASA__c, Sotto_ASA_Description__c FROM MappingSottoASA__C WHERE Sotto_ASA_Description__c=:Opp.Sotto_ASA_Description__c LIMIT 1].get(0);        
        Opp.Sotto_ASA__c=mapSottoASA.Sotto_ASA__c;
        Opp.Codice_Sotto_ASA__c= (String.ValueOf(mapSottoASA.Codice_Sotto_ASA__c)); 
    
    
    }
    
    if((Opp.Codice_ASA__c != null && Opp.Codice_ASA__c != '') && String.isBlank(Opp.ASA_Description__c) ){
    
        MappingASA__c mapASA = [SELECT ASA__c, Codice_ASA__c, ASA_Description__c FROM MappingASA__c WHERE Codice_ASA__c=:Integer.valueof(Opp.Codice_ASA__c.trim()) LIMIT 1].get(0);
        Opp.ASA__c = mapASA.ASA__c;
        Opp.ASA_Description__c = mapASA.ASA_Description__c;
        
    
    }
    }
        
    return Opps;
    
    }
    
   /* public static Sobject setASAandASAcodewhenchanged(sObject myoldOpp, sObject mynewOpp){
    
     Opportunity oldOpp = (Opportunity)myoldOpp; 
     Opportunity newOpp = (Opportunity)mynewOpp; 

     //system.debug('******MAPASA'+mapASA);
    
     if(oldOpp.ASA_Description__c != newOpp.ASA_Description__c){
            
            if(newOpp.ASA_Description__c==null || newOpp.ASA_Description__c==''){
            newOpp.ASA__c='';
            newOpp.Codice_ASA__c = '';
            }else{
             
            MappingASA__c mapASA = [SELECT ASA__c, Codice_ASA__c, ASA_Description__c FROM MappingASA__c WHERE ASA_Description__c=:newOpp.ASA_Description__c LIMIT 1].get(0);        

     
            newOpp.ASA__c= mapASA.ASA__c; 
            newOpp.Codice_ASA__c= (String.ValueOf(mapASA.Codice_ASA__c)); 
            }  

            if(newOpp.Sotto_ASA_Description__c=='' || newOpp.Sotto_ASA_Description__c==null){ 
                    
            newOpp.Codice_Sotto_ASA__c = '';
            newOpp.Sotto_ASA__c = '';
            }else{
            
            MappingSottoASA__c mapSottoASA = [SELECT Sotto_ASA__c, Codice_Sotto_ASA__c, Sotto_ASA_Description__c FROM MappingSottoASA__C WHERE Sotto_ASA_Description__c=:newOpp.Sotto_ASA_Description__c LIMIT 1].get(0);        
            newOpp.Codice_Sotto_ASA__c = (String.ValueOf(mapSottoASA.Codice_Sotto_ASA__c));
            newOpp.Sotto_ASA__c = mapSottoASA.Sotto_ASA__c;
            
            }
     
     
     }
     
     if(oldOpp.Sotto_ASA_Description__c != newOpp.Sotto_ASA_Description__c){
     
            if(newOpp.Sotto_ASA_Description__c!=''&& newOpp.Sotto_ASA_Description__c!=null){
            
            MappingSottoASA__c mapSottoASA = [SELECT Sotto_ASA__c, Codice_Sotto_ASA__c, Sotto_ASA_Description__c FROM MappingSottoASA__C WHERE Sotto_ASA_Description__c=:newOpp.Sotto_ASA_Description__c LIMIT 1].get(0);        
            newOpp.Sotto_ASA__c= mapSottoASA.Sotto_ASA__c; 
            newOpp.Codice_ASA__c= (String.ValueOf(mapSottoASA.Codice_Sotto_ASA__c)); 
            }  
     
     }
    
    
    return newOpp;
    
    }*/
    
    public static List<Sobject> setASAandASAcodewhenchanged(List<sObject> myoldOpps, List<sObject> mynewOpps){
    
     //Opportunity oldOpps = (Opportunity)myoldOpps; 
     //Opportunity newOpps = (Opportunity)mynewOpps; 

     //system.debug('******MAPASA'+mapASA);
    
        
        
    for(integer i=0; i<mynewOpps.size(); i++){
        
     if(mynewOpps.get(i).get('ASA_Description__c') != myoldOpps.get(i).get('ASA_Description__c')){
            
            if(mynewOpps.get(i).get('ASA_Description__c')==null || mynewOpps.get(i).get('ASA_Description__c')==''){
            mynewOpps.get(i).put('ASA__c','');
            mynewOpps.get(i).put('Codice_ASA__c','');
            }else{
            
            string ASADescription = string.ValueOf(mynewOpps.get(i).get('ASA_Description__c'));
            MappingASA__c mapASA = [SELECT ASA__c, Codice_ASA__c, ASA_Description__c FROM MappingASA__c WHERE ASA_Description__c=:ASADescription LIMIT 1].get(0);        

     
            mynewOpps.get(i).put('ASA__c',mapASA.ASA__c); 
            mynewOpps.get(i).put('Codice_ASA__c',(String.ValueOf(mapASA.Codice_ASA__c))); 
            }  

            if(mynewOpps.get(i).get('Sotto_ASA_Description__c')=='' || mynewOpps.get(i).get('Sotto_ASA_Description__c')==null){ 
                    
            mynewOpps.get(i).put('Sotto_ASA__c','');
            mynewOpps.get(i).put('Codice_Sotto_ASA__c','');
            }else{
            
            
            string SottoASADescription = String.ValueOf(mynewOpps.get(i).get('Sotto_ASA_Description__c'));
            
            MappingSottoASA__c mapSottoASA = [SELECT Sotto_ASA__c, Codice_Sotto_ASA__c, Sotto_ASA_Description__c FROM MappingSottoASA__C WHERE Sotto_ASA_Description__c=:SottoASADescription  LIMIT 1].get(0);        
            mynewOpps.get(i).put('Codice_Sotto_ASA__c',(String.ValueOf(mapSottoASA.Codice_Sotto_ASA__c)));
            mynewOpps.get(i).put('Sotto_ASA__c',mapSottoASA.Sotto_ASA__c);
            
            }
     
     
     }
     
     if(mynewOpps.get(i).get('Sotto_ASA_Description__c') != myoldOpps.get(i).get('Sotto_ASA_Description__c')){
     
            if(mynewOpps.get(i).get('Sotto_ASA_Description__c')!=''&& mynewOpps.get(i).get('Sotto_ASA_Description__c')!=null){
            
            string SottoASADescription = String.ValueOf(mynewOpps.get(i).get('Sotto_ASA_Description__c'));

            
            MappingSottoASA__c mapSottoASA = [SELECT Sotto_ASA__c, Codice_Sotto_ASA__c, Sotto_ASA_Description__c FROM MappingSottoASA__C WHERE Sotto_ASA_Description__c=:SottoASADescription  LIMIT 1].get(0);        
            mynewOpps.get(i).put('Sotto_ASA__c',mapSottoASA.Sotto_ASA__c); 
            mynewOpps.get(i).put('Codice_Sotto_ASA__c',(String.ValueOf(mapSottoASA.Codice_Sotto_ASA__c))); 
            }  
     
     }
    
    }
    
    return mynewOpps;
    
    }
    
    
    
    
}