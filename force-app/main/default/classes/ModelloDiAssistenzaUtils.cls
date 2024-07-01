/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         ModelloDiAssistenzaUtils
Description:   Apex class used to execute all the logics related to Modello di Assistenza.

History

10/08/2018     Created 
-------------------------------------------------------------------------------------------*/
public without sharing class ModelloDiAssistenzaUtils {
  
  	//OAVERSANO 27/07/2018: Nuovo Modello di Assistenza -- START  
  	@TestVisible private static Boolean runModelloDiAssistenzaFROMtest = false;
  	public static boolean runModelloDiAssistenza = true; 
  	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START 
  	public static final String HD1Role = 'HD1 IT';
  	public static final String HD2Role = 'HD2 IT';
  	public static final String HD1BIZRole = 'HD1 BIZ';
  	public static final String HD2BIZRole = 'HD2 BIZ';
  	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END 
  	public static final String HD3Role = 'HD3';
  	public static final String AgentRole = 'AGENT';
  	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START 
  	public static final String HD1QueueRole = 'Coda HD1 IT';
  	public static final String HD2QueueRole = 'Coda HD2 IT';
  	public static final String HD1BIZQueueRole = 'Coda HD1 BIZ';
  	public static final String HD2BIZQueueRole = 'Coda HD2 BIZ';
  	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END 
  	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
  	public static final String HD1ContabilitaRole = 'HD1 Contabilita';
  	public static final String HD1ContenziosoRole = 'HD1 Contenzioso';
  	public static final String HD1ContabilitaQueueRole = 'Coda HD1 Contabilita';
  	public static final String HD1ContenziosoQueueRole = 'Coda HD1 Contenzioso';
  	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
  	//public static final String[] HDRoles = new String[]{'HD1 IT','HD2 IT','HD1 BIZ','HD2 BIZ'}; //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
  	public static final String[] HDRoles = new String[]{'HD1 IT','HD2 IT','HD1 BIZ','HD2 BIZ','HD1 Contabilita','HD1 Contenzioso'}; //OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
  	public static final String[] ClosedStatusList = new String[]{AP_Constants.caseStatusChiusoInAutonomia, 
                              AP_Constants.caseStatusRisoltoInAutonomia,
                              AP_Constants.caseStatusClosed,
                              AP_Constants.caseStatusOutOfTime,
                              AP_Constants.caseStatusCancelled};
  	/*public static final String IdAdministrator;
	static{
        User u = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
    	if(u!=null)
    	{
      		IdAdministrator = u.Id;
    	}
    }*/
  
    //
    public class UserInformation
    {
      	public Map<String, String> mapProfileToId;
      	public Map<String, String> mapRoleToId;
      	public Map<String, String> mapNameToId;

      	public UserInformation()
      	{
          	mapProfileToId = new Map<String, String>();
          	mapRoleToId = new Map<String, String>();
          	mapNameToId = new Map<String, String>();
      	}
    }

    public static UserInformation getProfileAndRole(Set<String> Ids, Set<String> QueuesId)
    {
      	UserInformation UsInf = new UserInformation();
      	Ids.add(UserInfo.getUserId()); //OAVERSANO 25/10/2018 : ENHANCEMENT Nuovo Modello di Assistenza 
      	List<User> userOwner = [SELECT Id, Profile.Name, UserRole.Name,Name FROM User WHERE Id IN:Ids];
      	List<QueuesObject> queueOwner = [SELECT Id, Queue.Name, QueueId FROM QueuesObject WHERE QueueId IN :QueuesId];
      
      	for(User owner: userOwner)
      	{
          	UsInf.mapProfileToId.put(owner.Id,owner.Profile.Name);
          	UsInf.mapRoleToId.put(owner.Id,owner.UserRole.Name);
          	UsInf.mapNameToId.put(owner.Id,owner.Name);
      	}

      	for(QueuesObject owner: queueOwner)
      	{
          	UsInf.mapProfileToId.put(owner.QueueId,owner.Queue.Name);
          	UsInf.mapNameToId.put(owner.QueueId,owner.Queue.Name);
     	}
      	return UsInf;
	}

	/*public static Map<String, String> getProfileNameFromId(Set<String> Ids, Set<String> QueuesId)
    {
        Map<String, String> mapToReturn = new Map<String, String>();
        List<User> userOwner = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id IN:Ids];
        for(User owner: userOwner)
        {
            mapToReturn.put(owner.Id,owner.Profile.Name);
        }
        List<QueuesObject> queueOwner = [SELECT Id, Queue.Name, QueueId FROM QueuesObject WHERE QueueId IN :QueuesId];
        for(QueuesObject owner: queueOwner)
        {
            mapToReturn.put(owner.QueueId,owner.Queue.Name);
        }
        return mapToReturn;
    }
    
    public static Map<String, String> getRoleNameFromId(Set<String> Ids)
    {
        Map<String, String> mapToReturn = new Map<String, String>();
        List<User> userOwner = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id IN:Ids];
        for(User owner: userOwner)
        {
            mapToReturn.put(owner.Id,owner.UserRole.Name);
    }
        
        return mapToReturn;
    }*/
    
	/*public static void processCaseTeamAndCaseMilestone(List<Case> Cases, Map<String,Case> OldValues, Map<String,Account> MapCaseAccount, Map<String,Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdProfileNameMap, Map<String, String> ownerIdRoleNameMap)
    {
		system.debug('runModelloDiAssistenzaFROMtest: '+runModelloDiAssistenzaFROMtest);
        if(runModelloDiAssistenza || runModelloDiAssistenzaFROMtest)
        {
        	String IdAdministrator = '';
		    User u = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
			if(u!=null)
			{
		  		IdAdministrator = u.Id;
			}
          	runModelloDiAssistenzaFROMtest = false;
          	runModelloDiAssistenza = false;
          	system.debug('Nuovo Modello di Assistenza');
      		List<Case> caseList = [SELECT Id, Current_Owner_Queue__c, HD3_IT__c, Status, CaseMilestone_StartDate__c, Owner.Profile.Name, 
                  RecordType.DeveloperName, OwnerId, Owner.UserRole.Name, Tempo_in_gestione_HD3__c,
                  Time_With_Support__c, Time_With_Customer__c, Priority,
                  MilestoneFlag__c, isClosed, Durata_lavorazione_uffici_tecnici__c,
                  Owner.Name, Owner.FirstName, Owner.LastName, CreatedById, CreatedBy.ProfileID,CreatedBy.Name, CreatedBy.Profile.Name, LastModifiedById,
                  (SELECT id, StartDate, CompletionDate, IsCompleted
                  FROM CaseMilestones 
                  WHERE IsCompleted = false),
                  (SELECT MemberId, TeamRoleId, ParentId 
                  FROM TeamMembers)
                  FROM Case 
                  WHERE Id IN:Cases];
      
      		String defaultHoursId;
      		List<Case> casesToUpdate = new List<Case>();
      		List<CaseMilestone> caseMilestonesToUpdate = new List<CaseMilestone>();
      		for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true])
          	{
              	if(bh.Name == 'Default')
                  	defaultHoursId = bh.Id;
          	}
  
          	//Case team Management START  US-0763
          	Set<String> AgentProfileSet = new Set<String>();
       		Set<String> HD1ProfileSet = new Set<String>();
	       	Set<String> HD1QueueSet = new Set<String>();
	       	Set<String> HD2ProfileSet = new Set<String>();
	       	Set<String> HD2QueueSet = new Set<String>();
	       	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START 
	       	Set<String> HD1BIZProfileSet = new Set<String>();
	       	Set<String> HD1BIZQueueSet = new Set<String>();
	       	Set<String> HD2BIZProfileSet = new Set<String>();
	       	Set<String> HD2BIZQueueSet = new Set<String>();
	       	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END 
	       	Set<String> RecordTypeSet = new Set<String>();
	       	Map<String, String> ROLEProfileMap = new Map<String, String>();
          	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
          	Set<String> HD1ContabilitaProfileSet = new Set<String>();
	       	Set<String> HD1ContabilitaQueueSet = new Set<String>();
	       	Set<String> HD1ContabilitaRoleSet = new Set<String>();
	       	Set<String> HD1ContenziosoProfileSet = new Set<String>();
	       	Set<String> HD1ContenziosoQueueSet = new Set<String>();
	       	Set<String> HD1ContenziosoRoleSet = new Set<String>();
	       	Map<String, String> ROLErolesMap = new Map<String, String>();
	       	Set<String> HD1_HD2ProfilesSet = new Set<String>();
          	/*Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                            HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c, 
                            HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
                            FROM Modello_di_Assistenza__mdt 
                            WHERE DeveloperName  = 'ProfileManagement'
                            LIMIT 1];*/
            /*List<Modello_di_Assistenza__mdt> mdAssList = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                            HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c, 
                            HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c, Value__c
                            FROM Modello_di_Assistenza__mdt 
                            WHERE DeveloperName IN ('ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue')
                            ];
            
            for(Modello_di_Assistenza__mdt mdAss : mdAssList)
            {
            	if(mdAss.DeveloperName == 'ProfileManagement')
	      		{
	          		if(String.isNotBlank(mdAss.AgentProfile__c))
	          		{
	                  	for(String s:mdAss.AgentProfile__c.split(';'))
	                  	{
	                      	AgentProfileSet.add(s);
	                      	ROLEProfileMap.put(s,AgentRole);
	                  	}   
	          		}
	               	if(String.isNotBlank(mdAss.HD1Profile__c))
	               	{
	                  	for(String s:mdAss.HD1Profile__c.split(';'))
	                  	{
	                      	HD1ProfileSet.add(s); 
	                      	ROLEProfileMap.put(s,HD1Role);
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}  
	               	}
	              	if(String.isNotBlank(mdAss.HD1Queue__c))
	              	{
	                  	for(String s:mdAss.HD1Queue__c.split(';'))
	                  	{
	                      	HD1QueueSet.add(s);  
	                      	ROLEProfileMap.put(s,HD1QueueRole);
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}
	              	}
	              	if(String.isNotBlank(mdAss.HD2Profile__c))
	              	{
	                  	for(String s:mdAss.HD2Profile__c.split(';'))
	                  	{
	                      	HD2ProfileSet.add(s); 
	                      	ROLEProfileMap.put(s,HD2Role); 
							HD1_HD2ProfilesSet.add(s);
	                  	}
	              	}
	              	if(String.isNotBlank(mdAss.HD2Queue__c))
	              	{
	                  	for(String s:mdAss.HD2Queue__c.split(';'))
	                  	{
	                      	HD2QueueSet.add(s);  
	                      	ROLEProfileMap.put(s,HD2QueueRole);  
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}
	              	}
	              	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START 
	              	if(String.isNotBlank(mdAss.HD1BIZProfile__c))
	               	{
	                  	for(String s:mdAss.HD1BIZProfile__c.split(';'))
	                  	{
	                      	HD1BIZProfileSet.add(s); 
	                      	ROLEProfileMap.put(s,HD1BIZRole);
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}  
	               	}
	              	if(String.isNotBlank(mdAss.HD1BIZQueue__c))
	              	{
	                  	for(String s:mdAss.HD1BIZQueue__c.split(';'))
	                  	{
	                      	HD1BIZQueueSet.add(s);  
	                      	ROLEProfileMap.put(s,HD1BIZQueueRole);
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}
	              	}
	              	if(String.isNotBlank(mdAss.HD2BIZProfile__c))
	              	{
	                  	for(String s:mdAss.HD2BIZProfile__c.split(';'))
	                  	{
	                      	HD2BIZProfileSet.add(s); 
	                      	ROLEProfileMap.put(s,HD2BIZRole);  
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}
	              	}
	              	if(String.isNotBlank(mdAss.HD2BIZQueue__c))
	              	{
	                  	for(String s:mdAss.HD2BIZQueue__c.split(';'))
	                  	{
	                      	HD2BIZQueueSet.add(s);  
	                      	ROLEProfileMap.put(s,HD2BIZQueueRole); 
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}
	              	}
	              	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
	              	if(String.isNotBlank(mdAss.CaseTriggerRecordType__c))
	              	{
	                  	for(String s:mdAss.CaseTriggerRecordType__c.split(';'))
	                  	{
	                      	RecordTypeSet.add(s);  
	                  	}
	              	}
	      		}
	      		else if(mdAss.DeveloperName == 'HD1ContabilitaProfile')
	      		{
	      			if(String.isNotBlank(mdAss.Value__c))
	              	{
	                  	for(String s:mdAss.Value__c.split(';'))
	                  	{
	                      	HD1ContabilitaProfileSet.add(s);  
	                      	ROLEProfileMap.put(s,HD1ContabilitaRole);
	                      	HD1_HD2ProfilesSet.add(s);
	                  	}
	              	}
	      		}
	      		else if(mdAss.DeveloperName == 'HD1ContabilitaRole')
	      		{
	      			if(String.isNotBlank(mdAss.Value__c))
	      			{
	      				for(String s:mdAss.Value__c.split(';'))
	      				{
	      					HD1ContabilitaRoleSet.add(s);
	      					ROLErolesMap.put(s,HD1ContabilitaRole);
	      				}
	      			}
	      		}
	      		else if(mdAss.DeveloperName == 'HD1ContenziosoProfile')
	      		{
	      			if(String.isNotBlank(mdAss.Value__c))
	      			{
	      				for(String s:mdAss.Value__c.split(';'))
	      				{
	      					HD1ContenziosoProfileSet.add(s);
	      					ROLEProfileMap.put(s,HD1ContenziosoRole);
	      					HD1_HD2ProfilesSet.add(s);
	      				}
	      			}
	      		}
	      		else if(mdAss.DeveloperName == 'HD1ContenziosoRole')
	      		{
	      			if(String.isNotBlank(mdAss.Value__c))
	      			{
	      				for(String s:mdAss.Value__c.split(';'))
	      				{
	      					HD1ContenziosoRoleSet.add(s);
	      					ROLErolesMap.put(s,HD1ContenziosoRole);
	      				}
	      			}
	      		}
	      		else if(mdAss.DeveloperName == 'HD1ContabilitaQueue')
	      		{
	      			if(String.isNotBlank(mdAss.Value__c))
	      			{
	      				for(String s:mdAss.Value__c.split(';'))
	      				{
	      					HD1ContabilitaQueueSet.add(s);
	      					ROLEProfileMap.put(s,HD1ContabilitaQueueRole);
	      					HD1_HD2ProfilesSet.add(s);
	      				}
	      			}
	      		}
	      		else if(mdAss.DeveloperName == 'HD1ContenziosoQueue')
	      		{
	      			if(String.isNotBlank(mdAss.Value__c))
	      			{
	      				for(String s:mdAss.Value__c.split(';'))
	      				{
	      					HD1ContenziosoQueueSet.add(s);
	      					ROLEProfileMap.put(s,HD1ContenziosoQueueRole);
	      					HD1_HD2ProfilesSet.add(s);
	      				}
	      			}
	      		}
            }
            //OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
            
      		
    		List<CaseTeamRole> caseTeamRoles = [SELECT Id, Name FROM CaseTeamRole WHERE Name IN :HDRoles];
    		Map<String,String> csTRNameIdMap = new Map<String, String>();
    		Map<String,CaseTeamMember> membersToAdd = new Map<String,CaseTeamMember>();
    		for(CaseTeamRole csTR : caseTeamRoles)
    		{
      			csTRNameIdMap.put(csTR.name, csTR.Id);
    		}
    		Map<Id, List<String>> membersCaseMap = new Map<Id, List<String>>();
    		for(Case cs:caseList)
    		{
      			if(!cs.TeamMembers.isEmpty())
      			{
        			for(CaseTeamMember csTM:cs.TeamMembers)
        			{
          				if(membersCaseMap.containsKey(csTM.ParentId))
          				{
            				List<String> caseTeamMemberList = membersCaseMap.get(csTM.ParentId);
            				caseTeamMemberList.add(csTM.MemberId);
            				membersCaseMap.put(csTM.ParentId, caseTeamMemberList);
          				} 
          				else 
          				{
            				membersCaseMap.put(csTM.ParentId, new List<String> { csTM.MemberId }); 
          				}
        			}
      			}  
    		}
      		//Case team Management END  US-0763
      
      		//Milestone tracking START  US-0769
      		Map<String, Case> idCaseMap = new Map<String, Case>(); 
    		Set<Id> caseIdSet = new Set<Id>();
       		List<Milestone_Tracking__c> mlstTrackListToUpdate = new List<Milestone_Tracking__c>();
    		List<Working_Times__c> wrkgTimesListToUpdate = new List<Working_Times__c>();
    		Map<String, List<Milestone_Tracking__c>> CaseMilestoneTrackingMap = new Map<String, List<Milestone_Tracking__c>>();
			Map<String, Working_Times__c> mlstnTrackWorkingTimeMap = new Map<String, Working_Times__c>();
    		List<Working_Times__c> workingTimesToInsert = new List<Working_Times__c>();
    		Set<Id> setWorkingTimesId = new Set<Id>(); 
    		Map<Id, Working_Times__c> workingTimeMap = new Map<Id, Working_Times__c>([SELECT Id, UserProfile__c, 
                                        UserRole__c, Time_Spent__c 
                                        FROM Working_Times__c 
                                        WHERE Case__c IN:caseList]);
    		
    		List<Milestone_Tracking__c> milestoneTrackList = [SELECT Id, Case__c, CaseStatus__c, CreatedById, 
                              CreatedBy.Name, TimeSpent__c, UserProfile__c, 
                              UserRole__c, SupportStartDate__c, Working_Time__c, 
                              Working_Time__r.UserProfile__c, Working_Time__r.UserRole__c, 
                              Working_Time__r.Time_Spent__c, Owner__c, RecordTypeWorkingItem__c  
                              FROM Milestone_Tracking__c
                              WHERE Case__c IN:caseList order by createdDate desc];
    
    		if(!milestoneTrackList.isEmpty())
    		{
      			for(Milestone_Tracking__c mlstTrack: milestoneTrackList)
      			{
        			if(String.isNotBlank(mlstTrack.Case__c))
        			{
          				if(CaseMilestoneTrackingMap.containsKey((String)mlstTrack.Case__c)) 
                  		{
            				List<Milestone_Tracking__c> mlstList = CaseMilestoneTrackingMap.get((String)mlstTrack.Case__c);
            				mlstList.add(mlstTrack);
            				CaseMilestoneTrackingMap.put((String)mlstTrack.Case__c, mlstList);
          				} 
          				else 
          				{
            				CaseMilestoneTrackingMap.put((String)mlstTrack.Case__c, new List<Milestone_Tracking__c> { mlstTrack });
          				}
        			}
        			if(String.isNotBlank(mlstTrack.Working_Time__c))
        			{
          				mlstnTrackWorkingTimeMap.put(mlstTrack.Id, workingTimeMap.get(mlstTrack.Working_Time__c));
        			}
      			}
    		}
    		//Milestone tracking END  US-0769
    
    		for(Case cs:caseList)
      		{
        		//Case team Management
        		system.debug('cs.Ownerid: '+cs.Ownerid);
            	system.debug('cs.Owner.Profile.Name: '+cs.Owner.Profile.Name);
            	system.debug('HD1ProfileSet: '+HD1ProfileSet);
        		if(    (
              			HD1ProfileSet.contains(cs.Owner.Profile.Name)
              			||
              			HD2ProfileSet.contains(cs.Owner.Profile.Name)
              			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START 
              			||
              			HD1BIZProfileSet.contains(cs.Owner.Profile.Name)
              			||
              			HD2BIZProfileSet.contains(cs.Owner.Profile.Name)
              			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
              			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
              			||
              			HD1ContabilitaProfileSet.contains(cs.Owner.Profile.Name)
              			||
              			HD1ContenziosoProfileSet.contains(cs.Owner.Profile.Name)
						//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END              			
              			)
              			&& RecordTypeSet.contains(cs.RecordType.DeveloperName) 
              		)
        		{
          			if( membersCaseMap.containsKey(cs.Id) )
          			{
            			system.debug('case with caseteam');
            			if(!(membersCaseMap.get(cs.Id).contains(cs.OwnerId) ) )
            			{
              				system.debug('aggiunta nuovo membro');
              				CaseTeamMember ctMember = new CaseTeamMember(ParentId = cs.Id,
                              	MemberId = cs.OwnerId
                              	//TeamRoleId = (HD1ProfileSet.contains(cs.Owner.Profile.Name)?csTRNameIdMap.get(HD1Role):csTRNameIdMap.get(HD2Role))
                          	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                              	//TeamRoleId = (HD1ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1Role):(HD2ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD2Role):(HD1BIZProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1BIZRole):csTRNameIdMap.get(HD2BIZRole) //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
                         	);
                         	if( HD1ContabilitaProfileSet.contains(cs.Owner.Profile.Name) || (HD1ProfileSet.contains(cs.Owner.Profile.Name) && HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name)) )
                          	{
                            	ctMember.TeamRoleId = csTRNameIdMap.get(HD1ContabilitaRole);   		
                         	}
                         	else if( HD1ContenziosoProfileSet.contains(cs.Owner.Profile.Name) || (HD1ProfileSet.contains(cs.Owner.Profile.Name) && HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name)) )
                         	{
                         		ctMember.TeamRoleId = csTRNameIdMap.get(HD1ContenziosoRole);   	
                         	}
                         	else
                         	{
                         		ctMember.TeamRoleId = (HD1ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1Role):(HD2ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD2Role):(HD1BIZProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1BIZRole):csTRNameIdMap.get(HD2BIZRole); 
                         	}
                          	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END        
              				membersToAdd.put(ctMember.MemberId,ctMember);
            			}
          			}
          			else
          			{
            			system.debug('inizializzazione membro');
            			CaseTeamMember ctMember = new CaseTeamMember(ParentId = cs.Id,
                      		MemberId = cs.ownerid
                      		//TeamRoleId = (HD1ProfileSet.contains(cs.Owner.Profile.Name)?csTRNameIdMap.get(HD1Role):csTRNameIdMap.get(HD2Role))
              			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                            //TeamRoleId = (HD1ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1Role):(HD2ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD2Role):(HD1BIZProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1BIZRole):csTRNameIdMap.get(HD2BIZRole) //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
                     	);
                     	if( HD1ContabilitaProfileSet.contains(cs.Owner.Profile.Name) || (HD1ProfileSet.contains(cs.Owner.Profile.Name) && HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name)) )
                      	{
                        	ctMember.TeamRoleId = csTRNameIdMap.get(HD1ContabilitaRole);   		
                     	}
                     	else if( HD1ContenziosoProfileSet.contains(cs.Owner.Profile.Name) || (HD1ProfileSet.contains(cs.Owner.Profile.Name) && HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name)) )
                     	{
                     		ctMember.TeamRoleId = csTRNameIdMap.get(HD1ContenziosoRole);   	
                     	}
                     	else
                     	{
                     		ctMember.TeamRoleId = (HD1ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1Role):(HD2ProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD2Role):(HD1BIZProfileSet.contains(cs.Owner.Profile.Name))?csTRNameIdMap.get(HD1BIZRole):csTRNameIdMap.get(HD2BIZRole); 
                     	}
                      	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END     
          				membersToAdd.put(ctMember.MemberId,ctMember);
          			}
        		}
        		//Case team Management
        		
        		system.debug('ownerIdProfileNameMap: '+JSON.serializepretty(ownerIdProfileNameMap));
        		system.debug('cs.OwnerId: '+cs.OwnerId);
        		system.debug('OldValues.get(cs.Id).OwnerId: '+OldValues.get(cs.Id).OwnerId);
        		system.debug('cs.cs.Status: '+cs.Status);
        		system.debug('OldValues.get(cs.Id).Status: '+OldValues.get(cs.Id).Status);
        		system.debug('MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName()): '+MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName()));
        		system.debug('old priority: '+OldValues.get(cs.Id).Priority);
        		system.debug('priority: '+cs.Priority);
                system.debug('Profilo utente: ' + cs.CreatedBy.Profile.name);
        		//Milestone tracking START  US-0769
        		if( ((/*AgentProfileSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
            			||
            			AgentProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
            			||*/
            			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
            			/*HD1ProfileSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
            			||
            			HD1ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
            			||
            			HD2ProfileSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
            			||
            			HD2ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
			            ||
			            HD1QueueSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
			            ||
			            HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
			            ||
			            HD2QueueSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
			            ||
			            HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
            			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
            			||
            			HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
            			||
            			HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
            			||
            			HD2BIZProfileSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
            			||
            			HD2BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
			            ||
			            HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
			            ||
			            HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
			            ||
			            HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
			            ||
			            HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))*/
            			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
            			/*HD1_HD2ProfilesSet.contains(ownerIdProfileNameMap.get(cs.OwnerId))
            			||
            			HD1_HD2ProfilesSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
            			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
          				||
          				(OldValues.get(cs.Id).CreatedById == IdAdministrator && OldValues.get(cs.Id).Priority == 'DAC AXA Agenti')
          				)
          			&&
            		(
            			cs.Priority == 'Medium' && OldValues.get(cs.Id).Priority == 'DAC AXA Agenti'
            			||
            			cs.OwnerId != OldValues.get(cs.Id).OwnerId
                        ||
                        cs.HD3_IT__c != OldValues.get(cs.Id).HD3_IT__c
            			||
            			((HD1ProfileSet.contains(cs.CreatedBy.Profile.Name)|| HD1ProfileSet.contains(cs.Owner.Profile.Name))&& !System.isQueueable() //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
                        //OAVERSANO 16/01/2019 : FIX createdby HD1 -- START
                        &&(( cs.Status != OldValues.get(cs.Id).Status
                        	&& cs.OwnerId != OldValues.get(cs.Id).OwnerId)
                        	|| OldValues.get(cs.Id).CaseNumber == null)) 
            			//OAVERSANO 16/01/2019 : FIX createdby HD1 -- END
                        //OAVERSANO 29/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
            			||
            			(HD1BIZProfileSet.contains(cs.CreatedBy.Profile.Name) && !System.isQueueable() 
                         //OAVERSANO 16/01/2019 : FIX createdby HD1 -- START
                        	&&(( cs.Status != OldValues.get(cs.Id).Status
                        	&& cs.OwnerId != OldValues.get(cs.Id).OwnerId)
                        	|| OldValues.get(cs.Id).CaseNumber == null))
                        //OAVERSANO 16/01/2019 : FIX createdby HD1 -- END
            			//OAVERSANO 29/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
            			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
            			||
            			(HD1ContabilitaProfileSet.contains(cs.CreatedBy.Profile.Name) && !System.isQueueable() 
                        	&&(( cs.Status != OldValues.get(cs.Id).Status
                        	&& cs.OwnerId != OldValues.get(cs.Id).OwnerId)
                        	|| OldValues.get(cs.Id).CaseNumber == null))
                        ||
            			(HD1ContenziosoProfileSet.contains(cs.CreatedBy.Profile.Name) && !System.isQueueable() 
                        	&&(( cs.Status != OldValues.get(cs.Id).Status
                        	&& cs.OwnerId != OldValues.get(cs.Id).OwnerId)
                        	|| OldValues.get(cs.Id).CaseNumber == null))
            			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
            			||
            			/*ownerIdProfileNameMap.get(cs.OwnerId) != ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId)
			            ||
			            ownerIdRoleNameMap.get(cs.OwnerId) != ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId)
			            ||*/
                    //	cs.Status != OldValues.get(cs.Id).Status
                /*    )
                  &&
                  	RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName()))
                  ))
    			{
                  	//objContainer TrackObjectUpdated = MILESTONETracking(cs, OldValues, CaseMilestoneTrackingMap, defaultHoursId, AgentProfileSet, HD1ProfileSet, HD1QueueSet, HD2ProfileSet, HD2QueueSet, RecordTypeSet, ROLEProfileMap, ownerIdProfileNameMap, ownerIdRoleNameMap, idCaseMap, mlstnTrackWorkingTimeMap, ClosedStatusList);
                  	//objContainer TrackObjectUpdated = MILESTONETracking(cs, OldValues, CaseMilestoneTrackingMap, defaultHoursId, AgentProfileSet, HD1ProfileSet, HD1QueueSet, HD2ProfileSet, HD2QueueSet, HD1BIZProfileSet, HD1BIZQueueSet, HD2BIZProfileSet, HD2BIZQueueSet, RecordTypeSet, ROLEProfileMap, ownerIdProfileNameMap, ownerIdRoleNameMap, idCaseMap, mlstnTrackWorkingTimeMap, ClosedStatusList); //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
                  	objContainer TrackObjectUpdated = MILESTONETracking(cs, OldValues, CaseMilestoneTrackingMap, defaultHoursId, AgentProfileSet, HD1ProfileSet, HD1QueueSet, HD2ProfileSet, HD2QueueSet, HD1BIZProfileSet, HD1BIZQueueSet, HD2BIZProfileSet, HD2BIZQueueSet, HD1ContabilitaProfileSet, HD1ContenziosoProfileSet, HD1ContabilitaQueueSet, HD1ContenziosoQueueSet, HD1ContabilitaRoleSet, HD1ContenziosoRoleSet, RecordTypeSet, ROLEProfileMap, ROLErolesMap, ownerIdProfileNameMap, ownerIdRoleNameMap, idCaseMap, mlstnTrackWorkingTimeMap, ClosedStatusList, IdAdministrator); //OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
                  	idCaseMap = TrackObjectUpdated.idCaseMap;
                  	if(!TrackObjectUpdated.mlstTrackList.isEmpty())
                  	{
                    	mlstTrackListToUpdate.addAll(TrackObjectUpdated.mlstTrackList);
                  	}
                  	system.debug('TrackObjectUpdated.CsList: '+TrackObjectUpdated.CsList);
                  	system.debug('casesToUpdate@#: '+casesToUpdate);
                  	if(!TrackObjectUpdated.CsList.isEmpty())
                  	{
                    	Set<Case> caseSet = new Set<Case>();
                    	caseSet.addAll(TrackObjectUpdated.CsList);
                    	casesToUpdate.addAll(caseSet);
                  	}
                  	system.debug('casesToUpdate@#after: '+casesToUpdate);
                  	if(!TrackObjectUpdated.CsMilestoneList.isEmpty())
                  	{
                    	caseMilestonesToUpdate.addAll(TrackObjectUpdated.CsMilestoneList);
                  	}
                  	if(!TrackObjectUpdated.caseIdSet.isEmpty())
                  	{
                    	caseIdSet.addAll(TrackObjectUpdated.caseIdSet);
                  	}
                  	if(!TrackObjectUpdated.WrkTimesList.isEmpty())
                  	{
                    	wrkgTimesListToUpdate.addAll(TrackObjectUpdated.WrkTimesList);
                  	}
                }
                //Milestone tracking END  US-0769
        	}
        	
          	//try
          	//{
            	if(!caseMilestonesToUpdate.isEmpty())
                {
                  	database.update(caseMilestonesToUpdate);
                }
                system.debug('@@@: '+casesToUpdate);
                if(!casesToUpdate.isEmpty())
                {
                  	database.update(casesToUpdate);
                }
                if(!caseIdSet.isEmpty() && !Test.isRunningTest() && !System.isQueueable()) //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
                {
                  	//System.enqueuejob(new updateCase(caseIdSet, OldValues, AgentProfileSet, HD1ProfileSet, HD2ProfileSet, HD1BIZProfileSet, HD2BIZProfileSet));//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
                  	System.enqueuejob(new updateCase(caseIdSet, OldValues, AgentProfileSet, HD1ProfileSet, HD2ProfileSet, HD1BIZProfileSet, HD2BIZProfileSet, HD1ContabilitaProfileSet, HD1ContabilitaRoleSet, HD1ContenziosoProfileSet, HD1ContenziosoRoleSet));//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
                }
                if(!mlstTrackListToUpdate.isEmpty()) {
                  	system.debug('mlstTrackListToUpdate: '+mlstTrackListToUpdate);
					//rimozione duplicati 
					//causa |FATAL_ERROR|System.ListException: Before Insert or Upsert list must not have two identically equal elements
					Set<Milestone_Tracking__c> milestoneTrackingSet = new Set<Milestone_Tracking__c>();
					List<Milestone_Tracking__c> milestoneTrackingList = new List<Milestone_Tracking__c>();
					milestoneTrackingSet.addAll(mlstTrackListToUpdate);
					milestoneTrackingList.addAll(milestoneTrackingSet);
					//upsert
                  	database.upsert(milestoneTrackingList);
                }
                if(!wrkgTimesListToUpdate.isEmpty()) {
				  //rimozione duplicati 
				  //causa |FATAL_ERROR|System.ListException: Before Insert or Upsert list must not have two identically equal elements
				  Set<Working_Times__c> workingTimesSet = new Set<Working_Times__c>();
				  List<Working_Times__c> workingTimesList = new List<Working_Times__c>();
				  workingTimesSet.addAll(wrkgTimesListToUpdate);
				  workingTimesList.addAll(workingTimesSet);
				  //upsert
                  	database.update(workingTimesList);
                }
                List<CaseTeamMember> csTMList = new List<CaseTeamMember>();
                if(!membersToAdd.isEmpty())
                {
                  	system.debug('membersToAdd: '+membersToAdd);
                  	csTMList.addAll(membersToAdd.values());
                  	database.insert(csTMList);
                }
        	//}
        	//catch(exception e) 
        	//{
            //	system.debug('errore: '+e.getMessage());
         	//}
      	}
	}
    
    //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- START  US-0769
    public class objContainer
    {
    	public Set<Milestone_Tracking__c> mlstTrackList;
  		public Set<Case> CsList;
  		public Set<CaseMilestone> CsMilestoneList;   
  		public Set<Working_Times__c> WrkTimesList;   
  		public Map<String, Case> idCaseMap;    
  		public Set<Id> caseIdSet;    
     
       	public objContainer(){}
    }
    
   	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
    //public static objContainer MILESTONETracking(Case cs, Map<String,Case> OldValues, Map<String, List<Milestone_Tracking__c>> CaseMilestoneTrackingMap, String defaultHoursId, Set<String> AgentProfileSet, Set<String> HD1ProfileSet, Set<String> HD1QueueSet, Set<String> HD2ProfileSet, Set<String> HD2QueueSet, Set<String> HD1BIZProfileSet, Set<String> HD1BIZQueueSet, Set<String> HD2BIZProfileSet, Set<String> HD2BIZQueueSet, Set<String> RecordTypeSet, Map<String, String> ROLEProfileMap, Map<String,String> ownerIdProfileNameMap, Map<String, String> ownerIdRoleNameMap, Map<String, Case> idCaseMap, Map<String, Working_Times__c> mlstnTrackWorkingTimeMap, List<String> ClosedStatusList) {
    public static objContainer MILESTONETracking(Case cs, Map<String,Case> OldValues, Map<String, List<Milestone_Tracking__c>> CaseMilestoneTrackingMap, String defaultHoursId, Set<String> AgentProfileSet, Set<String> HD1ProfileSet, Set<String> HD1QueueSet, Set<String> HD2ProfileSet, Set<String> HD2QueueSet, Set<String> HD1BIZProfileSet, Set<String> HD1BIZQueueSet, Set<String> HD2BIZProfileSet, Set<String> HD2BIZQueueSet, Set<String> HD1ContabilitaProfileSet, Set<String> HD1ContenziosoProfileSet, Set<String> HD1ContabilitaQueueSet, Set<String> HD1ContenziosoQueueSet, Set<String> HD1ContabilitaRoleSet, Set<String> HD1ContenziosoRoleSet, Set<String> RecordTypeSet, Map<String, String> ROLEProfileMap, Map<String, String> ROLErolesMap, Map<String,String> ownerIdProfileNameMap, Map<String, String> ownerIdRoleNameMap, Map<String, Case> idCaseMap, Map<String, Working_Times__c> mlstnTrackWorkingTimeMap, List<String> ClosedStatusList, String IdAdministrator) {  
    //OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
      	Boolean trackingFoundCS = false;
      	Boolean trackingFoundOldCS = false;
      	objContainer objCont = new objContainer();
      	Set<Working_Times__c> workingTimesToReturnList = new Set<Working_Times__c>();
      	Set<Milestone_Tracking__c> mlstTrackToReturnList = new Set<Milestone_Tracking__c>();
      	Set<Case> csListToReturn = new Set<Case>();
      	Set<CaseMilestone> csMilestoneListToReturn = new Set<CaseMilestone>();
      	Set<Id> caseIdSet = new Set<Id>();
      	Milestone_Tracking__c mlstTrackToReturn;
      	Milestone_Tracking__c oldMlstTrackToReturn;
      	Working_Times__c wrkngTimeToReturn;

      	if(CaseMilestoneTrackingMap.containsKey(cs.Id))
      	{
        	for(Milestone_Tracking__c mlstTrack: CaseMilestoneTrackingMap.get(OldValues.get(cs.Id).Id))
        	{
          		system.debug('ROLEProfileMap: '+JSON.serializePretty(ROLEProfileMap));
          		if(		(mlstTrack.UserProfile__c == ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
            			&&
            			mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
          				)
            		||
              			(mlstTrack.UserProfile__c == AgentRole 
              			&&
              			mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status)
          			||
              			(mlstTrack.UserProfile__c == HD3Role
              			&&
              			mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status)
              			/*aggiunta Code*/
          		/*	||
              			(mlstTrack.UserProfile__c == HD1QueueRole && String.valueOf(OldValues.get(cs.Id).OwnerId).startsWith('00G')  
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1QueueRole)
              		||
              			(mlstTrack.UserProfile__c == HD2QueueRole && String.valueOf(OldValues.get(cs.Id).OwnerId).startsWith('00G')  
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD2QueueRole)
              			/*aggiunta Code*/
              		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 -- START
        /*      		||
              			(mlstTrack.UserProfile__c == HD1BIZQueueRole && String.valueOf(OldValues.get(cs.Id).OwnerId).startsWith('00G')  
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1BIZQueueRole)
              		||
              			(mlstTrack.UserProfile__c == HD2BIZQueueRole && String.valueOf(OldValues.get(cs.Id).OwnerId).startsWith('00G')  
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD2BIZQueueRole)
              		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 -- END
              		//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
              		||
              			(mlstTrack.UserProfile__c == HD1ContabilitaQueueRole && String.valueOf(OldValues.get(cs.Id).OwnerId).startsWith('00G')  
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContabilitaQueueRole)
              		||
              			(mlstTrack.UserProfile__c == HD1ContenziosoQueueRole && String.valueOf(OldValues.get(cs.Id).OwnerId).startsWith('00G')  
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContenziosoQueueRole)
              		||
              			//ROLES
              			(mlstTrack.UserProfile__c == ROLErolesMap.get(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId))
            			&&
            			mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
          				)
          				//ROLES
              		//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
      				)
          		{
            		system.debug('mlstTrack.UserProfile__c : '+mlstTrack.UserProfile__c );
            		system.debug('@@@@@@@mlstTrack.Owner__c: '+mlstTrack.Owner__c);
            		system.debug('@@@@@@@OldValues.get(cs.Id).OwnerId: '+OldValues.get(cs.Id).OwnerId);
            		system.debug('ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId)): '+ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId)));
            		system.debug('mlstTrack.CaseStatus__c == '+mlstTrack.CaseStatus__c);
            		system.debug('cs.Status == '+OldValues.get(cs.Id).Status);
        			if( (  (
        					//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
            				//ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1Role
            				(
            					ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1Role
            					&&
            					ROLErolesMap.get(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId))!=HD1ContabilitaQueueRole
            					&&
            					ROLErolesMap.get(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId))!=HD1ContenziosoQueueRole
            				)
            				//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                			||
              				(ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD2Role
              				&&
              				mlstTrack.UserRole__c == ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId))
                			/*||
                				ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==AgentRole*/
                			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
              /*  			||
                			ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1BIZRole
                			||
              				(ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD2BIZRole
              				&&
              				mlstTrack.UserRole__c == ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId))
                			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
                			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                			||
                			ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContabilitaRole
                			||
                			ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContenziosoRole
                			||
                			ROLErolesMap.get(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContabilitaRole
                			||
                			ROLErolesMap.get(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContenziosoRole
                			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
            				)
                			&&
            				mlstTrack.Owner__c == OldValues.get(cs.Id).OwnerId
            			)
            			||
              				(mlstTrack.UserProfile__c == AgentRole 
            				&&
                			(OldValues.get(cs.Id).Status == AP_Constants.caseStatusSoluzioneProposta 
            				|| 
							OldValues.get(cs.Id).Status == AP_Constants.caseStatusAttesaInfoAgente
							|| 
                			OldValues.get(cs.Id).Status == AP_Constants.caseStatusPending)
              				)
            			||
              				(mlstTrack.UserProfile__c == HD3Role
                			&&
                			OldValues.get(cs.Id).Status == AP_Constants.caseStatusGestioneHD3 
              				)
              				/*aggiunta code*/
            	/*		||
			              	(mlstTrack.UserProfile__c ==  HD1QueueRole
			              	&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1QueueRole)
			              	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
              				&& mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
              				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
            			||
              				(mlstTrack.UserProfile__c ==  HD2QueueRole
              				&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD2QueueRole)
              				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
              				&& mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
              				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
              				/*aggiunta code*/
              				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
              	/*		||
			              	(mlstTrack.UserProfile__c ==  HD1BIZQueueRole
			              	&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1BIZQueueRole)
              				&& mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
            			||
              				(mlstTrack.UserProfile__c ==  HD2BIZQueueRole
              				&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD2BIZQueueRole)
              				&& mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
              				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
              				//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
          				||
			              	(mlstTrack.UserProfile__c ==  HD1ContabilitaQueueRole
			              	&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContabilitaQueueRole)
              				&& mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
            			||
              				(mlstTrack.UserProfile__c ==  HD1ContenziosoQueueRole
              				&& ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))==HD1ContenziosoQueueRole)
              				&& mlstTrack.CaseStatus__c == OldValues.get(cs.Id).Status
              				//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        			)
          			{
              			system.debug('Record trovato Old');
              			trackingFoundOldCS = true;
              			oldMlstTrackToReturn = mlstTrack;
              			Double timeSinceLastChangeOwner = BusinessHours.diff(defaultHoursId, oldMlstTrackToReturn.SupportStartDate__c, System.now())/3600000.0; 
              			if(oldMlstTrackToReturn.TimeSpent__c!=null){
							oldMlstTrackToReturn.TimeSpent__c = oldMlstTrackToReturn.TimeSpent__c+timeSinceLastChangeOwner;
							oldMlstTrackToReturn.SupportEndDate__c = system.now();
						  }
              			else{
							oldMlstTrackToReturn.TimeSpent__c = timeSinceLastChangeOwner;
							oldMlstTrackToReturn.SupportEndDate__c = system.now();
						  }
              			Case csToUpdate;
              			if(mlstnTrackWorkingTimeMap.get(oldMlstTrackToReturn.Id)!=null)
              			{
                			wrkngTimeToReturn = mlstnTrackWorkingTimeMap.get(oldMlstTrackToReturn.Id);
              			}
          				system.debug('1 ## idCaseMap: '+idCaseMap);
              			if(idCaseMap.containsKey(cs.Id))
              			{
                			csToUpdate = idCaseMap.geT(cs.Id);
              			}
              			else
          				{
                			csToUpdate = cs;
                			idCaseMap.put(cs.Id, cs);
              			}
              			if 	(	(mlstTrack.UserProfile__c == HD1Role 
          						/*aggiunta code || mlstTrack.UserProfile__c == HD1QueueRole /*aggiunta code*/
          						//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
/*          						|| mlstTrack.UserProfile__c == HD1BIZRole 
          					 	|| mlstTrack.UserProfile__c == HD1BIZQueueRole 
          					 	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
          					 	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
          					 	|| mlstTrack.UserProfile__c == HD1ContabilitaRole 
          					 	|| mlstTrack.UserProfile__c == HD1ContabilitaQueueRole 
          					 	|| mlstTrack.UserProfile__c == HD1ContenziosoRole 
          					 	|| mlstTrack.UserProfile__c == HD1ContenziosoQueueRole 
          					 	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
          						)
                  				&& OldValues.get(cs.Id).Status != AP_Constants.caseStatusSoluzioneProposta && OldValues.get(cs.Id).Status != AP_Constants.caseStatusAttesaInfoAgente && OldValues.get(cs.Id).Status != AP_Constants.caseStatusPending
              				)  
             			{
             				//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- START
                			/*system.debug('csToUpdate.Time_With_Support__c: '+csToUpdate.Time_With_Support__c);
                			//if(cs.Status != AP_Constants.caseStatusSoluzioneProposta && cs.Status != AP_Constants.caseStatusAttesaInfoAgente)
                			if(csToUpdate.Time_With_Support__c!=null)
                  				csToUpdate.Time_With_Support__c = cs.Time_With_Support__c+timeSinceLastChangeOwner;
                			system.debug('csToUpdate.Time_With_Support__c after Update : '+csToUpdate.Time_With_Support__c);*/
                			//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- END
                			/*if(wrkngTimeToReturn!=null)
                			{
                				//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- START
	                			system.debug('csToUpdate.Time_With_Support__c: '+csToUpdate.Time_With_Support__c);
	                			if(csToUpdate.Time_With_Support__c!=null)
	                  				csToUpdate.Time_With_Support__c = cs.Time_With_Support__c+timeSinceLastChangeOwner;
	                			system.debug('csToUpdate.Time_With_Support__c after Update : '+csToUpdate.Time_With_Support__c);
	                			//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- END
                  				if(wrkngTimeToReturn.Time_Spent__c!=null)
                    				wrkngTimeToReturn.Time_Spent__c = wrkngTimeToReturn.Time_Spent__c+timeSinceLastChangeOwner;
                  				else
                   					wrkngTimeToReturn.Time_Spent__c = timeSinceLastChangeOwner;
                  				workingTimesToReturnList.add(wrkngTimeToReturn);
                  				system.debug('OldValues.get(cs.Id).Status--'+OldValues.get(cs.Id).Status);
			                  	//csToUpdate.Time_With_Support__c = wrkngTimeToReturn.Time_Spent__c;
			                  	//csToUpdate.Time_With_Support__c = csToUpdate.Time_With_Support__c+timeSinceLastChangeOwner;
			                  	system.debug('csToUpdate.Time_With_Support__c--'+csToUpdate.Time_With_Support__c);
                			}
              			}  
              			else if((mlstTrack.UserProfile__c == HD2Role
      							/*aggiunta code || mlstTrack.UserProfile__c == HD2QueueRole /*aggiunta code*/
      							//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
      						/*	|| mlstTrack.UserProfile__c == HD2BIZRole
      							|| mlstTrack.UserProfile__c == HD2BIZQueueRole 
      							//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
      							)  
      							//OAVERSANO 29/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
               					&& OldValues.get(cs.Id).Status != AP_Constants.caseStatusSoluzioneProposta
								   && OldValues.get(cs.Id).Status != AP_Constants.caseStatusAttesaInfoAgente
								   && OldValues.get(cs.Id).Status != AP_Constants.caseStatusPending
               					//OAVERSANO 29/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
               					&& OldValues.get(cs.Id).Status != AP_Constants.caseStatusGestioneHD3)
              			{
                			//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- START
                			/*if(csToUpdate.Durata_lavorazione_uffici_tecnici__c!=null)
                  				csToUpdate.Durata_lavorazione_uffici_tecnici__c = cs.Durata_lavorazione_uffici_tecnici__c+timeSinceLastChangeOwner;
                			else
                  				csToUpdate.Durata_lavorazione_uffici_tecnici__c = timeSinceLastChangeOwner;*/
              				//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- END
            		/*		if(wrkngTimeToReturn!=null)
                			{
                  				if(wrkngTimeToReturn.userRole__c == mlstTrack.UserRole__c)
                  				{
                  					//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- START
		                			if(csToUpdate.Durata_lavorazione_uffici_tecnici__c!=null)
		                  				csToUpdate.Durata_lavorazione_uffici_tecnici__c = cs.Durata_lavorazione_uffici_tecnici__c+timeSinceLastChangeOwner;
		                			else
		                  				csToUpdate.Durata_lavorazione_uffici_tecnici__c = timeSinceLastChangeOwner;
		              				//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- END
                    				wrkngTimeToReturn.Time_Spent__c = wrkngTimeToReturn.Time_Spent__c +timeSinceLastChangeOwner;
                    				workingTimesToReturnList.add(wrkngTimeToReturn);
                  				}
                			}
              			}
              			else if(mlstTrack.UserProfile__c == AgentRole && (OldValues.get(cs.Id).Status == AP_Constants.caseStatusSoluzioneProposta || OldValues.get(cs.Id).Status == AP_Constants.caseStatusAttesaInfoAgente || OldValues.get(cs.Id).Status == AP_Constants.caseStatusPending))
              			{
                			if(wrkngTimeToReturn!=null)
                			{
                  				wrkngTimeToReturn.Time_Spent__c = wrkngTimeToReturn.Time_Spent__c +timeSinceLastChangeOwner;
                  				workingTimesToReturnList.add(wrkngTimeToReturn);
                  				//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- START
	                			csToUpdate.Time_With_Customer__c = wrkngTimeToReturn.Time_Spent__c;
	                			//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- END
                			}
                			//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- START
                			//csToUpdate.Time_With_Customer__c = wrkngTimeToReturn.Time_Spent__c;
                			//OAVERSANO 07/02/2019 : NMA Fix Tempi di lavorazione -- END
              			}
              			else if(mlstTrack.UserProfile__c == HD3Role && OldValues.get(cs.Id).Status == AP_Constants.caseStatusGestioneHD3)
              			{
                  			//OAVERSANO 08/02/2019 : NMA Fix Tempi di lavorazione -- START
                  			/*if(csToUpdate.Tempo_in_gestione_HD3__c!=null)
                      			csToUpdate.Tempo_in_gestione_HD3__c = cs.Tempo_in_gestione_HD3__c+timeSinceLastChangeOwner;
                  			else
                      			csToUpdate.Tempo_in_gestione_HD3__c = timeSinceLastChangeOwner;*/
                      		//OAVERSANO 08/02/2019 : NMA Fix Tempi di lavorazione -- END
/*                  			if(wrkngTimeToReturn!=null)
                  			{
                  				//OAVERSANO 08/02/2019 : NMA Fix Tempi di lavorazione -- START
	                  			if(csToUpdate.Tempo_in_gestione_HD3__c!=null)
	                      			csToUpdate.Tempo_in_gestione_HD3__c = cs.Tempo_in_gestione_HD3__c+timeSinceLastChangeOwner;
	                  			else
	                      			csToUpdate.Tempo_in_gestione_HD3__c = timeSinceLastChangeOwner;
	                      		//OAVERSANO 08/02/2019 : NMA Fix Tempi di lavorazione -- END
                     			wrkngTimeToReturn.Time_Spent__c = wrkngTimeToReturn.Time_Spent__c +timeSinceLastChangeOwner;
                      			workingTimesToReturnList.add(wrkngTimeToReturn);
                  			}
              			}  
              			//if(cs.Ownerid <> OldValues.get(cs.id).Ownerid) 
                		//oldMlstTrackToReturn.SupportStartDate__c = system.now();
              			mlstTrackToReturnList.add(oldMlstTrackToReturn);
              			csListToReturn.add(csToUpdate);
              			system.debug('mlstTrackToReturnList: '+mlstTrackToReturnList);
              			break;
          			}
          		}
          		else
          		{
            		continue;
          		}
       	 	}
        	for(Milestone_Tracking__c mlstTrack: CaseMilestoneTrackingMap.get(cs.Id))
        	{
          		if(	(   
          				!ClosedStatusList.contains(cs.Status)
            			&&
            			mlstTrack.UserProfile__c == ROLEProfileMap.get(cs.Owner.Profile.Name)
            			&& 
            			mlstTrack.CaseStatus__c == cs.Status
            			&&
          				String.valueOf(cs.OwnerId).startsWith('005')
            		)
            		||
              		(	
              			mlstTrack.UserProfile__c == AgentRole 
              			&& 
              			mlstTrack.CaseStatus__c == cs.Status
              		)
            		||
              		(
              			mlstTrack.UserProfile__c == HD3Role
              			&& 
             			mlstTrack.CaseStatus__c == cs.Status
             		)
          			||
              		(
              			mlstTrack.UserProfile__c == HD1QueueRole && String.valueOf(cs.OwnerId).startsWith('00G') 
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1QueueRole
              			&& mlstTrack.CaseStatus__c == cs.Status //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
              		)
          			||
          			(
          				mlstTrack.UserProfile__c == HD2QueueRole && String.valueOf(cs.OwnerId).startsWith('00G') 
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD2QueueRole
              			&& mlstTrack.CaseStatus__c == cs.Status //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
              		)
              		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
              		||
              		(
              			mlstTrack.UserProfile__c == HD1BIZQueueRole && String.valueOf(cs.OwnerId).startsWith('00G') 
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1BIZQueueRole
              			&& mlstTrack.CaseStatus__c == cs.Status
              		)
          			||
          			(
          				mlstTrack.UserProfile__c == HD2BIZQueueRole && String.valueOf(cs.OwnerId).startsWith('00G') 
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD2BIZQueueRole
              			&& mlstTrack.CaseStatus__c == cs.Status
              		)
              		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
              		//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
              		||
              		(
              			mlstTrack.UserProfile__c == HD1ContabilitaQueueRole && String.valueOf(cs.OwnerId).startsWith('00G') 
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1ContabilitaQueueRole
              			&& mlstTrack.CaseStatus__c == cs.Status
              		)
          			||
          			(
          				mlstTrack.UserProfile__c == HD1ContenziosoQueueRole && String.valueOf(cs.OwnerId).startsWith('00G') 
              			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1ContenziosoQueueRole
              			&& mlstTrack.CaseStatus__c == cs.Status
              		)
              		||
              		(   
          				!ClosedStatusList.contains(cs.Status)
            			&&
            			mlstTrack.UserProfile__c == ROLErolesMap.get(cs.Owner.UserRole.Name)
            			&& 
            			mlstTrack.CaseStatus__c == cs.Status
            			&&
          				String.valueOf(cs.OwnerId).startsWith('005')
            		)
              		//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        		)
          		{
            		if( (  (
	              			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
	              			//ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1Role
	              			(	
	              				ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1Role
	              				&&
	              				ROLErolesMap.get(ownerIdRoleNameMap.get(cs.OwnerId))!=HD1ContabilitaRole
	              				&&
	              				ROLErolesMap.get(ownerIdRoleNameMap.get(cs.OwnerId))!=HD1ContenziosoRole
	              			)
	              			//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
	              			||
	                		(ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD2Role
	                		&&
	                		mlstTrack.UserRole__c == ownerIdRoleNameMap.get(cs.OwnerId)
	            			)
			              	/*||
			              	ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==AgentRole*/
			              	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
			    /*          	||
			              	ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1BIZRole
	              			||
	                		(ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD2BIZRole
	                		&&
	                		mlstTrack.UserRole__c == ownerIdRoleNameMap.get(cs.OwnerId)
	            			)
			              	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
			              	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
			              	||
			              	ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1ContabilitaRole
			              	||
			              	ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1ContenziosoRole
			              	||
			              	ROLErolesMap.get(ownerIdRoleNameMap.get(cs.OwnerId))==HD1ContabilitaRole
			              	||
			              	ROLErolesMap.get(ownerIdRoleNameMap.get(cs.OwnerId))==HD1ContenziosoRole
			              	//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
			              	)
          					&&
              				mlstTrack.Owner__c == cs.OwnerId
            			)
            			||
	              		(	
	              			mlstTrack.UserProfile__c==AgentRole
	                		&&
	                		(cs.Status == AP_Constants.caseStatusSoluzioneProposta 
	                		|| 
							cs.Status == AP_Constants.caseStatusAttesaInfoAgente
							|| 
							cs.Status == AP_Constants.caseStatusPending)
              			)
            			||
              			(
              				mlstTrack.UserProfile__c==HD3Role
                			&&
                			cs.Status == AP_Constants.caseStatusGestioneHD3 
                            &&
                            cs.HD3_IT__c == OldValues.get(cs.Id).HD3_IT__c
             			)
              			/*aggiunta code*/
            /*			||
                		(
                			mlstTrack.UserProfile__c == HD1QueueRole
                			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1QueueRole
            			)
          				||
                		(
                			mlstTrack.UserProfile__c == HD2QueueRole
                			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD2QueueRole
                		)
                		/*aggiunta code*/
                		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
              /*  		||
                		(
                			mlstTrack.UserProfile__c == HD1BIZQueueRole
                			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1BIZQueueRole
            			)
          				||
                		(
                			mlstTrack.UserProfile__c == HD2BIZQueueRole
                			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD2BIZQueueRole
                		)
                		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
                		//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                		||
                		(
                			mlstTrack.UserProfile__c == HD1ContabilitaQueueRole
                			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1ContabilitaQueueRole
            			)
          				||
                		(
                			mlstTrack.UserProfile__c == HD1ContenziosoQueueRole
                			&& ROLEProfileMap.get(ownerIdProfileNameMap.get(cs.OwnerId))==HD1ContenziosoQueueRole
                		)
                		//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        			)
          			{
              			system.debug('Record trovato');
              			trackingFoundCS = true;
              			mlstTrackToReturn = mlstTrack;
              			//if(trackingFoundOldCS == false && cs.Ownerid <> OldValues.get(cs.id).Ownerid)
              			mlstTrackToReturn.SupportStartDate__c = System.now();
              			if(ownerIdProfileNameMap.get(cs.OwnerId) != ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))
              			{
                			Case csToUpdate;
                			system.debug('2 ## idCaseMap: '+idCaseMap);
              				if(idCaseMap.containsKey(cs.Id))
                			{
                  				csToUpdate = idCaseMap.geT(cs.Id);
                			}
                			else
                			{
                  				csToUpdate = cs;
                  				idCaseMap.put(cs.Id, cs);
            				}
                			csToUpdate.CaseMilestone_StartDate__c = System.now();
                			csListToReturn.add(csToUpdate);
                			system.debug('entrato in cambio startdate');
              			}
              
              			/***********/
              /*			system.debug('(String.valueOf(OldValues.get(cs.Id).OwnerId)): '+(String.valueOf(OldValues.get(cs.Id).OwnerId)));
              			system.debug('ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId): '+ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId));
              			system.debug('HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId)): '+ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId));
              			if(		(String.valueOf(OldValues.get(cs.Id).OwnerId)).startsWith('00G') 
        						&& 
            					(   
            						((HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ProfileSet.contains(cs.Owner.Profile.Name) && !HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name) && !HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name))
              						|| 
              						((HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD2ProfileSet.contains(cs.Owner.Profile.Name))
              						//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
              						||
              						((HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1BIZProfileSet.contains(cs.Owner.Profile.Name))
              						|| 
              						((HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD2BIZProfileSet.contains(cs.Owner.Profile.Name))
              						//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
              						//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
              						|| 
              						((HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContabilitaProfileSet.contains(cs.Owner.Profile.Name))
              						|| 
              						((HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name))
              						|| 
              						((HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContenziosoProfileSet.contains(cs.Owner.Profile.Name))
              						|| 
              						((HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name))
              						//OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
              					) 
            				)
            			{
              				Milestone_Tracking__c mlstTrackQueue; 
              				for(Milestone_Tracking__c mlstTrackInt: CaseMilestoneTrackingMap.get(OldValues.get(cs.Id).Id))
                			{
                  				system.debug('@@##mlstTrack: '+mlstTrackInt);
                  				//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                  				if(HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId)) || HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId)) )
                  				{
                  					if(mlstTrackInt.UserProfile__c == ROLErolesMap.get(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId)) 
                  					&& mlstTrackInt.CaseStatus__c == OldValues.get(cs.Id).Status)
                  					{
                    					mlstTrackQueue = mlstTrackInt;
                  					}
                  				}
                  				else
                  				{
                  					if(mlstTrackInt.UserProfile__c == ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId)) 
		              				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
		              				&& mlstTrackInt.CaseStatus__c == OldValues.get(cs.Id).Status) 
		              				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
		              				
		              				{
		                				mlstTrackQueue = mlstTrackInt;
		              				}
                  				}
                  				//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                			}
                			if(mlstTrackQueue!=null)
            				{
                				Double timeQueue = BusinessHours.diff(defaultHoursId, mlstTrackQueue.SupportStartDate__c, System.now())/3600000.0;
								mlstTrackToReturn.TimeSpent__c += timeQueue;
								mlstTrackToReturn.SupportEndDate__c = system.now();
                				Working_Times__c wrkgTimeQueue;
                				if(mlstnTrackWorkingTimeMap.get(mlstTrackToReturn.Id)!=null)
                				{
                  					system.debug('mlstnTrackWorkingTimeMap.get(mlstTrackToReturn.Id)'+mlstnTrackWorkingTimeMap.get(mlstTrackToReturn.Id));
                  					wrkgTimeQueue = mlstnTrackWorkingTimeMap.get(mlstTrackToReturn.Id);
                  					wrkgTimeQueue.Time_Spent__c += timeQueue;
                  					workingTimesToReturnList.add(wrkgTimeQueue);
                				}
                			}
            			}        
              			/***********/
              /*			caseIdSet.add(cs.Id);
              			mlstTrackToReturnList.add(mlstTrackToReturn);
              			system.debug('mlstTrackToReturnListaftrer: '+mlstTrackToReturnList);
              			break;
          			}
          		}
          		else
          		{
            		continue;
          		}
    		}
      	}
      	if((trackingFoundCS == false || !CaseMilestoneTrackingMap.containsKey(cs.Id)))
      	{
        	system.debug('inizializzazione');
        	if(cs.Status == AP_Constants.caseStatusGestioneHD3  && String.valueOf(cs.OwnerId).startsWith('005') )
        	{
          		mlstTrackToReturn = new Milestone_Tracking__c(Case__c = cs.Id,
                          CaseStatus__c = AP_Constants.caseStatusGestioneHD3,
                          UserProfile__c = HD3Role,
						  TimeSpent__c  = 0,
						  Gruppo_di_lavoro__c = (cs.HD3_IT__c != null)? cs.HD3_IT__c:'',
                          SupportStartDate__c = system.now(),
						  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
				ModelloDiAssistenzaUtils.setCaseHistory(mlstTrackToReturn, cs, OldValues.get(cs.Id));
        		mlstTrackToReturnList.add(mlstTrackToReturn);
    		}
        	else if((cs.Status == AP_Constants.caseStatusSoluzioneProposta || cs.Status == AP_Constants.caseStatusAttesaInfoAgente || cs.Status == AP_Constants.caseStatusPending)  && String.valueOf(cs.OwnerId).startsWith('005') )
        	{
          		mlstTrackToReturn = new Milestone_Tracking__c(Case__c = cs.Id,
                          CaseStatus__c = cs.Status,
                          UserProfile__c = AgentRole,
						  TimeSpent__c  = 0,
						  Gruppo_di_lavoro__c = (cs.Status == AP_Constants.caseStatusAttesaInfoAgente && (cs.RecordTypeId != null && cs.RecordType.DeveloperName == AP_Constants.rtCaseAssistenzaAgenti))?'Agent': (cs.Current_Owner_Queue__c != null)? cs.Current_Owner_Queue__c.replace('_',' '):'',
                          SupportStartDate__c = system.now(),
						  RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
				ModelloDiAssistenzaUtils.setCaseHistory(mlstTrackToReturn, cs, OldValues.get(cs.Id));
        		mlstTrackToReturnList.add(mlstTrackToReturn);
        	}
        	else if( String.valueOf(cs.OwnerId).startsWith('00G') )
    		{
          		system.debug('cs.Owner.Profile.Name: '+cs.Owner.Profile.Name);
          		system.debug('HD1QueueSet: '+HD1QueueSet);
          		mlstTrackToReturn = new Milestone_Tracking__c(Case__c = cs.Id,
                          CaseStatus__c = cs.Status,
                          //UserProfile__c = (HD1QueueSet.contains(cs.Owner.Name))?HD1QueueRole:(HD2QueueSet.contains(cs.Owner.Name))?HD2QueueRole:(HD1BIZQueueSet.contains(cs.Owner.Name))?HD1BIZQueueRole:(HD2BIZQueueSet.contains(cs.Owner.Name))?HD2BIZQueueRole:'', //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 | US-0911
                          UserProfile__c = (HD1QueueSet.contains(cs.Owner.Name))?HD1QueueRole:(HD2QueueSet.contains(cs.Owner.Name))?HD2QueueRole:(HD1BIZQueueSet.contains(cs.Owner.Name))?HD1BIZQueueRole:(HD2BIZQueueSet.contains(cs.Owner.Name))?HD2BIZQueueRole:(HD1ContabilitaQueueRole.contains(cs.Owner.Name))?HD1ContabilitaQueueRole:(HD1ContenziosoQueueRole.contains(cs.Owner.Name))?HD1ContenziosoQueueRole:'', //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
						  TimeSpent__c  = 0,
						  Gruppo_di_lavoro__c = (cs.Current_Owner_Queue__c != null)?cs.Current_Owner_Queue__c.contains('Coda_Agenzia_Case')?'Agent':cs.Current_Owner_Queue__c.replace('_',' '):(cs.RecordTypeId != null && cs.RecordType.DeveloperName == AP_Constants.rtCaseAAI)?AP_Constants.rtCaseAAI.replace('_',' '):'',
                          SupportStartDate__c = system.now(),
                          RecordTypeWorkingItem__c = AP_Constants.rtWorkTimCoda,
						  OwnerId = IdAdministrator);
				ModelloDiAssistenzaUtils.setCaseHistory(mlstTrackToReturn, cs, OldValues.get(cs.Id));
        		mlstTrackToReturnList.add(mlstTrackToReturn);
        	}
        	else
        	{
                system.debug('Current Owner queue attuale: '+cs.Current_Owner_Queue__c);
                system.debug('Record Type DeveloperName: '+cs.RecordType.DeveloperName);
				String tempRole = (HD2ProfileSet.contains(cs.Owner.Profile.Name))?cs.Owner.UserRole.Name:(HD2BIZProfileSet.contains(cs.Owner.Profile.Name))?cs.Owner.UserRole.Name:'';
          		mlstTrackToReturn = new Milestone_Tracking__c(Case__c = cs.Id,
                            CaseStatus__c = (cs.Status==AP_Constants.caseStatusOpen)?AP_Constants.caseStatusAssigned:cs.Status,
                            //UserProfile__c = (HD1ProfileSet.contains(cs.Owner.Profile.Name))?HD1Role:(HD2ProfileSet.contains(cs.Owner.Profile.Name))?HD2Role:(HD1BIZProfileSet.contains(cs.Owner.Profile.Name))?HD1BIZRole:(HD2BIZProfileSet.contains(cs.Owner.Profile.Name))?HD2BIZRole:'', //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 | US-09
							
							UserRole__c = cs.Owner.Profile.Name.contains('HD1')?cs.Owner.UserRole.Name:tempRole,
							Gruppo_di_lavoro__c = (cs.Current_Owner_Queue__c != null)? cs.Current_Owner_Queue__c.replace('_',' '):(cs.RecordTypeId != null && cs.RecordType.DeveloperName == AP_Constants.rtCaseAssistenzaAgenti)?AP_Constants.rtCaseAAI.replace('_',' '):'',
							OwnerId = cs.OwnerId,
                            Owner__c = cs.OwnerId,
                            SupportStartDate__c = system.now(),
							RecordTypeWorkingItem__c = AP_Constants.rtWorkTimUser);
				ModelloDiAssistenzaUtils.setCaseHistory(mlstTrackToReturn, cs, OldValues.get(cs.Id));
                //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                if( HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name) )
                {
                	mlstTrackToReturn.UserProfile__c = HD1ContabilitaRole;
                }
                else if( HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name) )
                {
                	mlstTrackToReturn.UserProfile__c = HD1ContenziosoRole;
                }
                else
                {
                	mlstTrackToReturn.UserProfile__c = (HD1ProfileSet.contains(cs.Owner.Profile.Name))?HD1Role:(HD2ProfileSet.contains(cs.Owner.Profile.Name))?HD2Role:(HD1BIZProfileSet.contains(cs.Owner.Profile.Name))?HD1BIZRole:(HD2BIZProfileSet.contains(cs.Owner.Profile.Name))?HD2BIZRole:(HD1ContabilitaProfileSet.contains(cs.Owner.Profile.Name))?HD1ContabilitaRole:(HD1ContenziosoProfileSet.contains(cs.Owner.Profile.Name))?HD1ContenziosoRole:'';
                }
                //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END           
        		system.debug('(String.valueOf(OldValues.get(cs.Id).OwnerId)): '+(String.valueOf(OldValues.get(cs.Id).OwnerId)));
        		system.debug('ownerIdProfileNameMap.get(cs.OwnerId): '+ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId));
        		if(		(String.valueOf(OldValues.get(cs.Id).OwnerId)).startsWith('00G') 
          			&& 
            		(   
            			((HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ProfileSet.contains(cs.Owner.Profile.Name) && !HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name) && !HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name) ) 
            			|| 
            			((HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD2ProfileSet.contains(cs.Owner.Profile.Name))
        				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
        				||
        				((HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1BIZProfileSet.contains(cs.Owner.Profile.Name)) 
            			|| 
            			((HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD2BIZProfileSet.contains(cs.Owner.Profile.Name))
        				//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
        				//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
  						|| 
  						((HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContabilitaProfileSet.contains(cs.Owner.Profile.Name))
  						|| 
  						((HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name))
  						|| 
  						((HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContenziosoProfileSet.contains(cs.Owner.Profile.Name))
  						|| 
  						((HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId))) && HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name))
  						//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        			) 
          		)
          		{
            		Milestone_Tracking__c mlstTrackQueue; 
            		if(CaseMilestoneTrackingMap.get(OldValues.get(cs.Id).Id)!=null)
            		{
              			for(Milestone_Tracking__c mlstTrack: CaseMilestoneTrackingMap.get(OldValues.get(cs.Id).Id))
                		{
                  			system.debug('@@##mlstTrack: '+mlstTrack);
                  			//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                  			if( HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId)) || HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId)) )
                			{
                				if(mlstTrack.UserProfile__c == ROLErolesMap.get(ownerIdRoleNameMap.get(OldValues.get(cs.Id).OwnerId)))	
                				{
	                   				mlstTrackQueue = mlstTrack;
	                 	 		}
                			}
                  			else
                  			{
                  				if(mlstTrack.UserProfile__c == ROLEProfileMap.get(ownerIdProfileNameMap.get(OldValues.get(cs.Id).OwnerId)))
	                  			{
	                   				mlstTrackQueue = mlstTrack;
	                 	 		}
                  			}
                 	 		//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                		}
            		}
              		if(mlstTrackQueue!=null)
              		{
              			Double timeQueue = BusinessHours.diff(defaultHoursId, mlstTrackQueue.SupportStartDate__c, System.now())/3600000.0;
						  mlstTrackToReturn.TimeSpent__c = timeQueue;
						  mlstTrackToReturn.SupportEndDate__c = system.now();
              		}
              		else
              		{
               			mlstTrackToReturn.TimeSpent__c = 0;
              		}
          		}        
        		else
          			mlstTrackToReturn.TimeSpent__c = 0;
        		mlstTrackToReturnList.add(mlstTrackToReturn);
    		}
  			cs.CaseMilestone_StartDate__c = System.now();
  			caseIdSet.add(cs.Id);
      		csListToReturn.add(cs);
  		}
      	objCont.mlstTrackList = mlstTrackToReturnList;
      	objCont.CsList = csListToReturn;
      	objCont.CsMilestoneList = csMilestoneListToReturn;
      	objCont.idCaseMap = idCaseMap;
      	objcont.WrkTimesList = workingTimesToReturnList;
      	objCont.caseIdSet = caseIdSet;
      	system.debug('MILESTONETracking END');
      	return objCont;
	}
    */
    public class updateCase implements Queueable 
    {
      	private Set<id> setId; 
      	private Map<String,Case> OldValues;
      	private Set<String> AgentProfileSet; 
      	private Set<String> HD1ProfileSet; 
      	private Set<String> HD2ProfileSet;
  		private Set<String> HD1BIZProfileSet; 
  		private Set<String> HD2BIZProfileSet;
  		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
  		private Set<String> HD1ContabilitaProfileSet; 
      	private Set<String> HD1ContabilitaRoleSet;
  		private Set<String> HD1ContenziosoProfileSet; 
  		private Set<String> HD1ContenziosoRoleSet;
  		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
              
        //public updateCase(Set<id> setId, Map<String,Case> OldValues, Set<String> AgentProfileSet, Set<String> HD1ProfileSet, Set<String> HD2ProfileSet, Set<String> HD1BIZProfileSet, Set<String> HD2BIZProfileSet)  //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
        public updateCase(Set<id> setId, Map<String,Case> OldValues, Set<String> AgentProfileSet, Set<String> HD1ProfileSet, Set<String> HD2ProfileSet, Set<String> HD1BIZProfileSet, Set<String> HD2BIZProfileSet, Set<String> HD1ContabilitaProfileSet, Set<String> HD1ContabilitaRoleSet, Set<String> HD1ContenziosoProfileSet, Set<String> HD1ContenziosoRoleSet)  //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 
        {
          	this.setId = setId;
          	this.OldValues = OldValues;
        	this.AgentProfileSet = AgentProfileSet;
        	this.HD1ProfileSet = HD1ProfileSet;
        	this.HD2ProfileSet = HD2ProfileSet;
        	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
        	this.HD1BIZProfileSet = HD1BIZProfileSet;
        	this.HD2BIZProfileSet = HD2BIZProfileSet;
        	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END 
        	//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
        	this.HD1ContabilitaProfileSet = HD1ContabilitaProfileSet;
        	this.HD1ContabilitaRoleSet = HD1ContabilitaRoleSet;
        	this.HD1ContenziosoProfileSet = HD1ContenziosoProfileSet;
        	this.HD1ContenziosoRoleSet = HD1ContenziosoRoleSet;
        	//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
        }
              
     	public void execute(QueueableContext queCont) 
     	{
          	List<Case> lstCase = [SELECT Id, MilestoneFlag__c  FROM CASE WHERE id in :setId ];
      		for( Case c : lstCase )
      		{
        		if(c.MilestoneFlag__c == false)
          			c.MilestoneFlag__c = true;
        		else
          			c.MilestoneFlag__c = false;
        	}
       		update lstCase;
        	if(!Test.isRunningTest())
          		//System.enqueueJob(new updateCaseMilestone(setId, OldValues, AgentProfileSet, HD1ProfileSet, HD2ProfileSet, HD1BIZProfileSet, HD2BIZProfileSet)); //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911
          		System.enqueueJob(new updateCaseMilestone(setId, OldValues, AgentProfileSet, HD1ProfileSet, HD2ProfileSet, HD1BIZProfileSet, HD2BIZProfileSet, HD1ContabilitaProfileSet, HD1ContabilitaRoleSet, HD1ContenziosoProfileSet, HD1ContenziosoRoleSet)); //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
     	}
  	}

  	public class updateCaseMilestone implements Queueable 
  	{
 		private Set<id> setId; 
      	private Map<String,Case> OldValues;
      	private Set<String> AgentProfileSet; 
      	private Set<String> HD1ProfileSet; 
      	private Set<String> HD2ProfileSet;
        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
        private Set<String> HD1BIZProfileSet; 
      	private Set<String> HD2BIZProfileSet;
        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
  		private Set<String> HD1ContabilitaProfileSet; 
      	private Set<String> HD1ContabilitaRoleSet;
  		private Set<String> HD1ContenziosoProfileSet; 
  		private Set<String> HD1ContenziosoRoleSet;
  		//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
        
   		//public updateCaseMilestone(Set<id> setId, Map<String,Case> OldValues, Set<String> AgentProfileSet, Set<String> HD1ProfileSet, Set<String> HD2ProfileSet, Set<String> HD1BIZProfileSet, Set<String> HD2BIZProfileSet) //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84
       	public updateCaseMilestone(Set<id> setId, Map<String,Case> OldValues, Set<String> AgentProfileSet, Set<String> HD1ProfileSet, Set<String> HD2ProfileSet, Set<String> HD1BIZProfileSet, Set<String> HD2BIZProfileSet, Set<String> HD1ContabilitaProfileSet, Set<String> HD1ContabilitaRoleSet, Set<String> HD1ContenziosoProfileSet, Set<String> HD1ContenziosoRoleSet)  //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
       	{ 
        	this.setId = setId;
        	this.OldValues = OldValues;
        	this.AgentProfileSet = AgentProfileSet;
        	this.HD1ProfileSet = HD1ProfileSet;
        	this.HD2ProfileSet = HD2ProfileSet;
        	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
        	this.HD1BIZProfileSet = HD1BIZProfileSet;
        	this.HD2BIZProfileSet = HD2BIZProfileSet;
        	//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
        	//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
        	this.HD1ContabilitaProfileSet = HD1ContabilitaProfileSet;
        	this.HD1ContabilitaRoleSet = HD1ContabilitaRoleSet;
        	this.HD1ContenziosoProfileSet = HD1ContenziosoProfileSet;
        	this.HD1ContenziosoRoleSet = HD1ContenziosoRoleSet;
        	//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
  		}
              
     	public void execute(QueueableContext queCont) 
     	{
           	Set<CaseMilestone> caseMilestonesToUpdate = new Set<CaseMilestone>();
           	List<Working_Times__c> workingTimeList = new List<Working_Times__c>([SELECT Id, Case__c, UserProfile__c, 
                                          UserRole__c, Time_Spent__c 
                                          FROM Working_Times__c 
                                          WHERE Case__c IN:setId]);
      		Map<String, List<Working_Times__c>> caseIdWorkingItemMap = new Map<String, List<Working_Times__c>>();
      		for(Working_Times__c wrkTime: workingTimeList)
      		{
        		if(caseIdWorkingItemMap.containsKey((String)wrkTime.Case__c)) 
                {
          			List<Working_Times__c> WrkTimeList = caseIdWorkingItemMap.get((String)wrkTime.Case__c);
          			WrkTimeList.add(wrkTime);
          			caseIdWorkingItemMap.put((String)wrkTime.Case__c, WrkTimeList);
    			} 
        		else 
        		{
          			caseIdWorkingItemMap.put((String)wrkTime.Case__c, new List<Working_Times__c> { wrkTime });
        		}
      		}
      		List<Case> lstCase = [SELECT Id, Current_Owner_Queue__c, Status, CaseMilestone_StartDate__c, Owner.Profile.Name, 
                	RecordType.DeveloperName, OwnerId, Owner.UserRole.Name,
                    Time_With_Support__c, Time_With_Customer__c, 
                    MilestoneFlag__c, isClosed, Durata_lavorazione_uffici_tecnici__c,
                    (SELECT id, StartDate, CompletionDate, IsCompleted
                    FROM CaseMilestones 
                    WHERE IsCompleted = false) 
                    FROM Case 
                    WHERE Id IN:setId];
      		Map<String, CaseMilestone> idCaseMilestoneMap = new Map<String, CaseMilestone>();
      		for( Case cs : lstCase )
      		{
        		if(!cs.isClosed)
          		{
            		if(!cs.CaseMilestones.isEmpty())
            		{
              			for(CaseMilestone csMilestone: cs.CaseMilestones)
              			{
              				//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
               				//if(HD1ProfileSet.contains(cs.Owner.Profile.Name))
               				if(HD1ProfileSet.contains(cs.Owner.Profile.Name) && !HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name) && !HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name))
                			//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                			{
                  				system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                  				if(caseIdWorkingItemMap.get(cs.Id)!=null)
                  				{
                    				Double timeToCut = 0;
                    				for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                    				{
                      					if(wrkTime.UserProfile__c == HD1Role)
                      					{
                          					timeToCut += wrkTime.Time_Spent__c;
                          					break;
                      					}
                    				}
                    				if(timeToCut!=0)
                    				{
				                      	system.debug('cs.CaseMilestone_StartDate__c : '+cs.CaseMilestone_StartDate__c);
				                      	csMilestone.StartDate = system.now().addMinutes(-(Integer.valueOf((timeToCut)*60)) );
				                      	caseMilestonesToUpdate.add(csMilestone);
				                      	system.debug('timeToCut: '+timeToCut*60);
                    				}
                  				}
                			}
                			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
                			else if(HD1BIZProfileSet.contains(cs.Owner.Profile.Name))
                			{
                  				system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                  				if(caseIdWorkingItemMap.get(cs.Id)!=null)
                  				{
                    				Double timeToCut = 0;
                    				for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                    				{
                      					if(wrkTime.UserProfile__c == HD1BIZRole)
                      					{
                          					timeToCut += wrkTime.Time_Spent__c;
                          					break;
                      					}
                    				}
                    				if(timeToCut!=0)
                    				{
				                      	system.debug('cs.CaseMilestone_StartDate__c : '+cs.CaseMilestone_StartDate__c);
				                      	csMilestone.StartDate = system.now().addMinutes(-(Integer.valueOf((timeToCut)*60)) );
				                      	caseMilestonesToUpdate.add(csMilestone);
				                      	system.debug('timeToCut: '+timeToCut*60);
                    				}
                  				}
                			}
                			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
                			else if(HD2ProfileSet.contains(cs.Owner.Profile.Name))
                			{
                  				system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                  				if(caseIdWorkingItemMap.get(cs.Id)!=null)
                  				{
                    				Double timeToCut = 0;
                    				system.debug('cs.Owner.UserRole.Name: '+cs.Owner.UserRole.Name);
                    				for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                    				{
                      					system.debug('wrkTime.UserProfile__c: '+wrkTime.UserProfile__c);
                      					if(	wrkTime.UserProfile__c == HD2Role
                        					&&
                        					wrkTime.UserRole__c == cs.Owner.UserRole.Name)
                      					{
	                          				timeToCut += wrkTime.Time_Spent__c;
	                          				break;
                      					}
              						}
                    				if(timeToCut!=0)
                    				{
                      					system.debug('cs.CaseMilestone_StartDate__c : '+cs.CaseMilestone_StartDate__c);
                      					csMilestone.StartDate = system.now().addMinutes(-(Integer.valueOf((timeToCut)*60)) );
                      					caseMilestonesToUpdate.add(csMilestone);
                      					system.debug('timeToCut: '+timeToCut*60);
                    				}
                  				}
                			}
                			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
                			else if(HD2BIZProfileSet.contains(cs.Owner.Profile.Name))
                			{
                  				system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                  				if(caseIdWorkingItemMap.get(cs.Id)!=null)
                  				{
                    				Double timeToCut = 0;
                    				system.debug('cs.Owner.UserRole.Name: '+cs.Owner.UserRole.Name);
                    				for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                    				{
                      					system.debug('wrkTime.UserProfile__c: '+wrkTime.UserProfile__c);
                      					if(	wrkTime.UserProfile__c == HD2BIZRole
                        					&&
                        					wrkTime.UserRole__c == cs.Owner.UserRole.Name)
                      					{
	                          				timeToCut += wrkTime.Time_Spent__c;
	                          				break;
                      					}
              						}
                    				if(timeToCut!=0)
                    				{
                      					system.debug('cs.CaseMilestone_StartDate__c : '+cs.CaseMilestone_StartDate__c);
                      					csMilestone.StartDate = system.now().addMinutes(-(Integer.valueOf((timeToCut)*60)) );
                      					caseMilestonesToUpdate.add(csMilestone);
                      					system.debug('timeToCut: '+timeToCut*60);
                    				}
                  				}
                			}
                			//OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END
                			//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                			if(HD1ContabilitaProfileSet.contains(cs.Owner.Profile.Name) || HD1ContabilitaRoleSet.contains(cs.Owner.UserRole.Name))
                			{
                  				system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                  				if(caseIdWorkingItemMap.get(cs.Id)!=null)
                  				{
                    				Double timeToCut = 0;
                    				for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                    				{
                      					if(wrkTime.UserProfile__c == HD1ContabilitaRole)
                      					{
                          					timeToCut += wrkTime.Time_Spent__c;
                          					break;
                      					}
                    				}
                    				if(timeToCut!=0)
                    				{
				                      	system.debug('cs.CaseMilestone_StartDate__c : '+cs.CaseMilestone_StartDate__c);
				                      	csMilestone.StartDate = system.now().addMinutes(-(Integer.valueOf((timeToCut)*60)) );
				                      	caseMilestonesToUpdate.add(csMilestone);
				                      	system.debug('timeToCut: '+timeToCut*60);
                    				}
                  				}
                			}
                			if(HD1ContenziosoProfileSet.contains(cs.Owner.Profile.Name) || HD1ContenziosoRoleSet.contains(cs.Owner.UserRole.Name))
                			{
                  				system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                  				if(caseIdWorkingItemMap.get(cs.Id)!=null)
                  				{
                    				Double timeToCut = 0;
                    				for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                    				{
                      					if(wrkTime.UserProfile__c == HD1ContenziosoRole)
                      					{
                          					timeToCut += wrkTime.Time_Spent__c;
                          					break;
                      					}
                    				}
                    				if(timeToCut!=0)
                    				{
				                      	system.debug('cs.CaseMilestone_StartDate__c : '+cs.CaseMilestone_StartDate__c);
				                      	csMilestone.StartDate = system.now().addMinutes(-(Integer.valueOf((timeToCut)*60)) );
				                      	caseMilestonesToUpdate.add(csMilestone);
				                      	system.debug('timeToCut: '+timeToCut*60);
                    				}
                  				}
                			}
                			//OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
              			}
            		}
          		}
    		}
        	List<CaseMilestone> caseMilestonesListToUpdate = new List<CaseMilestone>();
        	if(!caseMilestonesToUpdate.isEmpty())
        	{
          		system.debug('caseMilestonesToUpdate: '+caseMilestonesToUpdate);
          		caseMilestonesListToUpdate.addAll(caseMilestonesToUpdate);
          		update caseMilestonesListToUpdate;
    		}              
     	}
	}
  	//OAVERSANO 26/07/2018: Nuovo Modello di Assistenza -- END  US-0769

  	//MDANTONIO 05/04/2019 : destinatario commento - start
    public static String getDestinatario(String userProfileLogged, String userRoleLogged, String ownerId){
        String destinatario;
        Set<String> HD1PQSet = new Set<String>();
        Set<String> HD2PQSet = new Set<String>();
        Set<String> HD1BIZPQSet = new Set<String>();
        Set<String> HD2BIZPQSet = new Set<String>();
        Set<String> HD1ContabilitaPQSet = new Set<String>();
        Set<String> HD1ContabilitaRoleSet = new Set<String>();
        Set<String> HD1ContenziosoPQSet = new Set<String>();
        Set<String> HD1ContenziosoRoleSet = new Set<String>();
        List<Modello_di_Assistenza__mdt> mdAssList = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                         HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                         HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c, Value__c
                                         FROM Modello_di_Assistenza__mdt
                                         WHERE DeveloperName IN ('ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue')
                                         ];
    	System.debug('===> userProfileLogged: ' + userProfileLogged);
    	System.debug('===> userRoleLogged: ' + userRoleLogged);
    	System.debug('===> ownerid: ' + ownerId);
        for(Modello_di_Assistenza__mdt mdAss : mdAssList)
        {
            if(mdAss.DeveloperName == 'ProfileManagement')
            {
                if(String.isNotBlank(mdAss.HD1Profile__c))
                {
                    for(String s:mdAss.HD1Profile__c.split(';'))
                    {
                        HD1PQSet.add(s);
                    } 
                }
                if(String.isNotBlank(mdAss.HD1Queue__c))
                {
                    for(String s:mdAss.HD1Queue__c.split(';'))
                    {
                        HD1PQSet.add(s); 
                    }
                }
                if(String.isNotBlank(mdAss.HD2Profile__c))
                {
                    for(String s:mdAss.HD2Profile__c.split(';'))
                    {
                        HD2PQSet.add(s);
                    }
                }
                if(String.isNotBlank(mdAss.HD2Queue__c))
                {
                    for(String s:mdAss.HD2Queue__c.split(';'))
                    {
                        HD2PQSet.add(s); 
                    }
                }
                if(String.isNotBlank(mdAss.HD1BIZProfile__c))
                {
                    for(String s:mdAss.HD1BIZProfile__c.split(';'))
                    {
                        HD1BIZPQSet.add(s);
                    } 
                }
                if(String.isNotBlank(mdAss.HD1BIZQueue__c))
                {
                    for(String s:mdAss.HD1BIZQueue__c.split(';'))
                    {
                        HD1BIZPQSet.add(s); 
                    }
                }
                if(String.isNotBlank(mdAss.HD2BIZProfile__c))
                {
                    for(String s:mdAss.HD2BIZProfile__c.split(';'))
                    {
                        HD2BIZPQSet.add(s);
                    }
                }
                if(String.isNotBlank(mdAss.HD2BIZQueue__c))
                {
                    for(String s:mdAss.HD2BIZQueue__c.split(';'))
                    {
                        HD2BIZPQSet.add(s); 
                    }
                }
            }
            else if(mdAss.DeveloperName == 'HD1ContabilitaProfile')
            {
                if(String.isNotBlank(mdAss.Value__c))
                {
                    for(String s:mdAss.Value__c.split(';'))
                    {
                        HD1ContabilitaPQSet.add(s);
                    }
                }
            }
            else if(mdAss.DeveloperName == 'HD1ContabilitaRole')
            {
                if(String.isNotBlank(mdAss.Value__c))
                {
                    for(String s:mdAss.Value__c.split(';'))
                    {
                        HD1ContabilitaRoleSet.add(s);
                    }
                }
            }
            else if(mdAss.DeveloperName == 'HD1ContenziosoProfile')
            {
                if(String.isNotBlank(mdAss.Value__c))
                {
                    for(String s:mdAss.Value__c.split(';'))
                    {
                        HD1ContenziosoPQSet.add(s);
                    }
                }
            }
            else if(mdAss.DeveloperName == 'HD1ContenziosoRole')
            {
                if(String.isNotBlank(mdAss.Value__c))
                {
                    for(String s:mdAss.Value__c.split(';'))
                    {
                        HD1ContenziosoRoleSet.add(s);
                    }
                }
            }
            else if(mdAss.DeveloperName == 'HD1ContabilitaQueue')
            {
                if(String.isNotBlank(mdAss.Value__c))
                {
                    for(String s:mdAss.Value__c.split(';'))
                    {
                        HD1ContabilitaPQSet.add(s);
                    }
                }
            }
            else if(mdAss.DeveloperName == 'HD1ContenziosoQueue')
            {
                if(String.isNotBlank(mdAss.Value__c))
                {
                    for(String s:mdAss.Value__c.split(';'))
                    {
                        HD1ContenziosoPQSet.add(s);
                    }
                }
            }
        }

        if((HD1ContabilitaPQSet.contains(userProfileLogged)) || (ownerid.startsWith('005') && HD1PQSet.contains(userProfileLogged) && HD1ContabilitaRoleSet.contains(userRoleLogged))){
            destinatario = 'Primo Livello Contabilità';
        }
        else if(HD1ContenziosoPQSet.contains(userProfileLogged) || (ownerid.startsWith('005') && HD1PQSet.contains(userProfileLogged) && HD1ContenziosoRoleSet.contains(userRoleLogged))){
            destinatario = 'Primo Livello Contenzioso';
        }
        else if(HD1PQSet.contains(userProfileLogged) && !HD1ContabilitaRoleSet.contains(userRoleLogged) && !HD1ContenziosoRoleSet.contains(userRoleLogged)){
            destinatario = 'Primo Livello IT';
        }
        else if(HD2PQSet.contains(userProfileLogged)){
            destinatario = 'Secondo Livello IT';
        }
        else if(HD1BIZPQSet.contains(userProfileLogged)){
            destinatario = 'Primo Livello Business';
        }
        else if(HD2BIZPQSet.contains(userProfileLogged)){
            destinatario = 'Secondo Livello Business';
        }

        return destinatario;
    }
	//MDANTONIO 05/04/2019 : destinatario commento - end
	
	public static void setCaseHistory(Milestone_Tracking__c milestoneTrackingToUpsert, Case newCase, Case oldCase){
		milestoneTrackingToUpsert.Case_Last_Modified_By__c = newCase.LastModifiedById;  
		//milestoneTrackingToUpsert.Case_Owner__c = newCase.OwnerId;  
		if(string.valueOf(newCase.OwnerId).startsWith('005')){
			//owner is User
			milestoneTrackingToUpsert.Case_Owner_Name__c = newCase.Owner.FirstName + ' ' + newCase.Owner.LastName;
       	} else if(string.valueOf(newCase.OwnerId).startsWith('00G')) {
			//owner is Queue 
			milestoneTrackingToUpsert.Case_Owner_Name__c = newCase.Owner.Name;
       	}
		if(oldCase.CaseNumber == null){
			milestoneTrackingToUpsert.Activity__c = 'Case Creato';
		} else if(newCase.Status != oldCase.Status && newCase.OwnerId != oldCase.OwnerId){
			milestoneTrackingToUpsert.Activity__c = 'Cambio Stato e Titolare';
		} else if(newCase.Status != oldCase.Status && AP_Constants.caseStatusGestioneHD3.equalsIgnoreCase(newCase.Status) && AP_Constants.caseStatusGestioneSpecialistica.equalsIgnoreCase(oldCase.Status)){
			milestoneTrackingToUpsert.Activity__c = 'Cambio Stato e Gruppo';
		} else if(newCase.Status != oldCase.Status) { 
			milestoneTrackingToUpsert.Activity__c = 'Cambio Stato';
		} else if(AP_Constants.caseStatusGestioneHD3.equalsIgnoreCase(newCase.Status) && newCase.HD3_IT__c != oldCase.HD3_IT__c){
			milestoneTrackingToUpsert.Activity__c = 'Cambio Gruppo';
		} else if(newCase.OwnerId != oldCase.OwnerId){
			milestoneTrackingToUpsert.Activity__c = 'Cambio Titolare';
		}
	}
    
}