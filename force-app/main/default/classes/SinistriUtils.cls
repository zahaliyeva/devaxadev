/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         SinistriUtils
Description:   Apex class used to execute all the logics related to Sinistri Danni Banca and Sinistri AAI records.

History

18/03/2018     Created 
-------------------------------------------------------------------------------------------*/
public without sharing class SinistriUtils {
  
    @TestVisible private static Boolean runSinistriUtilsFROMtest = false;
    public static boolean runSinistriUtils = true; 
    public static final String axaAssistanceRole = 'HD1 AXA Assistance';
    public static final String axaAssistanceSupervisorRole = 'HD1 AXA Assistance Supervisor';
    public static final String customerOperationRole = 'HD1 Customer Operation';
    public static final String axaAssistanceQueueRole = 'Coda HD1 AXA Assistance';
    public static final String customerOperationQueueRole = 'Coda HD1 Customer Operation';
    public static final String[] HDRoles = new String[]{'HD1 AXA Assistance','HD1 Customer Operation'};
    public static final String[] ClosedStatusList = new String[]{   AP_Constants.caseStatusClosed, 
                                    AP_Constants.caseStatusOutOfTime,
                                                  AP_Constants.caseStatusCancelled};
    public static final String IdAdministrator;
  static{
        User u = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator','Amministratore del sistema') AND Alias ='utte' LIMIT 1];
      if(u!=null)
      {
          IdAdministrator = u.Id;
      }
    }
    //OAVERSANO 08/04/2019 : AXA Assistance -- START
    public static boolean runProcessTeamAndMilestone = false; 
    //OAVERSANO 08/04/2019 : AXA Assistance -- END
  
    
    
    public class updateCase implements Queueable 
    {
        private Set<id> setId; 
        private Map<String,Case> OldValues;
        private Set<String> axaAssistanceProfileSet; 
        private Set<String> customerOperationProfileSet; 
              
        public updateCase(Set<id> setId, Map<String,Case> OldValues, Set<String> axaAssistanceProfileSet, Set<String> customerOperationProfileSet)  
        {
            this.setId = setId;
            this.OldValues = OldValues;
          this.axaAssistanceProfileSet = axaAssistanceProfileSet;
          this.customerOperationProfileSet = customerOperationProfileSet;
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
              System.enqueueJob(new updateCaseMilestone(setId, OldValues, axaAssistanceProfileSet, customerOperationProfileSet)); 
      }
    }

    public class updateCaseMilestone implements Queueable 
    {
    private Set<id> setId; 
        private Map<String,Case> OldValues;
        private Set<String> axaAssistanceProfileSet; 
        private Set<String> customerOperationProfileSet; 
        
        public updateCaseMilestone(Set<id> setId, Map<String,Case> OldValues, Set<String> axaAssistanceProfileSet, Set<String> customerOperationProfileSet)  
        { 
          this.setId = setId;
          this.OldValues = OldValues;
          this.axaAssistanceProfileSet = axaAssistanceProfileSet;
          this.customerOperationProfileSet = customerOperationProfileSet;
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
          List<Case> lstCase = [SELECT Id, Status, CaseMilestone_StartDate__c, Owner.Profile.Name, 
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
                      if(axaAssistanceProfileSet.contains(cs.Owner.Profile.Name))
                      {
                          system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                          if(caseIdWorkingItemMap.get(cs.Id)!=null)
                          {
                            Double timeToCut = 0;
                            for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                            {
                                if(wrkTime.UserProfile__c == axaAssistanceRole)
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
                      else if(customerOperationProfileSet.contains(cs.Owner.Profile.Name))
                      {
                          system.debug('caseIdWorkingItemMap: '+caseIdWorkingItemMap);
                          if(caseIdWorkingItemMap.get(cs.Id)!=null)
                          {
                            Double timeToCut = 0;
                            for(Working_Times__c wrkTime:caseIdWorkingItemMap.get(cs.Id))
                            {
                                if(wrkTime.UserProfile__c == customerOperationRole)
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
    
}