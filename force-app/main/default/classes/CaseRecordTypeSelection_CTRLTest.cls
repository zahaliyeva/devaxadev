@isTest
public class CaseRecordTypeSelection_CTRLTest {
@testSetup private static void createData(){
        
    }
    
    @isTest static void test() {
       Test.startTest();
        CaseRecordTypeSelection_CTRL.getSelectableTypes();
       Test.stopTest();          
    }
}