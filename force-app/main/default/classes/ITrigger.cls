/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 * the interface do not requires test coverage https://developer.salesforce.com/forums/?id=906F000000092cdIAA
 * Interface containing methods Trigger Handlers must implement to enforce best practice  
 * and bulkification of triggers.  
 */ 

public interface ITrigger {  
    /**  
    * BULK 
    *  
    * Those methods are called prior to execution of a trigger. Use those to cache  
    * any data required into maps prior execution of the trigger.  
    */ 

     void bulkBefore();

     void bulkAfter();

    
    /*BEFORE SINGLE METHOD*/
     void beforeInsert(SObject so);

     void beforeUpdate(SObject oldSo, SObject so);

     void beforeDelete(SObject so);
    
    /*BEFORE LIST METHOD*/
     void beforeInsert(List<SObject> soList);

     void beforeUpdate(List<SObject> oldSoList, List<SObject> soList);

     void beforeDelete(List<SObject> soList);

    
    /*AFTER SINGLE METHOD*/
     void afterInsert(SObject so);       

     void afterUpdate(SObject oldSo, SObject so);

     void afterDelete(SObject so);
     
     void afterUndelete(SObject so);

    /*AFTER LIST METHOD*/
     void afterInsert(List<SObject> soList);
    
     void afterUpdate(List<SObject> oldSoList, List<SObject> soList);
    
     void afterDelete(List<SObject> soList);
     
     void afterUndelete(List<SObject> soList);
       

    /** 
    * andFinally
    *  
    * This method is called once all records have been processed by the trigger. Use this   
    * method to accomplish any final operations such as creation or updates of other records.  
    */ 

     void andFinally();

}