@isTest
public with sharing class SendEmailTriggerTest {

    @IsTest
    public static void testSendEmailTrigger(){
        Test.startTest();
        EventBus.publish(new SendEmail__e(Type__c='Invalid Extension', AttachmentName__c = 'Test', CaseSubjectReference__c = 'Subject', Recipient__c = 'a.t@t.it'));
        Test.stopTest();
    }

}