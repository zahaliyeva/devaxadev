trigger StoricoConversazioniTrigger on Storico_conversazioni__c (before insert,before update,after insert,after update) {

   String DisableExecution = 'DEACTIVATE_TRIGGER_FOR_USER';
   public boolean DEACTIVATE_TRIGGER = (AAI_Code_Variables__c.getAll()).get(DisableExecution) != null ? (AAI_Code_Variables__c.getAll()).get(DisableExecution).Value__c == UserInfo.getUserId() : false;
   System.Debug('DEACTIVATE_TRIGGER: '+ DEACTIVATE_TRIGGER + ' -> RELATED TO CUSTOM SETTING AAI_Code_Variables__c: ' + DisableExecution);
   
   if (DEACTIVATE_TRIGGER == FALSE) 
   {
    TriggerFactory.createHandler('StoricoConversazioniHandler');
   }
    
}