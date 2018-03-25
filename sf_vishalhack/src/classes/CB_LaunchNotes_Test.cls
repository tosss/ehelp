@isTest
public class CB_LaunchNotes_Test 
{
    static testMethod void insertLaunches()
    {
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
        
        Insert newLaunch;
        
        Launch_Notes__c ln = new Launch_Notes__c();
        ln.Launch_Id__c = newLaunch.ID;
        ln.Notes__c = 'test notes';
        ln.Notes_Type__c = 'Designer';
        ln.Date__c = DateTime.now();
        
        CB_LaunchNotes_Handler.saveLaunchNotes(ln);
        CB_LaunchNotes_Handler.getAllLaunchNotes(ln.Launch_Id__c);
    }

}