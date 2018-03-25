@IsTest
public class DS_DocusignRecipientStatus_Test 
{
    public static testmethod void QueryFilterAndUpdateDealState() 
    {
        Opportunity o = DS_TestObjects.NewOpportunity_Inserted();
        
        Deal_State__c DealState = new Deal_State__c();
        DealState.Quantity_of_Sites__c = 2;
        DealState.Opportunity__c = o.Id;
        try { insert DealState; } catch(Exception e) { system.debug(e); }
        
        dsfs__Docusign_Status__c DocusignStatus = new dsfs__DocuSign_Status__c();
        DocusignStatus.Deal_State__c = DealState.Id;
        insert DocusignStatus;
        
        //03/17/2015 Venkata.shrivol@cdk.com - Added map to pass the test coverage
        list<Docusign_Recipient__c> dRecLst = new list<Docusign_Recipient__c>();
        Docusign_Recipient__c testRecipient = new Docusign_Recipient__c();
        testRecipient.Name = 'Legal Counter Signer';
        testRecipient.Email__c = 'docusign.anysigner@cdk.com';
        testRecipient.Routing_Order__c = 20;
        testRecipient.Alternate_Routing_Order__c = 5;
        dRecLst.add(testRecipient);
        
        Docusign_Recipient__c testRecipient2 = new Docusign_Recipient__c();
        testRecipient2.Name = 'SCS';
        testRecipient2.Email__c = 'scs.docusign@cdk.com';
        testRecipient2.Routing_Order__c = 5;
        testRecipient2.Alternate_Routing_Order__c = 3;
        dRecLst.add(testRecipient2);
        
        Docusign_Recipient__c testRecipient3 = new Docusign_Recipient__c();
        testRecipient3.Name = 'CA';
        testRecipient3.Routing_Order__c = 10;
        testRecipient3.Alternate_Routing_Order__c = 4;
        dRecLst.add(testRecipient3);
        
        Docusign_Recipient__c testRecipient4 = new Docusign_Recipient__c();
        testRecipient4.Name = 'CRA Signer';
        testRecipient4.Routing_Order__c = 25;
        testRecipient4.Email__c = 'cra.anysigner@cdk.com';
        testRecipient4.Alternate_Routing_Order__c = 6;
        dRecLst.add(testRecipient4);
        insert dRecLst;
        
        dsfs__DocuSign_Recipient_Status__c drs = new dsfs__DocuSign_Recipient_Status__c();
        drs.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        drs.Name = 'TEST';
        drs.dsfs__Recipient_Status__c = 'Sent';
        drs.Recipient_Signed_on_Paper__c = 'yes';
        drs.dsfs__DocuSign_Recipient_Id__c = 'TEST';
        drs.dsfs__Date_Signed__c = system.today();
        drs.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        insert drs;
        
        dsfs__DocuSign_Recipient_Status__c drs2 = new dsfs__DocuSign_Recipient_Status__c();
        drs2.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        drs2.Name = 'SCS Approver';
        drs2.dsfs__Recipient_Status__c = 'Sent';
        drs2.Recipient_Signed_on_Paper__c = 'yes';
        drs2.dsfs__DocuSign_Recipient_Id__c = 'TEST1';
        drs2.dsfs__Date_Signed__c = system.today();
        drs2.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        insert drs2;

        dsfs__DocuSign_Recipient_Status__c drs3 = new dsfs__DocuSign_Recipient_Status__c();
        drs3.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        drs3.Name = 'CA Approver';
        drs3.dsfs__Recipient_Status__c = 'Sent';
        drs3.Recipient_Signed_on_Paper__c = 'yes';
        drs3.dsfs__DocuSign_Recipient_Id__c = 'TEST3';
        drs3.dsfs__Date_Signed__c = system.today();
        drs3.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        insert drs3;

        dsfs__DocuSign_Recipient_Status__c drs4 = new dsfs__DocuSign_Recipient_Status__c();
        drs4.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        drs4.Name = 'Any Signer';
        drs4.dsfs__Recipient_Status__c = 'Sent';
        drs4.Recipient_Signed_on_Paper__c = 'yes';
        drs4.dsfs__DocuSign_Recipient_Id__c = 'TEST4';
        drs4.dsfs__Date_Signed__c = system.today();
        drs4.dsfs__Parent_Status_Record__c = DocusignStatus.Id;
        insert drs4;

        
        // test query
        list<dsfs__DocuSign_Recipient_Status__c> QueriedRecipientStatuses 
            = DS_DocusignRecipientStatus_Handler.QueryRecipientStatuses(new list<Id>{drs.Id,drs2.Id,drs3.Id,drs4.Id});
        
        // test filter
        DS_DocusignRecipientStatus_Handler.FilterIdsToProcessAfterInsert(new list<dsfs__DocuSign_Recipient_Status__c>{drs,drs2,drs3,drs4});
        
        
        
        // test deal state update
        list<dsfs__DocuSign_Recipient_Status__c> qrs = null;
        if(QueriedRecipientStatuses != null && !QueriedRecipientStatuses.isEmpty()) {
            qrs = QueriedRecipientStatuses; }
        
        if(qrs != null)
        {
            qrs[0].dsfs__DocuSign_Routing_Order__c = 1;
            DS_DocusignRecipientStatus_Handler.UpdateDealStates(new list<dsfs__DocuSign_Recipient_Status__c>{qrs[0]});
            
            qrs[0].dsfs__DocuSign_Routing_Order__c = 2;
            DS_DocusignRecipientStatus_Handler.UpdateDealStates(new list<dsfs__DocuSign_Recipient_Status__c>{qrs[0]});
            
            qrs[1].dsfs__DocuSign_Routing_Order__c = 3;
            DS_DocusignRecipientStatus_Handler.UpdateDealStates(new list<dsfs__DocuSign_Recipient_Status__c>{qrs[1]});
            
            
            qrs[2].dsfs__DocuSign_Routing_Order__c = 4;
            DS_DocusignRecipientStatus_Handler.UpdateDealStates(new list<dsfs__DocuSign_Recipient_Status__c>{qrs[2]});
            
            qrs[3].dsfs__DocuSign_Routing_Order__c = 5;
            DS_DocusignRecipientStatus_Handler.UpdateDealStates(new list<dsfs__DocuSign_Recipient_Status__c>{qrs[3]});
            
            qrs[3].dsfs__DocuSign_Routing_Order__c = 6;
            DS_DocusignRecipientStatus_Handler.UpdateDealStates(new list<dsfs__DocuSign_Recipient_Status__c>{qrs[3]});
        }
        
        
        drs.dsfs__Date_Signed__c = Datetime.newInstance(2015,01,01,00,00,00);
        
        update drs;
       
    }
    
}