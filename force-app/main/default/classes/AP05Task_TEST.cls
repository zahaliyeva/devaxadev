@isTest
private class AP05Task_TEST {
/*
----------------------------------------------------------------------------------------------------
-- - Name          : AP05Task
-- - Author        :    
-- - Description   : Test Methods for AP05Task
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
    static list <Task> taskList;
    
    static{
        
        //MOSCATELLI_M 16072015: CR-15-----START
        Task_Notes_Historicization__c Tnh = new Task_Notes_Historicization__c(Name='Motor Task', Enable_Historicization__c=false);
        insert Tnh;
        //MOSCATELLI_M 16072015: CR-15-----END
                
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
                new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[0].Id,AgentId__c='123'),
                new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[0].Id),
                new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor),AccountId= accList[0].Id)
            };
            insert caseList;
            
            //tasks
            taskList = new list <Task>{
                new Task(WhatID = caseList[0].id,Subject='Sample Task1',Status='Open',Priority='Normal',Send_email_to_case_owner__c=true,HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'),
                new Task(WhatID = caseList[1].id,Subject='Sample Task2',Status='Open',Priority='Normal',Send_email_to_case_owner__c=true),
                new Task(WhatID = caseList[2].id,Subject='Sample Task3',Status='Open',Priority='Normal',Send_email_to_case_owner__c=false)
            };
            System.assertEquals( 3,taskList.size());
            
        }//end run as
    }//end static
    
    static testMethod void taskInsert_Test() {

        system.runas(userAdmin){
            Test.startTest();
                insert taskList;
            Test.stopTest();
        }
        System.assertEquals( 3,taskList.size());
    }
    
    static testMethod void taskUpdate_Test() {

        system.runas(userAdmin){
            insert taskList;
            Test.startTest();
                taskList[2].Send_email_to_case_owner__c =true;
                taskList[1].Send_email_to_case_owner__c =false;
                update taskList;
            Test.stopTest();
        }
    }
}