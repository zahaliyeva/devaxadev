@isTest
private class NewEventLeadCtrl_Test {

//CAPOBIANCO_A 23/06/2017 -- START
    static user userAdmin;
    static list<Lead> leadList;
    static id idLead;
    static Event newEvent;
    static Lead leadInserted;
    static id eventRecordType;
    
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

            newEvent = new Event();

            insert leadList;        
        }
    }
    
    static testMethod void eventCreationSuccess_Test() {
        system.debug('#### Start of method taskCreation_Test');
         system.runAs(userAdmin){
            
            test.starttest();

                Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                eventRecordType = [Select Id From RecordType where sObjectType='Event' and Name='AAI - Event'].Id;               

                PageReference pageRef = Page.NewEventLead;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('who_id',idLead);
                ApexPages.currentPage().getParameters().put('RecordType',eventRecordType);

                ApexPages.StandardController sc = new ApexPages.StandardController(newEvent);
                NewEventLeadCtrl newEventCtrl = new NewEventLeadCtrl(sc);

                //Event creation
                newEventCtrl.newEvent.Subject = newEventCtrl.getSubjectList().get(1).getValue();
                newEventCtrl.newEvent.StartDateTime =  System.today();
                newEventCtrl.newEvent.EndDateTime = System.today()+1;
                newEventCtrl.newEvent.IsReminderSet = true;
                newEventCtrl.newEvent.Type = newEventCtrl.getTypeList().get(1).getValue();
                newEventCtrl.newEvent.ShowAs = newEventCtrl.getShowTimeAsList().get(1).getValue();
                //CAPOBIANCO_A 18/01/2018 -- START
                newEventCtrl.getInTimesAppointment();
                newEventCtrl.getOutTimesAppointment();
                newEventCtrl.updateEventEndTime();
                //CAPOBIANCO_A 18/01/2018 -- END
                newEventCtrl.changeShowReminder();
                List<User> userList = NewEventLeadCtrl.queryContacts('test testuser');
                List<Lead> leadQuery = NewEventLeadCtrl.queryLeads('John Smith');
                newEventCtrl.save();
                
            test.stoptest();
            
            list<Event> eventAsrtList = [Select Id
                                        From Event 
                                        Where WhoId =:leadList[0].Id];
            list<Lead> leadAsrtList = [Select Status
            							From Lead
            							Where Id =: idLead];

            system.assertEquals(eventAsrtList.size(),1); 
            system.assertEquals(leadAsrtList[0].Status, 'Appointment');
            system.assertEquals(userList[0].Id, userAdmin.Id);
            system.assertEquals(leadQuery[0].Id, leadAsrtList[0].Id);
         }
    }

    static testMethod void eventCreationFailure_Scenario1_Test() {
        system.debug('#### Start of method taskCreation_Test');
         system.runAs(userAdmin){
            
            test.starttest();

               	Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                eventRecordType = [Select Id From RecordType where sObjectType='Event' and Name='AAI - Event'].Id;               
				
                PageReference pageRef = Page.NewEventLead;
                Test.setCurrentPage(pageRef);
                //commented in order to trigger the error
                //ApexPages.currentPage().getParameters().put('who_id',idLead);
                ApexPages.currentPage().getParameters().put('RecordType',eventRecordType);

                ApexPages.StandardController sc = new ApexPages.StandardController(newEvent);             
                NewEventLeadCtrl newEventCtrl = new NewEventLeadCtrl(sc);

                //Event creation
                //commented in order to trigger the error
                //newEventCtrl.newEvent.Subject = 'J';
                //newEventCtrl.newEvent.StartDateTime =  System.today();
                //newEventCtrl.newEvent.EndDateTime = System.today()+1;
                newEventCtrl.save();
                
            test.stoptest();
            
            list<Task> taskAsrtList = [Select Id
                                        From Task 
                                        Where WhoId =:leadList[0].Id];

            system.assertEquals(taskAsrtList.size(),0); 
         }
    }

    static testMethod void eventCreationFailure_Scenario2_Test() {
        system.debug('#### Start of method eventCreationFailure_Scenario2_Test');
         system.runAs(userAdmin){
            
            test.starttest();

                Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                eventRecordType = [Select Id From RecordType where sObjectType='Event' and Name='AAI - Event'].Id;               

                PageReference pageRef = Page.NewEventLead;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('who_id',idLead);
                //ApexPages.currentPage().getParameters().put('RecordType',eventRecordType); commented to trigger the 2nd type of error

                ApexPages.StandardController sc = new ApexPages.StandardController(newEvent);
                NewEventLeadCtrl newEventCtrl = new NewEventLeadCtrl(sc);

                //Event creation
                newEventCtrl.newEvent.Subject = 'J';
                newEventCtrl.newEvent.StartDateTime =  System.today();
                newEventCtrl.newEvent.EndDateTime = System.today()+1;
                newEventCtrl.save();
                
            test.stoptest();
            
            list<Task> taskAsrtList = [Select Id
                                        From Task 
                                        Where WhoId =:leadList[0].Id];

            system.assertEquals(taskAsrtList.size(),0); 
         }
    }

    static testMethod void eventCreationFailure_Scenario3_Test() {
        system.debug('#### Start of method eventCreationFailure_Scenario3_Test');
         system.runAs(userAdmin){
            
            test.starttest();

                Lead leadInserted = [Select Id From Lead where Email = 'john.smith@axa-italy-devtest.com'];
                Id idLead = leadInserted.Id;
                eventRecordType = [Select Id From RecordType where sObjectType='Event' and Name='AAI - Event'].Id;               

                PageReference pageRef = Page.NewEventLead;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('who_id',idLead);
                //ApexPages.currentPage().getParameters().put('RecordType',eventRecordType); commented to trigger the 2nd type of error

                ApexPages.StandardController sc = new ApexPages.StandardController(newEvent);
                NewEventLeadCtrl newEventCtrl = new NewEventLeadCtrl(sc);

                //Event creation
                newEventCtrl.newEvent.Subject = 'J';
                newEventCtrl.cancel();
                
            test.stoptest();
            
            list<Task> taskAsrtList = [Select Id
                                        From Task 
                                        Where WhoId =:leadList[0].Id];

            system.assertEquals(taskAsrtList.size(),0); 
         }
    }
}

//CAPOBIANCO_A 23/06/2017 -- END