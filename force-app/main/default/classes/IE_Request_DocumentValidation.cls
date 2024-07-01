public class IE_Request_DocumentValidation implements IE_RequestCompiler {

    public String NameSpacePrefixToUse1 = '';
    public String NameSpacePrefixToUse2 = '';
    public String NameSpaceUriToUse1 = '';
    public String NameSpaceUriToUse2 = '';

    public IE_Integration_Record__c IR;

    public String compileRequest(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs) {
        // initialise the attributes
        this.IR = IR; //passing the IR info to the class instance

        String compiledRequest = IR.RequestBody__c;

        return compiledRequest;
    }
}