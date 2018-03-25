public class DS_CreateSForceSalesTeam {
	public List<OpportunityTeamMember> insertSForceSalesTeam(List<Sales_Team__c> salesTeam){
		
		List<Id> opportunities = new List<Id>();
		for(Sales_Team__c st:salesTeam){
			opportunities.add(st.Opportunity__c);
		}
		
		Map<Id,Opportunity> opportunityOwners = new Map<Id,Opportunity>([select Id, OwnerId,Owner.IsActive from Opportunity where Id in :opportunities]);
		
		OpportunityTeamMember temp;
		OpportunityShare oppShare;
		List<OpportunityShare> opportunityShareList = new List<OpportunityShare>();
		List<OpportunityTeamMember> opportunityMembers = new List<OpportunityTeamMember>();
		for(Sales_Team__c teamMember:salesTeam){
			// CN 3/17 add only if it is present in oppOwners
			temp = new OpportunityTeamMember();
			temp.UserId=teamMember.User__c;
			temp.TeamMemberRole=teamMember.Team_Role__c;
			temp.OpportunityId=teamMember.Opportunity__c;
			temp.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
			System.debug('OA: '+teamMember.Opportunity_Access__c);
			System.debug('OA: '+returnPickVal(teamMember.Opportunity_Access__c));
			System.debug('OA: '+temp.OpportunityAccessLevel);
			System.debug('OA: '+temp);
			
			opportunityMembers.add(temp);
			System.debug('OA: '+opportunityMembers);
		
			oppShare = new OpportunityShare();
			oppShare.UserOrGroupId=teamMember.User__c;
			oppShare.OpportunityId=teamMember.Opportunity__c;
			
			oppShare.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
			
			if(opportunityOwners.get(teamMember.Opportunity__c)!=null && teamMember.User__c!=opportunityOwners.get(teamMember.Opportunity__c).OwnerId){
				
				opportunityShareList.add(oppShare);
			}
			else if(!opportunityOwners.get(teamMember.Opportunity__c).Owner.isActive)
			{
				opportunityShareList.add(oppShare);
				
			}
		}
		if(opportunityMembers.size()>0){
			insert opportunityMembers;
		}
		if(opportunityShareList.size()>0){
			insert opportunityShareList;	
		}

		return opportunityMembers;
	}
	public void deleteSForceSalesTeam(List<Sales_Team__c> salesTeam){
		Set<String> teamMembers = new Set<String>();
		for(Sales_Team__c teamMember:salesTeam){
			teamMembers.add(teamMember.SForce_Sales_Team_Id__c);		
		}
	
		List<OpportunityTeamMember> opportunityMembers = [select Id from OpportunityTeamMember where Id in :teamMembers];
		
		delete opportunityMembers;
	}
	public List<AccountTeamMember> insertAccountTeam(List<Account_Team__c> accountTeam){
		AccountTeamMember temp;
		AccountShare tempAccountShare;
		
		List<AccountShare> accountShareList = new List<AccountShare>();
		List<AccountTeamMember> accountMembers = new List<AccountTeamMember>();
		Set<Id> accounts = new Set<Id>();
		for(Account_Team__c tm:accountTeam){
			accounts.add(tm.Account__c);
		}

		Map<Id,Account> accountOwners = new Map<Id,Account>([select Id, OwnerId from Account where Id in :accounts]);
		
		for(Account_Team__c teamMember:accountTeam){
			temp = new AccountTeamMember();
			temp.UserId=teamMember.Team_Member__c;
			temp.TeamMemberRole=teamMember.Team_Role__c;
			temp.AccountId=teamMember.Account__c;
			temp.AccountAccessLevel=teamMember.Account_Access__c; system.debug(teamMember.Account_Access__c);

			accountMembers.add(temp);
			
			System.debug(teamMember.Team_Member__c+'=='+accountOwners.get(teamMember.Account__c).OwnerId);
			if(teamMember.Team_Member__c!=accountOwners.get(teamMember.Account__c).OwnerId){
				tempAccountShare=new AccountShare();
				tempAccountShare.UserOrGroupId=teamMember.Team_Member__c;
				tempAccountShare.AccountId=teamMember.Account__c;
				
				tempAccountShare.AccountAccessLevel=returnPickVal(teamMember.Account_Access__c);
				tempAccountShare.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
				tempAccountShare.CaseAccessLevel=returnPickVal(teamMember.Case_Access__c);
				accountShareList.add(tempAccountShare); 
			}
		}
		
		if(accountMembers.size()>0){
			system.debug(accountMembers);
			insert accountMembers;
		}
		if(accountShareList.size()>0){
			system.debug(accountShareList);
			insert accountShareList;	
		}
		
		return accountMembers;
	}
	public void deleteAccountTeam(List<Account_Team__c> accountTeam){
		Set<String> teamMembers = new Set<String>();
		for(Account_Team__c teamMember:accountTeam){
			teamMembers.add(teamMember.SForce_Account_Team_Id__c);		
		}
	
		List<AccountTeamMember> accountMembers = [select Id from AccountTeamMember where Id in :teamMembers];
		
		if(accountMembers.size()>0){
			delete accountMembers;
		}
	}
	public String returnPickVal(String val){
		if(val=='Private') return 'None';
		else if(val=='Read Only') return 'Read';
		else if(val=='Read/Write') return 'Edit';	
		
		return 'None';
	}
}