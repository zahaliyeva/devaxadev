/*------------------------------------------------------------------------
Author:        --
Company:       --
Class:         PolizzaHandler_Helper
Description:   Class for avoiding duplicate CODE on trigger and Batch LIKE Before or After INSERT, class
               used by batch and trigger 

ND:             Importan 

29/11/2021     Created - *-+
----------------------------------------------------------------------------*/
public with sharing class PolizzaHandler_Helper {
  
    // Member variable to hold the Id's of Polizza 'in use'  
    private Set<Id> RecordsInUse = new Set<Id>();


    public final String objectShare = 'InsurancePolicy__Share';
    public final String parentId = 'parentId';
    public final String rawCause = 'Manual';
    public final String accessLevelName = 'AccessLevel';
    public final String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Nodes__c';

    
    
    public final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();

    public PolizzaHandler_Helper() {

    }

    public List<InsurancePolicy__c> BeforeOperationsPolizza (List<InsurancePolicy__c> scope){
        System.debug('Into Before Operations with -'+scope.size()+'-records to process');
        List<InsurancePolicy__c> policiesForAfterOperations = new List<InsurancePolicy__c>();
        try{
            //CHANGE OWNER FOR AXA ASSICURAZIONI 
            for(InsurancePolicy__c polizzaTemp : scope)
            {
               
                if (polizzaTemp.TECH_COMPANY__C == 'AAI') {
                    polizzaTemp.ownerid = AXA_TECHNICAL_USER_ID;
                    system.debug('++++++++++++++++++++++ NEW OWNER:'+polizzaTemp.ownerid);

                    policiesForAfterOperations.add(polizzaTemp);
                }
            }
            
            
            
        }catch(Exception e){
            System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
        }
        return policiesForAfterOperations;
    }
    
   	
    public void AfterOperationsPolizza(List<InsurancePolicy__c> scope){
            System.debug('Into After Operations with -'+scope.size()+'-records to process');
        try{ 
            Map<Id,sObject> mapSObj = new Map<Id,sObject>();
            for (InsurancePolicy__c polizzaTemp : scope)
            {
                mapSObj.put(polizzaTemp.id, polizzaTemp);
            }
    
            //SHARING 
            RecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
    
        }catch(Exception e){
            System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
            }
    }
}