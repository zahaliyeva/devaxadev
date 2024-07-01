@isTest
public class MobilityQuotazioniEcommerceTest {
    
    @testSetup
    private Static void createData(){
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    	insert acv;
        Quotazione__c q = new Quotazione__c();
        insert q;
        
    }
    
    @isTest static void test() {
        AAI_Code_Variables__c cv = [SELECT id FROM AAI_Code_Variables__c];
        System.debug('TEST **** cv: ' + cv);
        Quotazione__c q = [SELECT id, RecordType.DeveloperName FROM Quotazione__c LIMIT 1];
        System.debug('TEST **** : ' + q.RecordType.DeveloperName);
       	Test.startTest();
        MobilityQuotazioniEcommerceController.getRTDevName(q.Id);
       	Test.stopTest();          
    }
    
}