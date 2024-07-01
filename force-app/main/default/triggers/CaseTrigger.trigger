trigger CaseTrigger on Case (before insert,before update,after insert,after update)
{
   String DisableExecution = 'DEACTIVATE_TRIGGER_FOR_USER';
   public boolean DEACTIVATE_TRIGGER = (AAI_Code_Variables__c.getAll()).get(DisableExecution) != null ? (AAI_Code_Variables__c.getAll()).get(DisableExecution).Value__c == UserInfo.getUserId() : false;
   //dario
   public boolean DEACTIVATE_TRIGGER_WFCL = true;
   AAI_Code_Variables__c temp = (AAI_Code_Variables__c.getAll()).get('CheckWFCL');
    if(temp != null && temp.Value__c == 'true'){
        for(Case c : Trigger.new){
        if(c.Origine_Pratica_Documentale__c != 'WFCL' || c.Pratica_Documentale__c == false)
        DEACTIVATE_TRIGGER_WFCL = false;
        }
    } else {
        DEACTIVATE_TRIGGER_WFCL = false;
    }
   System.Debug('DEACTIVATE_TRIGGER_WFCL: '+ DEACTIVATE_TRIGGER_WFCL + ' -> RELATED TO CUSTOM SETTING AAI_Code_Variables__c: CheckWFCL');
   System.Debug('DEACTIVATE_TRIGGER: '+ DEACTIVATE_TRIGGER + ' -> RELATED TO CUSTOM SETTING AAI_Code_Variables__c: ' + DisableExecution);
   
   if (DEACTIVATE_TRIGGER == FALSE && CaseHandler.RunTrigger && DEACTIVATE_TRIGGER_WFCL == FALSE) 
   {
    TriggerFactory.createHandler('CaseHandler');
   }
}