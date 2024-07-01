trigger NodeTrigger on Node__c (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{  
   public boolean DeactivateTrigger = NodeHandler.isDeactivateTrigger();
   //V03 *-+- 04-03-2022 for Test class 
   if(DeactivateTrigger)
      System.debug('Disable trigger Node for -User-'+UserInfo.getName());
   else
      TriggerFactory.createHandler('NodeHandler');
   
}