public with sharing class SchedaClienteCaseLazyController {

    public class Wrapper {
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String category;
        @AuraEnabled
        public String subCategory;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Datetime createdDate;
        @AuraEnabled
        public String owner;
    }
   
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getRecords(String id, Integer limits) {
        List<Case> records = [SELECT  Id, CaseNumber, Category__c, SubCategory__c, Subject, Status, CreatedDate, Owner.Name FROM Case WHERE AccountId =:id order by CreatedDate desc LIMIT :Integer.valueof(limits) ];
        List<Wrapper> wrapperList = new List<Wrapper>();
        for(Case record: records){
            Wrapper wrapper = new Wrapper();
            wrapper.caseId = '/' + record.Id; 
            wrapper.caseNumber = record.CaseNumber;
            wrapper.category = record.Category__c;
            wrapper.subCategory = record.SubCategory__c;
            wrapper.subject = record.Subject;
            wrapper.status = record.Status;
            wrapper.createdDate = record.CreatedDate;
            wrapper.owner = record.Owner.Name;
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }  

    @AuraEnabled(cacheable=true)
    public static Integer getCount(String id){
        AggregateResult results = [SELECT Count(Id) Counter FROM Case WHERE AccountId =:id];
        return ((Integer) results.get('Counter'));
    } 

}