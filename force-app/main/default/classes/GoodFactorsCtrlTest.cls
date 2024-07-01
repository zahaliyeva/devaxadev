@isTest
private class GoodFactorsCtrlTest {

	public GoodFactorsCtrlTest() {
		
	}

	static testmethod void getDataTest(){

		Id leadECommerceRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'eCommerce' AND SobjectType = 'Lead'].Id;
		
		AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    	insert acv;

    	LeadAssignmentConfiguration__c lac1 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for Lead duplication', 
    											DaysLimit__c=7.0
    											);
    	insert lac1;

    	LeadAssignmentConfiguration__c lac2 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for duplication M upload', 
    											DaysLimit__c=7.0
    											);

    	List<LeadAssignmentConfiguration__c> listLac = new List<LeadAssignmentConfiguration__c>();
    	insert lac2;

		System.debug(' ==> RecordType Id: ' + leadECommerceRecordTypeId);

		//Create Lead
	    Lead ld = new Lead(
	            LastName = 'LeadTest',
	            FirstName ='test',
	            Email = 'lead@mail.test',
	            Phone = '0333333333',
	            Agency_Code__c = '006345',
	            MobilePhone = '3333333333', 
	            Landing_page__c = 'Confido',
	            Postalcode = '20090',
	            RecordTypeId = leadECommerceRecordTypeId,
	            ASA__c = 'Famiglia',
	            Sotto_ASA__c = 'ABITAZIONE',
	            LeadSource = 'Web'
	            );
	    insert ld;   

	    List<Lead> llist = new List<Lead>();
    	llist.add(ld);
    
    	QuotationManagement.setAgencyCode(llist);
	    
	    //Create Quotazione
	    Quotazione__c quot = new Quotazione__c(
	            Name = 'QuotTest',
            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
	            Lead__c = ld.Id
	            );
	    insert quot;

	    ApexPages.StandardController stcctrl = new ApexPages.StandardController(quot);

		Test.startTest();

		GoodFactorsCtrl ctrl = new GoodFactorsCtrl(stcctrl);

		List<Map<String, String>> ret = GoodFactorsCtrl.getDataComplete(quot.Id);

		for(Map<String, String> t : ret){
			System.assertEquals('Nome del cane', t.get('Name'));
			System.assertEquals('Gennaro', t.get('Value'));
		}

		Test.stopTest();

	}
}