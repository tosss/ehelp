/*
*
* 05/19/2015    Venkata Shrivol - Created
* Description - Handler Class for IMP_SiteProds Trigger for Inserting answer records on Discovery
*               site workbook category if any Products are added to SubProjectSites on SubProject.
*-----HISTORY--------
* 06/07/15 Venkata Shrivol 
*Testing
*/

public with sharing class IMP_AddAnsOnSiteProdsInsert_Handler 
{
    public static void addAnswers(set<Id> siteProdIds)
    {
        set<Id> subProjectIds = new set<Id>();
        set<Id> productIds = new set<Id>();
        set<Id> uniqueQuestionIds = new set<Id>();
        set<Id> siteAccountIds = new set<Id>();
        set<Id> uniqueQuestionIdSecondSet = new set<Id>();
        set<Id> existingQuestionIds = new set<Id>();
        set<Id> workbookCategoryIds = new set<Id>();
        set<String> marketSet = new Set<String>();
        set<String> projectTypeSet = new Set<String>();
        set<Id> allWkbkCategoryIds = new set<Id>();
        set<Id> allExistingQuestionsPerOneSW = new set<Id>(); 
        set<Id> forOnlyAnsWkbkCatQuestionSet = new set<Id>();
        set<Id> forOnlyAnsWkbkCatDWCSet = new set<Id>();
        set<Id> forOnlyAnsWkbkCatSiteWkbkSet = new set<Id>();
        
        
        list<Site_Workbook__c> existingWorkbooks;
        list<Discovery_Workbook_Category__c> existingWorkbookCategories;
        list<Discovery_Question_Category__c> questionCategoryList;
        list<Answer__c> discoveryAnswersForInsertList = new list<Answer__c>();
        list<Discovery_Workbook_Category__c> discoveryWBCategoriesToUpdate = new list<Discovery_Workbook_Category__c>();
        list<Discovery_Workbook_Category__c> discoveryWBCategoriesToInsert = new list<Discovery_Workbook_Category__c>();
        list<Discovery_Answer_Workbook_Category__c> discoveryAnswerWkbkCatListToInsert = new list<Discovery_Answer_Workbook_Category__c>();
        //list<Discovery_Workbook_Category__c> allWkbkCategories = new list<Discovery_Workbook_Category__c>();
        
        //boolean doBreak = false;
        
        map<Id,set<Id>> categorytToQuestionMap = new map<Id, set<Id>>();
        map<Id,set<Id>> existingSiteWkbkToQuestionCategoryMap = new map<Id,set<Id>>();
        map<Id,set<Id>> existingSWBCategoryToQuestionMap = new map<Id, Set<Id>>();
        map<Id,set<Id>> existingSiteWkbkToQuestionMap = new map<Id, set<Id>>();
        map<Id,set<Id>> existingSiteWkbkToSWBCategoryMap = new map<Id,set<Id>>();
        map<Id,Id>  SiteWorkbookToProjectMap = new map<Id,Id>();
        map<Id,Id> wkbkCategoryToAnswerMap = new map<Id,Id>();
        Map<Id,Id> wkbkCategoryToQuestionMap = new Map<Id,Id>();
        
        
        list<Site_Product__c> insertedSiteProds = [
        		select SubProject__c, SubProject__r.Project__c, SubProject__r.Market__c, SubProject__r.Project_Type__c, Product__c,
        		SubProjectSite__r.Account__c 
        		from Site_Product__c where Id IN: siteProdIds];
        
        
        for(Site_Product__c sp:insertedSiteProds)
        {
            subProjectIds.add(sp.SubProject__c);
            productIds.add(sp.Product__c);
            marketSet.add(sp.SubProject__r.Market__c);
            projectTypeSet.add(sp.SubProject__r.Project_Type__c);
            siteAccountIds.add(sp.SubProjectSite__r.Account__c);
        }
        //----For Debugging Purposes-----
        system.debug('-------marketSet--------'+marketSet);
        system.debug('--------projectTypeSet--------'+projectTypeSet);
        
        if(!subProjectIds.isEmpty())
        {
            existingWorkbooks = [
            	select Id,Project__c, SubProject__c  
            	from Site_Workbook__c 
            	where SubProject__c IN:subProjectIds and Site__c IN:siteAccountIds];
        }
        for(Site_Workbook__c sw:existingWorkbooks)
        {
            SiteWorkbookToProjectMap.put(sw.Id, sw.SubProject__c);
        }
        
        if(!subProjectIds.isEmpty())
        {
            existingWorkbookCategories = [
                select Id, Site_Workbook__c, Count_of_Questions__c, Question_Category__c, 
                (select Answer__r.Question__c from Discovery_Answer_Workbook_Categories__r) 
                from Discovery_Workbook_Category__c 
                where Site_Workbook__c IN :SiteWorkbookToProjectMap.keySet()];
            
        }
        if(existingWorkbookCategories!=null && !existingWorkbookCategories.isEmpty())
        {
            for(Discovery_Workbook_Category__c dwc:existingWorkbookCategories)
            {
                Set<Id> tempSet = existingSiteWkbkToQuestionCategoryMap.keySet().contains(dwc.Site_Workbook__c) ? existingSiteWkbkToQuestionCategoryMap.get(dwc.Site_Workbook__c): new Set<Id>();
                tempSet.add(dwc.Question_Category__c);
                existingSiteWkbkToQuestionCategoryMap.put(dwc.Site_Workbook__c, tempSet);
                for(Discovery_Answer_Workbook_Category__c danswkbk:dwc.Discovery_Answer_Workbook_Categories__r)
                {
                    existingQuestionIds.add(danswkbk.Answer__r.Question__c);
                }
                existingSWBCategoryToQuestionMap.put(dwc.Id, existingQuestionIds);
                Set<Id> wkbkCatSet = existingSiteWkbkToSWBCategoryMap.keySet().contains(dwc.Site_Workbook__c) ? existingSiteWkbkToSWBCategoryMap.get(dwc.Site_Workbook__c): new Set<Id>();
                wkbkCatSet.add(dwc.Id);
                existingSiteWkbkToSWBCategoryMap.put(dwc.Site_Workbook__c, wkbkCatSet);
            }
            system.debug('------existingSWBCategoryToQuestionMap-------'+existingSWBCategoryToQuestionMap.keySet());
            
            for(Id siteWkbkId:existingSiteWkbkToSWBCategoryMap.keySet())
            {
                for(Id siteWkbkCatId:existingSiteWkbkToSWBCategoryMap.get(siteWkbkId))
                {
                    allExistingQuestionsPerOneSW.addAll(existingSWBCategoryToQuestionMap.get(siteWkbkCatId));
                }
                existingSiteWkbkToQuestionMap.put(siteWkbkId, allExistingQuestionsPerOneSW);	
            }
            
            string query = 'SELECT ID, Question__c, Product__r.Solution__r.Question_Category__c FROM   Discovery_Question_Product__c  WHERE  Product__c IN :productIds and  Question__r.Active__c =  true and (Question__r.Market__c includes(';
            for(string s:marketSet)
            {
                query += '\''+s+'\''+',';
            }
            query = query.removeEnd(',');
            query += ') and Question__r.Project_Type__c includes(';
            for(string s:projectTypeSet)
            {
                query += '\''+s+'\''+',';
            }
            query = query.removeEnd(',');
            query += '))';
            
            system.debug('-------Query-------'+query);
            list<Discovery_Question_Product__c> dqpList = Database.Query(query);
            /*[
				SELECT ID, Question__c, Product__r.Solution__r.Question_Category__c
				FROM   Discovery_Question_Product__c 
				WHERE  Question__r.Active__c =  true 
				and    (
				(Product__c IN :productIds)
				and    
				(Question__r.Market__c IN :marketSet and Question__r.Project_Type__c IN :projectTypeSet) 
				)
				
				];*/
            for(Discovery_Question_Product__c dqp: dqpList)
            {
                set<Id> tempSet = categorytToQuestionMap.containsKey(dqp.Product__r.Solution__r.Question_Category__c) ? categorytToQuestionMap.get(dqp.Product__r.Solution__r.Question_Category__c) : new set<Id>();
                tempSet.add(dqp.Question__c);
                categorytToQuestionMap.put(dqp.Product__r.Solution__r.Question_Category__c, tempSet);   
            }
            
            system.debug('------categorytToQuestionMap------'+categorytToQuestionMap.keySet());
            
            // To add Question and Answers for the exisitng Categories
            for(Discovery_Workbook_Category__c dwc:existingWorkbookCategories)
            {
                if(categorytToQuestionMap.keySet().contains(dwc.Question_Category__c))
                {
                    for(Id qId:categorytToQuestionMap.get(dwc.Question_Category__c))
                    {
                        if(!existingSWBCategoryToQuestionMap.get(dwc.Id).contains(qId))
                        {
                            if(!uniqueQuestionIds.contains(qId))
                            {
                                Answer__c createdAnswer = new Answer__c();
                                //createdAnswer.Discovery_Workbook_Category__c = dwc.Id;
                                createdAnswer.Question__c = qId;
                                createdAnswer.Discovery_Site_Workbook__c = dwc.Site_Workbook__c;
                                discoveryAnswersForInsertList.add(createdAnswer);
                                uniqueQuestionIds.add(qId);
                                allWkbkCategoryIds.add(dwc.Id);
                                //wkbkCategoryToAnswerMap.put()
                            }
                        }
                    }
                    
                    // for every category the questions should be unique
                    uniqueQuestionIds.clear();
                    if(discoveryAnswersForInsertList.size()>0)
                    {
                        dwc.Count_of_Questions__c = dwc.Count_of_Questions__c + discoveryAnswersForInsertList.size();
                        discoveryWBCategoriesToUpdate.add(dwc); 
                    }
                }
            }
            
            //To add new Categories into Workbook
            for(Id qId:categorytToQuestionMap.keySet())
            {
                for(Id sId:existingSiteWkbkToQuestionCategoryMap.keySet())
                {
                    if(!existingSiteWkbkToQuestionCategoryMap.get(sId).contains(qId))
                    {
                        Discovery_Workbook_Category__c createdSiteWkbookCategory = new Discovery_Workbook_Category__c();
                        createdSiteWkbookCategory.Site_Workbook__c = sId;
                        createdSiteWkbookCategory.Question_Category__c = qId; //questionCategory.Id;
                        createdSiteWkbookCategory.Count_of_Questions__c = categorytToQuestionMap.get(qId).size();
                        createdSiteWkbookCategory.SubProject__c = SiteWorkbookToProjectMap.get(sId);
                        //createdSiteWkbookCategory.Project__c = SiteWorkbookToProjectMap.get(sId).Project__c;
                        //4.3. Add new Discovery_Workbook_Category__c to insertlist
                        discoveryWBCategoriesToInsert.add(createdSiteWkbookCategory);
                    }
                }
            }
            if(!discoveryWBCategoriesToInsert.isEmpty())
            {
                try { insert discoveryWBCategoriesToInsert;}
                catch(Exception ex){ system.debug('------Exception------'+ex);}
                for(Discovery_Workbook_Category__c dwc:discoveryWBCategoriesToInsert)
                {
                    allWkbkCategoryIds.add(dwc.Id);
                }
            }
            system.debug('------existingSiteWkbkToQuestionMap-------'+existingSiteWkbkToQuestionMap);
            //To add new answers for the new Categories inserted into Workbook
            for(Discovery_Workbook_Category__c dwc:discoveryWBCategoriesToInsert)
            {
                for(Id qId:categorytToQuestionMap.get(dwc.Question_Category__c))
                {
                    system.debug('-----DWC SiteWorkbookId after Insert----'+dwc.Site_Workbook__c);
                    if(!existingSiteWkbkToQuestionMap.get(dwc.Site_Workbook__c).contains(qId))
                    {
                        if(!uniqueQuestionIdSecondSet.contains(qId))
                        {
                            Answer__c createdAnswer = new Answer__c();
                            //createdAnswer.Discovery_Workbook_Category__c = dwc.Id;
                            createdAnswer.Question__c = qId;
                            createdAnswer.Discovery_Site_Workbook__c = dwc.Site_Workbook__c;
                            discoveryAnswersForInsertList.add(createdAnswer);
                            uniqueQuestionIdSecondSet.add(qId);
                        }
                    }
                    else 
                    {
                        // For creating answer workbook categories of duplicate questions
                        forOnlyAnsWkbkCatQuestionSet.add(qId);
                        forOnlyAnsWkbkCatDWCSet.add(dwc.Id);
                        forOnlyAnsWkbkCatSiteWkbkSet.add(dwc.Site_Workbook__c);
                    }
                }
            }
            system.debug('------forOnlyAnsWkbkCatQuestionSet-------'+forOnlyAnsWkbkCatQuestionSet);
            system.debug('------forOnlyAnsWkbkCatDWCSet-------'+forOnlyAnsWkbkCatDWCSet);
            system.debug('---------forOnlyAnsWkbkCatSiteWkbkSet----'+forOnlyAnsWkbkCatSiteWkbkSet);
            
            if(!discoveryAnswersForInsertList.isEmpty())
            {
                try { insert discoveryAnswersForInsertList;}
                catch(Exception ex){ system.debug('------Exception------'+ex);}
                
                for(Id dWkbkCatId:allWkbkCategoryIds)
                {
                    for(Answer__c ans:discoveryAnswersForInsertList)
                    {
                        Discovery_Answer_Workbook_Category__c createdAnswerWkbkCat = new Discovery_Answer_Workbook_Category__c();
                        createdAnswerWkbkCat.Answer__c = ans.Id;
                        createdAnswerWkbkCat.Discovery_Workbook_Category__c = dWkbkCatId;
                        discoveryAnswerWkbkCatListToInsert.add(createdAnswerWkbkCat);
                    }
                }
            }
            
            list<Answer__c> tempAnswerList = [
                select Id, Any_Answer__c 
                from Answer__c 
                where Question__c IN:forOnlyAnsWkbkCatQuestionSet and
                Discovery_Site_Workbook__c IN:forOnlyAnsWkbkCatSiteWkbkSet
            ];
            
            for(Id dWkbkCatId:forOnlyAnsWkbkCatDWCSet)
            {
                for(Answer__c ans:tempAnswerList)
                {
                    Discovery_Answer_Workbook_Category__c createdAnswerWkbkCat = new Discovery_Answer_Workbook_Category__c();
                    createdAnswerWkbkCat.Answer__c = ans.Id;
                    if(ans.Any_Answer__c == true)
                    {
                        createdAnswerWkbkCat.Answer_Completed__c = true; 
                    }
                    createdAnswerWkbkCat.Discovery_Workbook_Category__c = dWkbkCatId;
                    discoveryAnswerWkbkCatListToInsert.add(createdAnswerWkbkCat);
                }	
            }                
            if(!discoveryAnswerWkbkCatListToInsert.isEmpty())
            {
                insert discoveryAnswerWkbkCatListToInsert;
            }  
            if(!discoveryWBCategoriesToUpdate.isEmpty())
            {
                try { update discoveryWBCategoriesToUpdate;}
                catch(Exception ex){ system.debug('------Exception------'+ex);}
            }  
        }
        
    }   
    
}