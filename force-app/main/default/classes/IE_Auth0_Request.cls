/**
 * @description Auth0 Request Compiler
 * @author Reply
 * @since 04/2023
 */
public with sharing class IE_Auth0_Request implements IE_RequestCompiler {
 	
    public String NameSpacePrefixToUse1 = '';
    public String NameSpacePrefixToUse2 = '';
    public String NameSpaceUriToUse1 = '';
    public String NameSpaceUriToUse2 = '';

    public IE_Integration_Record__c IR;

    /**
     * @description Request compiler
     * @param IR Integration record
     * @param CR Configuration R+record
     * @param PHs 
     * @param JRs 
     * @return  `String` request compiled
     */
    public String compileRequest(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs) {
        // initialise the attributes
        this.IR = IR; //passing the IR info to the class instance

        String compiledRequest = IR.RequestBody__c;

        return compiledRequest;
    }
}