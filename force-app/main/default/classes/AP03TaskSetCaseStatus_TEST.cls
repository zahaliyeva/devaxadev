@isTest
private class AP03TaskSetCaseStatus_TEST {
/*
----------------------------------------------------------------------------------------------------
-- - Name          : AP03TaskSetCaseStatus_TEST
-- - Author        :    
-- - Description   : Test Methods for AP03TaskSetCaseStatus
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
    static id profileId;
    static map<String,Id> acc_developerIdMap;
    static map<String,Id> case_developerIdMap;
    static string accIndividualId;
    static list <Account> accList;
    static list <Case> caseList;
    static list <Task> taskList;
    static list <CaseCategoryToCloseTask__c> listCustomSetting; //CAPOBIANCO_A 15/06/2017 EVO 86
    
    static
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        
        //MOSCATELLI_M 16072015 : CR-15-----START
        //Task_Notes_Historicization__c Tnh = new Task_Notes_Historicization__c(Name='Motor Task', Enable_Historicization__c=false);
        //insert Tnh; 
        //MOSCATELLI_M 16072015 : CR-15-----EMD
        
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
                            ProfileId = UserInfo.getProfileId(),
                            ByPassAT__c='AP09');
                        
        insert userAdmin; 
        
        system.runas(userAdmin)
        {
            acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;         

            Account acc = new Account(FirstName ='John',LastName= 'Smith', PersonEmail = 'john.smith@axa-italy-devtest.com', RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient) );
            insert acc;

            listCustomSetting = new list <CaseCategoryToCloseTask__c>
                                                                    {
                                                                        new CaseCategoryToCloseTask__c(Category__c = 'Duplicati polizza - Polizze auto', Name = '1'),
                                                                        new CaseCategoryToCloseTask__c(Category__c = 'Duplicati polizza - Polizze auto', SubCategory__c = 'Contratto di polizza', Name = '2')
                                                                    };
            insert listCustomSetting;

            caseList = new list <Case>
                                    {
                                       new Case(Status = 'Assigned',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor),AccountId= acc.Id,Category__c='Duplicati polizza - Polizze auto', SubCategory__c = 'Contratto di polizza') 
                                    };
            insert caseList;

            taskList = new list <Task>{
                                        new Task(WhatID = caseList[0].id,Subject='Sample Task1',Status='Open',Priority='Normal',HierarchyLevel1__c='h1',HierarchyLevel2__c='h2',HierarchyLevel3__c='h3')
                                    };
            insert taskList;
        }
    }

    static testMethod void CloseCase()
    {
        system.runAs(userAdmin)
        {
            test.starttest();           
            String cid = [Select Id from Case where Category__c='Duplicati polizza - Polizze auto'].id;
        
            Case c1 = new Case(id=cid,Status=AP_Constants.caseStatusClosed);
            update c1;

            test.stoptest();

            /*String Status = [Select id, Status from Task where whatid=:cid].Status;
            system.assertEquals( Status,AP_Constants.taskStatusOutOfTime);*/
            

        }
    }

}