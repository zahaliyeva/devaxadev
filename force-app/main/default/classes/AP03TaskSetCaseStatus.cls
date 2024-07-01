public class AP03TaskSetCaseStatus {
/* 
----------------------------------------------------------------------
-- - Name          : AP01CaseCalculateDueDate
-- - Author        : Spoon Consulting
-- - Description   : Class to calculate DueDate and AcknowledgementDueDate
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 15-JAN-2015  HDU    1.0     Initial version
-- 27-JAN-2015  NAP    2.0     TECH_Key__c + update all related task
----------------------------------------------------------------------
***********************************************************************/
/*
    public static void setStatus(map<Id,Case> mapCase,map<Id,Case> MapCaseIdOfPendingTask,Set<String> setTaskKey){
        
        Id defaultHoursId = [select Id from BusinessHours where IsDefault=true].id;
        
        List<Task> TasksToUpdate =new list<Task>(); 
        
        System.debug('>>> START AP03TaskSetCaseStatus - setStatus <<<');
        list<Task> listTask = new list<Task>();
        
        for (Case caseRecord : [    Select  id, c.IsClosed, status,recordtype.developername,PendingDueToTaskDT__c, Pending_due_to_Task_Start_Duration__c,

                                            (Select IsClosed, id , Status, TECH_Key__c,IsBackupTask__c
                                            From    Tasks 
                                            where   isClosed = false) 
                                    From    Case c
                                    where id IN :mapCase.keyset()
                                        or id IN :MapCaseIdOfPendingTask.keyset()]){
            system.debug('#####Status: '+caseRecord.status);
            boolean pending = false;

            for(Task tsk:caseRecord.Tasks){
                if(setTaskKey.contains(tsk.TECH_Key__c)){
                    if(tsk.status != AP_Constants.taskStatusPending && tsk.status != AP_Constants.taskStatusInProgress){
                        listTask.add(tsk);
                    }
                    else if(tsk.IsBackupTask__c)
                    {
                        Task UpdateTsk = new Task(Id=tsk.Id,IsBackupTask__c=false);
                        TasksToUpdate.add(UpdateTsk);
                    }
                }
                else{
                    if(tsk.status ==AP_Constants.taskStatusPending){                        
                        MapCaseIdOfPendingTask.put(caseRecord.id,new case(id=caseRecord.id,status=AP_Constants.caseStatusPending));                        
                    }
                    else{                        

                            
                        if(caseRecord.status=='Pending')
                        {
                            if(caseRecord.PendingDueToTaskDT__c!=null)
                            {
                                Double pendingduration = BusinessHours.diff(defaultHoursId, caseRecord.PendingDueToTaskDT__c, system.now())/3600000.0 + (caseRecord.Pending_due_to_Task_Start_Duration__c==null?0:caseRecord.Pending_due_to_Task_Start_Duration__c); 
                                mapCase.put(caseRecord.id,new case(id=caseRecord.id,status=AP_Constants.caseStatusDelegated,Pending_due_to_Task_Start_Duration__c=pendingduration,PendingDueToTaskDT__c=null));                        
                            }
                            else
                            {
                                mapCase.put(caseRecord.id,new case(id=caseRecord.id,status=AP_Constants.caseStatusDelegated));
                            }
                        }
                        else
                            mapCase.put(caseRecord.id,new case(id=caseRecord.id,status=AP_Constants.caseStatusDelegated));
                        
                    }
                }
            }
            

            if(caseRecord.isclosed){
                mapCase.remove(caseRecord.id);
                MapCaseIdOfPendingTask.remove(caseRecord.id);
            }                                                           
        }
        mapCase.putAll(MapCaseIdOfPendingTask);
        System.debug('>>>  AP03TaskSetCaseStatus - setStatus listCaseForUpdate.size : '+mapCase.size() );
        System.debug('>>>  AP03TaskSetCaseStatus - setStatus listCaseForUpdate.size : '+mapCase );
        if(mapCase.size() > 0){
            update mapCase.values();
        }
        if(listTask.size() > 0){
            delete listTask;
        }

        if(TasksToUpdate.size()>0)
            update TasksToUpdate;
        
        System.debug('>>> END AP03TaskSetCaseStatus - setStatus <<<');
    }
*/
    //CAPOBIANCO_A 12/05/2017 EVO 86 -- START
    @future
    public static void closeTask(Set<Id> idToClose)
    {
        //List<Task> taskToClose = [Select Id, Status FROM Task WHERE Id IN : idToClose];
        List<Task> taskToClose = new List<Task>();

        if(idToClose.size()>0)
        {
            for(String s : idToClose)
            {
                Task TaskClose = new Task(id=s,Status = AP_Constants.taskStatusOutOfTime);
                taskToClose.add(TaskClose);
            }
        }

        if(taskToClose.size()>0)
            update taskToClose;
    }
    //CAPOBIANCO_A 12/05/2017 EVO 86 -- END

}//end of class