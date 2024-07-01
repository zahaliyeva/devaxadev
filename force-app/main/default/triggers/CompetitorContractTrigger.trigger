trigger CompetitorContractTrigger on Competitor_Contract__c (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{  
    TriggerFactory.createHandler('CompetitorContractHandler');   
}