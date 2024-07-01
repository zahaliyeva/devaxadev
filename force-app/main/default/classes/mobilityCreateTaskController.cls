public with sharing class mobilityCreateTaskController {
    public mobilityCreateTaskController() {

    }
    @AuraEnabled(cacheable = true)
    public static Account getAccount(String NDG){
        Account acc=[Select Id,Name,Contact_Master_Id__c,Contact_Master_Id__r.Name,Owner.Name from Account where NDG__c=:NDG limit 1];
        return acc;
    }
    @AuraEnabled(cacheable = true)
    public static recordType getRecordType(String recordTypeOb){
        recordType  rT=[Select Id,Name,DeveloperName from recordType where DeveloperName=:recordTypeOb limit 1];
        return rT;
    }
    @AuraEnabled
    public static user getUserName(){
        // cercare forma con schemadatabase
        
        user  rT=[Select Id, Name from user where id=:UserInfo.getUserId()];
        if(rT!=null){
            return rT;
        }else {
            return null;
        }    
    }
}