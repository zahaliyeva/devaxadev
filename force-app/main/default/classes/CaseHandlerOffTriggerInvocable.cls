public with sharing class CaseHandlerOffTriggerInvocable {
  @InvocableMethod(Label = 'Disable Trigger on Case and Chat Transcript'description = 'for Disable trigger  CASE running on flow or proc builder')
  public static void SetDisableTriggerOnCase (){
    CaseHandler.RunTrigger = false;
    LiveChatTranscriptHandler.RunTrigger = false ;
  }
}