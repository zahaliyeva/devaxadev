@isTest
private class AP09TaskWithClosedCase_TEST {
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
-- 02-04-2015   HDU     1.0     
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/  static string caseStatusClosed,taskStatusClosed,taskStatusOpen,taskStatusInProgress,caseStatusOpen;
    static user userAdmin;
    static id profileId;
    static list <Task> listTasks;
    static list <Case> listCases;
    static map<String,Id> case_developerIdMap;//MOSCATELLI_M 16072015: CR-15 
    static{
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        profileId = AP_Constants.getProfileAdminId();
        caseStatusClosed = AP_Constants.caseStatusClosed;
        caseStatusOpen = AP_Constants.caseStatusOpen;
        taskStatusClosed = AP_Constants.taskStatusClosed;
        taskStatusOpen = AP_Constants.taskStatusOpen;
        taskStatusInProgress = AP_Constants.taskStatusInProgress;
        case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);//MOSCATELLI_M 16072015: CR-15 
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
                            ProfileId = profileId,
                            ByPassVR__c = true);
        insert userAdmin; 
        
        system.runas(userAdmin){
             //MOSCATELLI_M 16072015: CR-15-----START
            Task_Notes_Historicization__c Tnh1 = new Task_Notes_Historicization__c(Name='Non-Motor Task', Enable_Historicization__c=false);
            Task_Notes_Historicization__c Tnh2 = new Task_Notes_Historicization__c(Name='Motor Task', Enable_Historicization__c=false);
            List<Task_Notes_Historicization__c> tnhList = new List<Task_Notes_Historicization__c>();
            tnhList.add(Tnh1); tnhList.add(Tnh2);
            insert tnhList;
            //MOSCATELLI_M 16072015: CR-15-----END
            
            //case
            listCases = new list <Case>{
                new Case(
                    Subject = 'su1',
                    status = caseStatusClosed,
                    Category__c = 'Cat',
                    Subcategory__c = 'SubCat',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)//MOSCATELLI_M 16072015: CR-15 
                    
                ),
                new Case(
                    Subject = 'Su2',
                    status = caseStatusOpen,
                    Category__c = 'Cat',
                    Subcategory__c = 'SubCat',                   
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)//MOSCATELLI_M 16072015: CR-15 
                    )
            };
            insert listCases;
            
            listTasks = new list<Task>{
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = taskStatusOpen,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = taskStatusOpen,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = taskStatusClosed,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = taskStatusClosed
                )
            };
        }//end of run as
    }//end of static
    
    static testMethod void  validatedTaskAndCaseStatusInsertTEST(){
        
        system.runas(userAdmin){
            Test.startTest();
                try{
                    insert listTasks;
                }catch(Exception e){
                    system.assert(e.getMessage().indexOf(System.label.ClosedCaseTaskNoneClosedError) >= 0);
                }
            Test.stopTest();
        }
        
    }//end of test method
    static testMethod void  validatedTaskAndCaseStatusUpdateTEST(){
        system.runas(userAdmin){
            listTasks[0].whatid = listCases[1].id;
            listTasks[1].whatid = listCases[1].id;
            listTasks[2].whatid = listCases[1].id;
            listTasks[3].whatid = listCases[1].id;
            Test.startTest();
            insert listTasks;
            Test.stopTest();
            listCases[1].Status = caseStatusClosed;
            update listCases;
            
            listTasks[0].status = taskStatusInProgress;
            
                try{
                    update listTasks;
                }catch(Exception e){
                    System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
                    //system.assert(e.getMessage().indexOf(System.label.ClosedCaseTaskNoneClosedError) >= 0);
                }
            
        }
    }//end of test method
}//end of class