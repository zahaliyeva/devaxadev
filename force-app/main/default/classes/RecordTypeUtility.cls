public with sharing class RecordTypeUtility
{

    public static String getDeveloperNameById(String sObjectType, String id){
        return Schema.SObjectType.Case.getRecordTypeInfosById().get(id).getDeveloperName();
    }


    public static Map<Id, String> getRecordTypeMap(String sObjectType){
        Map<Id, String> result = new Map<Id, String>();
        Map<Id,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.getGlobalDescribe().get(sObjectType).getDescribe().getRecordTypeInfosById();
        for (Id key : recordTypeInfosMap.keySet()) {
            result.put((recordTypeInfosMap.get(key).getRecordTypeId()), (recordTypeInfosMap.get(key)).getDeveloperName());
        }
        return result;
    }

    public static Id getRecordTypeIdByDeveloperName(String sObjectType, String developerName){
        Map<Id,Schema.RecordTypeInfo> recordTypeInfosMap = Schema.getGlobalDescribe().get(sObjectType).getDescribe().getRecordTypeInfosById();
        for (Id key : recordTypeInfosMap.keySet()) {
            if(developerName.equals((recordTypeInfosMap.get(key)).getDeveloperName())){
                return key;
            }
        }
        return null;
    }

    /*
    //USAGE:
    Map<String,String> mapRT_Account_DevName_ID = RecordTypeUtility.getRecordTypeMapDeveloperNameId('Account');
    system.debug(mapRT_Account_DevName_ID);
    Id B2B_Client_ID = mapRT_Account_DevName_ID.get('B2B_Client');
    system.debug(B2B_Client_ID);
    */

    // NON UTILIZZARE! QUERY SUI RECORD TYPE a.turrini 
    public static Map<String,String> getRecordTypeMapDeveloperNameId(String SobjetType)
    {
        Map<String, Id> rtMap_Devname_Id = new Map<String, Id>();    
        for (RecordType r : [select Id, DeveloperName from RecordType where SObjectType =:SobjetType]) {
            rtMap_Devname_Id.put(r.DeveloperName, r.Id);
        }
        return rtMap_Devname_Id;
    }
                
        
    //picklist based on profile visibility
    public List<SelectOption> getRecordTypes(String SobjetType)
    {  

            //String SobjetType = 'Account';

            List<SelectOption> options = new List<SelectOption>();
            
            List<String> recordTypeNameList = new List<String>();
            /** Need to create list to collect record type name.**/
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Schema.SObjectType sobjType = gd.get(SobjetType); 
            Schema.DescribeSObjectResult R = sobjType.getDescribe(); 


            /** You need to change the object name according to your requirement.**/
            List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
            for( Schema.RecordTypeInfo recordType : RT )
            {
                if(recordType.isAvailable())//profile check
                { 
                     /** Check if the recordtype is visible for the current user or not. **/
                    if(recordType.Name!='Principale') 
                    {


                        options.add(new SelectOption(recordType.getRecordTypeId()+'',recordType.Name+''));
                        system.debug('+++'+recordType.getRecordTypeId()+'+++'+recordType.Name+'');

                    }
                }
            }
            system.debug('+++options:'+options);
            return options;

    }

    /**
    * Method that returns the RecodTypeId depending on the field DeveloperName
    * @author Juana Valenzuela
    * @date 27/05/2017
    * @param 
    * inDeveloperName: Record type' developer name for which we want the RecordType Id
    */

    // NON UTILIZZARE! QUERY SUI RECORD TYPE a.turrini 
    public static Id getRecordTypeIdOnDeveloperName(String inDeveloperName){
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :inDeveloperName].Id;
        return recordTypeId;
    }



    
}