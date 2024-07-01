@isTest
private class VFC08_CaseFindAssociatedAccount_TEST {
/*
----------------------------------------------------------------------------------------------------
-- - Name          : VFC08_CaseFindAssociatedAccount_TEST
-- - Author        :    
-- - Description   : Test Methods for VFC08_CaseFindAssociatedAccount
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------------------------------------
-- 27-02-2015   YRA     1.0     
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/
    static user userAdmin;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static list <Account> accList;
    static list <Case> caseList;
    static list <Task> taskList;
    
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
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;

            //account
            accList = new list<Account>{
                new Account(FirstName ='John',
                            LastName= 'Smith',
                            PersonEmail = 'john.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary),
                            Fiscal_ID__c = '5645',
                            Matricola__c='1253',
                            PersonBirthdate = date.today()
                ),
                new Account(FirstName ='Jane',
                            LastName= 'Smith',
                            PersonEmail = 'jane.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                            Matricola__c='123',
                            Fiscal_ID__c = '56',
                            PersonBirthdate = date.today()
                ),
                new Account(
                    Name='YRA',
                    Partita_IVA__c='23',
                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccCorporateClient)
                ),
                //SPINELLI_F 04022016: EVO-18----START
                new Account(FirstName ='JohnAxa',
                            LastName= 'Smith',
                            PersonEmail = 'johnaxa.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C),
                            AAI_Codice_fiscale__c = '56451',
                            PersonBirthdate = date.today()
                ),
                
                new Account(
                    Name='YROaxa',
                    AAI_Partita_IVA__c='2322',
                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2B)
                )
                
                //SPINELLI_F 04022016: EVO-18----END
            };
                
            insert accList;

            id idAccount = [Select Id from Account where PersonEmail = 'john.smith@axa-italy-devtest.com'].Id;
         
            //case
            caseList = new list <Case>{
                new Case(
                    Status = 'Assigned',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                    AgentId__c='123',
                    SuppliedEmail='navin.appadoo@gmail.com'),
                new Case(
                    Status = 'Assigned',
                    SuppliedEmail='navin1.appadoo@gmail.com',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                    AccountId= accList[1].Id
                ),
                new Case(
                    Status = 'Assigned',
                    SuppliedEmail='navin2.appadoo@gmail.com',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor)
                ),
                //SPINELLI_F 04022016: EVO-18----START
                 new Case(
                    Status = 'Assigned',
                    SuppliedEmail='navin3.appadoo@gmail.com',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI)
                    
                )
                //SPINELLI_F 04022016: EVO-18----END
            };
            insert caseList;
        }
    }
    
    static testMethod void associateAcc_Agent_Scenario1_Test() {
        system.debug('#### Start of method associateAcc_Agent_Scenario1_Test');
         system.runAs(userAdmin){
            test.starttest(); 

               //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
               Id [] fixedSearchResults= new Id[1];
               fixedSearchResults[0] = accList[1].Id;
               Test.setFixedSearchResults(fixedSearchResults);                        
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END

                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[0]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.FirstName = 'J';
                caseFind.customer.LastName = 'smith';
                caseFind.customer.Fiscal_ID__c = '56';
                caseFind.customer.PersonBirthdate = date.today();
                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[0].Id];
            system.assertEquals(accList[1].Id,caseAsrtList[0].AccountId);
            
            list<Account> accAsrtList = [Select Id,personemail 
                                        From Account 
                                        Where Id=:caseAsrtList[0].AccountId];
            //system.assertEquals(caseList[0].SuppliedEmail,accAsrtList[0].personemail);
         }
    }
   
    static testMethod void associateAcc_Corporate_Scenario2_Test() {
        system.debug('#### Start of method associateAcc_Corporate_Scenario2_Test');
         system.runAs(userAdmin){
            test.starttest();

               //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
               Id [] fixedSearchResults= new Id[1];
               fixedSearchResults[0] = accList[2].Id;
               Test.setFixedSearchResults(fixedSearchResults);                        
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END            
           
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[1].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[1]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.Name = 'Y';
                caseFind.customer.Partita_IVA__c='23';

                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[1].Id];
            system.assertEquals(accList[2].Id,caseAsrtList[0].AccountId);
            
            list<Account> accAsrtList = [Select Id,Account_Email__c 
                                        From Account 
                                        Where Id=:caseAsrtList[0].AccountId];
            //system.assertEquals(caseList[1].SuppliedEmail,accAsrtList[0].Account_Email__c);
         }
    }
    
    static testMethod void associateAgent_NewCustomer_Scenario3_Test() {
        system.debug('#### Start of method associateAgent_NewCustomer_Scenario3_Test');
         system.runAs(userAdmin){
            test.starttest();
               //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
               Id [] fixedSearchResults= new Id[1];
               fixedSearchResults[0] = accList[0].Id;
               Test.setFixedSearchResults(fixedSearchResults);                        
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[2].Id);
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[2]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.Matricola__c='1253';
                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId,AgentName__c
                                        From Case 
                                        Where Id =:caseList[2].Id];
            system.assertEquals(accList[0].Id,caseAsrtList[0].AccountId);
            system.assertEquals(accList[0].Id,caseAsrtList[0].AgentName__c);
         }
    }
    
    static testMethod void associateAcc_SearchError_Scenario4_Test() {
        system.debug('#### Start of method associateAcc_SearchError_Scenario4_Test');
         system.runAs(userAdmin){
            test.starttest();       
                
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[0]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.FirstName = '';
                caseFind.customer.LastName = '';
                caseFind.customer.Fiscal_ID__c = '';
                caseFind.customer.PersonBirthdate = null;
                caseFind.customer.Name ='';
                caseFind.customer.Partita_IVA__c = '';
                caseFind.searchCustomer();
            test.stoptest();
            
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            system.debug('msgs1:'+msgs);
            boolean b = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains(system.label.VFP08_FillSearch)) b = true;
            }
            system.assertEquals(true,b);
         }
    }   
    
    static testMethod void associateAcc_BirthDateError_Scenario5_Test() {
        system.debug('#### Start of method associateAcc_BirthDateError_Scenario5_Test');
         system.runAs(userAdmin){
            test.starttest();           
             
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[0]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.FirstName = 'J';
                caseFind.customer.PersonBirthdate = date.today()+1;
                caseFind.searchCustomer();
            test.stoptest();
            
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            system.debug('msgs2:'+msgs);
            boolean b = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains(system.label.VFP08_BirthDate)) b = true;
            }
            system.assertEquals(true,b);
         }
    }
  
    static testMethod void associateAcc_NewCustomer_Scenario6_Test() {
        system.debug('#### Start of method associateAcc_NewCustomer_Scenario6_Test');
         system.runAs(userAdmin){
            test.starttest();
      
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[0]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.FirstName = 'J';
                caseFind.searchCustomer();
                
                //Create new acc
                caseFind.newCustomer();
                caseFind.selectedCustomer.LastName = 'Vegas';
                caseFind.saveCustomer();
                
            test.stoptest();
            
            list<Account> accAsrtList = [Select Id,LastName,FirstName,recordtype.Name
                                        From Account 
                                        Where LastName='Vegas' and FirstName='J' Limit 1];
            system.debug('accAsrtList:'+accAsrtList);
            system.assertEquals(true,accAsrtList.size()>0);
            
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[0].Id];
            system.assertEquals(accAsrtList[0].Id,caseAsrtList[0].AccountId);
            
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            system.debug('msgs3:'+msgs);
            boolean b = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains(system.label.VFP08_Successful)) b = true;
            }
            system.assertEquals(true,b);
         }
    }
        
    static testMethod void associateAcc_NewCustomer_Scenario7_Test() {
        system.debug('#### Start of method associateAcc_NewCustomerCorporate_Scenario7_Test');
         system.runAs(userAdmin){
          test.starttest();              
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[0]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.Name = 'YRA';
                caseFind.customer.Partita_IVA__c='2236';
                caseFind.searchCustomer();
                
                //Create new acc
                caseFind.newCustomer();
                caseFind.saveCustomer();
                
            test.stoptest();
            
            list<Account> accAsrtList = [Select Id,Name,Fiscal_ID__c,Partita_IVA__c,recordtype.Name
                                        From Account 
                                        Where Name='YRA' and Partita_IVA__c='2236' Limit 1];
            system.debug('accAsrtListC:'+accAsrtList);
            system.debug('accAsrtListC:'+accAsrtList[0].Fiscal_ID__c);
            system.assertEquals(true,accAsrtList.size()>0);
            system.assertEquals(accAsrtList[0].Partita_IVA__c,accAsrtList[0].Fiscal_ID__c);
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[0].Id];
            system.assertEquals(accAsrtList[0].Id,caseAsrtList[0].AccountId);
            
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            system.debug('msgs4:'+msgs);
            boolean b = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains(system.label.VFP08_Successful)) b = true;
            }
            system.assertEquals(true,b);
         }
    }
    
    static testMethod void associateAgent_NewCustomer_Scenario8_Test() {
        system.debug('#### Start of method associateAgent_NewCustomer_Scenario8_Test');
         system.runAs(userAdmin){
            test.starttest();
  
                         
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[0]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.FirstName = 'YRA';
                caseFind.customer.LastName='Ram';
                caseFind.customer.Matricola__c='789';
                caseFind.searchCustomer();
                
                //Create new acc
                caseFind.newCustomer();
                caseFind.saveCustomer();
                
            test.stoptest();
            
            list<Account> accAsrtList = [Select Id,Name,Fiscal_ID__c,Partita_IVA__c,recordtype.Name
                                        From Account 
                                        Where FirstName='YRA' and LastName='Ram' and Matricola__c='789' Limit 1];
            system.debug('accAsrtListC:'+accAsrtList);
            system.assertEquals(true,accAsrtList.size()>0);
            
            list <Case> caseAsrtList = [Select Id,AccountId,AgentName__c
                                        From Case 
                                        Where Id =:caseList[0].Id];
            system.assertEquals(accAsrtList[0].Id,caseAsrtList[0].AgentName__c);
            system.assertEquals(accAsrtList[0].Id,caseAsrtList[0].AccountId);
            
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            system.debug('msgs5:'+msgs);
            boolean b = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains(system.label.VFP08_Successful)) b = true;
            }
            system.assertEquals(true,b);
         }
    }
    
    //SPINELLI_F 04022016: EVO-18----START
    static testMethod void associateAcc_Agent_Scenario9_Test() {
        system.debug('#### Start of method associateAcc_Agent_Scenario9_Test');
         system.runAs(userAdmin){
            test.starttest();
               //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
               Id [] fixedSearchResults= new Id[1];
               fixedSearchResults[0] = accList[1].Id;
               Test.setFixedSearchResults(fixedSearchResults);                        
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
 
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[3].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[3]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.FirstName = 'Ja';
                caseFind.customer.LastName = 'smith';
                caseFind.customer.Fiscal_ID__c = '56';
                //caseFind.customer.PersonBirthdate = date.today();
                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[3].Id];
            system.assertEquals(accList[1].Id,caseAsrtList[0].AccountId);
            
           // list<Account> accAsrtList = [Select Id,personemail 
             //                           From Account 
               //                         Where Id=:caseAsrtList[0].AccountId];
            //system.assertEquals(caseList[0].SuppliedEmail,accAsrtList[0].personemail);
         }
    }
   
      static testMethod void associateAcc_Agent_Scenario10_Test() {
        system.debug('#### Start of method associateAcc_Agent_Scenario9_Test');
         system.runAs(userAdmin){
            test.starttest();
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
               Id [] fixedSearchResults= new Id[1];
               fixedSearchResults[0] = accList[3].Id;
               Test.setFixedSearchResults(fixedSearchResults);                        
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[3].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[3]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.FirstName = 'Jo';
                caseFind.customer.LastName = 'smith';
                //caseFind.customer.PersonBirthdate = date.today();
                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[3].Id];
            system.assertEquals(accList[3].Id,caseAsrtList[0].AccountId);
            
           // list<Account> accAsrtList = [Select Id,personemail 
             //                           From Account 
               //                         Where Id=:caseAsrtList[0].AccountId];
            //system.assertEquals(caseList[0].SuppliedEmail,accAsrtList[0].personemail);
         }
    }
   
    static testMethod void associateAcc_Corporate_Scenario11_Test() {
        system.debug('#### Start of method associateAcc_Corporate_Scenario2_Test');
         system.runAs(userAdmin){
            test.starttest();  
               //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
               Id [] fixedSearchResults= new Id[1];
               fixedSearchResults[0] = accList[2].Id;
               Test.setFixedSearchResults(fixedSearchResults);                        
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END           
           
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[3].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[3]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.Name = 'YRA';
                caseFind.customer.Partita_IVA__c='23';

                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[3].Id];
            system.assertEquals(accList[2].Id,caseAsrtList[0].AccountId);
            
            list<Account> accAsrtList = [Select Id,Account_Email__c 
                                        From Account 
                                        Where Id=:caseAsrtList[0].AccountId];
            //system.assertEquals(caseList[1].SuppliedEmail,accAsrtList[0].Account_Email__c);
         }
    }
    
    static testMethod void associateAcc_Corporate_Scenario12_Test() {
        system.debug('#### Start of method associateAcc_Corporate_Scenario2_Test');
         system.runAs(userAdmin){
            test.starttest();
               //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
               Id [] fixedSearchResults= new Id[1];
               fixedSearchResults[0] = accList[4].Id;
               Test.setFixedSearchResults(fixedSearchResults);                        
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END             
           
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[3].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[3]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.Name = 'YRO';
                
                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[3].Id];
            system.assertEquals(accList[4].Id,caseAsrtList[0].AccountId);
            
            list<Account> accAsrtList = [Select Id,Account_Email__c 
                                        From Account 
                                        Where Id=:caseAsrtList[0].AccountId];
            //system.assertEquals(caseList[1].SuppliedEmail,accAsrtList[0].Account_Email__c);
         }
    }
    
    static testMethod void associateAcc_Corporate_Scenario13_Test() {
        system.debug('#### Start of method associateAcc_Corporate_Scenario2_Test');
         system.runAs(userAdmin){
            test.starttest();
                
           
                PageReference pageRef = Page.VFP08_CaseFindAssociatedAccount;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('id',caseList[0].Id);
                ApexPages.currentPage().getParameters().put('type', 'Customer');
      
                ApexPages.StandardController sc = new ApexPages.StandardController(caseList[3]);
                VFC08_CaseFindAssociatedAccount caseFind = new VFC08_CaseFindAssociatedAccount(sc);
                
                //search accs
                caseFind.customer.Name = 'YRO';
                
                caseFind.searchCustomer();
                
                //update case with acc found
                caseFind.selectedCustomerVal = 0;
                caseFind.asociateCustomerToCase();
            test.stoptest();
            
            list <Case> caseAsrtList = [Select Id,AccountId
                                        From Case 
                                        Where Id =:caseList[0].Id];
            system.assertEquals(null,caseAsrtList[0].AccountId);
            
            list<Account> accAsrtList = [Select Id,Account_Email__c 
                                        From Account 
                                        Where Id=:caseAsrtList[0].AccountId];
            //system.assertEquals(caseList[1].SuppliedEmail,accAsrtList[0].Account_Email__c);
         }
    }    
     //SPINELLI_F 04022016: EVO-18-----END
}