/** 
* @author YRA
* @description Test Methods for VFC06_ClientCallProcessing
* @date 25-02-2015
* Maintenance History: 14-04-2023 pmd fix
*/
@isTest
private class VFC06_ClientCallProcessing_TEST {

    static user userAdmin;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static list <Account> accList;
    static list <Case> caseList;
    static list<InsurancePolicy__c> insuranceList;
    static user userAdmin_2;//MOSCATELLI_M 13062016:EVO 62
    static user userAAIVenditeAvanzato;//OAVERSANO 04/07/2018: Close The Loop ICF
    static CaseRTtoTaskRT__c CrtTtask;

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

        //MOSCATELLI_M 13062016:EVO 62 -- START
        userAdmin_2 = new User(Username = 'testclassAP02@test.com',
                               LastName = 'testuser',
                               LanguageLocaleKey = 'en_US',
                               FirstName = 'test',
                               Email = 'test2@test2.com',
                               Alias = 'test2',
                               TimeZoneSidKey = 'Europe/Dublin',
                               LocaleSidKey = 'en_US',
                               EmailEncodingKey = 'UTF-8',
                               ProfileId = AP_Constants.getProfileAdminId()
                              );

        insert userAdmin_2;
        //MOSCATELLI_M 13062016:EVO 62 -- END

        //OAVERSANO 04/07/2018: Close The Loop ICF -- START
        acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        Account accTest = new Account(Name='nomeAccount', Agency_Code__c='003900',Recordtypeid= acc_developerIdMap.get('Agency'),Active__c=true);
        insert accTest;
        Contact conTest = new Contact(LastName='lastNameCon',
                                      AccountId = accTest.Id,
                                      MobilePhone ='003911223344',
                                      Phone = '003911223344');
        insert conTest;
        userAAIVenditeAvanzato = new User(Username = 'testclassAP06Vendite@test.com',
                                          LastName = 'testuserVendite',
                                          LanguageLocaleKey = 'en_US',
                                          FirstName = 'test',
                                          Email = 'test@testVendite.com',
                                          Alias = 'tvend',
                                          TimeZoneSidKey = 'Europe/Dublin',
                                          MobilePhone = '003911223344',
                                          Phone = '003911223344',
                                          LocaleSidKey = 'en_US',
                                          EmailEncodingKey = 'UTF-8',
                                          ContactId = conTest.Id,
                                          ProfileId = AP_Constants.getProfileIdAAIVenditeAvanzato());
        insert userAAIVenditeAvanzato;
        //OAVERSANO 04/07/2018: Close The Loop ICF -- END

        system.runas(userAdmin){
            //acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
            // AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            //insert acv;                       

            //account
            accList = new list<Account>{
                new Account(FirstName ='John',
                            LastName= 'Smith',
                            PersonMobilePhone = '05849999991',
                            PersonEmail = 'john.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary)
                           ),
                    new Account(FirstName ='Jane',
                                LastName= 'Smith',
                                PersonEmail = 'jane.smith@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Matricola__c='123',
                                personBirthDate = date.today()
                               ),
                    new Account(FirstName ='yud',
                                LastName= 'ram',
                                PersonEmail = 'yud.ram@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Matricola__c='1236',
                                personBirthDate = date.today()
                               ),
                    //MOSCATELLI_M 02022016: EVO-18-----START
                    new Account(FirstName ='Test',
                                LastName= 'AAIB2C',
                                PersonEmail = 'test.aaib2c@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C),
                                AAI_Codice_fiscale__c='4578',
                                Servizio__c ='MPS One',
                                Phone='0112344532424',
                                AAI_Agency_Reference_Code__c='00789',
                                personBirthDate = date.today()
                               ),
                    new Account(Name ='TestCompanyAAI',
                                Subject_email__c = 'TestCompanyAAI@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2B),
                                AAI_Partita_IVA__c='91011',
                                Servizio__c ='MPS One',
                                AAI_Agency_Reference_Code__c='00789',
                                Phone = '21321314'
                               ),
                    new Account(FirstName ='Test',
                                LastName= 'MPSIndividual',
                                PersonEmail = 'test.mpsindividual@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Fiscal_ID__c='121314',
                                Servizio__c ='MPS One',
                                PersonMobilePhone='01123445',
                                personBirthDate = date.today()
                               ),
                    new Account(Name ='TestCompanyMPS',
                                Account_email__c = 'TestCompanyMPS@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccCorporateClient),
                                Partita_IVA__c='1415116',
                                Servizio__c ='MPS One',
                                Phone = '3534643636'
                               ),
                    //MOSCATELLI_M 07072016:EVO 62 -- START
                    new Account(FirstName ='James',
                                LastName= 'Smith',
                                PersonMobilePhone = '05849999992',
                                PersonEmail = 'James.smith@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary)
                               ),
                    new Account(FirstName ='Jhonny',
                                LastName= 'Smith',
                                PersonMobilePhone = '05849999992',
                                PersonEmail = 'Jhonny.smith@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary)
                               ),
                    new Account(FirstName ='Anne',
                                LastName= 'Smith',
                                Phone = '003905849999992',
                                PersonEmail = 'Anne.smith@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary)
                               ),
                    //OAVERSANO 05/12/2018 : Caring Angel -- START
                    new Account(FirstName ='aggiornamento',
                                LastName= 'gestori',
                                Phone = '00390584999999222',
                                Matricola__c='98765',
                                PersonEmail = 'aggiornamento.gestori@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary)
                               )
                    //OAVERSANO 05/12/2018 : Caring Angel -- END
                    //MOSCATELLI_M 07072016:EVO 62 -- END                                                  
                    //MOSCATELLI_M 02022016: EVO-18-----END
                    };

                        insert accList;


            //insurance
            insuranceList = new list<InsurancePolicy__c>{
                new InsurancePolicy__c(CUID__c=accList[1].Id,Name='123'),
                    new InsurancePolicy__c(CUID__c=accList[2].Id,Name='12345'),
                    //MOSCATELLI_M 02022016: EVO-18-----START
                    new InsurancePolicy__c(CUID__c=accList[3].Id,Name='678'),
                    new InsurancePolicy__c(CUID__c=accList[4].Id,Name='91011'),
                    new InsurancePolicy__c(CUID__c=accList[5].Id,Name='121314'),
                    new InsurancePolicy__c(CUID__c=accList[6].Id,Name='151617')
                    //MOSCATELLI_M 02022016: EVO-18-----END
                    };
                        insert insuranceList;

            //case
            caseList = new list <Case>{
                new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[0].Id,AgentId__c='123'),
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[0].Id),
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[0].Id),
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[2].Id),
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[2].Id),
                    //MOSCATELLI_M 13062016:EVO 62 -- START
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),Phone_Call_Ids__c='567'),
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),OwnerId=userAdmin_2.Id),
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[2].Id,OwnerId=userAdmin_2.Id),
                    new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[8].Id,OwnerId=userAdmin_2.Id,AgentName__c=accList[8].Id),
                    //MOSCATELLI_M 13062016:EVO 62 -- END
                    //OAVERSANO 05/12/2018 : Caring Angel -- START
                    new Case(Status = AP_Constants.caseStatusAssILivello,RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseCaringAngel),AccountId= accList[8].Id)
                    //OAVERSANO 05/12/2018 : Caring Angel -- END
                    };
                        insert caseList;

                    CrtTtask = new CaseRTtoTaskRT__c (Name='Motor',Task_RT_developername__c='Motor_Task');
                    insert CrtTtask;
        }//end run as        
    }

     static testMethod void CreateGestore_NewAccTest() {
        system.debug('#### Start of method CreateGestore_NewAccTest');
        system.runAs(userAdmin){
            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            AAI_Code_Variables__c acv1 = new AAI_Code_Variables__c(Name='VFC06_ContactCenterNumbers', Value__c='0584999999');
            insert acv1;

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '0584999999');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '502887');
            ApexPages.currentPage().getParameters().put('agentemail', 'marco.falugi@mps.it');
            ApexPages.currentPage().getParameters().put('Distribution', 'MPS');//MOSCATELLI_M 07072016:EVO 62

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();

            ccProcess.setAgentPhone();
            ccProcess.getNoOfCasesFromList();
            ccProcess.getNoOfCases();
            ccProcess.policyNumber='123';
            ccProcess.searchFirstName='Jane';
            ccProcess.searchLastName='Smith';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.loadPolicyClients();
            ccProcess.clientPolicyNumber = 'Test1';
            ccProcess.createClientForNewCase();
            test.stoptest();

            list <Account> accAsrtList = [Select Id,PersonEmail,Name
                                          From Account where Name ='Marco Falugi' ];
            system.debug('accAsrtList'+accAsrtList);
            system.assertEquals(true,accAsrtList.size()>0);
        }//end run as
    }

    static testMethod void LoadGestore_AccTest() {
        system.debug('#### Start of method LoadGestore_AccTest');
        system.runAs(userAdmin){
            test.starttest();

            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            AAI_Code_Variables__c acv1 = new AAI_Code_Variables__c(Name='VFC06_ContactCenterNumbers', Value__c='1234;5678');
            insert acv1;

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '0584999999');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Distribution', 'MPS');//MOSCATELLI_M 07072016:EVO 62

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.searchFirstName='yud';
            ccProcess.searchLastName='ram';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.loadPolicyClients();
            ccProcess.selectedClientId = accList[2].Id;
            ccProcess.updateclient();
            ccProcess.loadCases();
            ccProcess.loadPolicyClientCase();
            //MOSCATELLI_M 27/07/2016: EVO 65 -- START
            ccProcess.CreateLightCase();
            //MOSCATELLI_M 27/07/2016: EVO 65 -- END
            test.stoptest();
        }//end run as
    }

    static testMethod void LoadGestore_Acc1Test() {
        system.debug('#### Start of method LoadGestore_AccTest');
        system.runAs(userAdmin){
            test.starttest();

            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '0584999999');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Distribution', 'MPS');//MOSCATELLI_M 07072016:EVO 62

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.searchFiscalId='ram';
            ccProcess.loadPolicyClients();
            ccProcess.policyNumber = '21343';
            ccProcess.loadPolicyClients();
            test.stoptest();
        }//end run as
    }

    static testMethod void Loadcliente_AccTest() {
        system.debug('#### Start of method Loadcliente_AccTest');
        system.runAs(userAdmin){
            test.starttest();

            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();

            System.assertEquals(ccProcess != null, true,'VFC06_ClientCallProcessing vfp deve essere creata');

            test.stoptest();
        }//end run as
    }

    static testMethod void Loadcliente_Acc1Test() {
        system.debug('#### Start of method Loadcliente_AccTest');
        system.runAs(userAdmin){
            test.starttest();

            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.isPerson = true;
            ccProcess.selectedClientId = accList[0].id;
            ccProcess.updateclient();
            ccProcess.isPerson = false;
            ccProcess.selectedClientId = accList[0].id;
            ccProcess.updateclient();
            test.stoptest();
        }//end run as
    }

    static testMethod void LoadclienteV2_AccTest() {
        system.debug('#### Start of method LoadclienteV2_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='yud';
            ccProcess.searchLastName='ram';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }

    //MOSCATELLI_M 02022016: EVO-18-----START
    static testMethod void LoadclienteV3_AccTest() {
        system.debug('#### Start of method LoadclienteV3_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','MPSIndividual');
            ApexPages.currentPage().getParameters().put('Custemail','test.mpsindividual@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','121314');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='MPSIndividual';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.searchFiscalId='121314';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV4_AccTest() {
        system.debug('#### Start of method LoadclienteV4_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '0');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','MPSIndividual');
            ApexPages.currentPage().getParameters().put('Custemail','test.mpsindividual@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','121314');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='MPSIndividual';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.searchFiscalId='121314';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV5_AccTest() {
        system.debug('#### Start of method LoadclienteV5_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','AAIB2C');
            ApexPages.currentPage().getParameters().put('Custemail','test.aaib2c@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','4578');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='AAIB2C';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.searchFiscalId='4578';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV6_AccTest() {
        system.debug('#### Start of method LoadclienteV6_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '01123445');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','MPSIndividual');
            ApexPages.currentPage().getParameters().put('Custemail','test.mpsindividual@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','121314');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='MPSIndividual';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.searchFiscalId='121314';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV7_AccTest() {
        system.debug('#### Start of method LoadclienteV7_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '0112344532424');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','AAIB2C');
            ApexPages.currentPage().getParameters().put('Custemail','test.aaib2c@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','4578');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='AAIB2C';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.searchFiscalId='4578';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }

    static testMethod void LoadclienteV8_AccTest() {
        system.debug('#### Start of method LoadclienteV8_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '3534643636');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyMPS@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','1415116');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyMPS');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV9_AccTest() {
        system.debug('#### Start of method LoadclienteV9_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '21321314');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyAAI@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','91011');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyAAI');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.enabCustChng=true;
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyAAI';
            ccProcess.searchPartitaIVA='91011';
            ccProcess.policyNumber='91011';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV10_AccTest() {
        system.debug('#### Start of method LoadclienteV10_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '21321314');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyAAI@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','91011');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyAAI');
            ApexPages.currentPage().getParameters().put('Custservice','');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyAAI';
            ccProcess.searchPartitaIVA='91011';
            ccProcess.policyNumber='91011';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV11_AccTest() {
        system.debug('#### Start of method LoadclienteV11_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '3534643636');
            ApexPages.currentPage().getParameters().put('category', '');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyMPS@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','1415116');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyMPS');
            ApexPages.currentPage().getParameters().put('Custservice','');
            ApexPages.currentPage().getParameters().put('PhonecallID','123');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }

    static testMethod void LoadclienteV12_AccTest() {
        system.debug('#### Start of method LoadclienteV12_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','MPSIndividual');
            ApexPages.currentPage().getParameters().put('Custemail','test.mpsindividual@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','121314');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='MPSIndividual';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.policyNumber='121314';
            ccProcess.searchFiscalId='121314';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV13_AccTest() {
        system.debug('#### Start of method LoadclienteV13_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','AAIB2C');
            ApexPages.currentPage().getParameters().put('Custemail','test.aaib2c@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','4578');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='AAIB2C';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.policyNumber='678';
            ccProcess.searchFiscalId='4578';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV14_AccTest() {
        system.debug('#### Start of method LoadclienteV14_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '01123445');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','MPSIndividual');
            ApexPages.currentPage().getParameters().put('Custemail','test.mpsindividual@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','121314');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='MPSIndividual';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.policyNumber='121314';
            ccProcess.searchFiscalId='121314';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV15_AccTest() {
        system.debug('#### Start of method LoadclienteV15_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '0112344532424');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','Test');
            ApexPages.currentPage().getParameters().put('Custlastn','AAIB2C');
            ApexPages.currentPage().getParameters().put('Custemail','test.aaib2c@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','4578');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchFirstName='Test';
            ccProcess.searchLastName='AAIB2C';
            ccProcess.searchDateOfBirth=String.valueOf(date.today());
            ccProcess.policyNumber='678';
            ccProcess.searchFiscalId='4578';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }

    static testMethod void LoadclienteV16_AccTest() {
        system.debug('#### Start of method LoadclienteV16_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '3534643636');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyMPS@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','1415116');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyMPS');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV17_AccTest() {
        system.debug('#### Start of method LoadclienteV17_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '21321314');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyAAI@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','91011');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyAAI');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyAAI';
            ccProcess.searchPartitaIVA='91011';
            ccProcess.policyNumber='91011';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV18_AccTest() {
        system.debug('#### Start of method LoadclienteV18_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '21321314');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyAAI@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','91011');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyAAI');
            ApexPages.currentPage().getParameters().put('Custservice','');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyAAI';
            ccProcess.searchPartitaIVA='91011';
            ccProcess.policyNumber='91011';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    static testMethod void LoadclienteV19_AccTest() {
        system.debug('#### Start of method LoadclienteV19_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '3534643636');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyMPS@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','1415116');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyMPS');
            ApexPages.currentPage().getParameters().put('Custservice','');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.getClients();
            test.stoptest();
        }//end run as
    }
    //MOSCATELLI_M 02022016: EVO-18-----END

    //MOSCATELLI_M 13062016:EVO 62 -- START
    static testMethod void LoadclienteV20_AccTest()
    {
        system.debug('#### Start of method LoadclienteV20_AccTest');

        system.runAs(userAdmin)
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'Cliente');
            ApexPages.currentPage().getParameters().put('phone', '3534643636');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','TestCompanyMPS@axa-italy-devtest.com');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','1415116');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','MPS');
            ApexPages.currentPage().getParameters().put('Nomeazienda','TestCompanyMPS');
            ApexPages.currentPage().getParameters().put('Custservice','');

            String NumberTest = [Select CaseNumber from Case where id=:caseList[0].Id].CaseNumber;
            system.debug('##NumberTest :'+NumberTest);
            ApexPages.currentPage().getParameters().put('Casenumber',NumberTest);
            ApexPages.currentPage().getParameters().put('PhonecallID','456');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.AllowDMLforMethods();
            ccProcess.getClients();
            ccProcess.selectedCaseId=caseList[5].id;
            test.stoptest();
        }
    }
    static testMethod void LoadclienteV21_AccTest()
    {
        system.debug('#### Start of method LoadclienteV21_AccTest');

        system.runAs(userAdmin)
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'cliente');
            ApexPages.currentPage().getParameters().put('phone', '05849999991');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','');
            ApexPages.currentPage().getParameters().put('Fiscalcode','');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','');
            ApexPages.currentPage().getParameters().put('Casenumber','03422');
            ApexPages.currentPage().getParameters().put('PhonecallID','789');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.AllowDMLforMethods();
            ccProcess.getClients();
            ccProcess.selectedCaseId=caseList[0].id;
            ccProcess.AddPhoneCallId();
            test.stoptest();
        }
    }
    static testMethod void LoadclienteV22_AccTest()
    {
        system.debug('#### Start of method LoadclienteV22_AccTest');

        system.runAs(userAdmin)
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'cliente');
            ApexPages.currentPage().getParameters().put('phone', '1236');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','');
            ApexPages.currentPage().getParameters().put('Fiscalcode','4578');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            String NumberTest = [Select CaseNumber from Case where id=:caseList[5].Id].CaseNumber;
            ApexPages.currentPage().getParameters().put('Casenumber',NumberTest);
            ApexPages.currentPage().getParameters().put('PhonecallID','101112');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.AllowDMLforMethods();
            ccProcess.getClients();
            test.stoptest();
        }
    }
    static testMethod void LoadclienteV23_AccTest()
    {
        system.debug('#### Start of method LoadclienteV23_AccTest');

        system.runAs(userAdmin)
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'cliente');
            ApexPages.currentPage().getParameters().put('phone', '1236');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','');
            ApexPages.currentPage().getParameters().put('Fiscalcode','4578');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            String NumberTest = [Select CaseNumber from Case where id=:caseList[6].Id].CaseNumber;
            ApexPages.currentPage().getParameters().put('Casenumber',NumberTest);

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.AllowDMLforMethods();
            ccProcess.getClients();
            test.stoptest();
        }
    }
    static testMethod void LoadclienteV24_AccTest()
    {
        system.debug('#### Start of method LoadclienteV24_AccTest');

        system.runAs(userAdmin)
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'cliente');
            ApexPages.currentPage().getParameters().put('phone', '1236');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','');
            ApexPages.currentPage().getParameters().put('Fiscalcode','4578');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            String NumberTest = [Select CaseNumber from Case where id=:caseList[7].Id].CaseNumber;
            ApexPages.currentPage().getParameters().put('Casenumber',NumberTest);

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.AllowDMLforMethods();
            ccProcess.getClients();
            test.stoptest();
        }
    }
    static testMethod void LoadclienteV25_AccTest()
    {
        system.debug('#### Start of method LoadclienteV25_AccTest');

        system.runAs(userAdmin)
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'cliente');
            ApexPages.currentPage().getParameters().put('phone', '1236');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','');
            ApexPages.currentPage().getParameters().put('Fiscalcode','45789e535');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            String NumberTest = [Select CaseNumber from Case where id=:caseList[6].Id].CaseNumber;
            ApexPages.currentPage().getParameters().put('Casenumber',NumberTest);

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.getNoOfClients();
            ccProcess.getNoOfCases();
            ccProcess.getNoOfCasesFromList();
            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.AllowDMLforMethods();
            ccProcess.getClients();
            test.stoptest();
        }
    }
    static testMethod void LoadclienteV26_AccTest()
    {
        system.debug('#### Start of method LoadclienteV26_AccTest');

        system.runAs(userAdmin)
        {
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'cliente');
            ApexPages.currentPage().getParameters().put('phone', '1236');
            ApexPages.currentPage().getParameters().put('category', '0');
            ApexPages.currentPage().getParameters().put('subcategory', '');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Custfirstn','');
            ApexPages.currentPage().getParameters().put('Custlastn','');
            ApexPages.currentPage().getParameters().put('Custemail','');
            ApexPages.currentPage().getParameters().put('Fiscalcode','45789e535');
            ApexPages.currentPage().getParameters().put('Partitaiva','');
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('Distribution','');
            ApexPages.currentPage().getParameters().put('Nomeazienda','');
            ApexPages.currentPage().getParameters().put('Custservice','MPS One');

            String NumberTest = [Select CaseNumber from Case where id=:caseList[6].Id].CaseNumber;
            ApexPages.currentPage().getParameters().put('Casenumber',NumberTest);

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();

            ccProcess.searchName='TestCompanyMPS';
            ccProcess.searchPartitaIVA='1415116';
            ccProcess.policyNumber='151617';
            ccProcess.loadPolicyClients();
            ccProcess.AllowDMLforMethods();
            test.stoptest();
        }
    }
    //MOSCATELLI_M 13062016:EVO 62 -- END

    static testMethod void cerateCustomerTest() {
        system.debug('#### Start of method LoadclienteV2_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            test.starttest();

            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '0584999999');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.customer.FirstName = 'test';
            ccProcess.customer.FirstName = 'lastname';
            ccProcess.clientPolicyNumber = '1253426';
            ccProcess.CreateCustomer();
            ccProcess.customer.FirstName = 'test';
            ccProcess.customer.lastName = 'lastname';
            ccProcess.clientPolicyNumber = '1253426';
            ccProcess.CreateCustomer();
            ccProcess.newCaseUrl = 'test';
            ccProcess.recTypeName = 'test';
            ccProcess.getNoOfCases();
            test.stoptest();
        }//end run as
    }

    static testMethod void cerateCustomer1Test() {
        system.debug('#### Start of method LoadclienteV2_AccTest');
        //subcategory and category is blank
        system.runAs(userAdmin){
            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '0584999999');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.activeViewClientExistingCase = false;
            ccProcess.activeViewAgentExistingCase = false;
            ccProcess.getNoOfCases();
            ccProcess.activeViewAgentExistingCase = true;
            ccProcess.selectedAgentPhone = null ;
            ccProcess.selectedAgentId = accList[0].id;
            ccProcess.setAgentPhone();
            test.stoptest();
        }//end run as
    }
    //MOSCATELLI_M 13062016:EVO 62 -- START
    static testMethod void cerateCustomer2Test()
    {
        system.debug('#### Start of method cerateCustomer2Test');

        system.runAs(userAdmin)
        {
            test.starttest();

            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '0584999999');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', 'Marco');
            ApexPages.currentPage().getParameters().put('Agentlastn', 'Falugi');
            ApexPages.currentPage().getParameters().put('agentbranch', '2403');
            ApexPages.currentPage().getParameters().put('agentcode', '123');
            String NumberTest = [Select CaseNumber from Case where id=:caseList[5].Id].CaseNumber;
            ApexPages.currentPage().getParameters().put('Casenumber',NumberTest);
            ApexPages.currentPage().getParameters().put('Distribution', 'MPS');//MOSCATELLI_M 07072016:EVO 62

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.activeViewClientExistingCase = false;
            ccProcess.activeViewAgentExistingCase = false;
            ccProcess.getNoOfCases();
            ccProcess.activeViewAgentExistingCase = true;
            ccProcess.selectedAgentPhone = null ;
            ccProcess.selectedAgentId = accList[0].id;
            ccProcess.setAgentPhone();
            test.stoptest();
        }
    }
    static testMethod void MultipleAgentsCall_TEST() {
        system.debug('#### Start of method MultipleAgentsCall_TEST');
        system.runAs(userAdmin){
            test.starttest();

            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '05849999992');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Distribution', '');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.loadAgentCases();
            ccProcess.getNoOfAgents();
            ccProcess.selectedAgentId= accList[8].id;
            ccProcess.spoolAgentCases();
            //MOSCATELLI_M 27/07/2016: EVO 65 -- START
            ccProcess.CreateLightCase();
            //MOSCATELLI_M 27/07/2016: EVO 65 -- END
            test.stoptest();
        }//end run as
    }

    static testMethod void MultipleAgentsCall_TEST2() {
        system.debug('#### Start of method MultipleAgentsCall_TEST2');
        system.runAs(userAdmin){
            test.starttest();

            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            PageReference pageRef = Page.Unsubscribe;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('caller', 'gestore');
            ApexPages.currentPage().getParameters().put('phone', '003905849999992');
            ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
            ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
            ApexPages.currentPage().getParameters().put('Agentfirstn', '');
            ApexPages.currentPage().getParameters().put('Agentlastn', '');
            ApexPages.currentPage().getParameters().put('agentbranch', '');
            ApexPages.currentPage().getParameters().put('agentcode', '');
            ApexPages.currentPage().getParameters().put('Distribution', '');

            VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
            ccProcess.loadAgentCases();
            ccProcess.getNoOfAgents();
            test.stoptest();
        }//end run as
    }
    //MOSCATELLI_M 13062016:EVO 62 -- END   

    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
    static testMethod void ProvidedCases_test()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id,(select id from Tasks) from Case where Id=:caseList[3].id];
        List<Task> TskLst1 = CaseLst1[0].Tasks;

        ApexPages.currentPage().getParameters().put('CaseId', caseList[3].Id);
        ApexPages.currentPage().getParameters().put('phone', '11122017');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.searchExistingCase();

        List<Case> CaseLst2 = [select id,Phone_Call_Ids__c,(select id from Tasks) from Case where Id=:caseList[3].id];

        List<Task> TskLst2 = CaseLst2[0].Tasks;
        system.assertEquals(TskLst1.size(),0);
        system.assertEquals(TskLst2.size(),1);



        system.assertEquals(CaseLst2[0].Phone_Call_Ids__c,'7891011');

        test.stoptest();
    }

    static testMethod void UniqueB2C_test()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id,(select id from Tasks) from Case where Id=:caseList[3].id];

        ApexPages.currentPage().getParameters().put('CustomerId', accList[3].Id);
        ApexPages.currentPage().getParameters().put('phone', '0112344532424');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.closePopup();

        system.assertEquals(ccProcess.mapClients.size()>0,true);


        test.stoptest();
    }

    static testMethod void UniqueB2C_test2()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id,(select id from Tasks) from Case where Id=:caseList[3].id];

        ApexPages.currentPage().getParameters().put('phone', '0112344532424');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = accList[3].id;
        Test.setFixedSearchResults(fixedSearchResults);
        ccProcess.loadClients();
        ccProcess.closePopup();

        //system.assertEquals(ccProcess.mapClients.size()>0,true);


        test.stoptest();
    }

    static testMethod void UniqueB2C_test3()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id,(select id from Tasks) from Case where Id=:caseList[3].id];

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.searchFiscalId='4578';

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = accList[3].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.loadPolicyClients();

        test.stoptest();
    }


    static testMethod void UniqueB2B_test()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id,(select id from Tasks) from Case where Id=:caseList[3].id];

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.searchPartitaIVA='91011';

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = accList[4].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.loadPolicyClients();

        test.stoptest();
    }

    static testMethod void UniqueB2C_test4()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id,(select id from Tasks) from Case where Id=:caseList[3].id];

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.policyNumber='678';

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = insuranceList[2].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.loadPolicyClients();

        test.stoptest();
    }
    //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

    //MOSCATELLI_M 13/02/2018: Aggiornamento gestori -- START
    static testMethod void SearchAgent()
    {
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Account> AccLst = new List<Account>([Select Id from Account where PersonEmail='James.smith@axa-italy-devtest.com']);

        ApexPages.currentPage().getParameters().put('phone', '0000000000');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'gestore');
        ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');
        ApexPages.currentPage().getParameters().put('agentcode', '909832324');

        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadAgentCases();
        ccProcess.client.FirstName='James';
        ccProcess.client.lastname= 'Smith';

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = AccLst[0].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.SearchAAIAgents();

    }
    //MOSCATELLI_M 13/02/2018: Aggiornamento gestori -- END

	//OAVERSANO 04/07/2018: Close The Loop ICF -- START
    static testMethod void SearchAAIAgents_test()
    {
        List<Account> AccLst = new List<Account>([Select Id from Account where Agency_Code__c='003900']);
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('phone', '111111');
        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();
        ccProcess.searchAgencyCode = '003900';
        ccProcess.searchAgencyName = 'nomeProva';
        ccProcess.searchAgencyLastname = 'cognomeProva';
        ccProcess.searchAgentCommunityId = 'test';
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = AccLst[0].id;
        Test.setFixedSearchResults(fixedSearchResults);
        ccProcess.paramPhone = '003911223344';
        ccProcess.SearchAAIAgents();
        ccProcess.SearchAAIAgentsbyPhone();
        ccProcess.closePopup();
        test.stoptest();
    }

    static testMethod void UniqueB2C_testCallerAgent()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id,(select id from Tasks) from Case where Id=:caseList[3].id];

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'agente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Axa_Assicurazioni');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        System.assertEquals(ccProcess != null, true,'VFC06_ClientCallProcessing vfp deve essere creata');

    }
    static testMethod void SearchAAIAgents_test2()
    {
        List<Account> AccLst = new List<Account>([Select Id from Account where Agency_Code__c='003900']);
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('phone', '111111');
        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();
        ccProcess.searchAgencyCode = '';
        ccProcess.searchAgencyName = 'nomeProva';
        ccProcess.searchAgencyLastname = 'cognomeProva';
        ccProcess.searchAgentCommunityId = 'test';
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = AccLst[0].id;
        Test.setFixedSearchResults(fixedSearchResults);
        ccProcess.paramPhone = '003911223344';
        ccProcess.SearchAAIAgents();
        ccProcess.getNoOfAAIAgents();
        ccProcess.getNoOflistAAIAgentCases();
        ccProcess.searchAgencyCode = '';
        ccProcess.searchAgencyName = '';
        ccProcess.searchAgencyLastname = 'cognomeProva';
        ccProcess.searchAgentCommunityId = 'test';
        ccProcess.paramPhone = '003911223344';
        ccProcess.SearchAAIAgents();
        ccProcess.searchAgencyCode = '';
        ccProcess.searchAgencyName = '';
        ccProcess.searchAgencyLastname = '';
        ccProcess.searchAgentCommunityId = 'test';
        ccProcess.paramPhone = '003911223344';
        ccProcess.SearchAAIAgentsbyPhone();
        ccProcess.SearchAAIAgents();
        ccProcess.searchAgencyCode = '';
        ccProcess.searchAgencyName = '';
        ccProcess.searchAgencyLastname = '';
        ccProcess.searchAgentCommunityId = '';
        ccProcess.paramPhone = '';
        ccProcess.SearchAAIAgents();
        //ccProcess.SearchAAIAgentsbyPhone();
        test.stoptest();
    }
    //OAVERSANO 04/07/2018: Close The Loop ICF -- END

    //OAVERSANO 05/12/2018 : Caring Angel -- START
    static testMethod void UniqueB2C_testCaringAngel()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Caring_Angel');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.searchTarga = 'TR456TR';
        ccProcess.policyNumber = '678';
        ccProcess.searchFirstName = 'Jhonny';
        ccProcess.searchLastName = 'Smith';
        ccProcess.searchFiscalId = 'test';
        ccProcess.searchDateOfBirth = String.valueOf(system.today());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = insuranceList[2].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.loadPolicyClients();

        test.stoptest();
    }

    static testMethod void UniqueB2C_testCaringAngel2()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Caring_Angel');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.policyNumber = '678';
        ccProcess.searchFirstName = 'Jhonny';
        ccProcess.searchLastName = 'Smith';
        ccProcess.searchFiscalId = 'test';
        ccProcess.searchDateOfBirth = String.valueOf(system.today());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = insuranceList[2].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.loadPolicyClients();

        test.stoptest();
    }

    static testMethod void UniqueB2C_testCaringAngel3()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Caring_Angel');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.searchFirstName = 'Jhonny';
        ccProcess.searchLastName = 'Smith';
        ccProcess.searchFiscalId = 'test';
        ccProcess.searchDateOfBirth = String.valueOf(system.today());
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = insuranceList[2].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.loadPolicyClients();

        test.stoptest();
    }

    static testMethod void UniqueB2C_testCaringAngel4()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        List<Case> CaseLst1 = [select id, AccountId, (select id from Tasks) from Case where Status =: AP_Constants.caseStatusAssILivello];

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');
        ApexPages.currentPage().getParameters().put('RecordType','Caring_Angel');


        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();

        ccProcess.AllowDMLforMethods();
        ccProcess.loadClients();
        ccProcess.policyNumber = '678';
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = insuranceList[2].id;
        Test.setFixedSearchResults(fixedSearchResults);

        ccProcess.loadPolicyClients();
        ccProcess.selectedClientId = CaseLst1[0].AccountId;
        ccProcess.lob = 'Motor';
        ccProcess.paramCategory = 'Sinistro Caring Angel';
        ccProcess.paramSubCategory = 'Denuncia Sinistro';
        ccProcess.CallIdentifier = '0909090909';
        ccProcess.CallDateTime = '09090909';
        ccProcess.creaCaringAngelCase();
        test.stoptest();
    }

    static testMethod void testAggiornamentogestori1()
    {
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        PageReference pageRef = Page.Unsubscribe;
        Test.setCurrentPage(pageRef);

        Account accAggGestori = [SELECT Id, FirstName, LastName, Matricola__c FROM Account WHERE Matricola__c='98765' LIMIT 1];

        ApexPages.currentPage().getParameters().put('phone', '011234453242489898989898');
        ApexPages.currentPage().getParameters().put('category', 'polizza risparmio');
        ApexPages.currentPage().getParameters().put('subcategory', 'duplicati');
        ApexPages.currentPage().getParameters().put('caller', 'cliente');
        ApexPages.currentPage().getParameters().put('PhonecallID','7891011');

        VFC06_ClientCallProcessing ccProcess = new VFC06_ClientCallProcessing();
        test.starttest();
        ccProcess.client = accAggGestori;
        ccProcess.listAgents = new List<Account>();
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = accAggGestori.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        ccProcess.SearchAgent();
        test.stoptest();
    }
    //OAVERSANO 05/12/2018 : Caring Angel -- END


    @IsTest // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
    static void searchByClaimTest() {

        Account acc = [
                SELECT Id, FirstName, LastName
                FROM Account
                WHERE PersonEmail = 'jane.smith@axa-italy-devtest.com'
                LIMIT 1
        ];

        InsurancePolicy__c p = new InsurancePolicy__c(Name = '100137', Targa_veicolo__c = 'CV123SH', CUID__c = acc.Id);
        insert p;

        Claim__c c = new Claim__c(Name = '082899000112', Account__c = acc.Id, Polizza__c = p.Id);
        insert c;

        Id [] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        VFC06_ClientCallProcessing ccp = new VFC06_ClientCallProcessing();
        ccp.searchClaim = '082899000112';
        ccp.searchFirstName = acc.FirstName;
        ccp.searchTarga = p.Targa_veicolo__c;
        ccp.loadPolicyClients();
        System.assertEquals(1, ccp.mapPolicyClients.size());
        System.assert(ccp.mapPolicyClients.containsKey(acc.Id));

        ccp.searchTarga = 'WE123QA';
        ccp.loadPolicyClients();
        System.assert(ccp.mapPolicyClients.isEmpty());

    }
}