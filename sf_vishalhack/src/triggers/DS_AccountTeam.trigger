//2015-11-09- anirudh.singh@cdk.com- Modified the API Version from 10.0 to 34.0.
//2016-06-27 -venkata.shrivol@cdk.com - Added code for apex sharing of contacts from account team members RQ-06969
//2016-07-11 - venkata.shrivol@cdk.com - added temporary custom settings profile check for admin profile
//2016-07-15 - venkata.shrivol@cdk.com - Refactored trigger code
//2017-03-27 - ragashalini.koka@cdk.com - Added after delete functionality for Top 5 Sharing for RQ-08784
trigger DS_AccountTeam on Account_Team__c (before insert, before update, before delete, after insert, after update, after delete) 
{
    List<Account_Team__c> accountTeam=Trigger.new;
    List<Account_Team__c> oldAccountTeam=Trigger.old;
    List<AccountTeamMember> accountMembers;
    
    //2016-06-27 -venkata.shrivol@cdk.com - Added code for apex sharing in after insert/update and before delete contexts
    if(Trigger.isAfter)
    {
    	//if(UserInfo.getProfileId() !=CustomSettings__c.getInstance().Profile_Id__c)
        //{
        if(Trigger.isInsert)
        {
            DS_AccountTeam_Handler.afterInsert(Trigger.New);
        }
        else if(Trigger.isUpdate)
        {
            DS_AccountTeam_Handler.afterUpdate(Trigger.New, Trigger.oldMap);
        }
        else if(Trigger.isDelete)
        {
            DS_AccountTeam_Handler.afterDelete(Trigger.old);
        }
        //}
    }
    else if(Trigger.isBefore)
    {
	    if(Trigger.isDelete)
	    {
			DS_AccountTeam_Handler.beforeDelete(Trigger.old);	    	
	    }
	    //Insert the standard salesforce sales team member(s)
	    else if(Trigger.isInsert)
	    {
			DS_AccountTeam_Handler.beforeInsert(Trigger.New);	        
	    }
	    //Update the standard salesforce account team by deleting then inserting the records
	    else if(Trigger.isUpdate)
	    {
	      	DS_AccountTeam_Handler.beforeUpdate(Trigger.New, Trigger.old);
	    }
    }
}