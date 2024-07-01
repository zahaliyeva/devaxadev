@isTest
private class AP10SendTaskOwnerEmail_TEST {
    /*
----------------------------------------------------------------------------------------------------
-- - Name          : AP10SendTaskOwnerEmail_TEST
-- - Author        : Spoon consulting   
-- - Description   : Test class for AP07CaseEmailAlert
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------------------------------------
-- 15-MAY-2015   DMT    1.0     initial version
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/
    static id profileId;
    static map<String,Id> case_developerIdMap;//MOSCATELLI_M 16072015: CR-15 
    static user userAdmin;
    static user userAdmin2;
    static list <Case> listCases;
    static list<Task> taskList;
    static string statusOpen = AP_Constants.taskStatusOpen;
    static string statusClosed = AP_Constants.taskStatusClosed;
    static{
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        profileId = AP_Constants.getProfileAdminId();
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
        

        userAdmin2 = new User(Username = 'testclassAP01_2@test.com',
                             LastName = 'testuser_2',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test_2',
                             Email = 'test_2@test.com',
                             Alias = 'test_2',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId = profileId,
                             ByPassVR__c = true);
        insert userAdmin2; 

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
                //MOSCATELLI_M 16072015: CR-15----START
                new Case(Category__c = 'Aspetti tecnici/assuntivi polizza di previdenza - risponde Axa',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)),
                new Case(Category__c = 'Duplicati polizza di protezione - risponde Axa',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor))
                //MOSCATELLI_M 16072015: CR-15-----END
                };
                        
                insert listCases;
            
            taskList = new list<Task>{
                new Task(subject = 't sub 1',
                         whatid = listCases[0].id,
                         status = statusClosed,
                         HierarchyLevel1__c = 'h1',
                         HierarchyLevel2__c = 'h2',
                         HierarchyLevel3__c = 'h3')
                    };
                        insert taskList;
        }//end of run as
        System.assertEquals( 1,taskList.size());
    }//end of method static
    
    static testMethod void taskReopened(){

        system.runAs(userAdmin2)
        {
            taskList[0].status = statusOpen;
            test.startTest();
            update taskList;
            test.stopTest();
        }
    }

       

    static testMethod void emailtest(){
        Task t = new Task(subject = 'sub test email',
                     whatid = listCases[0].id,
                     status = statusClosed,
                     HierarchyLevel1__c = 'h1',
                     HierarchyLevel2__c = 'h2',
                     HierarchyLevel3__c = 'h3');
        insert t;
        List<Task> ts= new List<Task>();
        ts.add(t);
        Case c =new Case(Category__c = 'Aspetti tecnici/assuntivi polizza di previdenza - risponde Axa');
        insert c;
        Set<Id> ss=new Set<Id>();
        ss.add(c.id);
        
            test.startTest();
            AP10SendTaskOwnerEmail.sendEmail(ts,ss);
            test.stopTest();
        
    }//end taskReopened
}