@isTest
private class VFC03_Feedback_Test {
    /*
----------------------------------------------------------------------
-- - Name          : VFC03_Feedback_Test
-- - Author        : Spoon Consulting
-- - Description   : Test class for VFC03_Feedback
--                 
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 31-MAR-2015  HDU   1.0      Initial version 
----------------------------------------------------------------------
*/  static user userAdmin;
    static Account clientAcc;
    //MOSCATELLI_M 14122016: EVO-72-----START
    //static Case complaint;
    static list<Case> complaint;
    static map<String,Id> case_developerIdMap;
    //MOSCATELLI_M 14122016: EVO-72-----END
    static map<String,Id> acc_developerIdMap;
    static map<String, ID> mapRTAcc = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
    //MOSCATELLI_M 14122016: EVO-72-----START
    //static Feedback_Configuration__c Fdbconf;//MOSCATELLI_M 12112015: Evo 37 - Instant Feedback Enhancement
    static list<Feedback_Configuration__c> Fdbconf;
    //MOSCATELLI_M 14122016: EVO-72-----END
    
    
    static{
        system.debug('## >>> START VFC_Feedback_TEST - insert test data <<< run by ' + UserInfo.getUserName());
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
                             ProfileId = AP_Constants.getProfileAdminId()
                            );
        
        insert userAdmin;
        system.runAs(userAdmin){
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            
            //MOSCATELLI_M 12112015: EVO-37-----START 
            
            //MOSCATELLI_M 14122016: EVO-72-----START
            case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
            /*
Fdbconf  = new Feedback_Configuration__c(Question_1__c  = 'Question1', Question_2__c    = 'Question2',
Question_3__c  = 'Question3', Welcome_Message__c   = 'WelcomeMessage',
Error_Message__c   = 'ErrorMessage', Rule_Active__c=true,
Case_Record_Type__c='All');
insert Fdbconf;
*/
            Fdbconf = new list <Feedback_Configuration__c>{
                new Feedback_Configuration__c(Question_1__c='Question1',
                                              Question_2__c='Question2',
                                              Question_3__c='Question3',
                                              Question_4__c='Question4',
                                              Error_Message__c='ErrorMessage',
                                              Rule_Active__c=true,
                                              Case_Record_Type__c='All',
                                              Welcome_Message__c='WelcomeMessage',
                                              Complainant__c='All',
                                              Case_Origin__c ='Email'                             
                                             ),
                    new Feedback_Configuration__c(Question_1__c='Question5',
                                                  Question_2__c='Question6',
                                                  Question_3__c='Question7',
                                                  Question_4__c='Question8',
                                                  Error_Message__c='ErrorMessage',
                                                  Rule_Active__c=true,
                                                  Case_Record_Type__c='Motor',
                                                  Welcome_Message__c='WelcomeMessage',
                                                  Complainant__c='All',
                                                  Case_Origin__c ='Email'
                                                 ),                                                           
                    new Feedback_Configuration__c(Question_1__c='Question9',
                                                  Question_2__c='Question10',
                                                  Question_3__c='Question11',
                                                  Question_4__c='Question12',
                                                  Error_Message__c='ErrorMessage',
                                                  Rule_Active__c=true,
                                                  Case_Record_Type__c='Motor',
                                                  Welcome_Message__c='WelcomeMessage',
                                                  Complainant__c='Customer',
                                                  Case_Origin__c ='Email'
                                                 ),
                    new Feedback_Configuration__c(Question_1__c='Question13',
                                                  Question_2__c='Question14',
                                                  Question_3__c='Question15',
                                                  Question_4__c='Question16',
                                                  Error_Message__c='ErrorMessage',
                                                  Rule_Active__c=true,
                                                  Case_Record_Type__c='All',
                                                  Welcome_Message__c='WelcomeMessage',
                                                  Complainant__c='Customer',
                                                  Case_Origin__c ='Email'
                                                 )}; 
                                                     insert Fdbconf;
            //MOSCATELLI_M 14122016: EVO-72-----END
            
            //MOSCATELLI_M 12112015: EVO-37-----END      
            
            acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
            clientAcc = new Account(FirstName ='Jane',
                                    LastName= 'Smith',
                                    PersonEmail = 'jane.smith@axa-italy-devtest.com',
                                    RecordTypeId = acc_developerIdMap.get(AP_Constants.rtAccIndividualClient),
                                    Matricola__c='123'
                                   );
            
            insert clientAcc;
            
            id idAccount = [Select Id from Account where PersonEmail = 'jane.smith@axa-italy-devtest.com'].Id;
            
            
            //MOSCATELLI_M 14122016: EVO-72-----START
            /*
complaint = new Case(   AccountId = clientAcc.Id,
Subject = 'testSubject',
Description = 'test Description',
Status = 'New');
*/
            complaint = new list<Case>{
                new Case( AccountId = clientAcc.Id,
                         Subject = 'testSubject',
                         Description = 'test Description',
                         Status = 'New',
                         Complainant__c ='Bank Agent',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor)),
                    new Case( AccountId = clientAcc.Id,
                             Subject = 'testSubject',
                             Description = 'test Description',
                             Status = 'New',
                             Complainant__c ='Customer',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor)),
                    new Case( AccountId = clientAcc.Id,
                             Subject = 'testSubject',
                             Description = 'test Description',
                             Status = 'New',
                             Complainant__c ='Customer',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseQuadra)),
                    new Case( AccountId = clientAcc.Id,
                             Subject = 'testSubject',
                             Description = 'test Description',
                             Status = 'New',
                             Complainant__c ='Bank Agent',
                             RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseQuadra))
                    
                    
                    };    
                        //MOSCATELLI_M 14122016: EVO-72-----END
                        insert complaint;
            
            
        }
        system.debug('## >>> END VFC_Feedback_TEST - insert test data <<<');
        
        
        
    }//end static
    
    static testMethod void testHasWithouComplaint() {
        system.runAs(userAdmin){
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            
            PageReference pageRef = Page.VFP03_Feedback;
            Test.setCurrentPage(pageRef);
            
            VFC03_Feedback controller = new VFC03_Feedback();
            
            system.assertEquals(false, controller.hasComplaint);
        }
    }
    static testMethod void testHasComplaintWithFeedback() {
        system.runAs(userAdmin){
            
            //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            //insert acv;
            
            insert new Feedback__c(Complaint__c = complaint[0].Id, Account__c = complaint[0].AccountId, FeedbackComments__c ='test',Survey_Origin__c=AP_Constants.rtFeedbackFromEmail);
            PageReference pageRef = Page.VFP03_Feedback;pageRef.getParameters().put('id', complaint[0].Id);
            pageRef.getParameters().put('recaptcha_challenge_field', 'test challenge');
            pageRef.getParameters().put('recaptcha_response_field', 'test challenge');
            Test.setCurrentPage(pageRef);
            
            VFC03_Feedback controller = new VFC03_Feedback();
            
            system.assertEquals(true, controller.hasComplaint);
            system.assertEquals(true, controller.hasFeedback);
        }
        
    }
    
    static testMethod void testHasComplaintWithoutFeedback() {
        system.runAs(userAdmin){
            PageReference pageRef = Page.VFP03_Feedback;pageRef.getParameters().put('id', complaint[1].Id);
            pageRef.getParameters().put('recaptcha_challenge_field', 'test challenge');
            pageRef.getParameters().put('recaptcha_response_field', 'test challenge');
            Test.setCurrentPage(pageRef);
            
            //AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            //insert acv;     
            
            VFC03_Feedback controller = new VFC03_Feedback();
            //MOSCATELLI_M 14122016: EVO-72-----START
            controller.selected='1';
            controller.SelectedRating1='9';
            controller.setChoiceValue();
            controller.selected='2';
            controller.SelectedRating2='9';
            controller.setChoiceValue();
            controller.selected='3';
            controller.SelectedRating3='9';
            controller.setChoiceValue();
            controller.selected='4';
            controller.SelectedRating4='9';
            controller.setChoiceValue();            
            //MOSCATELLI_M 14122016: EVO-72-----END
            
            //submitForm
            controller.submit();
            
            system.assertEquals(true, controller.hasComplaint);
            system.assertEquals(true, controller.hasFeedback);
            //system.assertEquals(true, controller.verified); CAPOBIANCO_A 16/06/2017 Commented because the CAPTCHA Part was also commented
        }
    }
    static testMethod void testHasComplaintWithoutFeedbackReset() {
        system.runAs(userAdmin){
            PageReference pageRef = Page.VFP03_Feedback;pageRef.getParameters().put('id', complaint[2].Id);
            pageRef.getParameters().put('recaptcha_challenge_field', 'test challenge');
            pageRef.getParameters().put('recaptcha_response_field', 'test challenge');
            Test.setCurrentPage(pageRef);
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            
            VFC03_Feedback controller = new VFC03_Feedback();
            
            //submitForm
            controller.reset();
            
            system.assertEquals(true, controller.hasComplaint);
            system.assertEquals(null, controller.hasFeedback);
            system.assertEquals(false, controller.verified);
        }
    }
    
    static testMethod void testHasComplaintWithoutChallenged() {
        system.runAs(userAdmin){
            PageReference pageRef = Page.VFP03_Feedback;pageRef.getParameters().put('id', complaint[3].Id);
            Test.setCurrentPage(pageRef);
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;    
            
            VFC03_Feedback controller = new VFC03_Feedback();
            
            //submitForm
            controller.submit();
            
            system.assertEquals(true, controller.hasComplaint);
            system.assertEquals(null, controller.hasFeedback);
           // system.assertEquals(false, controller.verified); MOSCATELLI_M 08/06/2018: Google disabled captcha v1 fix
        }
    }
    
    static testMethod void testpublicKey() {
        system.runAs(userAdmin){
            PageReference pageRef = Page.VFP03_Feedback;pageRef.getParameters().put('id', complaint[0].Id);
            Test.setCurrentPage(pageRef);
            
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            insert acv;
            
            VFC03_Feedback controller = new VFC03_Feedback();
            
            //submitForm
            string key = controller.publicKey;
            
            
            system.assertEquals(system.label.reCAPTCHApublicKey, key);
        }
    }
}//end testClass VFC_Feedback_TEST