@isTest
private class InsertAMLEmailMessage_TEST {
   @isTest
   static void testInsertMessage() {
       // Create test data
       ServiceUtilsClass.populateCustomSettingsForTests();
       Map<String,Id> Case_DeveloperIdMap;  
       Case_DeveloperIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);

       List<Contact> testContacts = new List<Contact>{
           new Contact(FirstName = 'Test Contact 1',LastName = 'Last 1', Email = 'test1@example.com'),
           new Contact(FirstName = 'Test Contact 2',LastName = 'Last 2', Email = 'test2@example.com')
       };
       insert testContacts;
       List<Case> testCases = new List<Case>{
           new Case( ContactId = testContacts[0].Id, SuppliedEmail = 'test1@example.com', RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseAAI)),
           new Case( SuppliedEmail = 'test2@example.com', RecordTypeId=Case_DeveloperIdMap.get(AP_Constants.rtCaseAAI))
       };
       insert testCases;
       // Call the insertMessage method
       Test.startTest();
       InsertAMLEmailMessage.insertMessage(testCases);
       Test.stopTest();
       // Assert on the expected behavior
       List<EmailMessage> createdEmailMessages = [SELECT Subject, FromAddress, ToAddress, HtmlBody FROM EmailMessage];
       System.assertEquals(2, createdEmailMessages.size(), 'Expected 2 EmailMessages to be created');
       // Add more specific assertions based on your requirements
       //System.assertEquals('smartcenteraxamps@axa.it', createdEmailMessages[0].FromAddress);
       System.assertEquals('test1@example.com', createdEmailMessages[0].ToAddress);
       System.assertNotEquals(null, createdEmailMessages[0].HtmlBody);
       // Similar assertions for the second EmailMessage
       //System.assertEquals('smartcenteraxamps@axa.it', createdEmailMessages[1].FromAddress);
       System.assertEquals('test2@example.com', createdEmailMessages[1].ToAddress);
       System.assertNotEquals(null, createdEmailMessages[1].HtmlBody);
   }
}