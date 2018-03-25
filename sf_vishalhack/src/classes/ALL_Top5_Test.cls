//2016-12-27 - ragashalini.koka@cdk.com - RQ-08369 - Created this class
//2017-03-27 - ragashalini.koka@cdk.com - RQ-08784 - Added Account Team for Account
@isTest
public class ALL_Top5_Test {
    
    @testSetup
    static void setupData() {
        
        Account acc = DS_TestObjects.NewAccount_Inserted();
        
        User usr1 = DS_TestObjects.NewUser();
        usr1.FirstName = 'Owner Mgr First';
        insert usr1;
        User usr2 = DS_TestObjects.NewUser();
        usr2.FirstName = 'Owner First';
        usr2.ManagerId = usr1.Id;
        insert usr2;
         
        List<Top_5__c> top5List = new List<Top_5__c>();
        Top_5__c top5Rec1 = new Top_5__c();
        top5Rec1.OwnerId = usr2.Id;
        top5Rec1.Account__c = acc.Id;
        top5Rec1.Status__c = 'Black';
        top5Rec1.Comments__c = 'Test Comments';
        top5Rec1.Status_Change_Reason__c = 'Test Status Change Reason';
        top5List.add(top5Rec1);
        
        Top_5__c top5Rec2 = new Top_5__c();
        top5Rec2.Account__c = acc.Id;
        top5Rec2.Comments__c = 'Sample Comment';
        top5Rec2.CDK_Executive_Owner__c = 'Brian MacDonald – President & CEO';
        top5Rec2.DOS_Confirmed__c = true;
        top5Rec2.Main_Competitor__c = 'Sample Competitor';
        top5Rec2.RGM_Confirmed__c = true;
        top5Rec2.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Top_5__c', 'To Grow');
        top5Rec2.Status__c = 'Green';
        top5List.add(top5Rec2);
        
        insert top5List;
       
        
        Top_5s_Audit__c top5AuditObj = [
            SELECT Id,Comments_Current__c,CDK_Executive_Owner_Current__c,DOS_Confirmed_Current__c,
            Main_Competitor_Current__c,RGM_Confirmed_Current__c,Record_Type_Name_Current__c,Status_Current__c,Action__c,Top_5s_Lookup__r.RecordType.Name
            FROM Top_5s_Audit__c 
            WHERE Top_5s_Lookup__c =: top5Rec2.Id
        ];
        System.assert(top5AuditObj.Comments_Current__c == top5Rec2.Comments__c);
        System.assert(top5AuditObj.CDK_Executive_Owner_Current__c == top5Rec2.CDK_Executive_Owner__c);
        System.assert(top5AuditObj.DOS_Confirmed_Current__c == top5Rec2.DOS_Confirmed__c);
        System.assert(top5AuditObj.Main_Competitor_Current__c == top5Rec2.Main_Competitor__c);
        System.assert(top5AuditObj.RGM_Confirmed_Current__c == top5Rec2.RGM_Confirmed__c);
        System.assert(top5AuditObj.Record_Type_Name_Current__c == top5AuditObj.Top_5s_Lookup__r.RecordType.Name);
        System.assert(top5AuditObj.Status_Current__c == top5Rec2.Status__c);
        System.assert(top5AuditObj.Action__c == 'I');
    }
    
    static testmethod void validateOwnerFields()
    {
        Test.startTest();
        Top_5__c top5Rec = [SELECT Id, OwnerId, Owner_Manager__c, Owner_Manager_Mgr__c FROM Top_5__c LIMIT 1];
        User usr = [SELECT Id, ManagerId, Manager.ManagerId FROM User WHERE Id = : top5Rec.OwnerId];
        System.assertEquals(usr.ManagerId, top5Rec.Owner_Manager__c, 'Incorrect data in Owner Manager Top 5 Record');
        System.assertEquals(usr.Manager.ManagerId, top5Rec.Owner_Manager_Mgr__c, 'Incorrect data in Owner Manager Mgr Top 5 Record');
        Test.stopTest();
    }
    
    static testmethod void actionOnApproval() 
    {
        List<Top_5__c> top5RecordsList = [SELECT Id FROM Top_5__c WHERE Status__c='Black'];
        if(top5RecordsList.size() > 0) {
            List<ProcessInstance> processInstanceList = [SELECT Id,Status FROM ProcessInstance WHERE TargetObjectId = :top5RecordsList[0].Id];
            if(processInstanceList.size() > 0) {
                List<ProcessInstanceWorkitem> workItemList = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstanceId = :processInstanceList[0].Id];
                if(workItemList.size() > 0) {
                    Approval.ProcessWorkitemRequest request= new Approval.ProcessWorkitemRequest();
                    request.setWorkitemId(workItemList[0].Id);
                    request.setAction('Reject');
                    Approval.process(request);
                    processInstanceList = [SELECT Id,Status FROM ProcessInstance WHERE TargetObjectId = :top5RecordsList[0].Id];
                }
            }
        }
    }
    
    static testmethod void testUpdate()
    {
        Top_5__c top5BeforeUpdateObj = [
            SELECT Id,Comments__c,CDK_Executive_Owner__c,
            DOS_Confirmed__c,Main_Competitor__c,RGM_Confirmed__c,RecordType.Name,Status__c 
            FROM Top_5__c 
            WHERE RGM_Confirmed__c = true
            LIMIT 1
        ];
        top5BeforeUpdateObj.Status__c = 'Yellow';
        update top5BeforeUpdateObj;
        
        top5BeforeUpdateObj.Status__c = 'Green';
        Top_5__c top5AfterUpdateObj = [
            SELECT Id,Comments__c,CDK_Executive_Owner__c,
            DOS_Confirmed__c,Main_Competitor__c,RGM_Confirmed__c,RecordType.Name,Status__c 
            FROM Top_5__c 
            WHERE Id =: top5BeforeUpdateObj.Id 
        ];
        
        Top_5s_Audit__c top5AuditObj = [
            SELECT Id,Comments_Current__c,CDK_Executive_Owner_Current__c,DOS_Confirmed_Current__c,
            Main_Competitor_Current__c,RGM_Confirmed_Current__c,Record_Type_Name_Current__c,Status_Current__c,
            Comments_Previous__c,CDK_Executive_Owner_Previous__c,DOS_Confirmed_Previous__c,
            Main_Competitor_Previous__c,RGM_Confirmed_Previous__c,Record_Type_Name_Previous__c,Status_Previous__c,Action__c
            FROM Top_5s_Audit__c 
            WHERE Top_5s_Lookup__c = : top5BeforeUpdateObj.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        System.assert(top5AuditObj.Comments_Current__c == top5AfterUpdateObj.Comments__c);
        System.assert(top5AuditObj.CDK_Executive_Owner_Current__c == top5AfterUpdateObj.CDK_Executive_Owner__c);
        System.assert(top5AuditObj.DOS_Confirmed_Current__c == top5AfterUpdateObj.DOS_Confirmed__c);
        System.assert(top5AuditObj.Main_Competitor_Current__c == top5AfterUpdateObj.Main_Competitor__c);
        System.assert(top5AuditObj.RGM_Confirmed_Current__c == top5AfterUpdateObj.RGM_Confirmed__c);
        System.assert(top5AuditObj.Record_Type_Name_Current__c == top5AfterUpdateObj.RecordType.Name);
        System.assert(top5AuditObj.Status_Current__c == top5AfterUpdateObj.Status__c);
        System.assert(top5AuditObj.Comments_Previous__c == top5BeforeUpdateObj.Comments__c);
        System.assert(top5AuditObj.CDK_Executive_Owner_Previous__c == top5BeforeUpdateObj.CDK_Executive_Owner__c);
        System.assert(top5AuditObj.DOS_Confirmed_Previous__c == top5BeforeUpdateObj.DOS_Confirmed__c);
        System.assert(top5AuditObj.Main_Competitor_Previous__c == top5BeforeUpdateObj.Main_Competitor__c);
        System.assert(top5AuditObj.RGM_Confirmed_Previous__c == top5BeforeUpdateObj.RGM_Confirmed__c);
        System.assert(top5AuditObj.Record_Type_Name_Previous__c == top5BeforeUpdateObj.RecordType.Name);
        System.assert(top5AuditObj.Status_Previous__c == top5BeforeUpdateObj.Status__c);
        System.assert(top5AuditObj.Action__c == 'U');
    }
    
    static testmethod void testDelete()
    {
        Top_5__c top5Obj = [SELECT Id,Comments__c,CDK_Executive_Owner__c,DOS_Confirmed__c,Main_Competitor__c,RGM_Confirmed__c,RecordType.Name,Status__c FROM Top_5__c LIMIt 1];
        delete top5Obj;
        
        Top_5s_Audit__c top5AuditObj = [
            SELECT Id,Comments_Previous__c,CDK_Executive_Owner_Previous__c,DOS_Confirmed_Previous__c,
            Main_Competitor_Previous__c,RGM_Confirmed_Previous__c,Record_Type_Name_Previous__c,Status_Previous__c,Action__c
            FROM Top_5s_Audit__c 
            WHERE Top_5s_Lookup__c = NULL 
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        System.assert(top5AuditObj.Comments_Previous__c == top5Obj.Comments__c);
        System.assert(top5AuditObj.CDK_Executive_Owner_Previous__c == top5Obj.CDK_Executive_Owner__c);
        System.assert(top5AuditObj.DOS_Confirmed_Previous__c == top5Obj.DOS_Confirmed__c);
        System.assert(top5AuditObj.Main_Competitor_Previous__c == top5Obj.Main_Competitor__c);
        System.assert(top5AuditObj.RGM_Confirmed_Previous__c == top5Obj.RGM_Confirmed__c);
        System.assert(top5AuditObj.Record_Type_Name_Previous__c == top5Obj.RecordType.Name);
        System.assert(top5AuditObj.Status_Previous__c == top5Obj.Status__c);
        System.assert(top5AuditObj.Action__c == 'D');
    }
    
    static testmethod void validateTop5Share() 
    {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<User> usrList = [SELECT Id FROM User ORDER BY Createddate desc LIMIT 2];
        List<Account_Team__c> accTeamList = new List<Account_Team__c>();
        Account_Team__c accTeam1 = new Account_Team__c();
        accTeam1.Account__c = acc.Id;
        accTeam1.Team_Member__c = usrList[0].Id;
        accTeam1.Team_Role__c = 'Forecasting - Baseline Rep';
        accTeamList.add(accTeam1);
        Account_Team__c accTeam2 = new Account_Team__c();
        accTeam2.Account__c = acc.Id;
        accTeam2.Team_Member__c = usrList[1].Id;
        accTeam2.Team_Role__c = 'Forecasting - Baseline Rep';
        accTeamList.add(accTeam2);
        insert accTeamList;
        
        Top_5__c top5Rec = new Top_5__c();
        top5Rec.Account__c = acc.Id;
        top5Rec.Status__c = 'Green';
        top5Rec.RecordTypeId =  ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Top_5__c', 'Digital Opportunity');
        top5Rec.Comments__c = 'Test Comments';
        insert top5Rec;
        
        List<Top_5__Share> top5ShareList = [SELECT Id FROM Top_5__Share WHERE ParentId = :top5Rec.Id AND UserOrGroupId = :accTeam1.Team_Member__c];
        System.assert(top5ShareList.size() > 0);
       
        delete accTeam1;
        
        top5ShareList = [SELECT Id FROM Top_5__Share WHERE ParentId = :top5Rec.Id AND UserOrGroupId = :accTeam1.Team_Member__c];
        System.assert(top5ShareList.size() == 0);    
        Test.stopTest();
        
    }

}