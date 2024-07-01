@isTest
public class MobilityUserControllerTest {
    static testMethod void testUser() {
     
        Map<String,List< Object>> Map1 = new Map<String,List< Object>>();
        List<String> Lista = new List<String>();
        
		Test.startTest();
        
        MobilityUserController.getUserPartners(10,2,Map1,'Name','ASC','Name');
        MobilityUserController.getQueues(10,2,Map1,'QueueId','ASC','QueueId');
        MobilityUserController.getCurrentUser();
        MobilityUserController.getUserAgency();
        //MobilityUserController.changeOwner('Campaign',Lista,'7016E000000HHPKQA4');
        //MobilityUserController.changeOwnerData('Campaign',Lista,'7016E000000HHPKQA4');
        Test.stopTest();
    }
}