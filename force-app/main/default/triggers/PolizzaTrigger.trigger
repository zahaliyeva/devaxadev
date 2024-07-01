trigger PolizzaTrigger on InsurancePolicy__c (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{ 

  public boolean DATA_DELETION = (Trigger.isUpdate || Trigger.isInsert) && UserInfo.getUserId().equals(DataDeletionBypass__c.getOrgDefaults().Bypass__c);
 
   // if user is not on the custom setting is false by default
   public boolean DisableTriggerforUser = ByPassingTrigger__c.getInstance(UserInfo.getUserId()).isTriggerPolicy__c;//var static
   // if is DeactivateTrigger TRUE??
   public boolean DeactivateTrigger = PolizzaHandler.DeactivateTrigger();
   
   if (DisableTriggerforUser || DeactivateTrigger || DATA_DELETION){
    System.debug('Disable trigger Polizza for -User-'+UserInfo.getName());
   }
   else {
    //trigger IS active for this user!!!  
    TriggerFactory.createHandler('PolizzaHandler');
  }
}