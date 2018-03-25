//Modified By				Dated					Description
//anirudh.singh@cdk.com		22nd September, 2015	To upgrade the API Version FROM 29.0 to 34.0.

//History
//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed UpdateLead method to add contact record type
@IsTest
public class DS_UpdateLeadTest
{
    public static testmethod void UpdateLead()
    {
        GlobalSettings__c gs=new GlobalSettings__c(
            Lead_Owner_Mgrs_Mgr_Roles_to_Exclude__c='Fake Role' // in other words, do not exclude
        ); insert gs;
        
        User NewLeadOwner=DS_TestObjects.NewUser();
        NewLeadOwner.UserRoleId=[Select Id, RollupDescription From UserRole Where RollupDescription='Data Librarian'].Id;
        system.runas(DS_TestObjects.CurrentUser()) { insert NewLeadOwner; } 
        
        Account TestAccount=DS_TestObjects.NewAccount();
        TestAccount.Key_Rep__c = UserInfo.getuserId();
        insert TestAccount;
        
        Contact TestContact=DS_TestObjects.NewContact();
        TestContact.AccountId=TestAccount.Id; 
        TestContact.Phone='(847) 555-0001'; // test phone number updating
        TestContact.MobilePhone='(847) 555-0002'; // test phone number updating
        TestContact.Role__c='Test Role'; // 9/29
        
         //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        TestContact.RecordType = [select id from recordtype where name = 'Customer Contact' and sObjectType='Contact'][0];
        insert TestContact;
        
        Lead TestLead=DS_TestObjects.NewLead();
        TestLead.Current_Account__c=TestContact.AccountId;
        TestLead.Contact__c=TestContact.Id;
        TestLead.LeadSource='Trade Show - NADA';
        insert TestLead;
        
        TestLead.OwnerId=NewLeadOwner.Id;
        update TestLead;
    }
    
    
    public static testmethod void ConvertLead()
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
        
        leadObj.Status ='Converted to Opportunity';
        update leadObj;
     
        leadObj = [Select isConverted from lead where Id =: leadObj.Id];
        
        System.assert(leadObj.IsConverted,'Couldnot convert lead with no Opportunity');
        
        leadObj = DS_TestObjects.NewLead();
        leadObj.Current_Account__C = accObj.Id;
        leadObj.Contact__c = conObj.Id;
        leadObj.Opportunity__c = oppObj.Id;
        insert leadObj;
        
        leadObj.Status ='Converted to Opportunity';
        update leadObj;
        
        leadObj = [Select isConverted from lead where Id =: leadObj.Id];
        
        System.assert(leadObj.IsConverted,'Couldnot convert lead with no Opportunity');
    }

}