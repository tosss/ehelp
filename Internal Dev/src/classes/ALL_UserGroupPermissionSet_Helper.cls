public with sharing class ALL_UserGroupPermissionSet_Helper {
    
    public static void addPermissionSetsAndGroups(List<User> userList) 
    {
        List<Assign_PermissionSets__c> customSettingList=Assign_PermissionSets__c.getAll().values();
        
        Map<Id, Map<String, List<Assign_PermissionSets__c>>> permSetIdGrpingIdCondtnMap=new Map<Id, Map<String, List<Assign_PermissionSets__c>>>();
        Map<Id, Map<String, List<Assign_PermissionSets__c>>> grpIdGrpingIdCondtnMap=new Map<Id, Map<String, List<Assign_PermissionSets__c>>>();
        
        for(Assign_PermissionSets__c ref: customSettingList)
        {
            Map<String, List<Assign_PermissionSets__c>> grpingIdCondtnMap;
            
            Id permSetId=ref.PermissionSet_ID__c;
            if(permSetId!=Null)
            {
                grpingIdCondtnMap=fetchGrpingIdCondtnsMap(permSetIdGrpingIdCondtnMap, ref, permSetId, ref.Grouping_ID_Permission_Set__c);
                permSetIdGrpingIdCondtnMap.put(permSetId, grpingIdCondtnMap);
            }
            
            grpingIdCondtnMap=Null;
            
            Id grpId=ref.Group_ID__c;
            if(grpId!=Null)
            {
                grpingIdCondtnMap=fetchGrpingIdCondtnsMap(grpIdGrpingIdCondtnMap, ref, grpId, ref.Grouping_ID_Group__c);
                grpIdGrpingIdCondtnMap.put(grpId, grpingIdCondtnMap);
            }
        }
        
        Set<String> userPermSetIdsToAdd=new Set<String>();
        Set<String> userPermSetIdsToRemove=new Set<String>();
        Set<String> userGrpIdsToAdd=new Set<String>();
        Set<String> userGrpIdsToRemove=new Set<String>();
        Set<Id> inactiveUserIds=new Set<Id>();
        
        for(User userRec: userList)
        {
            if(userRec.IsActive)
            {
                populatePermSetsOrGrpsToAddRemove(userRec, permSetIdGrpingIdCondtnMap, userPermSetIdsToAdd, userPermSetIdsToRemove);
                
                populatePermSetsOrGrpsToAddRemove(userRec, grpIdGrpingIdCondtnMap, userGrpIdsToAdd, userGrpIdsToRemove);
            }
            else
            {
                inactiveUserIds.add(userRec.Id);
                
                for(Id grpId: grpIdGrpingIdCondtnMap.keySet())
                {
                    String key=userRec.Id+':'+grpId;
                    userGrpIdsToRemove.add(key);
                }
            }
        }
        
        if(userPermSetIdsToAdd.size()!=0 || userPermSetIdsToRemove.size()!=0)
        {
            addPermissionSets(userPermSetIdsToAdd, userPermSetIdsToRemove);
        }
        
        if(userGrpIdsToAdd.size()!=0 || userGrpIdsToRemove.size()!=0)
        {
            addGroups(userGrpIdsToAdd, userGrpIdsToRemove);
        }
        
        if(inactiveUserIds.size()>0)
        {
            remAllAssgndPermSets(inactiveUserIds);
        }
        
    }
    
    private static Map<String, List<Assign_PermissionSets__c>> fetchGrpingIdCondtnsMap(Map<Id, Map<String, List<Assign_PermissionSets__c>>> permSetOrGrpIdGrpingIdCondtnMap, 
                                                                                       Assign_PermissionSets__c ref, Id permSetOrGrpId, String permSetOrGrpGrpingId)
    {
        Map<String, List<Assign_PermissionSets__c>> grpingIdCondtnMap=new Map<String, List<Assign_PermissionSets__c>>();
        
        if(permSetOrGrpIdGrpingIdCondtnMap.containsKey(permSetOrGrpId))
        {
            grpingIdCondtnMap=permSetOrGrpIdGrpingIdCondtnMap.get(permSetOrGrpId);
            List<Assign_PermissionSets__c> condtnsList=new List<Assign_PermissionSets__c>();
            
            String grpingId=permSetOrGrpGrpingId;
            if(grpingIdCondtnMap.containsKey(grpingId))
            {
                condtnsList=grpingIdCondtnMap.get(grpingId);
            }
            condtnsList.add(ref);
            
            grpingIdCondtnMap.put(grpingId, condtnsList);
        }
        else
        {
            String grpingId=permSetOrGrpGrpingId;
            List<Assign_PermissionSets__c> condtnsList=new List<Assign_PermissionSets__c>();
            condtnsList.add(ref);
            
            grpingIdCondtnMap.put(grpingId, condtnsList);
        }
        
        return grpingIdCondtnMap;
    }
    
    
    private static void populatePermSetsOrGrpsToAddRemove(User userRec, Map<Id, Map<String, List<Assign_PermissionSets__c>>> permSetOrGrpIdGrpingIdCondtnMap, 
                                                          Set<String> userPermSetOrGrpIdsToAdd, Set<String> userPermSetOrGrpIdsToRemove)
    {
        Id userId=userRec.Id;
        for(Id permSetOrGrpId: permSetOrGrpIdGrpingIdCondtnMap.keySet())
        {
            Map<String, List<Assign_PermissionSets__c>> grpingIdCondtnMap=permSetOrGrpIdGrpingIdCondtnMap.get(permSetOrGrpId);
            Boolean condtnsMet=false;
            
            for(String grpingId: grpingIdCondtnMap.keySet())
            {
                if(!condtnsMet)
                {
                    List<Assign_PermissionSets__c> condtnsList=grpingIdCondtnMap.get(grpingId);
                    Integer noOfConditions=condtnsList.size();
                    Integer counter=0;
                    
                    for(Assign_PermissionSets__c csRec: condtnsList)
                    {
                        Id idFieldVal;
                        if(csRec.Field_Value__c!=Null && validateId(csRec.Field_Value__c)!=Null)
                        {
                            idFieldVal=csRec.Field_Value__c;
                        }
                        
                        Object csFieldValue=(idFieldVal==Null) ? String.valueOf(csRec.Field_Value__c) : String.valueOf(idFieldVal);
                        
                        String userFieldName=csRec.Field_Name__c;
                        Object userFieldValue=userRec.get(userFieldName);
                        String key=userId+':'+permSetOrGrpId;
                        
                        if(checkCondition(csFieldValue, csRec.Operator__c, userFieldValue, csRec.Data_Type__c))
                        {
                            counter++;
                        }
                        else
                        {
                            userPermSetOrGrpIdsToRemove.add(key);
                            break;
                        }
                        
                        if(counter==noOfConditions)
                        {
                            userPermSetOrGrpIdsToAdd.add(key);
                            condtnsMet=true;
                            
                            if(userPermSetOrGrpIdsToRemove.contains(key))
                            {
                                userPermSetOrGrpIdsToRemove.remove(key);
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private static String validateId(String idVal)
    {
        String idValStr=String.escapeSingleQuotes(idVal);
        if((idValStr.length()==15 || idValStr.length()==18) && Pattern.matches('^[a-zA-Z0-9]*$', idValStr))
        {
            return idValStr;
        }
        return Null;
    }
    
    public static boolean checkCondition(object csFieldValue, String operator, object userFieldValue, String dataType)
    {
        dataType=dataType!= Null ? dataType.toLowerCase(): Null;
        
        if(operator!=Null && (operator.equals('==') || operator.equals('!='))) 
        {
            if(dataType=='string' || dataType=='boolean') 
            { 
                csFieldValue=String.valueOf(csFieldValue)!=Null ? String.valueOf(csFieldValue).toLowerCase(): Null; 
                userFieldValue=String.valueOf(userFieldValue)!=Null ? String.valueOf(userFieldValue).toLowerCase(): Null;
            }
        }
        
        if(operator!=Null && (operator.equals('==') || operator.equals('===')))
        {
            return (csFieldValue==userFieldValue);
        }
        else if(operator!=Null && (operator.equals('!=') || operator.equals('!==')))
        {
            return !(csFieldValue==userFieldValue);
        }
        else if(dataType=='datetime' && operator!=Null && operator.equals('>'))
        {
            DateTime userDate=(DateTime) userFieldValue;
            DateTime csDate=Null; 
            try 
            { 
                csDate=DateTime.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage() + ' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate > csDate;
        }
        else if(dataType=='datetime' && operator!=Null && operator.equals('<'))
        {
            DateTime userDate=(DateTime) userFieldValue;
            DateTime csDate=Null; 
            try 
            { 
                csDate=DateTime.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage()+' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate < csDate;
        }
        else if(dataType=='date' && operator!=Null && operator.equals('>'))
        {
            Date userDate=Date.valueOf(userFieldValue);
            Date csDate=Null; 
            try 
            { 
                csDate=Date.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage() + ' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate > csDate;
        }
        else if(dataType=='date' && operator!=Null && operator.equals('<'))
        {
            Date userDate=Date.valueOf(userFieldValue);
            Date csDate=Null; 
            try 
            { 
                csDate=Date.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage() + ' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate < csDate;
        }
        else if(dataType=='integer' && operator!=Null && operator.equals('>'))
        {
            Integer userInt=Integer.valueOf(userFieldValue);
            Integer csInt=Integer.valueOf(csFieldValue);
            
            return userInt > csInt;
        }
        else if(dataType=='integer' && operator!=Null && operator.equals('<'))
        {
            Integer userInt=Integer.valueOf(userFieldValue);
            Integer csInt=Integer.valueOf(csFieldValue);
            
            return userInt < csInt;
        }
        else if(dataType=='datetime' && operator!=Null && operator.equals('>='))
        {
            DateTime userDate=(DateTime) userFieldValue;
            DateTime csDate=Null; 
            try 
            { 
                csDate=DateTime.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage() + ' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate > csDate;
        }
        else if(dataType=='datetime' && operator!=Null && operator.equals('<='))
        {
            DateTime userDate=(DateTime) userFieldValue;
            DateTime csDate=Null; 
            try 
            { 
                csDate=DateTime.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage() + ' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate < csDate;
        }
        else if(dataType=='date' && operator!=Null && operator.equals('>='))
        {
            Date userDate=(Date) userFieldValue;
            Date csDate=Null; 
            try 
            { 
                csDate=Date.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage() + ' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate >= csDate;
        }
        else if(dataType=='date' && operator!=Null && operator.equals('<='))
        {
            Date userDate=(Date) userFieldValue;
            Date csDate=Null; 
            try 
            { 
                csDate=Date.parse(String.valueOf(csFieldValue)); 
            } 
            catch(Exception exceptionThrown) 
            { 
                system.debug(exceptionThrown.getMessage() + ' at---->'+ exceptionThrown.getLineNumber());
            }
            
            return userDate <= csDate;
        }
        else if(dataType=='integer' && operator!=Null && operator.equals('>='))
        {
            Integer userInt=Integer.valueOf(userFieldValue);
            Integer csInt=Integer.valueOf(csFieldValue);
            
            return userInt > csInt;
        }
        else if(dataType=='integer' && operator!=Null && operator.equals('<='))
        {
            Integer userInt=Integer.valueOf(userFieldValue);
            Integer csInt=Integer.valueOf(csFieldValue);
            
            return userInt < csInt;
        }
        else
        {
            return false;   
        } 
    }
    
    private static String formatIds(String recordId)
    {
        return recordId.left(15);
    }
    
    @Future
    private static void addPermissionSets(Set<String> userPermissionSetIdSet, Set<String> removeUserPermissionSets)
    {
        try
        {
            if(removeUserPermissionSets.size()!=0)
            {
                removePermissionSets(removeUserPermissionSets);
            }
            if(userPermissionSetIdSet!=Null)
            {
                List<PermissionSetAssignment> assignmentList=new  List<PermissionSetAssignment>();
                for(String userPermissionSetId: userPermissionSetIdSet)
                {
                    String[] keyArr=userPermissionSetId.split(':');
                    PermissionSetAssignment assignObj=new PermissionSetAssignment();
                    assignObj.PermissionSetId=keyArr[1];
                    assignObj.AssigneeId=keyArr[0];
                    assignmentList.add(assignObj);
                }
                
                //Skip exceptions when license of User and permission Set do not match
                Database.upsertResult [] upsertResult=Database.upsert(assignmentList, false);
                for(Database.upsertResult upsertResultObj :upsertResult)
                {
                    Database.Error[] errors= upsertResultObj.getErrors();
                    if(errors.size()!=0)
                    {
                        System.debug('***** Database upsert Exception: '+upsertResultObj.getErrors());
                    }
                }
            }
        }
        catch(Exception exceptionThrown)
        {
            ALL_UtilitiesMiscellaneous.showDebug=true;
            ALL_UtilitiesMiscellaneous.debug(exceptionThrown.getMessage()); 
        }
    }
    
    private static void removePermissionSets(Set<String> removeUserPermissionSets)
    {
        if(removeUserPermissionSets.size()!=0)
        {
            List<Id> userIds=new List<Id>();
            List<Id> permissionSetIds=new List<Id>();
            
            for(String permissionSet: removeUserPermissionSets)
            {
                String[] keyArr= permissionSet.split(':');
                userIds.add(keyArr[0]);
                permissionSetIds.add(keyArr[1]);
            }
            List<PermissionSetAssignment> permissionSetAssignmentList=[
                SELECT Id 
                FROM PermissionSetAssignment 
                WHERE PermissionSetId in :permissionSetIds 
                AND AssigneeId in :userIds
            ];
            
            if(permissionSetAssignmentList.size()!=0)
            {
                delete permissionSetAssignmentList;
            }
        }
    }
    
    @Future
    private static void addGroups(Set<String> UserGroupIdSet, Set<String> removeUserGroupIdSet)
    {
        try
        {
            if(removeUserGroupIdSet.size()!=0)
            {
                removeUsersFromGroup(removeUserGroupIdSet);
            }
            if(UserGroupIdSet!=Null)
            {
                List<GroupMember> groupList=new  List<GroupMember>();
                for(String UserGroupId: UserGroupIdSet)
                {
                    String[] keyArr=UserGroupId.split(':');
                    GroupMember groupMemberObject=new GroupMember();
                    groupMemberObject.GroupId= keyArr[1];
                    groupMemberObject.UserOrGroupId= keyArr[0];
                    groupList.add(groupMemberObject);
                }
                
                //Skip exceptions when license of User and permission Set do not match
                Database.upsertResult [] upsertResult=Database.upsert(groupList, false);
                for(Database.upsertResult upsertResultObj: upsertResult)
                {
                    Database.Error[] errors= upsertResultObj.getErrors();
                    if(errors.size()!=0)
                    {
                        System.debug('Database upsert Exception---->'+upsertResultObj.getErrors());
                    }
                }
            }
        }
        catch(Exception exceptionThrown)
        {
            ALL_UtilitiesMiscellaneous.showDebug=true;
            ALL_UtilitiesMiscellaneous.debug(exceptionThrown.getMessage()); 
        }
    }
    
    private static void removeUsersFromGroup(Set<String> removeUserGroupIdSet)
    {
        if(removeUserGroupIdSet.size()!=0)
        {
            List<Id> userIds=new List<Id>();
            List<Id> groupIds=new List<Id>();
            
            for(String userGroupId: removeUserGroupIdSet)
            {
                String[] keyArr= userGroupId.split(':');
                userIds.add(keyArr[0]);
                groupIds.add(keyArr[1]);
            }
            List<GroupMember> groupMemList=[
                SELECT Id 
                FROM GroupMember 
                WHERE UserorGroupId in :userIds 
                AND 
                GroupId in :groupIds
            ];
            
            if(groupMemList.size()!=0)
            {
                delete groupMemList;
            }
        }
    }
    
    @Future
    private static void remAllAssgndPermSets(Set<Id> inactiveUserIds)
    {
        system.debug('Start remAllAssgndPermSets---->');
        List<PermissionSetAssignment> permSetAssignmentList=new List<PermissionSetAssignment>([
            SELECT Id 
            FROM PermissionSetAssignment 
            WHERE AssigneeId in :inactiveUserIds
            AND PermissionSetId IN (
                SELECT Id 
                FROM PermissionSet
                WHERE IsOwnedByProfile=false
            )
        ]);
        
        if(permSetAssignmentList.size()>0)
        {
            delete permSetAssignmentList;
        }
        
        system.debug('End remAllAssgndPermSets---->');
    }
    
}