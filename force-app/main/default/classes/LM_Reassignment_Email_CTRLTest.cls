@isTest
public class LM_Reassignment_Email_CTRLTest {
    @testSetup private static void createData(){
        
    }
    
    @isTest static void test() {
        Test.startTest();
        Lead l = new Lead(LastName = 'Test', FirstName = 'Prova', Codice_Sub_Agenzia__c = '');
        Lead l2 = new Lead(LastName = 'Test', FirstName = 'Prova', Codice_Sub_Agenzia__c = '1234');
        insert l;
        insert l2;
        
        LM_Reassignment_Email_CTRL lm = new LM_Reassignment_Email_CTRL();
        lm.theLead = l;
        lm.relatedToLeadId = l.id;
        lm.getReassignmentString();
        LM_Reassignment_Email_CTRL lm2 = new LM_Reassignment_Email_CTRL();
        lm2.relatedToLeadId = l2.id;
        lm2.getReassignmentString();
        Test.stopTest();          
    }
}