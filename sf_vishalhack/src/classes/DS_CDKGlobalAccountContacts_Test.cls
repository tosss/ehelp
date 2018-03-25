//RQ-04894 : Trigger on Contact to set User.ContactId when Contact.User__c is ins/upd
//2015-07-02 : vishal.bandari@cdk.com - updated updateUser method to meet RQ-04894 requirement, added 'negativeTest' method
//2015-11-27 : vishal.bandari@cdk.com    RQ-05289:changed methods to add contact record type
//2016-03-15- anirudh.singh@cdk.com- Re-written the whole test class to bring it up to standards. 
//2016-03-15- anirudh.singh@cdk.com- Added testing logic for Hire Date and Rehire Date.
//2016-05-10- anirudh.singh@cdk.com- Changed the positon of test.stopTest() in all the testMethods due to error in assertions due to invoking of future methods.
@isTest
public class DS_CDKGlobalAccountContacts_Test
{    
    //To setup test data
    @TestSetup
    private static void setupTestData()
    {
        List<User> userList=new List<User>();
        //Creating new User with Emp_Contact__c field not set.
        User userOne=DS_TestObjects.NewUser();
        userOne.Firstname='ContactTestUser 1';
        userList.add(userOne);
        
        //Creating new User with Emp_Contact__c field not set.
        User userTwo=DS_TestObjects.NewUser();
        userTwo.Firstname='ContactTestUser 2';
        userList.add(userTwo);
        insert userList;
        
        //Creating CDK GLOBAL Account.
        Account accountRecord=DS_TestObjects.NewAccount();
        accountRecord.Name='CDK GLOBAL';
        insert accountRecord;
        
        //Updating the Org Defaults of CustomSetting__c.
        CustomSettings__c customSettingRecord=CustomSettings__c.getOrgDefaults();
        customSettingRecord.CDK_Global_Account_Id__c=accountRecord.Id;
        insert customSettingRecord;
    }
    
    private static testMethod void updateUserForAfterInsertTest()
    {
        Account accountRecord=[SELECT Id FROM Account];
        Map<Id, User> userMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        userMap.values()[0].Emp_Contact__c=Null;
        userMap.values()[1].Emp_Contact__c=Null;
        update userMap.values();
        
        List<Contact> contactList=[SELECT Id, User__c FROM Contact WHERE User__c IN :userMap.keySet()];
        contactList[0].User__c=Null;
        contactList[1].User__c=Null;
        update contactList;
        
        test.startTest();
        Contact newContact=DS_TestObjects.NewContact();
        newContact.AccountId=accountRecord.Id;
        newContact.FirstName='Test';
        newContact.LastName='Test Contact';
        newContact.RecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        newContact.User__c=userMap.values()[0].Id;
        newContact.Vendor_ID__c='5176537450';
        newContact.HR_Rehire_Date__c=date.newInstance(2016, 03, 01);
        insert newContact;
        
        List<Contact> newContactList=new List<Contact>();
        newContactList.add(newContact);
        
        DS_CDKGlobalAccountContacts_Handler.updateUser(newContactList, Null);
        test.stopTest();
        
        Map<Id, User> updatedUserMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        system.assertEquals(Null, userMap.values()[0].Emp_Contact__c, 'Emp_Contact__c field value on old User record was Null.');
        system.assertNotEquals(Null, updatedUserMap.values()[0].Emp_Contact__c, 'Emp_Contact__c field value on User record updated.');
        system.assertEquals(newContact.Id, updatedUserMap.values()[0].Emp_Contact__c, 'Emp_Contact__c field value on User record updated.');
        
        system.assertEquals(Null, userMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on old User record was Null.');
        system.assertEquals('5176537450', updatedUserMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record updated.');
        system.assertEquals(newContact.Vendor_Id__c, updatedUserMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record updated.');
        
        system.assertEquals(Null, userMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on old User record was Null.');
        system.assertEquals(date.newInstance(2016, 03, 01), updatedUserMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on User record updated.');
        system.assertEquals(newContact.HR_Rehire_Date__c, updatedUserMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on User record updated.');
    }
    
    private static testMethod void updateUserForAfterUpdateTest()
    {
        Account accountRecord=[SELECT Id FROM Account];
        Map<Id, User> userMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        userMap.values()[0].Emp_Contact__c=Null;
        userMap.values()[1].Emp_Contact__c=Null;
        update userMap.values();
        
        List<Contact> contactList=[SELECT Id, User__c FROM Contact WHERE User__c IN :userMap.keySet()];
        contactList[0].User__c=Null;
        contactList[1].User__c=Null;
        update contactList;
        
        test.startTest();
        Contact oldContact=DS_TestObjects.NewContact();
        oldContact.AccountId=accountRecord.Id;
        oldContact.FirstName='Test';
        oldContact.LastName='Test Contact';
        oldContact.RecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        oldContact.User__c=userMap.values()[0].Id;
        oldContact.Vendor_ID__c='5176537450';
        oldContact.HR_Rehire_Date__c=date.newInstance(2016, 03, 01);
        insert oldContact;
        
        Map<Id, Contact> oldContactMap=new Map<Id, Contact>();
        oldContactMap.put(oldContact.Id, oldContact);
        
        Contact newContact=new Contact();
        newContact=oldContact.clone(true);
        newContact.Vendor_ID__c='5176537451';
        newContact.HR_Rehire_Date__c=date.newInstance(2016, 03, 02);
        
        List<Contact> newContactList=new List<Contact>();
        newContactList.add(newContact);
        
        DS_CDKGlobalAccountContacts_Handler.updateUser(newContactList, oldContactMap);
        test.stopTest();
        
        Map<Id, User> updatedUserMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        system.assertEquals(Null, userMap.values()[0].Emp_Contact__c, 'Emp_Contact__c field value on old User record was Null.');
        system.assertNotEquals(Null, updatedUserMap.values()[0].Emp_Contact__c, 'Emp_Contact__c field value on User record updated.');
        system.assertEquals(newContact.Id, updatedUserMap.values()[0].Emp_Contact__c, 'Emp_Contact__c field value on User record updated.');
        
        system.assertEquals(Null, userMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on old User record was Null.');
        system.assertEquals('5176537451', updatedUserMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record updated.');
        system.assertEquals(newContact.Vendor_Id__c, updatedUserMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record updated.');
        
        system.assertEquals(Null, userMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on old User record was Null.');
        system.assertEquals(date.newInstance(2016, 03, 02), updatedUserMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on User record updated.');
        system.assertEquals(newContact.HR_Rehire_Date__c, updatedUserMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on User record updated.');
    }
    
    private static testMethod void updateUserForAfterUpdateUserNullTest()
    {
        Account accountRecord=[SELECT Id FROM Account];
        Map<Id, User> userMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        userMap.values()[0].Emp_Contact__c=Null;
        userMap.values()[1].Emp_Contact__c=Null;
        update userMap.values();
        
        List<Contact> contactList=[SELECT Id, User__c FROM Contact WHERE User__c IN :userMap.keySet()];
        contactList[0].User__c=Null;
        contactList[1].User__c=Null;
        update contactList;
        
        test.startTest();
        Contact oldContact=DS_TestObjects.NewContact();
        oldContact.AccountId=accountRecord.Id;
        oldContact.FirstName='Test';
        oldContact.LastName='Test Contact';
        oldContact.RecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        oldContact.User__c=userMap.values()[0].Id;
        oldContact.Vendor_ID__c='5176537450';
        oldContact.HR_Rehire_Date__c=date.newInstance(2016, 03, 01);
        insert oldContact;
        
        Map<Id, Contact> oldContactMap=new Map<Id, Contact>();
        oldContactMap.put(oldContact.Id, oldContact);
        
        Contact newContact=new Contact();
        newContact=oldContact.clone(true);
        newContact.User__c=Null;
        newContact.Vendor_ID__c='5176537451';
        newContact.HR_Rehire_Date__c=date.newInstance(2016, 03, 02);
        
        List<Contact> newContactList=new List<Contact>();
        newContactList.add(newContact);
        
        DS_CDKGlobalAccountContacts_Handler.updateUser(newContactList, oldContactMap);
        test.stopTest();
        
        Map<Id, User> updatedUserMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        system.assertEquals(Null, updatedUserMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record not updated.');
        system.assertNotEquals(newContact.Vendor_Id__c, updatedUserMap.values()[0].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record not updated.');
        
        system.assertEquals(date.newInstance(2016, 03, 01), updatedUserMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on User record not updated.');
        system.assertNotEquals(newContact.HR_Rehire_Date__c, updatedUserMap.values()[0].Hire_Date__c, 'Hire_Date__c field value on User record not updated.');
    }
    
    private static testMethod void updateUserForAfterUpdateNewUserTest()
    {
        Account accountRecord=[SELECT Id FROM Account];
        Map<Id, User> userMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        userMap.values()[0].Emp_Contact__c=Null;
        userMap.values()[1].Emp_Contact__c=Null;
        update userMap.values();
        
        List<Contact> contactList=[SELECT Id, User__c FROM Contact WHERE User__c IN :userMap.keySet()];
        contactList[0].User__c=Null;
        contactList[1].User__c=Null;
        update contactList;
        
        test.startTest();
        Contact oldContact=DS_TestObjects.NewContact();
        oldContact.AccountId=accountRecord.Id;
        oldContact.FirstName='Test';
        oldContact.LastName='Test Contact';
        oldContact.RecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        oldContact.User__c=userMap.values()[0].Id;
        oldContact.Vendor_ID__c='5176537450';
        oldContact.HR_Rehire_Date__c=date.newInstance(2016, 03, 01);
        insert oldContact;
        
        Map<Id, Contact> oldContactMap=new Map<Id, Contact>();
        oldContactMap.put(oldContact.Id, oldContact);
        
        Contact newContact=new Contact();
        newContact=oldContact.clone(true);
        newContact.User__c=userMap.values()[1].Id;
        newContact.Vendor_ID__c='5176537451';
        newContact.HR_Rehire_Date__c=Null;
        newContact.HR_Hire_Date__c=date.newInstance(2016, 03, 02);
        
        List<Contact> newContactList=new List<Contact>();
        newContactList.add(newContact);
        
        DS_CDKGlobalAccountContacts_Handler.updateUser(newContactList, oldContactMap);
        test.stopTest();
        
        Map<Id, User> updatedUserMap=new Map<Id, User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c 
            FROM User WHERE FirstName LIKE 'ContactTestUser%'
        ]);
        
        system.assertEquals(Null, userMap.values()[1].Emp_Contact__c, 'Emp_Contact__c field value on old User record was Null.');
        system.assertNotEquals(Null, updatedUserMap.values()[1].Emp_Contact__c, 'Emp_Contact__c field value on User record updated.');
        system.assertEquals(newContact.Id, updatedUserMap.values()[1].Emp_Contact__c, 'Emp_Contact__c field value on User record updated.');
        
        system.assertEquals(Null, userMap.values()[1].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on old User record was Null.');
        system.assertEquals('5176537451', updatedUserMap.values()[1].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record updated.');
        system.assertEquals(newContact.Vendor_Id__c, updatedUserMap.values()[1].Contact_Vendor_Id__c, 'Contact_Vendor_Id__c field value on User record updated.');
        
        system.assertEquals(Null, userMap.values()[1].Hire_Date__c, 'Hire_Date__c field value on old User record was Null.');
        system.assertEquals(date.newInstance(2016, 03, 02), updatedUserMap.values()[1].Hire_Date__c, 'Hire_Date__c field value on User record updated.');
        system.assertEquals(newContact.HR_Hire_Date__c, updatedUserMap.values()[1].Hire_Date__c, 'Hire_Date__c field value on User record updated.');
    }
    
    private static testMethod void updateUserNegativeTest()
    {
        DS_CDKGlobalAccountContacts_Handler.updateUser(Null, Null);
    }
}