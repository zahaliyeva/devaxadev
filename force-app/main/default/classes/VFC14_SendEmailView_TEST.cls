/*
**********************************************************************************************
----------------------------------------------------------------------------------------------
-- - Name          : VFC14_SendEmailView_TEST
-- - Author        : Marco Moscatelli
-- - Description   : Test Methods for VFC14_SendEmailView
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ---------------------------------------------------------------------
-- 26-05-2016   1.0     
----------------------------------------------------------------------------------------------
**********************************************************************************************
*/


@isTest(SeeAllData=true)
private class VFC14_SendEmailView_TEST
{
  static user UserAdmin;
    static List<Case> TestCaseList;
    static List<Account> TestAccountList;
    static Account TestAgent;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static List<Record_Type_Email__c> EmailRulesList;
    static List<EmailMessage> EmailMessageList;
    static Attachment EmailAttachment;
    static User usr1;
    
    static
    {
        //User
        UserRole Rol = [Select id from UserRole where developername ='AXA_MPS'];

        userAdmin = new User(Username = 'testclassAP01@test.com',
                             LastName = 'testuser',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test',
                             Email = 'test@test.com',
                             Alias = 'test',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = AP_Constants.getProfileAdminId(),
                             UserRoleId = Rol.id 
                            );
        
        insert userAdmin;

        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];

        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');

       system.runAs(userAdmin)
       { 
        Account agencyAccount = new Account(Name = 'Agency Test Account',
                                            RecordTypeId = account_agency,
                                            Agency_Code__c = '006345',
                                            Active__c = true,
                                            DAOL_2_0__c = true);
        insert agencyAccount;
        
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
                                            RecordtypeId = contact_agency,
                                            AccountId = agencyAccount.Id);
        insert agencyContact;
        


        usr1=new User(FirstName='Marzia',
                               LastName = 'Rossi', 
                               Alias = 'mro666', 
                               Email = 'mrosskmans@deloitte.com', 
                               Username = 'mrosskm11@axa.com.masterdev', 
                               CommunityNickname = 'MarziRo', 
                               LanguageLocaleKey = 'en_US',
                               TimeZoneSidKey='Europe/Rome',
                               Agency_Code__c = '000828',
                               Nodes__c = 'DIF_000828',
                               Main_Node__c = '000828',
                               Profileid = pvendite.id,
                               LocaleSidKey='en_US',
                               EmailEncodingKey='ISO-8859-1',
                               IsActive = true,
                               ContactId = agencyContact.Id
                              );
        

        
        //system.runAs(userAdmin)
        //{  
            insert usr1;
            acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
            
            //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
            /*AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;*/
            //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
            //Creating the Agency Accounts with the relative Contacts
            //BOVOLENTA_D US 588 
           // Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
           // id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');

            Account agency = new Account(
                          RecordTypeId = account_agency,
                          Agency_Code__c = '999999',
                          Active__c = true,
                          Accordo_Digitale__c = true,
                          Name = 'AGENZIA PROVA'
                          );  

            insert agency;
            Id agencyId = agency.id;
            //BOVOLENTA_D END
            /*TestAccountList = new list<Account>
            {
                new Account(PersonEmail='Account1_Individual@test.it',
                           FirstName='Account1',
                           LastName='Individual',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                           ),
                new Account(Additional_Email__c='Account2_Individual@test.it',
                           FirstName='Account2',
                           LastName='Individual',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                           ),
                new Account(Account_email__c='Account3_Corporate@test.it',
                           Name='Account3 Corporate',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccCorporateClient)
                           ),
                new Account(Subject_email__c='Account4_B2B@test.it',
                           Name='Account4 B2B',
                           AAI_Agency__c = agencyId,
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2B)
                           ),
                new Account(CIF_PersonEmail__c='Account5_B2C@test.it',
                           FirstName='Account5',
                           LastName='B2C',
                           AAI_Agency__c = agencyId,
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C)
                           ),
                new Account(Claim_PersonalEmail__c='Account6_Individual@test.it',
                           FirstName='Account6',
                           LastName='Individual',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                           )                    
            };

            insert TestAccountList; */
            
            TestAgent = new Account(RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary),
                                   PersonEmail = 'Agent@test.it',
                                   FirstName = 'Test',
                                   LastName ='Agent'
                                   );                                
            insert TestAgent;
            
            /*Id AgentId =[select Id from Account where PersonEmail='Agent@test.it'].Id;
            
            TestCaseList = new list<Case>
            {
                new Case(Complainant__c='Customer',
                         SuppliedEmail='testCase1@test.it',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[0].id,
                         AgentName__c = AgentId
                        ),
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[1].id
                        ),
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[2].id
                        ),
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[3].id
                        ),
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[4].id
                        ),
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[5].id
                        )                    
            };
                
            insert TestCaseList;  */
                
            EmailRulesList = new list<Record_Type_Email__c>
            {
                new Record_Type_Email__c(Caller__c = 'Customer',
                                        Record_Type__c='Non Motor',
                                        Sender_Email__c='orgemail@customer.it'
                                        ),
                new Record_Type_Email__c(Caller__c = 'Bank Agent',
                                        Record_Type__c='Non Motor',
                                        Sender_Email__c='orgemail@agent.it'
                                        ),
                new Record_Type_Email__c(Caller__c = 'Techincal Office',
                                        Record_Type__c='Non Motor',
                                        Sender_Email__c='orgemail@OT.it'
                                        )                    
            };
           
            insert EmailRulesList;  
                 /*      
            EmailMessageList = new list<EmailMessage> 
            {
                new EmailMessage(Subject ='Test Incoming1',
                                Status ='1',
                                TextBody= 'Messaggio test 1',
                                MessageDate= Date.today()-1,
                                Incoming = true,
                                FromAddress = 'Receiver1@test1.it',
                                ParentID=TestCaseList[0].id
                                ),
                new EmailMessage(Subject ='Test Outbound1',
                                Status ='2',
                                TextBody= 'Messaggio test 2',
                                MessageDate= Date.today(),
                                Incoming = false,
                                FromAddress = 'Sender1@test2.it',
                                ParentID=TestCaseList[0].id
                                ),
                new EmailMessage(Subject ='Test Outbound1',
                                Status ='2',
                                TextBody= 'Test Outbound1 Test Outbound1 Test Outbound1 Test Outbound1Test Outbound1 Test Outbound1 Test Outbound1 Test Outbound1',
                                MessageDate= Date.today(),
                                Incoming = false,
                                FromAddress = 'Sender1@test2.it',
                                ParentID=TestCaseList[1].id
                                )                    
            };
            
            insert EmailMessageList;
            
            EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/
        }
    }

    static testMethod void SendEmail1()
    {

        
        Id AgentId;
        User user1;
        system.runAs(userAdmin)
        {
        user1 = [Select id from User where Username='mrosskm11@axa.com.masterdev'];

        TestAccountList = new list<Account>
        {
            new Account(PersonEmail='Account1_Individual@test.it',
                       FirstName='Account1',
                       LastName='Individual',
                       RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                       )
                };
        insert TestAccountList;
        AgentId =[select Id from Account where PersonEmail='Agent@test.it'].Id;


        
        TestCaseList = new list<Case>
        {
            new Case(Complainant__c='Customer',
                     SuppliedEmail='testCase1@test.it',
                     RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                     AccountId=TestAccountList[0].id,
                     OwnerId=user1.id,
                     AgentName__c = AgentId
                    )};
        insert TestCaseList;

        //system.runAs(usr1)
        //{
            Task t = new Task(Subject='Email: posta',
                            ActivityDate = system.today(),
                            Description = 'Mittente: test@test.it'+'\n'+'Destinatario: dest@test.it'+'\n'+'Allegato: all.pdf'+'\n'+'Oggetto: ogg'+'\n'+'Corpo: c',
                            Tipo_Attivit__c = 'Email',
                            Type = 'Email',
                            Status = 'Completed',
                            WhatId = TestCaseList[0].id
                            );
            insert t;
        }

        system.runAs(userAdmin)
        {
            test.starttest();
   
            EmailMessageList = new list<EmailMessage> 
            {
                new EmailMessage(Subject ='Test Incoming1',
                                Status ='1',
                                TextBody= 'Messaggio test 1',
                                MessageDate= Date.today()-1,
                                Incoming = true,
                                FromAddress = 'Receiver1@test1.it',
                                ParentID=TestCaseList[0].id
                                )
                    };
                        insert EmailMessageList;
            /*EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/

            PageReference pageRef = Page.VFP14_SendEmailView;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',TestCaseList[0].id);            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestCaseList[0]);
            VFC14_SendEmailView RuleCreation = new VFC14_SendEmailView(sc);            
              
            test.stoptest();
        }
    }

    static testMethod void SendEmail2()
    {

        system.runAs(userAdmin)
        {
            test.starttest();
            TestAccountList = new list<Account>
            {
                new Account(Additional_Email__c='Account2_Individual@test.it',
                           FirstName='Account2',
                           LastName='Individual',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                           )
                    };
            insert TestAccountList;
            Id AgentId =[select Id from Account where PersonEmail='Agent@test.it'].Id;
            
            TestCaseList = new list<Case>
            {
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[0].id
                        )};
            insert TestCaseList;
            EmailMessageList = new list<EmailMessage> 
            {
                new EmailMessage(Subject ='Test Incoming1',
                                Status ='1',
                                TextBody= 'Messaggio test 1',
                                MessageDate= Date.today()-1,
                                Incoming = true,
                                FromAddress = 'Receiver1@test1.it',
                                ParentID=TestCaseList[0].id
                                )
                    };
                        insert EmailMessageList;
            /*EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/
            PageReference pageRef = Page.VFP14_SendEmailView;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',TestCaseList[0].id);            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestCaseList[0]);
            VFC14_SendEmailView RuleCreation = new VFC14_SendEmailView(sc);            
  
            test.stoptest();
        }
    }
    
    static testMethod void SendEmail3()
    {

        system.runAs(userAdmin)
        {
            test.starttest();
            TestAccountList = new list<Account>
            {
                new Account(Account_email__c='Account3_Corporate@test.it',
                           Name='Account3 Corporate',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccCorporateClient)
                           )
                    };
            insert TestAccountList;
            Id AgentId =[select Id from Account where PersonEmail='Agent@test.it'].Id;
            
            TestCaseList = new list<Case>
            {
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[0].id
                        )};
            insert TestCaseList;
            EmailMessageList = new list<EmailMessage> 
            {
                new EmailMessage(Subject ='Test Incoming1',
                                Status ='1',
                                TextBody= 'Messaggio test 1',
                                MessageDate= Date.today()-1,
                                Incoming = true,
                                FromAddress = 'Receiver1@test1.it',
                                ParentID=TestCaseList[0].id
                                )
                    };
                        insert EmailMessageList;
            /*EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/
            PageReference pageRef = Page.VFP14_SendEmailView;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',TestCaseList[0].id);            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestCaseList[0]);
            VFC14_SendEmailView RuleCreation = new VFC14_SendEmailView(sc);            
  
            test.stoptest();
        }
    } 
    
    static testMethod void SendEmail4()
    {

        system.runAs(userAdmin)
        {
            test.starttest();

            Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
            id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');

            Account agency = new Account(
                          RecordTypeId = account_agency,
                          Agency_Code__c = '999999',
                          Active__c = true,
                          Accordo_Digitale__c = true,
                          Name = 'AGENZIA PROVA'
                          );  

            insert agency;
            Id agencyId = agency.id;
            TestAccountList = new list<Account>
            {
                new Account(Subject_email__c='Account4_B2B@test.it',
                           Name='Account4 B2B',
                           AAI_Agency__c = agencyId,
                            AAI_Agency_Reference_Code__c='00898',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2B)
                           )
                    };
            insert TestAccountList;
            
            TestCaseList = new list<Case>
            {
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[0].id
                        )};
            insert TestCaseList;
            EmailMessageList = new list<EmailMessage> 
            {
               new EmailMessage(Subject ='Test Outbound1',
                                Status ='2',
                                TextBody= 'Messaggio test 2',
                                MessageDate= Date.today(),
                                Incoming = false,
                                FromAddress = 'Sender1@test2.it',
                                ParentID=TestCaseList[0].id
                                )
                    };
                        insert EmailMessageList;
            /*EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/
            PageReference pageRef = Page.VFP14_SendEmailView;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',TestCaseList[0].id);            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestCaseList[0]);
            VFC14_SendEmailView RuleCreation = new VFC14_SendEmailView(sc);            
  
            test.stoptest();
        }
    } 
    
    static testMethod void SendEmail5()
    {

        system.runAs(userAdmin)
        {
            test.starttest();
            Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
            id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');

            Account agency = new Account(
                          RecordTypeId = account_agency,
                          Agency_Code__c = '999999',
                          Active__c = true,
                          Accordo_Digitale__c = true,
                          Name = 'AGENZIA PROVA'
                          );  

            insert agency;
            Id agencyId = agency.id;
            TestAccountList = new list<Account>
            {
                new Account(CIF_PersonEmail__c='Account5_B2C@test.it',
                           FirstName='Account5',
                           LastName='B2C',
                           AAI_Agency__c = agencyId,
                            AAI_Agency_Reference_Code__c='00898',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C)
                           )
                    };
            insert TestAccountList;
            
            TestCaseList = new list<Case>
            {
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[0].id
                        )};
            insert TestCaseList;
            EmailMessageList = new list<EmailMessage> 
            {
               new EmailMessage(Subject ='Test Outbound1',
                                Status ='2',
                                TextBody= 'Messaggio test 2',
                                MessageDate= Date.today(),
                                Incoming = false,
                                FromAddress = 'Sender1@test2.it',
                                ParentID=TestCaseList[0].id
                                )
                    };
                        insert EmailMessageList;
            /*EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/
            PageReference pageRef = Page.VFP14_SendEmailView;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',TestCaseList[0].id);            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestCaseList[0]);
            VFC14_SendEmailView RuleCreation = new VFC14_SendEmailView(sc);            
  
            test.stoptest();
        }
    }
    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
  static testmethod void SendEmail6()
    {

        system.runAs(userAdmin)
        {
            test.starttest();
            TestAccountList = new list<Account>
            {
                new Account(PersonEmail='Account1_Individual@test.it',
                           FirstName='Account1',
                           LastName='Individual',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                           )
                    };
            insert TestAccountList;
            Id AgentId =[select Id from Account where PersonEmail='Agent@test.it'].Id;
            
            TestCaseList = new list<Case>
            {
                new Case(Complainant__c='Customer',
                         SuppliedEmail='testCase1@test.it',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[0].id,
                         AgentName__c = AgentId
                        )};
            insert TestCaseList;
            EmailMessageList = new list<EmailMessage> 
            {
                new EmailMessage(Subject ='Test Outbound1',
                                Status ='2',
                                TextBody= 'Test Outbound1 Test Outbound1 Test Outbound1 Test Outbound1Test Outbound1 Test Outbound1 Test Outbound1 Test Outbound1',
                                MessageDate= Date.today(),
                                Incoming = false,
                                FromAddress = 'Sender1@test2.it',
                                ParentID=TestCaseList[0].id
                                )
                    };
                        insert EmailMessageList;
            /*EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/
            PageReference pageRef = Page.VFP14_SendEmailView;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',TestCaseList[0].id);            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestCaseList[0]);
            VFC14_SendEmailView RuleCreation = new VFC14_SendEmailView(sc);

      RuleCreation.ExternalProviderType = 'MyFox';
            RuleCreation.getExternalProviderInfo();                     
  
            test.stoptest();
        }
    }
    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END 
    static testMethod void SendEmail7()
    {

        system.runAs(userAdmin)
        {
            test.starttest();
            Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
            id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
            TestAccountList = new list<Account>
            {
                new Account(Claim_PersonalEmail__c='Account6_Individual@test.it',
                           FirstName='Account6',
                           LastName='Individual',
                           RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient)
                           ) 
                    };
            insert TestAccountList;
            Id AgentId =[select Id from Account where PersonEmail='Agent@test.it'].Id;
            
            TestCaseList = new list<Case>
            {
                new Case(Complainant__c='Customer',
                         SuppliedEmail='',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),
                         AccountId=TestAccountList[0].id
                        ) };
            insert TestCaseList;
            EmailMessageList = new list<EmailMessage> 
            {
                new EmailMessage(Subject ='Test Incoming1',
                                Status ='1',
                                TextBody= 'Messaggio test 1',
                                MessageDate= Date.today()-1,
                                Incoming = true,
                                FromAddress = 'Receiver1@test1.it',
                                ParentID=TestCaseList[0].id
                                )
                    };
                        insert EmailMessageList;
            /*EmailAttachment = new Attachment(ParentId=EmailMessageList[0].id,
                                            Name='Attachment1',
                                            Body=Blob.valueof('Body'));
            
            insert EmailAttachment;*/
            PageReference pageRef = Page.VFP14_SendEmailView;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',TestCaseList[0].id);            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(TestCaseList[0]);
            VFC14_SendEmailView RuleCreation = new VFC14_SendEmailView(sc);            
  
            test.stoptest();
        }
    }
    
}