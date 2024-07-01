@isTest
private class AP04Email2Case_TEST {
    /*
----------------------------------------------------------------------------------------------------
-- - Name          : AP04Email2Case_TEST
-- - Author        :    
-- - Description   : Test Methods for AP04Email2Case
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------------------------------------
-- 24-02-2015   YRA     1.0     
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/
    static user userAdmin;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static list <Account> accList;
    static list <Case> caseList;
    static list <Contact> conList;
    static user userAAIVenditeAvanzato;//OAVERSANO 05/07/2018: Easy Azienda 
    static Account accTest;//OAVERSANO 05/07/2018: Easy Azienda
    
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
                             ProfileId = AP_Constants.getProfileAdminId(),
                             ByPassAT__c='AP06');
        
        insert userAdmin;
        
        //OAVERSANO 04/07/2018: Easy Azienda -- START
        accTest = new Account(Name='nomeAccount', Agency_Code__c='003900',Additional_email__c='john.smith@axa-italy-devtest.com');
        insert accTest;
        Contact conTest = new Contact(LastName='lastNameCon',
                                      AccountId = accTest.Id,
                                      MobilePhone ='003911223344',
                                      Phone = '003911223344');
        insert conTest;
        userAAIVenditeAvanzato = new User(Username = 'john.smith@axa-italy-devtest.com',
                                          LastName = 'john.smith@axa-italy-devtest.com',
                                          LanguageLocaleKey = 'en_US',
                                          FirstName = 'john.smith@axa-italy-devtest.com',
                                          Email = 'jane.smith@axa-italy-devtest.com',
                                          Alias = 'tvend',
                                          TimeZoneSidKey = 'Europe/Dublin',
                                          MobilePhone = '003911223344',
                                          Phone = '003911223344',
                                          LocaleSidKey = 'en_US',
                                          EmailEncodingKey = 'UTF-8',
                                          ContactId = conTest.Id,
                                          ProfileId = AP_Constants.getProfileIdAAIVenditeAvanzato());
        insert userAAIVenditeAvanzato;
        //OAVERSANO 04/07/2018: Easy Azienda -- END    
        
        system.runas(userAdmin){
            acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            
            
            
            //account
            accList = new list<Account>{
                new Account(FirstName ='John',
                            LastName= 'Smith',
                            Additional_email__c = 'john.smith@axa-italy-devtest.com',//OAVERSANO 05/07/2018 Close The Loop ICF
                            PersonEmail = 'john.smith@axa-italy-devtest.com',
                            RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIntermediary) 
                           ),
                    new Account(FirstName ='Jane',
                                LastName= 'Smith',
                                PersonEmail = 'jane.smith@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                Matricola__c='123'
                               ),
                    //MOSCATELLI_M 02052016: Bugfix Evo 18 -- START
                    new Account(Name ='Jane Srl1',
                                Subject_email__c = 'jane.test@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2B),
                                Matricola__c=''
                               ),
                    new Account(FirstName ='Jane',
                                LastName= 'Test2',
                                CIF_PersonEmail__c = 'jane.test2@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C),
                                Matricola__c=''
                               ),
                    //OAVERSANO 05/07/2018 Easy Azienda -- START
                    new Account(FirstName ='Jane3',
                                LastName= 'Test3',
                                CIF_Work_email__c = 'jane.test2@axa-italy-devtest.com',
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccB2C),
                                Matricola__c=''
                               ),
                    //OAVERSANO 05/07/2018 Easy Azienda -- END
                    new Account(Name ='Jane Srl2',
                                Subject_Email__c = 'jane.test3@axa-italy-devtest.com',
                                Account_email__c = 'jane.test3@axa-italy-devtest.com',//OAVERSANO 05/07/2018 Easy Azienda
                                RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccCorporateClient),
                                Matricola__c=''
                               )                                        
                    //MOSCATELLI_M 02052016: Bugfix Evo 18 -- END
                    };
                        insert accList; 
                        
            //case
            caseList = new list <Case>{
                new Case(Status = 'Assigned',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                         AccountId= accList[0].Id, //test
                         origin = AP_Constants.caseOriginEmail2Case,
                         SuppliedEmail='john.smith@axa-italy-devtest.com'
                        ),
                    new Case(Status = 'Assigned',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                             AccountId= accList[0].Id,
                             origin = AP_Constants.caseOriginEmail2Case,
                             SuppliedEmail='john.smith@axa-italy-devtest.com'
                            ),
                    new Case(Status = 'Assigned',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                             AccountId= null,
                             origin = AP_Constants.caseOriginEmail2Case,
                             SuppliedEmail='john.smith@axa-italy-devtest.com'
                            ),
                    new Case(Status = 'Assigned',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                             AccountId= null,
                             origin = AP_Constants.caseOriginEmail2Case,
                             SuppliedEmail='jane.smith@axa-italy-devtest.com'
                            ),
                    //MOSCATELLI_M 02052016: Bugfix Evo 18 -- START
                    new Case(Status = 'Assigned',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                             AccountId= null,
                             origin = AP_Constants.caseOriginEmail2Case,
                             SuppliedEmail='jane.test@axa-italy-devtest.com'
                            ),
                    new Case(Status = 'Assigned',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                             AccountId= null,
                             origin = AP_Constants.caseOriginEmail2Case,
                             SuppliedEmail='jane.test2@axa-italy-devtest.com'
                            ),
                    new Case(Status = 'Assigned',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),
                             AccountId= null,
                             origin = AP_Constants.caseOriginEmail2Case,
                             SuppliedEmail='jane.test3@axa-italy-devtest.com'
                            )                                                                
                    //MOSCATELLI_M 02052016: Bugfix Evo 18 -- END                               
                    };
                        }//end runas
    }//end static
    
    static testMethod void email2Case_Scenario1_Test() {
        
        system.runas(userAdmin){
            Test.startTest();
            
            //MOSCATELLI_M 02052016: Bugfix Evo 18 -- START
            
            List<Id> fixedSearchResults= new list <Id>();
            
            for(Account acc: accList)
            {
                fixedSearchResults.add(acc.Id);
            }
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI_M 02052016: Bugfix Evo 18 -- END
            
            insert caseList;
            
            Test.stopTest();            
            
            list <Case> caseAsrtList = [Select Id,Category__c,Status,accountid,AgentName__c,contactid
                                        From Case 
                                        Where Id IN:caseList];
                   
            system.assertEquals(accList[0].Id,caseAsrtList[0].AgentName__c);
            //system.assertEquals(null,caseAsrtList[0].accountid);
            system.assertEquals(accList[0].Id,caseAsrtList[0].accountid);
            
            system.assertEquals(accList[0].Id,caseAsrtList[1].AgentName__c);
            //system.assertEquals(null,caseAsrtList[1].accountid);
            system.assertEquals(accList[0].Id,caseAsrtList[1].accountid);
            
            system.assertEquals(accList[0].Id,caseAsrtList[2].AgentName__c);
            //system.assertEquals(null,caseAsrtList[2].accountid);
            system.assertEquals(accList[0].Id,caseAsrtList[2].accountid);
            
            system.assertEquals(accList[1].Id,caseAsrtList[3].accountid);
            
        }
    }  
    //OAVERSANO 05/07/2018 Easy Azienda -- START
    static testMethod void email2Case_Scenario2_Test() {
     
        system.runas(userAdmin){
            Test.startTest();
            
            //MOSCATELLI_M 02052016: Bugfix Evo 18 -- START
            
            List<Id> fixedSearchResults= new list <Id>();
            
            for(Account acc: accList)
            {
                fixedSearchResults.add(acc.Id);
            }
            Test.setFixedSearchResults(fixedSearchResults);
            //MOSCATELLI_M 02052016: Bugfix Evo 18 -- END
            Id [] fixedSearchResults2= new Id[1];
            fixedSearchResults2[0] = userAAIVenditeAvanzato.Id;
            Test.setFixedSearchResults(fixedSearchResults2);
            
            insert caseList;
            
            Test.stopTest();            
            
            list <Case> caseAsrtList = [Select Id,Category__c,Status,accountid,AgentName__c,contactid
                                        From Case 
                                        Where Id IN:caseList];                    
            system.assertEquals(accList[0].Id,caseAsrtList[0].AgentName__c);
            //system.assertEquals(null,caseAsrtList[0].accountid);
            system.assertEquals(accList[0].Id,caseAsrtList[0].accountid);
            
            system.assertEquals(accList[0].Id,caseAsrtList[1].AgentName__c);
            //system.assertEquals(null,caseAsrtList[1].accountid);
            system.assertEquals(accList[0].Id,caseAsrtList[1].accountid);
            
            system.assertEquals(accList[0].Id,caseAsrtList[2].AgentName__c);
            //system.assertEquals(null,caseAsrtList[2].accountid);
            system.assertEquals(accList[0].Id,caseAsrtList[2].accountid);
            
            //system.assertEquals(accList[1].Id,caseAsrtList[3].accountid);
            
        }
    }
    //OAVERSANO 05/07/2018 Easy Azienda -- END
}