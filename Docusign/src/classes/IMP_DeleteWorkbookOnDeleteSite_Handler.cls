/*
*-----HISTORY--------
* 05/28/2015 Venkata Shrivol - Created
*
07/14/15 Venkata Shrivol - Updated accordingly to delete all the related object records
						   instead of only site-workbook records
*/
public with sharing class IMP_DeleteWorkbookOnDeleteSite_Handler 
{
	public static void deleteWorkbookOnDeleteSites(set<Id> SubProjectSiteIds)
	{
		list<Discovery_Workbook_Category__c> siteWorkboookcategoriesToDelete;
		set<Id> siteWorkbookIdSet = new set<Id>();
		list<Discovery_Workbook_Category__c> siteWbCategoriesToBeDeleted = new List<Discovery_Workbook_Category__c>();
        list<Discovery_Answer_Workbook_Category__c> ansWkbkCategories = new list<Discovery_Answer_Workbook_Category__c>();
        list<Answer__c> answersTobeDeleted = new list<Answer__c>();
		list<Site_Workbook__c> siteWorkbooksToDelete = [select Id from Site_Workbook__c where Site__c IN (select Account__c from SubProjectSite__c where Id IN:SubProjectSiteIds)];
		
		if(!siteWorkbooksToDelete.isEmpty())
		{
			for(Site_Workbook__c swc:siteWorkbooksToDelete)
			{
				siteWorkbookIdSet.add(swc.Id);
			}
			if(!siteWorkbookIdSet.isEmpty())
			{
				siteWorkboookcategoriesToDelete = [
				 	select Id,
				 	(select Id from Discovery_Answer_Workbook_Categories__r)
				 	from Discovery_Workbook_Category__c where Site_Workbook__c IN:siteWorkbookIdSet];
				
				answersTobeDeleted =[select Id from Answer__c where Discovery_Site_Workbook__c IN:siteWorkbookIdSet];
				if(!siteWorkboookcategoriesToDelete.isEmpty())
				{
					for(Discovery_Workbook_Category__c dwc:siteWorkboookcategoriesToDelete)
		        	{
		        		ansWkbkCategories.addAll(dwc.Discovery_Answer_Workbook_Categories__r);	
		        	}
				}
				if(!ansWkbkCategories.isEmpty())
				{
					try{delete ansWkbkCategories;}
					catch(Exception e)
					{
						system.debug(e);
					}
				}
				
			}
			try { delete siteWorkbooksToDelete; }
			catch(Exception e){ system.debug('---EXCEPTION-------'+e); }
			try {
				 delete siteWorkboookcategoriesToDelete;
				 delete answersTobeDeleted;
				}
				catch(Exception e){ system.debug('---EXCEPTION-------'+e); }
		}
	}

}