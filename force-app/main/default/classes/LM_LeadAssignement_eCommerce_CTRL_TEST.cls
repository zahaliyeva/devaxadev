@isTest
public with sharing class LM_LeadAssignement_eCommerce_CTRL_TEST {

    @testSetup 
	static void setup(){

		Id leadECommerceRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'eCommerce' AND SobjectType = 'Lead'].Id;
		
		AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    	insert acv;

		LeadAssignmentConfiguration__c lac1 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for Lead duplication', 
    											DaysLimit__c=7.0
    											);

    	LeadAssignmentConfiguration__c lac2 = new LeadAssignmentConfiguration__c(
    											Name='Last n days for duplication M upload', 
    											DaysLimit__c=7.0
    											);

    	List<LeadAssignmentConfiguration__c> listLac = new List<LeadAssignmentConfiguration__c>();
    	listLac.add(lac1);
    	listLac.add(lac2);

    	insert listLac;

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
	            LeadSource = 'Web',
	            Dettaglio__c = 'Salva quotazione',
	            ID_Session__c = 'tt6zst'
	            );


	    List<Lead> llist = new List<Lead>();
    	llist.add(ld);

    	insert llist;
    
    	QuotationManagement.setAgencyCode(llist);
	    
	    //Create Quotazione
	    Quotazione__c quot = new Quotazione__c(
	            Name = 'QuotTest',
				Lead_Step_Status__c = 'Salva quotazione',
            	Good_Factors__c = '[{"Name":"Nome del cane","Value":"Gennaro"}]',
				ID_Session__c = 'tt6zst',
	            Lead__c = ld.Id,
                Premium__c = 2000,
				Proposal_Code__c = 'aaa555'
	            );

		List<Quotazione__c> qlist = new List<Quotazione__c>();
    	qlist.add(quot);

    	insert qlist;

	}

    public LM_LeadAssignement_eCommerce_CTRL_TEST() {

    }
    
    static testmethod void testGetPolicyNumber(){

		List<Quotazione__c> quotation = [SELECT Id FROM Quotazione__c WHERE ID_Session__c = 'tt6zst'];

        Test.startTest();
        LM_LeadAssignement_eCommerce_CTRL ctrl = new LM_LeadAssignement_eCommerce_CTRL();
		ctrl.relatedToLeadSessionId = 'tt6zst';
		String ret = ctrl.getPolicyNumber();
		System.assertEquals(' aaa555', ret);
        Test.stopTest();
        System.debug(' ===> result: ' + ret);
    }
	
    static testmethod void testGetPremium(){

		List<Quotazione__c> quotation = [SELECT Id FROM Quotazione__c WHERE ID_Session__c = 'tt6zst'];

        Test.startTest();
        LM_LeadAssignement_eCommerce_CTRL ctrl = new LM_LeadAssignement_eCommerce_CTRL();
		ctrl.relatedToLeadSessionId = 'tt6zst';
		String ret = ctrl.getPremium();
		System.assertEquals(' 2000.00', ret);
        Test.stopTest();
        System.debug(' ===> result: ' + ret);
    }
	
    static testmethod void testGetLeadDataCreation(){

		List<Lead> lead = [SELECT Id FROM Lead WHERE ID_Session__c = 'tt6zst'];

        Test.startTest();
        LM_LeadAssignement_eCommerce_CTRL ctrl = new LM_LeadAssignement_eCommerce_CTRL();
		ctrl.relatedToLeadId = lead[0].Id;
		String ret = ctrl.getLeadDataCreation();
		//System.assertEquals(' 2000', ret);
        Test.stopTest();
        System.debug(' ===> result: ' + ret);
    }
    
    static testmethod void testGetPolicyNumberError(){

		List<Quotazione__c> quotation = [SELECT Id FROM Quotazione__c WHERE ID_Session__c = 'tt6zst'];

        Test.startTest();
        LM_LeadAssignement_eCommerce_CTRL ctrl = new LM_LeadAssignement_eCommerce_CTRL();
		ctrl.relatedToLeadSessionId = quotation[0].Id;
		String ret = ctrl.getPolicyNumber();
		System.assertEquals('Nessun Lead di riferimento trovato', ret);
        Test.stopTest();
        System.debug(' ===> result: ' + ret);
    }
	
    static testmethod void testGetPremiumError(){

		List<Quotazione__c> quotation = [SELECT Id FROM Quotazione__c WHERE ID_Session__c = 'tt6zst'];

        Test.startTest();
        LM_LeadAssignement_eCommerce_CTRL ctrl = new LM_LeadAssignement_eCommerce_CTRL();
		ctrl.relatedToLeadSessionId = quotation[0].Id;
		String ret = ctrl.getPremium();
		System.assertEquals('Nessun Lead di riferimento trovato', ret);
        Test.stopTest();
        System.debug(' ===> result: ' + ret);
    }
	
    static testmethod void testGetLeadDataCreationError(){

		List<Lead> lead = [SELECT ID_Session__c FROM Lead WHERE ID_Session__c = 'tt6zst'];

        Test.startTest();
        LM_LeadAssignement_eCommerce_CTRL ctrl = new LM_LeadAssignement_eCommerce_CTRL();
		ctrl.relatedToLeadId = '00Q6E000004DXyb';
		String ret = ctrl.getLeadDataCreation();
		System.assertEquals('Nessun Lead di riferimento trovato', ret);
        Test.stopTest();
        System.debug(' ===> result: ' + ret);
    }
}