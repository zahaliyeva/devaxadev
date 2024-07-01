public class CustomLayoutWrapper {
    @AuraEnabled
    public SObject record {get;set;}
    @AuraEnabled
    public String name {get;set;}
    @AuraEnabled
    public List<SectionItem> sections {get;set;}
    @AuraEnabled
    public String title {get;set;}
    
    public class SectionItem{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Integer index {get;set;}
        @AuraEnabled
        public List<FieldItem> fields {get;set;}
    }
    
    public class FieldItem{
        @AuraEnabled
        public String nameLookup {get;set;}
        @AuraEnabled
        public String developerName {get;set;}
        @AuraEnabled
        public String labelName {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean readOnly {get;set;}
        @AuraEnabled
        public Boolean required {get;set;}
        @AuraEnabled
        public Integer index {get;set;}
        @AuraEnabled
        public Object value {get;set;}
        @AuraEnabled
        public Map<String,String> pickListMap{get;set;}
    }

    public class CustomLayoutMobilityResponse extends MobilityResponse{
        @AuraEnabled
        public sObject record {get;set;}
    }
    
}