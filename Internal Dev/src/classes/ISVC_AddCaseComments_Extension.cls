// GLOBIT-3924: Create Publisher Action for adding comments to related cases
//
// 2017-10-12 marta.malinowska@cdk.com Created
public with sharing class ISVC_AddCaseComments_Extension {

    private Id caseId;
    public CaseComment caseComment {get; set;}
    public Boolean copyCommentsToRelatedCases {get; set;}

    public ISVC_AddCaseComments_Extension(ApexPages.StandardController controller) {
        caseId = controller.getId();
        initCaseComment();
    }

    public PageReference addCaseComments() {
        List<CaseComment> caseComments = new List<CaseComment>();
        caseComments.add(caseComment);
        if(copyCommentsToRelatedCases){
            for(Case relatedCase : [
                    SELECT Id FROM Case
                    WHERE ParentId = :caseComment.ParentId
                    		AND IsClosed = false]){
                CaseComment caseCommentCopy = new CaseComment();
                caseCommentCopy.ParentId = relatedCase.Id;
                caseCommentCopy.CommentBody = caseComment.CommentBody;
                caseComments.add(caseCommentCopy);
            }
        }
        try {
            insert caseComments;
            initCaseComment();            
        } catch(DmlException ex){
        		ApexPages.addMessages(ex);
        }
        
        return null;
    }

    private void initCaseComment(){
        caseComment = new CaseComment();
        caseComment.ParentId = caseId;
        copyCommentsToRelatedCases = false;
    }
}