/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_RequestCompiler
Description:   Interface Class with the Compiler methods used by the IntegrationEngine
History
 -30/12/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/

public interface IE_RequestCompiler{
    //Given all the required info compiles a request
    String compileRequest(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs);
    
    
    //IE_RequestCompiler init(IE_Integration_Record__c IR);
    //List<IE_CR2PH_junction__c> getJRs (Id ConfigId); 
    //List<IE_Placeholder__c> getPHs (List<IE_CR2PH_junction__c> JRs);
    
}