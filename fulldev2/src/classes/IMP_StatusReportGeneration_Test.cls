/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_StatusReportGeneration_Controller test class
History
10/06/14    Michael Lasala      Created
10/22/14    Samuel Oberes       Updated constructorReport_Test: added Project_Issue__c, Project_Risk__c, and Project_Change_Request__c to satisfy "Issue_Fields", "Risk_Fields", and "Change_Request_Fields" validation rules.
11/27/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
12/02/14    Samuel Oberes       Added instantiation of the IMP_RegularExpressions__c custom setting
04/14/15    Venkata Shrivol     Added another instantiation of the IMP_RegularExpressions__c custom setting
                                and PSR__c field for Project-Log Records. 
06/26/15    Samuel Oberes       Changed ReplacementString__c from 'blank' to '-'
08/18/15    Samuel Oberes       relocated creation of regex data from constructorReport_Test to testSetup method
                                IMP_Market__c initialization in testSetup method
                                added groupingAndSorting_Test method
------------------------------------------------------------*/
@isTest
public class IMP_StatusReportGeneration_Test {
    
    public static String MARKET_AUTOMOTIVE = 'Automotive';
    public static String MARKET_NAME_1 = 'Alliance PC Solutions Admin';
    public static String MARKET_HEAVY_TRUCK = 'Heavy Truck';
    public static String MARKET_NAME_2 = 'Major Central Florence';

    @testSetup 
    static void setup()
    {
        List<IMP_RegularExpressions__c> regexList = new List<IMP_RegularExpressions__c>();
        List<IMP_Market__c> marketList = new List<IMP_Market__c>();
        
        IMP_RegularExpressions__c regex = new IMP_RegularExpressions__c();
        regex.Name = 'ExcelWorksheetNameValidCharacters';
        regex.Pattern__c = '[\\[\\]\\*\\?\\/\\\\\\:]';
        regex.ReplacementString__c = '_';
        regexList.add(regex);

        IMP_RegularExpressions__c regexNew = new IMP_RegularExpressions__c();
        regexNew.Name = 'ExcelSheetFileName';
        regexNew.Pattern__c = '[#;]';
        regexNew.ReplacementString__c = '-';
        regexList.add(regexNew);
        
        insert regexList;

        IMP_Market__c market1 = new IMP_Market__c();
        market1.Name = MARKET_NAME_1;
        market1.Logo__c = 'LOGOHERE';
        market1.Notice__c = 'NOTICEHERE';
        market1.Market__c = MARKET_AUTOMOTIVE;
        marketList.add(market1);

        IMP_Market__c market2 = new IMP_Market__c();
        market2.Name = MARKET_NAME_2;
        market2.Logo__c = 'LOGOHERE';
        market2.Notice__c = 'NOTICEHERE';
        market2.Market__c = MARKET_HEAVY_TRUCK;
        marketList.add(market2);

        insert marketList;
    }

    static testMethod void constructorPopup_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;

        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;

        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id', testProject.Id);
            IMP_StatusReportGeneration_Controller popup = new IMP_StatusReportGeneration_Controller();
        Test.StopTest();
        
        System.assertEquals(testProject.Id, testSubProject.Project__c);
        System.assertNotEquals(0, popup.subProjectWrapperList.size());
    }
    
    static testMethod void constructorPopupError_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;

        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id', testProject.Id);
            IMP_StatusReportGeneration_Controller popup = new IMP_StatusReportGeneration_Controller();
        Test.StopTest();
        
        System.assertEquals(0, popup.subProjectWrapperList.size());
        
        Boolean isError;
        List<Apexpages.Message> errorMessages = ApexPages.getMessages(); 
        for(Apexpages.Message msg: errorMessages){
            if(msg.getDetail().contains('No related SubProjects found')){
                isError = true;
            }
        }
        System.assert(isError);
    }

    static testMethod void generateReport_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;

        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;

        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id', testProject.Id);
            IMP_StatusReportGeneration_Controller popup = new IMP_StatusReportGeneration_Controller();
            popup.generateReport();
        Test.StopTest();
        
        System.assertEquals(testProject.Id, testSubProject.Project__c);
        System.assertNotEquals(0, popup.subProjectWrapperList.size());
        //System.assertEquals(Page.IMP_StatusReportContent.getURL()+'?market='+String.valueOf(testMarket.Name).replace(' ', '+')+'&subProjectIds='+testSubProject.Id, popup.generateReport().getURL());   
    }

    static testMethod void generateReportErrorSubProject_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;

        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;

        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id', testProject.Id);
            IMP_StatusReportGeneration_Controller popup = new IMP_StatusReportGeneration_Controller();
            popup.subProjectWrapperList.get(0).isSelected = false;
            popup.generateReport();
        Test.StopTest();
        
        System.assertEquals(testProject.Id, testSubProject.Project__c);
        System.assertNotEquals(0, popup.subProjectWrapperList.size());
        
        Boolean isError;
        List<Apexpages.Message> errorMessages = ApexPages.getMessages(); 
        for(Apexpages.Message msg: errorMessages){
            if(msg.getDetail().contains('At least 1 SubProject should be selected')){
                isError = true;
            }
        }
        System.assert(isError);
    }

    static testMethod void constructorReport_Test(){
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;

        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;

        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        //testProject.Dealer_Group__c = testAccount.Id;
        insert testProject;

        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;

        Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
        insert testProjectMilestone;

        List<Project_Activity__c> testProjectActivityList = new List<Project_Activity__c>();
        Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
        testProjectActivity.Planned_Start_Date__c = null;
        testProjectActivity.Planned_End_Date__c   = null;
        testProjectActivityList.add(testProjectActivity);

        Project_Activity__c testProjectActivity2 = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
        testProjectActivity2.Display_on_PSR__c = true;
        testProjectActivity2.Planned_Start_Date__c = null;
        testProjectActivity2.Planned_End_Date__c   = null;
        testProjectActivityList.add(testProjectActivity2);
        
        insert testProjectActivityList;

        //Retrieve Project_Log__c Record Types
        Schema.DescribeSObjectResult resSchema = Project_Log__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();

        //Retrieve Record Type Ids of Record Types which will be used for the report
        Id recordTypeIdIssue = recordTypeInfo.get(IMP_StatusReportGeneration_Controller.PROJECT_LOG_RECORDTYPE_ISSUE).getRecordTypeId();
        Id recordTypeIdRisk = recordTypeInfo.get(IMP_StatusReportGeneration_Controller.PROJECT_LOG_RECORDTYPE_RISK).getRecordTypeId();
        Id recordTypeIdChangeRequest = recordTypeInfo.get(IMP_StatusReportGeneration_Controller.PROJECT_LOG_RECORDTYPE_CHANGE_REQUEST).getRecordTypeId();

        Project_Log__c testIssueProjectLog = IMP_TestFactory_Helper.buildIssueLog(testProject.Id, testSubProject.Id);
        testIssueProjectLog.RecordTypeId = recordTypeIdIssue;
        testIssueProjectLog.Client_Issue_Owner__c = testContact.Id;
        testIssueProjectLog.PSR__c = true;
        testIssueProjectLog.Comments__c = '<Test for PSR<> Issue RQ-04391>';
        insert testIssueProjectLog;

        Project_Log__c testRiskProjectLog = IMP_TestFactory_Helper.buildRiskLog(testProject.Id, testSubProject.Id);
        testRiskProjectLog.RecordTypeId = recordTypeIdRisk;
        testRiskProjectLog.Client_Assignee__c = testContact.Id;
        testRiskProjectLog.PSR__c = true;
        testRiskProjectLog.Resolution_Response__c = '<Test> for <PSR> Issue <RQ-04391>';
        insert testRiskProjectLog;

        Project_Log__c testChangeRequestProjectLog = IMP_TestFactory_Helper.buildChangeRequestLog(testProject.Id, testSubProject.Id);
        testChangeRequestProjectLog.RecordTypeId = recordTypeIdChangeRequest;
        testChangeRequestProjectLog.Client_Approver__c = testContact.Id;
        testChangeRequestProjectLog.PSR__c = true;
        insert testChangeRequestProjectLog;

        SubProject_CDK_Contact__c testCDKContact = new SubProject_CDK_Contact__c();
        testCDKContact.SubProject__c = testSubProject.Id;
        testCDKContact.CDK_Contact__c = UserInfo.getUserId();
        insert testCDKContact;

        SubProject_Client_Contact__c testClientContact = new SubProject_Client_Contact__c();
        testClientContact.SubProject__c = testSubProject.Id;
        testClientContact.Client_Contact__c = testContact.Id;
        insert testClientContact;
        
        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('subProjectIds', testSubProject.Id);
            IMP_StatusReportGeneration_Controller report = new IMP_StatusReportGeneration_Controller();
        Test.StopTest();
        
        System.assertEquals(testProject.Id, testSubProject.Project__c);
        System.assertNotEquals(null, report.fileName);
        System.assertNotEquals(0, report.subProjectList.size());
        System.assertNotEquals(0, report.subProjectMilestoneMap.keySet().size());
        System.assertNotEquals(0, report.subProjectMilestoneMap.values().size());
        System.assertNotEquals(0, report.milestoneActivityMap.keySet().size());
        System.assertNotEquals(0, report.milestoneActivityMap.values().size());
        System.assertNotEquals(0, report.subProjectIssueMap.keySet().size());
        System.assertNotEquals(0, report.subProjectIssueMap.values().size());
        System.assertNotEquals(0, report.subProjectRiskMap.keySet().size());
        System.assertNotEquals(0, report.subProjectRiskMap.values().size());
        System.assertNotEquals(0, report.subProjectChangeRequestMap.keySet().size());
        System.assertNotEquals(0, report.subProjectChangeRequestMap.values().size());
        System.assertNotEquals(0, report.subProjectClientContactMap.keySet().size());
        System.assertNotEquals(0, report.subProjectClientContactMap.values().size());
        System.assertNotEquals(0, report.subProjectCDKContactMap.keySet().size());
        System.assertNotEquals(0, report.subProjectCDKContactMap.values().size());
    }

    // added by Sam 2015-08-18
    static testMethod void groupingAndSorting_Test()
    {
        /*
            CHECK SUBPROJECT SORTING BY: (NULLS LAST)
            CreatedDate

            CHECK MILESTONE SORTING BY: (NULLS LAST)
            Site_Name__c
            Process_Step__c
            Planned_End_Date__c
            Sort_Sequence__c

            CHECKING ACTIVIY SORTING BY: (NULLS LAST)
            Site_Name__c
            Sequence__c
            Planned_Start_Date__c

            CHECKING TASK SORTING BY: (NULLS LAST)
            Site_Name__c
            Sequence__c
            Planned_Start_Date__c

            CHECKING ISS/RISK/CR SORTING BY: (NULLS LAST)
            Site_Name__c
            CreatedDate
        */

        String EXPECTED_SP_HEALTH_INDICATOR = 'Green';
        String EXPECTED_FILENAME = 'TESTING - PSR - ' + Datetime.now().format('MMddyyyy');
        String EXPECT_ACCOUNT_NAME_1 = 'ACC1';
        String EXPECT_ACCOUNT_NAME_2 = 'ACC2';
        String EXPECT_ACCOUNT_NAME_3 = 'ACC3';
        String PROCESS_STEP_1 = '01-Implementation Discovery';
        String PROCESS_STEP_2 = '02-Project Mapping';
        String PROCESS_STEP_3 = '03-Site Readiness';
        Integer SORT_SEQ_1 = 1;
        Integer SORT_SEQ_2 = 2;
        Integer SORT_SEQ_3 = 3;
        Integer SEQ_1 = 1;
        Integer SEQ_2 = 2;
        Integer SEQ_3 = 3;
        Date PLANNED_START_DATE_1 = Date.today();
        Date PLANNED_START_DATE_2 = Date.today() + 1;
        Date PLANNED_START_DATE_3 = Date.today() + 2;
        Date PLANNED_END_DATE_1 = PLANNED_START_DATE_1 + 1;
        Date PLANNED_END_DATE_2 = PLANNED_START_DATE_2 + 1;
        Date PLANNED_END_DATE_3 = PLANNED_START_DATE_3 + 1;
        Date CREATEDDATE = Date.today();

        Account account1 = IMP_TestFactory_Helper.buildAccount();
        account1.Name = EXPECT_ACCOUNT_NAME_1;
        insert account1;

        Account account2 = IMP_TestFactory_Helper.buildAccount();
        account2.Name = EXPECT_ACCOUNT_NAME_2;
        insert account2;

        Account account3 = IMP_TestFactory_Helper.buildAccount();
        account3.Name = EXPECT_ACCOUNT_NAME_3;
        insert account3;

        Project__c project = IMP_TestFactory_Helper.buildProject(0);
        project.Name = 'TESTING';
        insert project;

        SubProject__c subProject1 = IMP_TestFactory_Helper.buildSubProject(project.Id);
        subProject1.SubProject_Health_Indicator__c = EXPECTED_SP_HEALTH_INDICATOR;
        subProject1.SubProject_Region__c = MARKET_NAME_1;
        insert subProject1;

        SubProject__c subProject2 = IMP_TestFactory_Helper.buildSubProject(project.Id);
        subProject2.SubProject_Region__c = MARKET_NAME_2;
        insert subProject2;

        CMF_Info__c cmfInfo1 = IMP_TestFactory_Helper.buildCMFInfo(account1.Id);
        cmfInfo1.Name = 'CMFINFO1';
        cmfInfo1.Ship_CMF__c = 'CMFINFO1';
        insert cmfInfo1;

        CMF_Info__c cmfInfo2 = IMP_TestFactory_Helper.buildCMFInfo(account2.Id);
        cmfInfo2.Name = 'CMFINFO2';
        cmfInfo2.Ship_CMF__c = 'CMFINFO2';
        insert cmfInfo2;

        CMF_Info__c cmfInfo3 = IMP_TestFactory_Helper.buildCMFInfo(account3.Id);
        cmfInfo3.Name = 'CMFINFO3';
        cmfInfo3.Ship_CMF__c = 'CMFINFO3';
        insert cmfInfo3;

        SubProjectSite__c site1 = IMP_TestFactory_Helper.buildSubProjectSite(null, subProject1.Id, cmfInfo1.Id);
        insert site1;

        SubProjectSite__c site1OfSubProject2 = IMP_TestFactory_Helper.buildSubProjectSite(null, subProject2.Id, cmfInfo1.Id);
        insert site1OfSubProject2;

        SubProjectSite__c site2 = IMP_TestFactory_Helper.buildSubProjectSite(null, subProject1.Id, cmfInfo2.Id);
        insert site2;

        SubProjectSite__c site3 = IMP_TestFactory_Helper.buildSubProjectSite(null, subProject1.Id, cmfInfo3.Id);
        insert site3;

        /*
            HIERARCHY:

            subProject1
                milestone1
                    activity1ofMilestone1 -> Display_on_PSR__c = true
                    activity2OfMilestone1
                    activity3OfMilestone1
                milestone2
                    activity1ofMilestone2
                        task1OfActivity1OfMilestone2 -> Display_on_PSR__c = true
                        task2OfActivity1OfMilestone2
                        task3OfActivity1OfMilestone2
                milestone3
            subProject2
                milestoneOfSubproject2 -> Display_on_PSR__c = true

        */

        Project_Milestone__c milestone1 = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject1.Id, 'M1 DISPLAY_ON_PSR = FALSE -> M1A1 DISPLAY_ON_PSR = TRUE ---> WILL BE PRESENT IN PSR');
        milestone1.Site__c = site1.Id;
        milestone1.Process_Step__c = PROCESS_STEP_1;
        milestone1.Planned_Start_Date__c = PLANNED_START_DATE_1;
        milestone1.Planned_End_Date__c = PLANNED_END_DATE_1;
        milestone1.Sort_Sequence__c = SORT_SEQ_1;
        insert milestone1;

        Project_Milestone__c milestone2 = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject1.Id, 'M2 DISPLAY_ON_PSR = FALSE -> M2A1 DISPLAY_ON_PSR = FALSE -> M2A1T1 DISPLAY_ON_PSR = TRUE ---> WILL BE PRESENT IN PSR');
        milestone2.Site__c = site2.Id;
        milestone2.Process_Step__c = PROCESS_STEP_2;
        milestone2.Planned_Start_Date__c = PLANNED_START_DATE_2;
        milestone2.Planned_End_Date__c = PLANNED_END_DATE_2;
        milestone2.Sort_Sequence__c = SORT_SEQ_2;
        insert milestone2;

        Project_Milestone__c milestone3 = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject1.Id, 'M3 DISPLAY_ON_PSR = FALSE -> WILL BE ABSENT IN PSR');
        milestone3.Site__c = site3.Id;
        milestone3.Process_Step__c = PROCESS_STEP_3;
        milestone3.Planned_Start_Date__c = PLANNED_START_DATE_3;
        milestone3.Planned_End_Date__c = PLANNED_END_DATE_3;
        milestone3.Sort_Sequence__c = SORT_SEQ_3;
        insert milestone3;

        Project_Milestone__c milestoneOfSubproject2 = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject2.Id, 'ONLY MILESTONE OF SUBPROJECT 2');
        milestoneOfSubproject2.Site__c = site1OfSubProject2.Id;
        milestoneOfSubproject2.Process_Step__c = PROCESS_STEP_1;
        milestoneOfSubproject2.Planned_Start_Date__c = PLANNED_START_DATE_1;
        milestoneOfSubproject2.Planned_End_Date__c = PLANNED_END_DATE_1;
        milestoneOfSubproject2.Sort_Sequence__c = SORT_SEQ_1;
        milestoneOfSubproject2.Display_on_PSR__c = true;
        insert milestoneOfSubproject2;

        Project_Activity__c activity1ofMilestone1 = IMP_TestFactory_Helper.buildProjectActivity(milestone1.Id);
        activity1ofMilestone1.Description__c = 'M1A1';
        activity1ofMilestone1.Sequence__c = SEQ_1;
        activity1ofMilestone1.Planned_Start_Date__c = PLANNED_START_DATE_1;
        activity1ofMilestone1.Planned_End_Date__c = PLANNED_END_DATE_1;
        activity1ofMilestone1.Display_on_PSR__c = true;
        insert activity1ofMilestone1;

        Project_Activity__c activity1ofMilestone2 = IMP_TestFactory_Helper.buildProjectActivity(milestone2.Id);
        activity1ofMilestone2.Description__c = 'M2A1';
        activity1ofMilestone2.Sequence__c = SEQ_1;
        activity1ofMilestone2.Planned_Start_Date__c = PLANNED_START_DATE_1;
        activity1ofMilestone2.Planned_End_Date__c = PLANNED_END_DATE_1;
        insert activity1ofMilestone2;

        Project_Activity__c activity2OfMilestone1 = IMP_TestFactory_Helper.buildProjectActivity(milestone1.Id);
        activity2OfMilestone1.Description__c = 'M1A2';
        activity2OfMilestone1.Sequence__c = SEQ_2;
        activity2OfMilestone1.Planned_Start_Date__c = PLANNED_START_DATE_2;
        activity2OfMilestone1.Planned_End_Date__c = PLANNED_END_DATE_2;
        insert activity2OfMilestone1;

        Project_Activity__c activity3OfMilestone1 = IMP_TestFactory_Helper.buildProjectActivity(milestone1.Id);
        activity3OfMilestone1.Description__c = 'M1A3';
        activity3OfMilestone1.Sequence__c = SEQ_3;
        activity3OfMilestone1.Planned_Start_Date__c = PLANNED_START_DATE_3;
        activity3OfMilestone1.Planned_End_Date__c = PLANNED_END_DATE_3;
        insert activity3OfMilestone1;

        Project_Task__c task1OfActivity1OfMilestone2 = IMP_TestFactory_Helper.buildProjectTask(activity1ofMilestone2.Id);
        task1OfActivity1OfMilestone2.Description__c = 'M2A1T1';
        task1OfActivity1OfMilestone2.Sequence__c = SEQ_1;
        task1OfActivity1OfMilestone2.Planned_Start_Date__c = PLANNED_START_DATE_1;
        task1OfActivity1OfMilestone2.Planned_End_Date__c = PLANNED_END_DATE_1;
        task1OfActivity1OfMilestone2.Display_on_PSR__c = true;
        insert task1OfActivity1OfMilestone2;

        Project_Task__c task2OfActivity1OfMilestone2 = IMP_TestFactory_Helper.buildProjectTask(activity1ofMilestone2.Id);
        task2OfActivity1OfMilestone2.Description__c = 'M2A1T2';
        task2OfActivity1OfMilestone2.Sequence__c = SEQ_2;
        task2OfActivity1OfMilestone2.Planned_Start_Date__c = PLANNED_START_DATE_2;
        task2OfActivity1OfMilestone2.Planned_End_Date__c = PLANNED_END_DATE_2;
        insert task2OfActivity1OfMilestone2;

        Project_Task__c task3OfActivity1OfMilestone2 = IMP_TestFactory_Helper.buildProjectTask(activity1ofMilestone2.Id);
        task3OfActivity1OfMilestone2.Description__c = 'M2A1T3';
        task3OfActivity1OfMilestone2.Sequence__c = SEQ_3;
        task3OfActivity1OfMilestone2.Planned_Start_Date__c = PLANNED_START_DATE_3;
        task3OfActivity1OfMilestone2.Planned_End_Date__c = PLANNED_END_DATE_3;
        insert task3OfActivity1OfMilestone2;

        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('subProjectIds', subProject1.Id + ',' + subproject2.Id);
            IMP_StatusReportGeneration_Controller psrController = new IMP_StatusReportGeneration_Controller();
        Test.StopTest();


        // ASSERTIONS:

        // check proper filename
        System.assertEquals(EXPECTED_FILENAME, psrController.fileName);

        // expect proper region-to-market mapping
        System.assertEquals(MARKET_AUTOMOTIVE, psrController.subprojectMarkets.get(subproject1.Id));
        System.assertEquals(MARKET_HEAVY_TRUCK, psrController.subprojectMarkets.get(subproject2.Id));

        // subProject1 & subProject2
        System.assertEquals(2, psrController.subProjectList.size());

        // expect proper grouping, sorting, and total count of created records-per-type
        for (SubProject__c sp : psrController.subProjectList)
        {
            // subProject1 hierarchy
            if (sp.Id == subProject1.Id)
            {
                System.assertEquals(EXPECTED_SP_HEALTH_INDICATOR, sp.SubProject_Health_Indicator__c);

                // expecting milestone list with 2 milestones in it
                if (psrController.subProjectMilestoneMap.get(sp.Id).get(true) != null)
                {
                    List<Project_Milestone__c> milestonesList = psrController.subProjectMilestoneMap.get(sp.Id).get(true);
                    System.assertEquals(2, milestonesList.size());
                    System.assertEquals(milestone1.Id, milestonesList.get(0).Id);
                    System.assertEquals(milestone2.Id, milestonesList.get(1).Id);
                    // milestone3 should not appear here because it, and its children, wasn't marked to be displayed in the PSR (Display_on_PSR__c == false)

                    // expecting activity list with 1 activity in it because an activity's Display_on_PSR__c is set to true
                    if (psrController.milestoneActivityMap.get(milestone1.Id).get(true) != null)
                    {
                        List<Project_Activity__c> activitiesList = psrController.milestoneActivityMap.get(milestone1.Id).get(true);
                        System.assertEquals(1, activitiesList.size());
                        System.assertEquals(activity1ofMilestone1.Id, activitiesList.get(0).Id);
                        System.assertEquals(true, activitiesList.get(0).Display_on_PSR__c);
                        // activity2OfMilestone1 should not appear here because it wasn't marked to be displayed in the PSR (Display_on_PSR__c == false)
                        // activity3OfMilestone1 should not appear here because it wasn't marked to be displayed in the PSR (Display_on_PSR__c == false)
                    }
                    else
                    {
                        System.assert(psrController.milestoneActivityMap.get(milestone1.Id).get(true) == null, 'This is failing because milestoneActivityMap SHOULD contain a list of 1 activity, but getting a null list instead.');
                    }

                    // expecting activity list with 1 activity in it because an activity's task's Display_on_PSR__c is set to true
                    if (psrController.milestoneActivityMap.get(milestone2.Id).get(true) != null)
                    {
                        List<Project_Activity__c> activitiesList = psrController.milestoneActivityMap.get(milestone2.Id).get(true);
                        System.assertEquals(1, activitiesList.size());
                        System.assertEquals(activity1ofMilestone2.Id, activitiesList.get(0).Id);
                        System.assertEquals(false, activitiesList.get(0).Display_on_PSR__c);

                        // expecting task list with 1 task in it because an its Display_on_PSR__c is set to true
                        if (psrController.activityTaskMap.get(activity1ofMilestone2.Id).get(true) != null)
                        {
                            List<Project_Task__c> tasksList = psrController.activityTaskMap.get(activity1ofMilestone2.Id).get(true);
                            System.assertEquals(1, tasksList.size());
                            System.assertEquals(task1OfActivity1OfMilestone2.Id, tasksList.get(0).Id);
                            System.assertEquals(true, tasksList.get(0).Display_on_PSR__c);
                            // task2OfActivity1OfMilestone2 should not appear here because it wasn't marked to be displayed in the PSR (Display_on_PSR__c == false)
                            // task3OfActivity1OfMilestone2 should not appear here because it wasn't marked to be displayed in the PSR (Display_on_PSR__c == false)
                        }
                        else
                        {
                            System.assert(psrController.activityTaskMap.get(task1OfActivity1OfMilestone2.Id).get(true) == null, 'This is failing because activityTaskMap SHOULD contain a list of 1 task, but getting a null list instead.');
                        }
                    }
                    else
                    {
                        System.assert(psrController.milestoneActivityMap.get(milestone2.Id).get(true) == null, 'This is failing because milestoneActivityMap SHOULD contain a list of 1 activity, but getting a null list instead.');
                    }
                }
                else
                {
                    System.assert(psrController.subProjectMilestoneMap.get(sp.Id).get(true) == null, 'This is failing because subProjectMilestoneMap SHOULD contain a list of 2 milestones, but getting a null list instead.');
                }
            }

            // subProject2 hierarchy
            if (sp.Id == subProject2.Id)
            {
                // expecting milestone list is null because only milestones with an activity or task are to be fetched.
                if (psrController.subProjectMilestoneMap.get(sp.Id).get(true) == null)
                {
                    System.assertEquals(null, psrController.subProjectMilestoneMap.get(sp.Id).get(true));
                }
                else
                {
                    System.assert(psrController.subProjectMilestoneMap.get(sp.Id).get(true) != null, 'This is failing because subProjectMilestoneMap SHOULD contain a NULL list of 0 milestones, but getting a list filled with records instead.');
                }
            }
        }
    }
}