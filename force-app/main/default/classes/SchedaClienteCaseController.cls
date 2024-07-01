public with sharing class SchedaClienteCaseController {
    
    @AuraEnabled
    public static List<Case> getCases(String accountId) {
        return [SELECT CaseNumber, Category__c, SubCategory__c, Subject, Status, CreatedDate, Owner.Name from Case where AccountId =:accountId order by CreatedDate desc LIMIT 5 ];
    }

}