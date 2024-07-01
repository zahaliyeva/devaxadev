@isTest
public with sharing class RecordTypeUtilityTest {
    
    @IsTest
    public static void testGetRecordTypeMap(){
        System.assert(RecordTypeUtility.getRecordTypeMap('Account').size() > 0, 'Record Types retrieved');
    }
}