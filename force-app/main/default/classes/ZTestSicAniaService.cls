@isTest
public class ZTestSicAniaService {
    
    @testSetup static void setup() {
        SICANIAIntegration__c sicaniaIntegration = new SICANIAIntegration__c();
        sicaniaIntegration.CounterPartiesEndpoint__c = 'https://axaitalia--dev4.cs82.my.salesforce.com/home/home.jsp';
        sicaniaIntegration.RequestTokenEndpoint__c = 'https://axaitalia--dev4.cs82.my.salesforce.com/home/home.jsp';
        sicaniaIntegration.ValidateTokenEndpoint__c = 'https://axaitalia--dev4.cs82.my.salesforce.com/home/home.jsp';
        sicaniaIntegration.Name = 'sicaniaIntegration';
        
        
        insert sicaniaIntegration;
    }
    
    
    @isTest
    public static void test_invokeSicAnia(){
        SicAniaMockHttpResponseGenerator mock = new SicAniaMockHttpResponseGenerator();
        mock.serviceName = 'requestToken';
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        CAISicAniaService.invokeSicAnia('AA230BB','Policy-123','Policy-123', 'abcdefghi', 'user@axa.it', 'AA230BB');
        Test.stopTest();
    }
    
    @isTest
    public static void test_invokeSicAniaCounterParties(){
        CAIServiceWrapper wrapper = new CAIServiceWrapper();
        wrapper.counterPartiesRequestWrapper.plateCounterParties = 'aa123bb';
        wrapper.tokenResponseWrapper.token = 'abcd';
        SicAniaMockHttpResponseGenerator mock = new SicAniaMockHttpResponseGenerator();
        mock.serviceName = 'requestCounterParties';
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        CAISicAniaService.counterParties(wrapper);
        Test.stopTest();
    }

}