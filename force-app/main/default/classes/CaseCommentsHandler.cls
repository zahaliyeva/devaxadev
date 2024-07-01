/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         CaseCommentsHandler
Description:   Trigger Handler for the CaseComments SObject. This class implements 
               the ITrigger interface to help ensure the trigger code is bulkified and all in
               one place.  

History

16/08/2018     Created 
-------------------------------------------------------------------------------------------*/
public with sharing class CaseCommentsHandler implements ITrigger
{     
    
    public CaseCommentsHandler()
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
        Set<CaseComment> rSet = new Set<CaseComment>();
        Set<String> rIdSet = new Set<String>();
       
        for (SObject sObj : soList)
        {
            rSet.add((CaseComment)sObj);
            rIdSet.add((Id)sObj.get('Id'));
        } 

        CaseCommentsManagement.AfterInsert(rSet,rIdSet);
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
       
    }  
    
    public void afterDelete(List<SObject> soList)
    {  

    }
    
    public void afterUndelete(List<SObject> soList){ 
 
       
    }

    public void andFinally(){  

    }      
}