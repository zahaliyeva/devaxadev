/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         StoricoConversazioniManagement
Description:   Apex class used to execute all the logics internal to the 
trigger related to the Storico_conversazioni__c object

History

08/11/2018     Created 
-------------------------------------------------------------------------------------------*/
public class StoricoConversazioniManagement {

    
    public static void afterInsert(List<Storico_conversazioni__c> stoConvList, Map<String,Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecCASENameToDevelopername)
    {
    	Set<Id> caseIdSet = new Set<Id>();
    	Set<String> caseWithTaskCall = new Set<String>(); 
    	Set<String> RecordTypeSet = new Set<String>();
    	List<Case> casesToUpdate = new List<Case>();
    	Set<String> caseToCheck = new Set<String>(); 
    	List<String> admittedStatusListOCR = new List<String>();
        List<Case> caseNMAList = new List<Case>();
        Map<Id, List<Storico_conversazioni__c>> CaseStoConvMap = new Map<Id, List<Storico_conversazioni__c>>();
        if(MPS_Code_Variables__c.getValues('CaseManagement_CaseStatus_OCR')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('CaseManagement_CaseStatus_OCR').value__c))
            {
                for(String s:(MPS_Code_Variables__c.getValues('CaseManagement_CaseStatus_OCR').value__c).split(';'))
                {
                    admittedStatusListOCR.add(s);                
                }
            }
        }
    	Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                                    HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                                    HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c 
                                                    FROM Modello_di_Assistenza__mdt 
                                                    WHERE DeveloperName  = 'ProfileManagement'
                                                    LIMIT 1];
    	if(mdAss!=null)
        {
        	if(String.isNotBlank(mdAss.CaseTriggerRecordType__c))
        	{
                for(String s:mdAss.CaseTriggerRecordType__c.split(';'))
                {
                    RecordTypeSet.add(s);  
                } 
        	}
    	}
    	for(Storico_conversazioni__c stoConv : stoConvList)	  
    	{
    		caseIdSet.add(stoConv.Connected_case__c);
    	}
    	List<Case> caseList = [SELECT Id, Status, RecordTypeId, Origin, Phone_Call_Ids__c FROM Case WHERE Id IN:caseIdSet];
    	List<Storico_conversazioni__c> storicoConvList = [SELECT Id, Connected_case__c, Profilo_utente__c, Type__c, CaseStatus__c
    														FROM Storico_conversazioni__c WHERE Connected_case__c IN:caseIdSet];
    	for(Storico_conversazioni__c stCnv : storicoConvList)
    	{
    		if(CaseStoConvMap.containsKey(stCnv.Connected_case__c))
  			{
				List<Storico_conversazioni__c> CaseStoConvList = CaseStoConvMap.get(stCnv.Connected_case__c);
				CaseStoConvList.add(stCnv);
				CaseStoConvMap.put(stCnv.Connected_case__c, CaseStoConvList);
  			} 
  			else 
  			{
    			CaseStoConvMap.put(stCnv.Connected_case__c, new List<Storico_conversazioni__c> { stCnv }); 
  			}
    	}
    	system.debug('MapRecCASENameToDevelopername: '+MapRecCASENameToDevelopername);
    	system.debug('MapCaseRecordType: '+MapCaseRecordType);
    	for(Case cs:caseList)
    	{
		 	if(RecordTypeSet.contains(MapRecCASENameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
    		{
    			if(		((cs.Origin == 'Chat' || cs.Origin == 'Portale Assistenza')
    					&&  String.isBlank(cs.Phone_Call_Ids__c) )
    					|| 
                       	(cs.Origin == 'Phone' 
                        && String.isNotBlank(cs.Phone_Call_Ids__c)
                        && (cs.Phone_Call_Ids__c.indexOf('|')==-1) ) 
                    )
				{
            		caseNMAList.add(cs);
				}
    		}
    	}
    	system.debug('caseNMAList: '+caseNMAList);
    	if(!caseNMAList.isEmpty())
    	{
	 		for(Task t : [SELECT Id, WhatId, Tipo_Attivit__c
                          FROM Task 
                          WHERE WhatId IN:caseNMAList 
                          AND Tipo_Attivit__c =: AP_Constants.Tipo_Attivit_Log_a_Call
                          AND What.RecordType.Name = :AP_Constants.rtTaskAssistenzaAgentiName ])
            {
            	caseWithTaskCall.add(t.WhatId);
            }
    	}
    	for(Case cs:caseNMAList)
    	{
    		if(!caseWithTaskCall.contains(cs.Id) )
    		{
    			caseToCheck.add(cs.Id);
    		}
    		
    	}
    	for(Storico_conversazioni__c stoConv : stoConvList)
    	{
    		system.debug('caseToCheck: '+caseToCheck);
    		system.debug('stoConv: '+stoConv);
    		Boolean checkOCR = false;
    		if( admittedStatusListOCR.contains(stoConv.CaseStatus__c)
    			&& stoConv.Profilo_utente__c == AP_Constants.rtstoConvAgente 
    			&& caseToCheck.contains(stoConv.Connected_case__c))  
            {
            	if(CaseStoConvMap.containsKey(stoConv.Connected_case__c))
            	{
	            	for(Storico_conversazioni__c AllstCnv : CaseStoConvMap.get(stoConv.Connected_case__c))
	            	{
	            		if(AllstCnv.Profilo_utente__c == AP_Constants.rtstoConvAgente 
	            			&& 
	            			(AllstCnv.CaseStatus__c == AP_Constants.caseStatusSoluzioneRifiutata
	            			||
	            			AllstCnv.Type__c.contains('Inserimento commento'))
                           )
	        			{
	        				checkOCR = true;
	        				break;
	        			}
	        			else
	        			{
	        				continue;
	        			}
	            	}
            	}
            	if(!checkOCR)
            	{
	                Case caseToUpdate = new Case(Id = stoConv.Connected_case__c, OCR__c = true, Case_sollecitato__c = false);
	                casesToUpdate.add(caseToUpdate);
            	}
            }
    	}
    	try
    	{
    		update casesToUpdate;
    	}
    	catch(Exception ex)
    	{
    		system.debug('Error: '+ex.getMessage());
    	}
    }
    
}