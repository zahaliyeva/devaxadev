@isTest
public class MobilityReportControllerTest {
    
    @isTest
    static void testReport() {

		Test.startTest();
        MobilityReportController.getReport('null', 'filterColumn', 'ciao');
        MobilityReportController.getReport('Monitoraggio_accessi', 'filterColumn', 'ciao');
        Test.stopTest();
        
    }
}