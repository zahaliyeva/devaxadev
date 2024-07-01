public with sharing class lghtIFrameForCustomURLCTRL {

    
    @AuraEnabled
    public static String GetUrlFromRecordId( String RecordId ){

        try {
            String UrlDinamico;
            String query = '';

            String SObjectTypeName = UtilityClass.findObjectNameFromRecordIdPrefix(RecordId);
            sObject sObj = Schema.getGlobalDescribe().get(SObjectTypeName).newSObject() ;
    
            query = 'SELECT  TECH_URL_template_MC__c '
                +'FROM '+SObjectTypeName+' WHERE Id = \''+String.escapeSingleQuotes(RecordId)+'\' limit 1'; 
    
            sObject sObjectList= Database.query( query );
            UrlDinamico = (String)sObjectList.get('TECH_URL_template_MC__c');
            return UrlDinamico;
            
        } catch (Exception Error) {
           String result =  Error.getStackTraceString();
           return result;
        }

    }
}