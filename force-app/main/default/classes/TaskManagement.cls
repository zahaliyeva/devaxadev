/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         CaseManagement
Description:   Apex class used to execute all the logics internal to the 
trigger related to the Task object

History

17/05/2018     Created 
-------------------------------------------------------------------------------------------*/
public class TaskManagement
{
    public class RemainingObject
    {
        public Boolean ExistsNormalPending = false;
        public Boolean ExistsDPOPending = false;
        public Boolean ExistsNormalOpen = false;
        public Boolean ExistsDPOOpen = false;
        public Boolean FirstPendingIsDPO = false;
        public Boolean FirstOpenIsDPO = false;
        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
        public Boolean ExistsInternalPending = false;
        public Boolean ExistsInternalOpen = false;
        public Boolean FirstOpenIsInternal = false;
        public Boolean FirstPendingIsInternal = false;
        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END     
    }
    
    public without sharing class DeleteTasks 
    {
        
        public DeleteTasks ( list<Id> idTaskToDelete) 
        {
            List<Task> listTaskForDeletion = [Select id from task where id in :idTaskToDelete];
            delete listTaskForDeletion;
        }
    } 

    @AuraEnabled
    public static void saveTaskFromLWC(Task taskRecord){
        Id articleRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('ArticleFeedbackTask').getRecordTypeId();
        try{
            taskRecord.RecordTypeId=articleRT;
            insert taskRecord;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static void AfterInsertProcess(List<Task> Tasks, List<String>TasksId, Map<String,Boolean> MapCaseId,Map<String,String>MapTaskIdToCaseId,String defaultHoursId, String bhGDPR)
    {
        if(TaskHandler.firstRunAfterInsert)
        {
            System.Debug('## >>> Start of AfterInsertProcess <<< run by ' + UserInfo.getName());
            List<Attachment> AttachmentToInsert = new List<Attachment>();
            set<id> AP05setCaseId= new set<id>();
            list<Task> AP05listTask= new list<Task>(); 
            set<id> AP09CaseId= new set<id>();
            list<Task> AP09listTaskClosed= new list<Task>();
            list<Task> AP08listTask = new list<Task>();
            set<id> AP08setCaseId = new set<id>();
            List<Case> CaseToUpdateList = new List<Case>();
            Map<String,Case> MapCase = new Map<String,Case>();
            Boolean istechofftask = false;
            Map<String,Case> AssociatedCasesMap = new Map<String,Case>();//MOSCATELLI_M 23/01/2019: NMA Enhancement V
            
            AttachmentToInsert = ManageAttachments(TasksId, MapCaseId,MapTaskIdToCaseId);    
            
            List<String> GDPRHierarchyLevels = new List<String>();
            List<String> GDPRCategories = New List<String>();
            
            for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Hierarchylevel1'))
                    GDPRHierarchyLevels.add(MPSCv.Value__c);
                
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);
            }
            
            List<String> CasesContainingDPO = new List<String>();
            
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
            /*
for(Case c : [Select Id,Data_primo_Task_DPO__c from Case where id in: MapCaseId.Keyset()])     
{
if(c.Data_primo_Task_DPO__c<>null)
CasesContainingDPO.add(c.id);
}*/
            List<String> CasesContainingTaskInterni = new List<String>();
            
            //MOSCATELLI_M 23/01/2019: NMA Enhancement V -- start
            //for(Case c : [Select Id,Data_primo_Task_DPO__c,Data_primo_task_interno__c from Case where id in: MapCaseId.Keyset()]) 
            for(Case c : [Select Id,Data_primo_Task_DPO__c,Data_primo_task_interno__c, Origin,Case_sollecitato__c, (Select id,Tipo_Attivit__c,isClosed from Tasks) from Case where id in: MapCaseId.Keyset()])     
            //MOSCATELLI_M 23/01/2019: NMA Enhancement V -- end
            {
                if(c.Data_primo_Task_DPO__c<>null)
                    CasesContainingDPO.add(c.id);
                
                if(c.Data_primo_task_interno__c<>null)
                    CasesContainingTaskInterni.add(c.id);

                AssociatedCasesMap.put(c.Id,c);//MOSCATELLI_M 23/01/2019: NMA Enhancement V
            }        
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END  
            
            for (Task t: Tasks)
            {   
                if(String.isNotBlank(t.Hierarchylevel1__c))
                {
                    istechofftask = true;
                    
                    if(GDPRHierarchyLevels.contains(t.HierarchyLevel1__c) && !CasesContainingDPO.contains(t.whatid) && !MapCase.containsKey(t.whatid))
                    {
                        //CaseToUpdateList.add(new Case(id=t.WhatId,Data_primo_Task_DPO__c=System.now()));
                        MapCase.put(t.whatid,new Case(id=t.WhatId,Data_primo_Task_DPO__c=System.now()));
                    }
                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                    else if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c) && !CasesContainingTaskInterni.contains(t.whatid) && !MapCase.containsKey(t.whatid))
                    {
                        MapCase.put(t.whatid,new Case(id=t.WhatId,Data_primo_task_interno__c=System.now()));
                    }
                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END 
                    
                    if(PAD.canTrigger('AP09'))
                    {
                        if(!t.isclosed)
                        {
                            AP09listTaskClosed.add(t);
                            AP09CaseId.add(t.whatId);
                        }
                    }
                    
                    if(PAD.canTrigger('AP08'))
                    {           
                        AP08listTask.add(t);
                        AP08setCaseId.add(t.whatId);                 
                    }              
                }
                //MOSCATELLI_M 23/01/2019: NMA Enhancement V -- start
                else if(AssociatedCasesMap.containsKey(t.whatid))
                {
                    if(!AssociatedCasesMap.get(t.whatid).Case_sollecitato__c)
                    {
                        if(t.Tipo_Attivit__c== 'Log a Call')
                        {
                            CaseToUpdateList.add(new Case(id=t.WhatId,OCR__c=false,Case_sollecitato__c=true));
                        }
                    }                 
                }
                //MOSCATELLI_M 23/01/2019: NMA Enhancement V -- end
                
                if(PAD.canTrigger('AP05'))
                {
                    if(t.Send_email_to_case_owner__c == true)
                    {                         
                        AP05listTask.add(t);
                        AP05setCaseId.add(t.whatId);                     
                    }
                }
            }
            
            if(istechofftask)
                CaseToUpdateList = CalcoloTempidiLavorazione(MapCaseId,MapCase,defaultHoursId,'After Insert',GDPRHierarchyLevels,Tasks,bhGDPR,GDPRCategories);
            
            if(CaseToUpdateList.size()>0)
                update CaseToUpdateList;
            
            if(AttachmentToInsert.size()>0)
                insert AttachmentToInsert;  
            
            if(AP05listTask.size()>0)     
                AP05Task.sendTaskMails(AP05listTask,AP05setCaseId);
            
            if(AP08listTask.size()>0)
                AP08TaskReporting.setDaysBetweenTaskAndCaseCreation(AP08listTask,AP08setCaseId); 
            
            if(AP09listTaskClosed.size()> 0 )
                AP09TaskWithClosedCase.validatedTaskAndCaseStatus(AP09CaseId, AP09listTaskClosed); 
        }         
    }
    
    public static void AfterUpdateProcesses (List<Task> Tasks, List<String>TasksId, Map<String,Boolean> MapCaseId,Map<String,String>MapTaskIdToCaseId,Map<String,Task> OldValues,String defaultHoursId, String bhGDPR)
    {
        if(TaskHandler.firstRunAfterUpdate)
        {
            System.Debug('## >>> Start of AfterUpdateProcesses <<< run by ' + UserInfo.getName());
            
            Set<String> setTaskKey = new set<String>();
            List<Attachment> AttachmentToInsert = new List<Attachment>();
            List<Case> CaseToUpdate = new List<Case>();
            set<id> AP05setCaseId= new set<id>();
            list<Task> AP05listTask= new list<Task>(); 
            set<id> AP09CaseId= new set<id>();
            list<Task> AP09listTaskClosed= new list<Task>();      
            set<id> AP10setCaseId= new set<id>();
            list<Task> AP10listTask= new list<Task>(); 
            List<Task> TaskToUpdate = new List<Task>();
            
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
            Set<String> TasksModified = new Set<String>();

            for(Task t: Tasks)
            {
                if(String.isNotBlank(t.Hierarchylevel1__c))
                    TasksModified.add(t.TECH_Key__c);
            }
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END

            
            //MOSCATELLI_M 02/05/2018: GDPR--START
            List<String> GDPRHierarchyLevels = new List<String>();
            List<String> GDPRCategories = New List<String>();
            Map<String,Case> MapRemainingTasks = new Map<String,Case>();
            Map<String,RemainingObject> MapRemainingTasksTypes = new Map<String,RemainingObject>();
            //List<Task> TaskToDelete = new List<Task>();
            List<String> TaskToDelete = new List<String>();
            List<String> CasesContainingDPO = new List<String>();
            
            for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Hierarchylevel1'))
                    GDPRHierarchyLevels.add(MPSCv.Value__c);
                
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);          
            }
            
            for(Case c :[select id, IsClosed, status,recordtype.developername,PendingDueToTaskDT__c, Pending_due_to_Task_Start_Duration__c,Data_inizio_Pending_per_DPO__c,Durata_Pending_DPO__c,Data_primo_Task_DPO__c,Durata_lavorazione_DPO_in_business_hours__c,First_Long_Term_Management_Alert_DT__c,Second_Long_Term_Management_Alert_DT__c,Third_Long_Term_Management_Alert_DT__c,Inform_Customers_with_Alerts__c,Data_inizio_Pending_per_Task_interno__c,Durata_Pending_per_Task_interno__c,Data_primo_task_interno__c,
                         (Select IsClosed, id , Status, TECH_Key__c,IsBackupTask__c,HierarchyLevel1__c,Tipo_Attivit__c
                          From    Tasks 
                          where   isClosed = false
                          and HierarchyLevel1__c !=''
                          order by createddate asc) 
                         From    Case c
                         where id in : MapCaseId.keyset()])
            {
                MapRemainingTasks.put(c.id,c);
                
                RemainingObject r = new RemainingObject();
                
                Integer counterOpen = 0;
                Integer counterPending = 0;
                Integer counterLoop =0;
                
                if(c.Data_primo_Task_DPO__c<>null)
                    CasesContainingDPO.add(c.id);    
                
                for(Task t: c.Tasks)
                {
                    if(String.isNotBlank(t.HierarchyLevel1__c))
                    {
                        
                        if(GDPRHierarchyLevels.contains(t.HierarchyLevel1__c) && counterLoop==0)
                            r.FirstOpenIsDPO = true;
                        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                        else if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c) && (t.Tipo_Attivit__c == 'Task Interno') && counterLoop==0)
                            r.FirstOpenIsInternal = true;
                        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                        
/*
                        if(GDPRHierarchyLevels.contains(t.HierarchyLevel1__c))
                        {
                            if(counterLoop==0)
                                r.FirstOpenIsDPO = true;
                            
                            if(TasksId.contains(t.id))
                            {
                                if(t.status <> AP_Constants.taskStatusPending)
                                    r.ExistsDPOOpen = true;    
                                else
                                    r.ExistsDPOPending = true;   
                            }
                        }
                        else if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c))
                        {
                            if(t.Tipo_Attivit__c == 'Task Interno')
                            {
                                if(counterLoop==0)
                                    r.FirstOpenIsInternal = true;
                                
                                if(TasksId.contains(t.id))
                                {
                                    if(t.status <> AP_Constants.taskStatusPending)
                                        r.ExistsInternalOpen = true;    
                                    else
                                        r.ExistsInternalPending = true;     
                                }
                            }
                            else  
                            {
                                if(TasksId.contains(t.id))
                                {
                                    if(t.status <> AP_Constants.taskStatusPending)
                                        r.ExistsNormalOpen = true;    
                                    else
                                        r.ExistsNormalPending = true;   
                                }                               
                            }                                                                         
                        }
*/
                        if(!TasksId.contains(t.id) && !TasksModified.contains(t.TECH_Key__c))
                        {   
                            if(t.status == AP_Constants.taskStatusPending)  
                            {
                                if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c))
                                {
                                    if(t.Tipo_Attivit__c <> 'Task Interno')
                                    {   
                                        r.ExistsNormalPending = true;
                                    }
                                    else
                                    {
                                         r.ExistsInternalPending = true;
                                         
                                         if(counterPending==0)
                                            r.FirstPendingIsInternal = true;
                                    }
                                }
                                else
                                {
                                    r.ExistsDPOPending = true;
                                    
                                    if(counterPending==0)
                                    {
                                        r.FirstPendingIsDPO = true;
                                    }                                   
                                }
                                
                                counterPending++;
                            }
                            else
                            {
                                if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c))
                                {
                                    if(t.Tipo_Attivit__c <> 'Task Interno')
                                         r.ExistsNormalOpen = true;
                                    else
                                         r.ExistsInternalOpen = true;
                                }
                                else
                                    r.ExistsDPOOpen = true;
                            }
                            counterOpen++;
                        }
                        
                        counterLoop++;
                    }
                }  
                
                MapRemainingTasksTypes.put(c.id,r);
                
                system.debug('@@MapRemainingTasksTypes: '+MapRemainingTasksTypes);
            }
            //MOSCATELLI_M 02/05/2018: GDPR--END
            
            Map<String,Case> MapCase = new Map<String,Case>();
            Map<String,Boolean> ReducedMapCaseId = new Map<String,Boolean>();
            Map<String,Case> MapAP03TaskCases = new Map<String,Case>();
            
            AttachmentToInsert = ManageAttachments(TasksId, MapCaseId,MapTaskIdToCaseId);
            Boolean istechofftask = false;
            
            for (Task t:Tasks)
            {   
                if(String.isNotBlank(t.HierarchyLevel1__c))
                {    
                    istechofftask = true;
                    
                    if(PAD.canTrigger('AP09'))
                    {
                        if(t.status  <> OldValues.get(t.id).status && !t.isclosed)
                        {
                            AP09listTaskClosed.add(t);
                            AP09CaseId.add(t.whatId);
                        }
                    }
                    
                    Boolean isTaskToDelete = false;
                    Boolean isBackupTask = false;
                    
                    if(PAD.canTrigger('AP03'))
                    {
                        system.debug('@@t: '+t.id);
                        
                        for(Task tc: MapRemainingTasks.get(t.whatid).Tasks)
                        {
                            if(tc.id <> t.id && (tc.TECH_Key__c == t.TECH_Key__c) && tc.status != AP_Constants.taskStatusPending && tc.status != AP_Constants.taskStatusInProgress)
                            {
                                if(t.status<> AP_Constants.taskStatusOpen)
                                {
                                    //TaskToDelete.add(tc);
                                    TaskToDelete.add(tc.id);
                                    isTaskToDelete=true;
                                }
                                
                            }
                            else if(tc.IsBackupTask__c && (tc.TECH_Key__c == t.TECH_Key__c) && tc.id == t.id)
                            {
                                if(t.status<> AP_Constants.taskStatusOpen)
                                {            
                                    isBackupTask = true;
                                    TaskToUpdate.add(new Task(id=t.id,IsBackupTask__c = false));
                                }
                            }
                        }
                        
                        if((t.status  <> OldValues.get(t.id).status) && !MapRemainingTasks.get(t.whatid).IsClosed)
                        {
                            if((t.isClosed  <> OldValues.get(t.id).isClosed) && t.isClosed)
                            {
                                system.debug('Debuf1');
                                
                                if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c))
                                {
                                    if(t.Tipo_Attivit__c <> 'Task Interno')
                                    {
                                        if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending)
                                        {
                                            Case cas = new Case(id = t.whatid);
                                            Boolean ismodified = false;
                                            
                                            if(MapRemainingTasks.get(t.whatId).PendingDueToTaskDT__c!=null)
                                            {
                                                //Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).PendingDueToTaskDT__c, system.now())/3600000.0 + (MapRemainingTasks.get(t.whatId).Pending_due_to_Task_Start_Duration__c==null?0:MapRemainingTasks.get(t.whatId).Pending_due_to_Task_Start_Duration__c);      
                                                Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).PendingDueToTaskDT__c, system.now())/3600000.0;      
                                                
                                                cas.Pending_due_to_Task_Start_Duration__c=pendingduration;              
                                                
                                                cas.PendingDueToTaskDT__c=null;
                                                ismodified = true;
                                            }     
                                            
                                            if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && 
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen &&
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                               //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen && 
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                            {
                                                cas.status = AP_Constants.caseStatusAllTasksClosed;
                                                ismodified = true;                   
                                            }
                                            else if(MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal)
                                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                            {
                                                cas.status = AP_Constants.caseStatusDelegated;
                                                ismodified = true;  
                                            }
                                            else if(MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal && 
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                                
                                            {
                                                cas.status = AP_Constants.caseStatusInAttesaDPO;
                                                ismodified = true;  
                                            }
                                            else if(MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen &&
                                                    MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending )
                                            {
                                                cas.status = AP_Constants.caseInAttesa2ndInterno;
                                                ismodified = true;  
                                            }
                                            
                                            //else if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen)
                                            if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen)
                                            {                   
                                                cas.All_Tasks_Close_Date__c = System.now();
                                                ismodified = true;
                                                
                                                if(cas.First_Long_Term_Management_Alert_DT__c!=null || cas.Second_Long_Term_Management_Alert_DT__c!=null || cas.Third_Long_Term_Management_Alert_DT__c!=null)
                                                {
                                                    cas.First_Long_Term_Management_Alert_DT__c = null;
                                                    cas.Second_Long_Term_Management_Alert_DT__c = null;
                                                    cas.Third_Long_Term_Management_Alert_DT__c = null;
                                                    cas.Inform_Customers_with_Alerts__c = false;
                                                }                                                  
                                            }
                                            
                                            if(ismodified)
                                            {
                                                CaseToUpdate.add(Cas);
                                                MapCase.put(t.whatid,Cas);
                                            }
                                        }
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                    else
                                    {
                                        if(!MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                        {
                                            Case cas = new Case(id = t.whatid);
                                            Boolean ismodified = false;
                                            
                                            if(MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_Task_interno__c!=null)
                                            {
                                                Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_Task_interno__c, system.now())/3600000.0;      
                                                
                                                cas.Durata_Pending_per_Task_interno__c=pendingduration;              
                                                
                                                cas.Data_inizio_Pending_per_Task_interno__c=null;
                                                ismodified = true;
                                            }     
                                            
                                            if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && 
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen &&
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                               !MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen)
                                            {
                                                cas.status = AP_Constants.case2ndInternoCompletato;
                                                ismodified = true;                   
                                            }
                                            else if(MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && 
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO)
                                            {
                                                cas.status = AP_Constants.caseStatusDelegated;
                                                ismodified = true;  
                                            }
                                            else if(MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal)
                                            {
                                                cas.status = AP_Constants.caseStatusInAttesaDPO;
                                                ismodified = true;  
                                            }
                                            else if(MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen &&
                                                    MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending )
                                            {
                                                cas.status = AP_Constants.caseInAttesa2ndInterno;
                                                ismodified = true;  
                                            }
                                            
                                            if(!MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen)
                                            {                   
                                                cas.Data_completamento_Task_interni__c = System.now();
                                                ismodified = true;
                                                
                                                if(cas.First_Long_Term_Management_Alert_DT__c!=null || cas.Second_Long_Term_Management_Alert_DT__c!=null || cas.Third_Long_Term_Management_Alert_DT__c!=null)
                                                {
                                                    cas.First_Long_Term_Management_Alert_DT__c = null;
                                                    cas.Second_Long_Term_Management_Alert_DT__c = null;
                                                    cas.Third_Long_Term_Management_Alert_DT__c = null;
                                                    cas.Inform_Customers_with_Alerts__c = false;
                                                }                                                  
                                            }
                                            
                                            if(ismodified)
                                            {
                                                CaseToUpdate.add(Cas);
                                                MapCase.put(t.whatid,Cas);
                                            }
                                        }
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                }
                                else
                                {
                                    if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending)
                                    {
                                        Case cas = new Case(id = t.whatid);
                                        Boolean ismodified = false;
                                        
                                        if(MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_DPO__c!=null)
                                        {
                                            //Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_DPO__c, system.now())/3600000.0 + (MapRemainingTasks.get(t.whatId).Durata_lavorazione_DPO_in_business_hours__c==null?0:MapRemainingTasks.get(t.whatId).Durata_lavorazione_DPO_in_business_hours__c);      
                                            Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_DPO__c, system.now())/3600000.0;  
                                            Cas.Durata_Pending_DPO__c=pendingduration;
                                            
                                            Cas.Data_inizio_Pending_per_DPO__c=null;
                                            ismodified = true;                       
                                        }                        
                                        
                                        if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && 
                                           !MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen &&
                                           !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                           //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                           !MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen && 
                                           !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                        {
                                            cas.status = AP_Constants.caseStatusAttivitaDPOCompletate;
                                            ismodified = true;                       
                                        }
                                        else if(MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && 
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal &&
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                        {
                                            cas.status = AP_Constants.caseStatusDelegated;
                                            ismodified = true;  
                                        }
                                        else if(MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen && 
                                                MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal)
                                            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END)
                                        {
                                            cas.status = AP_Constants.caseStatusInAttesaDPO;
                                            ismodified = true;  
                                        }
                                        else if(MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen &&
                                                MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending )
                                        {
                                            cas.status = AP_Constants.caseInAttesa2ndInterno;
                                            ismodified = true;  
                                        }                                        
                                        
                                        //else if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen)
                                        if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen)
                                        {
                                            cas.Data_completamento_Task_DPO__c = System.now();
                                            ismodified = true;
                                        }
                                        
                                        if(ismodified)
                                        {
                                            CaseToUpdate.add(Cas);
                                            MapCase.put(t.whatid,Cas);              
                                        }
                                    }
                                }              
                            }
                            else if(OldValues.get(t.id).status  == AP_Constants.taskStatusPending && (t.status == AP_Constants.taskStatusOpen || t.status == AP_Constants.taskStatusInProgress || t.status == AP_Constants.taskStatusInformationReceived)) 
                            {
                                system.debug('Debuf2');
                                
                                if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c))
                                {
                                    if(t.Tipo_Attivit__c <> 'Task Interno')
                                    {
                                        if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending)
                                        {
                                            Case cas = new Case(id = t.whatid);
                                            Boolean ismodified = false;
                                            
                                            if(MapRemainingTasks.get(t.whatId).PendingDueToTaskDT__c!=null)
                                            {
                                                //Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).PendingDueToTaskDT__c, system.now())/3600000.0 + (MapRemainingTasks.get(t.whatId).Pending_due_to_Task_Start_Duration__c==null?0:MapRemainingTasks.get(t.whatId).Pending_due_to_Task_Start_Duration__c);      
                                                Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).PendingDueToTaskDT__c, system.now())/3600000.0;      
                                                
                                                cas.Pending_due_to_Task_Start_Duration__c=pendingduration;
                                                
                                                cas.PendingDueToTaskDT__c=null;
                                                ismodified = true;
                                            }     
                                            
                                            if((!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO && !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal) ||
                                               (!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && !MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen && !MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen)
                                              )
                                            {
                                                cas.status = AP_Constants.caseStatusDelegated;
                                                ismodified = true;                       
                                            }
                                            else if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && 
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending &&
                                                    MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen &&
                                                    MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO)
                                            {
                                                cas.status = AP_Constants.caseStatusInAttesaDPO;
                                                ismodified = true;  
                                            }
                                            else if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && 
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending && 
                                                    MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen &&
                                                    MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal)
                                            {
                                                cas.status = AP_Constants.caseInAttesa2ndInterno;
                                                ismodified = true;  
                                            }
                                            
                                            if(ismodified)
                                            {
                                                MapCase.put(t.whatid,Cas);
                                                CaseToUpdate.add(Cas);
                                            }
                                        }
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                    else
                                    {
                                        if(!MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                        {
                                            Case cas = new Case(id = t.whatid);
                                            Boolean ismodified = false;
                                            
                                            if(MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_Task_interno__c!=null)
                                            {
                                                Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_Task_interno__c, system.now())/3600000.0;      
                                                
                                                cas.Durata_Pending_per_Task_interno__c=pendingduration;
                                                
                                                cas.Data_inizio_Pending_per_Task_interno__c=null;
                                                ismodified = true;
                                            }     
                                            
                                            if((!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO && MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal) ||
                                               (!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && !MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen && !MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending)
                                              )
                                            {
                                                cas.status = AP_Constants.caseInAttesa2ndInterno;
                                                ismodified = true;                       
                                            }
                                            else if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                    MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen &&
                                                    MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO)
                                            {
                                                cas.status = AP_Constants.caseStatusInAttesaDPO;
                                                ismodified = true;  
                                            }
                                            else if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending &&
                                                    !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending && 
                                                    MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                    !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal)
                                            {
                                                cas.status = AP_Constants.caseStatusDelegated;
                                                ismodified = true;  
                                            }
                                            
                                            if(ismodified)
                                            {
                                                MapCase.put(t.whatid,Cas);
                                                CaseToUpdate.add(Cas);
                                            }
                                        }
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                }
                                else
                                {
                                    if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending)
                                    {
                                        Case cas = new Case(id = t.whatid);
                                        Boolean ismodified = false;
                                        
                                        if(MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_DPO__c!=null)
                                        {
                                            //Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_DPO__c, system.now())/3600000.0 + (MapRemainingTasks.get(t.whatId).Durata_lavorazione_DPO_in_business_hours__c==null?0:MapRemainingTasks.get(t.whatId).Durata_lavorazione_DPO_in_business_hours__c);      
                                            Double pendingduration = BusinessHours.diff(defaultHoursId, MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_DPO__c, system.now())/3600000.0;  
                                            Cas.Durata_Pending_DPO__c=pendingduration;
                                            
                                            Cas.Data_inizio_Pending_per_DPO__c=null;
                                            ismodified = true;                       
                                        }                        
                                        
                                        if((!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending &&
                                            MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO && !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal) ||
                                           (!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending && !MapRemainingTasksTypes.get(t.whatid).ExistsDPOOpen && !MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen))
                                        {
                                            cas.status = AP_Constants.caseStatusInAttesaDPO;
                                            ismodified = true;                       
                                        }
                                        else if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending &&
                                                MapRemainingTasksTypes.get(t.whatid).ExistsNormalOpen &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal)
                                        {
                                            cas.status = AP_Constants.caseStatusDelegated;
                                            ismodified = true;  
                                        }
                                        else if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending &&
                                                !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending &&
                                                 MapRemainingTasksTypes.get(t.whatid).ExistsInternalOpen &&
                                                !MapRemainingTasksTypes.get(t.whatid).FirstOpenIsDPO &&
                                                MapRemainingTasksTypes.get(t.whatid).FirstOpenIsInternal)
                                        {
                                            cas.status = AP_Constants.caseInAttesa2ndInterno;
                                            ismodified = true;  
                                        }
                                        
                                        if(ismodified)
                                        {
                                            MapCase.put(t.whatid,Cas);
                                            CaseToUpdate.add(Cas);              
                                        }
                                    }
                                }              
                            }
                            else if(t.status == AP_Constants.taskStatusPending)
                            {
                                if(!GDPRHierarchyLevels.contains(t.HierarchyLevel1__c))
                                {
                                    if(t.Tipo_Attivit__c <> 'Task Interno')
                                    {
                                        if(MapRemainingTasksTypes.containskey(t.whatid))
                                        {
                                            if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending)
                                            {
                                                Case cas = new Case(id = t.whatid);
                                                Boolean ismodified = false;
                                                
                                                if(MapRemainingTasks.get(t.whatId).PendingDueToTaskDT__c==null)
                                                {
                                                    cas.PendingDueToTaskDT__c=System.now();
                                                    ismodified = true;
                                                }     
                                                
                                                if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                                {
                                                    cas.status = AP_Constants.caseStatusPending;
                                                    ismodified = true;                       
                                                }
                                                
                                                if(ismodified)
                                                {
                                                    MapCase.put(t.whatid,Cas);
                                                    CaseToUpdate.add(Cas);
                                                }
                                            }
                                        }
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                    else
                                    {
                                        if(MapRemainingTasksTypes.containskey(t.whatid))
                                        {
                                            if(!MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                            {
                                                Case cas = new Case(id = t.whatid);
                                                Boolean ismodified = false;
                                                
                                                if(MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_Task_interno__c==null)
                                                {
                                                    cas.Data_inizio_Pending_per_Task_interno__c=System.now();
                                                    ismodified = true;
                                                }     
                                                
                                                if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending && !MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending)
                                                {
                                                    cas.status = AP_Constants.caseStatusPending;
                                                    ismodified = true;                       
                                                }
                                                
                                                if(ismodified)
                                                {
                                                    MapCase.put(t.whatid,Cas);
                                                    CaseToUpdate.add(Cas);
                                                }
                                            }
                                        }
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                }
                                else
                                {
                                    if(!MapRemainingTasksTypes.get(t.whatid).ExistsDPOPending)
                                    {
                                        Case cas = new Case(id = t.whatid);
                                        Boolean ismodified = false;
                                        
                                        if(MapRemainingTasks.get(t.whatId).Data_inizio_Pending_per_DPO__c==null)
                                        {
                                            cas.Data_inizio_Pending_per_DPO__c=System.now();
                                            ismodified = true;
                                        }     
                                        
                                        if(!MapRemainingTasksTypes.get(t.whatid).ExistsNormalPending && !MapRemainingTasksTypes.get(t.whatid).ExistsInternalPending)
                                        {
                                            cas.status = AP_Constants.caseStatusPending;
                                            ismodified = true;                       
                                        }
                                        
                                        if(ismodified)
                                        {
                                            MapCase.put(t.whatid,Cas);
                                            CaseToUpdate.add(Cas);
                                        }
                                    }
                                }              
                            }
                            
                            else if(OldValues.get(t.id).isclosed && !t.isclosed)
                            {
                                if(GDPRHierarchyLevels.contains(t.HierarchyLevel1__c) && !CasesContainingDPO.contains(t.whatid))
                                {
                                    Case cas = new Case(id = t.whatid,Data_primo_Task_DPO__c=System.now());
                                    CaseToUpdate.add(Cas);
                                    MapCase.put(t.whatid,Cas);
                                }
                            }                              
                        }
                    }
                }
                
                if(PAD.canTrigger('AP05'))
                {
                    if(t.Send_email_to_case_owner__c != OldValues.get(t.id).Send_email_to_case_owner__c && t.Send_email_to_case_owner__c == true)
                    {    
                        AP05listTask.add(t);
                        AP05setCaseId.add(t.whatId);
                    }
                }
                
                if (PAD.canTrigger('AP10') && String.isNotBlank(t.HierarchyLevel1__c))
                {
                    if (OldValues.get(t.id).status == AP_Constants.taskStatusClosed && t.status != AP_Constants.taskStatusClosed && UserInfo.getUserId() != t.ownerid)
                    {
                        AP10listTask.add(t);
                        AP10setCaseId.add(t.whatId);
                    }
                }        
            }
            
            system.debug('##setTaskKey: '+setTaskKey);
            
            if(istechofftask)
                CaseToUpdate = CalcoloTempidiLavorazione(MapCaseId,MapCase,defaultHoursId,'After Update',GDPRHierarchyLevels,Tasks,bhGDPR,GDPRCategories);      
            
            if(CaseToUpdate.size()>0)
            {
                //OAVERSANO 20/03/2019 : AXA Assistance -- START
                CaseHandler.AfterUpdateNotDone = true;
                SinistriUtils.runSinistriUtils = true;
                //OAVERSANO 20/03/2019 : AXA Assistance -- END
                update CaseToUpdate;
            }
            
            if(AttachmentToInsert.size()>0)
                insert AttachmentToInsert;
            
            if(AP05listTask.size()>0)      
                AP05Task.sendTaskMails(AP05listTask,AP05setCaseId);      
            
            if(AP09listTaskClosed.size()>0)      
                AP09TaskWithClosedCase.validatedTaskAndCaseStatus(AP09CaseId, AP09listTaskClosed);       
            
            if(AP10setCaseId.size()>0)      
                AP10SendTaskOwnerEmail.sendEmail(AP10listTask, AP10setCaseId);    
            
            if(TaskToUpdate.size()>0)
                update TaskToUpdate;
            
            if(TaskToDelete.size()>0)
            {
                DeleteTasks dt = new DeleteTasks(TaskToDelete);
            }
            //delete TaskToDelete;
            //Database.delete(TaskToDelete,false);
            
            System.Debug('## >>> END of TaskAfterUpdate <<< run by ' + UserInfo.getName());
        }
    }
    
    public static List<Attachment> ManageAttachments(List<String>TasksId, Map<String,Boolean> MapCaseId,Map<String,String>MapTaskIdToCaseId)
    {
        system.debug('@@Manage Attachments');
        
        List<Attachment> ToInsertList = new List<Attachment>();
        List<Attachment> ListTaskAttach = new List<Attachment>();
        List<Attachment> ListCaseAtt = new List<Attachment>();
        Set<String>  AlreadyAttachedSet  = new Set<String>(); 
        
        for(Attachment a : [SELECT ParentId,Id,Name,CreatedDate,BodyLength,Body FROM Attachment where (ParentId in :MapCaseId.keyset() or ParentId in :TasksId)])
        {
            if(TasksId.contains(a.ParentId))
                ListTaskAttach.add(a);
            else if(MapCaseId.containsKey(a.ParentId))
                ListCaseAtt.add(a);
        }
        
        for(Attachment TaskAtt : ListTaskAttach)
        {
            system.debug('############################Task attachments copy starts############################');
            
            if(MapTaskIdToCaseId.containsKey(TaskAtt.ParentId))
            {                
                if(String.isNotBlank(string.valueof(MapTaskIdToCaseId.get(TaskAtt.ParentId))))
                {           
                    integer ItemtobeAttachedFound = 0;
                    
                    for(Attachment CaseAtt: ListCaseAtt)
                    {
                        if(CaseAtt.parentId == MapTaskIdToCaseId.get(TaskAtt.ParentId) && CaseAtt.BodyLength == TaskAtt.BodyLength && CaseAtt.Name == TaskAtt.Name)
                        {
                            ItemtobeAttachedFound++;                 
                        }
                    }
                    
                    if(ItemtobeAttachedFound==0 && !AlreadyAttachedSet.contains(string.valueof(TaskAtt.Name+MapTaskIdToCaseId.get(TaskAtt.ParentId)))) //This condition avoids the possibility for an Advisor to attach to a case the same item twice in the same moment
                    {
                        system.debug('############################Copied. The attachment has not been already attached to the case############################');
                        Attachment TaskAttachmentDuplicate=new Attachment();
                        TaskAttachmentDuplicate.Name=TaskAtt.Name;
                        TaskAttachmentDuplicate.parentId = MapTaskIdToCaseId.get(TaskAtt.ParentId);                        
                        TaskAttachmentDuplicate.Body=TaskAtt.Body;
                        ToInsertList.add(TaskAttachmentDuplicate);
                        
                        AlreadyAttachedSet.add(string.valueof(TaskAtt.Name+MapTaskIdToCaseId.get(TaskAtt.ParentId)));                
                    }
                    else
                        system.debug('############################Not copied. The attachment had been already attached to the case############################');          
                }
            }
        }
        return ToInsertList;
    }
    
    public static void BeforeInsertProcess(List<Task> Tasks, Map<String,Schema.RecordTypeInfo> MapTaskRecordType, Map<String,Boolean> MapCaseId)
    {
        if(TaskHandler.firstRunBeforeInsert)
        {
            System.Debug('## >>> Start of BeforeInsertProcess <<< run by ' + UserInfo.getName());
            
            list<Task> AP08ClosedStatusListTask= new list<Task>();
            set<id> AP08ClosedStatusSetCaseId= new set<id>();
            Map<Id,Case> MapCase = new Map<Id,Case>();
            //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- START
            Map<String, String> caseIdRTDevNameMap = new Map<String, String>();
            Map<String, String> RTDevNameToRTIdMap = new Map<String, String>();
            
            for(Schema.RecordTypeInfo s:MapTaskRecordType.values())
            {
                RTDevNameToRTIdMap.put(s.getDeveloperName(),s.getRecordTypeId());
            }
            
            //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- END
            
            
            
            for(Case c : [select Id, RecordType.Name, RecordType.DeveloperName, Distribution_Network__c from Case where id in :MapCaseId.Keyset()])
            {
                MapCase.put(c.Id,c);
                caseIdRTDevNameMap.put(c.Id,c.RecordType.DeveloperName); //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza
            }
            
            for (Task t: Tasks)
            {
                t.IsVisibleInSelfService=true;
                //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- START
                if(( CaseRTtoTaskRT__c.getAll().get(caseIdRTDevNameMap.get(t.whatId)) )!=null)
                {
                    String RTDevName =  CaseRTtoTaskRT__c.getAll().get(caseIdRTDevNameMap.get(t.whatId)).Task_RT_developername__c ;
                    if( RTDevNameToRTIdMap.get( RTDevName ) !=null )
                        t.RecordTypeId = ( RTDevNameToRTIdMap.get(RTDevName) );
                }
                //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- END
                
                if(MapCase.containsKey(t.whatId))
                    t.Distribution_Network__c= MapCase.get(t.whatId).Distribution_Network__c;    
                
                system.debug('Intermediario: '+t.Distribution_Network__c);            
                
                if (t.Type=='Email' && String.isBlank(t.HierarchyLevel1__c))
                    t.Tipo_Attivit__c='Email';
                
                else if (t.Type<>'Email' && String.isBlank(t.HierarchyLevel1__c) && t.Call__c == true)
                    t.Tipo_Attivit__c='Log a Call';   
                
                else if (t.Type<>'Email' && String.isBlank(t.HierarchyLevel1__c) && t.Call__c == false)
                {
                    t.Tipo_Attivit__c='Task';   
                    
                    if (MapTaskRecordType.get(t.RecordTypeId).getName() == 'Retention Task' && t.Esito_attivita_di_Retention__c == 'Da Verificare')
                        t.Tipo_Attivit__c='Retention Yellow';
                    else if(MapTaskRecordType.get(t.RecordTypeId).getName() == 'Retention Task' && t.Esito_attivita_di_Retention__c == 'Riuscita')
                        t.Tipo_Attivit__c='Retention Green';
                    else if(MapTaskRecordType.get(t.RecordTypeId).getName() == 'Retention Task' && t.Esito_attivita_di_Retention__c == 'Fallita')
                        t.Tipo_Attivit__c='Retention Red';      
                }
                else if(String.isNotBlank(t.HierarchyLevel1__c))
                {
                    t.Last_Status_Change__c = System.now();
                    t.Time_With_Technical_Office__c = 0;
                    t.Time_With_Customer__c = 0;            
                }
                
                TaskNoteHistoricization(t, new Task(), 'Before Insert', MapTaskRecordType);
                
                if(PAD.canTrigger('AP08'))
                {
                    if(t.status == AP_Constants.taskStatusClosed)
                    {
                        t.Closing_date_activities__c = system.now();
                        AP08ClosedStatusListTask.add(t);
                        AP08ClosedStatusSetCaseId.add(t.whatId);
                    }
                    else if(t.status == AP_Constants.taskStatusPending)                 
                        t.Pending_Status_Checked_In__c = system.now();
                }
            }
            
            if(AP08ClosedStatusListTask.size()> 0 )
                AP08TaskReporting.trackTaskWithoutPendingStatus(AP08ClosedStatusListTask, AP08ClosedStatusSetCaseId);
        }
    }
    
    public static void BeforeUpdateProcesses (List<Task> Tasks, Map<String,Boolean> MapCaseId,Map<String,Task> OldValues,Map<String,Schema.RecordTypeInfo> MapTaskRecordType,String defaultHoursId, String bhGDPR)
    {   
        if(TaskHandler.firstRunBeforeUpdate)
        {
            System.Debug('## >>> Start of BeforeUpdateProcesses <<< run by ' + UserInfo.getName());
            
            List<Case> CaseToUpdateList = new list<Case>();
            Map<Id,Case> MapCase = new Map<Id,Case>();         
            list<Task> AP08PendingStatusListTask= new list<Task>();
            list<Task> AP08ClosedStatusListTask= new list<Task>();
            set<id> AP08ClosedStatusSetCaseId= new set<id>();
            Map<String,Amministrazione_chiusura_automatica_task__c> AutomaticClosureTaskMap = new map<String,Amministrazione_chiusura_automatica_task__c>();    
            Map<String,String> MapRecTasktoCase = new map<String,String>();
            Set<String> stopStatusSet = new Set<String>();
            Set<String> closedStatusSet = new Set<String>();
            Map<Id,Case> MapCaseToUpd = new Map<Id,Case>();
            List<String> GDPRCategories = New List<String>();
            
            for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);
            }
            
            for (TaskStatus status:[SELECT MasterLabel FROM TaskStatus WHERE IsClosed = true ]) // NOPMD  Fix CRUD violation
            {
                closedStatusSet.add(status.MasterLabel);
            }
            
            for (Stop_Status__c stopStatus:[Select Name From Stop_Status__c where Object_Type__c = 'Task' ]) // NOPMD  Fix CRUD violation
            {
                stopStatusSet.add(stopStatus.Name);
            }
            
            MapRecTasktoCase.put('Motor Task','Motor');
            MapRecTasktoCase.put('Quadra Task','Quadra');
            MapRecTasktoCase.put('AXA Assicurazioni Task','Axa_Assicurazioni');
            MapRecTasktoCase.put('Non-Motor Task','NonMotor');
            MapRecTasktoCase.put('Close the loop Task','Close_the_loop');  
            MapRecTasktoCase.put('AMPS Financial Task','AMPS_Financial');
            MapRecTasktoCase.put('Sinistri Danni Task','Sinistri_Danni_Banca');
            MapRecTasktoCase.put('Agenzia dipendenti Task','Agenzia_dipendenti'); //OAVERSANO 09/01/2019 : Agenzia diretta
            MapRecTasktoCase.put('Reclamo Task','Reclamo'); //OAVERSANO 15/01/2019 : Gestione Reclami
            MapRecTasktoCase.put('Sinistri AAI Task','Sinistri_AAI'); //OAVERSANO 22/03/2019 : AXA Assistance
            MapRecTasktoCase.put('Terze Parti Task','Terze_Parti'); //OAVERSANO 17/06/2019 : ING
            
            for(Case c : [select Id, RecordTypeid, Distribution_Network__c,Account_Email__c, Complainant__c,Status,Tasks_Time_With_Technicians__c,Category__c,(select id, whatid, status from Tasks where IsClosed <> true) from Case where id in :MapCaseId.KeySet()])
            {
                MapCase.put(c.Id,c);
            }
            
            for(Configurazione_SLA_Uffici_Tecnici__c Conf:[SELECT Id,Task_Record_Type__c, Hierarchy_Level_1__c, Hierarchy_Level_2__c, Hierarchy_Level_3__c,(SELECT Caller__c, Days_Before_Alert__c,Days_Before_Closure__c, Rule_Active__c FROM Amministrazione_chiusura_automatica_task__r where Rule_Active__c = true) FROM configurazione_SLA_Uffici_Tecnici__c where Rule_Active__c = true ]) // NOPMD  Fix CRUD violation
            {            
                if(!(Conf.Amministrazione_chiusura_automatica_task__r).isEmpty())
                {
                    for(Amministrazione_chiusura_automatica_task__c ConfTask : Conf.Amministrazione_chiusura_automatica_task__r)
                    {
                        AutomaticClosureTaskMap.put(Conf.Hierarchy_Level_1__c+'-'+Conf.Hierarchy_Level_2__c+'-'+Conf.Hierarchy_Level_3__c+'-'+Conf.Task_Record_Type__c+'-'+ConfTask.Caller__c, ConfTask);
                    }
                }
            }
            
            system.debug('##AutomaticClosureTaskMap: '+AutomaticClosureTaskMap);
            
            for (Task t: Tasks)
            {
                system.debug('###TriggerStatus: '+t.Status+', TriggerOldStatus: '+OldValues.get(t.id).Status+', AutomaticAlertDate: '+t.Automatic_Task_Alert__c+', AutomaticClosureDate: '+t.Automatic_Closure_Task__c); 
                
                if(String.isnotBlank(t.HierarchyLevel1__c))
                {
                    system.debug('GDPRCategories: '+GDPRCategories);
                    system.debug('MapCase: '+MapCase);
                    Boolean CaseIsGDPR = GDPRCategories.contains(MapCase.get(t.whatId).Category__c);
                    
                    t.Old_Task_Status__c = OldValues.get(t.id).status;
                    
                    t.Distribution_Network__c=MapCase.get(t.whatId).Distribution_Network__c;
                    
                    if(String.IsNotBlank(MapCase.get(t.whatId).Account_Email__c))
                        t.Customer_Email__c = MapCase.get(t.whatId).Account_Email__c;
                    
                    system.debug('###CustomerEmail: '+t.Customer_Email__c);
                    
                    if(t.Status<>OldValues.get(t.id).Status)
                    {
                        if(t.Status == AP_Constants.taskStatusPending)
                        {
                            t.Old_Time_Before_Change__c = OldValues.get(t.Id).ActivityDate;
                            
                            if(system.now() > OldValues.get(t.Id).ActivityDate)
                                t.Due_Date_Elapsed__c = true;    
                            
                            if(t.Automatic_Task_Alert__c == null && t.Automatic_Closure_Task__c == null)
                            {
                                String bHoursToUse = defaultHoursId;
                                Integer WorkingHours = 10;
                                
                                if(CaseIsGDPR)
                                {
                                    bHoursToUse = bhGDPR;
                                    WorkingHours = 24;
                                }
                                
                                system.debug('###Firstif');
                                
                                String TaskRecTyp    = MapTaskRecordType.get(t.RecordTypeId).getName();       
                                String AllValues     = 'All';
                                String NullValue     = null;
                                
                                String SearchString1 = t.HierarchyLevel1__c+'-'+t.HierarchyLevel2__c+'-'+t.HierarchyLevel3__c+'-'+MapRecTasktoCase.get(TaskRecTyp)+'-'+MapCase.get(t.whatId).Complainant__c;
                                String SearchString2 = t.HierarchyLevel1__c+'-'+t.HierarchyLevel2__c+'-'+t.HierarchyLevel3__c+'-'+AllValues+'-'+MapCase.get(t.whatId).Complainant__c;
                                String SearchString3 = AllValues+'-'+NullValue+'-'+NullValue+'-'+MapRecTasktoCase.get(TaskRecTyp)+'-'+MapCase.get(t.whatId).Complainant__c;  
                                
                                system.debug('String 1: '+SearchString1 + ', String 2: ' + SearchString2 + ', String 3: ' + SearchString3);
                                
                                if(AutomaticClosureTaskMap.containsKey(SearchString1))
                                {
                                    Double FirstElapse  = AutomaticClosureTaskMap.get(SearchString1).Days_Before_Alert__c   -1;
                                    Double SecondElapse = AutomaticClosureTaskMap.get(SearchString1).Days_Before_Closure__c -1;
                                    
                                    t.Automatic_Task_Alert__c      = BusinessHours.addGMT(bHoursToUse,System.now(),((FirstElapse*WorkingHours)*60 * 60 * 1000L).longValue());                        
                                    t.Automatic_Closure_Task__c    = BusinessHours.addGMT(bHoursToUse,System.now(),((SecondElapse*WorkingHours)*60 * 60 * 1000L).longValue());
                                    
                                    system.debug('###Elapses1: '+FirstElapse+', '+SecondElapse);
                                    system.debug('###FirstDate: '+t.Automatic_Task_Alert__c+', SecondDate: '+t.Automatic_Closure_Task__c);
                                }
                                else if(AutomaticClosureTaskMap.containsKey(SearchString2))
                                {
                                    Double FirstElapse  = AutomaticClosureTaskMap.get(SearchString2).Days_Before_Alert__c   -1;
                                    Double SecondElapse = AutomaticClosureTaskMap.get(SearchString2).Days_Before_Closure__c -1;
                                    
                                    t.Automatic_Task_Alert__c      = BusinessHours.addGMT(bHoursToUse,System.now(),((FirstElapse*WorkingHours)*60 * 60 * 1000L).longValue());                        
                                    t.Automatic_Closure_Task__c    = BusinessHours.addGMT(bHoursToUse,System.now(),((SecondElapse*WorkingHours)*60 * 60 * 1000L).longValue());                        
                                    
                                    system.debug('Elapses2: '+FirstElapse+', '+SecondElapse);                    
                                }
                                else if(AutomaticClosureTaskMap.containsKey(SearchString3))
                                {
                                    Double FirstElapse  = AutomaticClosureTaskMap.get(SearchString3).Days_Before_Alert__c   -1;
                                    Double SecondElapse = AutomaticClosureTaskMap.get(SearchString3).Days_Before_Closure__c -1;
                                    
                                    t.Automatic_Task_Alert__c      = BusinessHours.addGMT(bHoursToUse,System.now(),((FirstElapse*WorkingHours)*60 * 60 * 1000L).longValue());                        
                                    t.Automatic_Closure_Task__c    = BusinessHours.addGMT(bHoursToUse,System.now(),((SecondElapse*WorkingHours)*60 * 60 * 1000L).longValue());                        
                                    
                                    system.debug('Elapses3: '+FirstElapse+', '+SecondElapse);                              
                                }                    
                            }                  
                        }
                        else if(t.Status == AP_Constants.taskStatusOutOfTime)
                        {                
                            Case OOTCase = MapCase.get(t.whatId);
                            
                            system.debug('###OOTCase: '+OOTCase);                                                
                            system.debug('###NotClosedTasks: '+OOTCase.Tasks);
                            
                            if(OOTCase.Tasks.size()==1 && OOTCase.Tasks[0].id==t.id && 
                               !(OOTCase.Status == AP_Constants.caseStatusOutOfTime ||
                                 OOTCase.Status == AP_Constants.caseStatusClosed ||
                                 OOTCase.Status == AP_Constants.caseStatusCancelled ))
                            {
                                Case CasetoUpdate = new Case (id = t.whatid);
                                CasetoUpdate.Status = AP_Constants.caseStatusOutOfTime;
                                CasetoUpdate.Case_Automatically_Closed_by_Task__c = true;
                                CaseToUpdateList.add(CasetoUpdate); 
                                MapCaseToUpd.put(t.whatId,CasetoUpdate);                       
                            }                                                        
                        }                
                        
                        if(OldValues.get(t.id).Status == AP_Constants.taskStatusPending)
                        {
                            t.Automatic_Task_Alert__c = null;
                            t.Automatic_Closure_Task__c = null;     
                            
                            if(stopStatusSet.contains(OldValues.get(t.id).Status) && t.Last_Status_Change__c!=null)
                            {
                                Double timeSinceLastStatus = BusinessHours.diff(defaultHoursId, t.Last_Status_Change__c, System.now())/3600000.0;
                                
                                system.debug('New End Date: '+(BusinessHours.addGMT(defaultHoursId,t.ActivityDate,(timeSinceLastStatus*60 * 60 * 1000L).longValue())));
                                
                                if(!CaseIsGDPR)
                                    t.ActivityDate = (BusinessHours.addGMT(defaultHoursId,t.ActivityDate,(timeSinceLastStatus*60 * 60 * 1000L).longValue())).date();  
                                
                                if(t.Time_With_Customer__c!=null)
                                    t.Time_With_Customer__c += timeSinceLastStatus;
                                else
                                    t.Time_With_Customer__c = timeSinceLastStatus;
                                
                                system.debug('Old End Date: '+OldValues.get(t.id).ActivityDate+', Elapsed: '+timeSinceLastStatus+', New End Date: '+t.ActivityDate);   
                            }             
                        }
                        else if(OldValues.get(t.id).Status == AP_Constants.taskStatusClosed)
                        {
                            t.Task_Reopening_Date__c           = System.now();
                            t.Time_With_Customer__c            = null;
                            t.Time_With_Technical_Office__c    = null;
                            t.Task_Age_in_Business_Hours__c    = null;
                            t.Due_Date_Elapsed__c              = false;
                            
                            if(t.SLAHours__c!=null && !CaseIsGDPR)
                                t.ActivityDate  = Date.valueOf(BusinessHours.addGMT(defaultHoursId,system.now(),(t.SLAHours__c*60 * 60 * 1000L).longValue()));
                            
                            system.debug('Old Due Date: '+OldValues.get(t.id).ActivityDate+', New Due Date: '+t.ActivityDate);                  
                        }
                        //else if(!OldValues.get(t.id).isClosed && t.Last_Status_Change__c!=null)
                        else if(!stopStatusSet.contains(OldValues.get(t.id).Status) && t.Last_Status_Change__c!=null && !OldValues.get(t.id).isClosed)
                        {
                            Double timeSinceLastStatus = BusinessHours.diff(defaultHoursId, t.Last_Status_Change__c, System.now())/3600000.0;
                            
                            if(t.Time_With_Technical_Office__c!=null)
                                t.Time_With_Technical_Office__c += timeSinceLastStatus;
                            else
                                t.Time_With_Technical_Office__c = timeSinceLastStatus;                            
                            
                            Decimal CaseTimeWithOffices = 0;
                            
                            Case CaseToUpdate = new Case(Id = t.whatid);
                            
                            CaseTimeWithOffices = MapCase.get(t.whatid).Tasks_Time_With_Technicians__c;
                            
                            system.debug('#CaseTimeWithOffices: '+MapCase.get(t.whatid).Tasks_Time_With_Technicians__c);                        
                            
                            if(CaseTimeWithOffices == 0 || CaseTimeWithOffices == null)
                                CaseToUpdate.Tasks_Time_With_Technicians__c = t.Time_With_Technical_Office__c;
                            else
                                CaseToUpdate.Tasks_Time_With_Technicians__c = CaseTimeWithOffices + timeSinceLastStatus;
                            
                            if(MapCaseToUpd.containsKey(t.whatid))
                            {
                                if(CaseToUpdateList.indexOf(MapCaseToUpd.get(t.whatid))<>-1)
                                {
                                    Integer CaseIndex = CaseToUpdateList.indexOf(MapCaseToUpd.get(t.whatid));
                                    
                                    Case Cas = MapCaseToUpd.get(t.whatid);
                                    
                                    Cas.Tasks_Time_With_Technicians__c = CaseToUpdate.Tasks_Time_With_Technicians__c;
                                    
                                    CaseToUpdateList.set(CaseIndex,Cas);
                                }
                            } 
                            else
                                CaseToUpdateList.add(CaseToUpdate);                         
                            
                            system.debug('CaseToUpdate: '+CaseToUpdate);
                        }
                        
                        if (closedStatusSet.contains(t.Status) && !OldValues.get(t.id).isClosed)                        
                            t.Task_Age_in_Business_Hours__c = (t.Time_With_Customer__c==null?0:t.Time_With_Customer__c) +(t.Time_With_Technical_Office__c==null?0:t.Time_With_Technical_Office__c);                                                               
                        
                        if(t.Last_Status_Change__c!=null)
                            t.Last_Status_Change__c = System.now();
                    }
                    
                    TaskNoteHistoricization(t, OldValues.get(t.id), 'Before Update' , MapTaskRecordType);                         
                }
                
                if(t.Type<>'Email' && String.isBlank(t.HierarchyLevel1__c) && t.Call__c == false)
                {
                    if (MapTaskRecordType.get(t.RecordTypeId).getName() == 'Retention Task' && t.Esito_attivita_di_Retention__c == 'Da Verificare')
                        t.Tipo_Attivit__c='Retention Yellow';
                    else if(MapTaskRecordType.get(t.RecordTypeId).getName() == 'Retention Task' && t.Esito_attivita_di_Retention__c == 'Riuscita')
                        t.Tipo_Attivit__c='Retention Green';
                    else if(MapTaskRecordType.get(t.RecordTypeId).getName() == 'Retention Task' && t.Esito_attivita_di_Retention__c == 'Fallita')
                        t.Tipo_Attivit__c='Retention Red';    
                }
                
                if(PAD.canTrigger('AP08'))
                {
                    if(t.status  <> OldValues.get(t.id).status)
                    {
                        if(t.status == AP_Constants.taskStatusClosed)    
                            t.Closing_date_activities__c = system.now();
                        
                        else if(t.status == AP_Constants.taskStatusPending)
                            t.Pending_Status_Checked_In__c = system.now();
                        
                        if(OldValues.get(t.id).status == AP_Constants.taskStatusPending)
                            AP08PendingStatusListTask.add(t);
                        
                        if(t.status == AP_Constants.taskStatusClosed)
                        {
                            AP08ClosedStatusListTask.add(t);
                            AP08ClosedStatusSetCaseId.add(t.whatId);                      
                        }
                    }
                }
            }
            
            if(CaseToUpdateList.size()>0)
                Update CaseToUpdateList;
            
            if(AP08PendingStatusListTask.size()> 0)
                AP08TaskReporting.trackTaskPendingStatus(AP08PendingStatusListTask);
            
            if(AP08ClosedStatusListTask.size()> 0 )
                AP08TaskReporting.trackTaskWithoutPendingStatus(AP08ClosedStatusListTask, AP08ClosedStatusSetCaseId);   
            
        } 
    }
    
    public static void TaskNoteHistoricization(Task ta, Task OldTa, String TriggerType,Map<String,Schema.RecordTypeInfo> MapTaskRecordType)
    {
        system.debug('Task Historicization process Start');
        
        String data =(System.now()).format('dd/MM/yyyy kk.mm');
        String ProfileName = [Select Name from Profile where Id=:Userinfo.getProfileId()].Name;
        Boolean ProfileNotAvailable = (ProfileName == 'System Administrator' || ProfileName == 'AXA MPS Business Admin');
        Map<string,Task_Notes_Historicization__c> MapTaskHistory = Task_Notes_Historicization__c.getAll();
        Boolean Avail_RecordType = false;
        
        system.debug('RecordTypeId: '+ta.RecordTypeId);
        system.debug('MapTaskRecordType: '+MapTaskRecordType.get(ta.RecordTypeId).getName());
        system.debug('MapTaskHistory: '+MapTaskHistory);
        
        
        if (MapTaskHistory.containsKey(MapTaskRecordType.get(ta.RecordTypeId).getName())) 
            Avail_RecordType = MapTaskHistory.get(MapTaskRecordType.get(ta.RecordTypeId).getName()).Enable_Historicization__c;       
        
        system.debug('ProfileName:' +ProfileName);
        system.debug('ProfileNotAvailable: '+ProfileNotAvailable);                   
        
        if(Avail_RecordType)
        {
            if(TriggerType == 'BeforeInsert')
            {              
                if(String.isNotBlank(ta.Description))
                { 
                    ta.Description =  Userinfo.getName()+', '+data+' '+':'+'\n'+ta.Description;
                }
            }
            else
            {               
                try
                {     
                    System.debug('current date:'+data);                                     
                    
                    if(String.isnotBlank(ta.Description))
                    {
                        if(ta.Description <> OldTa.Description)
                        {
                            System.debug('--*Description is changed*--');
                            System.debug('**Old Description :'+OldTa.Description);
                            System.debug('**New Description :'+ta.Description);
                            
                            if(String.isnotBlank(OldTa.Description))
                            {
                                System.debug('Process Start');
                                
                                String OldDesc = OldTa.Description;
                                String NewDesc = ta.Description;
                                
                                string NewVal1='';
                                string Newval2='';             
                                
                                string Difference = NewDesc.difference(OldDesc);
                                
                                system.debug('Difference: '+Difference);
                                
                                if(OldDesc==Difference)
                                {
                                    system.debug('-------------The entire Text has been replaced---------------');
                                    
                                    NewVal1 =  '\n'+ '\n'+ Userinfo.getName()+', '+data+' '+':'+ '\n'+NewDesc+'\n'+ '\n'+OldDesc;
                                    
                                    System.debug('-------NewVal1: '+NewVal1);                   
                                    ta.Description =NewVal1;
                                }
                                else
                                {                    
                                    System.debug('------------------New text has been added--------------');
                                    
                                    List<string> partsOld = OldDesc.split('\n');
                                    List<string> partsNew = NewDesc.split('\n');
                                    
                                    integer eqNum = 0;                               
                                    
                                    string Old = '';
                                    string Newd = '';
                                    
                                    if(partsOld.size()<=partsNew.size())
                                    {
                                        for(integer iAct = 0;iAct<partsOld.size();iAct++)
                                        {
                                            Old = (partsOld[iAct].trim()).replaceAll('(?m)^[ \t]*\r?\n','');
                                            Newd =(partsNew[iAct].trim()).replaceAll('(?m)^[ \t]*\r?\n','');
                                            
                                            if(Old==Newd)
                                            {
                                                eqNum++;
                                            }                                        
                                        }                           
                                        
                                        if(eqNum<partsOld.size())
                                        {
                                            if(!ProfileNotAvailable)
                                                ta.addError('Attenzione: Non è consentito alterare il contenuto dei commenti precedentemente inseriti.   Per introdurre una nuova nota andare a capo.');
                                        }                                                                        
                                        else
                                        {
                                            string StringDifference='';
                                            
                                            for(integer iDiff = eqNum;iDiff<partsNew.size();iDiff++)
                                            {
                                                StringDifference += (partsNew[iDiff].trim()).replaceAll('(?m)^[ \t]*\r?\n','')+'\n';
                                            }
                                            
                                            StringDifference = (StringDifference.trim()).replaceAll('(?m)^[ \t]*\r?\n','');
                                            
                                            system.debug('StringDifference : '+StringDifference);
                                            
                                            if(StringDifference!='' && StringDifference!= null)
                                            { 
                                                Newval2 =  '\n'+ '\n'+ Userinfo.getName()+', '+data+' '+':'+ '\n' +StringDifference+'\n'+ '\n'+ OldDesc;
                                                
                                                ta.Description =Newval2;
                                            }
                                            else
                                            {
                                                Newval2 = OldDesc;                                                  
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if(!ProfileNotAvailable)
                                            ta.addError('Attenzione: Non è consentito alterare il contenuto dei commenti precedentemente inseriti.   Per introdurre una nuova nota andare a capo.');
                                    }    
                                }                   
                            }
                            else
                            {
                                ta.Description = Userinfo.getName()+', '+data+' '+':'+'\n'+ta.Description;
                            }
                        }
                    }
                    else
                    {
                        if(!ProfileNotAvailable && (String.isNotBlank(OldTa.Description)))
                            ta.addError('Attenzione: Non è consentito rimuovere i commenti precedentemente inseriti');
                    }
                }
                catch(Exception ex)
                {
                    system.debug('Errore:'+ex);
                    string error = ex.getMessage(); 
                }              
            }
        }
        system.debug('Task Historicization process End');
    }
    
    public static void LeadTaskProcesses(List<Task> ListTaskLead)
    {
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].Name;
        Boolean isAdmin = (profileName=='System Administrator' || profileName=='Amministratore del sistema')?true:false;
        
        AAI_Code_Variables__c aaiCS = AAI_Code_Variables__c.getValues('LeadStatusActivityError');
        
        if(aaiCS != null)
        {            
            if(!isAdmin)
            {
                for(Task t: ListTaskLead)
                {
                    if(t.Status == 'To be processed' || t.Status == 'Da lavorare')
                        t.addError(aaiCS.Value__c);
                }
            }
        }
    }
    
    public static List<Case> CalcoloTempidiLavorazione(Map<String,Boolean> MapCaseId,Map<String,Case> MapCase,String defaultHoursId,String TriggerType,List<String> GDPRHierarchyLevels,List<Task>Tasks,String bhGDPR,List<String>GDPRCategories)  
    {  
        system.debug('########INIZIO FUNZIONE MODIFICA SLA TOT UFFICI TECNICI################');
        
        Set<String>  AlreadyFoundTaskSet  = new Set<String>();
        Decimal TotalTasksSLA       = 0;
        String TaskKey              = '';
        Decimal TaskSLA = 0;
        String TaskSubject = '';
        //List<Case> CaseToUpdate = new List<Case>();
        Set<Case> CaseToUpdate = new Set<Case>();
        List<Case> CaseToUpdateList = new List<Case>();
        Map<String,Set<String>> MapCaseTsks = new Map<String,Set<String>>();
        
        for(Case caso : [SELECT c.Id,c.SLA_Technical_Offices__c,c.Tasks_End_Date__c,c.Oldest_Task_Creat_Date__c,c.StatusReopened_Date__c, TECH_2nd_support_activities__c,TECH_2nd_support_internal_activities__c, Data_Primo_Task_DPO__c, Category__c,Data_primo_task_interno__c, (select id, Createddate, Task_Reopening_Date__c, Subject,whatid, SLAHours__c,ActivityDate,TECH_Key__c,Recordtype.Developername, HierarchyLevel1__c, isClosed, Tipo_Attivit__c from Tasks where  HierarchyLevel1__c !=null Order by CreatedDate Asc)  from Case c where Id  in :MapCaseId.keyset() ]) // NOPMD  Fix CRUD violation
        {
            TotalTasksSLA                = caso.SLA_Technical_Offices__c;
            Datetime OldestTaskCreatDate = caso.Oldest_Task_Creat_Date__c;
            Datetime ReopenDate          = caso.StatusReopened_Date__c;
            Datetime OldestTaskCreatDateDPO = caso.Data_Primo_Task_DPO__c;
            Datetime FirstActivityDate = null;
            Datetime FirstActivityDateDPO = null;
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
            Datetime OldestInternalTaskCreatDate = caso.Data_primo_task_interno__c;
            Datetime FirstInternalActivityDate = null;
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
            Integer counterLoop = 0;
            Integer counterLoopDPO = 0;
            
            System.debug('Caseid: '+caso.id+' Case oldesttaskdate: '+OldestTaskCreatDate+' totalsla :'+TotalTasksSLA);
            
            Integer MaxSLA   = 0;
            Integer MaxSLA_DPO = 0;//MOSCATELLI_M 02/05/2018: GDPR
            Datetime MinDate = null;
            Datetime MinDate_DPO = null;//MOSCATELLI_M 02/05/2018: GDPR
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
            Datetime MinDate_TaskInterni = null;
            Integer MaxSLA_TaskInterni = 0;
            Boolean TaskIsInteral = false;
            Integer counterInternalTask=0;
            Boolean isupdateSLATaskInterni=false;
            Boolean isupdateTaskInterni = false;
            Integer counterLoopInternalTask=0;
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
            Integer counter  =0;
            Integer counterDPO = 0;  
            Boolean isupdate =false;
            Boolean isupdateSLA = false;
            Boolean isupdate2ndSupport = false;  
            Boolean isupdateDPO =false;
            Boolean isupdateSLADPO = false;
            Boolean TaskIsGDPR = false;
            
            for(Task attivita : caso.Tasks)
            {
                if(String.isNotBlank(attivita.HierarchyLevel1__c))
                {
                    TaskKey     = attivita.TECH_Key__c;
                    TaskSubject = attivita.Subject;  
                    TaskIsGDPR = GDPRHierarchyLevels.contains(attivita.HierarchyLevel1__c);//MOSCATELLI_M 02/05/2018: GDPR  
                    TaskIsInteral = (attivita.Tipo_Attivit__c == 'Task Interno')?true:false;//MOSCATELLI_M 07/06/2018: Inoltro Task Interni
                    
                    if(!AlreadyFoundTaskSet.contains(string.valueof(TaskKey)))
                    {
                        TaskSLA = attivita.SLAHours__c;
                        Datetime TaskCreateddate = attivita.Createddate;
                        Datetime TaskEndDate = attivita.ActivityDate;
                        Datetime TaskReopeningDT = attivita.Task_Reopening_Date__c;
                        
                        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                        if(!TaskIsGDPR && counterLoop==0 && !TaskIsInteral)
                            FirstActivityDate = TaskCreateddate;
                        else if(TaskIsGDPR && counterLoopDPO==0 && !TaskIsInteral)  
                            FirstActivityDateDPO = TaskCreateddate;            
                        else if(!TaskIsGDPR && counterLoopInternalTask==0 && TaskIsInteral)   
                            FirstInternalActivityDate = TaskCreateddate; 
                        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                        
                        if(ReopenDate==null)
                        {
                            //MOSCATELLI_M 02/05/2018: GDPR -- START
                            if(!TaskIsGDPR)
                            {
                                //MOSCATELLI_M 02/05/2018: GDPR -- END
                                
                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                if(!TaskIsInteral)
                                {
                                    if(integer.valueOf(TaskSLA) > MaxSLA)
                                        MaxSLA = integer.valueOf(TaskSLA); 
                                }
                                else
                                {
                                    if(integer.valueOf(TaskSLA) > MaxSLA_TaskInterni)
                                        MaxSLA_TaskInterni = integer.valueOf(TaskSLA); 
                                }
                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                            }
                            else
                            {
                                if(integer.valueOf(TaskSLA) > MaxSLA_DPO)
                                    MaxSLA_DPO = integer.valueOf(TaskSLA);               
                            }
                        }
                        else
                        {
                            if(TaskReopeningDT==null)
                            {
                                if(!TaskIsGDPR)
                                {
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                    if(!TaskIsInteral)
                                    {
                                        if(TaskCreateddate >= ReopenDate)
                                        {
                                            if(integer.valueOf(TaskSLA) > MaxSLA)
                                                MaxSLA = integer.valueOf(TaskSLA);
                                        }
                                    }
                                    else 
                                    {
                                        if(TaskCreateddate >= ReopenDate)
                                        {
                                            if(integer.valueOf(TaskSLA) > MaxSLA_TaskInterni)
                                                MaxSLA_TaskInterni = integer.valueOf(TaskSLA);
                                        }                    
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                }
                                else
                                {
                                    if(TaskCreateddate >= ReopenDate)
                                    {
                                        if(integer.valueOf(TaskSLA) > MaxSLA_DPO)
                                            MaxSLA_DPO = integer.valueOf(TaskSLA);
                                    }                
                                }
                            }
                            else
                            {
                                if(!TaskIsGDPR)
                                {
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                    if(TaskReopeningDT>=ReopenDate)
                                    {
                                        if(!TaskIsInteral)
                                        {
                                            if(integer.valueOf(TaskSLA) > MaxSLA)
                                                MaxSLA = integer.valueOf(TaskSLA); 
                                        }
                                        else
                                        {
                                            if(integer.valueOf(TaskSLA) > MaxSLA_TaskInterni)
                                                MaxSLA_TaskInterni = integer.valueOf(TaskSLA);                      
                                        }                                   
                                    }
                                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                                }
                                else
                                {
                                    if(TaskReopeningDT>=ReopenDate)
                                    {
                                        if(integer.valueOf(TaskSLA) > MaxSLA_DPO)
                                            MaxSLA_DPO = integer.valueOf(TaskSLA);                                    
                                    }                
                                }
                            }                            
                        }
                        
                        if(ReopenDate!= null)
                        {
                            if(!TaskIsGDPR)
                            {
                                if(!TaskIsInteral)
                                {
                                    if(!attivita.isclosed && MinDate == null && (TaskCreateddate >= ReopenDate) && TaskReopeningDT==null) 
                                    {
                                        MinDate = TaskCreateddate;
                                        
                                        system.debug('Id :'+attivita.Id+', MinDate: '+MinDate);
                                    }
                                    else if(!attivita.isclosed && MinDate == null && (TaskReopeningDT >= ReopenDate) && TaskReopeningDT!=null)
                                    {
                                        MinDate = TaskReopeningDT;
                                        
                                        system.debug('Id :'+attivita.Id+', MinDate: '+MinDate);
                                    }                    
                                    else if(!attivita.isclosed && TaskReopeningDT != null && MinDate!=null)
                                    {
                                        if((TaskReopeningDT >= ReopenDate) && (TaskReopeningDT <= MinDate))
                                            MinDate = TaskReopeningDT;  
                                    }
                                    else if(!attivita.isclosed && (TaskReopeningDT == null && MinDate!=null) && (TaskCreateddate >= ReopenDate) && (TaskCreateddate <= MinDate)) 
                                        MinDate = TaskCreateddate;
                                }
                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                else
                                {
                                    if(!attivita.isclosed && MinDate_TaskInterni == null && (TaskCreateddate >= ReopenDate) && TaskReopeningDT==null) 
                                    {
                                        MinDate_TaskInterni = TaskCreateddate;
                                        
                                        system.debug('Id :'+attivita.Id+', MinDate: '+MinDate_TaskInterni);
                                    }
                                    else if(!attivita.isclosed && MinDate == null && (TaskReopeningDT >= ReopenDate) && TaskReopeningDT!=null)
                                    {
                                        MinDate_TaskInterni = TaskReopeningDT;
                                        
                                        system.debug('Id :'+attivita.Id+', MinDate: '+MinDate_TaskInterni);
                                    }                    
                                    else if(!attivita.isclosed && TaskReopeningDT != null && MinDate_TaskInterni!=null)
                                    {
                                        if((TaskReopeningDT >= ReopenDate) && (TaskReopeningDT <= MinDate_TaskInterni))
                                            MinDate_TaskInterni = TaskReopeningDT;  
                                    }
                                    else if(!attivita.isclosed && (TaskReopeningDT == null && MinDate_TaskInterni!=null) && (TaskCreateddate >= ReopenDate) && (TaskCreateddate <= MinDate_TaskInterni)) 
                                        MinDate_TaskInterni = TaskCreateddate;                  
                                }
                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                            }
                            else
                            {
                                if(!attivita.isclosed && MinDate_DPO == null && (TaskCreateddate >= ReopenDate) && TaskReopeningDT==null) 
                                {
                                    MinDate_DPO = TaskCreateddate;
                                    
                                    system.debug('Id :'+attivita.Id+', MinDate: '+MinDate);
                                }
                                else if(!attivita.isclosed && MinDate_DPO == null && (TaskReopeningDT >= ReopenDate) && TaskReopeningDT!=null)
                                {
                                    MinDate_DPO = TaskReopeningDT;
                                    
                                    system.debug('Id :'+attivita.Id+', MinDate: '+MinDate);
                                }                    
                                else if(!attivita.isclosed && TaskReopeningDT != null && MinDate_DPO!=null)
                                {
                                    if((TaskReopeningDT >= ReopenDate) && (TaskReopeningDT <= MinDate_DPO))
                                        MinDate_DPO = TaskReopeningDT;  
                                }
                                else if(!attivita.isclosed && (TaskReopeningDT == null && MinDate_DPO!=null) && (TaskCreateddate >= ReopenDate) && (TaskCreateddate <= MinDate_DPO)) 
                                    MinDate_DPO = TaskCreateddate;              
                            }
                            
                            system.debug('Id :'+attivita.Id+', MinDate: '+MinDate);
                        }
                        else
                        {
                            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                            //if((counter == 0 || counterDPO == 0) && !attivita.isclosed)
                            if((counter == 0 || counterDPO == 0 || counterInternalTask == 0) && !attivita.isclosed)
                            {
                                if(!TaskIsGDPR)
                                    //MinDate = TaskCreateddate;
                                {
                                    if(!TaskIsInteral)
                                        MinDate = TaskCreateddate;
                                    else
                                        MinDate_TaskInterni = TaskCreateddate;
                                }
                                else 
                                    MinDate_DPO = TaskCreateddate;
                            }
                            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                        }
                        
                        if(!attivita.isclosed)
                        {
                            if(TaskIsGDPR)
                                counterDPO++;
                            else
                                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                                //counter++;
                            {
                                if(!TaskIsInteral)
                                    counter++;
                                else
                                    counterInternalTask++;
                            }
                            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END             
                        }
                        
                        AlreadyFoundTaskSet.add(string.valueof(TaskKey)+'');
                        
                        system.debug('#Task key: '+TaskKey+' TaskSLA: '+TaskSLA+' tASK DATE: '+TaskCreateddate);
                    }
                    else
                        system.debug('######Twin Task found: '+TaskKey);
                    
                    counterLoop++;

                    if(TaskIsGDPR)
                        counterLoopDPO++;
                        
                    if(TaskIsInteral)
                        counterLoopInternalTask++;//MOSCATELLI_M 07/06/2018: Inoltro Task Interni
                }
            }
            
            
            system.debug('MinDate: '+MinDate+', MaxSLA: '+MaxSLA);
            
            Case ParentCase = new Case(Id = caso.id);
            
            if(TriggerType =='After Insert') 
            {
                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                /*
                if(!MapCaseId.get(ParentCase.Id))
                {
                    Decimal CDLTaskNum = (ParentCase.TECH_2nd_support_activities__c!=null)?ParentCase.TECH_2nd_support_activities__c:0;
                    CDLTaskNum = CDLTaskNum+1;
                    ParentCase.TECH_2nd_support_activities__c = CDLTaskNum;
                    MapCase.put(caso.id,ParentCase);
                    isupdate2ndSupport  = true;
                }
                */
               
                Decimal CDLTaskNum_old = (caso.TECH_2nd_support_activities__c!=null)?caso.TECH_2nd_support_activities__c:0;
                Decimal InternalTaskNum_old = (caso.TECH_2nd_support_internal_activities__c!=null)?caso.TECH_2nd_support_internal_activities__c:0;
                Decimal CDLTaskNum = CDLTaskNum_old;
                Decimal InternalTaskNum= InternalTaskNum_old;
                Set<String>FoundKeys = new Set<String>();

                for(Task t:Tasks)
                {
                    if(!FoundKeys.contains(t.TECH_Key__c) && String.isNotBlank(t.HierarchyLevel1__c))
                    {
                        if(t.Tipo_Attivit__c == 'Task Interno')
                            InternalTaskNum = InternalTaskNum +1;
                        else if(t.Tipo_Attivit__c <> 'Task Interno')
                            CDLTaskNum = CDLTaskNum +1;

                        FoundKeys.add(t.TECH_Key__c);
                    }
                }


                if((InternalTaskNum>InternalTaskNum_old) || (CDLTaskNum > CDLTaskNum_old))
                {
                    ParentCase.TECH_2nd_support_internal_activities__c = InternalTaskNum;
                    ParentCase.TECH_2nd_support_activities__c = CDLTaskNum;
                
                    MapCase.put(caso.id,ParentCase);
                    isupdate2ndSupport  = true;
                }
                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
            }
            
            if(OldestTaskCreatDate == null && MinDate!=null)
            {
                system.debug('######Update OldestTaskDate: '+MinDate);
                ParentCase.Oldest_Task_Creat_Date__c = MinDate;
                OldestTaskCreatDate                  = MinDate;
                isupdate = true;
            }
            
            ///GDPR
            if(OldestTaskCreatDateDPO == null && MinDate_DPO!=null)
            {
                system.debug('######Update OldestTaskDate: '+MinDate_DPO);
                ParentCase.Data_Primo_Task_DPO__c = MinDate_DPO;
                OldestTaskCreatDateDPO          = MinDate_DPO;
                isupdateDPO = true;
            }
            
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
            if(OldestInternalTaskCreatDate == null && MinDate_TaskInterni!=null)
            {
                system.debug('######Update OldestTaskDate: '+MinDate_TaskInterni);
                ParentCase.Data_primo_task_interno__c = MinDate_TaskInterni;
                OldestInternalTaskCreatDate           = MinDate_TaskInterni;
                isupdateTaskInterni = true;
            }      
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
            
            //if(FirstActivityDate!=null && !TaskIsGDPR)
            if(OldestTaskCreatDate!=null && !TaskIsGDPR)
            {
                if(!GDPRCategories.contains(caso.Category__c))
                {
                    Double timeFromFirstTask            = BusinessHours.diff(defaultHoursId, OldestTaskCreatDate, System.now())/3600000.0;
                    ParentCase.SLA_Technical_Offices__c = integer.valueOf(timeFromFirstTask) + integer.valueOf(MaxSLA);
                    ParentCase.Tasks_End_Date__c        = BusinessHours.addGMT(defaultHoursId, OldestTaskCreatDate,(timeFromFirstTask*60*60*1000L + MaxSLA*60*60*1000L).longValue());
                    system.debug('######Updates = SLA Tech Offices: '+ParentCase.SLA_Technical_Offices__c+', Old Tasks Start Date: '+OldestTaskCreatDate+', Tasks End Date: '+ParentCase.Tasks_End_Date__c+', Time Elapsed: '+timeFromFirstTask);
                }
                else
                {
                    ParentCase.SLA_Technical_Offices__c = integer.valueOf(MaxSLA);
                    ParentCase.Tasks_End_Date__c        = BusinessHours.addGMT(bhGDPR, OldestTaskCreatDate,MaxSLA*60*60*1000L);
                }
                
                isupdateSLA = true;        
            }
            
            //GDPR
            if(OldestTaskCreatDateDPO!=null && TaskIsGDPR)
            {        
                ParentCase.SLA_DPO__c         = integer.valueOf(MaxSLA_DPO);
                ParentCase.Data_Prevista_Fine_DPO__c   = BusinessHours.addGMT(bhGDPR, OldestTaskCreatDateDPO,MaxSLA_DPO*60*60*1000L);
                isupdateSLADPO = true;
                
                system.debug('######Updates = SLA DPO: '+ParentCase.SLA_DPO__c+', Old Tasks Start Date: '+OldestTaskCreatDateDPO+', Tasks End Date: '+ParentCase.Data_Prevista_Fine_DPO__c);
            }
            //GDPR
            
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
            if(OldestInternalTaskCreatDate!=null && !TaskIsGDPR && TaskIsInteral)
            {        
                Double timeFromFirstTask            = BusinessHours.diff(defaultHoursId, OldestInternalTaskCreatDate, System.now())/3600000.0;
                ParentCase.SLA_Task_interni__c      = integer.valueOf(timeFromFirstTask) + integer.valueOf(MaxSLA_TaskInterni);
                ParentCase.Data_prevista_fine_task_interni__c        = BusinessHours.addGMT(defaultHoursId, OldestInternalTaskCreatDate,(timeFromFirstTask*60*60*1000L + MaxSLA_TaskInterni*60*60*1000L).longValue());
                system.debug('######Updates = SLA Internal Tech Offices: '+ParentCase.SLA_Task_interni__c+', Old Tasks Start Date: '+OldestInternalTaskCreatDate+', Tasks End Date: '+ParentCase.Data_prevista_fine_task_interni__c+', Time Elapsed: '+timeFromFirstTask);
                isupdateSLATaskInterni = true;
            }      
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END      
            
            //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
            //if(isupdate || isupdateSLA || isupdate2ndSupport || isupdateDPO || isupdateSLADPO)
            if(isupdate || isupdateSLA || isupdate2ndSupport || isupdateDPO || isupdateSLADPO || isupdateTaskInterni || isupdateSLATaskInterni)      
                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
            {
                if(MapCase.containsKey(caso.Id))
                {
                    Case c = MapCase.get(caso.id);
                    
                    if(isupdate)
                    {
                        //Case c = MapCase.get(caso.id);
                        c.Oldest_Task_Creat_Date__c = ParentCase.Oldest_Task_Creat_Date__c;
                        //MapCase.put(caso.id,c);
                    }
                    
                    if(isupdateSLA)
                    {
                        //Case c = MapCase.get(caso.id);
                        c.SLA_Technical_Offices__c = ParentCase.SLA_Technical_Offices__c;
                        c.Tasks_End_Date__c = ParentCase.Tasks_End_Date__c;
                        //MapCase.put(caso.id,c);
                    }
                    
                    if(isupdate2ndSupport)
                    {
                        //Case c = MapCase.get(caso.id);
                        c.TECH_2nd_support_activities__c = ParentCase.TECH_2nd_support_activities__c;
                        c.TECH_2nd_support_internal_activities__c = ParentCase.TECH_2nd_support_internal_activities__c;//MOSCATELLI_M 07/06/2018: Inoltro Task Interni
                        //MapCase.put(caso.id,c);
                    }
                    
                    if(isupdateDPO)
                    {
                        //Case c = MapCase.get(caso.id);
                        c.Data_Primo_Task_DPO__c = ParentCase.Data_Primo_Task_DPO__c;
                        //MapCase.put(caso.id,c);
                    }
                    
                    if(isupdateSLADPO)
                    {
                        //Case c = MapCase.get(caso.id);
                        c.SLA_DPO__c = ParentCase.SLA_DPO__c;
                        c.Data_Prevista_Fine_DPO__c = ParentCase.Data_Prevista_Fine_DPO__c;
                        //MapCase.put(caso.id,c);
                    }
                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                    if(isupdateTaskInterni)          
                        c.Data_primo_task_interno__c = ParentCase.Data_primo_task_interno__c;
                    
                    if(isupdateSLATaskInterni)
                    {
                        c.SLA_Task_interni__c = ParentCase.SLA_Task_interni__c;
                        c.Data_prevista_fine_task_interni__c = ParentCase.Data_prevista_fine_task_interni__c;
                    }          
                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                    MapCase.put(caso.id,c);
                }
                else
                    MapCase.put(Caso.id,ParentCase);
            }
            
            for(String s: MapCase.keyset())
            {
                CasetoUpdate.add(MapCase.get(s));
            }
        }
        system.debug('########FINE FUNZIONE MODIFICA SLA TOT UFFICI TECNICI################');
        
        if(CaseToUpdate.size()>0)
            CaseToUpdateList.addAll(CaseToUpdate);
        
        //return CaseToUpdate;
        return CaseToUpdateList;
    }
}