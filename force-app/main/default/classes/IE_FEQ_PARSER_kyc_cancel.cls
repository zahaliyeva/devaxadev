/**
 * @description Feq response parser
 * @author Reply
 * @since 04/2023
 */
public class IE_FEQ_PARSER_kyc_cancel implements IE_ResponseParser {
    /**
     * @description 
     * @param IR Integration record
     * @param CR Configuration record
     * @param PHs 
     * @param JRs 
     * @param RawResponse raw response
     * @return  `String` parsed response
     */
    public String ParseResponse(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs, string RawResponse) {
        String parsedResponse = RawResponse;
        return parsedResponse;
    }
}