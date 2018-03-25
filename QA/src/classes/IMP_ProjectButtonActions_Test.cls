/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: IMP_ProjectButtonActions_Handler test class
History
11/26/14     Samuel Oberes       Created     
------------------------------------------------------------*/
@isTest
public class IMP_ProjectButtonActions_Test {
	
	public static testmethod void testRemoveAssociatedRecords() {
		Test.startTest();

		// --------------------------------------------------------------------
        // INITIALIZATION
        List<Discovery_Workbook_Category__c> siteWorkbookCategoriesList;
        List<Project_log__c> projectIssuesList;
        List<Project_log__c> projectRisksList;
        List<Project_log__c> projectActionItemsList;
        List<Project_log__c> projectChangeRequestsList;
        List<Project_log__c> projectLessonsLearnedList;
        Project__c project;
        SubProject__c subproject;
        Site_Workbook__c siteWorkbook;
        Question_Category__c questionCategory;
        Discovery_Workbook_Category__c siteWorkbookCategory;
        Project_log__c projectIssueLog;
        Project_log__c projectRiskLog;
        Project_log__c projectActionItemLog;
        Project_log__c projectChangeRequestLog;
        Project_log__c projectLessonLearnedLog;
        List<Site_Workbook__c> siteWorkbooksList;
        //List<Project_Checklist__c> projectChecklistList;
        List<Project__c> listOfProjectsWithIds = new List<Project__c>();
        Set<Id> setOfProjectIds = new Set<Id>();
        

        // >>> BUILD PRE-PROJECT-CREATION RECORDS

        // build checklist categories
        /*List<Checklist_Category__c> checklistCategoriesList = new List<Checklist_Category__c>();
        for (Integer ctr = 1; ctr < 3; ctr++) {
            Checklist_Category__c checklistCategory = IMP_TestFactory_Helper.buildChecklistCategory();
            checklistCategory.Name = checklistCategory.Name + ctr;
            checklistCategory.Active__c = true;
            checklistCategoriesList.add(checklistCategory);  
        }
        insert checklistCategoriesList;*/


        
        // >>> BUILD PROJECT and PROJECT-RELATED RECORDS

        for (Integer numOfProjsToCreate = 0; numOfProjsToCreate < 2; numOfProjsToCreate++) {
        	// build project
	        project = IMP_TestFactory_Helper.buildProject(numOfProjsToCreate);
	        insert project;
	        listOfProjectsWithIds.add(project);

	        // build subproject
	        subproject = IMP_TestFactory_Helper.buildSubProject(project.Id);
	        insert subproject;

	        // build site workbooks
	        siteWorkbook = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(project.Id, subproject.Id);
            //siteWorkbook.SubProject__c = subproject.Id;
	        insert siteWorkbook;

	        // build question category
	        questionCategory = IMP_TestFactoryTemporary_Helper.buildDealershipNeed();
	        insert questionCategory;

	        // build 2 of the ff.:
	        //  > site workbook categories
	        //  > project issues
	        //  > project risks
	        //  > project action items
	        //  > project change requests
	        //  > project lessons learned

	        siteWorkbookCategoriesList = new List<Discovery_Workbook_Category__c>();
	        projectIssuesList  = new List<Project_log__c>();
	        projectRisksList = new List<Project_log__c>();
	        projectActionItemsList = new List<Project_log__c>();
	        projectChangeRequestsList = new List<Project_log__c>();
	        projectLessonsLearnedList = new List<Project_log__c>();

	        for (Integer ctr = 1; ctr < 3; ctr++) {
	        	siteWorkbookCategory = IMP_TestFactoryTemporary_Helper.buildDiscoveryWorkbookCategory(questionCategory.Id);
		        siteWorkbookCategory.Site_Workbook__c = siteWorkbook.Id;
		        siteWorkbookCategoriesList.add(siteWorkbookCategory);

		        // build project logs
		        projectIssueLog = IMP_TestFactory_Helper.buildIssueLog(project.Id, subproject.Id);
		        projectIssueLog.Description__c = projectIssueLog.Description__c + numOfProjsToCreate + '---' + ctr;
		        projectIssuesList.add(projectIssueLog);

		        projectRiskLog = IMP_TestFactory_Helper.buildRiskLog(project.Id, subproject.Id);
		        projectRiskLog.Description__c = projectRiskLog.Description__c + numOfProjsToCreate + '---' + ctr;
		        projectRisksList.add(projectRiskLog);

		        projectActionItemLog = IMP_TestFactory_Helper.buildActionItemLog(project.Id, subproject.Id);
		        projectActionItemLog.Description__c = projectActionItemLog.Description__c + numOfProjsToCreate + '---' + ctr;
		        projectActionItemsList.add(projectActionItemLog);

		        projectChangeRequestLog = IMP_TestFactory_Helper.buildChangeRequestLog(project.Id, subproject.Id);
		        projectChangeRequestLog.Description__c = projectChangeRequestLog.Description__c + numOfProjsToCreate + '---' + ctr;
		        projectChangeRequestsList.add(projectChangeRequestLog);

		        projectLessonLearnedLog = IMP_TestFactory_Helper.buildLessonLearnedLog(project.Id, subproject.Id);
		        projectLessonLearnedLog.Description__c = projectLessonLearnedLog.Description__c + numOfProjsToCreate + '---' + ctr;
		        projectLessonsLearnedList.add(projectLessonLearnedLog);
	        }
	        insert siteWorkbookCategoriesList;
	        insert projectIssuesList;
	        insert projectRisksList;
	        insert projectActionItemsList;
	        insert projectChangeRequestsList;
	        insert projectLessonsLearnedList;
        }
        

        // --------------------------------------------------------------------
        // TESTING PROPER

        for (Project__c p : listOfProjectsWithIds) {
        	setOfProjectIds.add(p.Id);
        }

        siteWorkbooksList = IMP_Project_Utility.retrieveSiteWorkbooks(setOfProjectIds);
        siteWorkbookCategoriesList = IMP_Project_Utility.retrieveWorkborkCategoryWithSubquery(siteWorkbooksList, null);

        // we initialized 1 siteworkbook per project, expect 2 created
        System.assertEquals(2, siteWorkbooksList.size());

        // we initialized 2 siteworkbook categories per project, expect 4 created
        System.assertEquals(4, siteWorkbookCategoriesList.size());
		
		// we initialized 2 checklist categories per project, expect 4 project checklists to get automatically created
		/*projectChecklistList = IMP_Project_Utility.retrieveProjectCheckList(setofproJectIds);
		System.assertEquals(4, projectChecklistList.size());*/

        // we initialized 2 action items per project, expect 4 created
        projectActionItemsList = [SELECT Id FROM Project_Log__c WHERE Project_Action_Items__c IN :setOfProjectIds];
        System.assertEquals(4, projectActionItemsList.size());

        // we initialized 2 change requests per project, expect 4 created
        projectChangeRequestsList = [SELECT Id FROM Project_Log__c WHERE Project_Change_Request__c IN :setOfProjectIds];
        System.assertEquals(4, projectChangeRequestsList.size());

        // we initialized 2 issues per project, expect 4 created
        projectIssuesList = [SELECT Id FROM Project_Log__c WHERE Project_Issue__c IN :setOfProjectIds];
        System.assertEquals(4, projectIssuesList.size());

        // we initialized 2 lessons learned per project, expect 4 created
        projectLessonsLearnedList = [SELECT Id FROM Project_Log__c WHERE Project_Lessons_Learned__c IN :setOfProjectIds];
        System.assertEquals(4, projectLessonsLearnedList.size());

        // we initialized 2 risks per project, expect 4 created
        projectRisksList = [SELECT Id FROM Project_Log__c WHERE Project_Risk__c IN :setOfProjectIds];
        System.assertEquals(4, projectRisksList.size());



        delete listOfProjectsWithIds;


        siteWorkbooksList = IMP_Project_Utility.retrieveSiteWorkbooks(setOfProjectIds);
        siteWorkbookCategoriesList = IMP_Project_Utility.retrieveWorkborkCategoryWithSubquery(siteWorkbooksList, null);

        // the BEFORE-DELETE context of the trigger should kick in and delete all associated records of the all the projects before deletion.
        // expect zeros across the board
        System.assertEquals(0, siteWorkbooksList.size());
		System.assertEquals(0, siteWorkbookCategoriesList.size());

		//projectChecklistList = IMP_Project_Utility.retrieveProjectCheckList(setOfProjectIds);
		//System.assertEquals(0, projectChecklistList.size());

        projectActionItemsList = [SELECT Id FROM Project_Log__c WHERE Project_Action_Items__c IN :setOfProjectIds];
        System.assertEquals(0, projectActionItemsList.size());

        projectChangeRequestsList = [SELECT Id FROM Project_Log__c WHERE Project_Change_Request__c IN :setOfProjectIds];
        System.assertEquals(0, projectChangeRequestsList.size());

        projectIssuesList = [SELECT Id FROM Project_Log__c WHERE Project_Issue__c IN :setOfProjectIds];
        System.assertEquals(0, projectIssuesList.size());

        projectLessonsLearnedList = [SELECT Id FROM Project_Log__c WHERE Project_Lessons_Learned__c IN :setOfProjectIds];
        System.assertEquals(0, projectLessonsLearnedList.size());

        projectRisksList = [SELECT Id FROM Project_Log__c WHERE Project_Risk__c IN :setOfProjectIds];
        System.assertEquals(0, projectRisksList.size());

        // if all the associated records were successfully deleted, the project should get successfully deleted as well
        System.assertEquals(0, [SELECT COUNT() FROM Project__c WHERE Id IN :setOfProjectIds]);



        Test.stopTest();
	}
}