//2015-11-27 : vishal.bandari@cdk.com    RQ-05289:changed UpdateFields method to add contact record type
@IsTest
public class DS_OrderAccuracyTrigger_Test
{
    public static testmethod void UpdateFields()
    {
        Launch__c NewLaunchNullAccount = DS_TestObjects.NewLaunch();
        NewLaunchNullAccount.Account__c = null;
        insert NewLaunchNullAccount;
        
        Order_Accuracy__c NewOrderAccuracy1 = new Order_Accuracy__c();
        NewOrderAccuracy1.MDA_Incorrect_Data__c = true;
        NewOrderAccuracy1.MDA_Incorrect_Data_Count__c = 1;
        NewOrderAccuracy1.OF_Incorrect_Data__c = true;
        NewOrderAccuracy1.OF_Incorrect_Data_Count__c = 1;
        NewOrderAccuracy1.Recap_Incorrect_Data__c = true;
        NewOrderAccuracy1.Recap_Incorrect_Data_Count__c = 1;
        NewOrderAccuracy1.Launch__c = NewLaunchNullAccount.Id;
        insert NewOrderAccuracy1;
        
        User CurrentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        profile p = [Select Id, Name From Profile Limit 1];
        User DSMDOSUser = DS_TestObjects.NewUser(); DSMDOSUser.Title = 'DSM'; insert DSMDOSUser;
        User DSMNatEntUser = DS_TestObjects.NewUser(); DSMNatEntUser.Title = 'DSM'; DSMNatEntUser.ManagerId = DSMDOSUser.Id; insert DSMNatEntUser;
        User DSMUser = DS_TestObjects.NewUser(); DSMUser.Title = 'DSM'; DSMUser.ManagerId = DSMDOSUser.Id; insert DSMUser;
        User DSCUser = DS_TestObjects.NewUser(); insert DSCUser;
        User DigitalMarketingStrategist = DS_TestObjects.NewUser(); insert DigitalMarketingStrategist;
        
        Launch__c NewLaunch = DS_TestObjects.NewLaunch_Inserted();
        NewLaunch.Account__r.Designated_DSM__c = DSMUser.Id;
        NewLaunch.Account__r.Digital_Sales_Consultant__c = DSCUser.Id;
        NewLaunch.Account__r.Designated_DSM_Nat_Ent__c = DSMNatEntUser.Id;
        NewLaunch.Account__r.Digital_Services_CAM__c = DigitalMarketingStrategist.Id;
        update NewLaunch.Account__r;
        
        Order_Accuracy__c NewOrderAccuracy2 = new Order_Accuracy__c();
        NewOrderAccuracy2.MDA_Incorrect_Data__c = true;
        NewOrderAccuracy2.MDA_Incorrect_Data_Count__c = 1;
        NewOrderAccuracy2.OF_Incorrect_Data__c = true;
        NewOrderAccuracy2.OF_Incorrect_Data_Count__c = 1;
        NewOrderAccuracy2.Recap_Incorrect_Data__c = true;
        NewOrderAccuracy2.Recap_Incorrect_Data_Count__c = 1;
        NewOrderAccuracy2.Launch__c = NewLaunch.Id;
        insert NewOrderAccuracy2;
        
        WebId__c NewWebID = DS_TestObjects.NewWebID_Inserted();
        
        // Default Case Team Member
        CaseTeamRole ctr = new CaseTeamRole(Name='TEST Case Team Member', AccessLevel='Edit');
        system.runas(CurrentUser) { insert ctr; }
        
        GlobalSettings__c gs = new GlobalSettings__c();
        gs.DefaultCaseTeamMemberId__c = ctr.Id;
        insert gs;
        
        contact con = DS_TestObjects.NewContact();
        con.AccountId = NewWebID.Account__c;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        con.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert con;
        
        Case NewCase = new Case(); 
        NewCase.Subject = 'TEST Order Accuracy';
        NewCase.AccountId = NewWebID.Account__c;
        NewCase.WebID__c = NewWebID.Id;
        NewCase.Status = 'Open';
        NewCase.Product_Category__c = 'Email';
        NewCase.Priority = 'Standard';
        NewCase.Origin = 'Email';
        NewCase.Origin_Type__c = 'INB-Customer';
        NewCase.Dealer_Group_Contact__c = con.Id;
        NewCase.ContactId = con.Id;
        //NewCase.Escalation_Reason__c = 'Other Technical Issue';
        insert NewCase;
        
        NewOrderAccuracy1.Launch__c = null;
        NewOrderAccuracy1.Case__c = NewCase.Id;
        update NewOrderAccuracy1;
    }
}