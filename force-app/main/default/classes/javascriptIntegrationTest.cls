@isTest
public class javascriptIntegrationTest {
      @isTest static void test() {
       Test.startTest();
       PageReference pageRef = Page.javascriptIntegrationInit;
       Test.setCurrentPage(pageRef);
       pageRef.getParameters().put('counters','campaign,lead,feedback');
       javascriptIntegration j = new javascriptIntegration();
       Test.stopTest();          
    }
}