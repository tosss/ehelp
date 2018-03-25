//2015-11-09- anirudh.singh@cdk.com- Modified the API Version from 10.0 to 34.0.
public class DS_CreateSForceSalesTeam
{
    public List<OpportunityTeamMember> insertSForceSalesTeam(List<Sales_Team__c> salesTeam)
    {
        List<Id> opportunities=new List<Id>();
        for(Sales_Team__c st: salesTeam)
        {
            opportunities.add(st.Opportunity__c);
        }
        
        Map<Id, Opportunity> opportunityOwners=new Map<Id, Opportunity>([SELECT Id, OwnerId, Owner.IsActive FROM Opportunity WHERE Id IN :opportunities]);
        
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //OpportunityTeamMember temp;
        
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //OpportunityShare oppShare;
        List<OpportunityShare> opportunityShareList=new List<OpportunityShare>();
        List<OpportunityTeamMember> opportunityMembers=new List<OpportunityTeamMember>();
        
        for(Sales_Team__c teamMember: salesTeam)
        {
            // CN 3/17 add only if it is present in oppOwners
            //2015-11-09- anirudh.singh@cdk.com- Earlier temp was declared outside this For Loop.
            OpportunityTeamMember temp=new OpportunityTeamMember();
            temp=new OpportunityTeamMember();
            temp.UserId=teamMember.User__c;
            temp.TeamMemberRole=teamMember.Team_Role__c;
            temp.OpportunityId=teamMember.Opportunity__c;
            //2015-11-09- anirudh.singh@cdk.com- Commented the below line.
            //temp.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
            opportunityMembers.add(temp);
            
            //2016-02-10- anirudh.singh@cdk.com- Added the IF Block to prevent the record insertion if the value of Opportunity_Access__c is Private or Null or Blank.
            if(teamMember.Opportunity_Access__c!='Private' && teamMember.Opportunity_Access__c!=Null && teamMember.Opportunity_Access__c!='')
            {
                //2015-11-09- anirudh.singh@cdk.com- Earlier oppShare was declared outside this For Loop.
                OpportunityShare oppShare=new OpportunityShare();
                oppShare.UserOrGroupId=teamMember.User__c;
                oppShare.OpportunityId=teamMember.Opportunity__c;
                oppShare.OpportunityAccessLevel=returnPickVal(teamMember.Opportunity_Access__c);
                
                if(opportunityOwners.get(teamMember.Opportunity__c)!=null && teamMember.User__c!=opportunityOwners.get(teamMember.Opportunity__c).OwnerId)
                {
                    opportunityShareList.add(oppShare);
                }
                else if(!opportunityOwners.get(teamMember.Opportunity__c).Owner.isActive)
                {
                    opportunityShareList.add(oppShare);
                }
            }
        }
        if(opportunityMembers.size()>0)
        {
            //lalitha.adduru@cdk.com - added try catch block for RQ-05118
            try
            {
                insert opportunityMembers;
            }
            catch(Exception ex)
            {
                system.debug(ex.getMessage() + ' at '+ex.getLineNumber());
            }
        }
        if(opportunityShareList.size()>0)
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

        }
        
        return opportunityMembers;
    }
    
    public void deleteSForceSalesTeam(List<Sales_Team__c> salesTeam)
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
            delete opportunityMembers;
        }
    }
    
    public List<AccountTeamMember> insertAccountTeam(List<Account_Team__c> accountTeam)
    {
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //AccountTeamMember temp;
        
        //2015-11-09- anirudh.singh@cdk.com- Commented the below line and declared it inside for loop.
        //AccountShare tempAccountShare;
        
        List<AccountShare> accountShareList=new List<AccountShare>();
        List<AccountTeamMember> accountMembers=new List<AccountTeamMember>();
        Set<Id> accounts=new Set<Id>();
        
        for(Account_Team__c tm:accountTeam)
        {
            accounts.add(tm.Account__c);
        }
        
        Map<Id, Account> accountOwners=new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accounts]);
        
        for(Account_Team__c teamMember: accountTeam)
        {
            //2015-11-09- anirudh.singh@cdk.com- Earlier temp was declared outside this For Loop.
            AccountTeamMember temp=new AccountTeamMember();
            temp.UserId=teamMember.Team_Member__c;
            temp.TeamMemberRole=teamMember.Team_Role__c;
            temp.AccountId=teamMember.Account__c;
            //2015-11-09- anirudh.singh@cdk.com- Commented the below line.
            //temp.AccountAccessLevel=teamMember.Account_Access__c; system.debug(teamMember.Account_Access__c);
            accountMembers.add(temp);
            
            //2016-02-10- anirudh.singh@cdk.com- Added IF condition to prevent the record insertion if the value of Account_Access__c is Private or Null or Blank.
            if(teamMember.Team_Member__c!=accountOwners.get(teamMember.Account__c).OwnerId 
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
            }
        }
        
        if(accountMembers.size()>0)
        {
            system.debug(accountMembers);
            insert accountMembers;
        }
        if(accountShareList.size()>0)
        {
            system.debug(accountShareList);
            insert accountShareList;	
        }
        
        return accountMembers;
    }
    
    public void deleteAccountTeam(List<Account_Team__c> accountTeam)
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
            delete accountMembers;
        }
    }
    
    public String returnPickVal(String val)
    {
        if(val=='Private') return 'None';
        else if(val=='Read Only') return 'Read';
        else if(val=='Read/Write') return 'Edit';	
        
        return 'None';
    }
}