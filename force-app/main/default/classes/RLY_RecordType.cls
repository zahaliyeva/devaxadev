public with sharing class RLY_RecordType {

    public static Map<String,String> recordTypeByDeveloperName(String obj){
        Map<String,String> recTypeNameWithIdMap=new Map<String,String>();

        if(obj != null){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()){
                recTypeNameWithIdMap.put(recInfo.getDeveloperName(),recInfo.getRecordTypeId());
            }
        }

        return recTypeNameWithIdMap;
    }

    public static Map<String,String> recordTypeById(String obj){
        Map<String,String> recTypeNameWithIdMap=new Map<String,String>();

        if(obj != null){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()){
                recTypeNameWithIdMap.put(recInfo.getRecordTypeId(), recInfo.getDeveloperName());
            }
        }
        
        return recTypeNameWithIdMap;
    }

  

}