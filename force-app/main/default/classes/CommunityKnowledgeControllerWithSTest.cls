@isTest
public class CommunityKnowledgeControllerWithSTest {
    @isTest static void test() {
        Test.startTest();
        CommunityKnowledgeControllerWithSharing.searchClient('Test');
        CommunityKnowledgeControllerWithSharing.searchInsurancePolicy('Test');
        CommunityKnowledgeControllerWithSharing.searchClientByNDG('Test');
        CommunityKnowledgeControllerWithSharing.searchPolicyByName('Test');
        Test.stopTest();          
    }
}