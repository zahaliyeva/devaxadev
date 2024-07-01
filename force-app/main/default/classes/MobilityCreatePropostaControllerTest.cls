@isTest
public class MobilityCreatePropostaControllerTest {
    
     @isTest static void testGetUserInfo() {
       Test.startTest();
       MobilityCreatePropostaController.getUserInfo();
       Test.stopTest();          
    }
  
       
     @isTest static void testGetOpportunityInfo() {
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
        
         
       MobilityCreatePropostaController.getOpportunityInfo(opp.Id);
       Test.stopTest();          
    }
  

}