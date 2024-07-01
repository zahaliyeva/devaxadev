trigger CommunicationToCustomerEventTrigger on CommunicationToCustomer__e (after insert){
    TriggerFactory.createHandler('CommunicationToCustomerEventHandler');
}