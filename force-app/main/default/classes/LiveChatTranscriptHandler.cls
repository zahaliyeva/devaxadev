public with sharing class LiveChatTranscriptHandler implements ITrigger  
{     
    private Set<Id> RecordsInUse = new Set<Id>();  

    // 23/12/2021 *-+
    public static Boolean RunTrigger = true;    

    
    public final String objectShare = 'LiveChatTranscriptShare';  
    public final String parentId = 'ParentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read'; 
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Account_Nodes__c';  
    
      // Constructor  
    public LiveChatTranscriptHandler()
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
        /*BOVOLENTA_D CONTACT HISTORY 19112018 START  
        List<LiveChatTranscript> Chats = soList;

        LiveChatTranscriptMgmt.TraceAgency(soList);
        BOVOLENTA_D CONTACT HISTORY 19112018  END */ 
    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {
        /*BOVOLENTA_D CONTACT HISTORY 19112018 START 
        List<LiveChatTranscript> Chats = soList;

        LiveChatTranscriptMgmt.TraceAgency(soList);        
        BOVOLENTA_D CONTACT HISTORY 19112018  END */ 
          //aggiornato 23-12-2021 *-+ ottimized
          system.debug('#### Entra after update listas *-+'); 

          List<LiveChatTranscript> NewrList = (List<LiveChatTranscript>) soList;
          Map<Id,sObject> mapSObj = new Map<Id,sObject>();
          List<LiveChatTranscript> LiveChatTranscriptsChangedOwner = new List<LiveChatTranscript>();
          Map <id,LiveChatTranscript> mapaOld = new Map <id,LiveChatTranscript> ((List<LiveChatTranscript>) oldSoList);
  
          for(LiveChatTranscript chatTrans_pivot : NewrList){
              //cambia il campo del record shared
              system.debug('#### Entra for owner new is -- '+String.valueOf(chatTrans_pivot.ownerid)); 
              system.debug('#### Entra for owner old is -- '+String.valueOf(mapaOld.get(chatTrans_pivot.id).CreatedById));
              
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
        
              
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();

        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 
 
        }
        if (!mapSObj.isEmpty()) 
            RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
        //aggiornato 23-12-2021 *-+ ottimized reply
        system.debug('#### Entra after update listas *-+'); 

        List<LiveChatTranscript> NewrList = (List<LiveChatTranscript>) soList;
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        Map <id,LiveChatTranscript> mapaOld = new Map <id,LiveChatTranscript> ((List<LiveChatTranscript>) oldSoList);

        for(LiveChatTranscript chatTrans_pivot : NewrList){
            if(chatTrans_pivot.Account_Nodes__c != mapaOld.get(chatTrans_pivot.id).Account_Nodes__c)
                mapSObj.put(chatTrans_pivot.id,chatTrans_pivot);
        }
   
        if(!mapSObj.isEmpty())         
            RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);            
           
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

    public void andFinally(){  

    }  
    
}