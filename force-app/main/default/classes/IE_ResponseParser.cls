/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_ResponseParser
Description:   Interface Class with the Parser methods used by the IntegrationEngine
History
 -04/01/2016   Davide Fabris - Created
----------------------------------------------------------------------------*/

public interface IE_ResponseParser{
    //Given all the required info parses a response. The output is a JSON object to allow easy access to any other class
    String ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs,string RawResponse);
    
}