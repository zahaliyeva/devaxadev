@isTest
public class IntegrationRecordInsertTest {
    @testSetup private static void createData(){

    }
    
    @isTest static void test() {
        Test.startTest();
        IE_Integration_Record__c ir = new IE_Integration_Record__c();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/xyz'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(ir));
        
        RestContext.request = req;
        RestContext.response= res;
        IntegrationRecordInsert.create();
        Test.stopTest();          
    }
}