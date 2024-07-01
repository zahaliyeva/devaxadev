trigger CommunicationToCustomerTrigger on Communications_to_customer__c (before insert,before update,after insert,after update) {
    
    String DisableExecution = 'DEACTIVATE_TRIGGER_FOR_USER';
    public boolean DeactivateTrigger = (AAI_Code_Variables__c.getAll()).get(DisableExecution) != null ? (AAI_Code_Variables__c.getAll()).get(DisableExecution).Value__c == UserInfo.getUserId() : false;
    public boolean DATA_DELETION = (Trigger.isUpdate || Trigger.isInsert) && UserInfo.getUserId().equals(DataDeletionBypass__c.getOrgDefaults().Bypass__c);
    boolean DEACTIVATE_TRIGGER_CODE = CommunicationToCustomerHandler.DeactivateTrigger;

    if (DeactivateTrigger || DATA_DELETION || DEACTIVATE_TRIGGER_CODE) {
        System.debug('Disable trigger for -User-'+UserInfo.getName());
    }
    else {
        System.debug('Enable trigger for -User-'+UserInfo.getName());
        //trigger IS active this user!!!   
        TriggerFactory.createHandler('CommunicationToCustomerHandler');
    }
}