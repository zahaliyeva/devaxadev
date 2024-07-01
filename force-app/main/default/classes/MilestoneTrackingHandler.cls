/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         MilestoneTrackingHandler
Description:   Trigger Handler for the Milestone_Tracking__c SObject. This class implements the ITrigger  
               interface to help ensure the trigger code is bulkified and all in one place.  

History

03/08/2018     Created 
-------------------------------------------------------------------------------------------*/
public class MilestoneTrackingHandler implements ITrigger
{ 
    
    public static Boolean firstRunStatus = true;
    public static Boolean firstRunChar = true;
    public static Boolean AfterInsertNotDone = true;
    public static Boolean AfterUpdateNotDone = true; 

    // Constructor  
    public MilestoneTrackingHandler()
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
      system.debug('afterInsert'+soList);
      if(AfterInsertNotDone)
            AfterInsertNotDone = false;
        else
        {
            system.debug('After Insert AlreadyRun');
        }
        List<Milestone_Tracking__c> mlstTrackList = soList;
      MilestoneTrackingManagement.checkWorkingTimes(mlstTrackList);  
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