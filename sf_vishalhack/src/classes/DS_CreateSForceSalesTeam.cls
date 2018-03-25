//2015-11-09- anirudh.singh@cdk.com- Modified the API Version from 10.0 to 34.0.
//2016-07-21 - venkata.shrivol@cdk.com -Modified this class as a part of RQ-07305
public class DS_CreateSForceSalesTeam
{
    public static List<OpportunityTeamMember> insertSForceSalesTeam(List<Sales_Team__c> salesTeam)
    {
        set<Id> opportunities=new set<Id>();
        set<Id> userIds = new set<Id>();
        for(Sales_Team__c st: salesTeam)
        {
            opportunities.add(st.Opportunity__c);
            userIds.add(st.User__c);
        }
        
        Map<Id, Opportunity> opportunityOwners=new Map<Id, Opportunity>([SELECT Id, OwnerId, Owner.IsActive FROM Opportunity WHERE Id IN :opportunities]);
        
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //OpportunityTeamMember temp;
        
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //OpportunityShare oppShare;
        List<OpportunityShare> opportunityShareList=new List<OpportunityShare>();
        List<OpportunityTeamMember> opportunityMembers=new List<OpportunityTeamMember>();
        map<string, Sales_Team__c> insertingSalesTeam = new map<String, Sales_team__c>();
        
        for(Sales_Team__c teamMember: salesTeam)
        {
            // CN 3/17 add only if it is present in oppOwners
            //2015-11-09- anirudh.singh@cdk.com- Earlier temp was declared outside this For Loop.
            //if(opportunityOwners.get(teamMember.Opportunity__c)!=null && teamMember.User__c!=opportunityOwners.get(teamMember.Opportunity__c).OwnerId)
            //{
            	OpportunityTeamMember temp=new OpportunityTeamMember();
	            temp=new OpportunityTeamMember();
	            temp.UserId=teamMember.User__c;
	            temp.TeamMemberRole=teamMember.Team_Role__c;
	            temp.OpportunityId=teamMember.Opportunity__c;
	            //2015-11-09- anirudh.singh@cdk.com- Commented the below line.
	            //temp.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
	            opportunityMembers.add(temp);
	            String keyValue = (String)teamMember.Opportunity__c+(string)teamMember.User__c;
	        	insertingSalesTeam.put(keyValue, teamMember);
            
            //}
            
            //2016-07-21 -venkata.shrivol@cdk.com -Commented this code out as we no longer needed manual share records.
            //2016-02-10- anirudh.singh@cdk.com- Added the IF Block to prevent the record insertion if the value of Opportunity_Access__c is Private or Null or Blank.
            /*if(teamMember.Opportunity_Access__c!='Private' && teamMember.Opportunity_Access__c!=Null && teamMember.Opportunity_Access__c!='')
            {
                //2015-11-09- anirudh.singh@cdk.com- Earlier oppShare was declared outside this For Loop.
                OpportunityShare oppShare=new OpportunityShare();
                oppShare.UserOrGroupId=teamMember.User__c;
                oppShare.OpportunityId=teamMember.Opportunity__c;
                oppShare.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
                
                if()
                {
                    opportunityShareList.add(oppShare);
                }
                else if(!opportunityOwners.get(teamMember.Opportunity__c).Owner.isActive)
                {
                    opportunityShareList.add(oppShare);
                }
            }*/
        }
        if(opportunityMembers.size()>0)
        {
            //lalitha.adduru@cdk.com - added try catch block for RQ-05118
            try
            {
            	//2016-07-14 -venkata.shrivol@cdk.com -changed insertDML statement to DML Method
                Database.insert(opportunityMembers, false);
            }
            catch(Exception ex)
            {
                system.debug(ex.getMessage() + ' at '+ex.getLineNumber());
            }
            
            //2016-07-21 -venkata.shrivol@cdk.com -Added this snippet of code to update the accountTeam shared records.
            //Needed this update call because you can't assign these fields directly on account team insertion
            list<OpportunityShare> insertedSharedRecs = 
        	[select Id, UserOrGroupId, OpportunityId from OpportunityShare 
        	 where RowCause = 'Team' 
        	 and UserOrGroupId IN :userIds
        	 and OpportunityId IN: opportunities
	        ];
	        list<OpportunityShare> oppSharesToUpdate = new list<OpportunityShare>();
	        for(OpportunityShare opp:insertedSharedRecs)
	        {
	        	Sales_Team__c thisSalesTeam = insertingSalesTeam.get((String)opp.OpportunityId+(string)opp.UserOrGroupId);
	        	if(thisSalesTeam !=null )
	        	{
	        		opp.OpportunityAccessLevel = returnPickVal(thisSalesTeam.Opportunity_Access__c);
	        		oppSharesToUpdate.add(opp);
	        	}
	        	
	        }
	        Database.update(oppSharesToUpdate, false);
	    }
        
        
       /* if(opportunityShareList.size()>0)
        {
            //lalitha.adduru@cdk.com - added try catch block for RQ-05118
            try
            {
                insert opportunityShareList;
            }
            catch(Exception ex)
            {
                system.debug(ex.getMessage() + ' at '+ex.getLineNumber());
            }

        }*/
        
        return opportunityMembers;
    }
    
    public static void deleteSForceSalesTeam(List<Sales_Team__c> salesTeam)
    {
        Set<String> teamMembers=new Set<String>();
        
        for(Sales_Team__c teamMember: salesTeam)
        {
            teamMembers.add(teamMember.SForce_Sales_Team_Id__c);		
        }
        
        List<OpportunityTeamMember> opportunityMembers=[SELECT Id FROM OpportunityTeamMember WHERE Id IN :teamMembers];
        
        //2015-11-09- anirudh.singh@cdk.com- Added The IF Block to check Null and size greater than zero.
        if(opportunityMembers!=Null && opportunityMembers.size()>0)
        {
        	//2016-07-14 -venkata.shrivol@cdk.com -changed insertDML statement to DML Method
            Database.delete(opportunityMembers, false);
        }
    }
    
    public static List<AccountTeamMember> insertAccountTeam(List<Account_Team__c> accountTeam, map<Id, Account_Team__c> newMap)
    {
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //AccountTeamMember temp;
        
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //AccountShare tempAccountShare;
        
        List<AccountShare> accountShareList=new List<AccountShare>();
        List<AccountTeamMember> accountMembers=new List<AccountTeamMember>();
        Set<Id> accounts=new Set<Id>();
        set<ID> userIds = new set<Id>();
        
        for(Account_Team__c tm:accountTeam)
        {
            accounts.add(tm.Account__c);
            userIds.add(tm.Team_Member__c);
        }
        
        //new map<accountId, map<userId, accountTeam>>
        map<string, Account_Team__c> myAccountTeam = new map<string, Account_Team__c>();
        Map<Id, Account> accountOwners=new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accounts]);
        
        for(Account_Team__c teamMember: accountTeam)
        {
        	//2016-07-26 -venkata.shrivol@cdk.com -commented the below if block to include the account owner as a team member also
            //2015-11-09- anirudh.singh@cdk.com- Earlier temp was declared outside this For Loop.
            //if(accountOwners.get(teamMember.Account__c)!=null && teamMember.Team_Member__c!=accountOwners.get(teamMember.Account__c).OwnerId)
            //{
            	AccountTeamMember temp=new AccountTeamMember();
	            temp.UserId=teamMember.Team_Member__c;
	            temp.TeamMemberRole=teamMember.Team_Role__c;
	            temp.AccountId=teamMember.Account__c;
	            //2015-11-09- anirudh.singh@cdk.com- Commented the below line.
	            //temp.AccountAccessLevel=teamMember.Account_Access__c; system.debug(teamMember.Account_Access__c);
	            accountMembers.add(temp);
	            string keyVal = (string)teamMember.Account__c+(string)teamMember.Team_Member__c;
	           	//system.debug('********keyVal******'+keyVal);
	        	myAccountTeam.put(keyVal, teamMember);
           // }
            //2016-02-10- anirudh.singh@cdk.com- Added IF condition to prevent the record insertion if the value of Account_Access__c is Private or Null or Blank.
           /* if(teamMember.Team_Member__c!=accountOwners.get(teamMember.Account__c).OwnerId 
               && teamMember.Account_Access__c!='Private' && teamMember.Account_Access__c!=Null 
               && teamMember.Account_Access__c!='')
            {
                //2015-11-09- anirudh.singh@cdk.com- Earlier tempAccountShare was declared outside this For Loop.
                AccountShare tempAccountShare=new AccountShare();
                tempAccountShare.UserOrGroupId=teamMember.Team_Member__c;
                tempAccountShare.AccountId=teamMember.Account__c;
                tempAccountShare.AccountAccessLevel=returnPickVal(teamMember.Account_Access__c);
                tempAccountShare.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
                tempAccountShare.CaseAccessLevel=returnPickVal(teamMember.Case_Access__c);
                accountShareList.add(tempAccountShare); 
            }*/
        }
        system.debug('-----accountMembers-------'+accountMembers.size());
        if(accountMembers.size()>0)
        {
            //system.debug(accountMembers);
            Database.insert(accountMembers, false);
        
	       /* if(accountShareList.size()>0)
	        {
	            system.debug(accountShareList);
	            insert accountShareList;	
	        }*/
	        
	        list<AccountShare> insertedSharedRecs = 
	        	[select Id, UserOrGroupId, AccountId from AccountShare 
	        	 where RowCause = 'Team' 
	        	 and UserOrGroupId IN :userIds
	        	 and AccountId IN: accounts
	        ];
	        list<AccountShare> accountShareToUpdate = new list<AccountShare>();
	        for(AccountShare acc:insertedSharedRecs)
	        {
	        	Account_Team__c thisAccountTeam = myAccountTeam.get((string)acc.AccountId+(string)acc.UserOrGroupId);
	        	if(thisAccountTeam!=null)
	        	{
	        		acc.AccountAccessLevel = returnPickVal(thisAccountTeam.Account_Access__c);
		        	acc.OpportunityAccessLevel = returnPickVal(thisAccountTeam.Opportunity_Access__c);
		        	acc.CaseAccessLevel = returnPickVal(thisAccountTeam.Case_Access__c);
		        	// Hardcoded string permission since it will always be read/write for contacts
		        	acc.ContactAccessLevel = 'Edit';
		        	accountShareToUpdate.add(acc);
	        	}
	        }
	        system.debug('******accountShareToUpdate****'+accountShareToUpdate.size());
	        Database.update(accountShareToUpdate, false);
	   }
        
        return accountMembers;
    }
    
    public static void deleteAccountTeam(List<Account_Team__c> accountTeam)
    {
        Set<String> teamMembers=new Set<String>();
        for(Account_Team__c teamMember: accountTeam)
        {
            teamMembers.add(teamMember.SForce_Account_Team_Id__c);		
        }
        
        List<AccountTeamMember> accountMembers=[SELECT Id FROM AccountTeamMember WHERE Id IN :teamMembers];
        
        //2015-11-09- anirudh.singh@cdk.com- Added Null check to the below IF Block.
        if(accountMembers!=Null && accountMembers.size()>0)
        {
            Database.delete(accountMembers, false);
        }
    }
    
    public static String returnPickVal(String val)
    {
        if(val=='Private') return 'None';
        else if(val=='Read Only') return 'Read';
        else if(val=='Read/Write') return 'Edit';	
        
        return 'None';
    }
}