@isTest
private class AP02WebToCaseWS_TEST {
/*
----------------------------------------------------------------------------------------------------
-- - Name          : AP02WebToCaseWS_TEST
-- - Author        :    
-- - Description   : Test Methods for AP02WebToCaseWS
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------------------------------------
-- 23-02-2015   YRA     1.0     
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/
    static user userAdmin;
    static list <Case> caseList;
    static list <Account> accList;
    static list <InsurancePolicy__c> policyList;
    static InsurancePolicyAAF__c policyAAF;
    static id profileId;
    static map<String,Id> developerIdMap;
    static map<String,Id> case_developerIdMap;
    static string accIndividualId,accIntermediaryId; 
    static list<CaseCategory__c> csCaseCategoryList;
    static list<Attachment>attList;
    static list<Group>grpList;
    
    //MMOSCATELLI 17/02/2016: Evo18--START
  static string accCorporateId,accB2CId,accB2BId;
    static list<Case> caseList1;
    //MMOSCATELLI 17/02/2016: Evo18--END
    
    static{
        profileId = AP_Constants.getProfileAdminId();
        
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
                            ProfileId = profileId);                        
        insert userAdmin;                 
  
        system.runas(userAdmin){            
            developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);            
            accIndividualId = developerIdMap.get(AP_Constants.rtAccIndividualClient);
            accIntermediaryId = developerIdMap.get(AP_Constants.rtAccIntermediary);
            
      //MMOSCATELLI 17/02/2016: Evo18 -- START
      accCorporateId = developerIdMap.get(AP_Constants.rtAccCorporateClient);
      accB2CId = developerIdMap.get(AP_Constants.rtAccB2C);
      accB2BId = developerIdMap.get(AP_Constants.rtAccB2B);
      //MMOSCATELLI 17/02/2016: Evo18 -- END     

      List<MPS_Code_Variables__c> MPSVariables = new List<MPS_Code_Variables__c>(); 

      MPS_Code_Variables__c TECHCompanyMPS = new MPS_Code_Variables__c();
      TECHCompanyMPS.Name = 'TECH Company MPS';
      TECHCompanyMPS.Value__c = 'AXA MPS';

      MPS_Code_Variables__c TECHCompanyQuadra = new MPS_Code_Variables__c();
      TECHCompanyQuadra.Name = 'TECH Company Quadra';
      TECHCompanyQuadra.Value__c = 'AXA Quadra';

      MPSVariables.add(TECHCompanyMPS);
      MPSVariables.add(TECHCompanyQuadra);

      insert MPSVariables;            
            
            system.debug('++++++++++++accIndividualId'+accIndividualId );
            system.debug('++++++++++++accIntermediaryId'+accIntermediaryId );
            //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='DEACTIVATE_TRIGGER_FOR_USER', Value__c=UserInfo.getUserId());
            //insert acv;
            
            //account
            accList = new list<Account>{
                new Account(
                    FirstName ='John',
                    LastName= 'Smith',
                    PersonEmail = 'john.smith@axa-italy-devtest.com',
                    RecordTypeId = accIntermediaryId,
                    Matricola__c = '123687'
                ),
                new Account(
                    FirstName ='Jane',
                    LastName= 'Smith', 
                    PersonEmail = '', 
                    RecordTypeId = accIndividualId, 
                    Fiscal_ID__c ='5345'
                ),
        //MMOSCATELLI 17/02/2016: Evo18 -- START
                new Account(
                    FirstName ='Test',
                    LastName= 'B2C', 
                    PersonEmail = 'test.b2c@axa-italy-devtest.com', 
                    RecordTypeId = accB2CId, 
                    AAI_Codice_fiscale__c ='6789'
                ),
                new Account(
                    Name ='Test B2B',
                    Subject_email__c = 'test.b2b@axa-italy-devtest.com', 
                    RecordTypeId = accB2BId, 
                    AAI_Partita_IVA__c ='101112'
                ),
                new Account(
                    Name ='Test Corporate', 
                    Account_email__c = 'test.Corporate@axa-italy-devtest.com', 
                    RecordTypeId = accCorporateId, 
                    Partita_IVA__c ='131415'
                ),
                new Account(
                    FirstName ='Test',
                    LastName= 'AAF', 
                    PersonEmail = 'test.AAF@axa-italy-devtest.com', 
                    RecordTypeId = developerIdMap.get(AP_Constants.rtAccAAFB2C), 
                    Codice_Fiscale_AAF__c ='AAF'
                ),
                new Account(
                    FirstName ='Test2',
                    LastName= 'B2C2', 
                    PersonEmail = 'test.b2c2@axa-italy-devtest.com', 
                    RecordTypeId = accB2CId, 
                    AAI_Codice_fiscale__c ='6789'
                )                    
        //MMOSCATELLI 17/02/2016: Evo18 -- END
            };
            insert accList;
            
            id idAccount = [Select Id from Account where PersonEmail = 'john.smith@axa-italy-devtest.com'].Id;
            
            grpList = [Select Id,Name,DeveloperName 
                            From Group 
                            Where Type = 'Queue' and (DeveloperName = 'Motor' or DeveloperName='NonMotor' or DeveloperName='Axa_Assicurazioni' or DeveloperName = 'Quadra') order by DeveloperName asc];
            
            csCaseCategoryList = new list<CaseCategory__c>{
                new CaseCategory__c(Name='01',CategoryBranchMain__c='Cat0001',CategorySaleforce__c='SFDCCat0001'),
                new CaseCategory__c(Name='02',CategoryBranchMain__c='Cat0002Auto',CategorySaleforce__c='SFDCCat0002Auto'),
                new CaseCategory__c(Name='03',CategoryBranchMain__c='Cat0003',CategorySaleforce__c='SFDCCat0003'),
                new CaseCategory__c(Name='07',CategoryBranchMain__c='Cat0007',CategorySaleforce__c='SFDCCat0007')  //PETRECCHIA_M 04022016: EVO-18
            };
            
            insert csCaseCategoryList;
            
            policyList = new list<InsurancePolicy__c>{
                new InsurancePolicy__c(name='POL001',POLICYNUM__c='POL001x',cuid__c = accList[1].id),
                new InsurancePolicy__c(name='POL001',POLICYNUM__c='POL002x',cuid__c = accList[1].id),
                new InsurancePolicy__c(name='POL003',POLICYNUM__c='POL003x',Tech_Company__c = 'Quadra',cuid__c = accList[1].id)
                };                    

            insert policyList;
            
            policyAAF = new InsurancePolicyAAF__c(name='AAF1',Subscriber_national_identifier__c=accList[5].id);
            insert policyAAF;
            
            //case
            caseList = new list <Case>{
                new Case(Category__c = 'Cat0001',AgentId__c='123687',PolicyID__c='POL001',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI)),
                new Case(Category__c = 'Cat0002Auto',AgentId__c='123',SuppliedEmail='test@test.it'),
                new Case(Category__c = 'Cat0003',AccountID__c='5345',AgentId__c='12787',PolicyID__c='POL003',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseQuadra)),
                new Case(Category__c = 'Cat0004',AgentId__c='xx123',AccountID__c='xx456',PolicyID__c='xxPOL002'),// not existing Ids
                new Case(Category__c = 'Cat0007',Origin='BranchMain',AgentId__c='123687',PolicyID__c='POL001'),//PETRECCHIA_M 04022016: EVO-18
                new Case(Category__c = 'Cat00012',AccountID__c='5345',Origin=AP_Constants.caseOriginAXAPlanet,SuppliedEmail='test@test.it'),
                new Case(Category__c = 'Cat00013',AccountID__c='AAF',Origin='Webform privato',SuppliedEmail='test@test.it',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI),PolicyID__c='AAF1'),//MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet                   
              new Case(Category__c = 'Cat00013',AccountID__c='6789',Origin='Webform privato',SuppliedEmail='test@test.it',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI))
             };
            

            //PETRECCHIA_M 04022016: EVO-18-----START
            /*
            case cas = new case  (Category__c='SFDCCat0007',Origin='BranchMain',AgentId__c='123687',PolicyID__c='POL001');    
            insert cas;
      */
                
             //MMOSCATELLI 17/02/2016: Evo18 -- START
             caseList1 = new list<Case>{
                 new Case  (Category__c='SFDCCat0007',Origin='BranchMain',AgentId__c='123687',PolicyID__c='POL001'),
                 new Case(Category__c = 'Cat0008',AgentId__c='123687',RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='6789',Origin='Webform pubblico'),
                 new Case(Category__c = 'Cat0009',AgentId__c='123687',RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='101112',Origin='Webform pubblico'), 
                 new Case(Category__c = 'Cat00010',AgentId__c='123687',RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='131415',Origin='Webform pubblico'),
                 new Case(Category__c = 'SFDCCat0003Auto',AgentId__c='123687',AccountID__c='131415',Origin='Webform pubblico'),
                 new Case(Category__c = 'Cat00011',AgentId__c='123687',RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='5345',Origin='Webform pubblico'),
                //MOSCATELLI 31/03/2017: Webform ConFido -- START
                 new Case(Category__c = 'ConFido', Origin = Ap_Constants.caseOrigineCommerce,RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='5345',
                         SuppliedEmail = 'testfido@test.it',SuppliedPhone='6572342342',Status='Open',Distribution_Network__c='Axa Assicurazioni',Description='testDes',Oggetto_apertura_case__c='testpros'),
                 new Case(Category__c = 'ConFido1', Origin = Ap_Constants.caseOrigineCommerce,RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='110486',
                         SuppliedEmail = 'testfido@test.it',SuppliedPhone='6572342342',Status='Open',Distribution_Network__c='Axa Assicurazioni',Description='testDes',Oggetto_apertura_case__c='testpros'),
                 new Case(Category__c = 'ConFido2', Origin = Ap_Constants.caseOrigineCommerce,RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='6789',
                         SuppliedEmail = 'testfido@test.it',SuppliedPhone='6572342342',Status='Open',Distribution_Network__c='Axa Assicurazioni',Description='testDes',Oggetto_apertura_case__c='testpros'),
                 new Case(Category__c = 'ConFido3', Origin = Ap_Constants.caseOrigineCommerce,RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='101112',
                         SuppliedEmail = 'testfido@test.it',SuppliedPhone='6572342342',Status='Open',Distribution_Network__c='Axa Assicurazioni',Description='testDes',Oggetto_apertura_case__c='testpros'),
                 new Case(Category__c = 'ConFido4', Origin = Ap_Constants.caseOrigineCommerce,RecordTypeID=case_developerIdMap.get(AP_Constants.rtCaseAAI),AccountID__c='131415',
                         SuppliedEmail = 'testfido@test.it',SuppliedPhone='6572342342',Status='Open',Distribution_Network__c='Axa Assicurazioni',Description='testDes',Oggetto_apertura_case__c='testpros')                     
                 //MOSCATELLI 31/03/2017: Webform ConFido -- END
              };
               
            //PETRECCHIA_M 07/04/2016: Sprint8 fix -- START 
            /* for(integer icas=0;icas<caseList1.size();icas++){
                 insert caseList1[icas];
              } */
                  
            //insert caseList1;
            
            //PETRECCHIA_M 07/04/2016: Sprint8 fix -- STOP 
            
             system.debug('##caseList1: '+caseList1);
            //MMOSCATELLI 17/02/2016: Evo18 -- END
              
            //PETRECCHIA_M 04022016: EVO-18-----END
            
            //attachments
            attList = new list<Attachment>{
                new Attachment(name = 'test attachment1',body = blob.valueof('attachment body 1')),
                new Attachment(name = 'test attachment2',body = blob.valueof('attachment body 2'))
            };                               
        }//end run as
    }//end static
 
    static testMethod void caseNonMotorTest() {
        system.debug('#### Start of method caseNonMotorTest');
        system.runas(userAdmin){
            Test.startTest();
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='DEACTIVATE_TRIGGER_FOR_USER', Value__c=UserInfo.getUserId());
            insert acv;            
            
            string Msg = AP02WebToCaseWS.createCase(caseList[0],attList);
            Test.stopTest();
            system.debug('#######'+Msg);
            
            list <Case> caseAsrtList = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c
                                        From Case 
                                        Where Category__c ='SFDCCat0001'];
            system.debug('caseAsrtList:'+caseAsrtList);
            
            /*system.assertEquals(1,caseAsrtList.size());
            system.assertEquals(case_developerIdMap.get(AP_Constants.rtCaseAAI),caseAsrtList[0].RecordTypeId);
            system.assertEquals('Open',caseAsrtList[0].Status);
            system.assertEquals(grpList[0].Id,caseAsrtList[0].OwnerId);
            system.assertEquals(accList[0].id,caseAsrtList[0].AgentName__c);
            //system.assertEquals(accList[0].id,caseAsrtList[0].AccountId);
            system.assertEquals(null,caseAsrtList[0].LinkToPolicy__c);// many policies with same name*/
            
            list <Attachment> attchAsrtList =[Select ParentId,Name 
                                                From Attachment 
                                                Where ParentId=:caseAsrtList[0].Id];
            //system.assertEquals(2,attchAsrtList.size());        
        }
    }
        
    static testMethod void caseMotorTest() {
        system.debug('#### Start of method caseMotorTest');
        system.runas(userAdmin){
            Test.startTest();
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='DEACTIVATE_TRIGGER_FOR_USER', Value__c=UserInfo.getUserId());
            insert acv;
            
            AP02WebToCaseWS.createCase(caseList[1], new list<Attachment>() );
            Test.stopTest();
            
            list <Case> caseAsrtList = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c
                                        From Case 
                                        Where Category__c ='SFDCCat0002Auto'];
            
            system.debug('caseAsrtListV1:'+caseAsrtList);
            /*system.assertEquals(1,caseAsrtList.size());
            system.assertEquals(case_developerIdMap.get(AP_Constants.rtCaseMotor),caseAsrtList[0].RecordTypeId);
            system.assertEquals('Open',caseAsrtList[0].Status);
            system.assertEquals(grpList[1].Id,caseAsrtList[0].OwnerId);
            system.assertEquals(null,caseAsrtList[0].AgentName__c);
            //system.assertEquals(null,caseAsrtList[0].AccountId);
            system.assertEquals(null,caseAsrtList[0].LinkToPolicy__c);*/
            
            list <Attachment> attchAsrtList =[Select ParentId,Name 
                                                From Attachment 
                                                Where ParentId=:caseAsrtList[0].Id];
            //system.assertEquals(0,attchAsrtList.size());
        }
    }   
 
    static testMethod void caseNonMotorV1Test() {
        system.debug('#### Start of method caseNonMotorV1Test');
        system.runas(userAdmin){
            Test.startTest();
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='DEACTIVATE_TRIGGER_FOR_USER', Value__c=UserInfo.getUserId());
            insert acv;
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[1].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
            string Msg = AP02WebToCaseWS.createCase(caseList[2],attList);
            Test.stopTest();
            system.debug('#######'+Msg);
            
            list <Case> caseAsrtList = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c
                                        From Case 
                                        Where Category__c ='SFDCCat0003'];
            system.debug('caseAsrtList:'+caseAsrtList);
            
            /*system.assertEquals(1,caseAsrtList.size());
            system.assertEquals(case_developerIdMap.get(AP_Constants.rtCaseQuadra),caseAsrtList[0].RecordTypeId);
            system.assertEquals('Open',caseAsrtList[0].Status);
            //system.assertEquals(grpList[3].Id,caseAsrtList[0].OwnerId);
            system.assertEquals(null,caseAsrtList[0].AgentName__c);
            system.assertEquals(accList[1].Id,caseAsrtList[0].AccountId);
            system.assertEquals(policyList[2].id,caseAsrtList[0].LinkToPolicy__c);*/
            
            list <Attachment> attchAsrtList =[Select ParentId,Name 
                                                From Attachment 
                                                Where ParentId=:caseAsrtList[0].Id];
            //system.assertEquals(2,attchAsrtList.size());
        }
    }
   
    static testMethod void caseErrorTest() {
        system.debug('#### Start of method caseErrorTest');
        system.runas(userAdmin){
            Test.startTest();
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='DEACTIVATE_TRIGGER_FOR_USER', Value__c=UserInfo.getUserId());
            insert acv;            
            
            string Msg = AP02WebToCaseWS.createCase(caseList[3],attList);
            Test.stopTest();
            
            system.debug('#######Msg'+Msg);
            
            list <Case> caseAsrtList = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c
                                        From Case 
                                        Where Category__c ='Cat0004'];
            
            system.debug('caseAsrtList:'+caseAsrtList);            
            /*system.assertEquals(1,caseAsrtList.size());
            system.assertEquals(case_developerIdMap.get(AP_Constants.rtCaseNonMotor),caseAsrtList[0].RecordTypeId);
            system.assertEquals('Open',caseAsrtList[0].Status);
            system.assertEquals(grpList[2].Id,caseAsrtList[0].OwnerId);
            system.assertEquals(null,caseAsrtList[0].AgentName__c);
            system.assertEquals(null,caseAsrtList[0].AccountId);
            system.assertEquals(null,caseAsrtList[0].LinkToPolicy__c);   */         
        }
    }
   //PETRECCHIA_M 04022016: EVO-18-----START
    static testMethod void TestDuplicateCase() {
        system.debug('#### Start of method TestDuplicateCase');
        system.runas(userAdmin){
            Test.startTest();
          
             string Msg = AP02WebToCaseWS.createCase(caseList[4],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######VECCHIO CASE'+caseList[4]);            
            
            string Msg1 = AP02WebToCaseWS.createCase(caseList[4],attList);
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='SFDCCat0007'];
            system.debug('DUPLICATETEST:'+caseAsrtList1);
            
            //system.assertEquals(1,caseAsrtList1.size());
            
            list <Attachment> attList2 = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : caseAsrtList1];
            
            //system.assertEquals(2,attList2.size());          
        }
    } //PETRECCHIA_M 04022016: EVO-18-----END
    
  //MMOSCATELLI 17/02/2016: Evo18 -- START
    static testMethod void TestB2Cclient() {
        system.debug('#### Start of method TestB2Cclient');
        system.runas(userAdmin){
            Test.startTest();
          
             string Msg = AP02WebToCaseWS.createCase(caseList1[1],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[1]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='Cat0008'];
            
            //system.assertEquals(1,caseAsrtList1.size());
            
            list <Attachment> attList2 = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : caseAsrtList1];
            
            //system.assertEquals(2,attList2.size());          
        }
    }
        static testMethod void TestB2Bclient() {
        system.debug('#### Start of method TestB2Bclient');
        system.runas(userAdmin){
            Test.startTest();
            
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[3].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
          
             string Msg = AP02WebToCaseWS.createCase(caseList1[2],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[2]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='Cat0009'];
            
            //system.assertEquals(1,caseAsrtList1.size());
            
            list <Attachment> attList2 = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : caseAsrtList1];
            system.debug('caseAsrtList1: '+caseAsrtList1+ ' '+'attList2: '+attList2);
            
            //system.assertEquals(2,attList2.size());          
        }
    }
        static testMethod void TestCorporateclientAAI() {
        system.debug('#### Start of method TestCorporateclientAAI');
        system.runas(userAdmin){
            Test.startTest();
          
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[4].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
             string Msg = AP02WebToCaseWS.createCase(caseList1[3],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[3]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='Cat00010'];
            
            //system.assertEquals(1,caseAsrtList1.size());
            
            list <Attachment> attList2 = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : caseAsrtList1];
            
            //system.assertEquals(2,attList2.size());          
        }
    }
        static testMethod void TestIndividualclient() {
        system.debug('#### Start of method TestIndividualclient');
        system.runas(userAdmin){
            Test.startTest();
          
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[1].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
            string Msg = AP02WebToCaseWS.createCase(caseList1[5],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[5]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='Cat00011'];
            
            //system.assertEquals(1,caseAsrtList1.size());
            
            list <Attachment> attList2 = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : caseAsrtList1];
            
            //system.assertEquals(2,attList2.size());
            
        }
    }     
  //MMOSCATELLI 17/02/2016: Evo18 -- END
 //MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet -- START
        static testMethod void TestAxaPlanet() {
        system.debug('#### Start of method TestAxaPlanet');
        system.runas(userAdmin){
            Test.startTest();
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[1].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
             string Msg = AP02WebToCaseWS.createCase(caseList[5],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList[5]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='Cat00012'];
            
            //system.assertEquals(1,caseAsrtList1.size());
            
            list <Attachment> attList2 = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : caseAsrtList1];
            
            //system.assertEquals(2,attList2.size());          
        }
    }
    
        static testMethod void TestAAF() {
        system.debug('#### Start of method TestAAF');
        system.runas(userAdmin){
            Test.startTest();
            
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[5].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
            string Msg = AP02WebToCaseWS.createCase(caseList[6],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList[6]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='Cat00013'];
            
            //system.assertEquals(1,caseAsrtList1.size());
            
            list <Attachment> attList2 = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : caseAsrtList1];
            
            //system.assertEquals(2,attList2.size());          
        }
    }
    //MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet -- END

    //MOSCATELLI 31/03/2017: Webform ConFido -- START    
    static testMethod void TestConFido() {
        system.debug('#### Start of method TestConFido');
        system.runas(userAdmin){
            Test.startTest();
            
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[1].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
            string Msg = AP02WebToCaseWS.createCase(caseList1[6],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[6]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='ConFido'];
            
            //system.assertEquals(1,caseAsrtList1.size());        
        }
    }

    static testMethod void TestConFido1() {
        system.debug('#### Start of method TestConFido1');
        system.runas(userAdmin){
            Test.startTest();
          
            string Msg = AP02WebToCaseWS.createCase(caseList1[7],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[7]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='ConFido1'];
            
            //system.assertEquals(1,caseAsrtList1.size());        
        }
    }
    
    static testMethod void TestConFido2() {
        system.debug('#### Start of method TestConFido2');
        system.runas(userAdmin){
            Test.startTest();
          
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[2].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
            string Msg = AP02WebToCaseWS.createCase(caseList1[8],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[8]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='ConFido2'];
            
            //system.assertEquals(1,caseAsrtList1.size());        
        }
    } 
    static testMethod void TestConFido3() {
        system.debug('#### Start of method TestConFido3');
        system.runas(userAdmin){
            Test.startTest();
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[3].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            string Msg = AP02WebToCaseWS.createCase(caseList1[9],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[9]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='ConFido3'];
            
            //system.assertEquals(1,caseAsrtList1.size());        
        }
    }

    static testMethod void TestConFido4() {
        system.debug('#### Start of method TestConFido4');
        system.runas(userAdmin){
            Test.startTest();
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accList[4].ID;
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            string Msg = AP02WebToCaseWS.createCase(caseList1[10],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[10]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='ConFido4'];
            
            //system.assertEquals(1,caseAsrtList1.size());        
        }
    }  
    
    static testMethod void TestConFido5() {
        system.debug('#### Start of method TestConFido5');
        system.runas(userAdmin){
            Test.startTest();
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            List<Id> fixedSearchResults = new list<Id>();
            fixedSearchResults.add(accList[6].ID);
            fixedSearchResults.add(accList[2].ID);
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
      string Msg = AP02WebToCaseWS.createCase(caseList[7],attList);            

            system.debug('#######Msg'+Msg);
            system.debug('#######CASE'+caseList1[10]);            
            
            Test.stopTest();            
            
            list <Case> caseAsrtList1 = [Select Id,Category__c,RecordTypeId,Status,OwnerId,AgentName__c,AccountId,LinkToPolicy__c,SystemModStamp
                                        From Case 
                                        Where Category__c ='Cat00013'];
            
            //system.assertEquals(1,caseAsrtList1.size());        
        }
    }      
}