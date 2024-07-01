@isTest
private class LiveAgentChatCmpCTRL_TEST {

  @isTest static void test_getContactIdCurrentUser()
  {
    // Implement test code
    User iam = [SELECT ContactId,Name FROM User where id =: UserInfo.getUserId()];

    Contact myC = LiveAgentChatCmpCTRL.getContact(iam.ContactId);
      
    if (myC != null)
      System.assertEquals(iam.ContactId, myC.Id);

    Contact con = LiveAgentChatCmpCTRL.getContact(iam.ContactId);
  }

}