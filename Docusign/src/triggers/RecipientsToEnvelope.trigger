trigger RecipientsToEnvelope on dsfs__DocuSign_Envelope__c (after insert) 
{
    List<Docusign_Recipient__c> rcpList = Docusign_Recipient__c.getAll().values();
    List<dsfs__DocuSign_Envelope_Recipient__c> rcps = new List<dsfs__DocuSign_Envelope_Recipient__c>();
    for(dsfs__DocuSign_Envelope__c env : Trigger.New)
    {
        for(Docusign_Recipient__c rcp:rcpList)
        {
            dsfs__DocuSign_Envelope_Recipient__c envRcp= new dsfs__DocuSign_Envelope_Recipient__c();
            envRcp.dsfs__DocuSign_EnvelopeID__c = env.Id;
            envRcp.dsfs__DocuSign_Signature_Name__c = rcp.Full_Name__c;
            envRcp.dsfs__SignInPersonName__c = rcp.Full_Name__c;
            envRcp.dsfs__SignInPersonEmail__c = rcp.Email__c;
            envRcp.dsfs__Routing_Order__c = rcp.Routing_Order__c;
            envRcp.dsfs__DocuSign_Recipient_Role__c = rcp.Signer_Role__c;
            envRcp.dsfs__Salesforce_Recipient_Type__c = 'Default';
            rcps.add(envRcp);
        }
    }
    insert rcps;    
}