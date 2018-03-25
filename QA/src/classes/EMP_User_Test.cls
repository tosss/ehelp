/*******************************************************
* Author: Hemanth.Kesapragada@cdk.com
* Description: Test class for EMP_User_Handler
* 
* History:
* 2015-12-09 	Hemanth Kesapragada		Created
* *************************************************** */
@isTest
public class EMP_User_Test {
    
    @TestSetup
    public static void loadData()
    {
        Account acc  = DS_TestObjects.NewAccount_Inserted();
        CustomSettings__c cs = new CustomSettings__c();
        cs.CDK_Global_Account_Id__c = acc.Id;
        insert cs;
    }
    
    public static testMethod void testCreateContactForUser()
    {
        User currentLoggedInUser = [select id from User where id=:UserInfo.getUserId()];
        System.runAs(currentLoggedInUser)
        {
            Test.startTest();
            User userObj1 = new User();
            userObj1.FirstName = 'TestFirstName';
            userObj1.LastName = 'TestLastName';
            userObj1.Alias = 'TestFull';
            userObj1.Username = 'TestFirstName.TestLastName@cdk.com.test';
            userObj1.Email = 'TestFirstName.TestLastName@cdk.com';
            userObj1.profileId = [Select Id, Name From Profile Where Name = 'Standard User' Limit 1].Id;
            userObj1.ADID__c = '12345678';
            userObj1.FederationIdentifier = 'F12345678';
            userObj1.EmailEncodingKey='UTF-8'; 
            userObj1.LanguageLocaleKey='en_US'; 
            userObj1.LocaleSIDKey='en_US'; 
            userObj1.TimeZoneSIDKey='America/Chicago';
            insert userObj1;
            
            List<User> newUsersList = [
                select id,FirstName,LastName,Email,Contractor__c,Non_Employee__c,Non_Interactive_User__c,IsActive,Hire_Date__c 
                from User 
                where FirstName ='TestFirstName' and LastName='TestLastName'
            ];
            
            User UserObj;
            if(newUsersList != null && !newUsersList.isEmpty())
            {
                UserObj = newUsersList.get(0);
                Map<Id,User> newUserMap = new Map<Id,User>();
                newUserMap.put(UserObj.Id, UserObj);
                EMP_User_Handler.afterInsert(newUsersList, newUserMap);
                EMP_User_Handler.afterUpdate(newUsersList, newUsersList, newUserMap, newUserMap);
            }
            
            Test.stopTest();
            
            if(UserObj != null)
            {
                List<Contact> ContactsList = [
                    select id,FirstName,LastName,Email 
                    from Contact 
                    where Email = :UserObj.Email
                ];
                
                if(ContactsList != null && !ContactsList.isEmpty())
                {
                    Contact conObj = ContactsList.get(0);
                    System.assertEquals(UserObj.FirstName,conObj.FirstName);
                    System.assertEquals(UserObj.LastName,conObj.LastName);
                }
            }
        }
    }
    
}