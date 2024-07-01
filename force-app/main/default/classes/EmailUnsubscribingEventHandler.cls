public class EmailUnsubscribingEventHandler implements ITrigger  

{   // Constructor  

    public EmailUnsubscribingEventHandler()  
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
    
    }   
    
    public void beforeUpdate(SObject oldSo, SObject so)  
    {  
        


    }  

        
    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {  
        
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
    
    }  


    public void afterInsert(List<SObject> soList)
    {
        CustomerEventsManagement.insertEventInHistory(soList);
        EmailUnsubscribingEventManagement.sendUnsubscribeAlertEmails(soList);
    } 
       

    public void afterUpdate(SObject oldSo, SObject so)  
    {  

    }  

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {

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