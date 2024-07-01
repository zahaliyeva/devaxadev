@isTest
public class MobilityNewOpportunityControllerTest {

    @isTest static void testGetASAList() {
       Test.startTest();
       MobilityNewOpportunityController.getASAList();
       Test.stopTest();          
    }
  
        
      @isTest static void testCreateOpportunity() {
       Test.startTest();      
       Account acc = new Account();
       acc.Name= 'abc';   
       insert acc;       
       MobilityNewOpportunityController.createOpportunity(acc.Id, '1 - Auto');
       Test.stopTest();          
    }   
     
}