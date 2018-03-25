//2016-05-30 - vishal.bandari@cdk.com - created the class - RQ-07013
@IsTest
public class ALL_Event_Test 
{
    @Testsetup
    public static void setupData()
    {
        Account acc = DS_TestObjects.NewAccount_Inserted();
        WebId__c webIdObj = DS_TestObjects.NewWebID();
        webIdObj.account__c = acc.Id;
        insert webIdObj;
        
        All_SharedContactsActivityRelationships__c sharedContactsCustomSetting1 = new All_SharedContactsActivityRelationships__c();
        sharedContactsCustomSetting1.Name = 'a1M';
        sharedContactsCustomSetting1.Object__c = 'WebID__c';
        sharedContactsCustomSetting1.Field__c = 'Account__c';
        insert sharedContactsCustomSetting1;
        
        Opportunity opportunityObj = DS_TestObjects.NewOpportunity();
        opportunityObj.AccountId = acc.Id;
        insert opportunityObj;
        
        Deal_State__c dealstateObj = DS_TestObjects.New_DealState();
        dealstateObj.Opportunity__c = opportunityObj.Id;
        insert dealstateObj;
        
        All_SharedContactsActivityRelationships__c sharedContactsCustomSetting2 = new All_SharedContactsActivityRelationships__c();
        sharedContactsCustomSetting2.Name = 'a3G';
        sharedContactsCustomSetting2.Object__c = 'Deal_State__c';
        sharedContactsCustomSetting2.Field__c = 'Opportunity__c';
        sharedContactsCustomSetting2.Object_L1__c = 'Opportunity';
        sharedContactsCustomSetting2.Field_L1__c = 'AccountId';
        insert sharedContactsCustomSetting2;
        
        CMF_Info__c cmfObj = DS_TestObjects.NewCMFInfo();
        cmfObj.Account__c = acc.Id;
        insert cmfObj;
        
        Laser_Billing_Info__c lbiObj = new Laser_Billing_Info__c();
        lbiObj.Ship_To_CMF_Name__c = cmfObj.Id;
        lbiObj.C__c = '12';
        insert lbiObj;
        
        Laser_Case__c lcObj = new Laser_Case__c();
        lcObj.Case__c = '123';
        lcObj.Laser_Billing_Info__c = lbiObj.Id;
        insert lcObj;
        
        All_SharedContactsActivityRelationships__c sharedContactsCustomSetting3 = new All_SharedContactsActivityRelationships__c();
        sharedContactsCustomSetting3.Name = 'a05';
        sharedContactsCustomSetting3.Object__c = 'Laser_Case__c';
        sharedContactsCustomSetting3.Field__c = 'Laser_Billing_Info__c';
        sharedContactsCustomSetting3.Object_L1__c = 'Laser_Billing_Info__c';
        sharedContactsCustomSetting3.Field_L1__c = 'Ship_To_CMF_Name__c';
        sharedContactsCustomSetting3.Object_L2__c = 'CMF_Info__c';
        sharedContactsCustomSetting3.Field_L2__c = 'Account__c';
        insert sharedContactsCustomSetting3;
    }
    
    public static testmethod void testWebId()
    {
        WebId__c webIdObj = [SELECT Id from WebId__c Limit 1];
        Event eventObj =DS_TestObjects.NewEvent();
        eventObj.WhatId = webIdObj.Id;
        insert eventObj;
        validate(eventObj);
    }
    
    public static testmethod void testDealState()
    {
        Deal_State__c dealstateObj = [SELECT Id from Deal_State__c Limit 1];
        Event eventObj =DS_TestObjects.NewEvent();
        eventObj.WhatId = dealstateObj.Id;
        insert eventObj;
        validate(eventObj);
    }
    
    public static testmethod void testLaserCase()
    {
        Laser_Case__c dealstateObj = [SELECT Id from Laser_Case__c Limit 1];
        Event eventObj =DS_TestObjects.NewEvent();
        eventObj.WhatId = dealstateObj.Id;
        insert eventObj;
        validate(eventObj);
    }
    
    public static testmethod void negitiveTest()
    {
        Account accObj = [SELECT Id from Account Limit 1];
        Event eventObj =DS_TestObjects.NewEvent();
        eventObj.WhatId = accObj.Id;
        insert eventObj;
    }
    
    public static void validate(Event eventObj)
    {
        Account accObj = [SELECT Id from Account Limit 1];
        eventObj = [SELECT Primary_Account__c from Event where Id =: eventObj.Id];
        System.assertEquals(accObj.Id, eventObj.Primary_Account__c, 'Account is not populated');
    }
    
}