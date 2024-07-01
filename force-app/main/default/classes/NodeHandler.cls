/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class NodeHandler  

 *  

 * Trigger Handler for the Node__c SObject. This class implements the ITrigger  

 * interface to help ensure the trigger code is bulkified and all in one place.  

 */ 

public with sharing class NodeHandler implements ITrigger  
{     
    //On blacklist page the user updates all nodes with blacklist flags. This triggers the update of agency account that should be prevented
    public final Map<Id, Profile> skipAgencyUpdateProfiles = new Map<Id,Profile>([SELECT id, Name FROM Profile WHERE Name IN ('AAI - Vendite Avanzato')]);

    //for Disable triggers for a Node 
    private static boolean DeactivateTrigger = false;

    // Member variable to hold the Id's of Nodes 'in use'  

    private Set<Id> RecordsInUse = new Set<Id>();  

              

    // Constructor  

    public NodeHandler()  
    {  

    }  
    //get boolean for know if is Batch RUN
    public static boolean isDeactivateTrigger(){
        return DeactivateTrigger;
        }
   //set get boolean for Batch RUN
   public static void setDeactivateTrigger(Boolean flag) {
        DeactivateTrigger = flag ; 
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
        //ID 277 BlacklistProcessi__c --> Rinnovi
        List<Node__c> rList = (List<Node__c>) soList; 
        NodeManagement nm = new NodeManagement();
        nm.updateBlacklistfield(rList);
        //nm.prepareBulkRequestProcess(rList);
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
        // Map nodes to groups
        List<Node__c> rList = (List<Node__c>) soList;
        NodeManagement nm = new NodeManagement();
        nm.MapNodesToGroups(rList);        
        nm.prepareBulkRequestBroker(rList, null, 'insert');
        
        //Create Agency Queue
        NodeManagementAgency nma = new NodeManagementAgency();
        nma.UpsertAgencyAccounts(rList);

        //ID277 Update Accounts with BulkRequest 
        nm.prepareBulkRequestProcess(rList);
    } 
       

    public void afterUpdate(SObject oldSo, SObject so)  
    {  

    }  

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)  
    { 
        // Map nodes to groups
        List<Node__c> rList = (List<Node__c>) soList;
        List<Node__c> rListOld = (List<Node__c>) oldSoList;
        List<Node__c> NodesToRefresh = new List<Node__c>();

        for (Integer i= 0; i<rList.size(); i++) {
            
            //Adding logic to force recalculation even with same parent
            boolean FORCE_NODE_CALCULATION = false;// in case i dont know i should not recalculate
            try {
                AAI_Code_Variables__c CV =  AAI_Code_Variables__c.getValues('FORCE_NODE_CALCULATION');
                FORCE_NODE_CALCULATION = Boolean.ValueOf(CV.value__c);
            } catch (exception e) {
                FORCE_NODE_CALCULATION = false;// in case i dont know i should not recalculate
            }
            
            //Set recalculation in OR--> parentISdifferent || forcerecalculation THEN recalculate
            if (rList.get(i).Parent_node_unique_code__c!=rListOld.get(i).Parent_node_unique_code__c || FORCE_NODE_CALCULATION) {
                NodesToRefresh.add(rList.get(i));
            }
            
        }
        system.debug('++++++NodesToRefresh'+NodesToRefresh);
        NodeManagement nm = new NodeManagement();
        if (NodesToRefresh.size()>0) {
            //NodeManagement nm = new NodeManagement();
            //nm.MapNodesToGroups(rList);
            nm.MapNodesToGroups(NodesToRefresh);
        }
        nm.prepareBulkRequestBroker(rList, rListOld, 'update');

        //Let only allowed profiles to update agencies
        if (!skipAgencyUpdateProfiles.keyset().contains(Userinfo.getProfileId())) {
        //Create Agency Queue
            NodeManagementAgency nma = new NodeManagementAgency();
            nma.UpsertAgencyAccounts(rList);
        }

    }  

    public void afterDelete(SObject so)  
    {  

    }  
    
    public void afterUndelete(SObject so)  
    {  

    }  
    
    public void afterDelete(List<SObject> soList)  
    {  
        // Map nodes to groups
        List<Node__c> rList = (List<Node__c>) soList;
        NodeManagement nm = new NodeManagement();        
        nm.prepareBulkRequestBroker(rList, null, 'delete');
    }  

    public void afterUndelete(List<SObject> soList)  
    {  
        // Map nodes to groups
        List<Node__c> rList = (List<Node__c>) soList;
        NodeManagement nm = new NodeManagement();   
        nm.prepareBulkRequestBroker(rList, null, 'undelete');
    }         

    /**  

     * andFinally  

     *  

     * This method is called once all records have been processed by the trigger. Use this   

     * method to accomplish any final operations such as creation or updates of other records.  

     */ 

    public void andFinally()  

    {  
     system.debug('+++++++++++++++++++++++++++check on query limit:limits.getqueries()'+limits.getqueries());   

    }  

}