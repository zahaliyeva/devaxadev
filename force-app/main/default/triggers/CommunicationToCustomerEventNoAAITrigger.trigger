trigger CommunicationToCustomerEventNoAAITrigger on CommunicationToCustomerNoAAI__e (after insert) {
	TriggerFactory.createHandler('CommunicationToCustomerNoAAIEventHandler');
}