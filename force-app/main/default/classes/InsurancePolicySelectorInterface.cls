public interface InsurancePolicySelectorInterface {
    List<InsurancePolicy__c> getInsurancePolicy(Id accountId, Set<String> asa, Integer limits);
    Integer getActiveInsurancePolicyCount(Id accountId, Set<String> asa);
}