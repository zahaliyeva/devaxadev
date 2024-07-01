@isTest
public class BatchSandboxLeadSchedulerTest {

    static testMethod void myTestMethod() {        
         test.starttest();
         BatchSandboxLeadScheduler myClass = new BatchSandboxLeadScheduler ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Class', chron, myClass);
         test.stopTest();
    }
}