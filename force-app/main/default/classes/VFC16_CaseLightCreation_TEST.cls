/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : VFC16_CaseLightCreation_TEST
-- - Author        : Marco Moscatelli
-- - Description   : Test Methods for VFC16_CaseLightCreation
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 21-12-2016   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/
@isTest
public class VFC16_CaseLightCreation_TEST 
{
	static List<User> AdminList;
    static Storico_Chiamate__c StoricoChiamateTest;
    static Case TestCase;
    static List<Account> TstAccountList;
    static List<Case_Light_Categories__c> testCustSettList;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    
    static
    {
        AdminList = new List<User>{
                                     new User(Username = 'testclassVFC16@test.com',
                                     LastName = 'testuser',
                                     LanguageLocaleKey = 'en_US',
                                     FirstName = 'test',
                                     Email = 'test@test.com',
                                     Alias = 'test',
                                     TimeZoneSidKey = 'Europe/Dublin',
                                     LocaleSidKey = 'en_US',
                                     EmailEncodingKey = 'UTF-8',
                                     ProfileId = AP_Constants.getProfileAdminId()),
                                     new User(Username = 'testclass2VFC16@test.com',
                                     LastName = 'testuser2',
                                     LanguageLocaleKey = 'it',
                                     FirstName = 'test2',
                                     Email = 'test2@test.com',
                                     Alias = 'test2',
                                     TimeZoneSidKey = 'Europe/Dublin',
                                     LocaleSidKey = 'it',
                                     EmailEncodingKey = 'UTF-8',
                                     ProfileId = AP_Constants.getProfileAdminId())    
                                    };
		insert AdminList;
        
        acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        
        TstAccountList = new list<Account>{
            							      new Account(FirstName ='Jane',
                                              LastName= 'Smith',
                                              PersonEmail = 'jane.smith@axa-italy-devtest.com',
                                              RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                                             ),                      
                                  			  new Account(FirstName ='Jamie',
                                              LastName= 'Smith',
                                              PersonEmail = 'Jamie.smith@axa-italy-devtest.com',
                                              RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary),
                                              Matricola__c='456')            							  			
        								  };
        insert TstAccountList;
        
        TestCase = new Case(Status = 'Assigned',
                            RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                            AccountId= TstAccountList[0].Id,
                            AgentName__c=TstAccountList[1].id,
                            Category__c ='Preventivi ed emissioni - polizze di auto',
                            SubCategory__c = 'Emissioni polizze off line',
                            SubCategoryDetail__c = 'Figure contrattuali'
                           );
        insert TestCase;
        
        StoricoChiamateTest = new Storico_Chiamate__c(Call_ID__c='123',
                                                     Case__c=TestCase.Id,
                                                     Customer__c =TstAccountList[0].Id);
        insert StoricoChiamateTest;
        
        testCustSettList = new List<Case_Light_Categories__c>{
            													new Case_Light_Categories__c(Category__c='Altro',
                                                                                            Sub_Category__c='Financial',
                                                                                            Name='C-001'),
                                                                new Case_Light_Categories__c(Category__c='Altro',
                                                                                            Sub_Category__c='Isola della rete',
                                                                                            Name='C-002'), 
                                                                new Case_Light_Categories__c(Category__c='Aree riservate',
                                                                                            Sub_Category__c='Previsio',
                                                                                            Name='C-003')
        													 };
       insert testCustSettList;
    }
    
    static testMethod void test1()
    {
        system.runAs(AdminList[0])
        {
        	test.startTest();
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);
            
			ApexPages.currentPage().getParameters().put('CaseType', case_developerIdMap.get(AP_Constants.rtCaseMotor));
            ApexPages.currentPage().getParameters().put('CustType', 'cliente');
            ApexPages.currentPage().getParameters().put('CallId', '456');
            ApexPages.currentPage().getParameters().put('ClientId', TstAccountList[0].Id);
            ApexPages.currentPage().getParameters().put('AgentId', TstAccountList[1].Id);
            ApexPages.currentPage().getParameters().put('Distribution', 'MPS');
            
            VFC16_CaseLightCreation tstcontroller = new VFC16_CaseLightCreation();
            tstcontroller.CreateCaseLight();
            
            tstcontroller.SelectedCategory=testCustSettList[0].Category__c;
            tstcontroller.getSecondaryPickVals();
            tstcontroller.SelectedSubCategory=testCustSettList[0].Sub_Category__c;
            tstcontroller.CreateCaseLight();
            
            test.stopTest();
        }
    }
    
    static testMethod void test2()
    {
        system.runAs(AdminList[1])
        {
        	test.startTest();
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);
            
			ApexPages.currentPage().getParameters().put('CaseType', case_developerIdMap.get(AP_Constants.rtCaseMotor));
            ApexPages.currentPage().getParameters().put('CustType', 'gestore');
            ApexPages.currentPage().getParameters().put('CallId', '678');
            ApexPages.currentPage().getParameters().put('ClientId', TstAccountList[0].Id);
            ApexPages.currentPage().getParameters().put('AgentId', TstAccountList[1].Id);
            
            VFC16_CaseLightCreation tstcontroller = new VFC16_CaseLightCreation();
            tstcontroller.CreateCaseLight();
            
            tstcontroller.SelectedCategory=testCustSettList[0].Category__c;
            tstcontroller.getSecondaryPickVals();
            tstcontroller.SelectedSubCategory=testCustSettList[0].Sub_Category__c;
            tstcontroller.CreateCaseLight();
            
            test.stopTest();
        }
    }
    
    static testMethod void test3()
    {
        system.runAs(AdminList[1])
        {
        	test.startTest();
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);
            
			ApexPages.currentPage().getParameters().put('CaseType', case_developerIdMap.get(AP_Constants.rtCaseMotor));
            ApexPages.currentPage().getParameters().put('CustType', 'cliente');
            ApexPages.currentPage().getParameters().put('CallId', '123');
            ApexPages.currentPage().getParameters().put('ClientId', TstAccountList[0].Id);
            ApexPages.currentPage().getParameters().put('AgentId', TstAccountList[1].Id);
            
            VFC16_CaseLightCreation tstcontroller = new VFC16_CaseLightCreation();
            tstcontroller.CreateCaseLight();
            
            tstcontroller.SelectedCategory=testCustSettList[0].Category__c;
            tstcontroller.getSecondaryPickVals();
            tstcontroller.SelectedSubCategory=testCustSettList[0].Sub_Category__c;
            tstcontroller.CreateCaseLight();
            
            test.stopTest();
        }
    }

    static testMethod void test4()
    {
        system.runAs(AdminList[1])
        {
        	test.startTest();
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);
            
			ApexPages.currentPage().getParameters().put('CaseType', 'Light');
            ApexPages.currentPage().getParameters().put('CustType', 'cliente');
            ApexPages.currentPage().getParameters().put('CallId', '123');
            ApexPages.currentPage().getParameters().put('ClientId', TstAccountList[0].Id);
            ApexPages.currentPage().getParameters().put('AgentId', TstAccountList[1].Id);
            
            VFC16_CaseLightCreation tstcontroller = new VFC16_CaseLightCreation();
            tstcontroller.CreateCaseLight();
            
            tstcontroller.SelectedCategory=testCustSettList[0].Category__c;
            tstcontroller.getSecondaryPickVals();
            tstcontroller.SelectedSubCategory=testCustSettList[0].Sub_Category__c;
            tstcontroller.CreateCaseLight();
            
            test.stopTest();
        }
    }
}