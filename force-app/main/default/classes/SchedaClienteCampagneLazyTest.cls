@isTest 
private class SchedaClienteCampagneLazyTest {
    
    @TestSetup
    public static void makeData(){
        SchedaClienteControllerTest.makeData();
    }

    @isTest
    public static void testController(){
        Test.startTest();
        CampaignMember c = [SELECT Id,  Contact.Account.Id FROM CampaignMember LIMIT 1];
        SchedaClienteCampagneLazyController.getRecords(c.Contact.Account.Id, 1);
        SchedaClienteCampagneLazyController.getCount(c.Contact.Account.Id);
        Test.stopTest();
    }

}