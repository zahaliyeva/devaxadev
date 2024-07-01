@isTest
public without sharing class BatchHidePolizzeTest {
    
@TestSetup
static void makeData(){
    Account a = new Account(lastname = 'test');
    insert a;
    InsurancePolicy__c p = new InsurancePolicy__c (CUID__c = a.Id,datacheck__c = System.Today().addYears(-4));
    insert p;
    insert new Claim__c(Polizza__c=p.Id);
}

@isTest
static void runBatch(){
    Test.startTest();
    BatchHidePolizze batch = new BatchHidePolizze();
    Database.executeBatch(batch);
    Test.stopTest();

    List<Account> a = [select id from Account where isHidden__c = true ];
    List<InsurancePolicy__c> p = [select id from InsurancePolicy__c where isHidden__c = true ];
    List<Claim__c> c = [select id from Claim__c where isHidden__c = true ];
    Assert.areEqual(1, a.size(),'Account Not Hidden');
    Assert.areEqual(1, p.size(),'Polizza Not Hidden');
    Assert.areEqual(1, c.size(), 'Claim Not Hidden');
}

}