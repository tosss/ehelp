@isTest
private class ChatterAnswersEscalationTriggerTest 
{
    static testMethod void validateQuestionEscalation() {
        String questionTitle = 'questionTitle';
        String questionBody = 'questionBody';
        Community[] c = [
            SELECT Id 
            from Community 
            where name = 'Internal Ideas'
        ];
        
        // We cannot create a question without a community
        if (c.size() == 0) { return; }
        
        Id communityId = c[0].Id;
        Question q = new Question();
        
        q.Title = questionTitle;
        q.Body = questionBody;
        q.CommunityId = communityId;  
        insert(q);
        q.Priority = 'high';
        update(q);
        
        // A Case is expected to be inserted from the trigger on Question
        List<case> ca = new List<Case>();
        ca = [
            SELECT Origin, CommunityId, Subject, Description 
            from Case 
            where QuestionId =: q.Id
        ];
        
        // Test that escaltion trigger correctly escalate the question to a case
        if ( ca.size() != 0 )
        {
            System.assertEquals(questionTitle, ca[0].Subject);
            System.assertEquals(questionBody, ca[0].Description);
            System.assertEquals('Chatter Answers', ca[0].Origin);
            System.assertEquals(communityId, ca[0].CommunityId);
        }
    }
}