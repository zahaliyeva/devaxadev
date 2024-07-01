public  class View_Document_Link_CTRL {


    @AuraEnabled
    public static list<Case> checkDocumentId(String recordId){
        
        string documentId;
        string recordType;
        list<Case> c = new list<Case>([SELECT Id, Document_Unique_ID__c, RecordType.DeveloperName FROM case WHERE id =: recordId limit 1]);
        documentId = c[0].Document_Unique_ID__c;
        recordType = c[0].RecordType.DeveloperName;

        return c;
        }

    @AuraEnabled
    public static user fetchUser(){
       User u = [select id,Profile.Name from User where id =: userInfo.getUserId()];
        return u;
    }
}