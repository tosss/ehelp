/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class to test ALL_UserPermissionSetAndGroup_Handler Class
Created on:    9 June 2015.
Code Coverage: 100%
------------------------------------------------------------
History
10 June 2015    Vishal Bandari      RQ-04257: Added setupTestData Method
10 June 2015    Vishal Bandari      RQ-04257: Changed validateHandler Method
10 June 2015    Vishal Bandari      RQ-04257: Added negitiveTest Method
2016-01-13      matt.keefe@cdk.com  Deprecated Code
------------------------------------------------------------*/
@IsTest
public class ALL_UserPermissionSetAndGroup_Test
{
    /*
    //To setup Test Data
    @TestSetup
    private static void setupTestData()
    {                
        System.runAs (new User(Id = UserInfo.getUserId()))
        {
            //Inserting Sample PermissionSet
            PermissionSet permissionSetObject = new PermissionSet(
                Label = 'TestPermission',
                Name = 'Sample'
            );
            insert permissionSetObject;
            
            //Inserting Sample Group
            Group groupObject = new Group(
                Name = 'testGroup',
                DeveloperName = 'testName'
            );
            insert groupObject;
            
            //Changing EMP_Community_PermissionSet_Id__c CustomSetting PermissionSet_Id__c to newly created PermissionSet
            EMP_Community_PermissionSet_Id__c newPermissionSet = new EMP_Community_PermissionSet_Id__c(
                PermissionSet_Id__c = permissionSetObject.Id,
                Name = 'sample');
            insert newPermissionSet;
            
            //Changing EMP_Community_PublicGroup_Id__c CustomSetting Public_Group_Id__c to newly created Group
            EMP_Community_PublicGroup_Id__c newGroup = new EMP_Community_PublicGroup_Id__c(
                Public_Group_Id__c = groupObject.Id,
                Name = 'sample');
            insert newGroup;
            
            //Inserting Sample Users with different Non_Interactive_User__c, contractor__c, Non_Employee__c values
            List<User> userlist = new List<User>();
            for(integer i=0;i<2;i++)
            {
                User newUser = DS_TestObjects.NewUser();
                newUser.FirstName = 'TestUserPermission'+i;
                if(i==1)
                {
                    newUser.Non_Interactive_User__c = true;
                    newUser.contractor__c = true;
                    newUser.Non_Employee__c = true; 
                }
                userlist.add(newUser);
            }
            
            insert userlist;
            
        }
    } 
    
    public static testmethod void validateHandler()
    {
        
        //Scenario :1 Testing for PermissionSetSaasignment and GroupMember after User Object is Inserted 
        Map<id,User> userMap = new Map<id,User>([
            SELECT id
            FROM User 
            WHERE FirstName 
            LIKE 'TestUserPermission%'
        ]);
        
        PermissionSet permissionSetObject = [
            SELECT ID 
            FROM PermissionSet 
            WHERE Name = 'Sample'
        ];
        
        Group groupObject = [
            SELECT ID 
            FROM Group 
            WHERE Name = 'testGroup'
        ];
        
        List<PermissionSetAssignment> permissionSetAssignmentList = [
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId In: userMap.keySet()
            AND PermissionSetId =: permissionSetObject.Id
        ];
        
        List<GroupMember> groupMemberList = [
            SELECT Id
            FROM GroupMember
            WHERE UserorGroupId In: userMap.keySet()
            AND GroupId =: groupObject.Id
        ];
        
        Integer permissionSetAssignmentCount = permissionSetAssignmentList.size();
        Integer groupMemberCount = groupMemberList.size();
        
        System.assertEquals(true, permissionSetAssignmentCount == 1, 'PermissionSetAssignment not created on insert of User');
        System.assertEquals(true, groupMemberCount==1, 'GroupMember not created on insert of User');
        
        //Scenario :2 Testing for PermissionSetSaasignment and GroupMember for contract or non-employee Users
        User userObject = [
            SELECT id,firstname, contractor__c, Non_Interactive_User__c, Non_Employee__c 
            FROM User 
            WHERE FirstName = 'TestUserPermission0'
        ];
        
        userObject.Non_Interactive_User__c = false;
        userObject.contractor__c = true;
        userObject.Non_Employee__c = true;
        
        update userObject;
        
        permissionSetAssignmentList = [
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId In: userMap.keySet()
            AND PermissionSetId =: permissionSetObject.Id
        ];
        
        groupMemberList = [
            SELECT Id
            FROM GroupMember
            WHERE UserorGroupId In: userMap.keySet()
            AND GroupId =:groupObject.Id
        ];
        
        System.assertEquals(permissionSetAssignmentCount-1, permissionSetAssignmentList.size(), 'PermissionSetAssigment not deleted for contract or non-employee users');
        System.assertEquals(groupMemberCount-1, groupMemberList.size(),'Groupmember not deleted for contract or non-employee users' );
        
        //Scenario :3 Testing for PermissionSetSaasignment and GroupMember for non-interactive Users
        userObject = [
            SELECT id,firstname, contractor__c, Non_Interactive_User__c, Non_Employee__c 
            FROM User 
            WHERE FirstName = 'TestUserPermission1'
        ];
        userObject.Non_Interactive_User__c = true;
        userObject.contractor__c = true;
        userObject.Non_Employee__c = true;
        update userObject;
        
        permissionSetAssignmentList = [
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId In: userMap.keySet()
            AND PermissionSetId =: permissionSetObject.Id
        ];
        
        groupMemberList = [
            SELECT Id
            FROM GroupMember
            WHERE UserorGroupId In: userMap.keySet()
            AND GroupId =:groupObject.Id
        ];
        
        System.assertEquals(permissionSetAssignmentCount-1, permissionSetAssignmentList.size(), 'PermissionSetAssignment not deleted for non-interative users');
        System.assertEquals(groupMemberCount-1, groupMemberList.size(), 'GroupMember not deleted for non-interative users');

    }
    
    public static testmethod void negitiveTest()
    {
        ALL_UserPermissionSetAndGroup_Handler.setPermissionSetAndGroup(null);
    }
    */
}