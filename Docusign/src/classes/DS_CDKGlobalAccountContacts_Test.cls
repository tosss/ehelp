//RQ-04894 : Trigger on Contact to set User.ContactId when Contact.User__c is ins/upd

//2015-07-02 : vishal.bandari@cdk.com - updated updateUser method to meet RQ-04894 requirement, added 'negativeTest' method

@IsTest
public class DS_CDKGlobalAccountContacts_Test
{    
    //To setup test data
    @TestSetup
    private static void setupTestData()
    {
        //Creating CDK GLOBAL Account
        Account newAccount =  DS_TestObjects.NewAccount();
        newAccount.Name = 'CDK GLOBAL';
        insert newAccount;
        
        //Updating the Org Defaults of CustomSetting__c 
        CustomSettings__c orgDefualts = CustomSettings__c.getOrgDefaults();
        orgDefualts.CDK_Global_Account_Id__c = newAccount.Id;
        insert orgDefualts;
               
        //Creating new User with Emp_Contact__c field not set
        User newUser = DS_TestObjects.NewUser();
        newUser.Firstname = 'ContactTestUser';
        newUser.Lastname = 'ContactUser';
        insert newUser;
        
        
        //Creating new User with Emp_Contact__c field not set
        newUser = DS_TestObjects.NewUser();
        newUser.Firstname = 'ContactTestUser2';
        newUser.Lastname = 'ContactUser2';
        insert newUser;
        
        //Creating new Contact for CDK GLOBAL Account and newUser
        Contact newContact = DS_TestObjects.NewContact();
        newContact.AccountId = newAccount.Id;
        newContact.FirstName = 'test';
        newContact.LastName = 'TestContact';
        newContact.User__c = newUser.ID;
        insert newContact;
    }
    
    public static testmethod void updateUserTest()
    {
        //Updating Emp_Contact__c of User to null.
        User newUser = [
            SELECT Id, Emp_Contact__c 
            FROM User 
            WHERE FirstName = 'ContactTestUser2'
        ];
        
        newUser.Emp_Contact__c = null;
        update newUser;
               
        //Retrieve newly created Contact
        Contact newContact = [
            select id, Vendor_Id__c, User__c, User__r.Contact_Vendor_Id__c,AccountId, User__r.Emp_Contact__c
            from contact 
            where Name 
            Like '%TestContact%'
            Limit 1
        ];
         
        //Scenario :1   Changing the Contact VendorId from null to valid input
        newContact.Vendor_ID__c = 'V123456';
        update newContact;
        
        User updatedUser = [
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c
            FROM User 
            WHERE FirstName = 'ContactTestUser2'
        ];
        
        System.assertEquals(newContact.Id, updatedUser.EMP_Contact__c);
        System.assertEquals(newContact.Vendor_ID__c, updatedUser.Contact_Vendor_Id__c);
        
        //Scenario :2   Changing the Contact VendorId
        newContact.Vendor_ID__c = 'V654321';
        update newContact;
        updatedUser = [
            SELECT Id, Contact_Vendor_Id__c
            FROM User 
            WHERE FirstName = 'ContactTestUser2'
        ];

        System.assertEquals(newContact.Vendor_ID__c, updatedUser.Contact_Vendor_Id__c);
        
        //Scenario :3   Changing the Contact UserId
        updatedUser = [
            SELECT Id
            FROM User 
            WHERE FirstName = 'ContactTestUser'
        ];
        newContact.User__C = updatedUser.Id;
        update newContact;
        
        User updatedUser1 = [
            SELECT Id, Contact_Vendor_Id__c
            FROM User 
            WHERE FirstName = 'ContactTestUser2'
        ];
        
        User updatedUser2 = [
            SELECT Id, Contact_Vendor_Id__c
            FROM User 
            WHERE FirstName = 'ContactTestUser'
        ];
        
        System.assertEquals(null, updatedUser1.Contact_Vendor_ID__c);
        System.assertEquals(newContact.Vendor_ID__c, updatedUser2.Contact_Vendor_ID__c);
        
        //Scenario :4 Inserting a new Contact with VendorId
        newContact = DS_TestObjects.NewContact();
        newContact.AccountId = CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c;
        newContact.FirstName = 'test';
        newContact.LastName = 'TestContact2';
        newContact.User__c = updatedUser1.Id;
        newContact.Vendor_ID__c = 'V123456';
        insert newContact;
        
        updatedUser1 = [
            SELECT Id, Contact_Vendor_Id__c
            FROM User 
            WHERE FirstName = 'ContactTestUser2'
        ];
        
        System.assertEquals(newContact.Vendor_ID__c, updatedUser1.Contact_Vendor_ID__c);
        
        //Scenario :5 Inserting a new Contact without VendorId
        newContact = new Contact();
        newContact.AccountId = CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c;
        newContact.FirstName = 'test';
        newContact.LastName = 'TestContact3';
        newContact.User__c = updatedUser1.Id;
        insert newContact;
        
        updatedUser1 = [
            SELECT Id, Contact_Vendor_Id__c
            FROM User 
            WHERE FirstName = 'ContactTestUser2'
        ];
        
        System.assertEquals(null, updatedUser1.Contact_Vendor_ID__c);
        
    }
    
    //To perform negitive test
    public static testmethod void negativeTest()
    {
        DS_CDKGlobalAccountContacts_Handler.updateUser(null,null);
        
    }
}