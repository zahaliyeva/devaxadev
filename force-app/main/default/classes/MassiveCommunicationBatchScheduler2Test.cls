@isTest
public class MassiveCommunicationBatchScheduler2Test {

    static testMethod void myTestMethod() {        
         test.starttest();
         MassiveCommunicationBatchScheduler2 myClass = new MassiveCommunicationBatchScheduler2 ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Class', chron, myClass);
         test.stopTest();
    }
}