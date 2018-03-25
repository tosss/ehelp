//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed methods to add contact record type
//2015-01-06 : vishal.bandari@cdk.com - changed email ids from adp to cdk
@isTest

public class DS_SendToDocusign_Extension_Test 
{
    public static testMethod CustomSettings__c getCustomSettings()
    {
        CustomSettings__c cs = new CustomSettings__c();
        cs.DS_SalesTeamTrigger_On__c = true;
        insert cs;
        return cs;
    }
    public static testmethod void InitializeDocusignPage()
    {
        DS_SendToDocusign_Extension_Test.getCustomSettings();
        // create a Opportunity record for initializing the Docusign page
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        Opportunity NewOpportunity = DS_TestObjects.NewOpportunity();
        NewOpportunity.AccountId = NewAccount.Id;
        insert NewOpportunity;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Id rt = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        // insert two new contacts for using as signers
        Contact Signer1 = DS_TestObjects.NewContact();
        Contact Signer2 = DS_TestObjects.NewContact();
        Signer1.AccountId = NewAccount.Id;
        Signer1.RecordTypeId = rt;
        Signer2.AccountId = NewAccount.Id;
        Signer1.Role__c = 'Business Manager';
        Signer2.Role__c = 'Business Office Director';
        Signer2.RecordTypeId = rt;
        //Signer1.Additional_Client_Designated_Signer__c = true;
        //Signer2.Authorized_Contract_Signer__c = true;
        insert Signer1;
        insert Signer2;
        
        // insert custom settings for contact roles
        DocuSign_Contact_Roles__c DocusignRoles = new DocuSign_Contact_Roles__c();
        DocusignRoles.RoleSet1__c = True;
        DocusignRoles.RoleSet2__c = True;
        DocusignRoles.Name = 'Business Office Director';
        insert DocusignRoles; 
        
        DocuSign_Contact_Roles__c DocusignRoles2 = new DocuSign_Contact_Roles__c();
        DocusignRoles2.RoleSet1__c = True;
        DocusignRoles2.RoleSet2__c = True;
        DocusignRoles2.Name = 'Business Manager';
        insert DocusignRoles2;        
        
        // create a new deal state
        Deal_State__c Ds = new Deal_State__c();
        Ds.Opportunity__c = NewOpportunity.Id;
        Ds.Docusign_Envelope_Status__c = 'Sent';        
        Ds.Deal_type__c = 'Add-on'; 
        Ds.Total_One_Times__c = 5000; 
        Ds.Total_Monthlies__c = 300; 
        Ds.DCS__c = True; 
        Ds.x3PA__c = True; 
        Ds.Network_Telephony__c = True; 
        Ds.Client_Data_Exchange_Products__c = True;        
        insert Ds;
        
        // Delete [Select Id, Name, ParentId From Attachment Where ParentId = :Ds.Id];
        Attachment atch = new Attachment(); 
        atch.Name = 'Document';
        atch.ParentId = Ds.Id;
        Blob b = Blob.valueOf('test');
        atch.Body = b;
        insert atch;
        
        //delete atch;
           
        // set the current page
        PageReference SendToDocusignPage =  Page.DS_SendToDocusign;
        SendToDocusignPage.getParameters().put('Id', NewOpportunity.Id);
        Test.setCurrentPage(SendToDocusignPage);
        
        // Instantiate Standard controller
        ApexPages.StandardController Controller = new Apexpages.StandardController(NewOpportunity);
        DS_SendToDocusign_Extension NewSendToDocusignPage = new DS_SendToDocusign_Extension(Controller);
        // NewSendToDocusignPage.DisplayThisMessage = True;
        // update Account 'Signer_2_2_Signer__c' field for testing for different values
       
        NewAccount.Signer_2_2_Signer__c = 'Contact Specific Signer';
        NewAccount.Signer_Required__c = True;
        NewAccount.Signer_1_2_Signer__c = 'Contact Specific Signer';
        NewAccount.Contact_Specific_Signer_1__c = Signer1.Id;
        NewAccount.Contact_Specific_Signer_2__c = Signer2.Id;
        update NewAccount;
        NewOpportunity.AccountId = NewAccount.Id;
        NewOpportunity.putSObject('Account', NewAccount);
        update NewOpportunity;
        DS_SendToDocusign_Extension.SelectOptionListCollector(NewOpportunity,'Signer_1_2_Signer__c','Contact_Specific_Signer_1__c');
        DS_SendToDocusign_Extension.SelectOptionListCollector(NewOpportunity,'Signer_2_2_Signer__c','Contact_Specific_Signer_2__c');
        
        DS_SendToDocusign_Extension NewSendToDocusignPage2 = new DS_SendToDocusign_Extension(Controller);
        NewSendToDocusignPage2.dealStateObject.Alternate_DocuSign_Account__c = NewAccount.Id;
        NewSendToDocusignPage2.changeAccount();
        
		//Trying        
        NewAccount.Signer_1_2_Signer__c = 'CEO';    
        NewAccount.Signer_2_2_Signer__c = 'CEO';        
        NewAccount.Has_Corporate_Authorized_Signer__c = true;
        NewAccount.Signer_Required__c = true;
        update NewAccount; 
        NewSendToDocusignPage2.SignInPerson1 = true;
        NewSendToDocusignPage2.SignInPerson2 = false;
        NewSendToDocusignPage2.Signer_1_Email = 'signer1@cdk.com';
        NewSendToDocusignPage2.Signer_2_Email = 'signer2@cdk.com';
        NewSendToDocusignPage2.Signer1EmailUpdate = 'signer1Update@cdk.com';
        NewSendToDocusignPage2.Signer2EmailUpdate = 'signer2Update@cdk.com';
        NewSendToDocusignPage2.SelectedListSigner1 = 'SelectedListSigner1';
        NewSendToDocusignPage2.SelectedListSigner2 = 'SelectedListSigner2';
        NewSendToDocusignPage2.BuySellatBuyer = false;
        NewSendToDocusignPage2.buySellAtBuyerCheckBox = false;
        NewSendToDocusignPage2.ErrorOnPage = false;
        NewAccount.Signer_2_2_Signer__c = 'Client Authorized Signer';
        update NewAccount;
        //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_1_2_Signer__c','Contact_Specific_Signer_1__c');  
        //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_2_2_Signer__c','Contact_Specific_Signer_2__c');                         
        
        
        NewAccount.Signer_2_2_Signer__c = 'General Manager';
        NewAccount.Has_Corporate_Authorized_Signer__c = true;
        NewAccount.Signer_Required__c = true;        
        update NewAccount; 
        //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_1_2_Signer__c','Contact_Specific_Signer_1__c');  
        //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_2_2_Signer__c','Contact_Specific_Signer_2__c'); 
        DS_SendToDocusign_Extension NewSendToDocusignPage3 = new DS_SendToDocusign_Extension(Controller);
        
        // update Signer_2_2_Signer__c to 'Client Authorized Signer'
        NewAccount.Signer_Required__c = true; 
        NewAccount.Signer_2_2_Signer__c = 'Client Authorized Signer';
        update NewAccount;       
        DS_SendToDocusign_Extension NewSendToDocusignPage4 = new DS_SendToDocusign_Extension(Controller);       
        
        Ds.French_Wording__c = True;
        update Ds;                
        
        //New Remote Methods
        DS_SendToDocusign_Extension.UpdateDocusignReturnURL(NewOpportunity.Id,'/'+NewOpportunity.Id,false);
        
        //DS_SendToDocusign_Extension NewSendToDocusignPage5 = new DS_SendToDocusign_Extension(Controller);
        
        delete Ds;       
        //DS_SendToDocusign_Extension NewSendToDocusignPage6 = new DS_SendToDocusign_Extension(Controller); 
        DS_SendToDocusign_Extension.searchForUsers('searchTerm');
        DS_SendToDocusign_Extension.SelectUser(userInfo.getUserId());
        DS_SendToDocusign_Extension.getTheContact(Signer1.ID);
    }
    
    public static testmethod void TestForSelectContact()
    {
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        Contact Signer1 = DS_TestObjects.NewContact();        
        Signer1.AccountId = NewAccount.Id;        
        Signer1.Role__c = 'Business Manager'; 
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Signer1.RecordTypeId  = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert Signer1; 
        
        // invoke the remote action method
        DS_SendToDocusign_Extension.SelectContact(Signer1.Id);

    }
    
    public static testmethod void TestForUpdateDocusignFields()
    {
        DS_SendToDocusign_Extension_Test.getCustomSettings();
        // Instatiate the global vriable class to use it to pass the variables into the remote method
        DS_SendToDocusign_Extension.AllFieldVariables variablepack = new DS_SendToDocusign_Extension.AllFieldVariables();
        
        // get Docusign_Recipient__c custom settings
        List<Docusign_Recipient__c> DocuSignRecipient = new List<Docusign_Recipient__c>();
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='CA', Routing_Order__c=4, First_Name__c='CA', Last_Name__c='Approver', Email__c=''));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='CRA Signer', Routing_Order__c=6, First_Name__c='Any', Last_Name__c='Signer', Email__c='cra.anysigner@cdk.com'));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='Legal Counter Signer', Routing_Order__c=5, First_Name__c='Any', Last_Name__c='Signer', Email__c='docusign.anysigner@cdk.com'));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='SCS', Routing_Order__c=3, First_Name__c='SCS', Last_Name__c='Approver', Email__c='scs.docusign@cdk.com'));
        insert DocuSignRecipient;
        
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        NewAccount.Region__c = 'Canada';
        Update NewAccount;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Id rt = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        Contact SelectedSigner1 = new Contact();       
        SelectedSigner1.FirstName = 'Pete';
        SelectedSigner1.LastName = 'Griff';
        SelectedSigner1.Role__c = 'Comedian';
        SelectedSigner1.Email = 'sdfh@cdk.com';
        SelectedSigner1.AccountId = NewAccount.Id; 
        SelectedSigner1.RecordTypeId  = rt;
        insert SelectedSigner1;
        
        Contact SelectedSigner2 = new Contact();       
        SelectedSigner2.FirstName = 'Peter';
        SelectedSigner2.LastName = 'Muffin';
        SelectedSigner2.Role__c = 'Author';
        SelectedSigner2.Email = 'sdfh@cdk.com';
        SelectedSigner2.AccountId = NewAccount.Id;   
        SelectedSigner2.RecordTypeId  = rt;
        insert SelectedSigner2;
        
        // create a Opportunity record for generating an Id for assigning that value to the HiddenId variable in the variablePack        
        Opportunity NewOpportunity = DS_TestObjects.NewOpportunity();
        NewOpportunity.AccountId = NewAccount.Id;
        insert NewOpportunity;
        
         // create a new deal state
        Deal_State__c Ds = new Deal_State__c();
        
        Ds.Client_Signer_1_Role__c = 'Comedian';
        Ds.Client_Signer_2_Role__c = 'Author';
        Ds.IPNS_Only__c = false;
        Ds.Opportunity__c = NewOpportunity.Id;
        Ds.Docusign_Envelope_Status__c = 'Docusign Not Sent';     
        insert Ds;
        
        dsfs__DocuSign_Status__c Dstatus = new dsfs__DocuSign_Status__c();
        Dstatus.Deal_State__c = Ds.Id;
        insert Dstatus;
        
        // attach a document to the deal state
        Attachment atch = new Attachment(); 
        atch.Name = 'Document';
        atch.ParentId = Ds.Id;
        Blob b = Blob.valueOf('test');
        atch.Body = b;
        insert atch;
        
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
        // Assign vlaues for all the variables in the variablepack
        variablepack.selectedListSigner1 = SelectedSigner1.Id;
        variablepack.selectedListSigner2 = SelectedSigner2.Id;
        variablepack.SignInPerson1 = True;
        variablepack.SignInPerson2 = True;
        variablepack.Signer_1_Email = SelectedSigner1.Email;
        variablepack.Signer_2_Email = SelectedSigner2.Email;
        variablepack.Signer1EmailUpdate = True;
        variablepack.Signer2EmailUpdate = True;
        variablepack.EmailBody = 'Please sign electronically, Thanks!';
        variablepack.Subject = 'Docusign signature';
        variablepack.HiddenId = NewOpportunity.Id;
        
        // invoke the remoteaction method
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
        // test for a condition that allows through a condition if envelope status is sent.
        Ds.Docusign_Envelope_Status__c = 'Sent';                
        Update Ds;
        
        // invoke remoteaction method again
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
        variablepack.OverrideSignerId1 = SelectedSigner2.Id;
        variablepack.OverrideSignerId2 = SelectedSigner1.Id;
        
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
        // delete attachments for covering few lines of code coverage
        Delete atch;
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
        // test when deal state is null
        Delete Ds;
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);        
        
    } 
}