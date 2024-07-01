/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 * Class PolizzaHandler  
 *  
 * Trigger Handler for the Polizza SObject. This class implements the ITrigger  
 * interface to help ensure the trigger code is bulkified and all in one place.  
 */

public with sharing class PolizzaHandler implements ITrigger
{

    //for Disable triggers UPDATEs for a BatchRunPolizzaTriggers 
    private static boolean DeactivateTrigger = false;

    // Member variable to hold the Id's of Polizza 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();


    public final String objectShare = 'InsurancePolicy__Share';
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual';
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Nodes__c';

    //public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c;  
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();

    PolizzaHandler_Helper Polizza_helper = new PolizzaHandler_Helper ();

    // Constructor  
    public PolizzaHandler()
    {

    }
        //get boolean for know if is Batch RUN
    public static boolean DeactivateTrigger(){
            return DeactivateTrigger;
            }
       //set get boolean for Batch RUN
    public static void setDeactivateTrigger(Boolean flag) {
            DeactivateTrigger = flag ; 
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
        List<InsurancePolicy__c> rList = (List<InsurancePolicy__c>) soList;  

        for (InsurancePolicy__c p : rList) {
            //Se non � visibile non dare visibilita ai nodi
            if(p.isHidden__c == true) {
                p.Nodes__c = '';
            }
        }

        //29-11-2021 *-+
        if(rList?.size() > 0 ) {
            Polizza_helper.BeforeOperationsPolizza(rList);
        }
    }

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {
        List<InsurancePolicy__c> NewrList = (List<InsurancePolicy__c>) soList;
        List<InsurancePolicy__c> PolizzeChanged = new List<InsurancePolicy__c>();
        Map <id,InsurancePolicy__c> mapaOld = new Map <id,InsurancePolicy__c> ((List<InsurancePolicy__c>) oldSoList);

        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

         // aggiornato ID-54 SOLO in caso di modifica dei campi impattati 01-12-2021 *-+

        for(InsurancePolicy__c polizzaTemp : NewrList ){

            //Se sto nascondendo la polizza allora rimuovo i nodi
            if(polizzaTemp.isHidden__c == true && mapaOld.get(polizzaTemp.id).isHidden__c == false){
                polizzaTemp.Nodes__c = '';
            }else if (mapaOld.get(polizzaTemp.id).isHidden__c == true && polizzaTemp.isHidden__c == false && String.isBlank(polizzaTemp.Nodes__c) && profileName == 'System Administrator') {
                polizzaTemp.addError('Contestualmente all\'impostazione del flag isHidden=false � necessario popolare il campo Nodes');
            }

            if(polizzaTemp.TECH_COMPANY__C != mapaOld.get(polizzaTemp.id).TECH_COMPANY__C) 
            {    //CHANGE OWNER FOR AXA ASSICURAZIONI 
                PolizzeChanged.add(polizzaTemp);
            }  //end IF is changed company
        }  //end for

        if(PolizzeChanged?.size() > 0) {
            Polizza_helper.BeforeOperationsPolizza(PolizzeChanged);
        }
       
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
        //List<InsurancePolicy__c> NewrList = (List<InsurancePolicy__c>) soList;
        //29-11-2021 *-+
        if(soList?.size() > 0) {
            Polizza_helper.AfterOperationsPolizza(soList);
        }
        
         //PolizzaManagement.RollUpAccountPolizza(NewrList);
        
        
    }

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {
        List<InsurancePolicy__c> NewrList = (List<InsurancePolicy__c>) soList;
        List<InsurancePolicy__c> PolizzeChanged = new List<InsurancePolicy__c>();
        Map <id,InsurancePolicy__c> mapaOld = new Map <id,InsurancePolicy__c> ((List<InsurancePolicy__c>) oldSoList);
         // aggiornato ID-54 SOLO in caso di modifica dei campi impattati 01-12-2021 *-+
        // is really used??? this boolean
        
        for(InsurancePolicy__c polizzaTemp : NewrList ){
            if(polizzaTemp.Nodes__c != mapaOld.get(polizzaTemp.id).Nodes__c ) {
                //ok is really changed or BOOLEAN Custom Settg -- so all should be inside this if 
                PolizzeChanged.add(polizzaTemp);
             }// end IF changed Nodes or FORCE_VISIBILITY_SHARE
        }
        
        if(PolizzeChanged?.size() > 0) {
            Polizza_helper.AfterOperationsPolizza(PolizzeChanged);
        }
        //Da Rimuovere per Data Int
        //PolizzaManagement.RollUpAccountPolizza(NewrList);
    }

    public void afterDelete(List<SObject> soList)
    { //Da rimuovere per Data Int
		/*List<InsurancePolicy__c> rList = (List<InsurancePolicy__c>) soList;

        //SHARING NOT NEEDED HERE

        //ROLLUP   
        //PolizzaManagement.RollUpAccountPolizza(rList);*/ 
    }

    public void afterUndelete(List<SObject> soList)
    {   //02-12-2021 *-+
        List<InsurancePolicy__c> rList = (List<InsurancePolicy__c>) soList;

        if(rList?.size() > 0) {
            Polizza_helper.AfterOperationsPolizza(rList);
        }
        
		//PolizzaManagement.RollUpAccountPolizza(rList);	
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