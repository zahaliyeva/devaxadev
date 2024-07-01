public without sharing class SharingUtility{
    public static List<sObject> transferQuery(String query){
        return Database.query(query);
    }
}