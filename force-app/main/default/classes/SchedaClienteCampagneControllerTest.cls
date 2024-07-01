@isTest 
private class SchedaClienteCampagneControllerTest {
    
    @TestSetup
    public static void makeData(){
        SchedaClienteControllerTest.makeData();
    }

    @isTest
    public static void testController(){
        Test.startTest();
        CampaignMember c = [SELECT Id,  Contact.Account.Id FROM CampaignMember LIMIT 1];
        SchedaClienteCampagneController.getCampaignMembers(c.Contact.Account.Id);
        Test.stopTest();
    }
}