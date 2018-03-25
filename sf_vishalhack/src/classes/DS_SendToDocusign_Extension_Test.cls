//2016-05-23: siva.pragada@cdk.com - Shared contact changes.
//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed methods to add contact record type
//2015-01-06 : vishal.bandari@cdk.com - changed email ids from adp to cdk
//2017-01-12:  venkata.shrivol@cdk.com - re-modified this class, but no assertion statements.
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
    
    @testSetup static void prepareTestData()
    {
        CustomSettings__c cs = new CustomSettings__c();
        cs.DS_SalesTeamTrigger_On__c = true;
        insert cs;
        
        // get Docusign_Recipient__c custom settings
        List<Docusign_Recipient__c> DocuSignRecipient = new List<Docusign_Recipient__c>();
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='CA', Routing_Order__c=10, First_Name__c='CA', Last_Name__c='Approver', Email__c=''));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='CRA Signer', Routing_Order__c=25, First_Name__c='Any', Last_Name__c='Signer', Email__c='cra.anysigner@cdk.com'));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='Legal Counter Signer', Routing_Order__c=20, First_Name__c='Any', Last_Name__c='Signer', Email__c='docusign.anysigner@cdk.com'));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='SCS', Routing_Order__c=5, First_Name__c='SCS', Last_Name__c='Approver', Email__c='scs.docusign@cdk.com'));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='Shared System Seller', Routing_Order__c=3, First_Name__c='Shared System', Last_Name__c='Seller', Email__c=''));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='Shared System Seller2', Routing_Order__c=4, First_Name__c='Shared System', Last_Name__c='Seller2', Email__c=''));
        DocuSignRecipient.add(new Docusign_Recipient__c(Name='BlockingUser', Routing_Order__c=4, First_Name__c='Blocking', Last_Name__c='User', Email__c=''));
        insert DocuSignRecipient;
        
        Account NewAccount = DS_TestObjects.NewAccount();
        NewAccount.Region__c = 'Canada';
        insert NewAccount;
        
        Opportunity NewOpportunity = DS_TestObjects.NewOpportunity();
        NewOpportunity.Name = 'Docusign Test Opp';
        NewOpportunity.AccountId = NewAccount.Id;
        insert NewOpportunity;
        
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Id rt = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
       
        list<Contact> Signers = new list<Contact>();
        // insert two new contacts for using as signers
        Contact Signer1 = DS_TestObjects.NewContact();
        Signer1.AccountId = NewAccount.Id;
        Signer1.RecordTypeId = rt;
        Signer1.Email = 'testsigner1@gmail.com';
        Signers.add(Signer1);
        //insert Signer1;
        
        Contact Signer2 =  new Contact();
        Signer2.lastName='TESTLastName1';
        Signer2.FirstName='TESTFirstName1';
        Signer2.Title__c='Manager1';
        Signer2.Department__c='Service1';
        Signer2.AccountId  = NewAccount.Id;
        Signer2.RecordTypeId = rt;
        Signer2.Email = 'testsigner2@gmail.com';
        Signers.add(Signer2);
        
        insert Signers;
        integer i=0;
        list<Contact_Relationship__c> crtsToInsert = new list<Contact_Relationship__c>();
        for(Contact con:[select Id, FirstName,LastName,AccountId,Email from  Contact])
        {
        	Contact_Relationship__c crs1 = new Contact_Relationship__c();
            crs1.First_Name_LGY__c = con.FirstName;
            crs1.Last_Name_LGY__c = con.LastName;
            crs1.Email_LGY__c = con.Email;
            crs1.Account__c = con.AccountId;
            if(i==0)
            {
                crs1.Role__c = 'Business Manager';
            }
            else{
                 crs1.Role__c = 'Business Office Director';
            }
            crs1.Contact__c = con.Id; 
            crtsToInsert.add(crs1);
        }
        insert crtsToInsert;
        
        
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
        
       
        
    }
    
    public static testmethod void InitializeDocusignPage()
    {
         // create a new deal state

        
        list<Account> accts = [select Id from Account limit 1];
        Account thisAccount = accts.size() > 0 ? accts.get(0) : new Account();
        
        list<Opportunity> opps  = [select Id, Client_Signer_1_Sign_in_Person_Override__c,Client_Signer_2_Sign_in_Person_Override__c
                                   from Opportunity where Name ='Docusign Test Opp' limit 1];
        Opportunity thisOpp = opps.size() > 0 ? opps.get(0) : new Opportunity();
        
        Deal_State__c Ds = new Deal_State__c();
        Ds.Opportunity__c = thisOpp.Id;
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
        
        list<Contact> contacts = [select Id from Contact];
        
        list<Deal_State__c> dealStates = [select Id from Deal_state__c where Opportunity__c = :thisOpp.Id];
        Deal_State__c thisDealState = dealStates.size()> 0 ? dealStates.get(0) : new Deal_State__c();
        
        
        //delete atch;
         
        Test.startTest();
            // set the current page
            
        	// Instantiate Standard controller
            ApexPages.StandardController Controller = new Apexpages.StandardController(thisOpp);
            DS_SendToDocusign_Extension NewSendToDocusignPage = new DS_SendToDocusign_Extension(Controller);
            
            PageReference SendToDocusignPage =  Page.DS_SendToDocusign;
            SendToDocusignPage.getParameters().put('Id', thisOpp.Id);
            Test.setCurrentPage(SendToDocusignPage);
            
            
            // NewSendToDocusignPage.DisplayThisMessage = True;
            // update Account 'Signer_2_2_Signer__c' field for testing for different values
       
            thisAccount.Signer_2_2_Signer__c = 'Contact Specific Signer';
            thisAccount.Signer_Required__c = True;
            thisAccount.Signer_1_2_Signer__c = 'Contact Specific Signer';
            thisAccount.Contact_Specific_Signer_1__c = contacts.get(0).Id;
            thisAccount.Contact_Specific_Signer_2__c = contacts.get(1).Id;
            update thisAccount;
            
        	thisOpp.AccountId = thisAccount.Id;
            thisOpp.putSObject('Account', thisAccount);
            update thisOpp;
        
            DS_SendToDocusign_Extension.SelectOptionListCollector(thisOpp,'Signer_1_2_Signer__c','Contact_Specific_Signer_1__c');
            DS_SendToDocusign_Extension.SelectOptionListCollector(thisOpp,'Signer_2_2_Signer__c','Contact_Specific_Signer_2__c');
            
            DS_SendToDocusign_Extension NewSendToDocusignPage2 = new DS_SendToDocusign_Extension(Controller);
            NewSendToDocusignPage2.dealStateObject.Alternate_DocuSign_Account__c = thisAccount.Id;
            NewSendToDocusignPage2.changeAccount();
        
            //Trying        
            thisAccount.Signer_1_2_Signer__c = 'CEO';    
            thisAccount.Signer_2_2_Signer__c = 'CEO';        
            thisAccount.Has_Corporate_Authorized_Signer__c = true;
            thisAccount.Signer_Required__c = true;
            update thisAccount; 
        
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
            thisAccount.Signer_2_2_Signer__c = 'Client Authorized Signer';
            update thisAccount;
        
            //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_1_2_Signer__c','Contact_Specific_Signer_1__c');  
            //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_2_2_Signer__c','Contact_Specific_Signer_2__c');                         
        
        
            thisAccount.Signer_2_2_Signer__c = 'General Manager';
            thisAccount.Has_Corporate_Authorized_Signer__c = true;
            thisAccount.Signer_Required__c = true;        
            update thisAccount; 
        
            //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_1_2_Signer__c','Contact_Specific_Signer_1__c');  
            //NewSendToDocusignPage2.SelectOptionList(NewAccount,'Signer_2_2_Signer__c','Contact_Specific_Signer_2__c'); 
            DS_SendToDocusign_Extension NewSendToDocusignPage3 = new DS_SendToDocusign_Extension(Controller);
            
            // update Signer_2_2_Signer__c to 'Client Authorized Signer'
            thisAccount.Signer_Required__c = true; 
            thisAccount.Signer_2_2_Signer__c = 'Client Authorized Signer';
            update thisAccount;       
            DS_SendToDocusign_Extension NewSendToDocusignPage4 = new DS_SendToDocusign_Extension(Controller);       
            
            thisDealState.French_Wording__c = True;
            update thisDealState;                
            
            //New Remote Methods
            DS_SendToDocusign_Extension.UpdateDocusignReturnURL(thisOpp.Id,'/'+thisOpp.Id,false);
            
            //DS_SendToDocusign_Extension NewSendToDocusignPage5 = new DS_SendToDocusign_Extension(Controller);
            
            delete thisDealState;       
            //DS_SendToDocusign_Extension NewSendToDocusignPage6 = new DS_SendToDocusign_Extension(Controller); 
            DS_SendToDocusign_Extension.searchForUsers('searchTerm');
            DS_SendToDocusign_Extension.SelectUser(userInfo.getUserId());
            DS_SendToDocusign_Extension.getTheContact(contacts.get(0).Id);
        
        Test.stopTest();
    }
    
    public static testmethod void TestForSelectContact()
    {
        list<Opportunity> opps  = [select Id from Opportunity where Name ='Docusign Test Opp' limit 1];
        Opportunity thisOpp = opps.size() > 0 ? opps.get(0) : new Opportunity();
        
        Deal_State__c Ds = new Deal_State__c();
        Ds.Opportunity__c = thisOpp.Id;
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
        
        Test.startTest();
        
        list<Contact> contacts = [select Id from Contact];
        Contact thisCon = contacts.size() > 0 ? contacts.get(0) : new Contact();
        
        /*Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        Contact Signer1 = DS_TestObjects.NewContact();        
        Signer1.AccountId = NewAccount.Id;        
        Signer1.Role__c = 'Business Manager';
        Signer1.Email = 'Recipient20934702372093@cdkglobal.com';
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Signer1.RecordTypeId  = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert Signer1; */
        
        // invoke the remote action method
        DS_SendToDocusign_Extension.SelectContact(thisCon.Id);
        
        Test.stopTest();

    }
    
    public static testmethod void TestForUpdateDocusignFields()
    {
        list<Opportunity> opps  = [select Id from Opportunity where Name ='Docusign Test Opp' limit 1];
        Opportunity thisOpp = opps.size() > 0 ? opps.get(0) : new Opportunity();
        
        Deal_State__c Ds = new Deal_State__c();
        Ds.Opportunity__c = thisOpp.Id;
        Ds.Docusign_Envelope_Status__c = 'Docusign Not Sent';        
        Ds.Deal_type__c = 'Add-on'; 
        Ds.Total_One_Times__c = 5000; 
        Ds.Total_Monthlies__c = 300; 
        Ds.DCS__c = True; 
        Ds.x3PA__c = True; 
        Ds.Network_Telephony__c = True; 
        Ds.Client_Data_Exchange_Products__c = True;        
        insert Ds;
        
        Attachment atch = new Attachment(); 
        atch.Name = 'Document';
        atch.ParentId = Ds.Id;
        Blob b = Blob.valueOf('test');
        atch.Body = b;
        insert atch;
        
        dsfs__DocuSign_Status__c Dstatus = new dsfs__DocuSign_Status__c();
        Dstatus.Deal_State__c = Ds.Id;
        insert Dstatus;
        
       
        list<Contact> contacts = [select ID, Email from Contact];
        map<string, Docusign_Recipient__c> recipientsMap = Docusign_Recipient__c.getAll();
        
        Test.startTest();
        // Instatiate the global vriable class to use it to pass the variables into the remote method
        DS_SendToDocusign_Extension.AllFieldVariables variablepack = new DS_SendToDocusign_Extension.AllFieldVariables(); 
        
        /*variablepack.SignInPerson1 = True;
        variablepack.SignInPerson2 = True;*/
        
        //variablepack.EmailBody = 'Please sign electronically, Thanks!';
        //variablepack.Subject = 'Docusign signature';
        variablepack.HiddenId = thisOpp.Id;
        
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
               
        
        
		//2017-01-12 -venkata.shrivol@cdk.com -commented this code out to avoid SOQL 101 limit error
		// test for a condition that allows through a condition if envelope status is sent.
        /*Ds.Docusign_Envelope_Status__c = 'Sent';                
        Update Ds;
        
        // invoke remoteaction method again
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
        // delete attachments for covering few lines of code coverage
        /*Delete atch;
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        
        // test when deal state is null
        Delete Ds;
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);  */    
        
    
        Test.stopTest();
    }
    
    //2016-01-12 -venkata.shrivol@cdk.com -created
    static testMethod void testOnDocusignUpdate2()
    {
        list<Opportunity> opps  = [select Id from Opportunity where Name ='Docusign Test Opp' limit 1];
        Opportunity thisOpp = opps.size() > 0 ? opps.get(0) : new Opportunity();
        
        Deal_State__c Ds = new Deal_State__c();
        Ds.Opportunity__c = thisOpp.Id;
        Ds.Docusign_Envelope_Status__c = 'Docusign Not Sent';        
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
        
        dsfs__DocuSign_Status__c Dstatus = new dsfs__DocuSign_Status__c();
        Dstatus.Deal_State__c = Ds.Id;
        insert Dstatus;
        
       
        list<Contact> contacts = [select ID, Email from Contact];
        map<string, Docusign_Recipient__c> recipientsMap = Docusign_Recipient__c.getAll();
        
        Test.startTest();
        DS_SendToDocusign_Extension.AllFieldVariables variablepack = new DS_SendToDocusign_Extension.AllFieldVariables();
        
        // invoke the remoteaction method
        variablepack.HiddenId = thisOpp.Id;
        //variablepack.OverrideSignerId1 = contacts.get(1).Id;
        //variablepack.OverrideSignerId2 = contacts.get(0).Id;
        variablepack.Signer_1_Email = contacts.get(0).Email;
        variablepack.Signer_2_Email = contacts.get(1).Email;
        variablepack.Signer1EmailUpdate = True;
        variablepack.Signer2EmailUpdate = True;
        variablepack.selectedListSigner1 = contacts.get(0).Id;
        variablepack.selectedListSigner2 = contacts.get(1).Id;
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        Test.stopTest();
        
    }
    
    //2016-01-12 -venkata.shrivol@cdk.com -created
    static testMethod void testDocusignFieldUpdateThree()
    {
    	list<Opportunity> opps  = [select Id from Opportunity where Name ='Docusign Test Opp' limit 1];
        Opportunity thisOpp = opps.size() > 0 ? opps.get(0) : new Opportunity();
        
        Deal_State__c Ds = new Deal_State__c();
        Ds.Opportunity__c = thisOpp.Id;
        Ds.Docusign_Envelope_Status__c = 'Docusign Not Sent';        
        Ds.Deal_type__c = 'Add-on'; 
        Ds.Total_One_Times__c = 5000; 
        Ds.Total_Monthlies__c = 300; 
        Ds.DCS__c = True; 
        Ds.x3PA__c = True; 
        Ds.Network_Telephony__c = True; 
        Ds.Client_Data_Exchange_Products__c = True;        
        insert Ds;
        
        Attachment atch = new Attachment(); 
        atch.Name = 'Document';
        atch.ParentId = Ds.Id;
        Blob b = Blob.valueOf('test');
        atch.Body = b;
        insert atch;
        
        dsfs__DocuSign_Status__c Dstatus = new dsfs__DocuSign_Status__c();
        Dstatus.Deal_State__c = Ds.Id;
        insert Dstatus;
        
       
        list<Contact> contacts = [select ID, Email from Contact];
        map<string, Docusign_Recipient__c> recipientsMap = Docusign_Recipient__c.getAll();
        
        Test.startTest();
        DS_SendToDocusign_Extension.AllFieldVariables variablepack = new DS_SendToDocusign_Extension.AllFieldVariables();
        
        // invoke the remoteaction method
        variablepack.HiddenId = thisOpp.Id;
        variablepack.OverrideSignerId1 = contacts.get(1).Id;
        variablepack.OverrideSignerId2 = contacts.get(0).Id;
        
        DS_SendToDocusign_Extension.UpdateDocusignFields(variablepack);
        Test.stopTest();
            
    }
    //6/1/2016 - siva.pragada@cdk.com - added testForRequiredCcs() for test coverage
    public static testMethod void testForRequiredCcs()
    {
       Test.startTest();
        
        Site_Type__c siteType=new Site_Type__c(Name='Test Site Type', Corporation_Flag__c=true, Active__c=true);
        insert sitetype;
        
        
        Account topmostParent=DS_TestObjects.newAccount(); 
        topmostParent.Site_Type__c=siteType.Id;
        insert topmostParent;
        
        Account level1Child=DS_TestObjects.newAccount(); 
        level1Child.ParentId=topmostParent.Id;
        level1Child.Site_Type__c=siteType.Id;
        insert level1Child;
        
        Contact c = DS_TestObjects.NewContact_Inserted();
        
        contact_Relationship__c crs = new contact_Relationship__c();
        crs.Account__c = level1Child.ID;
        crs.Contact__c = c.ID;
        crs.Status__c = 'Active';
        crs.No_Longer_There__c = false;
        crs.DS_SLS_Required_cc__c = true;
        insert crs;
        
        DS_SendToDocusign_Extension.getAllRequiredCcsIntoJavascript(level1Child.ID, null);
        
        Test.stopTest();
    }
}