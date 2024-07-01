public with sharing class StoricoChiamateHandler implements ITrigger  
{     
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    
    public final String objectShare = 'Storico_Chiamate__Share';  
    public final String parentId = 'ParentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read'; 
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Account_Nodes__c';  
    
      // Constructor  
    public StoricoChiamateHandler()
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
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();

        //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- START
        Set<String> ImportantCalls = new Set<String>();
        Integer counter = 0;
        //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- END

        for (SObject sObj : soList)
        {
            mapSObj.put(sObj.id, sObj); 

            //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- START
            if((sObj.get('Email_Modified__c')<>oldSoList[counter].get('Email_Modified__c')) ||
               (sObj.get('Phone_Modified__c')<>oldSoList[counter].get('Phone_Modified__c')) ||
               (sObj.get('Address_Modified__c')<>oldSoList[counter].get('Address_Modified__c')))
            {
                ImportantCalls.add((String)sObj.get('Id'));
            }
            counter++;
            //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- END
        } 
        
        if(!mapSObj.isEmpty())         
            RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);            
    
        //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- START
        if(ImportantCalls.size()>0)
            StoricoChiamateManagement.HistoricizeCall(ImportantCalls);
        //MOSCATELLI_M 11/12/2018: Accesso a registrazioni audio -- END
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