@isTest
public class EmailMessageSkipTriggerInvocable_TEST {

    @isTest
    static void test() {
        Test.startTest();
		EmailMessageSkipTriggerInvocable.SetDisableTriggerOnEmailMessage();
        System.assertEquals(true, EmailMessageSkipTriggerInvocable.skipTrigger);
        Test.stopTest();          
    }    
    
}