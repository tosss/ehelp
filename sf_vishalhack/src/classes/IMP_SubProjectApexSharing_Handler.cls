/*--------------------------------------
RQ-05471 - SubProject Privacy Phase-II
2016-02-05 -venkata.shrivol@cdk.com - created
NOTE: This apex class doesn't have a test class as the methods are covered by IMP_Subproject_Test and 
	  IMP_SubProjectCDKContact_Test
---------------MODIFICATIONS-----------------------
2016-05-09 -venkata.shrivol@cdk.com -modified as per the new restrictions on sharing objects
-----------------------------------------*/
public with sharing class IMP_SubProjectApexSharing_Handler 
{
 	public static void getRequiredRecsFromSubProject(set<Id> SubprojectIds, set<Id> cdkContactUserIds, set<Id> ownerIds, boolean queryCDKContacts)
 	{
 		set<Id> projectLogIds = new set<Id>();
 		set<Id> userIds = new set<Id>();
 		if(cdkContactUserIds!=null)
 		{
 			userIds.addAll(cdkContactUserIds);	
 		}
 		
 		//projectLogIds = getProjectLogRecordsFromSubProject(SubprojectIds);
 		
 		if(queryCDKContacts)
 		{
 			userIds = getCDKContactUserIdsFromSubProject(subProjectIds, ownerIds);
 		}
 		

 		if(!userIds.isEmpty())
 		{
 			shareRecManuallyThroughApex(SubprojectIds, userIds,'SubProject__Share');
 			/*if(!projectLogIds.isEmpty())
 			{
 				shareRecManuallyThroughApex(projectLogIds, userIds,'Project_Log__Share');	
 			}*/
 		}
 		
 	}
 	
 	public static void shareRecManuallyThroughApex(set<Id> recordIdSet, set<Id> userOrGroupIdSet, string ObjectShareName)
 	{
 		
 		list<sObject> sharedList = new list<sObject>();
 		// Global describe will contain the object Share name if the object OWD is Private only.
 		try
 			{
                Schema.sObjectType sharedObjType = Schema.getGlobalDescribe().get(ObjectShareName); 
 				if(sharedObjType!=null)
	 			{
	 				for(Id recordId:recordIdSet)
	 				{
	 					for(Id uIdOrGroupId:userOrGroupIdSet)
	 					{
	 						SObject SharedRecord = sharedObjType.newSObject();
							SharedRecord.put('ParentId', recordId);
							SharedRecord.put('UserOrGroupId', uIdOrGroupId);
							SharedRecord.put('AccessLevel', 'Edit');
							SharedRecord.put('RowCause', 'Manual');
							sharedList.add(SharedRecord);
	 					}
	 				}
	 			}
                // sort sObjects by Type
	 			sharedList.sort();
	 			list<Database.saveResult> dsrList = Database.insert(sharedList, false);
	 			Integer i=0;
	 			for(Database.saveResult dsr:dsrList)
	 			{
	 				if(!dsr.isSuccess())
	 				{
	 					Database.Error err =dsr.getErrors()[0];
	 					system.debug('----Getting Errors on this Records----');
	 					system.debug('----Parent Id----'+sharedList[i].get('ParentId'));
	 					system.debug('----UserOrGroupId----'+sharedList[i].get('UserOrGroupId'));
	 					system.debug('----Error is-----'+err.getMessage());
	 				}
	 				i++;
	 			}
 			}
 			catch(Exception e)
 			{
 				system.debug('----------Exception--------'+e);	
 			}
 			
 		
 	}
 	public static void deleteManuallySharedRecsThroughApex(set<Id> recordIdSet, set<Id> userIdOrGroupIdSet, String objectShareName)
 	{
 		
 		String Query='';
 		Query += 'select Id from ';
 		if(objectShareName!=null && objectShareName!='')
 		{
 			Query += objectShareName + ' where ParentId IN :recordIdSet and UserOrGroupId IN :userIdOrGroupIdSet ';
 			
 			system.debug('-----Query-----'+Query);
 			
 			list<sObject> sharedObjectList = Database.Query(Query);
 			
 			delete sharedObjectList;
 		}
 	}
 	
 	/*public static set<Id> getProjectLogRecordsFromSubProject(set<Id> SubProjectIds)
 	{
 		set<Id> projectLogIds = new set<Id>();
 		if(SubProjectIds.isEmpty())
 		{
 			for(Project_Log__c plog:[
 			select Id from Project_Log__c where Sub_Project_Action_Items__c IN:SubprojectIds 
        	or
        	Sub_Project_Change_Request__c IN:SubprojectIds 
        	or
        	Sub_Project_Issue__c IN:SubprojectIds 
        	or
        	Sub_Project_Lessons_Learned__c IN:SubprojectIds 
        	or
        	Sub_Project_Risk__c IN:SubprojectIds ])
	 		{
	 			projectLogIds.add(plog.Id);
	 		}	
 		}
 		return projectLogIds;
 	} */
 	
 	public static set<Id> getCDKContactUserIdsFromSubProject(set<Id> subProjectIds, set<Id> ownerIds)
 	{
 		set<Id> cdkContUserIds = new set<Id>();
 		if(!subProjectIds.isEmpty())
 		{
 			for(SubProject_CDK_Contact__c subcdkcon : [
 			select CDK_Contact__c, CDK_Contact__r.ManagerId
 			from SubProject_CDK_Contact__c
 			where User_Visibility_Enabled__c = true
 			and SubProject__c IN: SubprojectIds
 			and CDK_Contact__c NOT IN:ownerIds])
	 		{
	 			cdkContUserIds.add(subcdkcon.CDK_Contact__c);
	 		}	
 		}
 		return cdkContUserIds;
 	}
    
}