/**
 * @description Auth0 Response Parser
 * @author Reply
 * @since 04/2023
 */
public class IE_Auth0_Response implements IE_ResponseParser {
    /**
     * @description 
     * @param IR 
     * @param CR 
     * @param PHs 
     * @param JRs 
     * @param RawResponse 
     * @return  `String`
     */
    public String ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
        String parsedResponse = RawResponse;
        return parsedResponse.replaceAll('-', '_');
    }
}