@IsTest
public class BatchSandboxAccount_Test{
    @TestSetup
    static void setup() {
        Account a = new Account (Name='Account Test', Account_email__c = 'test@test.invalid');
        insert a;
    }

    @IsTest
    static void execute() {
        Test.startTest();
        BatchSandboxAccount obj = new BatchSandboxAccount();
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
}