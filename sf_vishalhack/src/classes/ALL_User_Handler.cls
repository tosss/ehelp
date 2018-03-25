//2016-04-13 - lalitha.adduru@cdk.com - class created to refactor triggers and handlers on User object - RQ-06757
//2016-05-25 - lalitha.adduru@cdk.com - added recursive check to prevent duplicate contacts from getting created
//2016-08-30 - lalitha.adduru@cdk.com - commented out creating and deleting policies functionality
//2016-12-26 - ragashalini.koka@cdk.com - RQ-08369 - Added method to update Top_5__c records when Manager gets updated
//2017-03-21- anirudh.singh@cdk.com- RQ-08776 Update Permission Set Auto-assignment
//2017-03-21 - lalitha.adduru@cdk.com - method to update EMployee Information whenever user is made inactive - RQ-08780
public class ALL_User_Handler 
{
    public static void beforeInsert(List<User> newUserList)
    {
        makeFederationIdRequired(newUserList);
    }
    
    public static void beforeUpdate(Map<Id, User> newMap, Map<Id, User> oldMap)
    {
        makeFederationIdRequired(newMap.values());
        String newSerialisedString = json.serialize(newMap.values());
        String oldSerializedString = json.serialize(oldMap);
        updateEmployeeInfoOwner(newSerialisedString, oldSerializedString );
    }
    
    //2016-04-19 - lalitha.adduru@cdk.com - Moved from DS_userToEmployeeUpdateTriggerHandler and made some changes to fit coding standards - RQ-06757
    private static void makeFederationIdRequired(List<User> newUserList)
    {
        for(User newUser: newUserList)
        {
            if(newUser.federationIdentifier==Null || String.isEmpty(newUser.federationIdentifier))
            {
                //run if not test and user is active and is not a non-interactive user and is not a sales-automation user
                if(!Test.isRunningTest() &&              		
                   newUser.IsActive &&                          
                   newUser.Non_Interactive_User__c!=true &&  
                   newUser.Sales_Automation_User__c!=true) 
                {
                    //u.addError('Federation Id is required to save the record');
                    newUser.federationIdentifier.addError('Federation Id is required to save the record');
                }
            }
        }
    }
    
    //2017-03-21 - lalitha.adduru@cdk.com - method to update EMployee Information whenever user is made inactive - RQ-08780
    @Future
    private static void updateEmployeeInfoOwner(String newSerialisedString, String oldSerializedString)
    {
        List<User> newUserList = (List<User>)json.deserialize(newSerialisedString,List<User>.class);
        Map<Id, User> oldUserMap = (Map<Id, User>)json.deserialize(oldSerializedString, Map<Id, User>.class);
        Map<Id, Employee_Information__c> userToEmployeeInfoMap = new Map<Id, Employee_Information__c>();
        List<user> relevantUsers = new List<User>();
        
        for(User updatedUser : newUserList)
        {
            User oldUser = oldUserMap.get(updatedUser.Id);
            if((updatedUser.Termination_Date__c == null && oldUser.Termination_Date__c != null) 
               || (updatedUser.IsActive == false || String.valueOf(updatedUser.LastName).contains('retired')))
            {
                system.debug('user is inactive -- >'+updatedUser.username);
                relevantUsers.add(updatedUser);
            }
        }
        
        List<Employee_Information__c> empInfoList = [
            SELECT Id, User__c, OwnerId
            FROM Employee_Information__c WHERE User__c in :relevantUsers
        ];
        
        for(Employee_Information__c empInfo : empInfoList)
        {
            userToEmployeeInfoMap .put(empInfo.User__c, empInfo); 
        }
        
        Map<Id, Employee_Information__c> empInfosToUpdate = new Map<Id, Employee_Information__c>();
        
        List<User> adminUsers = [
            SELECT Id,username
            FROM User WHERE UserName=:GlobalSettings__c.getOrgDefaults().Admin_Integration_Username__c
        ];
        
        Id adminUserId = null;
        if(!adminUsers.isEmpty())
        {
            adminUserId = adminUsers[0].Id;
        }
        system.debug('admin user Id -- >'+adminUserId);
        
        for(User updatedUser : relevantUsers)
        {
            Employee_Information__c empInfo = userToEmployeeInfoMap.get(updatedUser.Id);
            if(empInfo != null)
            {
                if(updatedUser.Termination_Date__c == null)
                {
                    if(empInfo.OwnerId != updatedUser.Id)
                    {
                        empInfo.OwnerId = updatedUser.Id;
                        empInfosToUpdate.put(empInfo.Id, empInfo);
                    }
                }
                else
                {
                    if(adminUserId != null && empInfo.OwnerId != adminUserId)
                    { 
                        empInfo.OwnerId = adminUserId;
                        empInfosToUpdate.put(empInfo.Id, empInfo);
                    }
                }
            }
        }
        
        if(!empInfosToUpdate.isEmpty())
        {
            update empInfosToUpdate.values();
        }
    }
    
    public static void afterInsert(Map<Id, User> newMap)
    {
        addPermissionSetsAndGroups(newMap.values());
        
        //2016-04-18 - lalitha.adduru@cdk.com - prevent contact creation on new sales user - RQ-06386
        List<User> userListForPolicies=new List<User>();
        //to store newMap values just in case we needed to remove any users from newMap
        userListForPolicies=newMap.values();
        
        Map<Id, User> userForContactsMap=new Map<Id, User>();
        userForContactsMap.putAll(newMap);
        
        Map<Id, User> newUserToExistingUserMap=new Map<Id, User>();
        newUserToExistingUserMap=fetchActiveUsersWithSameFedId(newMap);
        
        //if none of them have an existing user with the same federation Id, contacts need to be created for all of them
        if(!newUserToExistingUserMap.isEmpty()) 
        {
            preventContactOnNewSalesUser(newMap.values(), newUserToExistingUserMap.values());
            
            //remove those users, for which an active user with the same federation Id exists from newMap
            for(Id userId: newUserToExistingUserMap.keySet())
            {
                userForContactsMap.remove(userId);
            }
        }
        
        List<Id> userIdsToCreateContacts=fetchUserIdsToCreateContacts(userForContactsMap.values());
        //List<Id> userIdsToCreatePolicies=fetchUserIdsToCreatePolicies(userListForPolicies);
        
        //2016-05-25 - lalitha.adduru@cdk.com - added recursive check to prevent duplicate contacts from getting created
        if(ALL_CheckRecursive.runCodeBlockOnce('createNewContactsAndPolicy'))
        {
            EMP_PolicyUtility.createNewContacts(userIdsToCreateContacts);
        }
    }
    
    public static void afterUpdate(Map<Id, User> newMap, Map<Id, User> oldMap)
    {
        userToEmployee(newMap, oldMap);
        addPermissionSetsAndGroups(newMap.values());
        
        List<Id> userIdsToCreateContacts=fetchUserIdsToCreateContacts(newMap.values());
        //List<Id> userIdsToCreatePolicies=fetchUserIdsToCreatePolicies(newMap.values());        
        
        //2016-05-25 - lalitha.adduru@cdk.com - added recursive check to prevent duplicate contacts from getting created
        if(ALL_CheckRecursive.runCodeBlockOnce('createNewContactsAndPolicy'))
        {
            EMP_PolicyUtility.createNewContacts(userIdsToCreateContacts);
        }
        
        //List<Id> userIdsToDeletePolicies=fetchUserIdsToDeletePolicies(newMap.values());
        //EMP_PolicyUtility.deletePolicyAcknowledgement(userIdsToDeletePolicies);
        updateManagerFieldsOnTop5Records(JSON.serialize(oldMap), JSON.serialize(newMap));
    }
    
    //2015-04-09 	Hemanth Kesapragada Added addPermissionSets method 
    //2017-03-21- anirudh.singh@cdk.com- Updated this method for RQ-08776 Update Permission Set Auto-assignment.
    private static void addPermissionSetsAndGroups(List<User> userList) 
    {
        system.debug('Start addPermissionSetsAndGroups---->');
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
            //2017-03-29- anirudh.singh@cdk.com- Added the below IF Block condition.
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
        
        //2017-03-21- anirudh.singh@cdk.com- Added this IF Block for RQ-08776 Update Permission Set Auto-assignment.
        if(inactiveUserIds.size()>0)
        {
            remAllAssgndPermSets(inactiveUserIds);
        }
        
        system.debug('End addPermissionSetsAndGroups---->');
    }
    
    //2017-03-21- anirudh.singh@cdk.com- Added this method for RQ-08776 Update Permission Set Auto-assignment.
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
    
    //2017-03-21- anirudh.singh@cdk.com- Added this method for RQ-08776 Update Permission Set Auto-assignment.
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
    
    //Author: Hemanth Kesapragada
    //Date :	2015-07-29
    //Description: Compiles the condition depending on the operator passed.
    //Parameters: Custom setting value, operator and user field value
    //Return type: boolean
    //2015-01-12    matt.keefe@cdk.com      Added dataType to checkCondition
    public static boolean checkCondition(object csFieldValue, String operator, object userFieldValue, String dataType)
    {
        system.debug('csFieldValue---->'+csFieldValue+', '+operator+', '+userFieldValue+', '+dataType);
        //ignore case for datatype
        //lalitha.adduru@cdk.com added Null check
        dataType=dataType!= Null ? dataType.toLowerCase(): Null;
        
        //lalitha.adduru@cdk.com added Null check
        if(operator!=Null && (operator.equals('==') || operator.equals('!='))) 
        {
            //ignore case
            if(dataType=='string' || dataType=='boolean') 
            { 
                //lalitha.adduru@cdk.com added Null check
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
    
    //2015-07-24 	Hemanth Kesapragada	Added methods to format Ids
    private static String formatIds(String recordId)
    {
        return recordId.left(15);
    }
    
    //2015-07-24 	Hemanth Kesapragada	Added methods to add permission sets
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
                //Map<String,String> newPermissionSetMap=checkForExistingPermissionSets(permissionSetMap);
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
    
    //2015-07-24 	Hemanth Kesapragada	Added methods to remove permission sets that are already added and the condition in custom setting is not met. 
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
    
    //2015-07-24 	Hemanth Kesapragada	Added methods to add groups
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
    
    //2015-07-24 	Hemanth Kesapragada	Added methods to remove users from groups
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
    
    //2017-03-21- anirudh.singh@cdk.com- Added this method for RQ-08776 Update Permission Set Auto-assignment.
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
    
    //2016-03-09 - lalitha.adduru@cdk.com - get new user Id to active user Map with same federation Id - RQ-06386
    private static Map<Id, User> fetchActiveUsersWithSameFedId(Map<Id, User> newUserMap)
    {
        Map<Id, User> newUserToExistingUserMap=new Map<Id, User>();
        
        Map<String,User> fedIdToUserMap=new Map<String,User>();
        Set<String> federationIdSet=new Set<String>();
        for(User newUser: newUserMap.values())
        {
            fedIdToUserMap.put(newUser.federationIdentifier, newUser);
            if(newUser.federationIdentifier!=Null || newUser.federationIdentifier!='')
            {
                federationIdSet.add('%'+newUser.federationIdentifier+'%');
            }
        }
        
        List<User> existingActiveUserList=new List<User>();
        existingActiveUserList=[
            SELECT Id, federationIdentifier, EMP_Contact__c
            FROM User 
            WHERE federationIdentifier 
            LIKE :federationIdSet
            AND isActive=true
            AND Id NOT IN :newUserMap.values()
        ];
        
        for(User existingUser: existingActiveUserList)
        {
            String fedIdWithNoUnderscores=existingUser.federationIdentifier ;
            while(fedIdWithNoUnderscores.startswith('_'))
            {
                fedIdWithNoUnderscores=fedIdWithNoUnderscores.removeStart('_');
            }
            if(fedIdToUserMap.containsKey(fedIdWithNoUnderscores))
            {
                newUserToExistingUserMap.put(fedIdToUserMap.get(fedIdWithNoUnderscores).Id, existingUser);
            }
        }
        
        return newUserToExistingUserMap;
    }
    
    //2016-03-01 - lalitha.adduru@cdk.com - prevent contact creation on new sales user - RQ-06386
    private static void preventContactOnNewSalesUser(List<User> newUserList, List<User> existingActiveUserList)
    {
        //serialize records in json as future methods cannot take sObjects as parameters
        List<String> serializedUserRecords=new List<String>();
        
        Set<Id> contactIdSet=new Set<Id>();
        Map<String, User> federationIdToUserMap=new Map<String, User>();
        Map<Id, Contact> contactsToUpdate=new Map<Id, Contact>();
        
        if(!existingActiveUserList.isEmpty())
        {
            for(User existingUser: existingActiveUserList)
            {
                String fedIdWithNoUnderscores=existingUser.FederationIdentifier;
                while(fedIdWithNoUnderscores.startswith('_'))
                {
                    fedIdWithNoUnderscores=fedIdWithNoUnderscores.removeStart('_');
                }
                federationIdToUserMap.put(fedIdWithNoUnderscores, existingUser);
                
                if(existingUser.EMP_Contact__c!=Null)
                {
                    contactIdSet.add(existingUser.EMP_Contact__c);
                }
            }
        }
        
        //get corresponding contacts
        Map<Id, Contact> contactMap=new Map<Id, Contact>([SELECT Id, User__c FROM Contact WHERE Id in :contactIdSet]);
        
        for(User newUser: newUserList)
        {
            User existingUser=federationIdToUserMap.get(newUser.FederationIdentifier);
            if(existingUser!=Null && newUser!=existingUser)
            {
                Contact existingContact=contactMap.get(existingUser.EMP_Contact__c);
                if(existingContact!=Null)
                {
                    existingContact.User__c= newUser.Id;
                    contactsToUpdate.put(existingContact.Id, existingContact);
                }
                
                existingUser.EMP_Contact__c=Null;
                serializedUserRecords.add(JSON.serialize(existingUser));
                //newUser.Contact_Vendor_ID__c=existingUser.Contact_Vendor_ID__c;
                //serializedUserRecords.add(JSON.serialize(newUser));
            }
        }
        
        //call future method to precent mixed dml error( as User is a setUp Object)
        updateUser(serializedUserRecords);
        
        update contactsToUpdate.values();
    }
    
    //2016-03-09 - lalitha.adduru@cdk.com - to prevent having dmls of setUp and Non-SetUp objects in one context
    //( gets called in preventContactOnNewSalesUser method) - RQ-06386
    @Future
    public static void updateUser(List<String> serialisedUserRecords)
    {
        Map<Id, User> usersToBeUpdated=new Map<Id, User>();
        
        for(String serialisedUserRecord: serialisedUserRecords)
        {
            User userRecord=(User)JSON.deserialize(serialisedUserRecord, User.class);
            usersToBeUpdated.put(userRecord.Id, userRecord);
        }
        
        if(!usersToBeUpdated.isEmpty())
        {
            update usersToBeUpdated.values();
        }
    }
    
    //2016-04-19 - lalitha.adduru@cdk.com - Moved from DS_userToEmployeeUpdateTriggerHandler and made some changes to fit coding standards - RQ-06757
    private static void userToEmployee(Map<Id, User> newMap, Map<Id, User> oldMap) 
    {
        List<Employee_Information__c> updatedEmps=new list<Employee_Information__c>();
        Set<String> changedEmps=new Set<String>();
        Set<String> userList=new Set<String>();
        Set<String> nonManagerList=new Set<String>();
        Set<String> managerList=new Set<String>();
        
        for(User updatedUser: newMap.values()) 
        {
            if(updatedUser.phone!=oldMap.get(updatedUser.Id).phone || updatedUser.extension!=oldMap.get(updatedUser.Id).extension ||
               updatedUser.fax!=oldMap.get(updatedUser.Id).fax || updatedUser.mobilePhone!=oldMap.get(updatedUser.Id).mobilePhone || 
               updatedUser.city!=oldMap.get(updatedUser.Id).city || updatedUser.state!=oldMap.get(updatedUser.Id).state || 
               updatedUser.postalCode!=oldMap.get(updatedUser.Id).postalCode || updatedUser.country!=oldMap.get(updatedUser.Id).country ||
               updatedUser.firstname!=oldMap.get(updatedUser.Id).firstname || updatedUser.lastname!=oldMap.get(updatedUser.Id).lastname) 
            {
                userList.add(updatedUser.Id);
                nonManagerList.add(updatedUser.Id);
            }  
            
            if(updatedUser.managerId!=oldMap.get(updatedUser.Id).managerId) 
            {
                userList.add(updatedUser.managerId);
                managerList.add(updatedUser.managerId);
            }
        }
        
        Map<String, Employee_Information__c> empInfoMap=new Map<String, Employee_Information__c>();
        Map<String, Employee_Information__c> empManagerInfoMap=new Map<String, Employee_Information__c>();
        
        list<Employee_Information__c> queriedEmployeeInformation=[
            SELECT empInfo.user__c, empInfo.Address__c, empInfo.City__c, empInfo.State__c, empInfo.Ext__c, empInfo.Fax__c, empInfo.Name, empInfo.Postal__c,
            empInfo.Work__c, empInfo.Manager__c
            FROM Employee_Information__c empInfo
            WHERE user__c=:newMap.keyset()
        ];
        
        if(queriedEmployeeInformation!=Null && !queriedEmployeeInformation.IsEmpty())
        {
            for(Employee_Information__c empInfo: queriedEmployeeInformation)
            {
                empInfoMap.put(empInfo.user__c, empInfo);
                //empManagerInfoMap.put(f.manager__r.user__C, f);
            }
        }
        
        list<Employee_Information__c> queriedManagerInformation=[
            SELECT Manager__r.User__c, Manager__r.Id, user__c
            FROM Employee_Information__c
            WHERE User__c in: Managerlist
        ];
        
        Map<String, Employee_Information__c> userMgrRev=new Map<String, Employee_Information__c>();
        if(queriedManagerInformation!=Null && !queriedManagerInformation.IsEmpty())
        {
            for(Employee_Information__c empInfo: queriedManagerInformation) 
            {
                //test if manager__r is Null
                userMgrRev.put(empInfo.user__c, empInfo);
            }
        }
        
        for(User newUser: newMap.values()) 
        {
            if(empInfoMap.containsKey(newUser.Id)) 
            {
                if(NonManagerList.contains(newUser.Id)) 
                {
                    //test for oldMap in case we add insert operation later                    
                    if(newUser.firstname!=oldMap.get(newUser.Id).firstname || newUser.lastname!=oldMap.get(newUser.Id).lastname) 
                    {
                        String newLastName=newUser.lastname;
                        String newLastNameWithoutRetired=(newLastName.toLowerCase().endsWith('-retired') ? 
                                                          newLastName.subString(0, newLastName.toLowerCase().lastIndexOf('-retired')): newLastName);
                        String oldLastName=oldMap.get(newUser.Id).lastname;
                        String oldLastNameWithoutRetired =(oldLastName.toLowerCase().endsWith('-retired') ?
                                                           oldLastName.subString(0, oldLastName.toLowerCase().lastIndexOf('-retired')) :oldLastName);
                        
                        empInfoMap.get(newUser.Id).name=newUser.firstname + ' ' + newLastName;
                    }
                    
                    if(newUser.phone!=oldMap.get(newUser.Id).phone) 
                    {
                        empInfoMap.get(newUser.Id).work__c=newUser.Phone;
                    }
                    
                    if(newUser.Extension!=oldMap.get(newUser.Id).Extension) 
                    {
                        empInfoMap.get(newUser.Id).Ext__c=newUser.Extension;
                    }
                    
                    //if(u.Email!=oldMap.get(u.Id).Email ){
                    //      empInfoMap.get(u.Id).E_Mail__c=u.Email;
                    // }
                    
                    if(newUser.Fax!=oldMap.get(newUser.Id).Fax) 
                    {
                        empInfoMap.get(newUser.Id).Fax__c=newUser.Fax;
                    }
                    
                    if(newUser.MobilePhone!=oldMap.get(newUser.Id).MobilePhone) 
                    {
                        empInfoMap.get(newUser.Id).Mobile__c=newUser.MobilePhone;
                    }
                    
                    //2014-02-18 MK - this was both commented out and uncommented in previous version
                    //  because one of these statements was uncommented, this functionality is uncommented as well
                    if(newUser.Street!=oldMap.get(newUser.Id).Street) 
                    {
                        empInfoMap.get(newUser.Id).address__c=newUser.Street;
                    }
                    
                    if(newUser.City!=oldMap.get(newUser.Id).City) 
                    {
                        empInfoMap.get(newUser.Id).City__c=newUser.City;
                    }
                    
                    if(newUser.State!=oldMap.get(newUser.Id).State) 
                    {
                        empInfoMap.get(newUser.Id).State__c=newUser.State;
                    }
                    
                    if(newUser.PostalCode!=oldMap.get(newUser.Id).PostalCode) 
                    {
                        empInfoMap.get(newUser.Id).Postal__c=newUser.PostalCode;
                    }
                    
                    if(newUser.Country!=oldMap.get(newUser.Id).Country) 
                    {
                        empInfoMap.get(newUser.Id).Country__c=newUser.Country;
                    }
                    
                    //if(u.Title!=oldMap.get(u.Id).Title){
                    //      empInfoMap.get(u.Id).Title__c=u.Title  ;
                    //}
                }  
                
                if(newUser.ManagerId!=oldMap.get(newUser.Id).ManagerId) 
                {
                    if(UserMgrRev!=Null && !UserMgrRev.IsEmpty()) 
                    {                       
                        empInfoMap.get(newUser.Id).Manager__c=userMgrRev.get(newUser.ManagerId).Id;
                    }
                    else 
                    {
                        empInfoMap.get(newUser.Id).Manager__c=Null;
                    }
                }
            }
        }
        
        try
        {
            update empInfoMap.values();
        } 
        catch(DMLException exceptionThrown) 
        {
            system.debug(exceptionThrown.getMessage() + 'at---->'+exceptionThrown.getLineNumber());
        }
    }
    
    //2016-04-25 - lalitha.adduru@cdk.com - fetch valid user ids to create contacts- RQ-06757
    private static List<Id> fetchUserIdsToCreateContacts(List<User> userListForContacts)
    {
        List<Id> userIdsToCreateContact=new List<Id>();
        
        Map<Id, Contact> userIdToContactRecordMap=new Map<Id, Contact>();
        userIdToContactRecordMap=userIdToContactRecordMap(userListForContacts);
        
        Set<String> contactEmailSet=new Set<String>();
        for(Contact retrievedContact: userIdToContactRecordMap.values())
        {
            contactEmailSet.add(retrievedContact.Email);
        }
        
        for(User user: userListForContacts)
        {
            if(user.Contractor__c==false && user.Non_Employee__c==false && user.Non_Interactive_User__c==false && user.IsActive==true)
            {
                //RQ-05492 hemanth.kesapragada@cdk.com Added check on emailId of the user
                //If the Map doesnt contain id - contact does not exist.
                if(!userIdToContactRecordMap.containsKey(user.Id) && !contactEmailSet.contains(user.Email))
                {
                    userIdsToCreateContact.add(user.Id);
                }
            }
        }
        
        return userIdsToCreateContact;
    }
    
    //2016-04-14 - lalitha.adduru@cdk.com get a Map a userId to corresponding contact record with required details - RQ-06757
    private static Map<Id, Contact> userIdToContactRecordMap(List<User> UserList)
    {
        Set<String> emailIdSet =new Set<String>();
        for(User userRecord: UserList)
        {
            emailIdSet.add(userRecord.Email);
        }
        
        List<Contact> contacts=[
            SELECT Id, Name, User__c, Email
            FROM Contact 
            WHERE User__c IN: UserList
            OR
            Email IN: emailIdSet
        ];
        
        Map<Id, Contact> userToContactMap=new Map<Id, Contact>();
        for(Contact eachContact: contacts)
        {
            UserToContactMap.put(eachContact.User__c, eachContact);
        }
        
        return userToContactMap;     
    }
    
    //2016-12-26 - ragashalini.koka@cdk.com - RQ-08369 - Added method to update Top_5__c records when Manager gets updated 
    @future
    private static void updateManagerFieldsOnTop5Records(String oldString, String newString)
    {
        Map<Id,User> oldMap = (Map<Id,User>)JSON.deserialize(oldString, Map<Id,User>.class);
        Map<Id,User> newMap = (Map<Id,User>)JSON.deserialize(newString, Map<Id,User>.class);
        Set<Id> userIdSet = new Set<Id>();
        
        for(Id userId : newMap.keySet())
        {
            if(oldMap.get(userId).ManagerId != newMap.get(userId).ManagerId)
            {
                userIdSet.add(userId);
            }
        }
        
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, ManagerId, Manager.ManagerId FROM User WHERE Id IN :userIdSet]);
        
        Map<Id, Top_5__c> top5Map = new Map<Id, Top_5__c>([
            SELECT Id, OwnerId, Owner_Manager__c, Owner_Manager_Mgr__c 
            FROM Top_5__c 
            WHERE OwnerId IN : userIdSet OR Owner_Manager__c IN : userIdSet
        ]);
        
        for(Id top5Id : top5Map.keySet()) 
        {
            Top_5__c top5Rec = top5Map.get(top5Id);
            
            if(userIdSet.contains(top5Rec.OwnerId))
            {
                top5Rec.Owner_Manager__c = userMap.get(top5Rec.OwnerId).ManagerId;
                top5Rec.Owner_Manager_Mgr__c = userMap.get(top5Rec.OwnerId).Manager.ManagerId;
            }
            else if(userIdSet.contains(top5Rec.Owner_Manager__c)) {
                top5Rec.Owner_Manager_Mgr__c = userMap.get(top5Rec.Owner_Manager__c).ManagerId;
                
            }
        } 
        
        update top5Map.values();
    }
}