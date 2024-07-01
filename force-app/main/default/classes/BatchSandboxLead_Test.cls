@IsTest
public class BatchSandboxLead_Test{
    @TestSetup
    static void setup() {
        Lead l = new Lead (LastName= 'LeadTest', Email = 'test@test.invalid');
        insert l;
    }

    @IsTest
    static void execute() {
        Test.startTest();
        BatchSandboxLead obj = new BatchSandboxLead();
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
}