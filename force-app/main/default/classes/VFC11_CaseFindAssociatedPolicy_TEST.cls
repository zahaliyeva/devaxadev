@isTest
private class VFC11_CaseFindAssociatedPolicy_TEST {
/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : VFC11_CaseFindAssociatedPolicy_TEST
-- - Author        : Marco Moscatelli
-- - Description   : Test Methods for VFC11_CaseFindAssociatedPolicy_TEST
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 22-04-2016   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/
    static user userAdmin;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static list <Account> accList;
    static list <Case> caseList;
    static list <InsurancePolicy__c> policyList;
    static InsurancePolicyAAF__c FamilyProtectPolicy;//MOSCATELLI_M 10102016: Family Protect
    
    
    static
    {
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
                             ByPassVR__c = true,
                             ProfileId = AP_Constants.getProfileAdminId()
                            );
        
        insert userAdmin;
        
        system.runas(userAdmin)
        {
            acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);      
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            
            //account
            accList = new list<Account>
            {
                new Account(FirstName ='John',
                            LastName= 'Smith',
                            PersonEmail = 'john.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                            Fiscal_ID__c = '5645',
                            PersonBirthdate = date.today()
                           ),
                    new Account(FirstName ='Test',
                                LastName= 'Account',
                                PersonEmail = 'test.account@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Fiscal_ID__c = '6789',
                                PersonBirthdate = date.today()
                               ),
                    new Account(FirstName ='Test',
                                LastName= 'Account2',
                                PersonEmail = 'test.account2@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Fiscal_ID__c = '111213',
                                PersonBirthdate = date.today()
                               ),
                    //MOSCATELLI_M 10102016: Family Protect -- START
                    new Account(FirstName ='Test',
                                LastName= 'Account3',
                                PersonEmail = 'test.account3@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccAAFB2C),
                                Fiscal_ID__c = '111213333',
                                PersonBirthdate = date.today()
                               )                    
                    //MOSCATELLI_M 10102016: Family Protect -- END
                    };
                        insert accList;        
            
            //Policies
            policyList = new list<InsurancePolicy__c>
            {
                new InsurancePolicy__c(
                    Name = 'Polizza1',
                    TECH_Company__c = 'MPS',
                    CUID__c =accList[0].Id,
                    CCDATE__c = date.today()-1,
                    EXPIRY_DATE__c= date.today(),
                    Product__c= 'Mutuo'),
                    new InsurancePolicy__c(
                        Name = 'Polizza2',
                        TECH_Company__c = 'Quadra',
                        CUID__c =accList[0].Id,
                        CCDATE__c = date.today()-1,
                        EXPIRY_DATE__c= date.today(),
                        Product__c= 'Vita'),
                    new InsurancePolicy__c(
                        Name = 'Polizza3',
                        TECH_Company__c = 'Quadra',
                        CUID__c =accList[2].Id,
                        CCDATE__c = date.today()-1,
                        EXPIRY_DATE__c= date.today(),
                        Product__c= 'Vita')
                    };
                        insert policyList;
            
            //MOSCATELLI_M 10102016: Family Protect -- START
            FamilyProtectPolicy = new InsurancePolicyAAF__c(Subscriber_national_identifier__c=accList[3].id,Name='AAF1');
            insert FamilyProtectPolicy;
            //MOSCATELLI_M 10102016: Family Protect -- END
            
            //case
            caseList = new list <Case>
            {
                new Case(
                    Status = 'Assigned',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                    AccountId=accList[0].Id),
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                        AccountId= accList[1].Id),
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                        LinkToPolicy__c= policyList[2].Id),
                    //MOSCATELLI_M 10102016: Family Protect -- START
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI),
                        Insurance_Policy_AAF__c= FamilyProtectPolicy.Id),
                    new Case(
                        Status = 'Assigned',
                        RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI),
                        AccountId= accList[3].Id)                    
                    //MOSCATELLI_M 10102016: Family Protect -- END
                    };
                        insert caseList;
        }
    }
    
    static testMethod void associatePolicy_Test1()
    {
        system.debug('#### Start of method associatePolicy_Test1');
        system.runAs(userAdmin){
            test.starttest();                         
            
            PageReference pageRef = Page.VFP11_CaseFindAssociatedPolicy;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
            ApexPages.currentPage().getParameters().put('Account', accList[0].Id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(caseList[0]);
            VFC11_CaseFindAssociatedPolicy policytocase = new VFC11_CaseFindAssociatedPolicy(sc);
            
            
            //update case with policy found
            policytocase.selectedPolicyVal = 0;
            policytocase.asociatePolicyToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,LinkToPolicy__c,AccountId
                                        From Case 
                                        Where Id =:caseList[0].Id];
            system.assertEquals(policyList[0].Id,caseAsrtList[0].LinkToPolicy__c);
            
            system.assertEquals(policyList[0].CUID__c,caseAsrtList[0].AccountId);
        }
    }
    static testMethod void associatePolicy_Test2()
    {
        system.debug('#### Start of method associatePolicy_Test2');
        system.runAs(userAdmin){
            test.starttest();                         
            
            PageReference pageRef = Page.VFP11_CaseFindAssociatedPolicy;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id',caseList[2].Id);
            ApexPages.currentPage().getParameters().put('Account', '');
            ApexPages.currentPage().getParameters().put('Policy',policyList[2].Id );
            
            ApexPages.StandardController sc = new ApexPages.StandardController(caseList[2]);
            VFC11_CaseFindAssociatedPolicy policytocase = new VFC11_CaseFindAssociatedPolicy(sc);
            
            
            //update case with policy found
            policytocase.selectedPolicyVal = 0;
            policytocase.asociatePolicyToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,LinkToPolicy__c,AccountId
                                        From Case 
                                        Where Id =:caseList[2].Id];
            
            system.debug('#caseAsrtList :'+caseAsrtList);
            system.debug('#caseAsrtList :'+policyList[2].Id);
            system.debug('#caseAsrtList :'+policyList[2].CUID__c);
            
            system.assertEquals(policyList[2].Id,caseAsrtList[0].LinkToPolicy__c);
            
            system.assertEquals(policyList[2].CUID__c,caseAsrtList[0].AccountId);
        }
    }
    
    //MOSCATELLI_M 10102016: Family Protect -- START
    static testMethod void associatePolicy_Test3()
    {
        system.debug('#### Start of method associatePolicy_Test3');
        system.runAs(userAdmin){
            test.starttest();                         
            
            PageReference pageRef = Page.VFP11_CaseFindAssociatedPolicy;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id',caseList[4].Id);
            ApexPages.currentPage().getParameters().put('Account', accList[3].Id);
            ApexPages.currentPage().getParameters().put('PolicyAAF','' );
            ApexPages.currentPage().getParameters().put('Policy','' );
            
            ApexPages.StandardController sc = new ApexPages.StandardController(caseList[4]);
            VFC11_CaseFindAssociatedPolicy policytocase = new VFC11_CaseFindAssociatedPolicy(sc);
            
            
            //update case with policy found
            policytocase.selectedPolicyVal = 0;
            policytocase.asociatePolicyToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,Insurance_Policy_AAF__c,AccountId
                                        From Case 
                                        Where Id =:caseList[4].Id];
            
            system.debug('#caseAsrtList :'+caseAsrtList);
            
            system.assertEquals(FamilyProtectPolicy.Id,caseAsrtList[0].Insurance_Policy_AAF__c);
            
            system.assertEquals(FamilyProtectPolicy.Subscriber_national_identifier__c,caseAsrtList[0].AccountId);
        }
    }
    
    static testMethod void associatePolicy_Test4()
    {
        system.debug('#### Start of method associatePolicy_Test4');
        system.runAs(userAdmin){
            test.starttest();                         
            
            PageReference pageRef = Page.VFP11_CaseFindAssociatedPolicy;
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('id',caseList[3].Id);
            ApexPages.currentPage().getParameters().put('Account', '');
            ApexPages.currentPage().getParameters().put('PolicyAAF',FamilyProtectPolicy.Id);
            ApexPages.currentPage().getParameters().put('Policy','' );
            
            ApexPages.StandardController sc = new ApexPages.StandardController(caseList[3]);
            VFC11_CaseFindAssociatedPolicy policytocase = new VFC11_CaseFindAssociatedPolicy(sc);
            
            
            //update case with policy found
            policytocase.selectedPolicyVal = 0;
            policytocase.asociatePolicyToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,Insurance_Policy_AAF__c,AccountId
                                        From Case 
                                        Where Id =:caseList[3].Id];
            
            system.debug('#caseAsrtList :'+caseAsrtList);
            
            system.assertEquals(FamilyProtectPolicy.Id,caseAsrtList[0].Insurance_Policy_AAF__c);
            
            system.assertEquals(FamilyProtectPolicy.Subscriber_national_identifier__c,caseAsrtList[0].AccountId);
        }
    }    
	//MOSCATELLI_M 10102016: Family Protect -- END    
}