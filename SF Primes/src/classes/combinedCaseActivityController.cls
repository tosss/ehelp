//2015-11-24- anirudh.singh@cdk.com- Modified the API Version from 19.0 to 34.0.
public class combinedCaseActivityController
{
    public List<combinedCaseActivity> caseCommentEmailList {get;set;}  // Ultimate list we'll populate to power the in-page repeater (main list)
    public Map<DateTime, combinedCaseActivity> commentMap {get;set;} // Map with comments from both email and comments
    public List<DateTime> dateList {get;set;} // Sortable date list to extract sorting function
    
    private ApexPages.StandardController controller {get; set;}  // Extending standard controller so we can display this page in-line
    private Case thisCase;  // Current case
    
    // Constructor
    public combinedCaseActivityController(ApexPages.StandardController controller)
    {
        this.controller = controller;  // create the controller
        this.thisCase = (Case)controller.getRecord();  // Get case from standard controller
        
        Integer lengthOfString = 2000;  // Set to preferred number of characters in final list output
        
        dateList = new List<DateTime>();  // Instantiating sortable date list
        commentMap = new Map<DateTime, combinedCaseActivity>();  // Instantiating map
        caseCommentEmailList = new List<combinedCaseActivity>();  // Instantiating final list
        
        Case thisCaseComplete = [
            SELECT Id, 
            CaseNumber, 
            (SELECT Id, CommentBody, CreatedDate, CreatedBy.Name 
             FROM CaseComments), 
            (SELECT Id, Subject, CreatedDate, CreatedBy.Name
             FROM EmailMessages), 
            (SELECT Id, Subject, Type, CreatedDate, CreatedBy.Name, Description
             FROM Tasks
             WHERE Status = 'Completed')
            FROM Case
            WHERE Id = :thisCase.Id
        ];
        
        /*  // Placed in line in the comment section to speed page up.
        // Fix strings for caseComments (line feeds)
        for (CaseComment cc : thisCaseComplete.CaseComments){
        if (cc.CommentBody != null){
        cc.CommentBody = cc.CommentBody.replaceAll( '\n', '<br/>' );
        }
        }
        */
        
        Integer commentNum = 1;  // This builds case number outputs
        for (Task t : thisCaseComplete.Tasks)
        {
            combinedCaseActivity thisTask = new CombinedCaseActivity();
            thisTask.urlId = t.Id;
            thisTask.caseId = thisCaseComplete.CaseNumber + '-' + commentNum;
            thisTask.lineType = 'Task';
            thisTask.dateCreatedStr = t.CreatedDate.format();
            thisTask.createdBy = t.CreatedBy.Name;
            integer i = 0;
            if (t.Description != null)
            {
                if (t.Description.length() < lengthOfString)
                {
                    i = t.Description.length();
                    thisTask.subjectString = t.Description.subString(0,i);
                }
                else
                {
                    i = lengthOfString;
                    thisTask.subjectString = t.Description.subString(0,i-3)+'...';
                }
                thisTask.subjectString = thisTask.subjectString.replaceAll('\n','<br/>');
            }
            // Added following on 9/8/2010 per request of Ann Brommer
            
            commentMap.put(t.CreatedDate, thisTask);
            dateList.add(t.CreatedDate);
            commentNum++;
        }
        
        // This loop populates the combined map and sortable date list with comments
        for (CaseComment c : thisCaseComplete.CaseComments)
        {
            combinedCaseActivity thisComment = new combinedCaseActivity();
            thisComment.urlId = c.Id;
            integer i = 0;
            if (c.CommentBody != null)
            {
                if (c.CommentBody.length() < lengthOfString)
                {
                    i = c.CommentBody.length();
                    thisComment.subjectString = c.CommentBody.subString(0,i);
                }
                else
                {
                    i = lengthOfString;
                    thisComment.subjectString = c.CommentBody.subString(0,i-3)+'...';
                }
            }
            // Added following on 9/8/2010 per request of Ann Brommer
            thisComment.subjectString = thisComment.subjectString.replaceAll('\n','<br/>');
            thisComment.caseID = thisCaseComplete.CaseNumber + '-' + commentNum;
            thisComment.lineType = 'Comment';
            thisComment.dateCreatedStr = c.CreatedDate.format(); 
            thisComment.createdBy = c.CreatedBy.Name;
            commentMap.put(c.CreatedDate, thisComment);
            dateList.add(c.CreatedDate);
            commentNum++;
        }
        
        /*  Emails are covered by tasks - disabling due to redundancy
        for (EmailMessage e : thisCaseComplete.EmailMessages){  // This loop populates the combined map and sortable date list with emails
        combinedCaseActivity thisEmail = new combinedCaseActivity();
        thisEmail.urlId = e.Id;
        integer i = 0;
        if (e.Subject.length() < lengthOfString){
        i = e.Subject.length();
        thisEmail.subjectString = e.Subject.subString(0,i);
        } else {
        i = lengthOfString;
        thisEmail.subjectString = e.Subject.subString(0,i-3)+'...';
        }
        thisEmail.lineType = 'Email';
        thisEmail.dateCreatedStr = e.CreatedDate.format(); 
        thisEmail.createdBy = e.CreatedBy.Name;
        commentMap.put(e.CreatedDate, thisEmail);
        dateList.add(e.CreatedDate);
        }
        */
        
        dateList.sort();  // Sorts ascending
        
        List<DateTime> dateListDESC = new List<DateTime>();  // New list for descending datelist
        
        // this loop re-sorts date list descending
        for (Integer i=dateList.size()-1; i>=0; i--)
        {
            dateListDESC.add(dateList[i]);
        }
        
        // This loop takes sorted date list and builds final list for output by grabbing string values from map using date as a key
        for (DateTime d : dateListDESC)
        {
            caseCommentEmailList.add(commentMap.get(d));
        }
    }
}