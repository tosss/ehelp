// 04/02/2016- lalitha.adduru@cdk.com- modified test class to use testSetUp so as to avoid dmls in testMethod

@IsTest
public class DS_DocusignRecipientStatus_Test 
{
    
    @testSetUp public static void setUp()
    {
        
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
        
        List<dsfs__DocuSign_Recipient_Status__c> statusList = new List<dsfs__DocuSign_Recipient_Status__c>();
        
        dsfs__DocuSign_Recipient_Status__c drs = DS_TestObjects.newDocusignRecipientStatus();
        drs.dsfs__DocuSign_Recipient_Id__c = testRecipient.id;
        //drs.dsfs__DocuSign_Recipient_Id__c = 'TEST';
        statusList.add(drs);
        
        dsfs__DocuSign_Recipient_Status__c drs2 = DS_TestObjects.newDocusignRecipientStatus();
        drs2.Name = 'SCS Approver';
        drs.dsfs__DocuSign_Recipient_Id__c = testRecipient2.id;
        //drs2.dsfs__DocuSign_Recipient_Id__c = 'TEST1';
        statusList.add(drs2);
        
        dsfs__DocuSign_Recipient_Status__c drs3 = DS_TestObjects.newDocusignRecipientStatus();
        drs.dsfs__DocuSign_Recipient_Id__c = testRecipient3.id;
        drs3.Name = 'CA Approver';
        //drs3.dsfs__DocuSign_Recipient_Id__c = 'TEST3';
        statusList.add(drs3);

        dsfs__DocuSign_Recipient_Status__c drs4 = DS_TestObjects.newDocusignRecipientStatus();
        drs4.Name = 'Any Signer';
        drs.dsfs__DocuSign_Recipient_Id__c = testRecipient4.id;
        //drs4.dsfs__DocuSign_Recipient_Id__c = 'TEST4';
        statusList.add(drs4);
        
        insert statusList;
        
    }
    
    
    public static testmethod void QueryFilterAndUpdateDealState() 
    {   
        List<dsfs__DocuSign_Recipient_Status__c> docRecptStatusList  = new List<dsfs__DocuSign_Recipient_Status__c>();
        
        Test.startTest();
        docRecptStatusList = [
            select id,dsfs__Parent_Status_Record__c,Name,dsfs__Date_Sent__c,dsfs__Date_Delivered__c,dsfs__Recipient_Status__c,Recipient_Signed_on_Paper__c,dsfs__DocuSign_Recipient_Id__c,dsfs__Date_Signed__c
            from dsfs__DocuSign_Recipient_Status__c
        ];
        
        // clone
        Map<id,dsfs__DocuSign_Recipient_Status__c> oldMap = new Map<id,dsfs__DocuSign_Recipient_Status__c>();
        
        List<id> docRecptStatusIdList = new List<id>();
        for(dsfs__DocuSign_Recipient_Status__c status : docRecptStatusList)
        {
            docRecptStatusIdList.add(status.id);
            oldMap.put(status.id, status);            
        }
        
        // test query
        list<dsfs__DocuSign_Recipient_Status__c> QueriedRecipientStatuses 
            = DS_DocusignRecipientStatus_Handler.QueryRecipientStatuses(docRecptStatusIdList);
        
        // test filter
        DS_DocusignRecipientStatus_Handler.FilterIdsToProcessAfterInsert(docRecptStatusList);        
        
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
        
        docRecptStatusList[1].dsfs__DocuSign_Routing_Order__c = 1;
        docRecptStatusList[0].dsfs__Date_Signed__c = Datetime.newInstance(2015,01,01,00,00,00);
        docRecptStatusList[0].dsfs__Date_Delivered__c = Datetime.newInstance(2015,02,01,00,00,00);
                
        DS_DocusignRecipientStatus_Handler.FilterIdsToProcessAfterUpdate(docRecptStatusList, oldMap);
        Test.stopTest();
    }
    
}