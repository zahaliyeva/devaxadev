/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class CompetitorContractHandler  

 *  

 * Trigger Handler for the Competitor_Contract_ custom Object. This class implements the ITrigger  

 * interface to help ensure the trigger code is bulkified and all in one place.  

 */ 

public with sharing class CompetitorContractHandler  

    implements ITrigger  

{     

    // Member variable to hold the Id's of CompetitorContracts 'in use'  

    private Set<Id> RecordsInUse = new Set<Id>(); 
    
    
 

              

    // Constructor  

    public CompetitorContractHandler()  
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
        //if the time dependent workflow is trying to update the flag to TRUE, I intercept the modification and create the task
        //The flag is set back to FALSE, so that next updates do not create a task, but a subsequent workflow does
        
        List<Competitor_Contract__c> NewrList = (List<Competitor_Contract__c>) soList;
        List<Competitor_Contract__c> OldrList = (List<Competitor_Contract__c>) oldSoList;
        List<Task> taskstoinsert= new List<Task>();
        Id recordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('Generico').getRecordTypeId();

        
        for (integer i=0;i<NewrList.size();i++) {
        integer ReferenceTime;
                if (NewrList[i].Policy_type__c=='Car'){
                    ReferenceTime=30;
                } else {
                    ReferenceTime=90;
                }
            if (OldrList[i].TECH_CreateTask__c==FALSE && NewrList[i].TECH_CreateTask__c==TRUE) {
            //if (TRUE==TRUE) {
                task thistask = new task();
                thistask.Whatid=NewrList[i].Id;
                thistask.subject='Polizza concorrente in scadenza';
                thistask.Recordtypeid=recordTypeId;
                thistask.Ownerid=NewrList[i].CreatedById;
             
                 date ContExpDate = NewrList[i].Contract_Expiry_Date__c;
                 date today=datetime.now().date();
                if(today.daysBetween(ContExpDate)>=ReferenceTime){
                    thistask.ActivityDate=ContExpDate.addDays(-30);
                }
                if(today.daysBetween(ContExpDate)<ReferenceTime){
                    thistask.ActivityDate=ContExpDate.addDays((ContExpDate.daysBetween(today))/2);
                }
                thistask.status='Open';
                thistask.Priority='Normal';
                //Add other relevant info 
                
                taskstoinsert.add(thistask);
                NewrList[i].TECH_CreateTask__c=FALSE;
            }
        }
        insert taskstoinsert;

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