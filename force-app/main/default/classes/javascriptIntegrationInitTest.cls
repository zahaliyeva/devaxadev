@isTest
public class javascriptIntegrationInitTest {
      @isTest static void test() {
       Test.startTest();
       PageReference pageRef = Page.javascriptIntegrationInit;
       Test.setCurrentPage(pageRef);
       pageRef.getParameters().put('counters','campaign,lead,feedback');
       javascriptIntegrationInit j = new javascriptIntegrationInit();
       Test.stopTest();          
    }
}