/*..............................................................................
. Author		:	lalitha.adduru@cdk.com                     
. Description	:	Webservice to send out an email 
.					of request details on click of a button " Email Request"
.					on Request__c
. History			
. July 2015		:	Lalitha Adduru modified the method sendEmailRequest
.					to take an array of emails as argument instead of one email
.					and removed Name argument since it is a single email to 
.					multiple users.
. 27th July 2015:	Lalitha Adduru Modified sendEmailRequest method to handle 
.					duplicate email addresses.
...............................................................................*/

global class DS_RequestSendEmail 
{
    /*....................................................................... 
	. Author		: 	lalitha.adduru@cdk.com                            	
    . Description	:	This method sends out an email of request details          	
	. Arguments		:	Request Id, URL of record, array of email addresses,
	.					message to be prefixed to the email.
    .......................................................................*/
    webservice static void sendEmailRequest(Id recordId, String recordLink, String[] emailAddresses, String message)
    {
        Request__c req = null;
        
        // soql to get the relevant request details
        list<Request__c> reqs = [
            select id, Name, Details__c, Business_Justification__c, Deployment_Strategy__c,
            Request_ID__c, Status__c, Internal_Priority__c,
            Internal_Comments__c, Initial_Estimate__c  
            from Request__c 
            where id =: recordId];
        
        if(reqs != null && !reqs.isEmpty())
        { 
            req = reqs.get(0);
        }
        
        // creating an instance of message class for a single email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        
        // removing duplicates from emailAddress List
        Set<String> uniqueEmailAddresses = new Set<String>(emailAddresses);
        
        // setting the list of email addresses that should recieve an email
        List<String> toAddresses = new List<String>(uniqueEmailAddresses) ;        
        mail.setToAddresses(toAddresses); 
        
        // setting the subject of the email
        mail.setSubject('Request '+req.Request_ID__c+' Detail');        
        
        // forming the body of the email with our required values
        String body = 'Hi, ' + 
            '<br /><br />' + message + 
            '<br /><br />' + req.Request_ID__c + '<br />' + string.valueof(req.Name == null ? '' : req.name ) + ' ' + '<br />' + recordLink +
            '<br /><br />' + '<hr align="left" style="border-top: dotted 1px;" width="10%" />' + 'Details:' + '<br />' + string.valueof(req.Details__c == null ? '' : req.Details__c )+
            '<br /><br />' + '<hr align="left" style="border-top: dotted 1px;" width="10%" />' + 'Business Justification:' + '<br />' + string.valueof(req.Business_Justification__c == null ? '' : req.Business_Justification__c) +
            '<br /><br />' + '<hr align="left" style="border-top: dotted 1px;" width="10%" />' + 'Status:' + '<br />' + string.valueof(req.Status__c == null ? '' : req.Status__C) + 
            '<br /><br />' + '<hr align="left" style="border-top: dotted 1px;" width="10%" />' + 'Deployment Strategy: ' + '<br />' + string.valueof(req.Deployment_Strategy__c == null ? '' : req.Deployment_Strategy__c) +
            '<br /><br />' + '<hr align="left" style="border-top: dotted 1px;" width="10%" />' + 'Internal Priority: ' + '<br />' + string.valueof(req.Internal_Priority__c == null ? '' : req.Internal_Priority__c )+
            '<br /><br />' + '<hr align="left" style="border-top: dotted 1px;" width="10%" />' + 'Internal Comments: ' + '<br />' + string.valueof(req.Internal_Comments__c == null ? '' : req.Internal_Comments__c) +
            '<br /><br />' + '<hr align="left" style="border-top: dotted 1px;" width="10%" />' + 'Initial Estimate: ' + '<br />' + string.valueof(req.Initial_Estimate__c == null ? '' : string.valueof(req.Initial_Estimate__c) );
        
        // set the body of the email to be sent
        mail.setHTMLBody(body); 
        
        // list of all attachments to be sent
        List<Attachment> attachments = [
            SELECT Id, Name, Body, ContentType 
            FROM Attachment 
            WHERE Parentid =: req.Id
        ];
        
        List<Note> notes = [
            select Id, CreatedBy.Name, title, Body 
            from Note 
            where parentid =: req.Id
        ];
        
        // list of email attachments
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        
        // creating email attachments from Notes and attachments
        for(Attachment att : attachments) 
        {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            efa.setContentType(att.ContentType);
            emailAttachments.add(efa);
        }
        
        for(Note n : notes)
        {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(n.title+'.doc');
            efa.Body = Blob.valueOf('Created By : '+n.CreatedBy.Name+ '\n\n'+ n.Body);
            emailAttachments.add(efa);
        }
        
        // setting email attachments with the ones that we created
        mail.setFileAttachments(emailAttachments);
        
        // sending emails
        Messaging.sendEmail(new Messaging.SingleEMailMessage[]{mail});        
    }
}