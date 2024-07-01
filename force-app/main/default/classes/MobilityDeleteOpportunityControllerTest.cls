@isTest
public class MobilityDeleteOpportunityControllerTest {
    
    @isTest static void testMethods() {
        Test.startTest();
        Account acc = new Account ();
        acc.Name='Test'; 
        acc.NDG__c='test test';  
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Myopp'; 
        opp.StageName='Open';
        opp.AccountId = acc.Id;
        opp.CloseDate= (date.today()).addDays(30); 
        insert opp;
        
        
        MobilityDeleteOpportunityController.getOpportunityInfo(opp.Id);
        MobilityDeleteOpportunityController.getDeleteOpportunity(opp);
        
        Test.stopTest();          
    }
    
}