@isTest
public with sharing class VFC03_FeedbackBot_TEST {

  
   @testSetup static void methodName() {

      map<String, ID> mapRTAcc = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
      map<String,Id> case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
   

      LiveChatVisitor visitor = new LiveChatVisitor( );
      insert visitor ;

     Account clientAcc = new Account(FirstName ='Jane',
                              LastName= 'Smith',
                              PersonEmail = 'jane.smith@axa-italy-devtest.com',
                              RecordTypeId = mapRTAcc.get(AP_Constants.rtAccIndividualClient),
                              Matricola__c='123'
                             );
      
      insert clientAcc;
      
      Case casoChat = new Case( AccountId = clientAcc.Id,
                         Subject = 'Chat case',
                         Description = 'test Description',
                         Status = 'New',
                         Complainant__c ='Bank Agent',
                         RecordTypeId=case_developerIdMap.get(AP_Constants.rtCaseMotor));

      insert casoChat;
     
      LiveChatTranscript chatLive = new LiveChatTranscript ();
      chatLive.LiveChatVisitorId = visitor.id ;
		chatLive.Status = 'Completed' ;
      chatLive.Body = '<p align="center">Chat Started: Wednesday, February 16, 2022, 17:22:38AXA.Letizia: Dimmidi seguito.<br>';
      chatLive.StartTime = System.now() ;
      chatLive.chatkey = '639A6fd2-G410-4212-8d76-66facab7571f';
      chatLive.EndTime = System.now().addMinutes(1) ;
      chatLive.CaseId = casoChat.id;

      insert chatLive ;

   }
 
      @isTest
    static void testChatTrans(){
      List <LiveChatTranscript> chatsSetup = new List <LiveChatTranscript> ();
      chatsSetup = [select id,status,chatkey  from LiveChatTranscript];
      Case caseChat = [select id  from Case limit 1];

      PageReference pageRef = Page.VFP03_FeddbackChatBot;
      pageRef.getParameters().put('chatDetails','{"agent":{"userId":"0Xx0D000000CaSZSA0","agentName":"Letizia","transfer":1}}');
      pageRef.getParameters().put('chatKey',chatsSetup[0].chatkey);
      pageRef.getParameters().put('attachedRecords', '{"CaseId":"'+caseChat.id+'"}');

      Test.setCurrentPage(pageRef);
            
      VFC03_FeedbackBot controller = new VFC03_FeedbackBot();
      controller.getTextData();
      controller.setTextData('commentario');
      controller.NPS = '10' ;

      //submitForm
      controller.commenta();
      controller.vota();
      
     
      controller.setTextData('');
      controller.NPS = '5' ;
      controller.commenta();
      
      controller.vota();
      controller.getFileContents();
     
      List<Feedback__c> feedbakcs = [select id,Complaint__c, FeedbackComments__c, NPS__c from Feedback__c limit 10];
      System.assert(feedbakcs.size()!=0);
    }

    @isTest
    static void testChatErrors(){
      List <LiveChatTranscript> chatsSetup = new List <LiveChatTranscript> ();
      chatsSetup = [select id,status,chatkey  from LiveChatTranscript];
      Account accountId = [select id  from Account limit 1];

      PageReference pageRef = Page.VFP03_FeddbackChatBot;
      pageRef.getParameters().put('chatDetails','{"agent":{"userId":"0Xx0D000000CaSZSA0","agentName":"Letizia","transfer"1}}');
      pageRef.getParameters().put('chatKey',chatsSetup[0].chatkey);
      pageRef.getParameters().put('attachedRecords', '{"CaseId":"null"}');

      Test.setCurrentPage(pageRef);
            
      VFC03_FeedbackBot controller = new VFC03_FeedbackBot();
      controller.getTextData();
      controller.setTextData('null');
      controller.NPS = 'numero' ;

      //submitForm
      controller.commenta();
      controller.vota();
      controller.getCaseIdRelated(new Map < String, Object >(), 'chatkey');
      controller.getTranscriptFormat('transcript');

    }
}