@isTest
private class AP08TaskReporting_TEST {
/*
----------------------------------------------------------------------------------------------------
-- - Name          : AP08TaskReporting_TEST
-- - Author        :    
-- - Description   : Test Methods for AP08TaskReporting
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------------------------------------
-- 25-03-2015   HDU     1.0     
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/
    
    static user userAdmin;
    static id profileId;
    static map<String,Id> case_developerIdMap;//MOSCATELLI_M 16072015: CR-15 
    static string statusOpen = AP_Constants.taskStatusOpen;
    static string statusPending = AP_Constants.taskStatusPending;
    static string statusClosed = AP_Constants.taskStatusClosed;
    static BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
    static list <Task> listTasks;
    static list <Case> listCases;
     
    static{
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        profileId = AP_Constants.getProfileAdminId();
         //MOSCATELLI_M 16072015: CR-15-----START
        case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        Task_Notes_Historicization__c Tnh1 = new Task_Notes_Historicization__c(Name='Non-Motor Task', Enable_Historicization__c=false);
        Task_Notes_Historicization__c Tnh2 = new Task_Notes_Historicization__c(Name='Motor Task', Enable_Historicization__c=false);
        List<Task_Notes_Historicization__c> tnhList = new List<Task_Notes_Historicization__c>();
        tnhList.add(Tnh1); tnhList.add(Tnh2);
        insert tnhList;
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
                            ProfileId = profileId,
                            ByPassVR__c = true);
                        
        insert userAdmin; 
        system.runas(userAdmin){
            //case
            listCases = new list <Case>{
                new Case(
                    Subject = 'su1',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)//MOSCATELLI_M 16072015: CR-15
                ),
                new Case(
                    Subject = 'Su2',
                    RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)//MOSCATELLI_M 16072015: CR-15 
                )
            };

            insert listCases;
        }//end of run as
    }///end of static
    
    
    static testMethod void  beforeInsertTEST(){
        system.runas(userAdmin){
            listTasks = new list<Task>{
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = statusClosed,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = statusPending,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = statusPending,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = statusClosed,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                )
            };
        
            Test.startTest();
                insert listTasks;
            Test.stopTest();
            
            List<Task> listTaskResults = new list<Task>([   SELECT  Pending_Status_Checked_In__c,ActivitiesWithoutPendingHours__c,
                                                                    Closing_date_activities__c,Hours_to_open_an_activity__c
                                                            FROM    task
                                                            WHERE   Id IN :listTasks]);
                                                            
            system.assertEquals(listTaskResults[0].Closing_date_activities__c.date() , system.today()); 
            system.assertEquals(listTaskResults[0].ActivitiesWithoutPendingHours__c,0); 
            system.assertEquals(listTaskResults[1].Pending_Status_Checked_In__c.date(),system.today()); 
            system.assertEquals(listTaskResults[2].Pending_Status_Checked_In__c.date(), system.today());    
            system.assertEquals(listTaskResults[3].Closing_date_activities__c.date(), system.today());  
            system.assertEquals(listTaskResults[3].ActivitiesWithoutPendingHours__c,0); 
        }//end of run as
    }// end of test method
    
    static testMethod void  setDaysBetweenTaskAndCaseCreationTEST(){
        system.runas(userAdmin){
            listTasks = new list<Task>{
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                )
            };
        
            Test.startTest();
                insert listTasks;
            Test.stopTest();
            
            List<Task> listTaskResults = new list<Task>([   SELECT  Closing_date_activities__c,ActivitiesWithoutPendingHours__c,Days_to_open_an_activity__c,
                                                                    Hours_to_open_an_activity__c,Pending_Status_Checked_In__c,Pending_status_duration__c
                                                            FROM    task
                                                            WHERE   Id IN :listTasks]);
                                                            
            long duration = BusinessHours.diff(defaultHours.id , datetime.newInstance(2012, 10, 4) ,  system.now());                                                        
            duration = duration/(60*60*1000);                       
            system.assertEquals(Integer.ValueOf(listTaskResults[0].Hours_to_open_an_activity__c),duration.intValue() ); 
        }//end of run as
    }// end of test method

    static testMethod void  trackTaskPendingTEST(){
        system.runas(userAdmin){
            listTasks = new list<Task>{
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = statusPending,
                    Tech_key__c ='001',
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),new Task(
                    subject = 't sub 1',
                    whatid = listCases[1].id,
                    status = statusPending,
                    Pending_status_duration__c = 4,
                    Tech_key__c ='002',
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = statusOpen,
                    Tech_key__c ='003',
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                ),
                new Task(
                    subject = 't sub 1',
                    whatid = listCases[0].id,
                    status = statusOpen,
                    Tech_key__c ='004',
                    HierarchyLevel1__c='Underwriting & Portfolio Monitoring',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice'
                )
            };
            Test.startTest();
            insert listTasks[0];
            insert listTasks[2];
            insert listTasks[3];
            insert listTasks[1];

            listTasks[0].Status = statusClosed;         
            listTasks[1].Status = statusClosed;     
            listTasks[2].Status = statusClosed; 
            listTasks[3].Status = statusPending;
            
            
                update listTasks;
            Test.stopTest();
            
            List<Task> listTaskResults = new list<Task>([   SELECT  Closing_date_activities__c,ActivitiesWithoutPendingDays__c,Days_to_open_an_activity__c,
                                                                    Hours_to_open_an_activity__c,Pending_Status_Checked_In__c,Pending_status_duration__c
                                                            FROM    task
                                                            WHERE   Id IN :listTasks]);
                                                            
            system.assertEquals(listTaskResults[0].Pending_status_duration__c,null );  
            system.assertEquals(listTaskResults[0].Pending_Status_Checked_In__c.date() , System.today() );  
            
            //system.assertEquals(listTaskResults[1].Pending_status_duration__c,4 );  
            //system.assertEquals(listTaskResults[1].ActivitiesWithoutPendingDays__c,-0.4 );
            //system.assertEquals(listTaskResults[1].Closing_date_activities__c.date() , System.today() );    
            
          //  system.assertEquals(listTaskResults[3].Pending_Status_Checked_In__c.date() , System.today() );  
                                                            
            system.debug('### :'+listTaskResults);                                              
            
            
        }//end of run as
    }// end of test method

}//end of test class