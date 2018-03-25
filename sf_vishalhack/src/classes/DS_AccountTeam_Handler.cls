/*----------------------------------------------------------
RQ-07305
Description: Trigger handler for DS_AccountTeam
2016-07-15 -venkata.shrivol@cdk.com -Created
---------------------UPDATES--------------------------------
2017-01-30 -venkata.shrivol@cdk.com -added digital advisor roles to skip the forecasting filter on team members
2017-03-27 -ragashalini.koka@cdk.com - added Top 5 Sharing in after insert, update and delete
2017-04-07 -venkata.shrivol@cdk.com	-changed the contact share logic in after insert, update and before delete methods (RQ-08999)
------------------------------------------------------------*/
public class DS_AccountTeam_Handler 
{
    public static String ERROR_MESSAGE ='A user can only appear once in the account team for each account.';
    public static string DIGITAL_ADVISOR_ROLES = CustomSettings__c.getOrgDefaults().Digitial_Advisor_Roles__c;
    public static void beforeInsert(list<Account_Team__c> accountTeam)
    {
        for(Account_Team__c act:accountTeam)
        {
            act.Account_User_Id__c = (String)act.Account__c + (string)act.Team_Member__c;
        }
        
        List<Account_Team_History__c> AccountTeamHistoryInserts=new List<Account_Team_History__c>();
        
        list<AccountTeamMember> accountMembers=DS_CreateSForceSalesTeam.insertAccountTeam(accountTeam, null);
        
        Map <ID,ID> existingStdATMS=new Map <ID,ID>();
        system.debug('----accountMembers-----'+accountMembers);
        if(accountMembers.size() > 0)
        {
            for(Integer x=0; x<accountTeam.size(); x++)
            {
                if(accountMembers.size() > x)
                {
                    if(existingStdATMS.get(accountMembers.get(x).Id)==null)
                    {
                        accountTeam.get(x).SForce_Account_Team_Id__c=accountMembers.get(x).Id;
                        existingStdATMS.put(accountMembers.get(x).Id, accountMembers.get(x).Id);
                    }
                    else
                    {
                        accountTeam.get(x).SForce_Account_Team_Id__c=null;
                    } 
                    
                    //x++;
                    
                    // 2012-01-31 Matt Keefe - Added Account Team History logging (for inserts)
                    // 2012-03-14 Matt Keefe - Added contains forcasting condition for inserts
                    if(accountTeam.get(x).Team_Role__c.toLowerCase().contains('forecasting'))
                    {
                        Account_Team_History__c ath=new Account_Team_History__c(
                            Team_Role__c=accountTeam.get(x).Team_Role__c,
                            Team_Member__c=accountTeam.get(x).Team_Member__c,
                            Date_of_Action__c=Date.today(),
                            Action__c='Insert',
                            Account__c=accountTeam.get(x).Account__c
                        ); AccountTeamHistoryInserts.add(ath);
                    }
                }
            }
        }
        //duplicateCheckOnAccountTeam(accountTeam, null); 
        try
        {
            insert AccountTeamHistoryInserts;
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }   
    }
    public static void beforeUpdate(list<Account_Team__c> accountTeam, list<Account_Team__c> oldAccountTeam)
    {
        for(Account_Team__c act:accountTeam)
        {
            act.Account_User_Id__c = (String)act.Account__c + (string)act.Team_Member__c;
        }
        DS_CreateSForceSalesTeam.deleteAccountTeam(accountTeam);
        list<AccountTeamMember> accountMembers=DS_CreateSForceSalesTeam.insertAccountTeam(accountTeam, null);	
        
        for(Integer x=0; x<accountTeam.size(); x++)
        {
            if(accountMembers.size() > x)
            {
                accountTeam.get(x).SForce_Account_Team_Id__c=accountMembers.get(x).Id;	
            }
            
            //x++;
        }
        //duplicateCheckOnAccountTeam(accountTeam, oldAccountTeam);
        
    }
    public static void beforeDelete(list<Account_Team__c> oldAccountTeam)
    {
        List<Account_Team_History__c> AccountTeamHistoryDeletes=new List<Account_Team_History__c>();
        
        set<Id> userIdsToDeleteShare = new set<Id>();
        set<Id> accountIds = new set<Id>();
        //Delete the standard salesforce sales team member(s)
        DS_CreateSForceSalesTeam.deleteAccountTeam(oldAccountTeam);
        
        // 2012-01-31 Matt Keefe - Added Account Team History logging (for deletes)
        // log a record of this action in the Account Team History object
        for(Account_Team__c member : oldAccountTeam)
        {
            if(member.Team_Role__c.toLowerCase().contains('forecasting'))
            {
                Account_Team_History__c ath=new Account_Team_History__c(
                    Team_Role__c=member.Team_Role__c,
                    Team_Member__c=member.Team_Member__c,
                    Date_of_Action__c=Date.today(),
                    Action__c='Delete',
                    Account__c=member.Account__c
                ); 
                AccountTeamHistoryDeletes.add(ath);
            }
            if(member.Sales_Roles__c == true || ( DIGITAL_ADVISOR_ROLES!=null ? DIGITAL_ADVISOR_ROLES.contains(member.Team_Role__c) : false) )
            {
                userIdsToDeleteShare.add(member.Team_Member__c);
                accountIds.add(member.Account__c);
            }
        }
        // if(UserInfo.getProfileId() !=CustomSettings__c.getInstance().Profile_Id__c)
        //{
        if(!accountIds.isEmpty())
        {
        	set<Id> contactIds = new set<Id>();
            ALL_InsertContactShare_Helper.sharingResult resultIdsToDeleteShare = ALL_InsertContactShare_Helper.prepareShareIds(accountIds);
            for(Id accountId:accountIds)
            {
            	if(resultIdsToDeleteShare.sharingIdMap.containsKey(accountId))
            	{
            		contactIds.addAll(resultIdsToDeleteShare.sharingIdMap.get(accountId));	
            	}
            	
            }
            system.debug('-----contactIds--------'+contactIds);
            ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIdsToDeleteShare,'ContactId', contactIds);
        }
        // }
        try
        {
            insert AccountTeamHistoryDeletes;
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }	
    }
    public static void afterInsert(list<Account_Team__c> accountTeam)
    {
        set<Id> accountIds = new set<Id>();
        set<Id> userOrGroupIds = new set<Id>();
        map<Id, set<Id>> accountIdsToMemberIds = new map<Id, set<Id>>();
        for(Account_Team__c act:accountTeam)
        {
            if(act.Sales_Roles__c == true || ( DIGITAL_ADVISOR_ROLES!=null ? DIGITAL_ADVISOR_ROLES.contains(act.Team_Role__c) : false))
            {
                set<Id> memberIds = accountIdsToMemberIds.containsKey(act.Account__c) ?
    								 accountIdsToMemberIds.get(act.Account__c) : 
    								 new set<Id>();
    			memberIds.add(act.Team_Member__c);
    			accountIdsToMemberIds.put(act.Account__c, memberIds);
                accountIds.add(act.Account__c);
                //userOrGroupIds.add(act.Team_Member__c);
            }
        }
        system.debug('------accountIdsToMemberIds-------->'+accountIdsToMemberIds);
        if(!accountIdsToMemberIds.isEmpty())
        {
            ALL_InsertContactShare_Helper.sharingResult resultIdsToShare = ALL_InsertContactShare_Helper.prepareShareIds(accountIdsToMemberIds.keySet());
	    	
	    	ALL_InsertContactShare_Helper.insertContactShare(resultIdsToShare.sharingIdMap, accountIdsToMemberIds,resultIdsToShare.ownerMapIdsToRemove, false);
	    	
	    	//TOP 5 records sharing.
            Map<Id,Set<Id>> accIdToAccTeamIdMap = getAccountToAccountTeamMap(accountTeam);
            ALL_InsertTop5Share_Helper.Top5Info top5InfoRec = ALL_InsertTop5Share_Helper.getTop5RecordsInfo(accountIds);
            ALL_InsertTop5Share_Helper.insertTop5Share(accIdToAccTeamIdMap, top5InfoRec.top5IdToAccIdMap, top5InfoRec.top5IdToOwnerIdMap);
        }
        
    }
    //2017-04-14 -venkata.shrivol@cdk.com - commented the after update logic as no act mem will ever be updated
    public static void afterUpdate(list<Account_Team__c> accountTeam, map<Id, Account_Team__c> oldAccountTeamMap)
    {
        /*set<Id> accIdsToBeDeleted = new set<Id>();
        set<Id> accIdsToBeInserted = new set<Id>();
        set<Id> userIds = new set<Id>();
        
        set<Id> userIdsToInsert = new set<Id>();
        set<Id> userIDsToDelete = new set<Id>();
        set<Id> accountIds = new set<Id>();
        
        for(Account_Team__c act:accountTeam)
        {
            Account_Team__c oldAccTeam = oldAccountTeamMap.get(act.Id);
            if(act.Account__c != oldAccTeam.Account__c && act.Team_Member__c != oldAccTeam.Team_Member__c)
            {
                accIdsToBeDeleted.add(oldAccTeam.Account__c);
                accIdsToBeInserted.add(act.Account__c);
                userIdsToInsert.add(act.Team_Member__c);
                userIDsToDelete.add(oldAccTeam.Team_Member__c);
            }
            else if(act.Account__c != oldAccTeam.Account__c)
            {
                accIdsToBeDeleted.add(oldAccTeam.Account__c);
                accIdsToBeInserted.add(act.Account__c);
                userIds.add(act.Team_Member__c);
            }
            else if(act.Team_Member__c != oldAccTeam.Team_Member__c)
            {
                userIdsToInsert.add(act.Team_Member__c);
                userIDsToDelete.add(oldAccTeam.Team_Member__c);
                accountIds.add(act.Account__c);
            }    			
        }
        if(!accIdsToBeDeleted.isEmpty())
        {
            ALL_InsertContactShare_Helper.sharingResult resultIdsToDeleteShare = ALL_InsertContactShare_Helper.prepareShareIds(accIdsToBeDeleted);
            ALL_InsertContactShare_Helper.sharingResult resultIdsToShare = ALL_InsertContactShare_Helper.prepareShareIds(accIdsToBeInserted);
            if(!userIds.isEmpty())
            {
                userIds.removeAll(resultIdsToDeleteShare.ownerIdsToRemove);
                ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIds, 'ContactId',resultIdsToDeleteShare.sharingIds);
                userIds.addAll(resultIdsToDeleteShare.ownerIdsToRemove);
                userIds.removeAll(resultIdsToShare.ownerIdsToRemove);
                ALL_InsertContactShare_Helper.insertContactShare(resultIdsToShare.sharingIds, userIds, false);
            }
            else
            {
                userIDsToDelete.removeAll(resultIdsToDeleteShare.ownerIdsToRemove);
                ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIDsToDelete, 'ContactId',resultIdsToDeleteShare.sharingIds);
                userIdsToInsert.removeAll(resultIdsToShare.ownerIdsToRemove);
                ALL_InsertContactShare_Helper.insertContactShare(resultIdsToShare.sharingIds, userIdsToInsert, false);
            }
        }
        if(!userIDsToDelete.isEmpty() && !accountIds.isEmpty())
        {
            ALL_InsertContactShare_Helper.sharingResult resultIdsToShare  = ALL_InsertContactShare_Helper.prepareShareIds(accountIds);
            userIDsToDelete.removeAll(resultIdsToShare.ownerIdsToRemove);
            ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIDsToDelete, 'ContactId', resultIdsToShare.sharingIds);
            userIdsToInsert.removeAll(resultIdsToShare.ownerIdsToRemove);
            ALL_InsertContactShare_Helper.insertContactShare(resultIdsToShare.sharingIds, userIdsToInsert, false);
        }*/
        manageSharingOnTop5(accountTeam, oldAccountTeamMap);
    }
    /* public static void duplicateCheckOnAccountTeam(list<Account_Team__c> accountTeam, list<Account_Team__c> oldAccountTeam)
{
Set<String> parentAccounts=new Set<String>();

for (Account_Team__c sTeamMember:accountTeam)
{
parentAccounts.add(sTeamMember.Account__c);
}

Map<String,String> acctTeam=new Map<String,String>();
List<Account_Team__c> accountTeamAll=[select Team_Member__c, Account__c from Account_Team__c where Account__c in :parentAccounts];

for(Account_Team__c teamMember:accountTeamAll)
{
String temp=acctTeam.get(teamMember.Account__c);

if(temp == null)
{
acctTeam.put(teamMember.Account__c,teamMember.Team_Member__c);
}
else
{
acctTeam.remove(teamMember.Account__c);
acctTeam.put(teamMember.Account__c,temp+teamMember.Team_Member__c);
}
}

for(Integer x=0; x<accountTeam.size(); x++)
{
system.debug('Set to null if in the same batch it has existing users: accountTeam.get(x).SForce_Account_Team_Id__c:'+accountTeam.get(x).SForce_Account_Team_Id__c);
String acctId=acctTeam.get(accountTeam[x].Account__c);

if(Trigger.isInsert)
{
if(acctId != null)
{
if(accountTeam[x].SForce_Account_Team_Id__c != null)
{
if(acctId.indexOf(accountTeam[x].Team_Member__c) != -1)
{
accountTeam[x].Team_Member__c.addError(ERROR_MESSAGE);					
}
}
else //In case of accounts with existing account teams
{
accountTeam[x].Team_Member__c.addError(ERROR_MESSAGE);
}
}
else //if no existing account teams
{
system.debug('---AccountTeamCheckpoingt---1');
if(accountTeam[x].SForce_Account_Team_Id__c == null)
{
accountTeam[x].Team_Member__c.addError(ERROR_MESSAGE);
}
}
}

if(Trigger.isUpdate)
{
if(acctId!=null)
{
if(acctId.indexOf(accountTeam[x].Team_Member__c)!=-1 && accountTeam[x].Team_Member__c!=oldAccountTeam[x].Team_Member__c)
{
system.debug('---AccountTeamCheckpoingt---4');
accountTeam[x].Team_Member__c.addError(ERROR_MESSAGE);					
}
}
}

} // End for	
}*/
    
    private static void manageSharingOnTop5(List<Account_Team__c> accountTeam, Map<Id,Account_Team__c> oldAccountTeamMap)
    {
        Set<Id> accIdsToBeDeleted = new Set<Id>();
        Set<Id> accIdsToBeInserted = new Set<Id>();
        Set<Id> userIdsToBeDeleted = new Set<Id>();
        Set<Id> userIdsToBeInserted = new Set<Id>();
        for(Account_Team__c team : accountTeam)
        {
            Account_Team__c oldAccTeam = oldAccountTeamMap.get(team.Id);
            
            if(team.Team_Role__c.startsWithIgnoreCase('Forecasting')) 
            {
                if(team.Account__c != oldAccTeam.Account__c )
                {
                    accIdsToBeDeleted.add(oldAccTeam.Account__c);
                    accIdsToBeInserted.add(team.Account__c);
                    userIdsToBeDeleted.add(oldAccTeam.Team_Member__c);
                    userIdsToBeInserted.add(team.Team_Member__c);
                }
                else if(team.Team_Member__c != oldAccTeam.Team_Member__c)
                {
                    userIdsToBeDeleted.add(oldAccTeam.Team_Member__c);
                    userIdsToBeInserted.add(team.Team_Member__c);
                    accIdsToBeDeleted.add(oldAccTeam.Account__c);
                    accIdsToBeInserted.add(team.Account__c);
                }
                else if(team.Team_Role__c != oldAccTeam.Team_Role__c && !oldAccTeam.Team_Role__c.startsWithIgnoreCase('Forecasting')) 
                {
                    accIdsToBeInserted.add(team.Account__c);
                    userIdsToBeInserted.add(team.Team_Member__c);
                }
            }
            else
            {
                if(oldAccTeam.Team_Role__c.startsWithIgnoreCase('Forecasting')) 
                {
                    accIdsToBeDeleted.add(oldAccTeam.Account__c);
                    userIdsToBeDeleted.add(oldAccTeam.Team_Member__c);
                }
            }
          
        }
         ALL_InsertTop5Share_Helper.deleteManualShare('Top_5__Share', 'ParentId', ALL_InsertTop5Share_Helper.getTop5RecordsInfo(accIdsToBeDeleted).top5IdToAccIdMap.keySet(),
                                                    'UserOrGroupId', userIdsToBeDeleted);
        Map<Id,Set<Id>> accIdToAccTeamIdMap = getAccountToAccountTeamMap(accountTeam);
        ALL_InsertTop5Share_Helper.Top5Info top5InfoRec = ALL_InsertTop5Share_Helper.getTop5RecordsInfo(accIdsToBeInserted);
        System.debug('accIdToAccTeamIdMap : ' + accIdToAccTeamIdMap);
        ALL_InsertTop5Share_Helper.insertTop5Share(accIdToAccTeamIdMap, top5InfoRec.top5IdToAccIdMap, top5InfoRec.top5IdToOwnerIdMap);
        
    }
    
    public static void afterDelete(List<Account_Team__c> accTeamList)
    {
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        for(Account_Team__c team : accTeamList)
        {
            accIdSet.add(team.Account__c);
            userIdSet.add(team.Team_Member__c);
        }
       ALL_InsertTop5Share_Helper.deleteManualShare('Top_5__Share', 'ParentId', ALL_InsertTop5Share_Helper.getTop5RecordsInfo(accIdSet).top5IdToAccIdMap.keySet(),
                                                    'UserOrGroupId', userIdSet);
    }
    public static Map<Id,Set<Id>> getAccountToAccountTeamMap(List<Account_Team__c> accountTeamList) 
    {
        Map<Id,Set<Id>> accountToTeamIdMap = new Map<Id,Set<Id>>();
        for(Account_Team__c team : accountTeamList)
        {
            if(team.Team_Role__c.startsWithIgnoreCase('Forecasting')) {
                Id accId = team.Account__c;
                if(!accountToTeamIdMap.containsKey(accId)) 
                {
                    accountToTeamIdMap.put(accId, new Set<Id>());
                }
                Set<Id> teamIdSet = accountToTeamIdMap.get(accId);
                teamIdSet.add(team.Team_Member__c);
            }
        }
        return accountToTeamIdMap;
    }
}