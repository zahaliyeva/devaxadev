/*------------------------------------------------------------------------------------------------
Author:        Andrea Capobianco
Company:       Deloitte
Class:         AssociaPropostaAccountCTRL_TEST
Description:   Test for the extension of the VF page for proposte creation from the account page
History

28/11/2017     Andrea Capobianco: created
--------------------------------------------------------------------------------------------------*/


@istest
public class CreaPropostaAccountCTRL_TEST {

	@testSetup static void setup(){//preparing test database
        
        //Create agency and smart center user
		AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
		insert acv;	
        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];     
        Id pVen = pvendite.Id;   
		Profile scMotorAdvisor = [SELECT Id FROM Profile WHERE Name = 'SmartCenter Motor Advisor'];
		Id scAdv = scMotorAdvisor.Id;

        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        
        //Create Partner User
        Account agencyAccount = new Account(Name = 'Agency Test Account',
        RecordTypeId = account_agency,
        Agency_Code__c = '000828');
        insert agencyAccount;
        
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
        RecordtypeId = contact_agency,
        AccountId = agencyAccount.Id);
        insert agencyContact;

        AAI_Code_Variables__c customSetting = new AAI_Code_Variables__c(Name = 'DAOL_URL_Prefix_CreaPropostaAccount',
                                                                         Value__c = 'https://daol-int.axa-italia.it/axad/');
        insert customSetting;
        

        
        User usr1=new User(FirstName='Testuser',
					        LastName = 'Deloitte', 
					        Alias = 'tde123', 
					        Email = 'testuser123ac@deloitte.com', 
					        Username = 'testuser123ac@axa.com.masterdev3', 
					        CommunityNickname = 'TestUS1', 
					        LanguageLocaleKey = 'en_US',
					        TimeZoneSidKey='Europe/Rome',
					        Agency_Code__c = '000828',
					        Nodes__c = 'DIF_000828',
					        Profileid = pVen,
					        LocaleSidKey='en_US',
					        EmailEncodingKey='ISO-8859-1',
					        //UserRoleId=pRol,
					        ContactId = agencyContact.Id
        );

        User usr2=new User(FirstName='TestuserSC',
					        LastName = 'Deloitte', 
					        Alias = 'tde321', 
					        Email = 'testuser321ac@deloitte.com', 
					        Username = 'testuser321ac@axa.com.masterdev3', 
					        CommunityNickname = 'TestUS2', 
					        LanguageLocaleKey = 'en_US',
					        TimeZoneSidKey='Europe/Rome',
					        Agency_Code__c = '000828',
					        Nodes__c = 'DIF_000828',
					        Profileid = scAdv,
					        LocaleSidKey='en_US',
					        EmailEncodingKey='ISO-8859-1'
        );
                    
        System.runAs(new User(Id=UserInfo.getUserId()))
        {            
            insert usr1;
            insert usr2;
        }

        Account Theclient = new Account(OwnerId = usr1.Id);
	        //TheClient.TECH_Company__c = 'AAI';
	        TheClient.NDG__c='1111111111';
	        RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
	        TheClient.RecordTypeId = PF_RT.Id;
	        TheClient.LastName = 'Rossi';
	        TheClient.FirstName = 'Mario';

	        insert Theclient;
        
		System.runAs(usr1)
        { 
	        // Insert Client 
	        
	                        
	        //InsertOpportunity
	        Opportunity Opp1 = new Opportunity();
	        Opp1.Name='test';
	        RecordType OPP_RE = [SELECT id from RecordType where DeveloperName ='Opportunita_AXA_Assicurazioni' AND SobjectType='Opportunity' Limit 1];
	        Opp1.RecordTypeId=OPP_RE.Id;
	        Opp1.StageName = 'Open';
	        Opp1.CloseDate = Date.Today().addDays(90);
	        Opp1.AccountId = TheClient.Id;

	        insert Opp1;
	    }

    }

    static testmethod void testmethod_1(){

    	Account myClient = [SELECT Id FROM Account where NDG__c='1111111111' Limit 1];
    	User theAgent = [SELECT id FROM user where Username='testuser123ac@axa.com.masterdev3' Limit 1]; 

    	ApexPages.StandardController sc = new ApexPages.StandardController(myClient);
    	CreaPropostaAccountCTRL ctrl = new CreaPropostaAccountCTRL(sc);
        PageReference pageRef = Page.CreaPropostaAccount;
        pageRef.getParameters().put('Id', String.valueOf(myClient.Id));
        Test.setCurrentPage(pageRef);

        System.runAs(theAgent)
        {
	        test.StartTest();
	        ctrl.createOpportunita();
	        ctrl.getOpportunita();
	        test.StopTest();
	    }

        Opportunity oppCreated = [SELECT Id,Name FROM Opportunity WHERE AccountId =: myClient.Id ORDER BY CreatedDate DESC LIMIT 1];


        System.assertEquals(ctrl.listOpp.size(),2);
        System.assertEquals(ctrl.oppId,oppCreated.Id);
        System.assertEquals(ctrl.oppName,oppCreated.Name);

    }

    static testmethod void testmethod_2(){

    	Account myClient = [SELECT Id FROM Account where NDG__c='1111111111' Limit 1];
    	Opportunity oppToDelete = [SELECT Id FROM Opportunity WHERE AccountId =: myClient.Id LIMIT 1];  
    	delete oppToDelete;

    	ApexPages.StandardController sc = new ApexPages.StandardController(myClient);
    	CreaPropostaAccountCTRL ctrl = new CreaPropostaAccountCTRL(sc);
        PageReference pageRef = Page.CreaPropostaAccount;
        pageRef.getParameters().put('Id', String.valueOf(myClient.Id));
        Test.setCurrentPage(pageRef);

        test.StartTest();
        try
        {
        	ctrl.setOpportunityIdAndName();
        }
        catch(Exception e)
        {
        	System.assertEquals(ctrl.oppId,null);
        	System.assertEquals(ctrl.oppName,null);
        	System.assertEquals(ctrl.showError,true);
        }
        test.StopTest();
    }

    //testing the failing of the opportunity creation. The Smart Center User is needed because he does not have access to the Opportunity Record Type
    static testmethod void testmethod_3(){

    	Account myClient = [SELECT Id FROM Account where NDG__c='1111111111' Limit 1];
    	User theAdvisor = [SELECT id FROM user where Username='testuser321ac@axa.com.masterdev3' Limit 1]; 

    	ApexPages.StandardController sc = new ApexPages.StandardController(myClient);
    	CreaPropostaAccountCTRL ctrl = new CreaPropostaAccountCTRL(sc);
        PageReference pageRef = Page.CreaPropostaAccount;
        pageRef.getParameters().put('Id', String.valueOf(myClient.Id));
        Test.setCurrentPage(pageRef);

        test.StartTest();
        System.runAs(theAdvisor)
        {
	        try
	        {
	        	ctrl.createOpportunita();
	        }
	        catch(Exception e)
	        {
	        	System.assertEquals(ctrl.oppId,null);
	        	System.assertEquals(ctrl.oppName,null);
	        	System.assertEquals(ctrl.showError,true);
	        }
	        test.StopTest();
    	}
    }

}