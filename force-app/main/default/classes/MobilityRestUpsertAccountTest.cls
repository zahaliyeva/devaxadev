@isTest
global class MobilityRestUpsertAccountTest {
    @isTest static void testUpsert(){
        MobilityRestUpsertAccount.RequestUpsertAccount req = new MobilityRestUpsertAccount.RequestUpsertAccount();
        req.account=new Account(name='company',NDG__c='CMP');
        Test.startTest();
        List<MobilityRestUpsertAccount.ResponseUpsertAccount> res=MobilityRestUpsertAccount.upsertAccount(req);
        Test.stopTest();
        System.assert(res[0].result.recordId!=null);
        System.assertEquals(1, [select id from account].size());
    }
    @isTest static void testUpsertNoAccount(){
        MobilityRestUpsertAccount.RequestUpsertAccount req = new MobilityRestUpsertAccount.RequestUpsertAccount();
        RestContext.response=new System.RestResponse();
        Test.startTest();
        List<MobilityRestUpsertAccount.ResponseUpsertAccount> res=MobilityRestUpsertAccount.upsertAccount(req);       
        Test.stopTest();
        System.assertEquals(0, [select id from account].size());      
    }
    @isTest static void testUpsertAccountNoNDG(){
        MobilityRestUpsertAccount.RequestUpsertAccount req = new MobilityRestUpsertAccount.RequestUpsertAccount();
        req.account=new Account(name='company');
        RestContext.response=new System.RestResponse();
        Test.startTest();
        List<MobilityRestUpsertAccount.ResponseUpsertAccount> res=MobilityRestUpsertAccount.upsertAccount(req);
        Test.stopTest();
        System.assertEquals(0, [select id from account].size());                
    }
}