/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         IE_SOLClaimOpening_Response_parser
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

4/10/2018     Created 
-------------------------------------------------------------------------------------------*/
public without sharing class IE_SOLClaimOpening_Response_parser implements IE_ResponseParser
{	
    public string ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) 
    {
	       
	    String parsedResponse = RawResponse;
	     
	    return parsedResponse ;
	}
}