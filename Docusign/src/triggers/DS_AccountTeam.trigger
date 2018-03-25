trigger DS_AccountTeam on Account_Team__c (before insert, before update, before delete) 
{
	List<Account_Team__c> accountTeam = Trigger.new;
	List<Account_Team__c> oldAccountTeam = Trigger.old;
	List<AccountTeamMember> accountMembers;
	
	// 2012-03-07 MK - split out deletes and inserts
	List<Account_Team_History__c> AccountTeamHistoryDeletes = new List<Account_Team_History__c>();
	List<Account_Team_History__c> AccountTeamHistoryInserts = new List<Account_Team_History__c>();
	
	String errorMessage='A user can only appear once in the account team for each account.';
	DS_CreateSForceSalesTeam sForceSalesTeam = new DS_CreateSForceSalesTeam();
	
	if(Trigger.isDelete)
	{
		//Delete the standard salesforce sales team member(s)
		sForceSalesTeam.deleteAccountTeam(oldAccountTeam);
		
		// 2012-01-31 Matt Keefe - Added Account Team History logging (for deletes)
		// log a record of this action in the Account Team History object
		for(Account_Team__c member : oldAccountTeam)
		{
			if(member.Team_Role__c.toLowerCase().contains('forecasting'))
			{
				Account_Team_History__c ath = new Account_Team_History__c(
					Team_Role__c = member.Team_Role__c,
					Team_Member__c = member.Team_Member__c,
					Date_of_Action__c = Date.today(),
					Action__c = 'Delete',
					Account__c = member.Account__c
				); AccountTeamHistoryDeletes.add(ath);
			}
		}
	}
	
	//Insert the standard salesforce sales team member(s)
	if(Trigger.isInsert)
	{
		accountMembers = sForceSalesTeam.insertAccountTeam(accountTeam);
		
		system.debug('Account Team inserted:'+accountTeam);
		system.debug('Number of Account Team inserted:'+accountTeam.size());
		system.debug('New Account Team inserted:'+accountMembers);
		system.debug('Number of New Account Team inserted:'+accountMembers.size());
		
		Map <ID,ID> existingStdATMS = new Map <ID,ID>();
		
		for(Integer x=0; x<accountTeam.size(); x++)
		{
			System.debug('Iteration:'+x+': accountMembers.get(x).Id:'+accountMembers.get(x).Id);
			
			if(existingStdATMS.get(accountMembers.get(x).Id)==null)
			{
				accountTeam.get(x).SForce_Account_Team_Id__c = accountMembers.get(x).Id;
				existingStdATMS.put(accountMembers.get(x).Id, accountMembers.get(x).Id);
			}
			else
			{
				accountTeam.get(x).SForce_Account_Team_Id__c = null;
			}
			
			System.debug('**Iteration:'+x+': accountTeam.get(x).SForce_Account_Team_Id__c:'+accountTeam.get(x).SForce_Account_Team_Id__c);
			
			//x++;
			
			// 2012-01-31 Matt Keefe - Added Account Team History logging (for inserts)
			// 2012-03-14 Matt Keefe - Added contains forcasting condition for inserts
			if(accountTeam.get(x).Team_Role__c.toLowerCase().contains('forecasting'))
			{
				Account_Team_History__c ath = new Account_Team_History__c(
					Team_Role__c = accountTeam.get(x).Team_Role__c,
					Team_Member__c = accountTeam.get(x).Team_Member__c,
					Date_of_Action__c = Date.today(),
					Action__c = 'Insert',
					Account__c = accountTeam.get(x).Account__c
				); AccountTeamHistoryInserts.add(ath);
			}
		}
	}
	
	//Update the standard salesforce account team by deleting then inserting the records
	if(Trigger.isUpdate)
	{
		sForceSalesTeam.deleteAccountTeam(accountTeam);
		accountMembers = sForceSalesTeam.insertAccountTeam(accountTeam);	
		
		for(Integer x=0; x<accountTeam.size(); x++)
		{
			accountTeam.get(x).SForce_Account_Team_Id__c = accountMembers.get(x).Id;	
			//x++;
		}
	}
	
	if(Trigger.isInsert || Trigger.isUpdate)
	{
		Set<String> parentAccounts = new Set<String>();
		
		for (Account_Team__c sTeamMember:accountTeam) {
			parentAccounts.add(sTeamMember.Account__c); }   
		
		system.debug('ParentAccount:'+parentAccounts);
		
		Map<String,String> acctTeam = new Map<String,String>();
		List<Account_Team__c> accountTeamAll = [select Team_Member__c, Account__c from Account_Team__c where Account__c in :parentAccounts];
		
		for(Account_Team__c teamMember:accountTeamAll)
		{
			String temp = acctTeam.get(teamMember.Account__c);
			system.debug('temp:'+temp);
			system.debug('acctTeam1:'+acctTeam);
	 		
			if(temp == null)
			{
				acctTeam.put(teamMember.Account__c,teamMember.Team_Member__c);
			}
			else
			{
				acctTeam.remove(teamMember.Account__c);
				acctTeam.put(teamMember.Account__c,temp+teamMember.Team_Member__c);
			}
			
			system.debug('acctTeam2:'+acctTeam);
		}
		
	 	system.debug('acctTeam Final:'+acctTeam);
	 	
		for(Integer x=0; x<accountTeam.size(); x++)
		{
			system.debug('Set to null if in the same batch it has existing users: accountTeam.get(x).SForce_Account_Team_Id__c:'+accountTeam.get(x).SForce_Account_Team_Id__c);
			String acctId = acctTeam.get(accountTeam[x].Account__c);
			
			system.debug('acctId:'+acctId);
			system.debug('accountTeam[x].Team_Member__c:'+accountTeam[x].Team_Member__c);
			
			if(Trigger.isInsert)
			{
				if(acctId != null)
				{
					if(accountTeam[x].SForce_Account_Team_Id__c != null)
					{
						if(acctId.indexOf(accountTeam[x].Team_Member__c) != -1)
						{
							accountTeam[x].Team_Member__c.addError(errorMessage);					
						}
						
						system.debug('accountTeam[x].Team_Member__c:' + accountTeam[x].Team_Member__c);
					}
					else //In case of accounts with existing account teams
					{
						accountTeam[x].Team_Member__c.addError(errorMessage);
					}
				}
				else //if no existing account teams
				{
					if(accountTeam[x].SForce_Account_Team_Id__c == null) {
						accountTeam[x].Team_Member__c.addError(errorMessage); }
					
					system.debug('Adding error as the user exists');
				}
			}
			
			if(Trigger.isUpdate)
			{
				if(acctId!=null)
				{
					if(acctId.indexOf(accountTeam[x].Team_Member__c)!=-1 && accountTeam[x].Team_Member__c!=oldAccountTeam[x].Team_Member__c)
					{
						accountTeam[x].Team_Member__c.addError(errorMessage);					
					}
				}
			}
			
		} // End for
	}
	
	try { insert AccountTeamHistoryDeletes; } catch (Exception ex) { system.debug(ex); }
	try { insert AccountTeamHistoryInserts; } catch (Exception ex) { system.debug(ex); }
}