/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 * Class ClaimHandler  
 *  
 * Trigger Handler for the Claim__c SObject. This class implements the ITrigger  
 * interface to help ensure the trigger code is bulkified and all in one place.  
 */ 

public with sharing class ClaimHandler implements ITrigger  
{     

    // Member variable to hold the Id's of Claim__c 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    
    public final String objectShare = 'Claim__Share';  
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Nodes__c';    
    
    //public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c;     
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();  

    // Constructor  
    public ClaimHandler()
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
    
        List<Claim__c> rList = (List<Claim__c>) soList;        
        //List<Claim__c> AMPSClaims = new list<Claim__c>();//MOSCATELLI_M 04042016: EVO46              
        
        //CHANGE OWNER FOR AXA ASSICURAZIONI 
        for(Claim__c a : rList)
        {
            //Se non � visibile non dare visibilita ai nodi
            if(a.isHidden__c == true) {
                a.Nodes__c = '';
            }

            if (a.TECH_COMPANY__C == 'AAI') {
                a.ownerid = AXA_TECHNICAL_USER_ID;
                system.debug('++++++++++++++++++++++ NEW OWNER:'+a.ownerid);
            }
            //MOSCATELLI_M 04042016: EVO46-----START
            /*else if((a.TECH_COMPANY__C == 'MPS' || a.TECH_COMPANY__C == 'Quadra') && String.isBlank(a.Account__c))
            {
              	AMPSClaims.add(a);  
            }*/
            //MOSCATELLI_M 04042016: EVO46-----END            
        }        
        //MOSCATELLI_M 04042016: EVO46-----START
        /*if(!AMPSClaims.isEmpty())
			AMPSClaimManagement.FindPolicyHolder(AMPSClaims);*/
        //MOSCATELLI_M 04042016: EVO46-----END
    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
    
        List<Claim__c> rList = (List<Claim__c>) soList;
        Map <id,Claim__c> mapaOld = new Map <id,Claim__c> ((List<Claim__c>) oldSoList);

        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        //List<Claim__c> AMPSClaims = new list<Claim__c>();//MOSCATELLI_M 04042016: EVO46 
        
         //CHANGE OWNER FOR AXA ASSICURAZIONI 
        for(Claim__c a : rList)
        {
            //Se sto nascondendo il claim allora rimuovo i nodi
            if(a.isHidden__c == true && mapaOld.get(a.id).isHidden__c == false){
                a.Nodes__c = '';
            }else if (mapaOld.get(a.id).isHidden__c == true && a.isHidden__c == false && String.isBlank(a.Nodes__c) && profileName == 'System Administrator') {
                a.addError('Contestualmente all\'impostazione del flag isHidden=false � necessario popolare il campo Nodes');
            } else if (a.isHidden__c == true && profileName != 'System Administrator') {
                a.isHidden__c = false;
            }

            if (a.TECH_COMPANY__C == 'AAI') {
                a.ownerid = AXA_TECHNICAL_USER_ID;
                system.debug('++++++++++++++++++++++ NEW OWNER:'+a.ownerid);
            }
            /*
            //MOSCATELLI_M 04042016: EVO46-----START
            else if((a.TECH_COMPANY__C == 'MPS' || a.TECH_COMPANY__C == 'Quadra') && String.isBlank(a.Account__c))
            {
              	AMPSClaims.add(a);  
            }*/
            //MOSCATELLI_M 04042016: EVO46-----END             
        }
        /*//MOSCATELLI_M 04042016: EVO46-----START  
        if(!AMPSClaims.isEmpty())
			AMPSClaimManagement.FindPolicyHolder(AMPSClaims);
        //MOSCATELLI_M 04042016: EVO46-----END*/
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
        //List<Claim__c> rList = (List<Claim__c>) soList;
        
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            if (!String.isBlank((String)sObj.get('Nodes__c'))) {
            mapSObj.put(sObj.id, sObj); 
            }
        } 
        
        //SHARING 
        if (!mapSObj.keySet().isEmpty()) {
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        }
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
        //List<Claim__c> rList = (List<Claim__c>) soList;

        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (Integer i=0; i<soList.size(); i++)
        {
            if ((String)oldSoList[i].get('Nodes__c') != (String)soList[i].get('Nodes__c')) {
            mapSObj.put(soList[i].id, soList[i]); 
            }
        } 
        
        //SHARING 
        if (!mapSObj.keySet().isEmpty()) {
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        }
    }  
    
    public void afterDelete(List<SObject> soList)
    {  

    }
    
    public void afterUndelete(List<SObject> soList)
    { 
        //List<Claim__c> rList = (List<Claim__c>) soList;
        
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
        } 
        
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);

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