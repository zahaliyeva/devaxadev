/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         MilestoneTrackingManagement
Description:   Apex class used to execute all the logics internal to the 
trigger related to the Mileston_Tracking__c object

History

03/08/2018     Created 
-------------------------------------------------------------------------------------------*/
public without sharing class MilestoneTrackingManagement {
    
    //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START 
    public static final String HD1Role = 'HD1 IT';
	public static final String HD2Role = 'HD2 IT';
	public static final String HD1BIZRole = 'HD1 BIZ';
	public static final String HD2BIZRole = 'HD2 BIZ';
	public static final String HD1QueueRole = 'Coda HD1 IT';
  	public static final String HD2QueueRole = 'Coda HD2 IT';
  	public static final String HD1BIZQueueRole = 'Coda HD1 BIZ';
  	public static final String HD2BIZQueueRole = 'Coda HD2 BIZ';
	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
	//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
  	public static final String HD1ContabilitaRole = 'HD1 Contabilita';
  	public static final String HD1ContenziosoRole = 'HD1 Contenzioso';
  	public static final String HD1ContabilitaQueueRole = 'Coda HD1 Contabilita';
  	public static final String HD1ContenziosoQueueRole = 'Coda HD1 Contenzioso';
  	//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
	//OAVERSANO 16/11/2018 : Caring Angel -- START
	public static final String HD1CARole = 'HD1';
	public static final String HD2CARole = 'HD2';
	public static final String HD1CAQueueRole = 'Coda HD1';
  	public static final String HD2CAQueueRole = 'Coda HD2';
	//OAVERSANO 16/11/2018 : Caring Angel -- END
	//OAVERSANO 19/03/2019 : AXA Assistance -- START
	public static final String axaAssistanceRole = 'HD1 AXA Assistance';
	public static final String customerOperationRole = 'HD1 Customer Operation';
	public static final String axaAssistanceQueueRole = 'Coda HD1 AXA Assistance';
  	public static final String customerOperationQueueRole = 'Coda HD1 Customer Operation';
	//OAVERSANO 19/03/2019 : AXA Assistance -- END
	public static final String HD3Role = 'HD3';
	public static final String AgentRole = 'AGENT';
    
    public static void checkWorkingTimes(List<Milestone_Tracking__c> MlstnTrackListTrigger)
    {
    	/*	Configurazioni SLA/Case Setting */
    	String[] types = new String[]{'Case'}; 
		List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 
		Map<String, Schema.RecordTypeInfo> MapCaseRecordTypeDevName = results[0].getRecordTypeInfosByDeveloperName();
       	Set<String> RecordTypeNameSet = new Set<String>();
        Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c, // NOPMD  Fix CRUD violation
        									HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c 
        									FROM Modello_di_Assistenza__mdt 
        									WHERE DeveloperName  = 'ProfileManagement' 
        									LIMIT 1];
		if(mdAss!=null)
		{
            if(String.isNotBlank(mdAss.CaseTriggerRecordType__c))
                for(String s:mdAss.CaseTriggerRecordType__c.split(';'))
                {
                    RecordTypeNameSet.add(MapCaseRecordTypeDevName.get(s).getName());
                }
		}
		//OAVERSANO 17/10/2018 : Caring Angel -- START
		Set<String> RecordTypeNameSetCA = new Set<String>();
      	Caring_Angel__mdt caringAngel = [SELECT Id, DeveloperName, CaseTriggerRecordType__c, // NOPMD  Fix CRUD violation
                        HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c 
                        FROM Caring_Angel__mdt 
                        WHERE DeveloperName  = 'ProfileManagement' 
                        LIMIT 1];
  		if(caringAngel!=null)
  		{
   		  	if(String.isNotBlank(caringAngel.CaseTriggerRecordType__c))
                for(String s:caringAngel.CaseTriggerRecordType__c.split(';'))
                {
                    RecordTypeNameSetCA.add(MapCaseRecordTypeDevName.get(s).getName());
                }
  		}
  		//OAVERSNAO 17/10/2018 : Caring Angel -- END
  		//OAVERSANO 19/03/2019 : AXA Assistance -- START
		Set<String> RecordTypeNameSetSinistri = new Set<String>();
      	List<Assistenza_sinistri__mdt> assSinList = [SELECT Id, DeveloperName, Value__c // NOPMD  Fix CRUD violation
                            FROM Assistenza_sinistri__mdt 
                            WHERE DeveloperName LIKE 'claimProfileManagement%' 
                            ];
            
            for(Assistenza_sinistri__mdt assSin : assSinList)
            {
	      		if(assSin.DeveloperName == 'claimProfileManagementRecordTypes')
	      		{
	      			if(String.isNotBlank(assSin.Value__c))
	              	{
	                  	for(String s:assSin.Value__c.split(';'))
	                  	{
	                      	RecordTypeNameSetSinistri.add(MapCaseRecordTypeDevName.get(s).getName());
	                  	}
	              	}
	      		}
            }
  		//OAVERSNAO 19/03/2019 : AXA Assistance -- END
		Map<String, Configurazione_SLA_Case__c> confSLACaseMap = new Map<String, Configurazione_SLA_Case__c>();
		List<Configurazione_SLA_Case__c> SLAConfList = [SELECT Category__c, Sub_Category__c, Case_Origin__c, // NOPMD  Fix CRUD violation
														Customer_Service_Type__c, Distribution_Network__c, SLA__c,
														Case_Record_Type__c,
														(SELECT Id, User_Role__c, SLA__c 
		        										FROM Configurazioni_SLA_Case_HD2__r)
														FROM Configurazione_SLA_Case__c 
														WHERE Rule_Active__c = true 
														AND 
														//OAVERSANO 17/10/2018 : Caring Angel -- START
														(
														Case_Record_Type__c IN: RecordTypeNameSet
														OR 
														Case_Record_Type__c IN: RecordTypeNameSetCA
														//OAVERSANO 19/03/2019 : AXA Assistance -- START
														OR 
														Case_Record_Type__c IN: RecordTypeNameSetSinistri
														//OAVERSANO 19/03/2019 : AXA Assistance -- END
														) ];
														//OAVERSANO 17/10/2018 : Caring Angel -- END
		for(Configurazione_SLA_Case__c confSC : SLAConfList)
		{
			confSLACaseMap.put(confSC.Case_Record_Type__c+'$'+confSC.Category__c+'$'+confSC.Sub_Category__c+'$'+confSC.Case_Origin__c+'$'+confSC.Customer_Service_Type__c+'$'+confSC.Distribution_Network__c,confSC);
		}
		/*	Configurazioni SLA/Case Setting */ 
    	List<Milestone_Tracking__c> MlstnTrackList = [SELECT Id, Case__c, CaseStatus__c, SupportStartDate__c, Owner__c, // NOPMD  Fix CRUD violation
    													UserProfile__c, RecordTypeWorkingItem__c, UserRole__c,TeamMemberSLA__c, TimeSpent__c,
    													Working_Time__c, Working_Time__r.Time_Spent__c, OwnerId, Owner.Name,
    													Owner.Profile.Name, Owner.UserRole.Name,
    													Case__r.Category__c, Case__r.SubCategory__c, Case__r.Origin,
    													Case__r.Customer_Service_Model__c, Case__r.Distribution_Network__c,
    													Case__r.RecordType.Name, Case__r.SLA_E2E_AssAgenti__c
    													FROM Milestone_Tracking__c
    													WHERE Id IN:MlstnTrackListTrigger ];
    	system.debug('checkWorkingTimes');
        Set<String> caseSet = new Set<String>();
        Map<String, Milestone_Tracking__c> roleMilTrackMap = new Map<String, Milestone_Tracking__c>();
        for(Milestone_Tracking__c mlst:MlstnTrackList)
        {
        	if(mlst.Case__c!=null)
        	{
        		caseSet.add(mlst.Case__c);
        	}
        }
        List<Working_Times__c> wrkngTimesToCheck = [SELECT Id, Case__c, UserRole__c, UserProfile__c, Time_Spent__c // NOPMD  Fix CRUD violation
        											FROM Working_Times__c WHERE Case__c IN:caseSet ];
		List<Milestone_Tracking__c> AllMlstnTrackList = [SELECT Id, Case__c, CaseStatus__c, SupportStartDate__c, Owner__c, // NOPMD  Fix CRUD violation
    													UserProfile__c, RecordTypeWorkingItem__c, UserRole__c, TimeSpent__c,
    													Working_Time__c, Working_Time__r.Time_Spent__c, OwnerId, Owner.Name,
    													Owner.Profile.Name, Owner.UserRole.Name 
    													FROM Milestone_Tracking__c
    													WHERE Case__c IN:caseSet ];
    	List<Case> caseList = [SELECT Id, OldOwnerIsQueue__c 
    							FROM Case 											
    							WHERE Id IN:caseSet];
    	Map<String, Boolean> OldOwnerIsQueueMap = new Map<String, Boolean>();
    	for(Case cs: caseList)
    	{
    		OldOwnerIsQueueMap.put(cs.Id, cs.OldOwnerIsQueue__c);
    	}						
		for(Milestone_Tracking__c mlst:AllMlstnTrackList)
        {
        	roleMilTrackMap.put(mlst.UserProfile__c, mlst);
        }
        Map<String,List<Working_Times__c>> caseIdWrkngTimeMap = new Map<String,List<Working_Times__c>>();
        for(Working_Times__c wrkngTime: wrkngTimesToCheck)
        {
        	if(caseIdWrkngTimeMap.containsKey((String)wrkngTime.Case__c)) 
          	{
				List<Working_Times__c> mlstList = caseIdWrkngTimeMap.get((String)wrkngTime.Case__c);
				mlstList.add(wrkngTime);
				caseIdWrkngTimeMap.put((String)wrkngTime.Case__c, mlstList);
			} 
			else 
			{
				caseIdWrkngTimeMap.put((String)wrkngTime.Case__c, new List<Working_Times__c> { wrkngTime });
			}
        }
        List<Milestone_Tracking__c> MlstTrackToUpdateList = new List<Milestone_Tracking__c>();
        List<Working_Times__c> wrkTimesToInsertList = new List<Working_Times__c>();
        List<Case> CaseToUpdateList = new List<Case>();
		Map<Integer,Integer> MapIndexwrkTimeToIndexMlstTrack = new Map<Integer,Integer>();
		Integer iCountMlstTrack = 0;
        Integer iCountWorkTimes = 0;
        String defaultHoursId;
        Set<Working_Times__c> wrkgTimesToReturnSet = new Set<Working_Times__c>();
		for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true ]) // NOPMD  Fix CRUD violation
        {
            if(bh.Name == 'Default')
                defaultHoursId = bh.Id;
        }
        for(Milestone_Tracking__c mlstTrk:MlstnTrackList)
        {
        	Boolean WorkingTimefound = false;
        	Milestone_Tracking__c mlstTrackingRecord = new Milestone_Tracking__c();
        	if(mlstTrk.Working_Time__c == null && mlstTrk.Case__c != null)
        	{
        		mlstTrackingRecord = mlstTrk;
        		if(caseIdWrkngTimeMap.containsKey((String)mlstTrk.Case__c))
        		{
        			for(Working_Times__c wrkT:caseIdWrkngTimeMap.get((String)mlstTrk.Case__c))
        			{
        				if(wrkT.UserProfile__c == mlstTrk.UserProfile__c)
        					
        					
						{
    						WorkingTimefound = true;
    						if(!roleMilTrackMap.containsKey(null))
    							system.debug('roleMilTrackMap: '+JSON.serializePretty(roleMilTrackMap));			
    						/************/
    						if(roleMilTrackMap.get('Coda '+mlstTrk.UserProfile__c)!= null && OldOwnerIsQueueMap.get(mlstTrk.Case__c))
    						{
    							Milestone_Tracking__c mlstTrackQueue;
    							mlstTrackQueue = roleMilTrackMap.get('Coda '+mlstTrk.UserProfile__c);
    							system.debug('mlstTrackQueue.SupportStartDate__c: '+mlstTrackQueue.SupportStartDate__c);
	    						Double timeQueue = BusinessHours.diff(defaultHoursId, mlstTrackQueue.SupportStartDate__c, System.now())/3600000.0;
	    						system.debug('timeQueue: '+timeQueue);
								system.debug('wrkT.Time_Spent__c : '+wrkT.Time_Spent__c );
								wrkT.Time_Spent__c = wrkT.Time_Spent__c + timeQueue;
								wrkgTimesToReturnSet.add(wrkT);
    						}
    						
							/************/
    						mlstTrackingRecord.Working_Time__c = wrkT.Id;
        					MlstTrackToUpdateList.add(mlstTrackingRecord);
    					}	
        			}
        		}
        		if(!WorkingTimefound)
        		{
        			Case cs = mlstTrk.Case__r;
        			Working_Times__c wrkTime = new Working_Times__c(Case__c = mlstTrk.Case__c,
	        														UserRole__c = (String.isNotBlank(mlstTrk.UserRole__c))?mlstTrk.UserRole__c:'',
	        														UserProfile__c = (String.isNotBlank(mlstTrk.UserProfile__c))?mlstTrk.UserProfile__c:'',
	        														Time_Spent__c = mlstTrk.TimeSpent__c,
	        														RecordTypeId = Schema.SObjectType.Working_Times__c.getRecordTypeInfosByName().get(mlstTrk.RecordTypeWorkingItem__c).getRecordTypeId(),
	        														OwnerId = mlstTrk.OwnerId);
					//if(mlstTrk.UserProfile__c == HD1Role || mlstTrk.UserProfile__c == HD2Role){
					//if(mlstTrk.UserProfile__c == HD1Role || mlstTrk.UserProfile__c == HD2Role || mlstTrk.UserProfile__c == HD1BIZRole || mlstTrk.UserProfile__c == HD2BIZRole ){ //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84
					//if(mlstTrk.UserProfile__c == HD1Role || mlstTrk.UserProfile__c == HD2Role || mlstTrk.UserProfile__c == HD1BIZRole || mlstTrk.UserProfile__c == HD2BIZRole || mlstTrk.UserProfile__c == HD1CARole || mlstTrk.UserProfile__c == HD2CARole ){ //OAVERSANO 16/11/2018 : Caring Angel
					//if(mlstTrk.UserProfile__c == HD1Role || mlstTrk.UserProfile__c == HD2Role || mlstTrk.UserProfile__c == HD1BIZRole || mlstTrk.UserProfile__c == HD2BIZRole || mlstTrk.UserProfile__c == HD1CARole || mlstTrk.UserProfile__c == HD2CARole || mlstTrk.UserProfile__c == HD1ContabilitaRole || mlstTrk.UserProfile__c == HD1ContenziosoRole ){ //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
					if(mlstTrk.UserProfile__c == HD1Role || mlstTrk.UserProfile__c == HD2Role || mlstTrk.UserProfile__c == HD1BIZRole || mlstTrk.UserProfile__c == HD2BIZRole || mlstTrk.UserProfile__c == HD1CARole || mlstTrk.UserProfile__c == HD2CARole || mlstTrk.UserProfile__c == HD1ContabilitaRole || mlstTrk.UserProfile__c == HD1ContenziosoRole || mlstTrk.UserProfile__c == axaAssistanceRole || mlstTrk.UserProfile__c == customerOperationRole ){ //OAVERSANO 19/03/2019 : AXA Assistance 
						//Integer SLAcalculated = SLACALCULATOR(confSLACaseMap, mlstTrk.Case__r, mlstTrk.UserProfile__c, mlstTrk.UserRole__c);
						//Integer SLAcalculated = SLACALCULATOR(confSLACaseMap, mlstTrk.Case__r, mlstTrk.UserProfile__c, mlstTrk.UserRole__c, RecordTypeNameSet, RecordTypeNameSetCA); //OAVERSANO 17/10/2018 : Caring Angel
						Integer SLAcalculated = SLACALCULATOR(confSLACaseMap, mlstTrk.Case__r, mlstTrk.UserProfile__c, mlstTrk.UserRole__c, RecordTypeNameSet, RecordTypeNameSetCA, RecordTypeNameSetSinistri); //OAVERSANO 17/10/2018 : Caring Angel
						if(cs.SLA_E2E_AssAgenti__c==null)
							cs.SLA_E2E_AssAgenti__c = SLAcalculated;
						else
							cs.SLA_E2E_AssAgenti__c += SLAcalculated;
						wrkTime.SLA__c = SLAcalculated;
						CaseToUpdateList.add(cs);
					}
                    if(mlstTrk.TeamMemberSLA__c != null){
                        wrkTime.TeamMemberSLA__c = mlstTrk.TeamMemberSLA__c;
                    }
	        		wrkTimesToInsertList.add(wrkTime);
	        		MlstTrackToUpdateList.add(mlstTrackingRecord);
	        		MapIndexwrkTimeToIndexMlstTrack.put(iCountWorkTimes,iCountMlstTrack);
	        		iCountWorkTimes++;
        		}
        	}
        	iCountMlstTrack++;
        }
        
        if(wrkTimesToInsertList.size()>0)
        {
            Database.SaveResult[] srList = Database.insert(wrkTimesToInsertList, false);
            
            for (integer i=0;i<srList.size();i++)
            {
                if (srList[i].isSuccess())
                {
                    MlstTrackToUpdateList[MapIndexwrkTimeToIndexMlstTrack.get(i)].Working_Time__c = srList[i].id;
                }
                else
                {            
                    for(Database.Error err : srList[i].getErrors())
                    {
                        MapIndexwrkTimeToIndexMlstTrack.remove(i);
                    }                 
                }
            }
        } 
        
        for(integer i=0;i<MlstTrackToUpdateList.size();i++)
        {
            if(String.isBlank(MlstTrackToUpdateList[i].Working_Time__c))
                MlstTrackToUpdateList.remove(i);
        }
        
		if(MlstTrackToUpdateList.size()>0)
        {
            Savepoint sp = Database.setSavepoint();
            
            try
            {
                 
				update MlstTrackToUpdateList; // NOPMD  Fix CRUD violation                
            }
            catch(exception ex)
            {
                Database.rollback(sp);
                system.debug('Error: '+ex.getmessage());  
            }             
        } 
        
        if(!wrkgTimesToReturnSet.IsEmpty())
        {
        	List<Working_Times__c> wrkgTimesToReturnList = new List<Working_Times__c>();
        	wrkgTimesToReturnList.addAll(wrkgTimesToReturnSet);
        	try
            {
                 
				update wrkgTimesToReturnList; // NOPMD  Fix CRUD violation
            }
            catch(exception ex)
            {
                system.debug('Error: '+ex.getmessage());  
            }       
        	
        }           
        
        if(!CaseToUpdateList.isEmpty())
        {
        	try
            {
                update CaseToUpdateList; 
            }
            catch(exception ex)
            {
                system.debug('Error: '+ex.getmessage());  
            }       
        }
        
       
        
    }
    
    //public static Integer SLACALCULATOR(Map<String, Configurazione_SLA_Case__c> confSLACaseMap, Case cs, String Profile, String Role){
    //public static Integer SLACALCULATOR(Map<String, Configurazione_SLA_Case__c> confSLACaseMap, Case cs, String Profile, String Role, Set<String> RecordTypeNameSet, Set<String> RecordTypeNameSetCA){ //OAVERSANO 17/10/2018 : Caring Angel
    public static Integer SLACALCULATOR(Map<String, Configurazione_SLA_Case__c> confSLACaseMap, Case cs, String Profile, String Role, Set<String> RecordTypeNameSet, Set<String> RecordTypeNameSetCA, Set<String> RecordTypeNameSetSinistri){ //OAVERSANO 19/03/2019 : AXA Assistance
    	
    	Integer SLAtoReturn;
    	String AllVAlues = 'All';
    	String nullValues = 'null';
    	for(Configurazione_SLA_Case__c conf:confSLACaseMap.values())
    	{
    		system.debug('conf: '+conf);
    	}
        Configurazione_SLA_Case__c SLAConfFound = new Configurazione_SLA_Case__c();
        system.debug('sla: '+cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+cs.Customer_Service_Model__c+'$'+cs.Distribution_Network__c);
        if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+cs.Customer_Service_Model__c+'$'+cs.Distribution_Network__c))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+cs.Customer_Service_Model__c+'$'+cs.Distribution_Network__c);
        }
    	else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+cs.Customer_Service_Model__c+'$'+AllVAlues))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+cs.Customer_Service_Model__c+'$'+AllVAlues);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+AllVAlues+'$'+cs.Distribution_Network__c))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+AllVAlues+'$'+cs.Distribution_Network__c);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+cs.Customer_Service_Model__c+'$'+cs.Distribution_Network__c))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+cs.Customer_Service_Model__c+'$'+cs.Distribution_Network__c);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+AllVAlues+'$'+cs.Distribution_Network__c))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+AllVAlues+'$'+cs.Distribution_Network__c);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+cs.Customer_Service_Model__c+'$'+AllVAlues))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+cs.Customer_Service_Model__c+'$'+AllVAlues);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+AllVAlues+'$'+AllVAlues))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+AllVAlues+'$'+AllVAlues);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+AllVAlues+'$'+AllVAlues))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+AllVAlues+'$'+AllVAlues+'$'+AllVAlues);
        }
        //OAVERSANO 22/03/2019 : AXA Assistance -- START
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+nullValues+'$'+nullValues+'$'+cs.Distribution_Network__c))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+nullValues+'$'+nullValues+'$'+cs.Distribution_Network__c);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+nullValues+'$'+cs.Customer_Service_Model__c+'$'+nullValues))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+nullValues+'$'+cs.Customer_Service_Model__c+'$'+nullValues);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+nullValues+'$'+nullValues))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+cs.Origin+'$'+nullValues+'$'+nullValues);
        }
        else if(confSLACaseMap.containsKey(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+nullValues+'$'+nullValues+'$'+nullValues))
        {
        	SLAConfFound = confSLACaseMap.get(cs.RecordType.Name+'$'+cs.Category__c+'$'+cs.SubCategory__c+'$'+nullValues+'$'+nullValues+'$'+nullValues);
        }
        //OAVERSANO 22/03/2019 : AXA Assistance -- END
        //if (Profile != null && (Profile == HD1Role || Profile == HD1BIZRole) && SLAConfFound!=null)
        //if (Profile != null && (Profile == HD1Role || Profile == HD1BIZRole || Profile == HD1CARole) && SLAConfFound!=null) //OAVERSANO 16/11/2018 : Caring Angel
        //if (Profile != null && (Profile == HD1Role || Profile == HD1BIZRole || Profile == HD1CARole || Profile == HD1ContabilitaRole || Profile == HD1ContenziosoRole) && SLAConfFound!=null) //OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
        if (Profile != null && (Profile == HD1Role || Profile == HD1BIZRole || Profile == HD1CARole || Profile == HD1ContabilitaRole || Profile == HD1ContenziosoRole || Profile == axaAssistanceRole || Profile == customerOperationRole) && SLAConfFound!=null) //OAVERSANO 19/03/2019 : AXA Assistance 
        {
        	SLAtoReturn = Integer.valueOf((SLAConfFound.SLA__c));
        } 
        //else if(Profile != null && (Profile == HD2Role || Profile == HD2BIZRole) && SLAConfFound!=null)
        else if(Profile != null && (Profile == HD2Role || Profile == HD2BIZRole || Profile == HD2CARole) && SLAConfFound!=null) //OAVERSANO 16/11/2018 : Caring Angel
        {
        	if(!SLAConfFound.Configurazioni_SLA_Case_HD2__r.isEmpty())
        	{
        		for(Configurazione_SLA_Case_HD2__c SLAHD2 : SLAConfFound.Configurazioni_SLA_Case_HD2__r)
        		{
        			if(Role!= null && Role == SLAHD2.User_Role__c)
        			{
        				SLAtoReturn = Integer.valueOf((SLAHD2.SLA__c));
        			}
        		}
        	}
        }
	        
        if(SLAtoReturn==null)
        {
        	//OAVERSANO 17/10/2018 : Caring Angel -- START
        	if(RecordTypeNameSet.contains(cs.RecordType.Name))
        	{
	        	MPS_Code_Variables__c MDASLA = MPS_Code_Variables__c.getValues('ModelloDiAssistenzaSLADefault');
	        	if(MDASLA!= null)
	        	{
	        		if(String.isNotBlank(MDASLA.Value__c))
	        			SLAtoReturn = Integer.valueOf(MDASLA.Value__c);
	        	}
        	}
        	else if(RecordTypeNameSetCA.contains(cs.RecordType.Name))
        	{
        		MPS_Code_Variables__c CASLA = MPS_Code_Variables__c.getValues('CaringAngelSLADefault');
	        	if(CASLA!= null)
	        	{
	        		if(String.isNotBlank(CASLA.Value__c))
	        			SLAtoReturn = Integer.valueOf(CASLA.Value__c);
	        	}
        	}
        	//OAVERSANO 17/10/2018 : Caring Angel -- END
        	//OAVERSANO 19/03/2019 : AXA Assistance -- START
        	else if(RecordTypeNameSetSinistri.contains(cs.RecordType.Name))
        	{
        		MPS_Code_Variables__c SinistriSLA = MPS_Code_Variables__c.getValues('SinistriSLADefault');
	        	if(SinistriSLA!= null)
	        	{
	        		if(String.isNotBlank(SinistriSLA.Value__c))
	        			SLAtoReturn = Integer.valueOf(SinistriSLA.Value__c);
	        	}
        	}
        	//OAVERSANO 19/03/2019 : AXA Assistance -- END
        }
    	return SLAtoReturn;
    }
    
}