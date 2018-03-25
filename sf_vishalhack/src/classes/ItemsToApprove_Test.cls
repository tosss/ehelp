//2015-01-06- vishal.bandari@cdk.com- Created this class for ItemsToApprove_Controller.
//2016-06-17- anirudh.singh@cdk.com- Modified the class to remove dependency on Approval Process and increase the Test Coverage.
@IsTest
public class ItemsToApprove_Test
{
    @TestSetup
    private static void setupData()
    {
        //Create a sample LAO Record.
        Laser_Artwork_Order__c laoRecord=DS_TestObjects.NewLaserArtworkOrder();
        laoRecord.Order_Type__c='Add/Change - DASH';
        laoRecord.Order_Status__c='Artwork to LFD Team';
        //2016-06-06 -venkata.shrivol@cdk.com -commented this line as this field is inserting from NewLaserArtworkOrder()
        //laoRecord.LFD_Name__c=Userinfo.getUserId();
        laoRecord.Artwork_Due_Date__c=DateTime.now().adddays(15);
        laoRecord.Artwork_to_LFD_Team__c=DateTime.now();
        laoRecord.Proofs_Required__c='No';
        laoRecord.Prev_SO__c='123';
        laoRecord.Contract_PO__c='1234';
        laoRecord.Change_Notes__c='text area';
        //2015-12-22 matt.keefe@cdk.com - updated to satisfy validation
        laoRecord.Quote_Type__c='Contracted';
        insert laoRecord;
    }
    
    private static testMethod void rerenderTableTest()
    {
        Laser_Artwork_Order__c laoRecord=[SELECT Id, RecordTypeId FROM Laser_Artwork_Order__c];
        List<ProcessDefinition> approvalProcessRecordsList=[SELECT Name, TableEnumOrId FROM ProcessDefinition WHERE TableEnumOrId='Laser_Artwork_Order__c' AND State='Active' ORDER BY Name];
        
        Approval.ProcessSubmitRequest req=new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(laoRecord.Id);
        req.setProcessDefinitionNameOrId(approvalProcessRecordsList[0].Name);
        req.setSkipEntryCriteria(true);
        
        Test.startTest();
        Approval.ProcessResult result=Approval.process(req);
        Test.stopTest();
        
        ItemsToApprove_Controller controllerRef=new ItemsToApprove_Controller();
        controllerRef.selectedOption='all';
        controllerRef.rerenderTable();
        
        ItemsToApprove_Controller.ProcessDetails refProcessDetails=new ItemsToApprove_Controller.ProcessDetails();
        Id currentUserId=UserInfo.getUserId();
        refProcessDetails.AssignedTo=currentUserId;
        refProcessDetails.AssignedToId=currentUserId;
        refProcessDetails.ReassignApproveUrl=currentUserId;
    }
}