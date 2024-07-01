/**
 * Created by Augens on 19/11/2018.
 */

@IsTest
public class LiveChatTranscriptManagement_TEST {

    @TestSetup
    static void setup() {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        Account acc = new Account(Name = 'myAccountTest');
        insert acc;

        Case c = new Case(Status = 'Open',
                Phone_Call_Ids__c = '',
                Origin = 'Portale Assistenza',
                Category__c = 'ATR',
                SubCategory__c = '');
        insert c;

        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        insert chatVisitor;
    }

    @IsTest
    static void AfterInsertTriggerTest() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'myAccountTest'];

        Case c = [SELECT Id FROM Case LIMIT 1];

        LiveChatVisitor chatVisitor = [SELECT Id FROM LiveChatVisitor LIMIT 1];

        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(AccountId = acc.Id,
                LiveChatVisitorId = chatVisitor.Id,
                CaseId = c.Id);

        Test.startTest();
        Database.SaveResult result = Database.insert(liveChatTranscript, false);
        System.assert(result.isSuccess());
        Test.stopTest();

    }
    @IsTest
    static void AfterUpdateTriggerTest() {

        Account acc = [SELECT Id FROM Account WHERE Name = 'myAccountTest'];

        Case c = [SELECT Id FROM Case LIMIT 1];

        LiveChatVisitor chatVisitor = [SELECT Id FROM LiveChatVisitor LIMIT 1];

        LiveChatTranscript liveChatTranscript1 = new LiveChatTranscript(AccountId = acc.Id,
                LiveChatVisitorId = chatVisitor.Id,
                CaseId = c.Id);
        insert liveChatTranscript1;

        liveChatTranscript1.Browser = 'Firefox 61.0';

        Test.startTest();
        Database.SaveResult updateResult = Database.update(liveChatTranscript1, false);
        System.assert(updateResult.isSuccess());
        Test.stopTest();

    }
}