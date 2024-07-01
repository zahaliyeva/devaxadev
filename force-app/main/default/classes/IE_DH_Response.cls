/**
 * @description DH Response Parser
 * @author Reply
 * @since 04/2023
 */
public class IE_DH_Response implements IE_ResponseParser {
    /**
     * @description 
     * @param IR Integration Record
     * @param CR Configuration Record
     * @param PHs 
     * @param JRs 
     * @param RawResponse 
     * @return  `String` parsed response
     */
    public String ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
        String parsedResponse = RawResponse;
        return parsedResponse;
    }
}