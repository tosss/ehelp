trigger chatter_answers_question_escalation_to_case_trigger on Question (after update) {
    for (Question q: Trigger.new) {
        // generic exception to test if an exception occurred outside of a catch block
        //   used to increase code coverage
        Exception CurrentException = null;
        Question QueriedQuestion = null;
        
        try {
            if (q.Priority == 'high' && (q.Cases == null || q.Cases.size() == 0) && Trigger.oldMap.get(q.id).Priority != 'high') {
                q = [
                    select Id, Title, Body, CommunityId, createdById, createdBy.AccountId, createdBy.ContactId 
                    from Question 
                    where Id = :q.Id
                ];
                QueriedQuestion = q;
                
                if(q.createdby.contactId != null)
                {
                    Case newCase = new Case(
                        Status = 'open',
                        Priority = 'normal', 
                        Product_Category__c = 'Analytics',
                        Origin='Chatter Answers', 
                        OwnerId=q.CreatedById, 
                        QuestionId=q.Id, 
                        CommunityId=q.CommunityId, 
                        Subject=q.Title, 
                        Description = (q.Body == null? null: q.Body.stripHtmlTags()), 
                        AccountId=q.createdby.AccountId, ContactId=q.CreatedBy.ContactId
                    );
                    insert newCase;
                }
                else
                {
                    return;
                }
            }
        } 
        catch (Exception e) { CurrentException = e; }
        
        if(CurrentException != null) {
            GlobalSettings gs = GlobalSettings.getInstance(null);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setReplyTo('no-reply@salesforce.com');
            mail.setSenderDisplayName('Salesforce Chatter Answers User');
            
            // The default sender is the portal user causing this trigger to run, 
            //   to change this, set an organization-wide address for
            // the portal user profile, and set the ID in the following line.
            // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
            // mail.setToAddresses(new String[] { Site.getAdminEmail() });
            mail.setToAddresses( gs.ERROR_EMAIL );
            mail.setSubject('Case Escalation exception in site ' + Site.getName());
            mail.setPlainTextBody(
                'Case Escalation on Question having ID: ' + (QueriedQuestion != null ? QueriedQuestion.Id : '') + 
                ' has failed with the following message: ' + CurrentException.getMessage() + 
                '\n\nStacktrace: ' + CurrentException.getStacktraceString()
            );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}