//2016-11-09 - lalitha.adduru@cdk.com - created -  RQ-08111
public class ALL_ADPDefaultTeamMembers_Handler 
{
    //lalitha.adduru@cdk.com - when an CDK Default Team Member is inserted, add appropriate Account Teams to Relevant Accounts -  RQ-08111
    public static void addRequiredAccountTeams(List<ADP_Default_Team_Members__c> teamMemberList)
    {
        system.debug('************************ addRequiredAccountTeams started ********************');
        SET<Id> CDK_Default_Team_Ids = new Set<Id>();
        for(ADP_Default_Team_Members__c teamMember : teamMemberList)
        {
            CDK_Default_Team_Ids.add(teamMember.ADP_Default_Team__c);
        }
        
        // Map of CDK Default team to the Accounts that have this team 
        Map<Id, Set<Id>> teamToAccountIdsMap = new Map<Id, Set<Id>>();
        List<Account> accountList = new List<Account>();
        accountList = [
            SELECT Id, CDK_Default_Team__c
            FROM Account WHERE CDK_Default_Team__c in :CDK_Default_Team_Ids
        ];
        
        for(Account relevantAccount : accountList)
        {
            if(!teamToAccountIdsMap.containsKey(relevantAccount.CDK_Default_Team__c))
            {
                teamToAccountIdsMap.put(relevantAccount.CDK_Default_Team__c, new Set<Id>{relevantAccount.Id});
            }
            else
            {
                teamToAccountIdsMap.get(relevantAccount.CDK_Default_Team__c).add(relevantAccount.Id);
            }
        }
        
        // Map that maps an Account to its Account Teams member Ids and a Map that maps account to its account teams with role 'OEM Sales'
        Map<Id, Map<Id, Account_Team__c>> accountToAccountTeamMap = new Map<Id, Map<Id, Account_Team__c>>();
        Map<Id, Map<Id, Account_Team__c>> accountToOEMSalesMap = new Map<Id, Map<Id, Account_Team__c>>();
        Set<Account> accountSet = new Set<Account>();
        accountSet.addAll(accountList);
        accountToAccountTeamMap = ALL_Account_Handler.getAccountToAccountTeamMap(accountSet);
        for(Account requiredAccount : accountList)
        {
            List<Account_Team__c> accountTeams;
            accountTeams = accountToAccountTeamMap.get(requiredAccount.Id) != null ? accountToAccountTeamMap.get(requiredAccount.Id).values() : new List<Account_Team__c>();
            for(Account_Team__c accountTeam : accountTeams)
            {
                if(accountTeam.Team_Role__c == 'OEM Sales')
                {
                    if(accountToOEMSalesMap.containsKey(accountTeam.Account__c))
                    {
                        accountToOEMSalesMap.get(accountTeam.Account__c).put(accountTeam.Team_Member__c, accountTeam);
                    }
                    else
                    {
                        accountToOEMSalesMap.put(accountTeam.Account__c, new Map<Id, Account_Team__c>{accountTeam.Team_Member__c=>accountTeam});
                    }
                }
            }
        }
        system.debug('accountToAccountTeamMap --- >'+accountToAccountTeamMap);
        
        // add new account teams on relevant accounts wherever required
        List<Account_Team__c> accountTeamsToBeInserted = new List<Account_team__c>();
        
        if(teamToAccountIdsMap != null && !teamToAccountIdsMap.isEmpty())
        {
            for(ADP_Default_Team_Members__c teamMember : teamMemberList)
            {
                for(Id relevantAccountId : teamToAccountIdsMap.get(teamMember.ADP_Default_Team__c)==null?new Set<Id>():teamToAccountIdsMap.get(teamMember.ADP_Default_Team__c))
                {
                    Map<Id, Account_Team__c> existingTeamMemberToAccountTeamMap;
                    existingTeamMemberToAccountTeamMap = accountToAccountTeamMap.get(relevantAccountId) == null ? new Map<Id, Account_team__c>() : accountToAccountTeamMap.get(relevantAccountId);
                    if(existingTeamMemberToAccountTeamMap.isEmpty() || !existingTeamMemberToAccountTeamMap.keyset().contains(teamMember.Team_Member__c))
                    {
                        Account_Team__c newAccountTeam = new Account_Team__c();
                        newAccountTeam.Account__c = relevantAccountId;
                        newAccountTeam.Account_Access__c = teamMember.Account_Access__c;
                        newAccountTeam.Opportunity_Access__c = teamMember.Opportunity_Access__c;
                        newAccountTeam.Case_Access__c = teamMember.Account_Access__c;
                        newAccountTeam.Team_Member__c = teamMember.Team_Member__c;
                        newAccountTeam.Team_Role__c = 'OEM Sales';
                        accountTeamsToBeInserted.add(newAccountTeam);
                    }
                }
                
            }
        }
        if(!accountTeamsToBeInserted.isEmpty())
        {
            system.debug('accountTeamsToBeInserted --- >'+accountTeamsToBeInserted);
            insert accountTeamsToBeInserted;
        }
        system.debug('************************ addRequiredAccountTeams ended ********************');
    }
    
    //lalitha.adduru@cdk.com - when an CDK Default Team Member is delete, delete appropriate Account Teams from Relevant Accounts -  RQ-08111
    public static void deleteRelatedAccountTeams(List<ADP_Default_Team_Members__c> teamMemberList)
    {
        system.debug('************** deleteRelatedAccountTeams started ********************');
        List<Account_Team__c> accountTeamsToDelete = new List<Account_Team__c>();
        Set<Id> defaultTeamIds = new Set<Id>();
        Set<Id> teamMemberIds = new Set<Id>();
        system.debug('teamstobedeleted --> '+teamMemberList);
        for(ADP_Default_Team_Members__c teamMember : teamMemberList)
        {
            defaultTeamIds.add(teamMember.ADP_Default_Team__c);
            teamMemberIds.add(teamMember.Team_Member__c);
        }
        accountTeamsToDelete = [
            SELECT Id 
            from Account_Team__c where team_Role__c = 'OEM Sales' and Account__r.CDK_Default_Team__c in :defaultTeamIds and Team_Member__c in :teamMemberIds
        ];
        if(!accountTeamsToDelete.isEmpty())
        {
            delete accountTeamsToDelete;
        }
        system.debug('********************** deleteRelatedAccountTeams ended *****************');
    }
    
    //lalitha.adduru@cdk.com - when an CDK Default Team Member is updated, update/delete appropriate Account Teams on/from Relevant Accounts -  RQ-08111
    public static void updateRequiredAccountTeams(List<ADP_Default_Team_Members__c> newteamMemberList, Map<Id, ADP_Default_Team_Members__c> oldTeamMemberMap)
    {
        system.debug('******************** updateRequiredAccountTeams started *******************');
        Map<Id, Account_Team__c> accountTeamsToUpdate = new Map<Id, Account_Team__c>();
        Map<Id, Account_Team__c> accountTeamsToDelete = new Map<Id,Account_Team__c>();
        List<Account_Team__c> accountTeamsToInsert = new List<Account_Team__c>();
        List<ADP_Default_Team_Members__c> newUserTeamMember = new List<ADP_Default_Team_Members__c>();
        Map<Id, List<Account_Team__c>> memberToAccountTeamsMap = new Map<Id, List<Account_Team__c>>();
        memberToAccountTeamsMap = getMemberToAccountTeamMap(oldTeamMemberMap.values());
        system.debug('****************** memberToAccountTeamsMap ********************** '+memberToAccountTeamsMap);
        Set<Id> CDKDefaultTeamIds = new Set<Id>();
        for(ADP_Default_Team_Members__c teamMember : newteamMemberList)
        {
            CDKDefaultTeamIds.add(teamMember.ADP_Default_Team__c);
        }
        Set<Account> accountSet = new Set<Account>();
        for(List<Account_Team__c> accountTeamList : memberToAccountTeamsMap.values())
        {
            for(Account_Team__c accountTeam : accountTeamList)
            {
                accountSet.add(new Account(Id=accountTeam.Account__c));
            }
        }
		Map<Id, Map<Id, Account_Team__c>> accToTeamMemberMap = new Map<Id, Map<Id, Account_team__c>>();
        accToTeamMemberMap = ALL_Account_Handler.getAccountToAccountTeamMap(accountSet);
        Map<Id,Set<Account>> requiredAccounts = new Map<Id,Set<Account>>();
        requiredAccounts = getTeamToAccountsMap(CDKDefaultTeamIds);
        for(ADP_Default_Team_Members__c teamMember : newteamMemberList)
        {
            for(Account_Team__c accountTeam : memberToAccountTeamsMap.containsKey(teamMember.Id) ? memberToAccountTeamsMap.get(teamMember.Id) : new List<Account_Team__c>())
            {
                if(teamMember.Team_Member__c != oldTeamMemberMap.get(teamMember.Id).Team_Member__c)
                {
                    if(accToTeamMemberMap.get(accountTeam.Account__c)!= null && accToTeamMemberMap.get(accountTeam.Account__c).containsKey(teamMember.Team_Member__c))
                    {
                        accountTeamsToDelete.put(accountTeam.Id, accountTeam);
                    }
                    else
                    {
                        accountTeam.Team_Member__c = teamMember.Team_Member__c;
                    }
                }
                if(!accountTeamsToDelete.containsKey(accountTeam.Id))
                {accountTeam.Account_Access__c = teamMember.Account_Access__c;
                accountTeam.Case_Access__c = teamMember.Account_Access__c;
                accountTeam.Opportunity_Access__c = teamMember.Opportunity_Access__c;
                 accountTeamsToUpdate.put(accountTeam.Id, accountTeam);}
            }
            
            /*if(!memberToAccountTeamsMap.containsKey(teamMember.Id))
            {
                system.debug('member not present');
                for(Account requiredAccount : requiredAccounts.get(teamMember.ADP_Default_Team__c))
                {
                    if(!accToTeamMemberMap.containsKey(requiredAccount.Id) || !accToTeamMemberMap.get(requiredAccount.Id).containsKey(teamMember.Team_Member__c))
                    {
                        Account_Team__c newAccountTeam = new Account_Team__c();
                        newAccountTeam.Account__c = requiredAccount.Id;
                        newAccountTeam.Opportunity_Access__c = teamMember.Opportunity_Access__c;
                        newAccountTeam.Case_Access__c = teamMember.Account_Access__c;
                        newAccountTeam.Account_Access__c = teamMember.Account_Access__c;
                        newAccountTeam.Team_Member__c = teamMember.Team_Member__c;
                        accountTeamsToInsert.add(newAccountTeam);
                    }
                }
            }*/
             
        }
        if(!accountTeamsToInsert.isEmpty())
        {
            insert accountTeamsToInsert;
        }
		if(!accountTeamsToUpdate.isEmpty())
        {
            system.debug('***************** accountTeamsToUpdate ******************** '+accountTeamsToUpdate.values());
            update accountTeamsToUpdate.values();
        }
        if(!accountTeamsToDelete.isEmpty())
        {
            system.debug('***************** accountTeamsToDelete ********************* '+accountTeamsToDelete.values());
            delete accountTeamsToDelete.values();
        }
        system.debug('******************** updateRequiredAccountTeams ended *********************');
    }
    
    //lalitha.adduru@cdk.com - fetch Map of CDK Default Team Member => List of Account Teams created from it -  RQ-08111
    public static Map<Id, List<Account_Team__c>> getMemberToAccountTeamMap(List<ADP_Default_Team_Members__c> teamMemberList)
    {
        system.debug('*********************** getMemberToAccountTeamMap started ********************');
        Map<Id, List<Account_Team__c>> memberToAccountTeamMap = new Map<Id, List<Account_Team__c>>();
        Set<Id> CDKDefaultTeamIds = new Set<Id>();
        Set<Id> teamMemberUserIds = new Set<Id>();
        for(ADP_Default_Team_Members__c teamMember : teamMemberList)
        {
            CDKDefaultTeamIds.add(teamMember.ADP_Default_Team__c);
            teamMemberUserIds.add(teamMember.Team_Member__c);
        }
        List<Account_Team__c> accountTeamList = new List<Account_Team__c>();
        accountTeamList = [
            SELECT Account__r.CDK_Default_Team__c,Account__r.Name, Opportunity_Access__c, Case_Access__c, Account_Access__c, Team_Member__c,Team_Member__r.Name 
            FROM Account_Team__c WHERE Account__r.CDK_Default_Team__c in :CDKDefaultTeamIds and Team_Member__c in :teamMemberUserIds and Team_Role__c = 'OEM Sales'
        ];
        
        for(ADP_Default_Team_Members__c teamMember : teamMemberList)
        {
            for(Account_Team__c accountTeam : accountTeamList)
            {
                if(accountTeam.Team_Member__c == teamMember.Team_Member__c && accountTeam.Account__r.CDK_Default_Team__c == teamMember.ADP_Default_Team__c)
                {
                    if(memberToAccountTeamMap.containsKey(teamMember.Id))
                    {
                        memberToAccountTeamMap.get(teamMember.Id).add(accountTeam);
                    }
                    else
                    {
                        memberToAccountTeamMap.put(teamMember.Id, new List<Account_Team__c>{accountTeam});
                    }
                }
            }
        }
        system.debug('************* getMemberToAccountTeamMap ended *******************');
        return memberToAccountTeamMap;
        
    }
    
    //lalitha.adduru@cdk.com -  get a Map that maps a CDK Default team with a Map of Team_Member__c (user) to ADP_Default_Team_Members__c -  RQ-08111
    //'sampleCDKTeamId'=> ('TeamMemberUserId' => 'CDkDefaultTeamMemberRecord') 
    public static Map<Id, Map<Id, ADP_Default_Team_Members__c>> getDefTeamToTeamMemMap(Set<Id> CDKDefaultTeamIds)
    {
        system.debug('********************** getDefTeamToTeamMemMap started *********************');
        Map<Id, Map<Id, ADP_Default_Team_Members__c>> teamToMembersMap = new Map<Id, Map<Id, ADP_Default_Team_Members__c>>();
        List<ADP_Default_Team_Members__c> teamMembersList = new List<ADP_Default_Team_Members__c>();
        teamMembersList  = [
            SELECT id, ADP_Default_Team__c, Account_Access__c, Opportunity_Access__c, Team_Member__c, Team_Role__c,Title__c 
            FROM ADP_Default_Team_Members__c where ADP_Default_Team__c in :CDKDefaultTeamIds
        ];
        for(ADP_Default_Team_Members__c teamMember : teamMembersList)
        {
            if(teamToMembersMap.containsKey(teamMember.ADP_Default_Team__c))
            {
                teamToMembersMap.get(teamMember.ADP_Default_Team__c).put(teamMember.Team_Member__c,teamMember);
            }
            else
            {
                teamToMembersMap.put(teamMember.ADP_Default_Team__c, new Map<Id,ADP_Default_Team_Members__c>{teamMember.Team_Member__c=>teamMember});
            }
        }
        system.debug('teamToMembersMap --- > '+teamToMembersMap);
        system.debug('***************** getDefTeamToTeamMemMap ended *****************');
        return teamToMembersMap;
    }
    
    public static Map<Id, Set<Account>> getTeamToAccountsMap(Set<Id> CDKDefaultTeamIds)
    {
        system.debug('******************* getDefTeamToTeamMemMap started **********************');
        Map<Id, Set<Account>> teamToAccountsMap = new Map<Id, Set<Account>>();
        List<Account> accountList = new List<Account>();
        accountList = [
            SELECT id, CDK_Default_Team__c
            FROM Account where CDK_Default_Team__c in :CDKDefaultTeamIds
        ];
        for(Account requiredAccount : accountList)
        {
            if(teamToAccountsMap.containsKey(requiredAccount.CDK_Default_Team__c))
            {
                teamToAccountsMap.get(requiredAccount.CDK_Default_Team__c).add(requiredAccount);
            }
            else
            {
                teamToAccountsMap.put(requiredAccount.CDK_Default_Team__c, new Set<Account>{requiredAccount});
            }
        }
        system.debug('********************* getDefTeamToTeamMemMap ended *******************');
        return teamToAccountsMap;
    }
    

}