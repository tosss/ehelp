//2017-05-17 lalitha.adduru@cdk.com modified this test class to test RQ-09223
@IsTest
public class ALL_SalesDiscovery_Test 
{
    @Testsetup
    public static void setupData()
    {
        // added by lalitha
        Id userId = UserInfo.getUserId();
        AVP_RGM_Link__c link = new 	AVP_RGM_Link__c(ARM_Supervisor__c = userId,
                                                    Implementation_Director__c = userId,
                                                    Controller__c = userId,
                                                    Region__c = 'Division');
        insert link;
        
        Account accObj = new Account(Name='TestAccount');
        insert accObj;
        
        Opportunity oppObj = DS_TestObjects.NewOpportunity();
        oppObj.AccountId = accObj.Id;
        oppObj.Type = 'Unhook';
        insert oppObj;
        
        Sales_Discovery__c salesObj = new Sales_Discovery__c();
        salesObj.Opportunity__c = oppObj.Id;
        salesObj.Sites_Involved_With_Request__c = 'Sample';
        salesObj.Number_of_Sites__c = 12;
        insert salesObj;
    }
    
    public static testmethod void test1()
    {
        Sales_Discovery__c salesObjOne = [SELECT Id,Implementation_Director__c from Sales_Discovery__c ][0];
        system.assertEquals(UserInfo.getUserId(), salesObjOne.Implementation_Director__c);
        
        Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
        Sales_Discovery__c salesObj = new Sales_Discovery__c();
        salesObj.Opportunity__c = oppObj.Id;
        salesObj.Sites_Involved_With_Request__c = 'Sample';
        salesObj.Number_of_Sites__c = 12;
        
        try
        {
            insert salesObj;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Sales Discovery already exists with given Opportunity'));
        }
    }
}