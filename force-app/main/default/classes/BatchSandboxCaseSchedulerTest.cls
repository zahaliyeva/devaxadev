@isTest
public class BatchSandboxCaseSchedulerTest {

    static testMethod void myTestMethod() {        
         test.starttest();
         BatchSandboxCaseScheduler myClass = new BatchSandboxCaseScheduler ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Class', chron, myClass);
         test.stopTest();
    }
}