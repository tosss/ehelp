@IsTest
public class DS_DealState_Test 
{
    public static testmethod void InsertDealStates()
    {
        Opportunity o = DS_TestObjects.NewOpportunity_Inserted();
        
        Deal_State__c ds1 = new Deal_State__c();
        ds1.Quantity_of_Sites__c = 2;
        ds1.Opportunity__c = o.Id;
        try { insert ds1; } catch(Exception e) { system.debug(e); }
        
        Deal_State__c ds2 = new Deal_State__c();
        ds2.Quantity_of_Sites__c = 2;
        ds2.Opportunity__c = o.Id;
        try { insert ds2; } catch(Exception e) { system.debug(e); } // exception expected
    }
    
    public static testmethod void InsertDealStateSecured()
    {
        Opportunity o = DS_TestObjects.NewOpportunity_Inserted();
        
        Deal_State__c ds1 = new Deal_State__c();
        ds1.Quantity_of_Sites__c = 2;
        ds1.Opportunity__c = o.Id;
        try { insert ds1; } catch(Exception e) { system.debug(e); }
        
        // insert a Deal State Secured
        Deal_State_Secured__c dss1 = new Deal_State_Secured__c();
        dss1.Deal_State__c = ds1.Id;
        try { insert dss1; } catch(Exception e) { system.debug(e); }
        
        // insert a second Deal State Secured - should cause an error
        Deal_State_Secured__c dss2 = new Deal_State_Secured__c();
        dss2.Deal_State__c = ds1.Id;
        try { insert dss2; } catch(Exception e) { system.debug(e); }
    }
    
    public static testmethod void UpdateOpportunityDealStateID()
    {
        Opportunity o = DS_TestObjects.NewOpportunity_Inserted();
        
        Deal_State__c ds1 = new Deal_State__c();
        ds1.Quantity_of_Sites__c = 2;
        ds1.Opportunity__c = o.Id;
        try { insert ds1; } catch(Exception e) { system.debug(e); }
        
        DS_DealState_Handler.UpdateOpportunityDealStateID(new list<Deal_State__c>{ds1});
    }
    
    public static testmethod void DealStateEmailUpdateTest()
    {
        User u = DS_TestObjects.NewAdminUser_Inserted();
        Account acc = DS_TestObjects.NewAccount();
        acc.Technology_Solutions_Manager__c = u.Id;
        insert acc;        
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.AccountId = acc.Id;
        opp.ADP_Opportunity_Owner__c = u.Id;
        Insert opp;
        
        Deal_State__c ds = new Deal_State__c();
        ds.Opportunity__c = opp.Id;
        Insert ds;
        
        user user2 = DS_TestObjects.NewSecondUser_Inserted();
        
        opp.ADP_Opportunity_Owner__c = user2.Id;
        update opp;
        
        acc.Key_DOS__c = user2.Id;
        Update acc;
    }
    
    public static testmethod void UpdateDealStateStatus()
    {
        Account accObj = DS_TestObjects.NewAccount_Inserted();
        
        Opportunity oppObj = new Opportunity(
            Account = accObj,
            Name = 'TestOpportunity',
            ADP_Opportunity_Owner__c=  Userinfo.getUserId(),
            CloseDate = Date.today(),
            StageName = 'Open',
            Type = 'Add-on'
        );
        
        insert oppObj;
        
        Deal_State__c dsObj = new Deal_State__C();
        dsObj.Opportunity__c = oppObj.Id;
        insert dsObj;
        
        oppObj.StageName = 'Inactive/Cancelled';
        update oppObj;
        
        dsObj = [
            SELECT Deal_Status__c 
            FROM Deal_State__c 
            WHERE ID = :dsObj.Id
        ];
        
        System.assertEquals('Cancelled',dsObj.Deal_Status__c );
        
        DS_DealState_Handler.UpdateDealState(null);
    }
}