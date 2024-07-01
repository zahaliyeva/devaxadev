/*-------------------------------------------------------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         LeadEngineUtility
Description:   Utility class for LeadDecisionalMotor_Batch
History

12/12/2017     Dario Bovolenta - Created
31/12/2018     Gabriel dos Santos - Edited 
                Add : relatedAttachmentFinder method
                Add : relatedNoteFinder method
                edit : handleRelatedActivities method 
----------------------------------------------------------------------------------------------------------------------------
* Id: 001
* description: Lead Management Sprint 59
* date: 12/12/2017 
* author: Dario Bovolenta
----------------------------------------------------------------------------------------------------------------------------*/

public class LeadEngineUtility{
    
    public static void handleRelatedActivities (List<Id> leadIdList)
    {

      String lastNDays = String.valueOf(Integer.valueOf(LeadAssignmentConfiguration__c.getValues('Last n days for Lead duplication').DaysLimit__c));
      List<Task> taskList = relatedTaskFinder(leadIdList, lastNDays);
      List<Event> eventList = relatedEventFinder(leadIdList, lastNDays);
      List<Attachment> attachmentList = relatedAttachmentFinder(leadIdList, lastNDays);
      List<Note> noteList = relatedNoteFinder(leadIdList, lastNDays);
      
      //DELETING THE ACTIVITIES FOR NOW
      if (taskList.size()>0)
        database.delete(taskList,false);
      if (eventList.size()>0)
        database.delete(eventList,false);

      // begin - Gabriel dos Santos edit 31/01/2018
      if (attachmentList.size() > 0)
        database.delete(attachmentList,false);
      if (noteList.size() > 0)
        database.delete(noteList,false);
      // fine - Gabriel dos Santos edit 31/01/2018

    }

    // begin - Gabriel dos Santos add 31/01/2018   
    public static List<Note> relatedNoteFinder(List<Id> leadIdList, String lastNDays){

        Date startDate = Date.today().addDays(-Integer.valueOf(lastNDays));
        
        list<String> agencyProfiles = new list<String> ();
        agencyProfiles.add ('AAI - Vendite Avanzato');
        agencyProfiles.add ('AAI - Vendite Base');

        list<Note> noteList = [SELECT Id FROM Note WHERE ParentId in :leadIdList and CreatedDate >= :startDate and CreatedBy.Profile.Name IN :agencyProfiles];
        return noteList;
    }

    public static List<Attachment> relatedAttachmentFinder(List<Id> leadIdList, String lastNDays){

        Date startDate = Date.today().addDays(-Integer.valueOf(lastNDays));
        
        list<String> agencyProfiles = new list<String> ();
        agencyProfiles.add ('AAI - Vendite Avanzato');
        agencyProfiles.add ('AAI - Vendite Base');

        list<Attachment> attachmentList = [SELECT Id,BodyLength FROM Attachment WHERE ParentId in :leadIdList and CreatedDate >= :startDate and CreatedBy.Profile.Name IN :agencyProfiles];
        return attachmentList;
    }
    // fine - Gabriel dos Santos add 31/01/2018

    public static List<Task> relatedTaskFinder(List<Id> leadIdList, String lastNDays)
    {

        Date startDate = Date.today().addDays(-Integer.valueOf(lastNDays));
        
        list<String> agencyProfiles = new list<String> ();
        agencyProfiles.add ('AAI - Vendite Avanzato');
        agencyProfiles.add ('AAI - Vendite Base');

        list<Task> taskList = [SELECT Id,Subject,Status,OwnerId,WhoId FROM Task WHERE WhoId in :leadIdList and CreatedDate >= :startDate and CreatedBy.Profile.Name IN :agencyProfiles];
        return taskList;
    }

    public static List<Event> relatedEventFinder(List<Id> leadIdList, String lastNDays)
    {
        Date startDate = Date.today().addDays(-Integer.valueOf(lastNDays));
        
        list<String> agencyProfiles = new list<String> ();
        agencyProfiles.add ('AAI - Vendite Avanzato');
        agencyProfiles.add ('AAI - Vendite Base');

        List<Event> eventList = [SELECT Id,Subject,OwnerId,WhoId FROM Event WHERE WhoId in :leadIdList and CreatedDate >= :startDate and CreatedBy.Profile.Name IN :agencyProfiles];
        return eventList;
    }  
    
     
/*
    public static List<Task> reassignTasks (List<Task> leadList)
    {
        return null;
    }   
    
    public static List<Event> reassignEvents (List<Lead> leadList)
    {
        return null;
    }   
    */  
    
    
}