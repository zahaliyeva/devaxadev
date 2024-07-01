/**
 * @description creazione dinamica della cheda cliente per polizze 
 * @author      Reply
 * @since       2021
 */
public with sharing class SchedaClientePolizzeLazyController {

    /**
     * @description wrapper for polizze lazy
     */
    public class Wrapper {
        @AuraEnabled
        public String policyId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public Date dataEffetto;
        @AuraEnabled
        public Date dataScadenza;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String PremioTotalePolizza;
        @AuraEnabled
        public String PremiototalePagareAnnuo;
        @AuraEnabled
        public String UltimoPremioPagatoLordo;
        @AuraEnabled
        public String UltimoPremioAggiuntivoLordoPagato;
        @AuraEnabled
        public String UltimoPremioLordoPagatoPianificato;

    }

    private static Map<String, Type> schedaClientePolizzeTypeToHandler = new Map<String, Type>{
        AP_Constants.TRANSITORYSETTING_FORCED_NEW  => InsurancePolicySelectorNew.Class,
        AP_Constants.SCHEDACLIENTE_TYPE_NEW        => InsurancePolicySelectorNew.Class,
        AP_Constants.TRANSITORYSETTING_FORCED_OLD  => InsurancePolicySelectorOld.Class,
        AP_Constants.SCHEDACLIENTE_TYPE_OLD        => InsurancePolicySelectorOld.Class,
        AP_Constants.TRANSITORYSETTING_FIELD_BASED => InsurancePolicySelectorFieldBased.Class
    };
   
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getRecords(String id, String asaJson, Integer limits, String schedaClientePolizzaType) {
        List<String> asa = ((List<String>) JSON.deserialize(asaJson, List<String>.class));

        InsurancePolicySelectorInterface insurancePolicySelector;
        if(schedaClientePolizzeTypeToHandler.get(schedaClientePolizzaType) != null ) {
            insurancePolicySelector = (InsurancePolicySelectorInterface) schedaClientePolizzeTypeToHandler.get(schedaClientePolizzaType).newInstance();
        } else {
            insurancePolicySelector = new InsurancePolicySelectorFieldBased();
        }


        List<InsurancePolicy__c> records = insurancePolicySelector.getInsurancePolicy(id, new Set<String>(asa), limits);
        System.debug('### records: ' + records);
        List<Wrapper> wrapperList = new List<Wrapper>();
        for(InsurancePolicy__c record: records){
            Wrapper wrapper = new Wrapper();
            wrapper.policyId = '/' + record.Id; 
            wrapper.name = record.Name;
            wrapper.productName = record.Product_Name__c;
            wrapper.dataEffetto = record.CCDATE__c;
            wrapper.dataScadenza = record.EXPIRY_DATE__c;
            wrapper.status = record.Status__c;
            wrapper.PremioTotalePolizza = String.valueOf(record.Premio_Totale_Polizza__c);
            wrapper.PremiototalePagareAnnuo = String.valueOf(record.Premio_totale_a_pagare__c);
            wrapper.UltimoPremioPagatoLordo = String.valueOf(record.Last_Premium_Paid__c);
            wrapper.UltimoPremioAggiuntivoLordoPagato = String.valueOf(record.Ultimo_premio_aggiuntivo_lordo_pagato__c);
            wrapper.UltimoPremioLordoPagatoPianificato =String.valueOf( record.Ultimo_premio_lordo_pagato_pianificato__c);

            wrapperList.add(wrapper);
        }
        return wrapperList;
    }  

    @AuraEnabled(cacheable=true)
    public static Integer getCount(String id, String asaJson, String schedaClientePolizzaType){
        List<String> asa = ((List<String>) JSON.deserialize(asaJson, List<String>.class));

        InsurancePolicySelectorInterface insurancePolicySelector;

        if(schedaClientePolizzeTypeToHandler.get(schedaClientePolizzaType) != null ) {
            insurancePolicySelector = (InsurancePolicySelectorInterface) schedaClientePolizzeTypeToHandler.get(schedaClientePolizzaType).newInstance();
        } else {
            insurancePolicySelector = new InsurancePolicySelectorFieldBased();
        }
        return insurancePolicySelector.getActiveInsurancePolicyCount(id, new Set<String>(asa));
    } 

}