/*******************************************************
* Author: Hemanth.Kesapragada@cdk.com
* Description: Handler for All_User trigger
* Adds permission sets to the user and also adds user to the group specified.
* Test Class: DS_AddPermissionSet_Test
* 
* History:
* 2015-04-02 	Hemanth Kesapragada		Created
* 2015-04-09 	Hemanth Kesapragada		Added addPermissionSets method 
* 2015-07-24 	Hemanth Kesapragada		Added methods to remove permission sets that are already added 
										and the condition in custom setting is not met.
* 2015-07-29 	Hemanth Kesapragada		Added checkCondition method to implement comparision functionality.
* 2015-01-12    matt.keefe@cdk.com      Added dataType to checkCondition
* *************************************************** */
public class DS_AddPermissionSet_Handler { 
	
    // ****************************************
	// Author: Hemanth Kesapragada
	// Description: Compiles the condition depending on the operator passed.
    // Parameters: Custom setting value, operator and user field value
	// Return type: boolean
	// **************************************** */ 
    public static boolean checkCondition(object csFieldValue, String operator, object userFieldValue, string dataType)
    {
        system.debug(
            '  csFieldValue:'+csFieldValue+
            ', operator:'+operator+
            ', userFieldValue:'+userFieldValue+
            ', dataType:'+dataType
        );
        
        // ignore case for datatype
        dataType = dataType.toLowerCase();
        
        if(operator.equals('==') || operator.equals('!='))
        {
            // ignore case
            if(dataType == 'string' || dataType == 'boolean') { 
                csFieldValue = String.valueOf(csFieldValue).toLowerCase(); 
                userFieldValue = String.valueOf(userFieldValue).toLowerCase(); 
            }
        }
        
        if(operator.equals('==') || operator.equals('==='))
        {
            return (csFieldValue == userFieldValue);
        }
        else if(operator.equals('!=') || operator.equals('!=='))
        {
            return !(csFieldValue == userFieldValue);
        }
        else if(dataType == 'datetime' && operator.equals('>'))
        {
            DateTime userDate = (DateTime) userFieldValue;
            DateTime csDate = null; try { csDate = DateTime.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { }
            
            return userDate > csDate;
        }
        else if(dataType == 'datetime' && operator.equals('<'))
        {
            DateTime userDate = (DateTime) userFieldValue;
            DateTime csDate = null; try { csDate = DateTime.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { }
            
            return userDate < csDate;
        }
        else if(dataType == 'date' && operator.equals('>'))
        {
            Date userDate = Date.valueOf(userFieldValue);
            Date csDate = null; try { csDate = Date.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { system.debug(exc); }
            
            system.debug(userDate + '>' + csDate + ': ' + (userDate > csDate)); 
            
            return userDate > csDate;
        }
        else if(dataType == 'date' && operator.equals('<'))
        {
            Date userDate = Date.valueOf(userFieldValue);
            Date csDate = null; try { csDate = Date.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { system.debug(exc); }
            
            system.debug(userDate + '<' + csDate + ': ' + (userDate > csDate)); 
            
            return userDate < csDate;
        }
        else if(dataType == 'integer' && operator.equals('>'))
        {
            Integer userInt = Integer.valueOf(userFieldValue);
            Integer csInt = Integer.valueOf(csFieldValue);
            
            return userInt > csInt;
        }
        else if(dataType == 'integer' && operator.equals('<'))
        {
            Integer userInt = Integer.valueOf(userFieldValue);
            Integer csInt = Integer.valueOf(csFieldValue);
            
            return userInt < csInt;
        }
        else if(dataType == 'datetime' && operator.equals('>='))
        {
            DateTime userDate = (DateTime) userFieldValue;
            DateTime csDate = null; try { csDate = DateTime.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { }
            
            return userDate > csDate;
        }
        else if(dataType == 'datetime' && operator.equals('<='))
        {
            DateTime userDate = (DateTime) userFieldValue;
            DateTime csDate = null; try { csDate = DateTime.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { }
            
            return userDate < csDate;
        }
        else if(dataType == 'date' && operator.equals('>='))
        {
            Date userDate = (Date) userFieldValue;
            Date csDate = null; try { csDate = Date.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { }
            
            return userDate >= csDate;
        }
        else if(dataType == 'date' && operator.equals('<='))
        {
            Date userDate = (Date) userFieldValue;
            Date csDate = null; try { csDate = Date.parse(String.valueOf(csFieldValue)); } catch(Exception exc) { }
            
            return userDate <= csDate;
        }
        else if(dataType == 'integer' && operator.equals('>='))
        {
            Integer userInt = Integer.valueOf(userFieldValue);
            Integer csInt = Integer.valueOf(csFieldValue);
            
            return userInt > csInt;
        }
        else if(dataType == 'integer' && operator.equals('<='))
        {
            Integer userInt = Integer.valueOf(userFieldValue);
            Integer csInt = Integer.valueOf(csFieldValue);
            
            return userInt < csInt;
        }
        else
        {
            return false;   
        } 
    }
    
    public static void addPermissionSetsAndGroups(List<User> userList) 
    {
        try
        {
            List<Assign_PermissionSets__c> customSettingList = Assign_PermissionSets__c.getAll().values();
            Map<String,List<Assign_PermissionSets__c>> groupConditionMap = new map<String,List<Assign_PermissionSets__c>>();
            Map<String,List<Assign_PermissionSets__c>> permissionSetConditionMap = new map<String,List<Assign_PermissionSets__c>>();
            Set<String> UserPermissionSetIdList = new Set<String>();
            Set<String> UserGroupIDList = new Set<String>();
            Set<String> removeUserGroupIdList = new Set<String>();
            Set<String> removeUserPermissionSets = new Set<String>();
            
            for(Assign_PermissionSets__c csObj : customSettingList)
            {
                List<Assign_PermissionSets__c> csList;
                if(csObj.Group_ID__c!=null)
                {
                    String groupId = formatIds(csObj.Group_ID__c);
                    if(groupConditionMap.containsKey(groupId))
                    {
                        csList = groupConditionMap.get(groupId);
                        csList.add(csObj);
                    }
                    else
                    {
                        csList = new List<Assign_PermissionSets__c>();
                        csList.add(csObj);
                    }
                    groupConditionMap.put(groupId, csList);
                }
                csList=null;
                if(csObj.PermissionSet_ID__c!=null)
                {
                    String permissionSetID = formatIds(csObj.PermissionSet_ID__c);
                    if(permissionSetConditionMap.containsKey(permissionSetID))
                    {
                        csList = permissionSetConditionMap.get(permissionSetID);
                        csList.add(csObj);
                    }
                    else
                    {
                        csList = new List<Assign_PermissionSets__c>();
                        csList.add(csObj);
                    }
                    permissionSetConditionMap.put(permissionSetID, csList);
                }
            }
            
            for(User userObj : userList)
            {
                String userId = formatIds(userObj.Id);
                for(String groupId : groupConditionMap.keySet())
                {
                    Integer noOfConditions = groupConditionMap.get(groupId).size();
                    Integer counter = 0;
                    for(Assign_PermissionSets__c csObj : groupConditionMap.get(groupId))
                    {
                        String customSettingfieldName = csObj.Field_Name__c;
                        object customSettingfieldValue = String.valueOf(csObj.Field_Value__c);
                        object userfieldValue = userObj.get(customSettingfieldName);
                        if(checkCondition(customSettingfieldValue, csObj.operator__c, userfieldValue, csObj.Data_Type__c))
                        {
                            counter++;
                        }
                        else
                        {
                            String key = userId+':'+groupId;
                            removeUserGroupIdList.add(key);
                        }
                        
                        if(counter==noOfConditions)
                        {
                            String key = userId+':'+groupId;
                            UserGroupIDList.add(key);
                        }
                    }
                }
                
                for(String permissionSetId : permissionSetConditionMap.keySet())
                {
                    Integer noOfConditions = permissionSetConditionMap.get(permissionSetId).size();
                    Integer counter = 0;
                    for(Assign_PermissionSets__c csObj : permissionSetConditionMap.get(permissionSetId))
                    {
                        String customSettingfieldName = csObj.Field_Name__c;
                        object customSettingfieldValue = String.valueOf(csObj.Field_Value__c);
                        object userfieldValue = userObj.get(customSettingfieldName);
                        if(checkCondition(customSettingfieldValue, csObj.operator__c, userfieldValue, csObj.Data_Type__c))
                        {
                            counter++;
                        }
                        else
                        {
                            String key = userId+':'+permissionSetId;
                            removeUserPermissionSets.add(key);
                        }
                        
                        if(counter==noOfConditions)
                        {
                            String key = userId+':'+permissionSetId;
                            UserPermissionSetIdList.add(key);
                        }
                    }
                }
            }
            
            if(UserPermissionSetIdList.size()!=0 || removeUserPermissionSets.size()!=0)
            {
                system.debug('Add:'+UserPermissionSetIdList); system.debug('Remove:'+removeUserPermissionSets);
                addPermissionSets(UserPermissionSetIdList,removeUserPermissionSets);
            }
            
            if(UserGroupIDList.size()!=0 || removeUserGroupIdList.size()!=0)
            {
                system.debug('Add:'+UserGroupIDList); system.debug('Remove:'+removeUserGroupIdList);
                addGroups(UserGroupIDList,removeUserGroupIdList);
            }  
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
        }
    }
    
    @future
    public static void addPermissionSets(Set<String> UserPermissionSetIdList,Set<String> removeUserPermissionSets)
    {
        try
        {
            if(removeUserPermissionSets.size()!=0)
            {
                removePermissionSets(removeUserPermissionSets);
            }
            if(UserPermissionSetIdList!=null)
            {
                List<PermissionSetAssignment> assignmentList = new  List<PermissionSetAssignment>();
                //Map<String,String> newPermissionSetMap = checkForExistingPermissionSets(permissionSetMap);
                for(String key : UserPermissionSetIdList)
                {
                    String[] keyArr = key.split(':');
                    PermissionSetAssignment assignObj = new PermissionSetAssignment();
                    assignObj.PermissionSetId = keyArr[1];
                    assignObj.AssigneeId = keyArr[0];
                    assignmentList.add(assignObj);
                }
                
                //Skip exceptions when license of User and permission Set do not match
                Database.upsertResult [] upsertResult = Database.upsert(assignmentList, false);
                for(Database.upsertResult upsertResultObj :upsertResult)
                {
                        Database.Error[] errors =  upsertResultObj.getErrors();
                        if(errors.size()!=0)
                        {
                           System.debug('***** Database upsert Exception: '+upsertResultObj.getErrors());
                        }
                }
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage()); 
        }
    }  
    
    @future
    public static void addGroups(Set<String> UserGroupIDList,Set<String> removeUserGroupIdList)
    {
        try
        {
            if(removeUserGroupIdList.size()!=0)
            {
                removeUsersFromGroup(removeUserGroupIdList);
            }
            if(UserGroupIDList!=null)
            {
                List<GroupMember> groupList = new  List<GroupMember>();
                for(String key : UserGroupIDList)
                {
                    String[] keyArr = key.split(':');
                    GroupMember groupMemberObject = new GroupMember();
                    groupMemberObject.GroupId =  keyArr[1];
                    groupMemberObject.UserOrGroupId =  keyArr[0];
                    groupList.add(groupMemberObject);
                }
                
                //Skip exceptions when license of User and permission Set do not match
                Database.upsertResult [] upsertResult = Database.upsert(groupList, false);
                for(Database.upsertResult upsertResultObj :upsertResult)
                {
                    Database.Error[] errors =  upsertResultObj.getErrors();
                    if(errors.size()!=0)
                    {
                        System.debug('***** Database upsert Exception: '+upsertResultObj.getErrors());
                    }
                }
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage()); 
        }
        
    } 
    
    public static void removeUsersFromGroup(Set<String> removeUserGroupIdList)
    {
        if(removeUserGroupIdList.size()!=0)
        {
            List<Id> userIds = new List<Id>();
            List<Id> groupIds = new List<Id>();
            
            for(String key : removeUserGroupIdList)
            {
                String[] keyArr= key.split(':');
                userIds.add(keyArr[0]);
                groupIds.add(keyArr[1]);
            }
            List<GroupMember> groupMemList = [select id from GroupMember where UserorGroupId in :userIds and GroupId in :groupIds];
            if(groupMemList.size()!=0)
            {
                delete groupMemList;
            }
        }
    }
    
    public static void removePermissionSets(Set<String> removeUserPermissionSets)
    {
        if(removeUserPermissionSets.size()!=0)
        {
            List<Id> userIds = new List<Id>();
            List<Id> permissionSetIds = new List<Id>();
            
            for(String key : removeUserPermissionSets)
            {
                String[] keyArr= key.split(':');
                userIds.add(keyArr[0]);
                permissionSetIds.add(keyArr[1]);
            }
            List<PermissionSetAssignment> permSetAssignmentList = [select id from PermissionSetAssignment where PermissionSetId in :permissionSetIds and AssigneeId in :userIds];
            if(permSetAssignmentList.size()!=0)
            {
                delete permSetAssignmentList;
            }
        }
    }
    
    private static String formatIds(String recordId)
    {
        return recordId.left(15);
    }
}