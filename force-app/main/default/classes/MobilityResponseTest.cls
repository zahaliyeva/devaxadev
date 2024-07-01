@isTest
class MobilityResponseTest {
    static testMethod void testResponse() {
        MobilityAccountController.MobilityAccountResponse res = new MobilityAccountController.MobilityAccountResponse();
        system.assert(!res.isSuccess);
        system.debug(res.errorMessage);
    }
}