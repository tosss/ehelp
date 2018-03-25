trigger CB_CaseClosedEmailRecResponse_trg on EmailMessage (after insert) 
{
    String strReplyToAddress = 'noreply@cobaltgroup.com';
    
    for (EmailMessage msg : trigger.new)
    {
        System.debug('Inside Trigger');
        
        Case selCase = [SELECT c.RecordTypeId, c.Status, c.CaseNumber FROM Case c WHERE c.Id =:msg.ParentId];
        
        if(selCase != null)
        {
            String recTypeId = selCase.RecordTypeId;
            
            RecordType recType = [SELECT rt.Id, rt.Name,rt.DEVELOPERNAME from RecordType rt WHERE rt.Id =: recTypeId];
            
            if ((recType.DEVELOPERNAME=='Tier_1' || recType.DEVELOPERNAME== 'Content' || recType.DEVELOPERNAME=='Tier_2_ETS') 
            && (selCase.Status=='Closed') && (msg.Incoming == true))
            { 
                try 
                {
                    OrgWideEmailAddress replyEmail 
                        = [SELECT ID, DisplayName FROM OrgWideEmailAddress WHERE Address =: 'noreply@cobaltgroup.com'];
                    
                    Messaging.SingleEmailMessage mailOut = new Messaging.SingleEmailMessage();
                    
                    mailOut.setToAddresses(new String[]{msg.FromAddress});
                    // mailOut.setSenderDisplayName('Case Administrator');
                    mailOut.setReplyTo(strReplyToAddress);
                    mailOut.setOrgWideEmailAddressId(replyEmail.Id);
                    
                    //As we need to send email to From address of email messages we cannot use email templates.
                    mailOut.setSubject('Case #'+selCase.CaseNumber+' is already closed');
                    mailOut.setPlainTextBody('Case #'+selCase.CaseNumber +' is closed and your email cannot be processed. '
                    	+ 'Please create a new case by sending a new email to your usual support address. '
                    	+ 'Replies to closed cases are unable to be processed. '
                    	+ 'Do not copy/paste any system generated text into the new request or we may be unable to process your request. ');
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailOut });
                }
                catch (Exception ex)
                {
                    msg.addError(ex);
                } // end try catch
            } 
        } // end if selCase != null
    } // end for Trigger New
}