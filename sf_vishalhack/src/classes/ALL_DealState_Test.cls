//2017-03-13 - ragashalini.koka@cdk.com - commented the Technology_Solutions_Manager references for RQ-08732
@isTest
public class ALL_DealState_Test 
{ 
    public static testMethod CustomSettings__c getCustomSettings()
    {
        CustomSettings__c cs = new CustomSettings__c();
        cs.DS_SalesTeamTrigger_On__c = true;
        insert cs;
        return cs;
    }
    public static testmethod void DealStateEmailUpdateTest()
    {
        ALL_DealState_Test.getCustomSettings();
        User u = DS_TestObjects.NewAdminUser_Inserted();
        
        Account acc = DS_TestObjects.NewAccount();
       // acc.Technology_Solutions_Manager__c = u.Id;
        insert acc; 
        
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.AccountId = acc.Id;
        opp.ADP_Opportunity_Owner__c = u.Id;
        Insert opp;
        
        Deal_State__c ds = new Deal_State__c();
        ds.Opportunity__c = opp.Id;
        Insert ds;
        
        SQT_NSA__c sa = new SQT_NSA__c();
        sa.Deal_State__c = ds.ID;
        insert sa;       
        
        user user2 = DS_TestObjects.NewSecondUser_Inserted();
        
        opp.ADP_Opportunity_Owner__c = user2.Id;
        update opp;
        
        acc.Key_DOS__c = user2.Id;
        Update acc;
    }    
    public static testmethod void validateHandler()
    {
        ALL_DealState_Test.getCustomSettings();
        AVP_RGM_Link__C avpObj = new AVP_RGM_Link__C();
        avpObj.Controller__c = '00540000001puXj';
        avpObj.Region__c = 'Division';
        insert avpObj;
        
        Account acc = DS_TestObjects.NewAccount();
        acc.Region__c = 'Division';
        insert acc; 
        
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.AccountId = acc.Id;
        Insert opp;
        
        Deal_State__c ds = new Deal_State__c();
        ds.Opportunity__c = opp.Id;
        Insert ds;
        
        
        User u = DS_TestObjects.NewUser();
        u.Region__c = 'Divison';
        insert u;
        
        ds = [
            select id, account_region__c, Client_1_Sign_In_Person__c, Dash_Only__c 
            from deal_state__c 
            where id =: ds.id
        ];
        
        
        SQT_NSA__c sqtNsaObj = new SQT_NSA__c(Deal_State__c = ds.Id);
        insert sqtNsaObj;
        
        sqtNsaObj = new SQT_NSA__c(Deal_State__c = ds.Id);
        insert sqtNsaObj; 
        
        DS_DealStateUpdateController_Handler.dealStateList = new List<Deal_State__c>();
        DS_DealStateUpdateController_Handler.dealStateList.add(ds);
        DS_DealStateUpdateController_Handler.userMap = new Map<id,User>();
        DS_DealStateUpdateController_Handler.userMap.put(u.id,u);
        
        avpObj.Controller__c = u.id;
        update avpObj;
        
        ds.Dash_Only__c = true;
        update ds;
        
        DS_DealStateUpdateController_Handler.updateControllerEmail(null,null);        
        DS_DealState_Handler.updateSQTNSA(null,null);
        
    }    
}