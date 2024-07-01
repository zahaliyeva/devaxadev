/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         FeedbackHandler
Description:   Apex class trigger whose purpose is to 
               recalculate the visibility of the feedbacks of Record
               Type 'AAI Feedback' to those users who have the visibility
               on the customer to which the feedback refers to  

History

18/01/2016     Created - F.M.
----------------------------------------------------------------------------*/


/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
 * Class FeedbackHandler  
 *  
 * Trigger Handler for the Feedback SObject. This class implements the ITrigger  
 * interface to help ensure the trigger code is bulkified and all in one place.  
 */ 

public with sharing class FeedbackHandler implements ITrigger  
{     

    // Member variable to hold the Id's of Feedback 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();  
    
    /*
    public final String objectShare = 'Feedback__Share';  
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroupForCustomerFeedbacks ='TECH_Account_Nodes__c';  
    
    public final Recordtype feedbackRecordTypeId = [select id FROM recordtype WHERE developername='AAI_Feedback' limit 1];  
    
    */
    //MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza -- START
    public final String objectShare = 'Feedback__Share';  
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroupForAgentFeeback ='Agency_Code__c';
    //MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza -- END
    //DANTONIO_M 21/01/2019: modifica sharing feedback - START
    public final String fieldNameOfGroupForCustomerFeedback ='AAI_Nodes_or_Agency__c';//BOVOLENTA_D 19112018 Customer History
    //DANTONIO_M 21/01/2019: modifica sharing feedback - END

    public Map<String, String> MapFdbckRecordType = new Map<String, String> ();//MMOSCATELLI 15/02/2017: Close the loop ICF    
    
    //public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c;  
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();   
    
    // Constructor  
    public FeedbackHandler()
    {  
        //MMOSCATELLI 15/02/2017: Close the loop ICF -- START
        String[] types = new String[]{'Feedback__c'};
            
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 
        
        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapFdbckRecordType.put(ri.getName(), ri.getRecordTypeId());
        }
        system.debug('##MapFdbckRecordType: '+MapFdbckRecordType);        
        //MMOSCATELLI 15/02/2017: Close the loop ICF -- END
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
        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
        List<Feedback__c> FeedbackList = soList;
        String AgencyCode='';
        Integer CodeLenght=0;
        Integer i=0;
        Map<ID, ID> MapAccountContact = new Map<ID,ID>();
        
        //*-+ 24-01-2022 Map of labels of Survey Origin to avoid use API names
        Map <String,String> originLabels = new Map<String,String>();
        originLabels = UtilityClass.getPicklistValue(new feedback__c(), 'Survey_Origin__c');
        
        List<ID> AccountIDList = new List<ID>();
        for(SObject c : soList){
            if(c.get('Account__c') != null)
            	AccountIDList.add((ID)c.get('Account__c'));

            //#id-278 cambiar il origin d SandSIV per il Label on Survey_origin picklist *-+ 24-01-2022
            if(String.isNotBlank((String)c.get('Survey_Origin__c')) && originLabels.containsKey((String)c.get('Survey_Origin__c')))
             c.put('Survey_Origin__c',originLabels.get((String)c.get('Survey_Origin__c')));
   
        }
        for(Contact c : [Select id, AccountId from contact where AccountId in :AccountIDList]){
            if(!MapAccountContact.containsKey(c.AccountId)){
                MapAccountContact.put(c.AccountId, c.ID);
            }
        }
        for(SObject c : soList)
        {
            AgencyCode = (String)c.get('Agency_Code__c');

            if(String.isNotBlank(AgencyCode))
            {
                if(AgencyCode.length()<6)
                {
                    CodeLenght = AgencyCode.length();

                    for(i=0;i<6-CodeLenght;i++)
                    {
                        AgencyCode = '0'+AgencyCode;
                    }
                }
            }
            AgencyCode = (String)c.put('Agency_Code__c',AgencyCode);
            system.debug('@@AgencyCode: '+AgencyCode);
            if(c.get('Account__c') != null && MapAccountContact.containsKey((ID)c.get('Account__c'))){
                c.put('TECH_PersonContactID__c',String.valueOf(MapAccountContact.get((ID)c.get('Account__c'))));
        }
        }
        
        
        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
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
        //MMOSCATELLI 09/02/2017: Close the loop ICF -- START
        Set<String> CustIdentifier = new Set<String>();        
        Set<String> FeedbackSet = new Set<String>();        
        //MMOSCATELLI 09/02/2017: Close the loop ICF -- END
        
        //OAVERSANO 09/07/2017: Close the loop ICF -- START
        Set<String> emailIdentifier = new Set<String>();        
        Set<String> phoneIdentifier = new Set<String>();  
        //OAVERSANO 09/07/2017: Close the loop ICF -- END
        
        
        List<Feedback__c> rList = (List<Feedback__c>) soList;
 
        Map<Id,sObject> mapSObjFromAgents = new Map<Id,sObject>();
        Map<Id,sObject> mapSObjFromCustomers = new Map<Id,sObject>();

        for (SObject sObj : soList)
        {
             //MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza -- START                    
            //BOVOLENTA_D 19112018 Customer History START
            String agentCreator = (String)sObj.get('Agent_ID__c');
            if(agentCreator!= null &&agentCreator!= '' ){
                mapSObjFromAgents.put(sObj.id, sObj); 
            }else{
                mapSObjFromCustomers.put(sObj.id, sObj); 
            }
            //BOVOLENTA_D 19112018 Customer History END
            //MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza -- END
            
            //MMOSCATELLI 09/02/2017: Close the loop ICF -- START

            //MMOSCATELLI 09/06/2017: EVO 86 --START
            //if((Id)sObj.get('RecordTypeId') == MapFdbckRecordType.get(Ap_Constants.rtClaimSurveyFeedback))
            if((Id)sObj.get('RecordTypeId') == MapFdbckRecordType.get(Ap_Constants.rtClaimSurveyFeedback) ||
                (Id)sObj.get('RecordTypeId') == MapFdbckRecordType.get(Ap_Constants.rtChatSurveyFeedback)||
                (Id)sObj.get('RecordTypeId') == MapFdbckRecordType.get('General Feedback') ||
                //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                (Id)sObj.get('RecordTypeId') == MapFdbckRecordType.get(Ap_Constants.rtAcquistoSurveyFeedback) 
                //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                )
            //MMOSCATELLI 09/06/2017: EVO 86 --END

            {
                //MMOSCATELLI 09/06/2017: EVO 86 --START
                if((Id)sObj.get('RecordTypeId') == MapFdbckRecordType.get(Ap_Constants.rtChatSurveyFeedback)||
                (Id)sObj.get('RecordTypeId') == MapFdbckRecordType.get('General Feedback'))
                {
                    system.debug('##Feedback Origin is Chat or Email');

                    if(String.isBlank((String)sObj.get('Agency_Code__c')))
                    {
                        if(String.isNotBlank((String)sObj.get('FeedbackComments__c')) &&
                            Integer.valueOf((Decimal)sObj.get('AverageRating__c'))<=6)
                        {
                            FeedbackSet.add(Json.serialize((Feedback__c)sObj));
                        }
                    }
                }
                else
                {
                    system.debug('##Feedback Origin is SandSIV');

                    FeedbackSet.add(Json.serialize((Feedback__c)sObj));
                               
                    if(String.isNotBlank((String)sObj.get('NDG__c')))
                        CustIdentifier.add((String)sObj.get('NDG__c'));
                    
                    if(String.isNotBlank((String)sObj.get('Fiscal_ID__c')))
                        CustIdentifier.add((String)sObj.get('Fiscal_ID__c'));
                    
                    //OAVERSANO 09/07/2017: Close the loop ICF -- START
                    if(String.isNotBlank((String)sObj.get('Mobile_Phone__c')))
                        phoneIdentifier.add((String)sObj.get('Mobile_Phone__c'));        
                    if(String.isNotBlank((String)sObj.get('Email__c')))
                        emailIdentifier.add((String)sObj.get('Email__c'));  
                    //OAVERSANO 09/07/2017: Close the loop ICF -- END
                }
                //MMOSCATELLI 09/06/2017: EVO 86 --END
            }
            //MMOSCATELLI 09/02/2017: Close the loop ICF -- END
        }
        
        //MMOSCATELLI 09/02/2017: Close the loop ICF -- START 
        system.debug('##FeedbackSet: '+FeedbackSet);             
        
        if(FeedbackSet.size()>0)
        {
            //OAVERSANO 09/07/2017: Close the loop ICF -- START
            //FeedbackManagement.CreateCase(FeedbackSet,CustIdentifier);

            FeedbackManagement.CreateCase(FeedbackSet,CustIdentifier,phoneIdentifier,emailIdentifier);             

            //OAVERSANO 09/07/2017: Close the loop ICF -- END  
        }
        //MMOSCATELLI 09/02/2017: Close the loop ICF -- END     
        
        RecordSharing.shareRecordBasedOnField(mapSObjFromAgents, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroupForAgentFeeback, separatorOfGroups);//MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza
        RecordSharing.shareRecordBasedOnField(mapSObjFromCustomers, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroupForCustomerFeedback, separatorOfGroups);//BOVOLENTA_D 19112018 Customer History START

        
        /* 
        if (!mapSObj.isEmpty()) {
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        }
        */
        
        
      /*  //ROLLUP for future use
        FeedbackManagement.RollUpAccountFeedback(rList);
        for (Feedback__c ip : rList)
        { 
            system.debug('+++++++++++Account_Nodes__c'+ip.TECH_Account_Nodes__c);
        } */
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
        //MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza -- START
        Map<Id,sObject> mapSObjFromAgents = new Map<Id,sObject>();
        Map<Id,sObject> mapSObjFromCustomers = new Map<Id,sObject>();

        for (SObject sObj : soList)
        {                  
            //BOVOLENTA_D 19112018 Customer History START
            String agentCreator = (String)sObj.get('Agent_ID__c');
            if(agentCreator!= null &&agentCreator!= '' ){
                System.debug('===> From Agents');
                mapSObjFromAgents.put(sObj.id, sObj); 
            }else{
                System.debug('===> From Customers');
                mapSObjFromCustomers.put(sObj.id, sObj); 
            }
        }
        if (!mapSObjFromAgents.isEmpty()){
            RecordSharing.shareRecordBasedOnField(mapSObjFromAgents, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroupForAgentFeeback, separatorOfGroups);//MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza
        }
        if (!mapSObjFromCustomers.isEmpty()){
            RecordSharing.shareRecordBasedOnField(mapSObjFromCustomers, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroupForCustomerFeedback, separatorOfGroups);//BOVOLENTA_D 19112018 Customer History START
        }
       //BOVOLENTA_D 19112018 Customer History END
        //MOSCATELLI_M 13/09/2018: Nuovo Modello di assistenza -- END
    /*
        List<Feedback__c> rList = (List<Feedback__c>) soList;
   
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        
        integer counterOld = 0;
        boolean FORCE_VISIBILITY_SHARE = AccountHandler.checkCSVisibility();
        String tempNodesNew = '';
        String tempNodesOld = '';
        for (SObject sObj : soList)
        {
            system.debug('++++check if visibility calc is required');
            system.debug('+++++sObj'+sObj.get('TECH_Account_Nodes__c'));
            system.debug('+++++oldSoList'+oldSoList[counterOld].get('TECH_Account_Nodes__c'));
            tempNodesNew = ''+sObj.get('TECH_Account_Nodes__c');
            tempNodesOld = ''+oldSoList[counterOld].get('TECH_Account_Nodes__c');
            
           if (sObj.get('RecordTypeId') == feedbackRecordTypeId.Id) {
            if ((!tempNodesNew.equals(tempNodesOld))  || FORCE_VISIBILITY_SHARE) {
                mapSObj.put(sObj.id, sObj); 
            } else {
                system.debug('+++++visibility skipped');
            }
            
            }
            counterOld++;
        } 
        
        if (!mapSObj.isEmpty()) {
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        
        }
        
      /*  //ROLLUP for future use
        FeedbackManagement.RollUpAccountFeedback(rList);
        for (Feedback__c ip : rList)
        { 
            system.debug('+++++++++++Account_Nodes__c'+ip.TECH_Account_Nodes__c);
        } */
       
    }  
    
    public void afterDelete(List<SObject> soList)
    {  
    /*
        List<Feedback__c> rList = (List<Feedback__c>) soList;
        
        //SHARING NOT NEEDED HERE
   
    /*    //ROLLUP for future use
        FeedbackManagement.RollUpAccountFeedback(rList);
        for (Feedback__c ip : rList)
        { 
            system.debug('+++++++++++Account_Nodes__c'+ip.TECH_Account_Nodes__c);
        } */

    }
    
    public void afterUndelete(List<SObject> soList)
    { 
    
    /*    
    List<Feedback__c> rList = (List<Feedback__c>) soList;
        
        Map<Id,sObject> mapSObj = new Map<Id,sObject>();
        for (SObject sObj : soList)
        {    
            if (sObj.get('RecordTypeId') == feedbackRecordTypeId.Id) {
            mapSObj.put(sObj.id, sObj); 
            }
        } 
        
        if (!mapSObj.isEmpty()) {
        //SHARING 
        RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        }
       
       /* //ROLLUP for future use
        FeedbackManagement.RollUpAccountFeedback(rList); 
       */
       
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