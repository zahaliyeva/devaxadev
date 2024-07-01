/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class CampaignMemberHandler  

 *  

 * Trigger Handler for the Account SObject. This class implements the ITrigger  

 * interface to help ensure the trigger code is bulkified and all in one place.  

 */ 

public with sharing class CampaignMemberHandler implements ITrigger  

{     

    // Constructor  
    public static boolean DeactivateTrigger = false;

    public CampaignMemberHandler()  
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
    system.debug('+++++++bulkbeforeCampaignMemberHandler');
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
        user userRun = new user();
        userRun = [SELECT Profile.Name FROM User WHERE  Id =: Userinfo.getUserId()];
        system.debug('+++++++userRun.Profile.Name='+userRun.Profile.Name);
        
        
        Set<String> ProfilesNotAllowedToDeleteCM = new Set<String>();
        // at the moment no AAI Profile is allowed to delete CM
        ProfilesNotAllowedToDeleteCM.add('AAI - Digital Avanzato');
        ProfilesNotAllowedToDeleteCM.add('AAI - Digital Consultazione');
        ProfilesNotAllowedToDeleteCM.add('AAI - Dipartimento Avanzato');
        ProfilesNotAllowedToDeleteCM.add('AAI - Distribuzione Avanzato');
        //ProfilesNotAllowedToDeleteCM.add('AAI - Marketing Avanzato'); BOVOLENTA_D 11042018 Marketing users are now allowed to delete some CMs
        ProfilesNotAllowedToDeleteCM.add('AAI - Marketing Consultazione');
        ProfilesNotAllowedToDeleteCM.add('AAI - Vendite Avanzato');
        ProfilesNotAllowedToDeleteCM.add('AAI - Vendite Base');
        
        system.debug('++++++Profiles NOT allowed'+ProfilesNotAllowedToDeleteCM);
        
        system.debug('++++++checkProfilePermission'+ProfilesNotAllowedToDeleteCM.contains(userRun.Profile.Name));

        if (ProfilesNotAllowedToDeleteCM.contains(userRun.Profile.Name))
        {
            for (Sobject so : soList )
            {
                so.adderror('Impossibile eliminare il membro campagna, non si dispone dei permessi necessari');
            }
        }
    } 

    public void afterInsert(SObject so)  
    {  
    
    }  


    public void afterInsert(List<SObject> soList)
    {

        //D.F. QuickEvo3 START
        //NOT SCALABLE, DISMISSED
        //List<CampaignMember> ListCM = (List<CampaignMember>) soList;
        //CampaignMemberManagement.traceActiveCampaignOnAccount(ListCM) ;     
        //D.F. QuickEvo3 END
        Map<Id,sObject> mapSObjContact = new Map<Id,sObject>();

        for (SObject sObj : soList)
        {
        system.debug('sObj: '+sObj);            
            if(!String.isEmpty(''+sObj.get('ContactId')))
            {
                system.debug('ContactId: '+''+sObj.get('ContactId'));
                mapSObjContact.put(sObj.id, sObj);
            }
 
        }

        CampaignMemberManagement.createCommunicationBounceEvents((List<CampaignMember>) mapSObjContact.values());
    } 
       

    public void afterUpdate(SObject oldSo, SObject so)  
    {

    }  

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)  
    {
    //CampaignMemberManagement.stampDateStatusToAccount(ListCM) ;
        Map<Id, CampaignMember> oldMap = new Map<Id, CampaignMember>();
        List<CampaignMember> cmList = (List<CampaignMember>) oldSoList;
        for(CampaignMember cm : cmList){
            oldMap.put(cm.Id, cm);
        }

        cmList = new List<CampaignMember>();
        for(CampaignMember cm : (List<CampaignMember>) soList){
            if(oldMap != null && oldMap.containsKey(cm.Id) && oldMap.get(cm.Id).Sottostato__c != null &&  
                (//oldMap.get(cm.Id).Sottostato__c.equals('Email non recapitabile') || 
                oldMap.get(cm.Id).Sottostato__c.equals('SMS non recapitabile')) && !String.isEmpty(cm.ContactId)){
                cmList.add(cm);
            }
        }
        
        if(cmList.size() != 0){
            CampaignMemberManagement.createCommunicationBounceEvents(cmList);
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