@IsTest
public class ItemsToApprove_Test
{
    //Author     : Vishal Bandari
    //Date       : 6th Jan, 2015
    //Description: This Test Class is used for the ItemsToApprove_Controller Apex Class.
    
    public static testmethod void valiadateItemsToApprove()
    {
        //Create a sample LAO Record
        Laser_Artwork_Order__c lao = DS_TestObjects.NewLaserArtworkOrder();
        lao.Order_Type__c = 'Add/Change - Elite';
        lao.Order_Status__c = 'AWIP';
        lao.LFD_Name__c = Userinfo.getUserId();
        lao.Artwork_Due_Date__c = DateTime.now().adddays(15);
        lao.Artwork_to_LFD_Team__c = DateTime.now();
        lao.Proofs_Required__c = 'No';
        lao.Prev_SO__c = '123';
        lao.Contract_PO__c ='1234';
        lao.Change_Notes__c ='text area';
        lao.Quote_Type__c = 'Contracted'; // 2015-12-22 matt.keefe@cdk.com - updated to satisfy validation
        //2016-02-24 venkata.shrivol@cdk.com - Uncommeneted the commented code by Matt to satisfy validation.
        insert lao;
        
        //Submit the lao record for Approval
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(lao.id);
        req.setProcessDefinitionNameOrId('DS_LSR_Detail_Elite_v01');
        req.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req);
        
        //Instantiating the Controller Object
        ItemsToApprove_Controller itemsToApproveObj = new ItemsToApprove_Controller();
        itemsToApproveObj.selectedOption='all';
        itemsToApproveObj.rerenderTable();
    }
}