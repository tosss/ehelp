/*-----------------------------------------------------------
RQ-05865 - Update confidential field on Project Log from parent Subproject

2015-12-21 - venkata.shrivol@cdk.com  - Created
-------------------------------------------------------------*/
public with sharing class IMP_ProjectLog_Handler 
{
	public static void beforeInsert(list<Project_Log__c> newList)
	{
		updateConfidentialField(newList, null, true);
	}
	
	public static void beforeUpdate(list<Project_Log__c> newList, map<Id, Project_Log__c> oldMap)
	{
		//IMP_UpdateConfidentialFieldOnProjectLog.
		updateConfidentialField(newList, oldMap, false);
	} 
	
	public static void updateConfidentialField(list<Project_Log__c> newList, map<Id, Project_Log__c> oldMap, boolean updateCheck)
	{
		set<Id> subProjectIds = new set<Id>();
		
		for(Project_Log__c plog:newList)
		{
			Id oldSubProjectId = oldMap!=null? oldMap.get(plog.Id).SubProject_Id__c : null;
			
			if(plog.SubProject_Id__c!=oldSubProjectId || updateCheck)
			{
				subProjectIds.add(plog.SubProject_Id__c);
			}
		}
		
		map<Id, SubProject__c> subPrjMap = new map<Id, Subproject__c>([
			select Id, Confidential__c from SubProject__c 
			where Id IN:subProjectIds
			]);
		 
		for(Project_Log__c pl:newList)
		{
			if(subPrjMap.containsKey(pl.SubProject_Id__c))
			{
				pl.SubProject_Confidential__c = subPrjMap.get(pl.SubProject_Id__c).Confidential__c;
			}
			else if(pl.SubProject_Id__c == null) 
			{
				pl.SubProject_Confidential__c = false;
			}		
		}
			
	}       
}