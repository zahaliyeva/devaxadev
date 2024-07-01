@isTest
public class MobilityOpportunityDispatcherTest {
    
    
    @isTest static void testGetCreaPropostaPath_getAssociaPropostaPath() {
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        MobilityOpportunityDispatcher m = new MobilityOpportunityDispatcher(sc);
        m.getCreaPropostaPath(); 
        m.getAssociaPropostaPath();   
        
        MobilityOpportunityDispatcher m2 = new MobilityOpportunityDispatcher();
    }
    
    
    
}