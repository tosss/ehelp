//2017-01-17  ragashalini.koka@cdk.com  - RQ-08462 - Created this class
@isTest
public class SLS_Top5List_Test {

    @testSetup
    static void setupTestData() {
        Account acc = DS_TestObjects.NewAccount_Inserted();
       Map<Id,RecordType> top5RecordTypeMap = new Map<Id,RecordType>([SELECT Id, Name FROM RecordType WHERE SobjectType='Top_5__c']);
        List<Top_5__c> top5List = new List<Top_5__c>();
        for(String recId : top5RecordTypeMap.keySet()) {
            Top_5__c top5Rec = new Top_5__c();
            top5Rec.RecordTypeId = recId;
            top5Rec.Account__c = acc.Id;
            top5Rec.Comments__c = 'Test Comments';
            top5Rec.Status__c = 'Green';
            top5List.add(top5Rec);
        }
        insert top5List;
        
        List<String> forecastingChannelList = new List<String>{'Digital Solutions', 'Truck', 'Canada', 'All', 'Central', null};
        List<User> userList = new List<User>();
        for(String channel : forecastingChannelList) {
            User usr = DS_TestObjects.NewUser();
            usr.Forecasting_Channel__c = channel;
            usr.Title = (channel == 'All') ? 'ADE' : (channel == 'Central') ? 'Test Title' : null;
            userList.add(usr);
        }
        insert userList;
        
    }
    
    testmethod static void  validatePrimary() {
       List<User> userList = [SELECT Id FROM User ORDER BY CreatedDate desc LIMIT 6];
       Test.startTest();
        for(User usr : userList) {
            System.runAs(usr) {
              PageReference reference = new PageReference('/apex/SLS_Top5ListPage_Primary');
              Test.setCurrentPage(reference);
               new SLS_Top5List_Controller();
            }
        }
        Test.stopTest();
       
    }
    
    testmethod static void  validateSecondary() {
       List<User> userList = [SELECT Id FROM User ORDER BY CreatedDate desc LIMIT 6];
       Test.startTest();
        for(User usr : userList) {
            System.runAs(usr) {
              PageReference reference = new PageReference('/apex/SLS_Top5ListPage_Secondary');
              Test.setCurrentPage(reference);
               new SLS_Top5List_Controller();
            }
        }
        Test.stopTest();
       
    }
}