public with sharing class SchedaClientePaginaPrincipaleController {
    
    public class Wrapper {
        @AuraEnabled
        public List<InsurancePolicy__c> polizze = new List<InsurancePolicy__c>();
        @AuraEnabled
        public Integer polizzeAttive = 0;
    }

    private static Map<String, Type> schedaClientePolizzeTypeToHandler = new Map<String, Type>{
        AP_Constants.TRANSITORYSETTING_FORCED_NEW  => InsurancePolicySelectorNew.Class,
        AP_Constants.SCHEDACLIENTE_TYPE_NEW        => InsurancePolicySelectorNew.Class,
        AP_Constants.TRANSITORYSETTING_FORCED_OLD  => InsurancePolicySelectorOld.Class,
        AP_Constants.SCHEDACLIENTE_TYPE_OLD        => InsurancePolicySelectorOld.Class,
        AP_Constants.TRANSITORYSETTING_FIELD_BASED => InsurancePolicySelectorFieldBased.Class
    };

    @AuraEnabled
    public static Wrapper getPolizze(String accountId, List<String> asa, String schedaClientePolizzaType) {
        Wrapper wrapper = new Wrapper();
        InsurancePolicySelectorInterface insurancePolicySelector;
        if(schedaClientePolizzeTypeToHandler.get(schedaClientePolizzaType) != null ) {
            insurancePolicySelector = (InsurancePolicySelectorInterface) schedaClientePolizzeTypeToHandler.get(schedaClientePolizzaType).newInstance();
        } else {
            insurancePolicySelector = new InsurancePolicySelectorFieldBased();
        }
            
        wrapper.polizze = insurancePolicySelector.getInsurancePolicy(accountId, new Set<String>(asa), 3);
        wrapper.polizzeAttive = insurancePolicySelector.getActiveInsurancePolicyCount(accountId, new Set<String>(asa));
        
        return wrapper;
    }
}