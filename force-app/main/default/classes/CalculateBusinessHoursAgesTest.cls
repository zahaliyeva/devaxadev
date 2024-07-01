@IsTest
public class CalculateBusinessHoursAgesTest {
    public static testMethod void testBusinessHoursBucketer() {
        List<Stop_Status__c> ss = new List<Stop_Status__c>{
                                                            new Stop_Status__c(Name = 'Delegated', Object_Type__c='Case'),
                                                            new Stop_Status__c(Name = 'Pending', Object_Type__c='Case'),
                                                            new Stop_Status__c(Name = 'Pending', Object_Type__c='Task'),
                                                            new Stop_Status__c(Name = 'Attività dispositive in attesa di verifica', Object_Type__c='Case')
                                                          };
        insert ss;
        
        //MOSCATELLI_M 25062015: Creation of a test user to avoid the failing of the Apex Test due to the validation rule CannotReturnToNewStatus----START
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'HoursAgesTestUser', Email='HoursAgesTestUser@test.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='HoursAgesTestUser@test.com',ByPassVR__c = true);
        //MOSCATELLI_M 25062015: Creation of a test user to avoid the failing of the Apex Test due to the validation rule CannotReturnToNewStatus----END
        
        Configurazione_attivita_dispositive__c  ConfAttDisp = new Configurazione_attivita_dispositive__c(Name='TEST',Category__c='Cat',SubCategory__c='SubCat',Days_until_verification__c=1);        
        
        System.RunAs(u) //MOSCATELLI_M 25062015: Creation of a test user to avoid the failing of the Apex Test due to the validation rule CannotReturnToNewStatus
        {   //MOSCATELLI_M 25062015: Creation of a test user to avoid the failing of the Apex Test due to the validation rule CannotReturnToNewStatus----START

            insert ConfAttDisp;
            //MOSCATELLI_M 29042016:EVO 51--START
            Account acc = new Account(FirstName='Test',LastName='AccountT');
            insert acc;
            Case c = new Case(AccountId=acc.Id,Category__c='Cat',SubCategory__c = 'SubCat');            
            //Case c = new Case();
            //MOSCATELLI_M 29042016:EVO 51--END
            c.Status = 'New';
            c.Last_Status_Change__c = System.Now();
            insert c;
    
            c.Status = 'Pending';
            update c;
            
            c.Status = 'Delegated';
            update c;
            Test.startTest();
            c.Status = 'Attività dispositive in attesa di verifica';
            update c;
    
            c.Status = 'New';
            update c; 
    
            Case updatedCase = [select Time_With_Customer__c,Time_With_Support__c,Case_Age_In_Business_Hours__c,Time_for_Applicative_activities__c from Case where Id=:c.Id];
            System.assert(updatedCase.Time_With_Customer__c!=null);
            System.assert(updatedCase.Time_With_Support__c!=null);
            System.assert(updatedCase.Time_for_Applicative_activities__c!=null);
            System.assert(updatedCase.Case_Age_In_Business_Hours__c==null);
    
            c.Status = 'Closed';
            update c;
    		Test.stopTest();
            updatedCase = [select Time_With_Customer__c,Time_With_Support__c,Case_Age_In_Business_Hours__c,Time_for_Applicative_activities__c from Case where Id=:c.Id];
    
            System.assert(updatedCase.Time_With_Customer__c!=null);
            System.assert(updatedCase.Time_With_Support__c!=null);
            System.assert(updatedCase.Time_for_Applicative_activities__c!=null);
            //System.assert(updatedCase.Case_Age_In_Business_Hours__c!=null);
        }//MOSCATELLI_M 25062015: Creation of a test user to avoid the failing of the Apex Test due to the validation rule CannotReturnToNewStatus----END
    }

    //CAPOBIANCO_A 14/06/2017 EVO 85 -- START
    public static testMethod void testBusinessHoursBucketer_AntiLaunderingMeasures() {
        List<Stop_Status__c> ss = new List<Stop_Status__c>{
                                                            new Stop_Status__c(Name = AP_Constants.caseStatusVerificaAttAntiRic, Object_Type__c='Case')
                                                          };
        insert ss;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'HoursAgesTestUser', Email='HoursAgesTestUser@test.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='HoursAgesTestUser@test.com',ByPassVR__c = true);
        
        System.RunAs(u)  
        {   
            Account acc = new Account(FirstName='Test',LastName='AccountT');
            insert acc;
            Case c = new Case(AccountId=acc.Id);            
            c.Status = 'New';
            c.Last_Status_Change__c = System.Now();
            insert c;

            c.Status = 'Delegated';
            update c;

            Case updatedCase = [select Time_With_Customer__c,Time_With_Support__c, Case_Age_In_Business_Hours__c from Case where Id=:c.Id];
            System.assertEquals(updatedCase.Time_With_Customer__c,0.0);
            System.assert(updatedCase.Time_With_Support__c!=null);
            System.assert(updatedCase.Case_Age_In_Business_Hours__c==null);

            c.Status = AP_Constants.caseStatusVerificaAttAntiRic;
            update c;
            Double timeWithSupport = updatedCase.Time_With_Support__c;

            updatedCase = [select Time_With_Customer__c,Time_With_Support__c, Case_Age_In_Business_Hours__c, Svolta_Attivita_Antiriciclaggio__c from Case where Id=:c.Id];        
            System.assertEquals(updatedCase.Time_With_Support__c, timeWithSupport);
            System.assert(updatedCase.Case_Age_In_Business_Hours__c==null);
            //System.assertEquals(updatedCase.Svolta_Attivita_Antiriciclaggio__c, true);        
        }
    }
    //CAPOBIANCO_A 14/06/2017 EVO 85 -- END
}