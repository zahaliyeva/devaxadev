/*------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         SocialPersonaHandler
Description:   Apex class used to manage all the events related to the DML 
			   operations related to Social Personas

History

14/07/2017     Created - Marco Moscatelli.
----------------------------------------------------------------------------*/


public with sharing class SocialPersonaHandler implements ITrigger
{
	public final String AccountPrefix = Schema.SObjectType.Account.getKeyPrefix();

	public SocialPersonaHandler() 
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


    public void beforeDelete(List<SObject> soList)
    {     

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

    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
    	List<Account> AccToUpdList = new List<Account>();
        Map<String,String> MapPersonaToAccount = new Map<String,String>();
    	Map<Id,sObject> MapAccountToPersona = new Map<Id,sObject>();

    	for(sObject sObj: soList)
    	{
    		if(((String)sObj.get('ParentId')).startsWith(AccountPrefix))
    		{
    			MapAccountToPersona.put((String)sObj.get('ParentId'),sObj);

                MapPersonaToAccount.put((String)sObj.get('Id'),(String)sObj.get('ParentId'));
    		}
    	}

    	SocialPersonaManagement SPM = new SocialPersonaManagement();

        if(MapAccountToPersona.size()>0)
    	   SPM.AccountUpdate(MapAccountToPersona,MapPersonaToAccount);
    }  
    
    public void afterDelete(List<SObject> soList)
    {  

    }
    
    public void afterUndelete(List<SObject> soList)
    { 
    
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