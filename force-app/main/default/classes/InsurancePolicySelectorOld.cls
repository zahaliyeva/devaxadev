public with sharing class InsurancePolicySelectorOld implements InsurancePolicySelectorInterface {

    public List<InsurancePolicy__c> getInsurancePolicy(Id accountId, Set<String> asa, Integer limits) {
        FilterValuesService filterValueService = new FilterValuesService('SchedaClientePolizze');

        Set<String> asaDescriptions = filterValueService.filterByField('ASA_Description__c').filterByKey(asa).getValues();

        return [SELECT Id, Name, Product_Name__c, CCDATE__c, EXPIRY_DATE__c, Status__c from InsurancePolicy__c  where Status__c = 'ATTIVO' and CUID__c =:accountId and ASA_Description__c in :asaDescriptions order by CreatedDate desc LIMIT :limits];
        
    }
    public Integer getActiveInsurancePolicyCount(Id accountId, Set<String> asa) {
        FilterValuesService filterValueService = new FilterValuesService('SchedaClientePolizze');

        Set<String> asaDescriptions = filterValueService.filterByField('ASA_Description__c').filterByKey(asa).getValues();

        AggregateResult results =  [SELECT Count(Id) Counter FROM InsurancePolicy__c WHERE Status__c = 'ATTIVO' and CUID__c =:accountId and ASA_Description__c in :asaDescriptions ];
        return ((Integer) results.get('Counter'));
    }
}