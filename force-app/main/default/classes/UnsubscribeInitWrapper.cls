public without sharing class UnsubscribeInitWrapper {
    

    
    @AuraEnabled
    public ErrorsWrapper errors{public get;public set;} 

    @AuraEnabled
    public String Token {public get; public set;}

    @AuraEnabled
    public MKT_Unsuscribed_Wrapper.ValueWrapper valuesFromMC {public get; public set;}

    @AuraEnabled
    public CIF_Privacy valuesFromCIF {public get; public set;}

    @AuraEnabled
    public Map<String, Boolean> editedFieldsMap {public get; public set;}

    @AuraEnabled
    public Account CIFResponse {public get; public set;}
    

    

    private Id accId;

    public Id getAccId(){
        return accId;
    }

    public void setAccId(Id accId){
        this.accId = accId;
    }

    public class CIF_Privacy{
        
        @AuraEnabled
        public Boolean Privacy1 {public get; public set;}
    
        @AuraEnabled
        public Boolean Privacy2 {public get; public set;}
    
        @AuraEnabled
        public Boolean Privacy3 {public get; public set;}
    
        @AuraEnabled
        public Boolean Privacy4 {public get; public set;}
        @AuraEnabled
        public Boolean Privacy5 {public get; public set;}
    
        @AuraEnabled
        public Boolean Privacy7 {public get; public set;}
    
        @AuraEnabled
        public Boolean Privacy8 {public get; public set;}
    
    }

    public UnsubscribeInitWrapper(){
        errors = new ErrorsWrapper();
        errors.isInCRM = true;
        errors.isDateValid = true;
        errors.isMCRespOK = true;
        errors.isCIFRespOK = true;
        errors.isTokenNew = true;
        errors.wrongRecipient = true;
        valuesFromMC = null;
        editedFieldsMap = new Map<String, Boolean>();
    }

    public class ErrorsWrapper{
        @AuraEnabled
        public Boolean isInCRM {public get; public set;}
    
        @AuraEnabled
        public Boolean isDateValid {public get; public set;}
    
        @AuraEnabled
        public Boolean isMCRespOK {public get; public set;}
    
        @AuraEnabled
        public Boolean isCIFRespOK {public get; public set;}
        
        @AuraEnabled
        public Boolean isTokenNew {public get; public set;}

        @AuraEnabled
        public Boolean wrongRecipient {public get; public set;}
        
    }
}