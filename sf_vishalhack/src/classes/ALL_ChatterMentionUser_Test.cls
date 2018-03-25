/*******************************************************
* Author: Hemanth.Kesapragada@cdk.com
* Description: Test class to test ALL_ChatterMentionUser_ProcessBuilder class
* 
* History:
* 2015-08-20 	Hemanth Kesapragada		Created
* 2015-08-19	Hemanth Kesapragada		Added testAddChatterMention method
seeAllData is set to true to avoid below error
System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. 
Please use @IsTest(SeeAllData=true).
* *************************************************** */
@isTest(seeAllData=true)
public class ALL_ChatterMentionUser_Test {
 
    private static final boolean RUN_ADD_CHATTER_MENTION = true;
    private static final boolean RUN_ALL = true;
    private static final boolean GENERATE_DEBUG_LOGS = true;
    
    public static testMethod void testAddChatterMention()
    {
        if(RUN_ADD_CHATTER_MENTION || RUN_ALL)
        {
            setHeaders('Testing add chatter mentions method');
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            currentUser.Forecasting_Channel__c = 'All';
            update currentUser;
            
            System.runAs(currentUser)
            {
                 Account acc = DS_TestObjects.NewAccount_Inserted();
                //Id recordID = [select id from Account limit 1].Id;
                Opportunity oppObj = DS_TestObjects.NewOpportunity();
                oppObj.AccountId = acc.Id;
                insert oppObj;
                
                User userObj = [select id,FirstName,LastName from User where id = :UserInfo.getUserId()];
                String text = 'Testing mention';
                Test.startTest();
                ALL_ChatterMentionUser_ProcessBuilder.ChatterMentionWrapper wrapperObj = new ALL_ChatterMentionUser_ProcessBuilder.ChatterMentionWrapper();
                wrapperObj.recordId = oppObj.id;
                wrapperObj.userId = userObj.Id;
                wrapperObj.text = text;
                List< ALL_ChatterMentionUser_ProcessBuilder.ChatterMentionWrapper> wrapperList = new List< ALL_ChatterMentionUser_ProcessBuilder.ChatterMentionWrapper>();
                wrapperList.add(wrapperObj);
                
                List<FeedItem> feedItemList = [select id,body from FeedItem where parentId=:oppObj.id];
                System.assertEquals(0, feedItemList.size());
                
                ALL_ChatterMentionUser_ProcessBuilder.addChatterMention(wrapperList);
                
                feedItemList = [select id,body from FeedItem where parentId=:oppObj.Id];
                System.assertEquals(1, feedItemList.size());
                
                FeedItem feedItemObj = feedItemList.get(0);
                String expectedBody = '@'+userObj.FirstName+' '+userObj.LastName+' '+text;
                String actualBody = feedItemObj.body;
                System.assertEquals(expectedBody.toLowerCase(), actualBody.toLowerCase());
               
                //delete oppObj;
                Test.stopTest();
            }
        }
    }
    
    private static void setHeaders(String txt)
    {
        if(GENERATE_DEBUG_LOGS)
        {
            System.debug('*************************************');
            System.debug('***** '+txt);
            System.debug('*************************************');
        }
    }

}