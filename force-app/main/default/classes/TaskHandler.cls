/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         TriggerHandler
Description:   Trigger Handler for the Task SObject. This class implements the ITrigger  
               interface to help ensure the trigger code is bulkified and all in one place.  

History

17/05/2018     Created 
-------------------------------------------------------------------------------------------*/
public with sharing class TaskHandler implements ITrigger 
{
    public final Map<String, Schema.RecordTypeInfo> MapTaskRecordType = new Map<String, Schema.RecordTypeInfo> ();
    public final String defaultHoursId;
    public final String bhGDPR;
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;
    public static Boolean firstRunBeforeInsert = true;
    public static Boolean firstRunBeforeUpdate = true;

    // Constructor  
    public TaskHandler()
    {  
        for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true])
        {
            if(bh.Name == 'Default')
                defaultHoursId = bh.Id;
            else if(bh.Name == 'GDPR')
                bhGDPR = bh.Id;
        }

        String[] types = new String[]{'Task'}; 
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 

        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapTaskRecordType.put(ri.getRecordTypeId(), ri);
        }   
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
        List<Task> Tasks = new List<Task>();
        Map<String,Boolean> MapCaseId = new Map<String,Boolean>();
        List<Task> ListTaskLead = new List<Task>();

        for(sObject so:soList)
        {
            String whatIdString = '';
            if (so.get('WhatId')!= null) whatIdString = (String)so.get('WhatId');
            String whoIdString = '';
            if (so.get('WhoId')!= null) whoIdString = (String)so.get('WhoId');            
            if(whatIdString.startsWith(AP_Constants.CaseKeyPrefix))
            {
                Tasks.add((Task)so);
                MapCaseId.put((String)so.get('WhatId'),(Boolean)so.get('IsBackupTask__c'));
            }
            else if(whoIdString.startsWith(Schema.SObjectType.Lead.getKeyPrefix()))
            {
                ListTaskLead.add((Task)so);
            }
        }

        if(Tasks.size()>0)
            TaskManagement.BeforeInsertProcess(Tasks,MapTaskRecordType,MapCaseId);  

        if(ListTaskLead.size()>0)
            TaskManagement.LeadTaskProcesses(ListTaskLead); 

        if(firstRunBeforeInsert)
            firstRunBeforeInsert= false;
        {
            system.debug('AlreadyRun Before Insert');
            //return;
        }                  
    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {
        integer counter=0;
        List<Task> Tasks = new List<Task>();
        Map<String,Boolean> MapCaseId = new Map<String,Boolean>();
        Map<String,Task> oldValMap = new Map <String,Task>(); 

        for(sObject so:soList)
        {
            String whatIdString = '';
            if (so.get('WhatId')!= null) whatIdString = (String)so.get('WhatId');
            if(whatIdString.startsWith(AP_Constants.CaseKeyPrefix))
            {
                Tasks.add((Task)so);
                MapCaseId.put((String)so.get('WhatId'),(Boolean)so.get('IsBackupTask__c'));
                oldValMap.put((String)so.get('Id'),(Task)oldSoList[counter]);
                        
                counter++;
            }
        }
        
        if(Tasks.size()>0)
            TaskManagement.BeforeUpdateProcesses(Tasks, MapCaseId,oldValMap,MapTaskRecordType,defaultHoursId,bhGDPR);

        if(firstRunBeforeUpdate)
            firstRunBeforeUpdate= false;
        {
            system.debug('AlreadyRun Before Update');
            //return;
        }             
    }  

    public void beforeDelete(List<SObject> soList){     
        AAI_Code_Variables__c aaiCS = AAI_Code_Variables__c.getValues('CannotDeleteIfNotAdmin');
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].Name;
        List<Task> tasks = (List<Task>) soList;
        String recordTypeId2 = [SELECT Id FROM RecordType WHERE DeveloperName='Communication' LIMIT 1].Id;
        //String rtId2     = String.valueOf(recordTypeId2);
        for(Task t : tasks)
        {
            String recordTypeId1 = (String) t.get('RecordTypeId');
            if (recordTypeId1 == recordTypeId2 && profileName != 'System Administrator' && profileName != 'Amministratore del sistema')
            {
                t.addError(aaiCS.Value__c);    
            }
        }            
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
        List<Task> Tasks = new List<Task>();
        List<String> TasksId = new List<String>();
        Map<String,Boolean> MapCaseId = new Map<String,Boolean>();
        Map<String,String> MapTaskIdToCaseId = new Map<String,String>();  

        for(sObject so:soList)
        {
            String whatIdString = '';
            if (so.get('WhatId')!= null) whatIdString = (String)so.get('WhatId');
            //if(String.isNotBlank((String)so.get('HierarchyLevel1__c')) && whatIdString.startsWith(AP_Constants.CaseKeyPrefix))
            if(whatIdString.startsWith(AP_Constants.CaseKeyPrefix))
            {
                Tasks.add((Task)so);
                TasksId.add((String)so.get('Id'));
                MapCaseId.put((String)so.get('WhatId'),(Boolean)so.get('IsBackupTask__c'));
                MapTaskIdToCaseId.put((String)so.get('Id'),(String)so.get('WhatId'));

            }
        }

        if(Tasks.size()>0)
            TaskManagement.AfterInsertProcess(Tasks,TasksId,MapCaseId,MapTaskIdToCaseId,defaultHoursId,bhGDPR);

        if(firstRunAfterInsert)
            firstRunAfterInsert= false;
        {
            system.debug('AlreadyRun After Insert');
            //return;
        }               
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
        integer counter=0;
        List<Task> Tasks = new List<Task>();
        List<String> TasksId = new List<String>();
        Map<String,Boolean> MapCaseId = new Map<String,Boolean>();
        Map<String,String> MapTaskIdToCaseId = new Map<String,String>();
        Map<String,Task> oldValMap = new Map <String,Task>(); 

        for(sObject so:soList)
        {
            String whatIdString = '';
            if (so.get('WhatId')!= null) whatIdString = (String)so.get('WhatId');
            //if(String.isNotBlank((String)so.get('HierarchyLevel1__c')) && whatIdString.startsWith(AP_Constants.CaseKeyPrefix))
            if(whatIdString.startsWith(AP_Constants.CaseKeyPrefix))
            {
                Tasks.add((Task)so);
                TasksId.add((String)so.get('Id'));
                MapCaseId.put((String)so.get('WhatId'),(Boolean)so.get('IsBackupTask__c'));
                MapTaskIdToCaseId.put((String)so.get('Id'),(String)so.get('WhatId'));
                oldValMap.put((String)so.get('Id'),(Task)oldSoList[counter]);
                        
                counter++;
            }
        }
        
        if(Tasks.size()>0)
            TaskManagement.AfterUpdateProcesses(Tasks,TasksId,MapCaseId,MapTaskIdToCaseId,oldValMap,defaultHoursId,bhGDPR);

        if(firstRunAfterUpdate)
            firstRunAfterUpdate= false;
        {
            system.debug('AlreadyRun After Update');
            //return;
        }     
    }  
    
    public void afterDelete(List<SObject> soList)
    {  

    }
    
    public void afterUndelete(List<SObject> soList)
    { 
 
       
    }

    public void andFinally(){  

    }  
    
}