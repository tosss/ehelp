/*******************************************************
* Author: Sanjay.Ghanathey@cdk.com
* Description: Test class for ALL_AngularInputFields class
* 
* History:
* 2015-07-30 	Sanjay Ghanathey		Created
* 2015-07-30	Sanjay Ghanathey		Typeahead Test
* 2015-08-01	Sanjay Ghanathey		Picklist Test
* 2015-03-01  	Raga Shalini Koka       GetNameForId Test
* *************************************************** */
@isTest
public class ALL_AngularInputFields_Test {
    
    public static testMethod void  testTypeahead()
    {
        List<sObject> genericList = new List<sObject>();
        Account account = DS_TestObjects.NewAccount_Inserted();
        String resultJSON = ALL_AngularInputFields_Controller.retrieveLookupData('Account','Id,Name','test','Name');        
        List<Account> accountList = (List<Account>)JSON.deserialize(resultJSON, List<Account>.class);
        System.assertNotEquals(accountList.size(), 2);
        resultJSON = ALL_AngularInputFields_Controller.doPost('Account','Id,Name','test','Name');
        accountList = (List<Account>)JSON.deserialize(resultJSON, List<Account>.class);        
        System.assertNotEquals(accountList.size(), 2);        
    }
    
    public static testMethod void  testPicklist()
    {
        List<ALL_AngularInputFields_Controller.Picklist> picklist = ALL_AngularInputFields_Controller.getPicklistValues('Account','Industry');
        System.assertNotEquals(picklist.size(), 0);
    }
    
    static testMethod void testGetNameForId()
    {
         Account account = DS_TestObjects.NewAccount_Inserted();
         String accountName = ALL_AngularInputFields_Controller.getNameForId(account.Id,'Name','Account');
         System.assertEquals(account.Name, accountName);
         delete account;
         accountName = ALL_AngularInputFields_Controller.getNameForId(account.Id,'Name','Account');
         System.assertEquals('', accountName);
    }
}