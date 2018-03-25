//Modified By				Dated					Description
//anirudh.singh@cdk.com		22nd September, 2015	To upgrade the API Version FROM 29.0 to 34.0.

//History
//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed UpdateLead method to add contact record type
//2016-04-15 : venkata.shrivol@cdk.com - Commented to two test methods which checks for Lead Opp conversion.
//2016-06-16 : vishal.bandari@cdk.com - added logic to invoke ALL_SharedContact_Helper.insertContact to update Contact
//2017-03-31 - lalitha.adduru@cdk.com - commented this class as it's moved to ALL_Lead_test - RQ-06389
@IsTest
public class DS_UpdateLeadTest
{
    /*public static testmethod void UpdateLead()
    {
        GlobalSettings__c gs=new GlobalSettings__c(
            Lead_Owner_Mgrs_Mgr_Roles_to_Exclude__c='Fake Role' // in other words, do not exclude
        ); insert gs;
        
        Trigger_Toggle_Profile__c ttp = new Trigger_Toggle_Profile__c(
            Name = 'Lead Trigger Profile for Current User', 
            On__c = true,
            Code_Reference__c = 'Lead',
            sobject__C = 'Lead',
            Profile_Id__c = UserInfo.getProfileId()
        );
        insert ttp;
        
        Trigger_Toggle__c tt =new Trigger_Toggle__c(
            Name = 'Lead Trigger Profile for Current User', 
            On__c = true,
            Code_Reference__c = 'Lead',
            sobject__C = 'Lead'
        );
        insert tt;
        
        User NewLeadOwner=DS_TestObjects.NewUser();
        NewLeadOwner.UserRoleId=[Select Id, RollupDescription From UserRole Where RollupDescription='Data Librarian'].Id;
        system.runas(DS_TestObjects.CurrentUser()) { insert NewLeadOwner; } 
        
        Account TestAccount=DS_TestObjects.NewAccount();
        TestAccount.Key_Rep__c = UserInfo.getuserId();
        insert TestAccount;
        
        Contact TestContact=DS_TestObjects.NewContact();
        TestContact.AccountId=TestAccount.Id; 
        //TestContact.Phone='(847) 555-0001'; // test phone number updating
        TestContact.MobilePhone='(847) 555-0002'; // test phone number updating
        //TestContact.Role__c=; // 9/29
        
         //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        TestContact.RecordType = [select id from recordtype where name = 'Customer Contact' and sObjectType='Contact'][0];
        //2016-06-16- vishal.bandari@cdk.com - added logic to invoke ALL_SharedContact_Helper.insertContact to update Contact
        ALL_SharedContact_Helper.insertContact(TestContact,'Test Role',null,null);
         
        Lead TestLead=DS_TestObjects.NewLead();
        TestLead.Current_Account__c=TestContact.AccountId;
        TestLead.Contact__c=TestContact.Id;
        TestLead.LeadSource='Trade Show - NADA';
        insert TestLead;
        
        TestLead.OwnerId=NewLeadOwner.Id;
        update TestLead;
    }
    
    //2016-04-15 : venkata.shrivol@cdk.com - Commented to two test methods which checks for Lead Opp conversion.
   /* public static testmethod void ConvertLeadWithoutOpportunity()
    {
        Account accObj = DS_TestObjects.NewAccount_Inserted();
        Contact conObj = DS_TestObjects.NewContact();
        conObj.AccountId = accObj.Id;
        insert conObj;
        
        Opportunity oppObj = DS_TestObjects.NewOpportunity();
        oppObj.AccountId = accObj.Id;
        insert oppObj;
        
        Campaign camObj = DS_TestObjects.NewCampaign_Inserted();
        Lead leadObj = DS_TestObjects.NewLead();
        leadObj.Current_Account__C = accObj.Id;
        leadObj.Contact__c = conObj.Id;
        insert leadObj;
        
        Test.startTest();
        leadObj.Status ='Converted to Opportunity';
        update leadObj;
        Test.stopTest();
     
        leadObj = [Select isConverted from lead where Id =: leadObj.Id];
        
        System.assert(leadObj.IsConverted,'Couldnot convert lead with no Opportunity');
        
       
    }
    
    public static testmethod void ConvertLeadWithOpportunity()
    {
        Account accObj = DS_TestObjects.NewAccount_Inserted();
        Contact conObj = DS_TestObjects.NewContact();
        conObj.AccountId = accObj.Id;
        insert conObj;
        
        Opportunity oppObj = DS_TestObjects.NewOpportunity();
        oppObj.AccountId = accObj.Id;
        insert oppObj;
        
        Campaign camObj = DS_TestObjects.NewCampaign_Inserted();
        Lead leadObj = DS_TestObjects.NewLead();
        leadObj.Current_Account__C = accObj.Id;
        leadObj.Contact__c = conObj.Id;
        leadObj.Opportunity__c = oppObj.Id;
        insert leadObj;
        
        Test.startTest();
        leadObj.Status ='Converted to Opportunity';
        update leadObj;
        Test.stopTest();
        leadObj = [Select isConverted from lead where Id =: leadObj.Id];
        
        System.assert(leadObj.IsConverted,'Couldnot convert lead with no Opportunity');
    }*/
    

}