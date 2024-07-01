@isTest
public class IE_Parser_GetGaranzieTest {
    
    @testSetup
    static void createTestData() {
        
        IE_Integration_Record__c ir = new IE_Integration_Record__c();
        insert ir;
        
        IE_Configuration__c c = new IE_Configuration__c(Name = 'Test');
        insert c;
        
        IE_Placeholder__c ph = new IE_Placeholder__c();
        insert ph;
        
        IE_CR2PH_junction__c j = new IE_CR2PH_junction__c();
        insert j;
        
        
        
        
    }
    
    @isTest static void test() {
        IE_Integration_Record__c ir = [SELECT id from IE_Integration_Record__c limit 1];
        IE_Configuration__c c = [SELECT id from IE_Configuration__c limit 1];
        List<IE_Placeholder__c> ph = [SELECT id from IE_Placeholder__c ];
        List<IE_CR2PH_junction__c> j = [SELECT id from IE_CR2PH_junction__c ];
        String r = 'Test';
        
        Test.startTest();
        IE_Parser_GetGaranzie pn = new IE_Parser_GetGaranzie();
        pn.ParseResponse(ir, c, ph, j, r);
        Test.stopTest();          
    }
    
}