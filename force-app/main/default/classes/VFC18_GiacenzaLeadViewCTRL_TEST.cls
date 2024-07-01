@isTest
public class VFC18_GiacenzaLeadViewCTRL_TEST {
    public static testMethod void test1(){
        Lead test1 = new Lead(Ultima_data_di_riassegnazione__c = date.today(),Contact_Date__c = date.today());
 		test1.FirstName = 'Test';
        test1.LastName = 'Test';
        Lead test2 = new Lead(Ultima_data_di_riassegnazione__c = date.today().addDays(-1));
 		test2.FirstName = 'Test2';
        test2.LastName = 'Test2';
        Lead test3 = new Lead(Ultima_data_di_riassegnazione__c = ((dateTime) date.today()).addHours(-7));
 		test3.FirstName = 'Test3';
        test3.LastName = 'Test3';
 		list<lead> tempList = new List<Lead>();
        tempList.add(test1);
        tempList.add(test2);
        tempList.add(test3);
        insert tempList;
 		Test.StartTest(); 
        PageReference pageRef = Page.VFP18_GiacenzaLeadView; // Add your VF page Name here
  		pageRef.getParameters().put('id', String.valueOf(test1.Id));
 		
  		Test.setCurrentPage(pageRef);
  		ApexPages.StandardController sc = new ApexPages.StandardController(test1);
  		VFC18_GiacenzaLeadViewCTRL testAccPlan = new VFC18_GiacenzaLeadViewCTRL(sc);
		
  		pageRef.getParameters().put('id', String.valueOf(test2.Id));
	
  		Test.setCurrentPage(pageRef);
        testAccPlan = new VFC18_GiacenzaLeadViewCTRL(sc);
        
        pageRef.getParameters().put('id', String.valueOf(test3.Id));
	
  		Test.setCurrentPage(pageRef);
        testAccPlan = new VFC18_GiacenzaLeadViewCTRL(sc);
 		Test.StopTest();
    }
}