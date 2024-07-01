@IsTest
public class CalculateBusinessHoursAgesTaskTest {
     static Account TestAccount;
    public static testMethod void testBusinessHoursBucketer() {
        Stop_Status__c ss = new Stop_Status__c(Name = 'On Hold');
        insert ss;
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        //MOSCATELLI_M 25062015: Creation of a test user to avoid the failing of the Apex Test due to the validation rule CannotReturnToNewStatus-----START
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'Hours', Email='HoursAgesTestUser@test.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='HoursAgesTestUser@test.com',ByPassVR__c = true);
        //MOSCATELLI_M 25062015: Creation of a test user to avoid the failing of the Apex Test due to the validation rule CannotReturnToNewStatus-----END

        System.RunAs(u) 
        {   
        
        TestAccount = new Account(FirstName = 'test',
                                  LastName  = 'AP01',
                                  Servizio__c = '',
                                  PersonEmail = 'test@ap01.com',
                                  RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id);
        
        insert TestAccount;
        
         id idAccount = [Select Id from Account where PersonEmail = 'test@ap01.com'].Id;
        
        date mydate = date.today();
        
        Entitlement en = new Entitlement();
        en.Name='TestEntitlement';
        en.AccountId = idAccount;
        en.StartDate = mydate;
        insert en;
         
            Case c = new Case();
            c.Status = 'New';
            c.Last_Status_Change__c = System.Now();
            insert c;
    
            c.Status = 'On Hold';
            update c;
    
            //c.Status = 'New';
           //Test.startTest();
           // update c;
           //Test.stopTest();
    
            Case updatedCase = [select Time_With_Customer__c,Time_With_Support__c,Case_Age_In_Business_Hours__c from Case where Id=:c.Id];
            system.debug('CasaMassimo: '+updatedCase);
            System.assert(updatedCase.Time_With_Customer__c!=null);
            System.assert(updatedCase.Time_With_Support__c!=null);
            System.assert(updatedCase.Case_Age_In_Business_Hours__c==null);
            
            //classe test per task
            
            Task t = new Task();
            t.Status = 'Open';
            t.WhatId=c.Id;
            t.Last_Status_Change__c = System.Now();
            insert t;
    
            Test.startTest();//MOSCATELLI_M 29042016:EVO 51
            t.Status = 'On Hold';
            update t;            
			
            t.Status = 'Open';
            //Test.startTest(); MOSCATELLI_M 29042016:EVO 51 -- COMMENTED
            update t;
            Test.stopTest();
            
            Task updatedTask = [select Time_With_Customer__c,Time_With_Technical_Office__c,Task_Age_In_Business_Hours__c from Task where Id=:t.Id];
            system.debug('TaskUpd: '+updatedTask);
            System.assert(updatedTask.Time_With_Customer__c!=null);
            System.assert(updatedTask.Time_With_Technical_Office__c!=null);
            System.assert(updatedTask.Task_Age_in_Business_Hours__c==null);
            
            
            
        }
    }
}