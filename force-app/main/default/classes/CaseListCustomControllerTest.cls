@isTest
private class CaseListCustomControllerTest {

    @IsTest 
    public static void getFilter(){
        System.assertEquals(true, !CaseListCustomController.getFilter().TipologiaFilters.isEmpty(), 'Custom Medatada ListViewCustom__mdt must not be empty');
    } 

    @IsTest
    public static void initRecords(){
        System.assertEquals(true, CaseListCustomController.initRecords('Case', 'Id', 'CreatedDate', 'asc', 'CreatedById  = \'CURRUSER\'') != null, 'DataTableWrapper must not be empty');
    }
 
}