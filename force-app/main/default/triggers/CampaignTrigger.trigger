trigger CampaignTrigger on Campaign (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{  

   String DisableExecution = 'DEACTIVATE_TRIGGER_FOR_USER';
	public boolean DEACTIVATE_TRIGGER = (AAI_Code_Variables__c.getAll()).get(DisableExecution) != null ? (AAI_Code_Variables__c.getAll()).get(DisableExecution).Value__c == UserInfo.getUserId() : false;
	
   boolean DEACTIVATE_TRIGGER_CODE = CampaignHandler.DeactivateTrigger;

   if(DEACTIVATE_TRIGGER || DEACTIVATE_TRIGGER_CODE){
      System.Debug('DEACTIVATE_TRIGGER for user AAI_Code_Variables__c-DEACTIVATE_TRIGGER_FOR_USER or for code');
   }else {
      TriggerFactory.createHandler('CampaignHandler');
   }
}