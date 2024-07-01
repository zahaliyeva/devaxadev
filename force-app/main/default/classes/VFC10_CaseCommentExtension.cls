public with sharing class VFC10_CaseCommentExtension {
    private final Case caseRec;
    public CaseComment comment {get; set;}

    public VFC10_CaseCommentExtension(ApexPages.StandardController controller) {
        caseRec = (Case)controller.getRecord();
        comment = new CaseComment();
        comment.parentid = caseRec.id;
    }

    public PageReference addComment() {
        insert comment;
        comment = new CaseComment();
        comment.parentid = caseRec.id;
        return null;
    }   
}