public with sharing class InsurancePolicySelectorNew implements InsurancePolicySelectorInterface {

    public List<InsurancePolicy__c> getInsurancePolicy(Id accountId, Set<String> asa, Integer limits) {
        FilterValuesService filterValueService = new FilterValuesService('SchedaClientePolizze');
        
        Set<String> workFlowEtlNew = filterValueService.filterByField('TECH_WorkFlow_ETL__c').getValuesAndReset();
        Set<String> macroRami = filterValueService.filterByField('Macro_Ramo__c').filterByKey(asa).getValues();

        return [SELECT Id, Name, 
                Product_Name__c,Status__c,CCDATE__c,EXPIRY_DATE__c,Premio_Totale_Polizza__c,
                Premio_totale_a_pagare__c,Last_Premium_Paid__c,Ultimo_premio_aggiuntivo_lordo_pagato__c,
                Ultimo_premio_lordo_pagato_pianificato__c 
                from InsurancePolicy__c 
                where CUID__c =:accountId 
                AND TECH_WorkFlow_ETL__c in :workFlowEtlNew 
                AND Flag_Polizza_Madre__c = true 
                AND Macro_Ramo__c in :macroRami 
                AND isHidden__c = false
                order by Status__c asc, CreatedDate desc LIMIT :limits];
        
    }
    public Integer getActiveInsurancePolicyCount(Id accountId, Set<String> asa) {
        FilterValuesService filterValueService = new FilterValuesService('SchedaClientePolizze');

        Set<String> workFlowEtlNew = filterValueService.filterByField('TECH_WorkFlow_ETL__c').getValuesAndReset();
        Set<String> macroRami = filterValueService.filterByField('Macro_Ramo__c').filterByKey(asa).getValues();

        AggregateResult results =  [SELECT Count(Id) Counter FROM InsurancePolicy__c 
                                    WHERE CUID__c =:accountId 
                                    AND Status__c = 'ATTIVO' 
                                    AND TECH_WorkFlow_ETL__c in :workFlowEtlNew 
                                    AND Flag_Polizza_Madre__c = true 
                                    AND  Macro_Ramo__c in :macroRami
                                    AND isHidden__c = false ];
        return ((Integer) results.get('Counter'));
    }
}