/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         StoricoConversazioniHandler
Description:   Trigger Handler for the Storico_conversazioni__c SObject. This class implements 
               the ITrigger interface to help ensure the trigger code is bulkified and all in
               one place.  

History

16/08/2018     Created 
-------------------------------------------------------------------------------------------*/
public with sharing class StoricoConversazioniHandler implements ITrigger
{     
    public final String objectShare = 'Storico_conversazioni__Share';  
    public final String parentId = 'ParentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Agency_Code__c';
    public final Map<String, String> MapSCRecordType = new Map<String, String> ();
    //OAVERSANO 08/11/2018 Nuovo Modello di Assistenza OCR -- START
    public final Map<String, Schema.RecordTypeInfo> MapCaseRecordType = new Map<String, Schema.RecordTypeInfo> ();
    public final Map<String,String> MapRecCASENameToDevelopername = new Map<String,String>();
    //OAVERSANO 08/11/2018 Nuovo Modello di Assistenza OCR -- END
    
    public StoricoConversazioniHandler()
    {
        String[] types;
        types = new String[]{'Storico_conversazioni__c'}; 
        List<Schema.DescribeSobjectResult> results;
        results = Schema.describeSObjects(types); 

        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapSCRecordType.put(ri.getRecordTypeId(), ri.getDeveloperName());
        }
        
        
        //OAVERSANO 08/11/2018 Nuovo Modello di Assistenza OCR -- START
        String[] casetypes = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> caseresults = Schema.describeSObjects(casetypes); 
        for(Schema.RecordTypeInfo ri: caseresults[0].getRecordTypeInfos()) 
        { 
            MapCaseRecordType.put(ri.getRecordTypeId(), ri);
            MapRecCASENameToDevelopername.put(ri.getName(), ri.getDeveloperName());
        }
        /*MapRecCASENameToDevelopername.put('Sinistri Danni Banca','Sinistri_Danni_Banca');
        MapRecCASENameToDevelopername.put('Motor','Motor');
        MapRecCASENameToDevelopername.put('Non Motor','NonMotor');
        MapRecCASENameToDevelopername.put('Axa Assicurazioni','Axa_Assicurazioni');
        MapRecCASENameToDevelopername.put('Quadra','Quadra');  
        MapRecCASENameToDevelopername.put('AMPS Financial','AMPS_Financial');
        MapRecCASENameToDevelopername.put('Family Protect','Family_Protect');
        MapRecCASENameToDevelopername.put('Close the loop','Close_the_loop');
        MapRecCASENameToDevelopername.put('Buon Lavoro','Buon_Lavoro');
        MapRecCASENameToDevelopername.put('Assistenza Agenti','Assistenza_Agenti');
        MapRecCASENameToDevelopername.put('Caring Angel','Caring_Angel');
        MapRecCASENameToDevelopername.put('Agenzia dipendenti','Agenzia_dipendenti'); //OAVERSANO 09/01/2019 : Agenzia diretta
        MapRecCASENameToDevelopername.put('Reclamo','Reclamo'); //OAVERSANO 15/01/2019 : Gestione Reclami*/
        //OAVERSANO 08/11/2018 Nuovo Modello di Assistenza OCR -- END
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
        List<Storico_conversazioni__c> rList;
        rList = (List<Storico_conversazioni__c>) soList;
 
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
       
        for (SObject sObj : soList)
        {
            String rtype = (String)sObj.get('RecordTypeId');

            system.debug('@@rt: '+MapSCRecordType.get(rtype));

            if(MapSCRecordType.get(rtype) == 'Agente')
                mapSObj.put(sObj.id, sObj); 
        } 

        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);      
        //OAVERSANO 08/11/2018 : Nuovo Modello di Assistenza OCR -- START
        StoricoConversazioniManagement.afterInsert(rList, MapCaseRecordType, MapRecCASENameToDevelopername);
        //OAVERSANO 08/11/2018 : Nuovo Modello di Assistenza OCR -- END
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
       
    }  
    
    public void afterDelete(List<SObject> soList)
    {  

    }
    
    public void afterUndelete(List<SObject> soList){ 
 
       
    }

    public void andFinally(){  

    }      
}