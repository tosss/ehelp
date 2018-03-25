/*
*	@test for ContactUpdateTriggerUpdates.
*	@Author		: Jeremy Mooer
*	@Date		: 21 Oct 2011
*/
//Dated                 	Modified By				Description
//22nd September, 2015 anirudh.singh@cdk.com		To upgrade the API Version FROM 20.0 to 34.0.
//2015-11-26           vishal.bandari@cdk.com       RQ-05289 added RecordType to Contact Object
//2016-01-08           brian.cook@cdk.com           rq-05034,  combine contact into one trigger/handler/test
@isTest
public class ContactUpdateTriggerUpdatesTest
{
    //no bulkification test necessary.
//    static testMethod void onUpdateCheckStatusAndUpdateRelatedValuesTest() 
//    {
//        Account accountTest=new Account(Name='AccountTest') ;
//        insert accountTest;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:uncommented line to add contact record type
//        RecordType recordtypeObj = [SELECT Id FROM RecordType where SObjectType = 'Contact' and Name = 'Customer Contact'][0];
//        Contact contactInactiveStatus=new Contact(AccountId=accountTest.Id, Status__c='Inactive', recordTypeid = recordtypeObj.Id,No_Longer_There__c=true, FirstName='Test', LastName='Test', Email='email@email.com', Role__c='Test Role'); // 9/29
//        Contact contactAtiveStatus=new Contact(AccountId=accountTest.Id, Status__c='Active', recordTypeid = recordtypeObj.Id,No_Longer_There__c=false, FirstName='Test', LastName='Test2', Email='email2@email.com', Role__c='Test Role'); // 9/29
//        Contact contactNoLongerThere=new Contact(AccountId=accountTest.Id, Status__c='Inactive', recordTypeid = recordtypeObj.Id,No_Longer_There__c=true, FirstName='Test', LastName='Test3', Email='email3@email.com', Role__c='Test Role'); // 9/29
//        Contact contactNotNoLongerThere=new Contact(AccountId=accountTest.Id, Status__c='Active', recordTypeid = recordtypeObj.Id,No_Longer_There__c=false, FirstName='Test', LastName='Test4', Email='email4@email.com', Role__c='Test Role'); // 9/29
        
//        Contact[] contactsToInsertAndUpdate=new Contact[]{contactInactiveStatus, contactAtiveStatus, contactNoLongerThere, contactNotNoLongerThere}; 
//        insert contactsToInsertAndUpdate;
        
//        Set<String> idSet=new Set<String>{contactInactiveStatus.Id, contactAtiveStatus.Id, contactNoLongerThere.Id, contactNotNoLongerThere.Id};
            
//        contactInactiveStatus.Status__c='Active';
//        contactAtiveStatus.Status__c='Inactive';
//        contactNoLongerThere.No_Longer_There__c=false;
//        contactNotNoLongerThere.No_Longer_There__c=true;
        
//        test.startTest();
//        update contactsToInsertAndUpdate;
//        test.stopTest();
        
//        for(Contact contactUpdated: [SELECT Id, Status__c, No_Longer_There__c FROM Contact WHERE Id IN :idSet])
//        {
//            if(contactUpdated.No_Longer_There__c==false)
//            {
//                system.assertEquals('Active', contactUpdated.Status__c);
//            }
//            else if(contactUpdated.No_Longer_There__c==true)
//            {
//              system.assertEquals('Inactive', contactUpdated.Status__c);
//            }
//        }
//    }
}