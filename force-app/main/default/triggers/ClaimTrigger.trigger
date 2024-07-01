trigger ClaimTrigger on Claim__c (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{  
   
   String DisableExecution = 'DEACTIVATE_TRIGGER_FOR_USER';
   public boolean DATA_DELETION = (Trigger.isUpdate || Trigger.isInsert) && UserInfo.getUserId().equals(DataDeletionBypass__c.getOrgDefaults().Bypass__c);
   public boolean DEACTIVATE_TRIGGER = (AAI_Code_Variables__c.getAll()).get(DisableExecution) != null ? (AAI_Code_Variables__c.getAll()).get(DisableExecution).Value__c == UserInfo.getUserId() : false;
   System.Debug('DEACTIVATE_TRIGGER: '+ DEACTIVATE_TRIGGER + ' -> RELATED TO CUSTOM SETTING AAI_Code_Variables__c: ' + DisableExecution);
   if (!DEACTIVATE_TRIGGER && !DATA_DELETION) 
   {
       TriggerFactory.createHandler('ClaimHandler');
   }
   
}