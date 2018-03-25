/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class to test UserPermissionSetAndGroup_Handler Class
Test Class:    ALL_UserPermissionSetAndGroup_Test
Created on:    2 February 2015.
Code Coverage: 100%
------------------------------------------------------------
History
10 June 2015    Vishal Bandari      RQ-04257: Changed setPermissionSetAndGroup Method
2015-01-13      matt.keefe@cdk.com  Deprecated Code
------------------------------------------------------------*/
public class ALL_UserPermissionSetAndGroup_Handler
{ 
    /*
    public static void setPermissionSetAndGroup(Map<Id, User> newUserMap)
    {
        try 
        {
            if(newUserMap.size()>0)
            {
                //Holds the PermissionSetAssignment and GroupMember Objects to be added.
                List<sobject> addPermissionSetAndGroupList = new List<sobject>();
                
                //Holds the Users List for which PermissionSetAssignment and GroupMember is to be removed.
                List<Id> usersListToRemove = new List<Id>();
                
                //Fetching Required PermissionSet Id from EMP_Community_PermissionSet_Id__c custom setting.
                Id permissionSetId = EMP_Community_PermissionSet_Id__c.getOrgDefaults().PermissionSet_Id__c;
                
                //Exisiting PermissionSetAssignment List of required Users                
                List<PermissionSetAssignment> PermissionSetAssignmentList = [
                    SELECT AssigneeId, PermissionSetId                    
                    FROM PermissionSetAssignment 
                    WHERE AssigneeId IN :newUserMap.keySet() 
                    AND PermissionSetId = :permissionSetId
                ]; 
                
                //Set of user Ids whose PermissionSetAssignment already exists
                Set<ID> AlreadyAssignedUserIDSet = new Set<ID>();
                
                if(PermissionSetAssignmentList != null && !PermissionSetAssignmentList.isEmpty())
                {
                    for(PermissionSetAssignment permisssionSetAssignmentObject: PermissionSetAssignmentList)
                    {
                        AlreadyAssignedUserIDSet.add(permisssionSetAssignmentObject.AssigneeId);
                    }
                }
                
                //Fetching Required Group Id from EMP_Community_PublicGroup_Id__c custom setting
                Id groupId = EMP_Community_PublicGroup_Id__c.getOrgDefaults().Public_Group_Id__c;
                
                //Existing GroupMembers of Group
                List<GroupMember> GroupMembersList = new List<GroupMember>([
                    SELECT UserOrGroupId 
                    FROM GroupMember 
                    WHERE GroupId = :groupId
                ]);
                
                //Existing User Ids who are member of Required Group
                Set<ID> GroupMemberIDsSet = new Set<ID>();
                
                if(GroupMembersList != null && !GroupMembersList.isEmpty())
                {
                    for(GroupMember gropuMemberObject: GroupMembersList)
                    {
                        GroupMemberIDsSet.add(gropuMemberObject.UserOrGroupId);
                    }
                }
                
                //Adding and Deleting PermissionSetAssignments and GroupMembers
                if(permissionSetId != null && groupId != null)
                {
                    for(User newUser: newUserMap.values())
                    {
                        //Adding PermissionSetAssignments and GroupMembers if not exists for Users who are not Non-interactive, contract, non-employee
                        if(!(newUser.Non_Interactive_User__c || newUser.Contractor__c || newUser.Non_Employee__c))
                        {
                            if(AlreadyAssignedUserIDSet != null && !AlreadyAssignedUserIDSet.contains(newUser.Id))
                            {
                                PermissionSetAssignment permissionSetAssignmentObject = new PermissionSetAssignment(
                                    PermissionSetId = permissionSetId,
                                    AssigneeId = newUser.Id
                                );
                                addPermissionSetAndGroupList.add(permissionSetAssignmentObject);
                            }
                            
                            if(GroupMemberIDsSet != null && !GroupMemberIDsSet.contains(newUser.Id))
                            {
                                GroupMember groupMemberObject = new GroupMember();
                                groupMemberObject.GroupId = groupId;
                                groupMemberObject.UserOrGroupId = newUser.id;
                                addPermissionSetAndGroupList.add(groupMemberObject);
                            }
                        }
                        
                        //Adding Users Ids who are Non-interactive into Removal List
                        else if(newUser.Non_Interactive_User__c)
                        {
                            usersListToRemove.add(newUser.Id);
                        }
                        
                        //Adding Users Ids who are not Non-interactive, but contractor or non-employee into Removal List
                        else if(newUser.Contractor__c || newUser.Non_Employee__c)
                        {
                            usersListToRemove.add(newUser.Id);
                        }
                    }
                    
                    //Removing PermissionSetAssignments and GroupMembers
                    if(usersListToRemove.size()>0)
                    {
                        List<sobject> removePermissionSetAndGroupList = new List<sobject>();
                        
                        //Fetching PermissionSetAssigment of Users for removal
                        List<sobject> removePermissionSetList =  [
                            SELECT id, PermissionSetId, AssigneeId
                            FROM PermissionSetAssignment
                            WHERE AssigneeId In: usersListToRemove 
                            AND PermissionSetId =: permissionSetId
                        ];
                        removePermissionSetAndGroupList.addAll(removePermissionSetList);
                        
                        //Fetching GroupMember of Users for removal
                        List<sobject> removeGroupList = [
                            SELECT id, GroupId, UserOrGroupId 
                            FROM GroupMember 
                            WHERE UserOrGroupId In: usersListToRemove
                            AND GroupId =: groupId
                        ];
                        removePermissionSetAndGroupList.addAll(removeGroupList);
                        
                        //Removing PermissionSetAssignments and GroupMembers
                        if(removePermissionSetAndGroupList.size()>0)
                        {
                            delete removePermissionSetAndGroupList; 
                        }
                    } 
                    
                    //Adding PermissionSetAssignments and GroupMembers
                    if(addPermissionSetAndGroupList.size()>0)
                    {
                        insert addPermissionSetAndGroupList;
                    }
                } 
            }
        }
        catch(Exception e)
        {
            System.debug('Exception: '+e.getMessage()+' At '+e.getLineNumber());
        }
    }
    */
}