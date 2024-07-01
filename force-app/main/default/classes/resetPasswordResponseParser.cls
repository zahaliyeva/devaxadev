public without sharing class resetPasswordResponseParser implements IE_ResponseParser{
    public string ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
       
        
        String parsedResponse = RawResponse.replace('email-list', 'emailList').replace('Exception','ExceptionMessage');
     
        return parsedResponse ;
  
    }
}