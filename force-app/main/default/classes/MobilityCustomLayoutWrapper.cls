public class MobilityCustomLayoutWrapper {
    @AuraEnabled
    public SObject record {get;set;}
    @AuraEnabled
    public String name {get;set;}
    @AuraEnabled
    public String recordType {get;set;}
    @AuraEnabled
    public List<SectionItem> sections {get;set;}
    @AuraEnabled
    public List<String> fields = new List<String>();
    @AuraEnabled
    public String title {get;set;}

    @AuraEnabled
    public Map<String, FieldItem> definition {get;set;}
    
    public class SectionItem{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String subName {get;set;}
        @AuraEnabled
        public String underSubName {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Integer index {get;set;}
        @AuraEnabled
        public List<FieldItem> fields {get;set;}
        @AuraEnabled
        public Boolean invisible {get;set;}
        @AuraEnabled
        public Boolean isUsingURLpreview {get;set;}
        @AuraEnabled
        public Boolean isUsingLink {get;set;}
        @AuraEnabled
        public String link {get;set;}
        @AuraEnabled
        public Boolean isUsingIcon {get;set;}
        @AuraEnabled
        public String Icon {get;set;}

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
        @AuraEnabled
        public Boolean invisible {get;set;}
        @AuraEnabled
        public String redirectURL {get;set;}
        @AuraEnabled
        public List<String> params{get;set;}
        @AuraEnabled
        public String redirectLab {get;set;}
    }

    public class FieldDefinition{
        @AuraEnabled
        public String developerName {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean readOnly {get;set;}
        @AuraEnabled
        public Boolean required {get;set;}
        @AuraEnabled
        public Map<String,String> pickListMap{get;set;}
    }

    public class CustomLayoutMobilityResponse extends MobilityResponse{
        @AuraEnabled
        public sObject record {get;set;}
    }
    
}