/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class MembriNucleoHandler  

 *  

 * Trigger Handler for the Membro_del_nucleo__c SObject. This class implements the ITrigger  

 * interface to help ensure the trigger code is bulkified and all in one place.  

 */ 
/**
 * @description PURE IT 22/05 - commentata la classe
 */
public with sharing class MembriNucleoHandler {}
  /** PURE IT
    implements ITrigger  

{   

    // Member variable to hold the Id's of Campaigns 'in use'  

    private Set<Id> RecordsInUse = new Set<Id>(); 
    
    // Constructor  

    public MembriNucleoHandler()  
    {  

    }  

   PURE IT */

    /**  

     * bulkBefore  

     *  

     * This method is called prior to execution of a BEFORE trigger. Use this to cache  

     * any data required into maps prior execution of the trigger.  

     */ 
/** PURE IT
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
    //Populating fieds for rollup when a new member is created. Not on edit as we prevent reassignment of members
        List<Membro_del_nucleo__c> inputL = (List<Membro_del_nucleo__c>) soList;
        inputL = MembriNucleoManagement.PopulateRollupFieldsOnCreation(inputL);
        system.debug('+++inputL.size()'+inputL.size());
        for (Membro_del_nucleo__c  thisM : inputL) {
            system.debug('++++thisM'+thisM);
        }
    }   
    
    public void beforeUpdate(SObject oldSo, SObject so)  
    {  

    }  

        
    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {  
    
        List<Membro_del_nucleo__c> NewrList = (List<Membro_del_nucleo__c>) soList;
        system.debug('++++NewrList'+NewrList);  
        List<Membro_del_nucleo__c> OldrList = (List<Membro_del_nucleo__c>) oldSoList;
        system.debug('++++OldrList'+OldrList); 
        List<Membro_del_nucleo__c> recalcList = new list<Membro_del_nucleo__c>();
        for (integer i=0;i<NewrList.size();i++) {
            if (OldrList[i].Account_correlato__c != NewrList[i].Account_correlato__c) {
                recalcList.add(NewrList[i]);
            }
        }
        recalcList = MembriNucleoManagement.PopulateRollupFieldsOnCreation(recalcList);
        system.debug('+++recalcList.size()'+recalcList.size());
        for (Membro_del_nucleo__c  thisM : recalcList) {
            system.debug('++++thisM'+thisM);    
        }   

    }    
PURE IT */
    /**  

     * beforeDelete  

     *  

     * This method is called iteratively for each record to be deleted during a BEFORE  

     * trigger.  

     */ 
/** PURE IT
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

    }    PURE IT */     

    /**  

     * andFinally  

     *  

     * This method is called once all records have been processed by the trigger. Use this   

     * method to accomplish any final operations such as creation or updates of other records.  

     */ 
/** PURE IT
    public void andFinally()  

    {  


    }  
    }
PURE IT */