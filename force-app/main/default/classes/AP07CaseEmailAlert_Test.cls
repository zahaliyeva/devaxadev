@isTest
private class AP07CaseEmailAlert_Test {
/*
----------------------------------------------------------------------------------------------------
-- - Name          : AP07CaseEmailAlert_Test
-- - Author        :    
-- - Description   : Test Methods for AP07CaseEmailAlert
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------------------------------------
-- 13-03-2015   HDU     1.0     
----------------------------------------------------------------------------------------------------
****************************************************************************************************
*/
    static id profileId;
    static map<String,Id> case_developerIdMap;//MOSCATELLI_M 16072015: CR-15
    static user userAdmin;
    static list <Case> listCases;
    static list<EmailMessage> listEmails;
    static list<Email_For_Notification_To_Advisor__c> listCustomSettings;
    
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
        
        //OAVERSANO 27/03/2019 : AXA Assistance -- START
        List<MPS_Code_Variables__c> codeVariables = new List<MPS_Code_Variables__c>();
        MPS_Code_Variables__c alert = new MPS_Code_Variables__c(name = 'AP07CaseEmailAlert_sendAlertToOwner', value__c = 'true');
        codeVariables.add(alert);
        MPS_Code_Variables__c template = new MPS_Code_Variables__c(name = 'AP07CaseEmailAlert_templateNameAgente', value__c = 'test');
        codeVariables.add(template);
        MPS_Code_Variables__c reT = new MPS_Code_Variables__c(name = 'AP07CaseEmailAlert_RecordTypeTemplate', value__c = 'Sinistri_AAI;');
        codeVariables.add(reT);
        insert codeVariables;
        //OAVERSANO 27/03/2019 : AXA Assistance -- END
        
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
                //MOSCATELLI_M 16072015: CR-15-----START
                //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
                //new Case(Category__c = 'Aspetti tecnici/assuntivi polizza di previdenza - risponde Axa',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)),
                //new Case(Category__c = 'Duplicati polizza di protezione - risponde Axa',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor))
                
                new Case(Category__c = 'Aspetti tecnici/assuntivi polizza di previdenza - risponde Axa',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)),
                new Case(Category__c = 'Aspetti tecnici/assuntivi polizza di previdenza - risponde Axa',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor)),
                new Case(Category__c = 'Operatività sulla polizza - Polizze auto',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor)),
                new Case(Category__c = 'Documenti polizza Auto',RecordTypeId=case_developerIdMap.get('Close_the_loop')),
                new Case(Category__c = 'Operatività sulla polizza di risparmio',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseQuadra)),
                new Case(Category__c = 'Documenti polizza Auto',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseAAI)),
                new Case(Category__c = 'Aspetti tecnici/assuntivi polizza di previdenza - risponde Axa',RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseNonMotor))
                
                //CAPOBIANCO_A 30/03/2017 BUGFIX --- END
                //MOSCATELLI_M 16072015: CR-15-----END
            };
            
            insert listCases;
        }//end of run as
    }//end of method static
    @isTest
    static void  notifyEmailAlertTest(){
        //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
        listCustomSettings = new list<Email_For_Notification_To_Advisor__c>{
            new Email_For_Notification_To_Advisor__c (Name='NonMotor',OrgId__c=UserInfo.getOrganizationId()),
            new Email_For_Notification_To_Advisor__c (Name='Motor',OrgId__c=UserInfo.getOrganizationId()),
            new Email_For_Notification_To_Advisor__c (Name='Quadra',OrgId__c=UserInfo.getOrganizationId()),
            new Email_For_Notification_To_Advisor__c (Name='Axa_Assicurazioni',OrgId__c=UserInfo.getOrganizationId())
         };
        //CAPOBIANCO_A 30/03/2017 BUGFIX --- END
             
        listEmails = new list<EmailMessage>{
             //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
             //new EmailMessage( parentId=listCases[0].id, Incoming=true ),            
             //new EmailMessage( parentId=listCases[1].id, Incoming=false )
             new EmailMessage( parentId=listCases[0].id, toAddress='masterdevcases@gmail.com', Incoming=true ),
             new EmailMessage( parentId=listCases[1].id, toAddress='axaplanet@gmail.com', Incoming=true ),
             new EmailMessage( parentId=listCases[2].id, toAddress='axaplanet@gmail.com', Incoming=true ),
             new EmailMessage( parentId=listCases[3].id, toAddress='axaplanet@gmail.com', Incoming=true ),
             new EmailMessage( parentId=listCases[4].id, toAddress='axaplanet@gmail.com', Incoming=true ),
             new EmailMessage( parentId=listCases[5].id, toAddress='axaplanet@gmail.com', Incoming=true ),
             new EmailMessage( parentId=listCases[6].id, toAddress='masterdevcases@gmail.com', Incoming=false )
             //CAPOBIANCO_A 30/03/2017 BUGFIX --- END
        };
        Test.startTest();
            insert listEmails;
        	insert listCustomSettings;
        Test.stopTest();
        list<EmailMessage> listEmailResult = new list<EmailMessage>([select Id from EmailMessage]);
        // System.assertEquals(2, listEmailResult.size() );
        System.assertEquals(7, listEmailResult.size() ); //CAPOBIANCO_A 30/03/2017 BUGFIX
    }// end of test method
    @isTest
    static void  caseFromUserToQueueTest(){
        
        system.runas(userAdmin){
            Group g = new Group(Type='Queue', Name='Queue name');
            insert g;
            
            QueueSObject q = new QueueSObject(SobjectType='Case', QueueId=g.Id);
            insert q; 
                
            Case c = new Case(subject='test',status = AP_Constants.caseStatusAssigned );
            insert c;
            c.ownerId = g.Id;
            Test.startTest();
                update c;
            Test.stopTest();
            Case resultCase  = new list<Case>([SELECT status from Case where id  = :c.id])[0];
            System.assertEquals(AP_Constants.caseStatusOpen, resultCase.status);
        }
    }// end of test method
    @isTest
    static void  notifyEmailAlertForTaskOwnerTest(){
        system.runas(userAdmin){
            listCases[0].Status = AP_Constants.caseStatusPending;
            update listCases[0];
            insert new task(Status = AP_Constants.taskStatusPending ,whatid = listCases[0].id, subject = 's');
            
            listEmails = new list<EmailMessage>{
                 new EmailMessage( parentId=listCases[0].id, Incoming=true ),           
                 new EmailMessage( parentId=listCases[1].id, Incoming=false )
            };
            
            Test.startTest();
                insert listEmails;
            Test.stopTest();
            list<EmailMessage> listEmailResult = new list<EmailMessage>([select Id from EmailMessage]);
            System.assertEquals(2, listEmailResult.size() );
        }
    }// end of test method
}// end of class