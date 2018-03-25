public class UserPermissionSetAndGroupTrigger_Handler
{ 
    public static void setPermissionSetAndGroup(Map<Id, User> newUserMap)
    {
        try
        {
            if(newUserMap.size()>0)
            {
                List<sobject> addPermissionSetAndGroupList = new List<sobject>();
                
                List<Id> usersList = new List<Id>();
                
                Id permissionSetId = EMP_Community_PermissionSet_Id__c.getOrgDefaults().PermissionSet_Id__c;
                                
                List<PermissionSetAssignment> PermissionSetAssignmentList = [
                    SELECT AssigneeId, PermissionSetId                    
                    FROM PermissionSetAssignment 
                    Where AssigneeId IN :newUserMap.keySet() AND PermissionSetId = :permissionSetId
                ]; 
                
                Set<ID> AlreadyAssignedUserIDSet = new Set<ID>();
                
                if(AlreadyAssignedUserIDSet != null && !AlreadyAssignedUserIDSet.isEmpty())
                {
                    for(PermissionSetAssignment psa: PermissionSetAssignmentList)
                    {
                        AlreadyAssignedUserIDSet.add(psa.AssigneeId);
                    }
                }
               
                
                Id groupId = EMP_Community_PublicGroup_Id__c.getOrgDefaults().Public_Group_Id__c;
                
                List<GroupMember> GroupMembers = new List<GroupMember>([Select UserOrGroupId From GroupMember Where GroupId = :groupId]);
                Set<ID> GroupMemberIDsSet = new Set<ID>();
                
                if(GroupMembers != null && !GroupMembers.isEmpty())
                {
                    for(GroupMember gm: GroupMembers)
                    {
                        GroupMemberIDsSet.add(gm.UserOrGroupId);
                    }
                }
                
                if(permissionSetId != null && groupId != null)
                {
                    for(User newUser: newUserMap.values())
                    {
                        if(!(newUser.Non_Interactive_User__c || newUser.Contractor__c || newUser.Non_Employee__c))
                        {
                            if(AlreadyAssignedUserIDSet != null && !AlreadyAssignedUserIDSet.contains(newUser.Id))
                            {
                                PermissionSetAssignment psa = new PermissionSetAssignment(
                                    PermissionSetId = permissionSetId,
                                    AssigneeId = newUser.Id
                                );
                                addPermissionSetAndGroupList.add(psa);
                            }
                            
                            if(GroupMemberIDsSet != null && !GroupMemberIDsSet.contains(newUser.Id))
                            {
                                GroupMember gm = new GroupMember();
                                gm.GroupId = groupId;
                                gm.UserOrGroupId = newUser.id;
                                addPermissionSetAndGroupList.add(gm);
                            }
                        }
                        else if(newUser.Non_Interactive_User__c)
                        {
                            usersList.add(newUser.Id);
                        }
                        else if(newUser.Contractor__c || newUser.Non_Employee__c)
                        {
                            usersList.add(newUser.Id);
                        }
                    }
                    
                    if(usersList.size()>0)
                    {
                        List<sobject> removePermissionSetAndGroupList = new List<sobject>();
                        
                        List<sobject> removePermissionSetList =  [
                            SELECT id, PermissionSetId, AssigneeId
                            FROM PermissionSetAssignment
                            WHERE AssigneeId In: usersList 
                            AND PermissionSetId =: permissionSetId
                        ];
                        removePermissionSetAndGroupList.addAll(removePermissionSetList);
                        
                        List<sobject> removeGroupList = [
                            SELECT id, GroupId, UserOrGroupId 
                            FROM GroupMember 
                            WHERE UserOrGroupId In: usersList
                            AND GroupId =: groupId
                        ];
                        removePermissionSetAndGroupList.addAll(removeGroupList);
                        
                        if(removePermissionSetAndGroupList.size()>0)
                        {
                            delete removePermissionSetAndGroupList; 
                        }
                    } 
                    
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
}