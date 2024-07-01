trigger CustomerQuotationRefusedTrigger on Customer_Quotation_Refused__e (after insert) {
	String DisableExecution = 'DEACTIVATE_TRIGGER_FOR_USER';
	public boolean DEACTIVATE_TRIGGER = (AAI_Code_Variables__c.getAll()).get(DisableExecution) != null ? (AAI_Code_Variables__c.getAll()).get(DisableExecution).Value__c == UserInfo.getUserId() : false;
	System.Debug('DEACTIVATE_TRIGGER: '+ DEACTIVATE_TRIGGER + ' -> RELATED TO CUSTOM SETTING AAI_Code_Variables__c: ' + DisableExecution);
	if (DEACTIVATE_TRIGGER == FALSE) 
	{
   		TriggerFactory.createHandler('CustomerQuotationRefusedEventHandler');
	}
}