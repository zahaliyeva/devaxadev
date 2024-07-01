@isTest
public class AF_cloneCase_TEST {
  	static Map<String,Id> Case_DeveloperIdMap;  
  	static Map<String,Id> Acc_DeveloperIdMap;    
	@isTest
    static void test1(){
                User AdminUser = new User(
                            Email ='TestAdm1@Test.com',
                            Username = 'TestAdm1@username.test',
                            FirstName='Test',
                            LastName='User',
                            Alias='tstusr',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = AP_Constants.getProfileAdminId()
                        	);
		insert AdminUser;
        System.runAs(AdminUser){
                    ServiceUtilsClass.populateCustomSettingsForTests();
        
        Case_DeveloperIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        Acc_DeveloperIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        Account newAccount =  new Account(FirstName ='John',
                                                    LastName= 'Smith',
                                                    PersonEmail = 'john.smith@axa-italy-devtest.com',
                                                    RecordTypeId = Acc_DeveloperIdMap.get(AP_Constants.rtAccIntermediary),
                                                    Matricola__c = 'TestST'
                                                   );
        insert newAccount;
        Case newCase = new Case(
           Origin = 'PEC',
           RecordTypeId = Case_DeveloperIdMap.get(AP_Constants.rtCaseAAI),
           Subject = 'Test Case',
           Description = 'This is a test case with related items'
       );
       insert newCase;
        
        Attachment newAttachment = new Attachment(
           ParentId = newCase.Id,
           Name = String.valueOf('TestAttachment.pdf'),
           ContentType	= 'application/pdf',
           Body = Blob.valueOf('Test Attachment Body')
       );
       insert newAttachment;        

       // Creazione di un ContentDocument
       ContentVersion newContent = new ContentVersion(
           Title = 'Test Content',
           PathOnClient = 'Test.csv',
           VersionData = Blob.valueOf('Test Content Body,t2,T3')
       );
       insert newContent;        
       
       // Associazione del ContentDocument appena creato al caso
       ContentDocumentLink cdl = new ContentDocumentLink(
           ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newContent.Id].ContentDocumentId,
           LinkedEntityId = newCase.Id,
           ShareType = 'V'
       );
       insert cdl; 
             
       EmailMessageSkipTriggerInvocable.SetDisableTriggerOnEmailMessage(); 
       // Creazione di un messaggio di posta elettronica associato al caso
       EmailMessage email = new EmailMessage(
           ParentId = newCase.Id,
           Subject = 'Test Email Message',
           TextBody = 'This is a test email message'
       );
       insert email;
        
       // Creazione di un record CtC
       Communications_to_Customer__c newCtc = new Communications_to_Customer__c(
           Status__c = 'Sent',
           CaseId__c = newCase.Id,
           AccountId__c = newAccount.Id
       );
       insert newCtc;
        
       Storico_Chiamate__c  newStoricoChiamate = new Storico_Chiamate__c (
           Case__c = newCase.Id
       );
       insert newStoricoChiamate;
      

        
        LiveChatVisitor newChatVisitor = new LiveChatVisitor(
        );
        insert newChatVisitor;        
        
        LiveChatTranscript newChatTranscript = new LiveChatTranscript(
            CaseId = newCase.Id,
            LiveChatVisitorId = newChatVisitor.Id
        );
        insert newChatTranscript;
        
        List<Case> caseParents = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Axa_Assicurazioni' order by CreatedDate desc];
		System.debug('caseParents:  ' + caseParents);
        String caseId = caseParents[0].Id;
        
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('recordId', caseId);
        
        Test.startTest();
        
        Flow.Interview.cloneCase myFlow = new Flow.Interview.cloneCase(inputs);
        myFlow.start();
        
        Test.stopTest();
        
        List<Case> caseIdCloned = [SELECT Id FROM Case WHERE ParentId =: caseId];
        System.assert(caseIdCloned.size() > 0 );
    }
    }
}