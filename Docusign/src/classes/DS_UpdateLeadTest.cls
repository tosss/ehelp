@IsTest
public class DS_UpdateLeadTest
{
    public static testmethod void UpdateLead()
    {
        GlobalSettings__c gs = new GlobalSettings__c(
            Lead_Owner_Mgrs_Mgr_Roles_to_Exclude__c = 'Fake Role' // in other words, do not exclude
        ); insert gs;
        
        User NewLeadOwner = DS_TestObjects.NewUser();
		NewLeadOwner.UserRoleId = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id;
		system.runas(DS_TestObjects.CurrentUser()) { insert NewLeadOwner; } 
        
        Account TestAccount = DS_TestObjects.NewAccount_Inserted();
        
        Contact TestContact = DS_TestObjects.NewContact();
        TestContact.AccountId = TestAccount.Id; 
        TestContact.Phone = '(847) 555-0001'; // test phone number updating
        TestContact.MobilePhone = '(847) 555-0002'; // test phone number updating
        TestContact.Role__c = 'Test Role'; // 9/29
        insert TestContact;
        
        Lead TestLead = DS_TestObjects.NewLead();
        TestLead.Current_Account__c = TestContact.AccountId;
        TestLead.Contact__c = TestContact.Id;
        TestLead.LeadSource = 'Trade Show - NADA';
        insert TestLead;
        
        TestLead.OwnerId = NewLeadOwner.Id;
        update TestLead;
    }
}