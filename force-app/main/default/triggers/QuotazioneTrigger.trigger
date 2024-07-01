trigger QuotazioneTrigger on Quotazione__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    //V01
    TriggerFactory.createHandler('QuotazioneHandler');
}