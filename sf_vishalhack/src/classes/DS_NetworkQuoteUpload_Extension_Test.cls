@isTest
public class DS_NetworkQuoteUpload_Extension_Test 
{
    
    public static testmethod void InitializeThePage()
    {
        ApexPages.currentPage().getHeaders().put('USER-AGENT','chrome');
        // create a Opportunity record for initializing the page
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        Opportunity NewOpportunity = new Opportunity(
            Name='TestOpportunity',
            AccountId = NewAccount.Id,
            ADP_Opportunity_Owner__c=UserInfo.getUserId(),
            CloseDate=Date.today(),
            StageName='Plan',
            Type='Add-on',
            Account = newAccount
        );
        
        insert NewOpportunity;
       
        
        // create a new deal state
        Deal_State__c Ds = new Deal_State__c();
        DS.PSE_Status__c = 'Open';
        Ds.Opportunity__c = NewOpportunity.Id;        
        insert Ds;
        Attachment atch = new Attachment(); 
        atch.Name = 'Document';
        atch.ParentId = NewOpportunity.Id;
        Blob b = Blob.valueOf('test');
        atch.Body = b;
        insert atch;
        
        // set the current page
        PageReference FileUploadPage = Page.DS_NetworkQuoteUpload;
        FileUploadPage.getParameters().put('Id', NewOpportunity.Id);
        Test.setCurrentPage(FileUploadPage);
        
        // Instantiate the standard controller
        ApexPages.StandardController Controller = new Apexpages.StandardController(NewOpportunity);
        DS_NetworkQuoteUpload_Extension NewFileUpload = new DS_NetworkQuoteUpload_Extension(Controller);
        
        // test for the UploadAndSave method
        NewFileUpload.aspBuyOutCat=true;
        NewFileUpload.aspBuyOutPrice='';
        NewFileUpload.holeInFirewallNoCharge=true;
        NewFileUpload.holeInFirewallUseCat=true;
        NewFileUpload.noQuotesRequired=true;
        NewFileUpload.isIE = true;
        NewFileUpload.UploadAndSave();
        NewFileUpload.Cancel();
        
        // populate the first and third new attachments
		List<DS_NetworkQuoteUpload_Extension.PageVariablePack> newAttachmentPack = NewFileUpload.FileUploadVariableList;
		newAttachmentPack[0].attach.Name ='Unit Test 1';
		newAttachmentPack[0].attach.Description = 'Unit Test 1';
		newAttachmentPack[0].attach.Body = Blob.valueOf('Unit Test 1');
        
        List<DS_NetworkQuoteUpload_Extension.PageVariablePack> newAttachmentPack2 = NewFileUpload.FileUploadVariableList2;
        newAttachmentPack2.add(new DS_NetworkQuoteUpload_Extension.PageVariablePack(newAttachmentPack[newAttachmentPack.size()-1].FileNumber+1, new attachment(Body = Blob.valueOf('Unit Test 2'))));		
        NewFileUpload.UploadAndSave();
        
        Test.startTest();
		DS_NetworkQuoteUpload_Extension.doUploadAttachment(NewOpportunity.Id,'Sample Attachment Body', 'Attachment Name',
        null,'fileDescription',0, 
        1,'OverAllNotes',true, 
        true, true,
        true, '50000','None',true);  
        DS_NetworkQuoteUpload_Extension.doUploadAttachment(NewOpportunity.Id,null,null,
        null,null,0, 
        0,'Notes',true, 
        true, true,
        true,'','None',true);                 
        
       Opportunity NewOpportunity2 = new Opportunity(
            Name='TestOpportunity',
            ADP_Opportunity_Owner__c=UserInfo.getUserId(),
            CloseDate=Date.today(),
            StageName='Plan',
            Type='Add-on',
            Account = newAccount
        );
        
        insert NewOpportunity2;

        
        DS_NetworkQuoteUpload_Extension.doUploadAttachment(NewOpportunity2.Id,'Sample Attachment Body', 'Attachment Name',
        null,'fileDescription',0, 
        1,'OverAllNotes',true, 
        true, true,
        true, '50000','None',true); 
        Test.stopTest();
    }
    
    
    
    
    public static testmethod void InitializeThePage2()
    {
        ApexPages.currentPage().getHeaders().put('USER-AGENT','chrome');
        // create a Opportunity record for initializing the page
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        Opportunity NewOpportunity = new Opportunity(
            Name='TestOpportunity',
            AccountId = NewAccount.Id,
            ADP_Opportunity_Owner__c=UserInfo.getUserId(),
            CloseDate=Date.today(),
            StageName='Plan',
            Type='Add-on',
            Account = newAccount
        );
        
        insert NewOpportunity;
        
        // create a new deal state
        Deal_State__c Ds = new Deal_State__c();
        Ds.PSE_Status__c = 'Open';
        Ds.Opportunity__c = NewOpportunity.Id;        
        insert Ds;
        Attachment atch = new Attachment(); 
        atch.Name = 'Document';
        atch.ParentId = NewOpportunity.Id;
        Blob b = Blob.valueOf('test');
        atch.Body = b;
        insert atch;
        
          Opportunity NewOpportunity2 = new Opportunity(
            Name='TestOpportunity2',
            AccountId = NewAccount.Id,
            ADP_Opportunity_Owner__c=UserInfo.getUserId(),
            CloseDate=Date.today(),
            StageName='Plan',
            Type='Add-on',
            Account = newAccount
        );
        
        insert NewOpportunity2;
        
        Test.startTest();
        // set the current page
        PageReference FileUploadPage = Page.DS_NetworkQuoteUpload;
        FileUploadPage.getParameters().put('Id', NewOpportunity.Id);
        Test.setCurrentPage(FileUploadPage);
        
        // Instantiate the standard controller
        ApexPages.StandardController Controller = new Apexpages.StandardController(NewOpportunity);
        DS_NetworkQuoteUpload_Extension NewFileUpload = new DS_NetworkQuoteUpload_Extension(Controller);
        
        // test for the UploadAndSave method
        NewFileUpload.UploadAndSave();
        NewFileUpload.Cancel();
        
        // populate the first and third new attachments
		List<DS_NetworkQuoteUpload_Extension.PageVariablePack> newAttachmentPack = NewFileUpload.FileUploadVariableList;
		newAttachmentPack[0].attach.Name ='Unit Test 1';
		newAttachmentPack[0].attach.Description = 'Unit Test 1';
		newAttachmentPack[0].attach.Body = Blob.valueOf('Unit Test 1');
        
        List<DS_NetworkQuoteUpload_Extension.PageVariablePack> newAttachmentPack2 = NewFileUpload.FileUploadVariableList2;
        newAttachmentPack2.add(new DS_NetworkQuoteUpload_Extension.PageVariablePack(newAttachmentPack[newAttachmentPack.size()-1].FileNumber+1, new attachment(Body = Blob.valueOf('Unit Test 2'))));		
        NewFileUpload.UploadAndSave();  
        DS_NetworkQuoteUpload_Extension.doUploadAttachment(NewOpportunity.Id,null,null,
        null,null,0, 
        0,'Notes',true, 
        true, true,
        true,'50000','None',true); 
        Test.stopTest();
        
    }
}