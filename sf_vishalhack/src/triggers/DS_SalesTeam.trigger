//2015-11-09- anirudh.singh@cdk.com- Modified the API Version from 10.0 to 34.0.
//2016-06-27 -venkata.shrivol@cdk.com - Added code for apex sharing of contacts from sales team members RQ-06969
//2016-07-11 - venkata.shrivol@cdk.com - added temporary custom settings profile check for admin profile
//2016-07-13 - venkata.shrivol@cdk.com - Refactored trigger code
trigger DS_SalesTeam on Sales_Team__c (before delete, after insert, after update, before insert, before update) 
{
    // 2015-06-29 matt.keefe@cdk.com - added condition for error handling
    boolean run=true; // default to on
    
    if(CustomSettings__c.getInstance()!=Null)
    { 
        run=CustomSettings__c.getInstance().DS_SalesTeamTrigger_On__c; 
    }
    
    if(run)
    {
        if(Trigger.isBefore)
        {
            if(Trigger.isDelete)
            {
                DS_SalesTeam_Handler.beforeDelete(Trigger.Old);
            }
            //Insert the standard salesforce sales team
            else if(Trigger.isInsert)
            {
               DS_SalesTeam_Handler.beforeInsert(Trigger.New);
            }
            //Update the standard salesforce sales team by deleting then inserting the records
            else if(Trigger.isUpdate)
            {
                DS_SalesTeam_Handler.beforeUpdate(Trigger.New, Trigger.Old);
            }
        }
        else if(Trigger.isAfter)
	    {
	    	//if(UserInfo.getProfileId() !=CustomSettings__c.getInstance().Profile_Id__c)
            //{
            	if(Trigger.isInsert)
		    	{
		    		DS_SalesTeam_Handler.afterInsert(Trigger.New);
		    	}
		    	else if(Trigger.isUpdate)
		    	{
		    		DS_SalesTeam_Handler.afterUpdate(Trigger.New, Trigger.oldMap);
		    	}
            //}
	    }
    }
}