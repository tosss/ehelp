/*--------------------------------------
RQ-05471 - SubProject Privacy Phase-II
2016-02-05 -venkata.shrivol@cdk.com - created
---------------MODIFICATIONS-----------------------
2016-05-09 -venkata.shrivol@cdk.com -modified as per the new restrictions on sharing objects
-----------------------------------------*/
public with sharing class IMP_SubProjectCDKContact_Handler 
{
	public static boolean profileCanByPass = IMP_Project_Utility.profileCanByPass('SubProject_Sharing',UserInfo.getProfileId());
	public static final string ERROR_MESSAGE = 'Only the Project Manager can Create/Edit/Modify the CDK Contacts for Restricted SubProjects';
	
	public static void afterInsert(map<Id, SubProject_CDK_Contact__c> newMap)
	{
		shareCDKContactRecords(newMap);
	}
	
	public static void beforeDelete(map<Id, SubProject_CDK_Contact__c> oldMap)
	{
		shareCDKContactRecords(oldMap);
	}
	
	public static void afterUpdate(map<Id, SubProject_CDK_Contact__c> newMap, map<Id, SubProject_CDK_Contact__c> oldMap)
	{
		boolean isMyOldSubProjectConfidential;
		boolean isMyNewSubProjectConfidential;
		boolean oldAndNewSubProjectHaveSameOwner;
		Id ownerIdOfSubProject;
		set<Id> subProjectIds = new set<Id>();
		set<ID> OwnerIds = new set<Id>();
		
		//one pair for deleting the shared records
		set<Id> userIdOrGroupIdsToDeleteShare = new set<ID>();
		set<Id> subProjectIdsToDeleteShare = new set<ID>();
		
		set<Id> userIdOrGroupIdsToShare = new set<Id>();
		set<Id> subProjectIdsToShare = new set<Id>();
		
		for(SubProject_CDK_Contact__c cdkContact:newMap.values())
		{
			SubProject_CDK_Contact__c oldCDKContact  = oldMap.get(cdkContact.Id); 
			subProjectIds.add(cdkContact.SubProject__c);
			if(cdkContact.SubProject__c != oldCDKContact.SubProject__c)
			{
				subProjectIds.add(oldCDKContact.SubProject__c);
				
			}
		}
			map<Id, SubProject__c> subProjectMap = new map<Id,SubProject__c>([
			select Confidentiality_Status__c, ownerId 
			from SubProject__c
			where Id IN:subProjectIds
			]);
			//shareCDKContactRecords(newMap, oldMap, subProjectMap);
			
		//system.debug('---subProjectMap--'+subProjectMap);
		
		for(SubProject_CDK_Contact__c cdkContact:newMap.values())
		{
			SubProject_CDK_Contact__c oldSubCDKContact  = oldMap.get(cdkContact.Id);
			
			boolean ownerCheckOfSubProject = subProjectMap.get(cdkContact.SubProject__c).OwnerId == UserInfo.getUserId() ? true : false;
			
			isMyOldSubProjectConfidential = subProjectMap.get(oldSubCDKContact.SubProject__c).Confidentiality_Status__c == 'Restricted';
			
			isMyNewSubProjectConfidential = subProjectMap.get(cdkContact.SubProject__c).Confidentiality_Status__c == 'Restricted';
			
			if(isMyOldSubProjectConfidential || isMyNewSubProjectConfidential)
			{
				if(oldSubCDKContact.User_Visibility_Enabled__c!= cdkContact.User_Visibility_Enabled__c ||
				 oldSubCDKContact.CDK_Contact__c!= cdkContact.CDK_Contact__c ||
				 oldSubCDKContact.SubProject__c != cdkContact.SubProject__c)
				{
					//system.debug('----Trace Point 1------>');
					if(oldSubCDKContact.SubProject__c!= cdkContact.SubProject__c)
					{ 
						oldAndNewSubProjectHaveSameOwner = subProjectMap.get(oldSubCDKContact.SubProject__c).OwnerId == subProjectMap.get(cdkContact.SubProject__c).OwnerId ?
															true : false;
						if((ownerCheckOfSubProject &&  oldAndNewSubProjectHaveSameOwner) || profileCanByPass )
						{
							userIdOrGroupIdsToDeleteShare.add(oldSubCDKContact.CDK_Contact__c);
							subProjectIdsToDeleteShare.add(oldSubCDKContact.SubProject__c);
							if(isMyNewSubProjectConfidential && cdkContact.User_Visibility_Enabled__c)
							{
								userIdOrGroupIdsToShare.add(cdkContact.CDK_Contact__c);
								subProjectIdsToShare.add(cdkContact.SubProject__c);
							}
						}
						else
						{
							//system.debug('----Trace Point 5------>');
							cdkContact.addError(ERROR_MESSAGE);
						}
					}
					else
					{
						//system.debug('----Trace Point 2------>');
						system.debug(isMyNewSubProjectConfidential);
						system.debug(ownerCheckOfSubProject);
						system.debug(profileCanByPass);
						if(isMyNewSubProjectConfidential && (ownerCheckOfSubProject || profileCanByPass ) )
						{
							//system.debug('----Trace Point 3------>');
							if(cdkContact.User_Visibility_Enabled__c)
							{
								userIdOrGroupIdsToShare.add(cdkContact.CDK_Contact__c);
								subProjectIdsToShare.add(cdkContact.SubProject__c);
							}
							else
							{
								userIdOrGroupIdsToDeleteShare.add(cdkContact.CDK_Contact__c);
								subProjectIdsToDeleteShare.add(cdkContact.SubProject__c);
							}
							if(oldSubCDKContact.CDK_Contact__c!= cdkContact.CDK_Contact__c)
							{
								userIdOrGroupIdsToDeleteShare.add(oldSubCDKContact.CDK_Contact__c);
								subProjectIdsToDeleteShare.add(oldSubCDKContact.SubProject__c);
							}
						}
						else
						{
							//system.debug('----Trace Point 4------>');
							cdkContact.addError(ERROR_MESSAGE);	
						}
					}
				}	
			}
			userIdOrGroupIdsToDeleteShare.remove(subProjectMap.get(cdkContact.SubProject__c).OwnerId);
		}
	//For Sharing the records
		if(!userIdOrGroupIdsToShare.isEmpty() && !subProjectIdsToShare.isEmpty())
		{
			IMP_SubProjectApexSharing_Handler.getRequiredRecsFromSubProject(subProjectIdsToShare, userIdOrGroupIdsToShare,OwnerIds,false);
		}
		
		//For Deleting the shared records
		if(!userIdOrGroupIdsToDeleteShare.isEmpty() && !subProjectIdsToDeleteShare.isEmpty())
		{
			IMP_SubProjectApexSharing_Handler.deleteManuallySharedRecsThroughApex(subProjectIdsToDeleteShare,userIdOrGroupIdsToDeleteShare,'SubProject__Share' );
			/*set<ID> ProjectLogIDs = IMP_SubProjectApexSharing_Handler.getProjectLogRecordsFromSubProject(subProjectIdsToDeleteShare);
			if(ProjectLogIDs!=null && !ProjectLogIDs.isEmpty())
			{
				IMP_SubProjectApexSharing_Handler.deleteManuallySharedRecsThroughApex(subProjectIdsToDeleteShare,userIdOrGroupIdsToDeleteShare,'Project_Log__Share' );	
			}*/
			
		}
		
	}
	
	
	
	public static void shareCDKContactRecords(map<Id, SubProject_CDK_Contact__c> mapOfCDKContacts)
	{
		
		//two pairs of sets
		//one pair for sharing the records
		set<Id> userIdOrGroupIdsToShare = new set<Id>();
		set<Id> subProjectIdsToShare = new set<Id>();
		boolean isMyOldSubProjectConfidential;
		boolean oldAndNewSubProjectHaveSameOwner;
		Id ownerIdOfSubProject;
		
		//one pair for deleting the shared records
		set<Id> userIdOrGroupIdsToDeleteShare = new set<ID>();
		set<Id> subProjectIdsToDeleteShare = new set<ID>();
		
		if(!mapOfCDKContacts.isEmpty())
		{
			for(SubProject_CDK_Contact__c subCdkContact:[
	  			select Id, CDK_Contact__c, SubProject__r.Confidentiality_Status__c, User_Visibility_Enabled__c, SubProject__r.OwnerId
	  			from SubProject_CDK_Contact__c 
	  			where Id IN: mapOfCDKContacts.keySet() 
	  			])
			{
			//Below code runs only in udpate trigger
			
				if(subCdkContact.SubProject__r.Confidentiality_Status__c =='Restricted' && subCdkContact.User_Visibility_Enabled__c )
				{
					system.debug('-----'+Trigger.isDelete);
					if(Trigger.isDelete)
					{
						if(subCdkContact.SubProject__r.OwnerId == UserInfo.getUserID() || profileCanByPass)
						{
							userIdOrGroupIdsToDeleteShare.add(subCdkContact.CDK_Contact__c);
							subProjectIdsToDeleteShare.add(subCdkContact.SubProject__c);
						}
						else
						{
							mapOfCDKContacts.get(subCdkContact.Id).addError(ERROR_MESSAGE);
						}
					}
					else
					{
						userIdOrGroupIdsToShare.add(subCdkContact.CDK_Contact__c);
						subProjectIdsToShare.add(subCdkContact.SubProject__c);
					}
					
				}
				userIdOrGroupIdsToDeleteShare.remove(subCdkContact.SubProject__r.OwnerId);
			}
			
			//For Sharing the records
			if(!userIdOrGroupIdsToShare.isEmpty() && !subProjectIdsToShare.isEmpty())
			{
				IMP_SubProjectApexSharing_Handler.getRequiredRecsFromSubProject(subProjectIdsToShare, userIdOrGroupIdsToShare, null, false);
			}
			
			//For Deleting the shared records
			if(!userIdOrGroupIdsToDeleteShare.isEmpty() && !subProjectIdsToDeleteShare.isEmpty())
			{
				IMP_SubProjectApexSharing_Handler.deleteManuallySharedRecsThroughApex(subProjectIdsToDeleteShare,userIdOrGroupIdsToDeleteShare,'SubProject__Share' );
				/*set<ID> ProjectLogIDs = IMP_SubProjectApexSharing_Handler.getProjectLogRecordsFromSubProject(subProjectIdsToDeleteShare);
				if(ProjectLogIDs!=null && !ProjectLogIDs.isEmpty())
				{
					IMP_SubProjectApexSharing_Handler.deleteManuallySharedRecsThroughApex(subProjectIdsToDeleteShare,userIdOrGroupIdsToDeleteShare,'Project_Log__Share' );	
				}*/
				
			}
		}
	}
	    
}