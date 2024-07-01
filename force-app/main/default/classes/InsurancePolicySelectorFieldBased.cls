public with sharing class InsurancePolicySelectorFieldBased implements InsurancePolicySelectorInterface {

    public List<InsurancePolicy__c> getInsurancePolicy(Id accountId, Set<String> asa, Integer limits) {
        FilterValuesService filterValueService = new FilterValuesService('SchedaClientePolizze');

        Set<String> macroRami = filterValueService.filterByField('Macro_Ramo__c').filterByKey(asa).getValuesAndReset();
        Set<String> asaDescriptions = filterValueService.filterByField('ASA_Description__c').filterByKey(asa).getValuesAndReset();
        Set<String> workFlowEtlNew = filterValueService.filterByField('TECH_WorkFlow_ETL__c').getValues();

        return [SELECT Id, Name, Product_Name__c, CCDATE__c, EXPIRY_DATE__c, Status__c from InsurancePolicy__c where Status__c = 'ATTIVO' and CUID__c =:accountId and 
            ( 
                ( Flag_Polizza_Madre__c = true AND  Macro_Ramo__c in :macroRami AND TECH_WorkFlow_ETL__c in :workFlowEtlNew ) OR 
                ( ASA_Description__c = :asaDescriptions AND TECH_WorkFlow_ETL__c not in :workFlowEtlNew )  
            ) 
            
            order by CreatedDate desc LIMIT :limits];
        
    }
    public Integer getActiveInsurancePolicyCount(Id accountId, Set<String> asa) {
        FilterValuesService filterValueService = new FilterValuesService('SchedaClientePolizze');

        Set<String> macroRami = filterValueService.filterByField('Macro_Ramo__c').filterByKey(asa).getValuesAndReset();
        Set<String> asaDescriptions = filterValueService.filterByField('ASA_Description__c').filterByKey(asa).getValuesAndReset();
        Set<String> workFlowEtlNew = filterValueService.filterByField('TECH_WorkFlow_ETL__c').getValues();

        AggregateResult results =  [SELECT Count(Id) Counter FROM InsurancePolicy__c WHERE Status__c = 'ATTIVO' and CUID__c =:accountId AND 
        ( 
                ( Flag_Polizza_Madre__c = true AND  Macro_Ramo__c in :macroRami AND TECH_WorkFlow_ETL__c in :workFlowEtlNew ) OR 
                ( ASA_Description__c = :asaDescriptions AND TECH_WorkFlow_ETL__c not in :workFlowEtlNew )  
        )];
        return ((Integer) results.get('Counter'));
    }
}