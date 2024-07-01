/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 * Class RelationshipHandler
 *  
 * Trigger Handler for the Relationship SObject. This class implements the ITrigger  
 * interface to help ensure the trigger code is bulkified and all in one place.  
 */ 

public with sharing class RelationshipHandler implements ITrigger  
{     

    // Member variable to hold the Id's of Relationship__c 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    
    public final String objectShare = 'Relationship__Share';  
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Nodes__c';    
    
    //public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c;  
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();   
    
    // Constructor  
    public RelationshipHandler()
    {  

    }  

    /**  
    * BULK 
    *  
    * Those methods are called prior to execution of a trigger. Use those to cache  
    * any data required into maps prior execution of the trigger.  
    */ 

    public void bulkBefore()
    {  

    }  

    public void bulkAfter()
    {  

    }  

    
    /*BEFORE SINGLE METHOD*/
    public void beforeInsert(SObject so)
    {  

    }  

    public void beforeUpdate(SObject oldSo, SObject so)
    {  

    }  

    public void beforeDelete(SObject so)
    {     

    }
    
    /*BEFORE LIST METHOD*/
    public void beforeInsert(List<SObject> soList)
    {  

    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {

    }  


    public void beforeDelete(List<SObject> soList){     

    } 

    
    /*AFTER SINGLE METHOD*/
    public void afterInsert(SObject so)
    {  

    }         

    public void afterUpdate(SObject oldSo, SObject so)
    {  

    }  

    public void afterDelete(SObject so)
    {  

    }
    
    public void afterUndelete(SObject so)
    {  

    }

    /*AFTER LIST METHOD*/
    public void afterInsert(List<SObject> soList)
    {  
    
        List<Relationship__c> rList = (List<Relationship__c>) soList;
 
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
    
        List<Relationship__c> rList = (List<Relationship__c>) soList;
   
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
    


    }  
    
    public void afterDelete(List<SObject> soList)
    {  
    
        
        //SHARING NOT NEEDED HERE
   


    }
    
    public void afterUndelete(List<SObject> soList)
    { 
    
        List<Relationship__c> rList = (List<Relationship__c>) soList;
        
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
    


    }
       

    /** 
    * andFinally
    *  
    * This method is called once all records have been processed by the trigger. Use this   
    * method to accomplish any final operations such as creation or updates of other records.  
    */ 

    public void andFinally(){  

    }  
    
}