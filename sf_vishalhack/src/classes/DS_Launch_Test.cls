// created - 3/3/2016 - siva.pragada@cdk.com
// 2016-06-16      venkata.shrivol@cdk.com - added CR test records after account and contact insertion.
@IsTest
public class DS_Launch_Test 
{
    // createdby matt.keefe@cdk.com - moved from CB_LaunchUpdateEmailsTest
    public static testmethod void Test()
    {
        // turn the WebID Triggers off (not testing those)
        CustomSettings__c c = new CustomSettings__c();
        c.WebIDTriggers_On__c = false;
        insert c;
        
        // insert a new User for assigning to the designated fields
        User u = DS_TestObjects.NewUser();
        u.Title = 'DSM'; 
        try { insert u; } catch (Exception e) { system.debug(e); }
        
        // insert a new Account from which some email fields will be pulled
        // it is not actually necessary to set the fields for code coverage
        //  - so, they're commented out, a null value will be passed
        Account a = DS_TestObjects.NewAccount();
        //a.Digital_Services_GAM__c = u.Id; 
        //a.Digital_Services_CAM__c = u.Id;
        //a.Designated_DSM__c = u.Id;
        try { insert a; } catch (Exception e) { system.debug(e); }
        
        Contact newContact = DS_TestObjects.NewContact();
        newContact.AccountID = a.ID;
        insert newContact;
        
        Contact_Relationship__c crt = IMP_TestFactory_Helper.buildContactRelationship(a.Id, newContact.Id);
        insert crt;
        
        // insert a new WebID for some other email fields
        WebID__c w = new WebID__c();
        w.Name = 'test-webid-001';
        w.Account__c = a.Id;
        //w.Account_Advocate__c = u.Id;
        //w.OwnerMktg_Specialist_lookup__c = u.Id;
        //w.Online_Marketing_Specialist__c = u.Id;
        //w.Reputation_Management_Specialist__c = u.Id;
        //w.SEO_Specialist__c = u.Id;
        //w.Social_Media_Specialist__c = u.Id;
        try { insert w; } catch (Exception e) { system.debug(e); }
        
        // insert a new Launch record that will test the CB_LaunchUpdateEmails Trigger
        ID A_La_Carte_RecordType = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Launch__c', 'A La Carte Launch');
        Launch__c l = new Launch__c();
        l.RecordTypeId = A_La_Carte_RecordType;
        l.Account__c = a.Id;
        l.WebID__c = w.Id;
        l.Product_Type__c = 'Dealer Group Support';
        l.Order_Priority__c = 'Normal';
        insert l; 
        
        l.status__c = 'Closed';
        l.DI_Completed__c = date.today() - 2;
        l.Contact__c = newContact.ID;
        l.Welcome_Email_Sent__c = Date.today() - 2;
        l.Oracle_Order_Number__c = '6372811011236';
        l.Booking_OM__c = userInfo.getUserId();
        l.Order_Submitted_By__c = 'Audi CAmry';
        l.X0_Order__c = true;
        l.Order_Signed_Date__c = Date.today() - 2;
        l.Notice_to_Book_Order_Recd_Attached__c = true;
        l.Order_Form_Attached__c = 'yes';
        l.Discount_Approvals__c = 'No Discount';
        l.MDA__c = 'On File';
        l.Additional_Documentation_Attached__c = 'Documentation Attached';
        l.Booking_Audit_Checklist__c = Date.today() - 2;
        l.Activation_OM__c = userInfo.getUserId();
        l.Confirm_code_snip_placement_on_5_pages__c = false;
        l.Confirm_non_CDK_site_flow_from_code_snip__c = false;
        l.Dealer_Setup_in_OnStation__c = Date.Today() - 2;
        l.Sent_Activation_Email_to_Dealer__c = Date.Today() - 2;
        l.Closed_Order_in_Oracle__c = Date.Today() - 2;
        update l;
    }
    
    // created - 3/3/2016 - siva.pragada@cdk.com
    @testSetUp static void launchTestSetUp()
    {  
        string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Launch__c', 'A La Carte Launch');
        string currentOrg = ALL_UtilitiesMiscellaneous.GetCurrentInstanceName();
        boolean isThisProductionOrg = ALL_UtilitiesMiscellaneous.isProductionOrg();
        
        currentOrg = '.' + currentOrg;
        
        if(isThisProductionOrg)
        {
            currentOrg = '';
        }
        
        list<sObject> settingsObjects = new list<sObject>{ 
            new ALL_Query_Conditions__c(Name='001', sObject__c='Group', Key__c='Name', Operator__c='=', Value__c='OMS Queue', Identifier__c='001'),
            new ALL_Query_Conditions__c(Name='002', sObject__c='Case', Key__c='Name', Operator__c='=', Value__c='Onboarding - OMS', 
                                        Class_Name__c='DynamicSOQL_Helper', Method_Name__c='getRecordTypeId()', Describe_Call__c=true, Identifier__c='002'),
            new ALL_Query_Conditions__c(Name='003', sObject__c='User', Key__c='	UserName', Operator__c='=', 
                                        Class_Name__c='DynamicSOQL_Helper', Method_Name__c='getAdminUser()', Identifier__c='003'),         
            new ALL_Field_Value_Assignment_Settings__c(Name='001', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='OwnerId', Query_Field_s__c='ID', 
                                                       	Query_sObject__c='Group', Query_Conditions_Identifier__c='001', Identifier__c='001'),
            new ALL_Field_Value_Assignment_Settings__c(Name='002', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='RecordTypeId', Query_Conditions_Identifier__c='002', 
                                                       Identifier__c='002'), 
            new ALL_Field_Value_Assignment_Settings__c(Name='003', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='Requested_By__c', Query_Field_s__c='ID', 
                                                       	Query_sObject__c='User', Query_Conditions_Identifier__c='003',Identifier__c='003'), 
            new ALL_Field_Value_Assignment_Settings__c(Name='004', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='AccountId', Lending_sObject__c='Launch__c',
                                                       	Lending_Field_Name__c='Account__c', Identifier__c='004'),
            new ALL_Field_Value_Assignment_Settings__c(Name='005', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='WebID__c', Lending_sObject__c='Launch__c',
                                                       	Lending_Field_Name__c='WebID__c', Identifier__c='005'),
            new ALL_Field_Value_Assignment_Settings__c(Name='006', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='Launch__c', Lending_sObject__c='Launch__c',
                                                       	Lending_Field_Name__c='ID', Identifier__c='006'),
            new Field_Value_Conditions__c(Name='001', Identifier__c='001', Contains__c=true, Field_Name__c='Product_Type__c', Field_Value__c='Pre-Roll Video',  
                                          sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='002', Identifier__c='002', EqualsTo__c=true, Field_Name__c='RecordTypeID', Field_Value__c=recordTypeID, sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='003', Identifier__c='003', EqualsTo__c=true, Field_Name__c='WebID__r.Status__c', Field_Value__c='Active', sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='004', Identifier__c='004', Field_Name__c='WebID__r.Status__c', Field_Value__c='InActive', Not_EqualsTo__c=true, 
                                          sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='005', Identifier__c='005', Field_Name__c='Send_Onboarding__c', isBoolean__c=true, isTrue__c=false, sObject__c='Launch__c'),
            new ALL_Decision_Box_Settings__c(
                Name='001', Assignment_sObject__c='Case', Condition_Check__c='( ( 001 AND 004 ) OR 003 ) AND 002 AND 005', 
                ConditionCheck_sObject__c='Launch__c',Value_Assignment__c='001 AND 002 AND 003 AND 004 AND 005 AND 006'),
            new GlobalSettings__c(Launch_Onboarding_Switch__c=true, Admin_Integration_Username__c='integration_user@adp.com'+ currentOrg),
            new Trigger_Toggle__c(Name='001', Code_Reference__c='DSCB_CaseConcatenate_Handler', On__c=false, RecordType_Name__c=null, sObject__c='Case'),
            new Trigger_Toggle__c(Name='002', Code_Reference__c='DSCB_CaseConcatenate_Handler', On__c=true, RecordType_Name__c='Onboarding - OMS', sObject__c='Case'),
            new Trigger_Toggle__c(Name='003', Code_Reference__c='ALL_Launch', On__c=true, sObject__c='Launch__c')
            
        };
        
        insert settingsObjects;
        
    }
    
    // created - 3/3/2016 - siva.pragada@cdk.com
    static testMethod  void executeOnboardingLaunchTest()
    {
        Group grp = [select Id, Name From Group Where Name='OMS Queue'];
        list<sObject> settingsObjects = new list<sObject>();
        string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Launch__c', 'A La Carte Launch');
        Launch__c newLaunch = DS_TestObjects.NewLaunch();
        Account acc = (Account)newLaunch.getsObject('Account__r');
        WebID__c webID = DS_TestObjects.NewWebID();
        webID.Account__c = acc.ID;
        contact con  = DS_TestObjects.NewContact();
        con.AccountId = acc.ID;
        insert new list<sObject>{ webID, con };
        
        newLaunch.Product_Type__c = 'Pre-Roll Video';
        newLaunch.RecordTypeId = recordTypeID;
        newLaunch.Send_Onboarding__c = false;
        newLaunch.WebID__c = webID.ID;
        
        settingsObjects.add(newLaunch);
        
        insert settingsObjects;
        
        Case autoInsertedCase = [Select Id, CaseNumber, RecordType.Name From Case Limit 1];
        
        system.assertEquals(autoInsertedCase.recordType.Name, 'Onboarding - OMS');
     
    }
}