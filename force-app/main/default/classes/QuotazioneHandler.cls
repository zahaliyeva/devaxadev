/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
* Class QuotazioneHandler
*  
* Trigger Handler for the Quotazione__c SObject. This class implements the ITrigger  
* interface to help ensure the trigger code is bulkified and all in one place.  
*/ 

public with sharing class QuotazioneHandler implements ITrigger  
{     
    
    // Member variable to hold the Id's of Relationship__c 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    
    public final String objectShare = 'Quotazione__Share';  
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Main_Node__c';    
    
    //public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c;  
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();   
    
    // Constructor  
    public QuotazioneHandler()
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
        system.debug('+++++++++++++++++++++++++++++++MyquotationstoShare'+soList);
        //List<Quotazione__c> Quotazioni = (List<Quotazione__c>) soList;
        List<SObject> QuotazioniLead = new List<SObject>();
        List<SObject> QuotazioniOpp = new List<SObject>();
        List<Id> QuotazioniLeadIds = new List<Id>();
        Map<Id,Id> IdOppsQuots = new Map<Id,Id>();
        List<Id> IdOpps = new List<Id>();
        List<Opportunity> OppstoUpdate = new List<Opportunity>();
        
        
        for(integer i=0; i<soList.size(); i++)
        {    
            system.debug('*o*o*o*'+soList.get(i).get('Agency_Code__c'));
            
            if (soList.get(i).get('Lead__c') != '' && soList.get(i).get('Lead__c') != null )
            {       
                QuotazioniLead.add(soList.get(i));
                QuotazioniLeadIds.add(soList.get(i).Id);
                
            }
            
            if (soList.get(i).get('Opportunity__c') != '' && soList.get(i).get('Opportunity__c') != null)
            {
                QuotazioniOpp.add(soList.get(i));
            }
            
        }
        
        if(QuotazioniLead.size()>0 && QuotazioniOpp.size()==0){
            
            Map<Id,sObject> mapSObj = new Map<Id,sObject>();
            for (SObject sObj : QuotazioniLead)
            {
                mapSObj.put(sObj.id, sObj); 
            } 
            
            //SHARING 
            //T. SERGER - 11/05/2018 - Sharing method is switched to the one on QuotationManagement
            //RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);

            if(!System.isBatch()){
                set<Id> quotazioniID = new set<Id>();
                for (SObject myQ : QuotazioniLead)
                    quotazioniID.add(myQ.Id);
                
                QuotationManagement.ShareWithFullAgency(quotazioniID);
            }
            
            else
                QuotationManagement.ShareWithFullAgency(QuotazioniLead);
            
            //END -- T. SERGER - 11/05/2018
            
            
            //shareRecordBasedOnFieldFuture - dismissed
            /*  String sObjectTypeFuture = 'Quotazione__c';
                Set<Id> setSObj = new Set<Id>();
                for (SObject sObj : QuotazioniLead)
                {
                setSObj.add(sObj.id); 
                } 

                //SHARING 
                RecordSharing.shareRecordBasedOnFieldFuture(setSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups,sObjectTypeFuture);
            */            
            //Queueable method - dismissed
            //QuotazioniSharingQueueable ShareQuotazioni = new QuotazioniSharingQueueable(QuotazioniLead); dismissed because exceeding queueable limits
            //Id ShareQuotazioniJobId = System.enqueueJob(ShareQuotazioni);
            
            //QuotationManagement.ShareWithFullAgency(QuotazioniLeadIds); ShareWithFullAgency method @future: dismissed
            
            
        }
        
        if(QuotazioniOpp.size()>0){
            
            
            
            Map<Id,sObject> mapSObj = new Map<Id,sObject>();
            for (SObject sObj : QuotazioniOpp)
            {
                mapSObj.put(sObj.id, sObj); 
            } 
            
            //SHARING 
            RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
            
            List<Quotazione__c> MyQuotswOppList = (List<Quotazione__c>) QuotazioniOpp;
            
            for(Quotazione__c quot: MyQuotswOppList){
                
                IdOpps.add(quot.Opportunity__c);
                IdOppsQuots.put(quot.Opportunity__c,quot.Id);
                
            }
            
            OppstoUpdate = [SELECT Id,Quotazione__c FROM Opportunity WHERE Id IN: IdOpps];
            
            for(Opportunity opp: OppstoUpdate){
                
                string Idquot = IdOppsQuots.get(opp.Id);
                system.debug('***********IDQUOT'+Idquot);
                opp.Quotazione__c = Idquot;
                
            }
            
            List<Database.SaveResult> SaveResult = Database.update(OppstoUpdate,false);
            system.debug('+++++++++++++++SAVERESULT'+SaveResult);
            
        }
        
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
        
        system.debug('+++++++++++++++++++++++++++++++MyquotationstoShare'+soList);
        //List<Quotazione__c> Quotazioni = (List<Quotazione__c>) soList;
        List<Id> QuotazioniLeadIds = new List<Id>();
        List<SObject> QuotazioniLead = new List<SObject>();
        List<SObject> QuotazioniOpp = new List<SObject>();
        
        for(integer i=0; i<soList.size(); i++)
        {
            if (soList.get(i).get('Lead__c') != '' && soList.get(i).get('Lead__c') != null )
            {         
                QuotazioniLead.add(soList.get(i));
                QuotazioniLeadIds.add(soList.get(i).Id);
                
            }
            
            if (soList.get(i).get('Opportunity__c') != '' && soList.get(i).get('Opportunity__c') != null)
            {
                QuotazioniOpp.add(soList.get(i));
            }
            
        }
        
        system.debug('èèèèè'+QuotazioniLead);
        system.debug('ààààà'+QuotazioniOpp);

            
            
        if(QuotazioniLead.size()>0 && QuotazioniOpp.size()==0){
            
            
            Map<Id,sObject> mapSObj = new Map<Id,sObject>();
            for (SObject sObj : QuotazioniLead)
            {
                mapSObj.put(sObj.id, sObj); 
            } 
            
            //SHARING 
            //START -- T. SERGER - 11/05/2018 - Sharing method is switched to the one on QuotationManagement
            //RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
            
            if(!System.isBatch()){
                set<Id> quotazioniID = new set<Id>();
                for (SObject myQ : QuotazioniLead)
                    quotazioniID.add(myQ.Id);
                
                QuotationManagement.ShareWithFullAgency(quotazioniID);
            }
            
            else
                QuotationManagement.ShareWithFullAgency(QuotazioniLead);
            
            //END -- T. SERGER - 11/05/2018
            
            //shareRecordBasedOnFieldFuture - dismissed 
            /* String sObjectTypeFuture = 'Quotazione__c';
                Set<Id> setSObj = new Set<Id>();
                for (SObject sObj : QuotazioniLead)
                {
                setSObj.add(sObj.id); 
                } 

            //SHARING 
            RecordSharing.shareRecordBasedOnFieldFuture(setSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups,sObjectTypeFuture);
           */
            
            //Queueable method - dismissed
            //QuotationManagement.ShareWithFullAgency(QuotazioniLeadIds); ShareWithFullAgency method used @future: dismissed
            
            //QuotazioniSharingQueueable ShareQuotazioni = new QuotazioniSharingQueueable(QuotazioniLead); queueable method dismissed because exceeding queueable limits
            
            /*if( Limits.getQueueableJobs() == 0){

                Id ShareQuotazioniJobId = System.enqueueJob(ShareQuotazioni);

            }*/
            
            
            
        }
        
        if(QuotazioniOpp.size()>0){
            
            List<Quotazione__c> rList = (List<Quotazione__c>) soList;
            
            Map<Id,sObject> mapSObj = new Map<Id,sObject>();
            for (SObject sObj : QuotazioniOpp)
            {
                mapSObj.put(sObj.id, sObj); 
            } 
            
            //SHARING 
            RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        }
        
    }  
    
    public void afterDelete(List<SObject> soList)
    {  
        
        
        //SHARING NOT NEEDED HERE
        
        
        
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