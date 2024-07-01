/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 * Class NucleoHander
 *  
 * Trigger Handler for the Nucleo_di_appartenenza__c SObject. This class implements the ITrigger  
 * interface to help ensure the trigger code is bulkified and all in one place.  
 */ 
/**
 * @description PURE IT 22/05 - commentata la classe
 */
public with sharing class NucleoHander  {}
/** PURE IT
implements ITrigger  
{     

    // Member variable to hold the Id's of Relationship__c 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    
    public final String objectShare = 'Nucleo_di_appartenenza__Share';  
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Agency_Code__c';    
    
    //public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c;  
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();   
    
    // Constructor  
    public NucleoHander()
    {  

    }  
PURE IT */
    /**  
    * BULK 
    *  
    * Those methods are called prior to execution of a trigger. Use those to cache  
    * any data required into maps prior execution of the trigger.  
    */ 
/** PURE IT
    public void bulkBefore()
    {  

    }  

    public void bulkAfter()
    {  

    }  

    PURE IT */
    /*BEFORE SINGLE METHOD*/

    /** PURE IT
    public void beforeInsert(SObject so)
    {  

    }  

    public void beforeUpdate(SObject oldSo, SObject so)
    {  

    }  

    public void beforeDelete(SObject so)
    {     

    }
    PURE IT */
    /*BEFORE LIST METHOD*/
    /** PURE IT
    public void beforeInsert(List<SObject> soList)
    {  

    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {

    }  


    public void beforeDelete(List<SObject> soList){     

    } 

    PURE IT */
    /*AFTER SINGLE METHOD*/
    /** PURE IT
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
PURE IT */
    /*AFTER LIST METHOD*/
    /** PURE IT
    public void afterInsert(List<SObject> soList)
    {  
    
        List<Nucleo_di_appartenenza__c> rList = (List<Nucleo_di_appartenenza__c>) soList;
        NucleoManagement.ShareWithFullAgency(rList);//the methods compute sharing for the whole agency
        PURE IT */
    /*    Set<Id> idstoReassign = new Set<Id>();
        for(Nucleo_di_appartenenza__c a : rList)
        {
            idstoReassign.add(a.id);
        }
        if (!System.isFuture()) { //CALLING FUTURE METHOD ONLY IF NOT ALREADY IN A FUTURE CALL
            NucleoManagement.reassingGroups(idstoReassign);
        } else {
            system.debug('+++++FUTURE CALL to reassign Before Update NOT MADE.');
        }*/
        
      /*  Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);*/
       /**PURE IT 
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
    
        List<Nucleo_di_appartenenza__c> rList = (List<Nucleo_di_appartenenza__c>) soList;
        NucleoManagement.ShareWithFullAgency(rList);//the methods compute sharing for the whole agency
        PURE IT */
      /*  Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);*/
    

/** PURE IT
    }  
    
    public void afterDelete(List<SObject> soList)
    {  
    
        
        //SHARING NOT NEEDED HERE
   


    }
    
    public void afterUndelete(List<SObject> soList)
    { 
    
        List<Nucleo_di_appartenenza__c> rList = (List<Nucleo_di_appartenenza__c>) soList;
        NucleoManagement.ShareWithFullAgency(rList);//the methods compute sharing for the whole agency
        PURE IT */
      /*  Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);*/
    

/**PURE IT
    }
    PURE IT */
       

    /** 
    * andFinally
    *  
    * This method is called once all records have been processed by the trigger. Use this   
    * method to accomplish any final operations such as creation or updates of other records.  
    */ 
/**PURE IT
    public void andFinally(){  

    }  
    }
    PURE IT */