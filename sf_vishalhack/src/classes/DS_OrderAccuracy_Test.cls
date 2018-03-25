//2015-11-27 - vishal.bandari@cdk.com    RQ-05289:changed UpdateFields method to add contact record type
//2017-01-11 - lalitha.adduru@cdk.com    renamed DS_OrderAccuracyTrigger_Test to DS_OrderAccuracy_Test - RQ-06026
//2017-01-11 - lalitha.adduru@cdk.com    refactored the code to meet coding standards - RQ-06026
//2017-05-17 - lalitha.adduru@cdk.com commented references to DESIGNATED_DSM_NAT_ENT__C as part of RQ-09180

@IsTest
public class DS_OrderAccuracy_Test
{
    @TestSetup
    public static void setupData()
    {
        Launch__c newLaunchNullAccount = DS_TestObjects.NewLaunch();
        newLaunchNullAccount.Account__c = null;
        insert newLaunchNullAccount;
        
        WebId__c NewWebID = DS_TestObjects.NewWebID_Inserted();
        
        contact con = DS_TestObjects.NewContact();
        con.AccountId = NewWebID.Account__c;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        con.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert con;
                   
        // 2016-07-27 matt.keefe@cdk.com - added contact relationship for shared contacts (Case Lookup requires)
        Contact_Relationship__c cr1 = new Contact_Relationship__c(Contact__c = con.Id, Account__c = NewWebID.Account__c);
        cr1.Role__c = 'Accountant';
        insert cr1;
        
        Case newCase = new Case(); 
        newCase.Subject = 'TEST Order Accuracy';
        newCase.AccountId = NewWebID.Account__c;
        newCase.WebID__c = NewWebID.Id;
        newCase.Status = 'Open';
        newCase.Product_Category__c = 'Assets';
        newCase.Priority = 'Standard';
        newCase.Origin = 'Email';
        newCase.Origin_Type__c = 'INB-Customer';
        newCase.Dealer_Group_Contact__c = con.Id;
        newCase.ContactId = con.Id;
        NewCase.Problem_Code__c = 'Background';
        //newCase.Escalation_Reason__c = 'Other Technical Issue';
        insert newCase;
        
        Order_Accuracy__c newOrderAccuracy1 = new Order_Accuracy__c();
        newOrderAccuracy1.MDA_Incorrect_Data__c = true;
        newOrderAccuracy1.MDA_Incorrect_Data_Count__c = 1;
        newOrderAccuracy1.OF_Incorrect_Data__c = true;
        newOrderAccuracy1.OF_Incorrect_Data_Count__c = 1;
        newOrderAccuracy1.Recap_Incorrect_Data__c = true;
        newOrderAccuracy1.Recap_Incorrect_Data_Count__c = 1;
        newOrderAccuracy1.Launch__c = newLaunchNullAccount.Id;
        //newOrderAccuracy1.Case__c = newCase.Id;
        insert newOrderAccuracy1;
        
        User CurrentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        profile p = [Select Id, Name From Profile Limit 1];
        List<User> userList = new List<User>();
        User DSMDOSUser = DS_TestObjects.NewUser(); DSMDOSUser.Title = 'DSM'; 
        userList.add(DSMDOSUser);
        User DSMNatEntUser = DS_TestObjects.NewUser(); DSMNatEntUser.Title = 'DSM'; DSMNatEntUser.ManagerId = DSMDOSUser.Id;
        userList.add(DSMNatEntUser);
        User DSMUser = DS_TestObjects.NewUser(); DSMUser.Title = 'DSM'; DSMUser.ManagerId = DSMDOSUser.Id; 
        userList.add(DSMUser);
        User DSCUser = DS_TestObjects.NewUser(); 
        userList.add(DSCUser);
        User DigitalMarketingStrategist = DS_TestObjects.NewUser();
        userList.add(DigitalMarketingStrategist);
        insert userList;
        
        Launch__c newLaunch = DS_TestObjects.NewLaunch_Inserted();
        newLaunch.Account__r.Designated_DSM__c = DSMUser.Id;
        newLaunch.Account__r.Digital_Sales_Consultant__c = DSCUser.Id;
        //newLaunch.Account__r.Designated_DSM_Nat_Ent__c = DSMNatEntUser.Id;
        newLaunch.Account__r.Digital_Services_CAM__c = DigitalMarketingStrategist.Id;
        update newLaunch.Account__r;
        
        Order_Accuracy__c newOrderAccuracy2 = new Order_Accuracy__c();
        newOrderAccuracy2.MDA_Incorrect_Data__c = true;
        newOrderAccuracy2.MDA_Incorrect_Data_Count__c = 1;
        newOrderAccuracy2.OF_Incorrect_Data__c = true;
        newOrderAccuracy2.OF_Incorrect_Data_Count__c = 1;
        newOrderAccuracy2.Recap_Incorrect_Data__c = true;
        newOrderAccuracy2.Recap_Incorrect_Data_Count__c = 1;
        newOrderAccuracy2.Launch__c = NewLaunch.Id;
        newOrderAccuracy2.Case__c = newCase.Id;
        insert newOrderAccuracy2;
        
        
        // Default Case Team Member
        CaseTeamRole ctr = new CaseTeamRole(Name='TEST Case Team Member', AccessLevel='Edit');
        system.runas(CurrentUser) { insert ctr; }
        
        GlobalSettings__c gs = new GlobalSettings__c();
        gs.DefaultCaseTeamMemberId__c = ctr.Id;
        insert gs;

             
    }
    public static testmethod void UpdateFields()
    {
        List<Order_Accuracy__c> orderAccuracyList = new List<Order_Accuracy__c>();
        orderAccuracyList = [
            SELECT id, Case__c, Launch__c, MDA_Incorrect_Data__c, MDA_Incorrect_Data_Count__c, OF_Incorrect_Data__c, OF_Incorrect_Data_Count__c,
            Recap_Incorrect_Data__c, Recap_Incorrect_Data_Count__c, DSM_Nat_Ent_Email__c, DSM_Nat_Ent_DOS_Email__c 
            FROM Order_Accuracy__c
        ];
        DS_OrderAccuracy_Handler.updateAccuracyEmailFields(orderAccuracyList);
    }
}