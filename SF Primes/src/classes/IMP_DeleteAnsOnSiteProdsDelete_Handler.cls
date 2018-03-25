/*
*
* 05/18/2015    Venkata Shrivol - Created
* Description - Handler Class for IMP_SiteProds Trigger for deleting answer records on Discovery
*				site workbook category if any Products are deleted.
*-----HISTORY--------
* 06/08/15  Venkata Shrivol  Added Code for deleting SiteWkbks when its child siteWkbkCategories 
*							 are deleted. 
*
*/

public with sharing class IMP_DeleteAnsOnSiteProdsDelete_Handler 
{
	public static void deleteAnswers(Set<Id> siteProdIds)
	{
		//list<Site_Workbook__c> existingWorkbooks = [select Id from Site_Workbook__c where Project__c IN (select SubProject__r.Project__c from Site_Product__c where Id IN: siteProdIds)];
		set<Id> subProjectIds = new set<Id>();
		set<Id> questionIds = new set<Id>();
		set<Id> productIds = new set<Id>();
		set<Id> siteWorkbookIds = new set<Id>();
		set<Id> workbookCategoryIds = new set<Id>();
		set<Id> questionCategoryIds = new set<Id>();
		set<Id> accountIds = new set<Id>();
		set<Id> subProjectSiteIds = new set<Id>();
		set<Id> commonQuestionIds = new set<Id>(); 
		
		//list<sObject> recordsToDelete;
		list<Site_Workbook__c> existingWorkbooks;
		list<Discovery_Workbook_Category__c> existingWorkbookCategories;
		list<Answer__c> answersToDelete = new list<Answer__c>();
		list<Discovery_Answer_Workbook_Category__c> ansWkbkCategoriesToDelete = new list<Discovery_Answer_Workbook_Category__c>();
		list<Discovery_Workbook_Category__c> zeroAnswerWorkbookCategoryList = new list<Discovery_Workbook_Category__c>();
		list<Site_Workbook__c> emptySiteWkbksToDelete = new list<Site_Workbook__c>();
		list<Discovery_Workbook_Category__c> categoriesToUpdate = new list<Discovery_Workbook_Category__c>();
		
		map<Id,list<Answer__c>> categoryToAnswerMap = new map<Id, list<Answer__c>>();
		map<Id,list<Discovery_Answer_Workbook_Category__c>> siteWkbkCategoryToAnsWkbkCatMap = new map<Id, list<Discovery_Answer_Workbook_Category__c>>();
		
		list<Site_Product__c> deletingSiteProds = [select SubProject__c, Product__c, SubProjectSite__r.Account__c, SubProjectSite__c  from Site_Product__c where Id IN: siteProdIds];
		for(Site_Product__c sp:deletingSiteProds)
		{
			subProjectIds.add(sp.SubProject__c);
			accountIds.add(sp.SubProjectSite__r.Account__c);
			subProjectSiteIds.add(sp.SubProjectSite__c);
			productIds.add(sp.Product__c);
		}
		
		for(Discovery_Question_Product__c dqp:[select Question__c, Product__r.Solution__r.Question_Category__c 
											  from Discovery_Question_Product__c 
											  where Question__r.Active__c = true and Product__c IN:productIds])
		{
			questionIds.add(dqp.Question__c);
			questionCategoryIds.add(dqp.Product__r.Solution__r.Question_Category__c);
			
		}
		
		existingWorkbooks = [select Id from Site_Workbook__c where SubProject__c IN:subProjectIds and Site__c IN:accountIds];
		
		if(!existingWorkbooks.isEmpty())
		{
			for(Site_Workbook__c sw:existingWorkbooks)
			{
				siteWorkbookIds.add(sw.Id);
			}
			//questionIds = IMP_Project_Utility.getQuestionIds(siteProdIds);
			
			if(!subProjectIds.isEmpty())
			{
				existingWorkbookCategories = [
											  select Id, Count_of_Questions__c 
											  from Discovery_Workbook_Category__c 
											  where Site_Workbook__c IN :siteWorkbookIds
											 ];
			}
			if(existingWorkbookCategories!=null && !existingWorkbookCategories.isEmpty())
			{
				list<Answer__c> existingAnswers = [select Id, 
												   (select Id, Discovery_Workbook_Category__c from Discovery_Answer_Workbook_Categories__r 
												   where Discovery_Workbook_Category__c IN:existingWorkbookCategories and 
												   Discovery_Workbook_Category__r.Question_Category__c IN:questionCategoryIds
												   ) 
												   from Answer__c 
												   where Discovery_Site_Workbook__c IN:siteWorkbookIds and 
												   Question__c IN:questionIds];
				
				for(Answer__c ans:existingAnswers)
				{
					ansWkbkCategoriesToDelete.addAll(ans.Discovery_Answer_Workbook_Categories__r);
					//system.debug('-------ansWkbkCategoriesToDelete----'+ansWkbkCategoriesToDelete);
					for(Discovery_Answer_Workbook_Category__c dawkc:ans.Discovery_Answer_Workbook_Categories__r)
					{
						 
						list<Discovery_Answer_Workbook_Category__c> tempList  = siteWkbkCategoryToAnsWkbkCatMap.containsKey(dawkc.Discovery_Workbook_Category__c) ? 
																				siteWkbkCategoryToAnsWkbkCatMap.get(dawkc.Discovery_Workbook_Category__c) : 
																				new list<Discovery_Answer_Workbook_Category__c>();
                    	tempList.add(dawkc);
                    	siteWkbkCategoryToAnsWkbkCatMap.put(dawkc.Discovery_Workbook_Category__c, tempList);
					}	 
				}	  
				if(!ansWkbkCategoriesToDelete.isEmpty())
				{	
					for(Discovery_Workbook_Category__c dwc:existingWorkbookCategories)
					{
						if(siteWkbkCategoryToAnsWkbkCatMap.keySet().contains(dwc.Id))
						{
							if(dwc.Count_of_Questions__c >= siteWkbkCategoryToAnsWkbkCatMap.get(dwc.Id).size())
							{
								dwc.Count_of_Questions__c = dwc.Count_of_Questions__c - siteWkbkCategoryToAnsWkbkCatMap.get(dwc.Id).size();
								//system.debug('-------dwc.Count_of_Questions__c After Update--------'+dwc.Count_of_Questions__c);
								if(dwc.Count_of_Questions__c == 0)
								{
									zeroAnswerWorkbookCategoryList.add(dwc);
								}
								else 
								{
									categoriesToUpdate.add(dwc);
								}
							}
						}
					}
					//recordsToDelete.addAll(existingAnswers);
					try
					{
						delete ansWkbkCategoriesToDelete;
						if(!categoriesToUpdate.isEmpty())
						{
							update categoriesToUpdate;
						}
						
						//system.debug('-----zeroAnswerWorkbookCategoryList size before Delete------'+zeroAnswerWorkbookCategoryList.size());
						
						if(!zeroAnswerWorkbookCategoryList.isEmpty())
						{
							delete zeroAnswerWorkbookCategoryList;
						}
						for(Answer__c ans:[select Id, 
										   (select Id from Discovery_Answer_Workbook_Categories__r
										   ) 
										   from Answer__c 
										   where Discovery_Site_Workbook__c IN:siteWorkbookIds and 
										   Question__c IN:questionIds])
						{
							if(ans.Discovery_Answer_Workbook_Categories__r.isEmpty())
							{
								answersToDelete.add(ans);
							}
						}
						if(!answersToDelete.isEmpty())
						{
							delete answersToDelete;
						}
						
						list<Site_Workbook__c> updatedWorkbooks = [
						select Id,
						(select Id from Discovery_Workbook__r) 
						from Site_Workbook__c 
						where SubProject__c IN:subProjectIds and Site__c IN:accountIds];
						
						for(Site_Workbook__c sw:updatedWorkbooks)
						{
							system.debug('---SWKBKS to Delete----'+sw.Discovery_Workbook__r);
							if(sw.Discovery_Workbook__r.isEmpty())
							{
								emptySiteWkbksToDelete.add(sw);
							}
						}
						if(!emptySiteWkbksToDelete.isEmpty())
						{
							delete emptySiteWkbksToDelete;
						}			
					}
					catch(Exception e)
					{
						system.debug('-----Exception Caught------'+e);
					}		
				}
			}
		}
	}
/*
list<Discovery_Question_Product__c> existingDQPList = [select Question__c from Discovery_Question_Product__c where Question__r.Active__c = true and Product__c IN
															  (select Product__c from Site_Product__c where Id NOT IN:siteProdIds and SubProjectSite__c IN:subProjectSiteIds)];
		
		
		
		for(Discovery_Question_Product__c dqp:existingDQPList)
		{
			commonQuestionIds.add(dqp.Question__c);
		}
		
		list<Discovery_Question_Product__c> dqpList = [select Question__c 
                                                       from Discovery_Question_Product__c 
                                                       where Question__r.Active__c = true and Product__c IN 
                                                       (select Product__c from Site_Product__c where Id IN:siteProdIds)
                                                       and Question__c NOT IN:commonQuestionIds
                                                       ];
	        if(!dqpList.isEmpty())
	        {
	           for(Discovery_Question_Product__c dqp:dqpList)
	            {
	                questionIds.add(dqp.Question__c);
	            } 
	        }
			
			system.debug('---questionIds----'+questionIds.size());
		
*/
}