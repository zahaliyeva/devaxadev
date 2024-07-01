@isTest
private class AP06CaseUpdate_TEST {
/*
----------------------------------------------------------------------------------------------------
-- - Name          : AP06CaseUpdate_TEST
-- - Author        : 	
-- - Description   : Test Methods for AP06CaseUpdate
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------------------------------------
-- 24-02-2015   YRA		1.0		
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/
	static user userAdmin;
	static map<String,Id> acc_developerIdMap;
	static map<String,Id> case_developerIdMap;
	static list <Account> accList;
	static list <Case> caseList;
	
	static{
		//User
	    userAdmin = new User(Username = 'testclassAP01@test.com',
	                        LastName = 'testuser',
	                        LanguageLocaleKey = 'en_US',
	                        FirstName = 'test',
	                        Email = 'test@test.com',
	                        Alias = 'test',
	                        TimeZoneSidKey = 'Europe/Dublin',
	                        LocaleSidKey = 'en_US',
	                        EmailEncodingKey = 'UTF-8',
	                        ProfileId = AP_Constants.getProfileAdminId()
	                        );
	                    
	    insert userAdmin;
	    
	    system.runas(userAdmin){
    		acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
			case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
			
			//account
		    accList = new list<Account>{
		    	new Account(FirstName ='John',
		    				LastName= 'Smith',
		    				PersonEmail = 'john.smith@axa-italy-devtest.com',
		    				RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary) 
		    	),
		    	new Account(FirstName ='Jane',
		    				LastName= 'Smith',
		    				PersonEmail = 'jane.smith@axa-italy-devtest.com',
		    				RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
							Matricola__c='123'
				)
		    };
		    insert accList;
		    
		    //case
			caseList = new list <Case>{
				new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[1].Id,AgentId__c='123'),
				new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[1].Id,AgentName__c =accList[0].Id )
			};

	    }
	}
   
    static testMethod void caseInsertTest() {
        system.debug('#### Start of method caseInsertTest');
		system.runas(userAdmin){
		 	Test.startTest();
	        	insert caseList;
	        Test.stopTest();
	        
			list <Case> caseAsrtList = [Select Id,Category__c,Status,accountid,AgentName__c,contactid,Case_Contact_Email__c
	         							From Case 
	         							Where Id IN:caseList];
	        system.debug('caseAsrtList:'+caseAsrtList);						
            
			system.assertNotEquals(null,caseAsrtList[0].ContactId);
            system.assertEquals(accList[1].PersonEmail,caseAsrtList[0].Case_Contact_Email__c);
            
            system.assertNotEquals(null,caseAsrtList[1].ContactId);
            system.assertEquals(accList[0].PersonEmail,caseAsrtList[1].Case_Contact_Email__c);
    	}
    }
    
	static testMethod void caseUpdateTest() {
        system.debug('#### Start of method caseUpdateTest');
		system.runas(userAdmin){
		 	insert caseList;
		 	Test.startTest();	        
	        	caseList[1].AccountId = null;
	        	caseList[1].AgentName__c = null;
	        	update caseList[1];
	        Test.stopTest();
	        
			list <Case> caseAsrtList = [Select Id,Category__c,Status,accountid,AgentName__c,contactid,Case_Contact_Email__c
 							From Case 
 							Where Id =:caseList[1].Id];
	        system.debug('caseAsrtList:'+caseAsrtList);	
	        system.assertEquals(null,caseAsrtList[0].ContactId);
		}
	}
}