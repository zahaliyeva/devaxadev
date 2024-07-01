@isTest
public with sharing class mobilityDashboardPaginationCtrlTEST {
    
    @isTest
    public static void getConfigurationTest() {
        Test.startTest();
        mobilityDashboardPaginationController.configuration conf = mobilityDashboardPaginationController.getConfiguration('Messaggio');
        Test.stopTest();

        Assert.areEqual('IniziativaName', conf.Title);
    }

    @isTest
    public static void getPaginationTest() {
        Test.startTest();
        SObjectTable.TablePagination res = mobilityDashboardPaginationController.getPagination(0,5,20);
        Test.stopTest();
        
        Assert.areEqual(20,res.total);
    }


}