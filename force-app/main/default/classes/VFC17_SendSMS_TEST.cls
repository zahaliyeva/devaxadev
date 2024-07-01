@isTest
public with sharing class VFC17_SendSMS_TEST
{
    static List<Account> AccountList;
    static List<User> UserAdminList;
    static List<Case> TestCaseList;
    static Map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static InsurancePolicy__c TestPolicy;
    
    static
    {
        UserAdminList = new List<User>{
                                     new User(Username = 'testclassVFC16@test.com',
                                     LastName = 'testuser',
                                     LanguageLocaleKey = 'en_US',
                                     FirstName = 'test',
                                     Email = 'test@test.com',
                                     Alias = 'test',
                                     TimeZoneSidKey = 'Europe/Dublin',
                                     LocaleSidKey = 'en_US',
                                     EmailEncodingKey = 'UTF-8',
                                     ProfileId = AP_Constants.getProfileAdminId(),
                                     ByPassVR__c = true),
                                     new User(Username = 'testclass2VFC16@test.com',
                                     LastName = 'testuser2',
                                     LanguageLocaleKey = 'it',
                                     FirstName = 'test2',
                                     Email = 'test2@test.com',
                                     Alias = 'test2',
                                     TimeZoneSidKey = 'Europe/Dublin',
                                     LocaleSidKey = 'it',
                                     EmailEncodingKey = 'UTF-8',
                                     ProfileId = AP_Constants.getProfileAdminId(),
                                     ByPassVR__c = true)
                                    };
		insert UserAdminList;        
    
    	acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);

        AccountList = new list<Account>{
                                        new Account(FirstName ='Jane',
                                                    LastName= 'Smith',
                                                    PersonMobilePhone = '00393408798576',
                                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                                    ShippingStreet='Via Veneziani 20',
                                                    ShippingCity = 'Roma',
                                                    ShippingCountry = 'ITALIA',
                                                    ShippingPostalCode = '00100'
                                                   ),                                        
                                        new Account(FirstName ='Test',
                                                    LastName= 'AAIB2C',
                                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C),
                                                    CIF_PersonMobilePhone__c='3396567889'
                                                   ),
                                        new Account(Name ='TestCompanyAAI',
                                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2B),
                                                    CIF_MobilePhone__c='3396567889'
                                                   ),										   
                                        new Account(FirstName ='Test',
                                                    LastName= 'MPSIndividual',
                                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                                    PersonMobilePhone='01123445'
                                                   ),
                                        new Account(Name ='TestCompanyMPS',
                                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccCorporateClient),
                                                    Mobilephone__c = '3534643636'
                                                   ),
                                        new Account(FirstName ='Will',
                                                    LastName= 'Smith',
                                                    PersonMobilePhone = '00393408798576',
                                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccAAFB2C)
                                                   )                                            
                    };
        
        system.runAs(UserAdminList[0])                
        {
        	insert AccountList;
         }
        
        TestPolicy = new InsurancePolicy__c(Name='tstpol1', CUID__c = AccountList[0].id);
        
        insert TestPolicy;

        TestCaseList = new List<Case>{
            						 new Case(RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), Origin = 'Phone',Complainant__c= 'Customer',Accountid = AccountList[0].id),
                                     new Case(RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), Origin = 'Phone',Complainant__c= 'Customer',Accountid = AccountList[1].id),
                                     new Case(RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), Origin = 'Phone',Complainant__c= 'Customer',Accountid = AccountList[2].id),
                                     new Case(RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), Origin = 'Phone',Complainant__c= 'Customer',Accountid = AccountList[3].id),
                                     new Case(RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), Origin = 'Phone',Complainant__c= 'Customer',Accountid = AccountList[4].id),
                                     new Case(RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor), Origin = 'Phone',Complainant__c= 'Customer',Accountid = AccountList[5].id)                                                                                    
        };
        
        insert TestCaseList;
    }
    
   
    @isTest(SeeAllData=true)
    static void TestSMS6()
    {
        system.runAs(UserAdminList[1])
        {   
            String FolderIdTest = [Select id from Folder where Name = 'SMS Automatici' LIMIT 1].Id;
            
            EmailTemplate TestTemplate = new EmailTemplate(FolderId=FolderIdTest,
                                                           IsActive=true,
                                                           TemplateType='text',
                                                           Name='tsttempl',
                                                           DeveloperName='tsttempl',
                                                           Encoding='ISO-8859-1',
                                                           Subject='test',
                                                           Body='Gentile {!Case.Account}, {!Case.Linktopolicy__c} {!Case.Createddate} {!InsurancePolicy__c.Name} {!Account.ShippingAddress}');
            insert TestTemplate;
            
			Set<String> InputSet = new Set<String>();
            
            InputSet.add(TestCaseList[0].id+'|'+AccountList[0].id+'|tsttempl');
            
            Case TstCase = new Case(id=TestCaseList[0].id,LinktoPolicy__c=TestPolicy.id);
            
            test.startTest();
            
            Upsert TstCase;
            
            VFC17_SendSMS.AutomaticSMS(InputSet);
            
            test.stopTest();
        }
    }

   
}