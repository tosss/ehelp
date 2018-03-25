/*
        Name           : CB_AccountPlanTrigger_Test
        Programmer     : Siva Pragada
        Date           : 21st December 2013, Again changes made on 10/23/2014 and 3/20/2015
        Description    : Test Class of AccountPlanTrigger
*/
//2015-11-27              vishal.bandari@cdk.com    RQ-05289:changed unitTest method to add contact record type
@isTest
public class CB_AccountPlanTrigger_Test {
    static testMethod void unitTest() {
         
        User u = DS_TestObjects.NewUser();
        u.isActive = true;
        insert u;
        User u2 = DS_TestObjects.NewSecondUser_Inserted();
        u2.IsActive = true;
        update u2;
        
        Account acc = new account();
        acc.name ='Test Account';
        insert acc;
        
        list<Account_Team__c> AtmList = new list<Account_Team__c>();
        Account_Team__c atm1 = new Account_Team__c();
        atm1.Account__c = acc.Id;
        atm1.Team_Member__c = u.Id;
        atm1.Team_Role__c = 'Email Marketing Specialist';
        AtmList.add(atm1);
        
        Account_Team__c atm2 = new Account_Team__c();
        atm2.Account__c = acc.Id;
        atm2.Team_Member__c = u2.Id;
        atm2.Team_Role__c = 'Social Media Specialist';
        AtmList.add(atm2);
        
        insert AtmList;
        
        Contact con = new Contact();
        con.accountid = acc.id;
        con.FirstName = 'Test Contact';
        con.LastName = 'Test LastCont';
        con.Role__c = 'Test Role'; // 9/29
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        con.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        Insert con;
        
        list<WebId__c> WebIdList = new list<WebId__c>();
        
        WebID__c wc = new WebID__c();
        wc.account__C = acc.id;
        wc.Status__c = 'Active';
        WebIdList.add(wc);
        
        insert WebIdList;
        
        Account_Plan_Fields__c AccountPlanFieldsCustomSetting = new Account_Plan_Fields__c();
        AccountPlanFieldsCustomSetting.Name = 'DA_Help_List_Description__c';
        insert AccountPlanFieldsCustomSetting;      
        
        ID AAAccountPlanId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'AA Account Plan');
        ID DAAAccountPlanId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'DAA Account Plan');
        
        Account_Plan__c accPlanObj  = new Account_Plan__c ();
        accPlanObj.RecordTypeId = AAAccountPlanId;
        accPlanObj.Account__c = acc.id;
        accPlanObj.WebID__c = wc.id;        
        accPlanObj.DA_Help_List_Description__c = 'Test DA Description';                                              
        insert accPlanObj;      
                
        Account_Plan__c accPlanObj1  = new Account_Plan__c ();
        accPlanObj1.RecordTypeId = DAAAccountPlanId;
        accPlanObj1.Account__c = acc.id;
        accPlanObj1.WebID__c = wc.id;       
        accPlanObj1.DA_Help_List_Description__c = 'Test DA Description';       
        accPlanObj1.DA_Echelon_Spend_Level__c = 'Cool';
        insert accPlanObj1 ; 
        
        CB_AccountPlanTriggerHandler.hasAlreadyRanBeforeUpdate = False;        
        accPlanObj.DA_Help_List_Description__c = 'Test DA Description New';        
        update accPlanObj;
        
        accPlanObj1.DA_Echelon_Spend_Level__c = null;
        Update accPlanObj1;
        
        accPlanObj1.Account_Status__c = 'Inactive';
        Update accPlanObj1;
        
        Delete accPlanObj1;
    }
    
    static testMethod void unitTest2()
    {
        User u = DS_TestObjects.NewUser();
        u.isActive = true;
        insert u;
        User u2 = DS_TestObjects.NewSecondUser_Inserted();
        u2.IsActive = true;
        update u2;
        
        Account acc = new account();
        acc.name ='Test Account';
        insert acc;
        
        list<Account_Team__c> AtmList = new list<Account_Team__c>();
        Account_Team__c atm1 = new Account_Team__c();
        atm1.Account__c = acc.Id;
        atm1.Team_Member__c = u.Id;
        atm1.Team_Role__c = 'Email Marketing Specialist';
        AtmList.add(atm1);
        
        Account_Team__c atm2 = new Account_Team__c();
        atm2.Account__c = acc.Id;
        atm2.Team_Member__c = u2.Id;
        atm2.Team_Role__c = 'Social Media Specialist';
        AtmList.add(atm2);
        
        insert AtmList;
        
        list<WebId__c> WebIdList = new list<WebId__c>();
        WebId__c OnstationWebId = new WebId__c();
        OnstationWebId.Account__c = acc.Id;
        OnstationWebId.Name = 'onstation';
        OnstationWebId.OwnerMktg_Specialist_lookup__c = u.Id;
        OnstationWebId.Status__c = 'Active';
        WebIdList.add(OnstationWebId);
        
        WebId__c SocialWebId = new WebId__c();
        SocialWebId.Account__c = acc.Id;
        SocialWebId.Name = 'social';
        SocialWebId.Social_Media_Specialist__c = u2.Id;
        SocialWebId.Status__c = 'Active';
        WebIdList.add(SocialWebId);       
        
        WebID__c wc = new WebID__c();
        wc.account__C = acc.id;
        wc.Status__c = 'Active';
        WebIdList.add(wc);
        
        insert WebIdList;
        
        Account_Plan__c accPlanObj  = new Account_Plan__c ();        
        accPlanObj.Account__c = acc.id;
        accPlanObj.WebID__c = wc.id;        
        accPlanObj.DA_Help_List_Description__c = 'Tes t DA Description';                                              
        insert accPlanObj; 
    }
    
}