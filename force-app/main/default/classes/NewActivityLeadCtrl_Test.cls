@isTest
private class NewActivityLeadCtrl_Test {

//CAPOBIANCO_A 23/06/2017 -- START
    static user userAdmin;
    static list<Lead> leadList;
    static id idAccount;
    static id idLead;
    static Task newTask;
    static Lead leadInserted;
    static id taskRecordType;
    
    static{

        //User
        userAdmin = new User(Username = 'testclassNewActivityLead@test.com',
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
        
        system.runas(userAdmin){

            leadList = new list<Lead>{
                new Lead(FirstName ='John',
                            LastName= 'Smith',
                            Email = 'john.smith@axa-italy-devtest.com',    
                            Phone = '123456',
                            Status = 'To be processed'
                )
            };

            newTask = new Task();

            insert leadList;        
        }
    }
    
    static testMethod void taskCreationSuccess_Test() {
        system.debug('#### Start of method taskCreation_Test');
         system.runAs(userAdmin){
            
            test.starttest();

                Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                taskRecordType = [Select Id From RecordType where sObjectType='Task' and Name='Generico'].Id;               

                PageReference pageRef = Page.NewActivityLead;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('who_id',idLead);
                ApexPages.currentPage().getParameters().put('RecordType',taskRecordType);

                ApexPages.StandardController sc = new ApexPages.StandardController(newTask);
                NewActivityLeadCtrl newTaskCtrl = new NewActivityLeadCtrl(sc);

                //task creation
                newTaskCtrl.getTimesTask(); //CAPOBIANCO_A 18/01/2018 -- SPRINT 59
                newTaskCtrl.newTask.Subject = newTaskCtrl.getSubjectList().get(1).getValue();
                newTaskCtrl.newTask.Status = newTaskCtrl.getStatusList().get(1).getValue();
                newTaskCtrl.newTask.Priority = newTaskCtrl.getPriorityList().get(1).getValue();
                newTaskCtrl.newTask.IsReminderSet = true;
                newTaskCtrl.changeShowReminder();
                List<User> userList = NewActivityLeadCtrl.queryContacts('test testuser');
                List<Lead> leadQuery = NewActivityLeadCtrl.queryLeads('John Smith');
                newTaskCtrl.save();
                
                
            test.stoptest();
            
            list<Task> taskAsrtList = [Select Id
                                        From Task 
                                        Where WhoId =:leadList[0].Id];

            list<Lead> leadAsrtList = [Select Status,Id
                                        From Lead
                                        Where Id =: idLead];

            system.assertEquals(taskAsrtList.size(),1);
            system.assertEquals(userList[0].Id, userAdmin.Id);
            system.assertEquals(leadQuery[0].Id, leadAsrtList[0].Id);
            system.assertEquals(leadAsrtList[0].Status, 'Call again');
         }
    }

    static testMethod void taskCreationFailure_Scenario1_Test() {
        system.debug('#### Start of method taskCreationFailure_Scenario1_Test');
         system.runAs(userAdmin){
            
            test.starttest();

                Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                taskRecordType = [Select Id From RecordType where sObjectType='Task' and Name='Generico'].Id;               

                PageReference pageRef = Page.NewActivityLead;
                Test.setCurrentPage(pageRef);
                //commented to trigger the error
                //ApexPages.currentPage().getParameters().put('who_id',idLead);
                ApexPages.currentPage().getParameters().put('RecordType',taskRecordType);

                ApexPages.StandardController sc = new ApexPages.StandardController(newTask);
                NewActivityLeadCtrl newTaskCtrl = new NewActivityLeadCtrl(sc);

                //task creation
                //commented to trigger the error
                //newTaskCtrl.newTask.Subject = 'J';
                newTaskCtrl.save();
                
            test.stoptest();
            
            list<Task> taskAsrtList = [Select Id
                                        From Task 
                                        Where WhoId =:leadList[0].Id];

            system.assertEquals(taskAsrtList.size(),0); 
         }
    }

    static testMethod void taskCreationFailure_Scenario2_Test() {
        system.debug('#### Start of method taskCreationFailure_Scenario2_Test');
         system.runAs(userAdmin){
            
            test.starttest();

                Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                taskRecordType = [Select Id From RecordType where sObjectType='Task' and Name='Generico'].Id;               

                PageReference pageRef = Page.NewActivityLead;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('who_id',idLead);
                //ApexPages.currentPage().getParameters().put('RecordType',taskRecordType); //commented in order to trigger the 2nd type of error

                ApexPages.StandardController sc = new ApexPages.StandardController(newTask);
                NewActivityLeadCtrl newTaskCtrl = new NewActivityLeadCtrl(sc);

                //task creation
                newTaskCtrl.newTask.Subject = 'J';
                newTaskCtrl.save();
                
            test.stoptest();
            
            list<Task> taskAsrtList = [Select Id
                                        From Task 
                                        Where WhoId =:leadList[0].Id];

            system.assertEquals(taskAsrtList.size(),0); 
         }
    }

    static testMethod void taskCreationFailure_Scenario3_Test() {
        system.debug('#### Start of method taskCreationFailure_Scenario3_Test');
         system.runAs(userAdmin){
            
            test.starttest();

                Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                taskRecordType = [Select Id From RecordType where sObjectType='Task' and Name='Generico'].Id;               

                PageReference pageRef = Page.NewActivityLead;
                Test.setCurrentPage(pageRef);
                
                ApexPages.currentPage().getParameters().put('who_id',idLead);
                ApexPages.currentPage().getParameters().put('RecordType',taskRecordType);

                ApexPages.StandardController sc = new ApexPages.StandardController(newTask);
                NewActivityLeadCtrl newTaskCtrl = new NewActivityLeadCtrl(sc);

                //task creation
                newTaskCtrl.newTask.Subject = 'J';
                newTaskCtrl.cancel();
                
            test.stoptest();
            
            list<Task> taskAsrtList = [Select Id
                                        From Task 
                                        Where WhoId =:leadList[0].Id];

            system.assertEquals(taskAsrtList.size(),0); 
         }
    }
}

//CAPOBIANCO_A 23/06/2017 -- END