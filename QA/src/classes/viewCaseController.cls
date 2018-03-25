//2015-11-24- anirudh.singh@cdk.com- Modified the API Version from 19.0 to 34.0.
public class viewCaseController
{
    public CaseComment thisComment {get;set;}
    public String thisCaseCommentId {get;set;}
    public Case thisCase {get;set;}
    
    public viewCaseController()
    {
        //Retrieve case comment details based on URL Id
        thisComment = [
            SELECT Id, IsPublished, CommentBody
            FROM CaseComment 
            WHERE Id = :ApexPages.currentPage().getParameters().get('caseCommentID')
        ];
        
        //Retrieve generated CaseCommentId from URL
        thisCaseCommentId = ApexPages.currentPage().getParameters().get('commentId');
        
        //Retrieve case details based on URL Id
        thisCase = [
            SELECT Id , Subject, Description
            FROM Case 
            WHERE Id = :ApexPages.currentPage().getParameters().get('caseId')
        ];
        
        // Fix output strings so they look right on the page 
        if(thisComment.commentBody != null) thisComment.commentBody = thisComment.commentBody.replaceAll( '\n', '<br/>' );
        if(thisCase.Description != null) thisCase.Description = thisCase.Description.replaceAll( '\n', '<br/>' );
        if(thisCase.Subject != null) thisCase.Subject = thisCase.Subject.replaceAll( '\n', '<br/>' );
    }
    
    // Simple method to build URL for previous case and redirect user
    public PageReference returnToCase()
    {
        PageReference previousCase = new PageReference('/'+thisCase.Id);
        return previousCase;
    }
}