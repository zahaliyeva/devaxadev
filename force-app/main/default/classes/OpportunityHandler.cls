/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class OpportunityHandler  

 *  

 * Trigger Handler for the Opportunity SObject. This class implements the ITrigger  

 * interface to help ensure the trigger code is bulkified and all in one place.  

 */ 

public with sharing class OpportunityHandler implements ITrigger  

{   

    public final String objectShare = 'OpportunityShare';  
    public final String parentId = 'OpportunityId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'OpportunityAccessLevel';
    public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Main_Node__c';  


    // Constructor  

    public OpportunityHandler()  
    {  

    }  

   

    /**  

     * bulkBefore  

     *  

     * This method is called prior to execution of a BEFORE trigger. Use this to cache  

     * any data required into maps prior execution of the trigger.  

     */ 

    public void bulkBefore()  
    {  

    }  

       

    public void bulkAfter()  
    {  

    }  

           

    public void beforeInsert(SObject so)  
    { 
        
    }  
    
    public void beforeInsert(List<SObject> soList)  
    {  
        soList = OpportunityManagement.assignRecordtype(soList);
        soList = OpportunityManagement.setASAandASAcode(soList);
    }   
    
    public void beforeUpdate(SObject oldSo, SObject so)  
    {  

    }  

        
    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {
        soList = OpportunityManagement.setASAandASAcodewhenchanged(oldSoList,soList);
    }    

    /**  

     * beforeDelete  

     *  

     * This method is called iteratively for each record to be deleted during a BEFORE  

     * trigger.  

     */ 

    public void beforeDelete(SObject so)  
    {     

    }  
    
    public void beforeDelete(List<SObject> soList)  
    {  

    } 

   public void afterInsert(SObject so)  
    {  
       //so = QuotationManagement.createQuotationFromConversion(so); //CAPOBIANCO_A 07/12/2017 - Sprint 57
    }  


    public void afterInsert(List<SObject> soList)  
    {
        
        
        //SHARING
        Map<id,SObject> mapSObj = new Map<id,SObject>();
        for(SObject s : soList)
        {
            mapSObj.put(s.id,s);
        }
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        
        for(SObject so : soList){
            
            so = QuotationManagement.createQuotationFromConversion(so); //CAPOBIANCO_A 07/12/2017 - Sprint 57
        
        }
        if(!QuotationManagement.Errors.isEmpty()) {
            ApplicationLogHelper.LogErrors('QuotationManagement', QuotationManagement.Errors);
            QuotationManagement.Errors.clear();
        }

    } 
    
       

    public void afterUpdate(SObject oldSo, SObject so)  
    {  

    }  

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {
    
        //SHARING
        Map<id,SObject> mapSObj = new Map<id,SObject>();
        for(SObject s : soList)
        {
            mapSObj.put(s.id,s);
        }
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);

    

    }  

    public void afterDelete(SObject so)  
    {  

    }  
    
    public void afterUndelete(SObject so)  
    {  

    }  
    
    public void afterDelete(List<SObject> soList)  
    {  
    

    }  

    public void afterUndelete(List<SObject> soList)  
    {  
        
        //SHARING
        Map<id,SObject> mapSObj = new Map<id,SObject>();
        for(SObject s : soList)
        {
            mapSObj.put(s.id,s);
        }
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);

    }         

    /**  

     * andFinally  

     *  

     * This method is called once all records have been processed by the trigger. Use this   

     * method to accomplish any final operations such as creation or updates of other records.  

     */ 

    public void andFinally()  

    {  


    }  

}