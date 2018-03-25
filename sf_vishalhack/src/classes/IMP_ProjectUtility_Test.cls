/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_ProjectUtility test class
History
09/17/14    Michael Lasala      Created
10/01/14    Rey Austral         Add Dealer Group in subproject, and change the value of Planned_Start_Date_Offset__c
10/25/14    Karl Simon          Updated test data creation for Project Activity records to accommodate recent Validation Rules added
for CDK Assignee requirement when a non-null Actual End Date is applied, and ensuring Planned Start/End and Actual
Start Dates exist when inserting a record with a non-null Actual End Date.
11/07/14    Karl Simon          Updated updateMilestoneActualEndDateSuccess_Test() to include a 2nd (non-terminal) Project Activity to simulate
a proper success test.
11/14/14    Samuel Oberes       renamed getStandardMilestonesNoMilestones_Test to getStandardMilestonesNoMilestonesifNoProjAct_Test
updated method updateMilestoneActualEndDateSuccess_Test -- replaced hardcoded user IDs with newly built users
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
01/03/15    Karl Simon          Added CMF_Info and SubprojectSite record generation and insertion logic into the getStandardMilestones_Test and
getStandardMilestonesNoMilestonesifNoProjAct_Test methods.  The addition accommodates the decommissioning of prior functionality that auto-generated
a Subproject Site upon population or change of the Subproject__c.Main_Site__c  field (which is planned for de-commission during Phase 1 R3).
01/06/15    Samuel Oberes       Added test getTopParentAccountId_Test
04/29/15    Samuel Oberes       commented out getStandardMilestones_Test and getStandardMilestonesNoMilestonesifNoProjAct_Test -- functionality not used anymore
06/07/16    Venkata Shrivol     updated the test class with new userRoles and runAs method to overcome the subproject privacy owd issues
06/05/17    Venkata Shrivol     commented validateMilestoneStatusError_Test method
------------------------------------------------------------*/
@isTest
public class IMP_ProjectUtility_Test {
    
    //static testMethod void getStandardMilestones_Test(){
    //    createCustomSettings();
    
    //    Account testAccount = IMP_TestFactory_Helper.buildAccount();
    //    insert testAccount;
    
    //    Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
    //    testOpportunity.AccountId = testAccount.Id;
    //    testOpportunity.ADP_Opportunity_Owner__c = UserInfo.getUserId();
    //    insert testOpportunity;
    
    //    Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
    //    insert testDealershipNeeded;
    
    //    Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
    //    insert testSolution;
    
    //    Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
    //    insert testProduct;
    
    //    Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
    //    insert testProject;
    
    //    SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
    //    testSubProject.Estimated_Install_Date_EID__c = Date.today();
    //    testSubProject.Dealer_Group__c = testAccount.Id;
    //    insert testSubProject;
    
    //    SubProject_Product__c testSubProjectProduct = IMP_TestFactory_Helper.buildSubProjectProduct(testSubProject.Id, testProduct.Id);
    //    insert testSubProjectProduct;
    
    //    CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
    //    insert testCMFInfo;
    
    //    SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.Id, testSubProject.Id, testCMFInfo.Id);
    //    insert testSubProjectSite;
    
    //    SubProjectOpp__c testSubProjectOpportunity = IMP_TestFactory_Helper.buildSubProjectOpportunity(testSubProject.Id);
    //    testSubProjectOpportunity.Opportunity__c = testOpportunity.Id;
    //    insert testSubProjectOpportunity;
    
    //    SubProject_External_Related_Entity__c testSubProjectExternalEntity = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
    //    insert testSubProjectExternalEntity;
    
    //    List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
    //    Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
    //    testMilestoneDefinitionList.add(testMilestoneDefinition);
    
    //    //Milestone_Definition__c testMilestoneDefinition2 = new Milestone_Definition__c();
    //    //testMilestoneDefinition2.Description__c = 'Test Milestone Definition';
    //    //testMilestoneDefinition2.Market__c = 'Drive - Baseline;Dash - Small Auto;';
    //    //testMilestoneDefinition2.Active__c = true;
    //    //testMilestoneDefinitionList.add(testMilestoneDefinition2);
    
    //    insert testMilestoneDefinitionList;
    
    //    Activity_Definition__c testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
    //    testActivityDefinition.Offset_Criteria__c = IMP_Project_Utility.OFFSET_CRITERIA_ESTIMATED_INSTALL;
    //    testActivityDefinition.Planned_Start_Date_Offset__c = 3;
    //    testActivityDefinition.Planned_End_Date_Offset__c = 2;
    //    insert testActivityDefinition;
    
    //    //Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct = new Project_Milestone_Definition_Product__c();
    //    //testProjectMilestoneDefinitionProduct.Milestone_Definition__c = testMilestoneDefinition.Id;
    //    ////testProjectMilestoneDefinitionProduct.Milestone_Definition__c = testMilestoneDefinition2.Id;
    //    //testProjectMilestoneDefinitionProduct.Product__c = testProduct.Id;
    //    //insert testProjectMilestoneDefinitionProduct;
    
    //    Test.StartTest();
    //    IMP_Project_Utility.getStandardMilestones(testSubProject.Id);
    //    Test.StopTest();
    
    //    List<Project_Milestone__c> createdProjectMilestoneList = [SELECT Id FROM Project_Milestone__c WHERE SubProject__c =: testSubProject.Id];
    //    List<Project_Activity__c> createdProjectActivityList = [SELECT Id FROM Project_Activity__c WHERE Milestone__c =: createdProjectMilestoneList.get(0).Id];
    //    SubProject__c updatedSubProject = [SELECT Milestones_Auto_Generated_Flag__c FROM SubProject__c WHERE Id =: testSubProject.Id];
    
    //    System.assertNotEquals(0, createdProjectMilestoneList.size());
    //    System.assertNotEquals(0, createdProjectActivityList.size());
    //    System.assertEquals(true, updatedSubProject.Milestones_Auto_Generated_Flag__c);
    //}
    
    //static testMethod void getStandardMilestonesNegative_Test(){
    //    Project__c testProject = new Project__c();
    //    testProject.Name = 'Test Project';
    //    insert testProject;
    
    //    SubProject__c testSubProject = new SubProject__c();
    //    testSubProject.SubProject_Name__c = 'Test SubProject';
    //    testSubProject.Project__c = testProject.Id;
    //    testSubProject.Project_Type__c = 'Upgrade';
    //    testSubProject.Market__c = 'Drive - Baseline';
    //    testSubProject.Number_of_Rooftops__c = 1;
    //    testSubProject.Number_of_User_Connections__c = 1;
    //    testSubProject.Estimated_Install_Date_EID__c = Date.today();
    //    insert testSubProject;
    
    //    Test.StartTest();
    //        String testString = IMP_Project_Utility.getStandardMilestones(testSubProject.Id);
    //    Test.StopTest();
    
    //    System.assertEquals('Please create Product/s', testString);
    //}
    
    //static testMethod void getStandardMilestonesNoMilestonesifNoProjAct_Test(){
    //    createCustomSettings();
    
    //    Account testAccount = IMP_TestFactory_Helper.buildAccount();
    //    insert testAccount;
    
    //    Opportunity testOpportunity = IMP_TestFactory_Helper.buildOpportunity();
    //    testOpportunity.AccountId = testAccount.Id;
    //    testOpportunity.ADP_Opportunity_Owner__c = UserInfo.getUserId();
    //    insert testOpportunity;
    
    //    Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
    //    insert testDealershipNeeded;
    
    //    Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
    //    insert testSolution;
    
    //    Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
    //    insert testProduct;
    
    //    Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
    //    insert testProject;
    
    //    SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
    //    testSubProject.Estimated_Install_Date_EID__c = Date.today();
    //    testSubProject.Dealer_Group__c = testAccount.Id;
    //    insert testSubProject;
    
    //    SubProject_Product__c testSubProjectProduct = IMP_TestFactory_Helper.buildSubProjectProduct(testSubProject.Id, testProduct.Id);
    //    insert testSubProjectProduct;
    
    //    CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
    //    insert testCMFInfo;
    
    //    SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.Id, testSubProject.Id, testCMFInfo.Id);
    //    insert testSubProjectSite;
    
    //    SubProjectOpp__c testSubProjectOpportunity = IMP_TestFactory_Helper.buildSubProjectOpportunity(testSubProject.Id);
    //    testSubProjectOpportunity.Opportunity__c = testOpportunity.Id;
    //    insert testSubProjectOpportunity;
    
    //    List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
    //    Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
    //    testMilestoneDefinitionList.add(testMilestoneDefinition);
    
    //    Test.StartTest();
    //    String testString = IMP_Project_Utility.getStandardMilestones(testSubProject.Id);
    //    Test.StopTest();
    
    //    List<Project_Milestone__c> createdProjectMilestoneList = [SELECT Id FROM Project_Milestone__c WHERE SubProject__c =: testSubProject.Id];
    //    SubProject__c updatedSubProject = [SELECT Milestones_Auto_Generated_Flag__c FROM SubProject__c WHERE Id =: testSubProject.Id];
    
    //    System.assertEquals(0, createdProjectMilestoneList.size());
    //    System.assertEquals(false, updatedSubProject.Milestones_Auto_Generated_Flag__c);
    
    //    System.assertEquals('No standard Milestones found based on SubProject criteria', testString);
    //}
    public static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    //public static final Project__c project { get; set; }
    public static final SubProject__c subProject { get; set; }
    public static final Account account { get; set; }
    public static final User user_cdkAssignee { get; set; }
    public static final Contact contact_clientAssignee { get; set; }
    public static final Project_Activity__c activity {get;set;}
    public static final Project_Milestone__c milestone {get;set;}
    
    //create test data from Project up to Project Task
    static 
    {
        Profile adminProfile = [select Id from Profile where Name='ADPDS - Admin - System Administrator' limit 1];
        
        UserRole upperHierarchyRole = new UserRole(Name='UpperHierarchy');
        insert upperHierarchyRole;
        
        UserRole lowerHierarchyRole = new UserRole(Name='LowerHierarchy', ParentRoleId=upperHierarchyRole.Id);
        insert lowerHierarchyRole;
        
        User u = DS_TestObjects.NewUser();
        u.FirstName = 'SystemAdminWithImpRole';
        u.profileId = adminProfile.Id;
        u.UserRoleId = lowerHierarchyRole.Id;
        insert u;
        system.runAs(u)
        {
            /*project = IMP_TestFactory_Helper.buildProject(0);
            insert project;*/
            
            subProject = IMP_TestFactory_Helper.buildSubProject();
            insert subProject;
            
            account = IMP_TestFactory_Helper.buildAccount();
            insert account;
            
            user_cdkAssignee = IMP_TestFactory_Helper.buildUser();
            insert user_cdkAssignee;
            
            contact_clientAssignee = IMP_TestFactory_Helper.buildContact(account.Id);
            insert contact_clientAssignee;
            
            milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
            insert milestone;
            
            activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
            activity.CDK_Assignee__c = user_cdkAssignee.Id;
            insert activity;
        }
    }
    
    static testMethod void getCalculatedDateNull_Test()
    {
        User u = [select Id from User where firstName='SystemAdminWithImpRole' limit 1];
        system.runAs(u)
        {
            createCustomSettings();
            
            /*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
            insert testProject;*/
            
            SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
            insert testSubProject;
            
            Test.StartTest();
            Date testDate = IMP_Project_Utility.getCalculatedDate(null, testSubProject, 0);
            Test.StopTest();
            
            System.assertEquals(null, testDate);
        }
        
    }
    
    static testMethod void updateMilestoneActualEndDateError_Test()
    {
        User u = [select Id from User where firstName='SystemAdminWithImpRole' limit 1];
        system.runAs(u)
        {
            createCustomSettings();
            
            /*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
            insert testProject;*/
            
            SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
            insert testSubProject;
            
            Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
            //testProjectMilestone.Site__c = 'Test;';
            insert testProjectMilestone;
            
            User cdkAssignee = IMP_TestFactory_Helper.buildUser();
            insert cdkAssignee;
            
            List<Project_Activity__c> testProjectActivityList = new List<Project_Activity__c>();
            Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
            testProjectActivity.CDK_Assignee__c = cdkAssignee.Id;
            testProjectActivity.Planned_Start_Date__c = Date.today()-1;
            testProjectActivity.Planned_End_Date__c = Date.today();
            testProjectActivity.Actual_Start_Date__c = Date.today()-1;
            testProjectActivity.Actual_End_Date__c = Date.today();
            testProjectActivityList.add(testProjectActivity);
            
            Project_Activity__c testProjectActivity2 = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
            testProjectActivity2.Description__c = 'Test';
            
            testProjectActivityList.add(testProjectActivity2);
            
            Test.StartTest();
            try{
                insert testProjectActivityList;
            } catch (DmlException e){
                Boolean isError;
                List<Apexpages.Message> errorMessages = ApexPages.getMessages(); 
                for(Apexpages.Message msg: errorMessages){
                    if(msg.getDetail().contains('Terminal activity can not be end-dated, if a Milestone has 1 or more non-terminal activities which have not yet been end-dated.')){
                        isError = true;
                    }
                }
                System.assert(isError);
            }
            Test.StopTest();
        }
        
    }
    /* no longer have the concept of end dating the parent through the utility given removal of the terminal task/activity concept;
as a result this test method is no longer a valid scenario
static testMethod void updateMilestoneActualEndDateSuccess_Test(){
createCustomSettings();

User cdkAssignee1 = IMP_TestFactory_Helper.buildUser();
insert cdkAssignee1;

User cdkAssignee2 = IMP_TestFactory_Helper.buildUser();
insert cdkAssignee2;

Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
insert testProject;

SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
insert testSubProject;

Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
//testProjectMilestone.Site__c = 'Test;';
insert testProjectMilestone;

List<Project_Activity__c> testProjectActivityList = new List<Project_Activity__c>();
Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
testProjectActivity.CDK_Assignee__c = cdkAssignee1.Id;
testProjectActivity.Planned_Start_Date__c = Date.today()-1;
testProjectActivity.Planned_End_Date__c = Date.today();
testProjectActivity.Actual_Start_Date__c = Date.today()-1;
testProjectActivity.Actual_End_Date__c = Date.today();
testProjectActivityList.add(testProjectActivity);

Project_Activity__c testProjectActivity2 = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
testProjectActivity2.CDK_Assignee__c = cdkAssignee2.Id;
testProjectActivity2.Planned_Start_Date__c = Date.today()-1;
testProjectActivity2.Planned_End_Date__c = Date.today();
testProjectActivity2.Actual_Start_Date__c = Date.today()-1;
testProjectActivity2.Actual_End_Date__c = Date.today();
testProjectActivityList.add(testProjectActivity2);

Test.StartTest();
insert testProjectActivityList;
Test.StopTest();

Project_Milestone__c updatedProjectMilestone = [SELECT Actual_End_Date__c FROM Project_Milestone__c WHERE Id =: testProjectMilestone.Id];

System.assertEquals(testProjectActivity.Actual_End_Date__c, updatedProjectMilestone.Actual_End_Date__c);
}
*/
    /*static testMethod void validateMilestoneStatusError_Test()
    {
        User u = [select Id from User where firstName='SystemAdminWithImpRole' limit 1];
        system.runAs(u)
        {
            createCustomSettings();
            
            /*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
            insert testProject;*/
            
            /*SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
            insert testSubProject;
            
            List<Project_Milestone__c> testProjectMilestoneList = new List<Project_Milestone__c>();
            
            Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
            //testProjectMilestone.Site__c = 'Test;';
            testProjectMilestoneList.add(testProjectMilestone);
            
            Project_Milestone__c testProjectMilestone2 = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
            //testProjectMilestone2.Site__c = 'Test;';
            testProjectMilestoneList.add(testProjectMilestone2);        
            
            insert testProjectMilestoneList;
            
            Test.StartTest();
            testSubProject.SubProject_Status__c = 'Closed';
            
            try{
                update testSubProject;
            } catch (DmlException e){
                Boolean isError;
                List<Apexpages.Message> errorMessages = ApexPages.getMessages(); 
                for(Apexpages.Message msg: errorMessages){
                    if(msg.getDetail().contains('All Milestone Statuses should be Complete before SubProject Status can be set to Complete.')){
                        isError = true;
                    }
                }
                System.assert(isError);
            }
            Test.StopTest();
        }
        
    }*/
    
    //static testMethod void validateMilestoneStatusSuccess_Test(){
    //    createCustomSettings();
    
    //    Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
    //    insert testProject;
    
    //    SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
    //    insert testSubProject;
    
    //    Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
    //    testProjectMilestone.Site__c = 'Test;';
    //    //testProjectMilestone.Status__c = 'Complete';
    //    insert testProjectMilestone;
    
    //    Test.StartTest();
    //    testSubProject.SubProject_Status__c = 'Closed';
    
    //    try{
    //        update testSubProject;
    //    } catch (DmlException e){
    //        Boolean isError;
    //        List<Apexpages.Message> errorMessages = ApexPages.getMessages(); 
    //        for(Apexpages.Message msg: errorMessages){
    //            if(msg.getDetail().contains('All Milestone Statuses should be Complete before SubProject Status can be set to Complete.')){
    //                isError = true;
    //            }
    //        }
    //        System.assert(!isError);
    //    }
    //    Test.StopTest();
    //}
    
    static testMethod void getTopParentAccountId_Test() 
    {
        User u = [select Id from User where firstName='SystemAdminWithImpRole' limit 1];
        system.runAs(u)
        {
            // --------------------------------------------------------
            // INITIALIZATION
            Site_Type__c siteType = IMP_TestFactory_Helper.buildSiteType();
            siteType.Active__c = true;
            siteType.Group_Flag__c = true;
            insert siteType;
            
            // create test accounts for extensive top-parent-account hierarchy
            Map<Id, Id> topParentAccountIdMap;
            Id parentAccountId;
            Account ac;
            Integer ctr;
            List<Account> acctsList;
            Id maxIdFetched1;
            Id maxIdFetched2;
            Integer MAX_NUMBER_OF_ACCOUNTS_HIERARCHY_1 = 10;
            Integer MAX_NUMBER_OF_ACCOUNTS_HIERARCHY_2 = 30;
            Integer TOPMOST_PARENT_INDEX = 1;
            String HIERARCHY_1_NAME = 'HIERARCHY_1';
            String HIERARCHY_2_NAME = 'HIERARCHY_2';
            
            
            
            // hierarchy 1 accounts
            parentAccountId = null;
            acctsList = new List<Account>();
            for (Integer i = TOPMOST_PARENT_INDEX; i <= MAX_NUMBER_OF_ACCOUNTS_HIERARCHY_1; i++) {
                ac = new Account();
                ac.Name = HIERARCHY_1_NAME + '_ACCOUNT_' + String.valueOf(i);
                ac.Site_Type__c = siteType.Id;
                acctsList.add(ac);
            }
            insert acctsList;
            
            ctr = 0;
            for (Account a : acctsList) {
                if (ctr > 0) {
                    a.ParentId = parentAccountId;
                }
                parentAccountId = a.Id;
                ctr++;
            }
            update acctsList;
            
            
            
            // hierarchy 2 accounts
            parentAccountId = null;
            acctsList = new List<Account>();
            for (Integer i = TOPMOST_PARENT_INDEX; i <= MAX_NUMBER_OF_ACCOUNTS_HIERARCHY_2; i++) {
                ac = new Account();
                ac.Name = HIERARCHY_2_NAME + '_ACCOUNT_' + String.valueOf(i);
                ac.Site_Type__c = siteType.Id;
                acctsList.add(ac);
            }
            insert acctsList;
            
            ctr = 0;
            for (Account a : acctsList) {
                if (ctr > 0) {
                    a.ParentId = parentAccountId;
                }
                parentAccountId = a.Id;
                ctr++;
            }
            update acctsList;
            
            
            
            
            
            
            // --------------------------------------------------------
            // TESTS PROPER
            
            
            
            // 1 account 1 hierarchy
            maxIdFetched1 = [SELECT Id FROM Account WHERE Name = :HIERARCHY_1_NAME + '_ACCOUNT_' + TOPMOST_PARENT_INDEX].Id;
            topParentAccountIdMap = IMP_Project_Utility.getTopParentAccountId( 
                new Set<Id> { 
                    [SELECT Id FROM Account WHERE Name = :HIERARCHY_1_NAME + '_ACCOUNT_6'].Id 
                        } 
            );
            
            System.assertEquals( 1, topParentAccountIdMap.size() );
            System.assertEquals( maxIdFetched1, topParentAccountIdMap.values().get(0) );
            
            
            
            // 3 accounts 1 hierarchy
            List<String> hierarchyNamesList = new List<String> { 
                HIERARCHY_1_NAME + '_ACCOUNT_4',
                    HIERARCHY_1_NAME + '_ACCOUNT_7',
                    HIERARCHY_1_NAME + '_ACCOUNT_' + MAX_NUMBER_OF_ACCOUNTS_HIERARCHY_1 
                    };
                        
                        List<Id> idList = new List<Id>();
            for (Account a : [SELECT Id FROM Account WHERE Name IN :hierarchyNamesList]) {
                idList.add(a.Id);
            }
            topParentAccountIdMap = IMP_Project_Utility.getTopParentAccountId( new Set<Id>(idList) );
            
            System.assertEquals( hierarchyNamesList.size(), topParentAccountIdMap.size() );
            
            for (Id i : topParentAccountIdMap.keySet()) {
                System.assertEquals( maxIdFetched1, topParentAccountIdMap.get(i) );
            }
            
            
            
            // 2 accounts 2 hierarchies
            maxIdFetched2 = [SELECT Id FROM Account WHERE Name = :HIERARCHY_2_NAME + '_ACCOUNT_' + TOPMOST_PARENT_INDEX].Id;
            Id accountIdFromHierarchy1 = [SELECT Id FROM Account WHERE Name = :HIERARCHY_1_NAME + '_ACCOUNT_8'].Id;
            Id accountIdFromHierarchy2 = [SELECT Id FROM Account WHERE Name = :HIERARCHY_2_NAME + '_ACCOUNT_23'].Id;
            topParentAccountIdMap = IMP_Project_Utility.getTopParentAccountId( 
                new Set<Id> { 
                    accountIdFromHierarchy1,
                        accountIdFromHierarchy2
                        } 
            );
            
            System.assertEquals( 2, topParentAccountIdMap.size() );
            System.assertEquals( maxIdFetched1, topParentAccountIdMap.get(accountIdFromHierarchy1) );
            System.assertEquals( maxIdFetched2, topParentAccountIdMap.get(accountIdFromHierarchy2) );
        }
        
        
        
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
    
    static testMethod void updateExpectedTimeSpentasAdmin()
    {
        User u = [select Id from User where firstName='SystemAdminWithImpRole' limit 1];
        UserRole upperHierarchyRole = [select ID from UserRole where name='UpperHierarchy' limit 1];
        Project_Task__c task1;
        system.runAs(u)
        {
            IMP_ProfilesToByPass__c byPassDetails = new IMP_ProfilesToByPass__c();
            byPassDetails.Name = 'Expected_Time_Spent__c';
            byPassDetails.Profile__c = 'ADPDS - Admin - System Administrator,ADPDS - Admin - System Administrator_Non-ISDC,System Administrator';
            byPassDetails.Permission_Set__c = 'Access_to_PM_Maintenance';
            
            insert byPassDetails;
            
            task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
            insert task1;	
        }
        
        String Random = DS_TestObjects.TrueRandomUpToAMillion();
        String RandomUserName = ALL_UtilitiesRandom.RandomUserName('Test123');
        Id ADPDSsysAdminId
            = [SELECT Id, Name FROM Profile WHERE Name = 'ADPDS - Admin - System Administrator'].Id;
        
        User NewUser = new User(
            UserName=RandomUserName,
            Email='test.user@cdk.com', 
            Alias='a'+Random,
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=ADPDSsysAdminId, 
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            TimeZoneSIDKey='America/Chicago',
            UserRoleId = upperHierarchyRole.Id,
            ADID__c='testus');
        
        insert NewUser;
        
        system.runAs(NewUser)
        {
            task1.Expected_Time_Spent__c = 2;
            update task1;
            
            Project_Task__c updatedTask = [SELECT Id,Expected_Time_Spent__c FROM Project_Task__c WHERE Id = : task1.Id];  
            
            system.Assert(updatedTask != null);
            system.Assert(updatedTask.Expected_Time_Spent__c  == 2);
        }
        
    }
    
    static testMethod void updateExpectedTimeSpentNotAdmin()
    {
        
        User u = [select Id from User where firstName = 'SystemAdminWithImpRole' limit 1];
        USerRole upperHierarchyRole = [select Id from UserRole where Name ='UpperHierarchy' limit 1];
        Project_Task__c task1;
        system.runAs(u)
        {
            IMP_ProfilesToByPass__c byPassDetails = new IMP_ProfilesToByPass__c();
            byPassDetails.Name = 'Expected_Time_Spent__c';
            byPassDetails.Profile__c = 'ADPDS - Admin - System Administrator,ADPDS - Admin - System Administrator_Non-ISDC,System Administrator';
            byPassDetails.Permission_Set__c = 'Access_to_PM_Maintenance';
            
            insert byPassDetails;
            
            task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
            insert task1;
        }
        
        String Random = DS_TestObjects.TrueRandomUpToAMillion();
        String RandomUserName = ALL_UtilitiesRandom.RandomUserName('test123');
        Id ADPDSsysAdminId
            = [SELECT Id, Name FROM Profile WHERE Name = 'ADPDS - Implementation - VIC'].Id;
        
        User NewUser = new User(
            UserName=RandomUserName,
            Email='test.user@cdk.com', 
            Alias='a'+Random,
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=ADPDSsysAdminId, 
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            TimeZoneSIDKey='America/Chicago',
            UserRoleId=upperHierarchyRole.Id,
            ADID__c='testus');
        
        insert NewUser;
        
        system.runAs(NewUser)
        {
            task1.Expected_Time_Spent__c = 2;
            update task1;
            
            Project_Task__c updatedTask = [SELECT Id,Expected_Time_Spent__c FROM Project_Task__c WHERE Id = : task1.Id];  
            
            system.Assert(updatedTask != null);
            system.Assert(updatedTask.Expected_Time_Spent__c  == 1);
        }
        
    }
}