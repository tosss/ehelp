@IsTest
public class DS_DealStateAttachmentsExtension_Test 
{
    
    public static testmethod void getAttachmentsTest()
    {
        //Insert account object
        Account newAccount = new Account(Name = 'Test Account');
        insert newAccount;
        
        //Insert Opportunity object
        Opportunity newOpportunity = new Opportunity(Name='TestOpportunity'
                                                     ,AccountId = newAccount.Id
                                                     ,ADP_Opportunity_Owner__c=UserInfo.getUserId()
                                                     ,CloseDate=Date.today()
                                                     ,StageName='Plan'
                                                     ,Type='Add-on'
                                                     ,Account = newAccount
                                                    );
        insert newOpportunity;
        
        Opportunity newOpportunity2 = new Opportunity(Name='TestOpportunity'
                                                      ,ADP_Opportunity_Owner__c=UserInfo.getUserId()
                                                      ,CloseDate=Date.today()
                                                      ,StageName='Plan'
                                                      ,Type='Add-on'
                                                      ,Account = newAccount
                                                     );
        insert newOpportunity2;
        Attachment atch2 = new Attachment(); 
        atch2.Name = 'Document 2';
        atch2.ParentId = newOpportunity2.Id;
        Blob b2 = Blob.valueOf('test 2');
        atch2.Body = b2;
        insert atch2;
        
        //Insert Deal State object
        Deal_State__c dsObj = new Deal_State__c(Opportunity__c=newOpportunity.Id,
                                                Quantity_of_Sites__c=10,
                                                Any_Other_Sites_Involved_With_Request__c='Test sites',
                                                Description_of_Need__c='Test Description');
        insert dsObj;
        
        //Insert Attachment object
        Attachment atch = new Attachment(); 
        atch.Name = 'Document';
        atch.ParentId = newOpportunity.Id;
        Blob b = Blob.valueOf('test');
        atch.Body = b;
        insert atch;
        
        //Insert Second attachment for same opportunity object
        Attachment atch3 = new Attachment(); 
        atch3.Name = 'Document 2';
        atch3.ParentId = newOpportunity.Id;
        Blob b3 = Blob.valueOf('test 2');
        atch3.Body = b3;
        insert atch3;
        
        //Insert Deal change for deal state object
        Deal_Change__c dealChangeObj = new Deal_Change__c(Deal_State__c=dsObj.Id,
                                                          Type_of_Change__c='SOW',
                                                          Requested_Changes__c='Test');
        dealChangeObj.ASP_Buy_Out_Cat_34174_36__c = true;
        dealChangeObj.ASP_Buy_Out_Price__c='10';
        dealChangeObj.ASP_Buy_Out_Quote__c = 10;
        dealChangeObj.Hole_in_Firewall_No_Charge__c = true;
        dealChangeObj.Hole_in_Firewall_use_Cat_34122_98__c = true;
        dealChangeObj.No_Quotes_Required__c = true;
        insert dealChangeObj; 
        
        
        
        //Insert second Deal change for same deal state object
        Deal_Change__c dealChangeObj2 = new Deal_Change__c(Deal_State__c=dsObj.Id,
                                                           Type_of_Change__c='SOW',
                                                           Requested_Changes__c='Test 2');
        insert dealChangeObj2;
        
        
        Deal_Change__c dealChangeObj3 = new Deal_Change__c(Deal_State__c=dsObj.Id,
                                                           Type_of_Change__c='SOW',
                                                           Requested_Changes__c='Test');
        dealChangeObj3.ASP_Buy_Out_Cat_34174_36__c = true;
        dealChangeObj3.ASP_Buy_Out_Price__c='10';
        dealChangeObj3.ASP_Buy_Out_Quote__c = 10;
        dealChangeObj3.Hole_in_Firewall_No_Charge__c = true;
        dealChangeObj3.Hole_in_Firewall_use_Cat_34122_98__c = true;
        dealChangeObj3.No_Quotes_Required__c = true;
        insert dealChangeObj3; 
        
        //Insert notes object for deal change
        Note noteObj = new Note();
        noteObj.Title='Test';
        noteObj.ParentId = dealChangeObj.id;
        insert noteObj;
        
        Note noteObj2 = new Note();
        noteObj2.Title='New Test';
        noteObj2.ParentId = dealChangeObj2.id;
        insert noteObj2;
        
        DS_Network_Quote_Attachment_Permissions__c networkObj = new DS_Network_Quote_Attachment_Permissions__c();
        networkObj.name='Test Name';
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name; 
        networkObj.Profile_Name__c= profileName;
        insert networkObj;
        
        //Create standard controller object and call the main method
        ApexPages.StandardController sc = new ApexPages.StandardController(newOpportunity);
        DS_DealStateAttachments_Extension dealStateAttachmentsObj = new DS_DealStateAttachments_Extension(sc);
        dealStateAttachmentsObj.getAttachments(); 
        
        //Create second object to explicitly create exception
        Opportunity newOpp  = new Opportunity();
        ApexPages.StandardController sc2 = new ApexPages.StandardController(newOpp);
        DS_DealStateAttachments_Extension dealStateAttachmentsObj2 = new DS_DealStateAttachments_Extension(sc2);
        dealStateAttachmentsObj2.setMapReOrderValues(dealStateAttachmentsObj2.getMapReOrderValues());
        dealStateAttachmentsObj2.getAttachments();
        
        dealStateAttachmentsObj.attachmentId = atch2.id;
        dealStateAttachmentsObj.deleteAttachment();
        
        dealStateAttachmentsObj.dealChangeId = dealChangeObj3.id;
         dealStateAttachmentsObj.deleteDealChange();
        
        
        dealStateAttachmentsObj.createDcNotesBody(dealChangeObj2);
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(newOpportunity2);
        DS_DealStateAttachments_Extension dealStateAttachmentsObj3 = new DS_DealStateAttachments_Extension(sc3);
        dealStateAttachmentsObj3.getAttachments();
    }
    
}