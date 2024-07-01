public class IE_Request_GetGaranzie implements IE_RequestCompiler{
    public string NameSpacePrefixToUse1 ='';
    public string NameSpacePrefixToUse2 ='';
    public string NameSpaceUriToUse1 ='';
    public string NameSpaceUriToUse2 ='';
    
    Public IE_Integration_Record__c IR;

    public string compileRequest(IE_Integration_Record__c IR, IE_Configuration__c CR, List<IE_Placeholder__c> PHs, List<IE_CR2PH_junction__c> JRs) {
        // initialise the attributes
        this.IR = IR; //passing the IR info to the class instance
        
        
        string compiledrequest = IR.RequestBody__c;
        
        return compiledRequest;
    }
}