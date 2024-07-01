trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{  
   
   public boolean DATA_DELETION = (Trigger.isUpdate || Trigger.isInsert) && UserInfo.getUserId().equals(DataDeletionBypass__c.getOrgDefaults().Bypass__c);
  
   // if user is not on the custom setting is false by default
   public boolean DisableTriggerAccountforUser = ByPassingTrigger__c.getInstance(UserInfo.getUserId()).isTriggerAccount__c;//var static
   // if is BatchRunAccountTriggers the one runing
   public boolean DeactivateTrigger = AccountHandler.DeactivateTrigger();
   public boolean ForceActivateTrigger = AccountHandler.ForceActivateTrigger();


   if ((DisableTriggerAccountforUser || DeactivateTrigger || DATA_DELETION) && !ForceActivateTrigger) {
    System.debug('Disable trigger Account for -User-'+UserInfo.getName());
   }
   else {
      System.debug('Enable trigger Account for -User-'+UserInfo.getName());
    //trigger IS active this user!!!   
    TriggerFactory.createHandler('AccountHandler');
   }
    
   
}