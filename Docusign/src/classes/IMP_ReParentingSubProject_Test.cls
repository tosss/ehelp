/*------------------------------------------------------------
Author:      Rey Austral
Company:     Cloud Sherpas
Description: Test class for IMP_ReParentingSubProject_Helper
Test Class:
History:
11/18/14     Rey Austral      Created
01/03/15     Karl Simon       Added CMF_Info and SubprojectSite record generation and insertion logic into the positiveTestandProjectClose and testAlreadyCloseTargetProject methods.
                              The addition accommodates the decommissioning of prior functionality that auto-generated a Subproject Site upon population or
                              change of the Subproject__c.Main_Site__c field (which is planned for de-commission during Phase 1 R3).
01/15/15     Samuel Oberes    added assertions in positiveTestandProjectClose, checking if the new fields Lookup_Field_API_Name_to_Subproject__c and SubProject_Id__c are automatically getting populated
------------------------------------------------------------*/
@isTest
public class IMP_ReParentingSubProject_Test {
    static testMethod void positiveTestandProjectClose()
    {
        createCustomSettings();
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();   
        insert testAccount;        
        
        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;        
        
        Project__c testProject_Source = IMP_TestFactory_Helper.buildProject(0);
        insert testProject_Source;
        
        Project__c testProject_Target = IMP_TestFactory_Helper.buildProject(0);
        insert testProject_Target;
        
        SubProject__c testSubProject_Source = IMP_TestFactory_Helper.buildSubProject(testProject_Source.Id);
        testSubProject_Source.Project_Manager__c = UserInfo.getUserId();
        testSubProject_Source.Dealer_Group__c = testAccount.id;
        testSubProject_Source.Project_Type__c = 'Unhook';
        insert testSubProject_Source;
        
        Project_Milestone__c testProjectMilestone =IMP_TestFactory_Helper.buildMilestoneStandard(testSubProject_Source.Id);
        insert testProjectMilestone;
        
        Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.id);
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();
        insert testProjectActivity;        
        
        Laser_Artwork_Order__c testLaser = IMP_TestFactory_Helper.buildLaserArtworkOrder(testContact.id);
        insert testLaser;
        
        CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        insert testCMFInfo;
        
        subProjectSite__c testSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.id,testSubProject_Source.id, testCMFInfo.Id);
        insert testSite;
        
        SubProject_External_Reference__c testExReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(testLaser.Id, testSubProject_Source.id, testProject_Source.id);        
        insert testExReference;
        
        SubProjectOpp__c testSubOpp = IMP_TestFactory_Helper.buildSubProjectOpportunity(testSubProject_Source.Id);
        testSubOpp.Project__c = testProject_Source.Id;
        insert testSubOpp;
        
        SubProject_External_Related_Entity__c testExRelated = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject_Source.Id);
        testExRelated.Project__c = testProject_Source.id;
        insert testExRelated;
        
        Test.StartTest();

        List<Project_Log__c> projectLogList;

        Project_Log__c issue = IMP_TestFactory_Helper.buildIssueLog(testProject_Source.Id,testSubProject_Source.Id);
        insert issue;

        projectLogList = [SELECT Lookup_Field_API_Name_to_Subproject__c, SubProject_Id__c FROM Project_Log__c WHERE Id = :issue.Id];
        System.assertEquals(1, projectLogList.size());
        System.assertEquals('Issue__c', projectLogList.get(0).Lookup_Field_API_Name_to_Subproject__c);
        System.assertEquals(testSubProject_Source.Id, projectLogList.get(0).SubProject_Id__c);
        
        Project_Log__c risk = IMP_TestFactory_Helper.buildRiskLog(testProject_Source.Id,testSubProject_Source.Id);
        insert risk;

        projectLogList = [SELECT Lookup_Field_API_Name_to_Subproject__c, SubProject_Id__c FROM Project_Log__c WHERE Id = :risk.Id];
        System.assertEquals(1, projectLogList.size());
        System.assertEquals('Risk__c', projectLogList.get(0).Lookup_Field_API_Name_to_Subproject__c);
        System.assertEquals(testSubProject_Source.Id, projectLogList.get(0).SubProject_Id__c);
        
        Project_Log__c action = IMP_TestFactory_Helper.buildActionItemLog(testProject_Source.Id,testSubProject_Source.Id);
        insert action;

        projectLogList = [SELECT Lookup_Field_API_Name_to_Subproject__c, SubProject_Id__c FROM Project_Log__c WHERE Id = :action.Id];
        System.assertEquals(1, projectLogList.size());
        System.assertEquals('Action_Items__c', projectLogList.get(0).Lookup_Field_API_Name_to_Subproject__c);
        System.assertEquals(testSubProject_Source.Id, projectLogList.get(0).SubProject_Id__c);
        
        Project_Log__c change = IMP_TestFactory_Helper.buildChangeRequestLog(testProject_Source.Id,testSubProject_Source.Id);
        insert change;
        
        projectLogList = [SELECT Lookup_Field_API_Name_to_Subproject__c, SubProject_Id__c FROM Project_Log__c WHERE Id = :change.Id];
        System.assertEquals(1, projectLogList.size());
        System.assertEquals('Change_Request__c', projectLogList.get(0).Lookup_Field_API_Name_to_Subproject__c);
        System.assertEquals(testSubProject_Source.Id, projectLogList.get(0).SubProject_Id__c);

        Project_Log__c lesson = IMP_TestFactory_Helper.buildLessonLearnedLog(testProject_Source.Id,testSubProject_Source.Id);
        insert lesson;
        
        projectLogList = [SELECT Lookup_Field_API_Name_to_Subproject__c, SubProject_Id__c FROM Project_Log__c WHERE Id = :lesson.Id];
        System.assertEquals(1, projectLogList.size());
        System.assertEquals('Lessons_Learned__c', projectLogList.get(0).Lookup_Field_API_Name_to_Subproject__c);
        System.assertEquals(testSubProject_Source.Id, projectLogList.get(0).SubProject_Id__c);

        
        testSubProject_Source.Project__c = testProject_Target.Id;
        update testSubProject_Source;

        Test.stopTest();
        
        //Select all the related record where the Project__c is the target project not the source
        List<subProjectSite__c> lstSite = [Select Id from subProjectSite__c where subproject__c =: testSubProject_Source.Id and Project__c =: testProject_Target.Id];
        List<SubProject_External_Reference__c> lstExternalRef = [Select Id from SubProject_External_Reference__c where subproject__c =: testSubProject_Source.Id and Project__c =: testProject_Target.Id];
        List<SubProjectOpp__c> lstProjectOpp = [Select Id from SubProjectOpp__c where subproject__c =: testSubProject_Source.Id and Project__c =: testProject_Target.Id];
        List<SubProject_External_Related_Entity__c> lstExternalRelated = [Select id From SubProject_External_Related_Entity__c where subproject__c =: testSubProject_Source.Id and Project__c =: testProject_Target.Id ];
        
        List<Project_Log__c> lstIssue = [Select Id from Project_Log__c where Sub_Project_Issue__c =: testSubProject_Source.Id and Project_Issue__c =: testProject_Target.Id];
        List<Project_Log__c> lstAction = [Select Id from Project_Log__c where Sub_Project_Action_Items__c =: testSubProject_Source.Id and Project_Action_Items__c =: testProject_Target.Id];
        List<Project_Log__c> lstChange = [Select Id from Project_Log__c where Sub_Project_Change_Request__c =: testSubProject_Source.Id and Project_Change_Request__c =: testProject_Target.Id];
        List<Project_Log__c> lstLesson = [Select Id from Project_Log__c where Sub_Project_Lessons_Learned__c =: testSubProject_Source.Id and Project_Lessons_Learned__c =: testProject_Target.Id];
        List<Project_Log__c> lstRisk = [Select Id from Project_Log__c where Sub_Project_Risk__c =: testSubProject_Source.Id and Project_Risk__c =: testProject_Target.Id];
        
        Project__c lstProject = [Select Project_Status__c from Project__c where Id =: testProject_Source.Id];
        
        //check if all the list have record, if empty then the record was not transfer to the new project
        System.assertEquals(1, lstSite.size());
        System.assertEquals(1, lstExternalRef.size());
        System.assertEquals(1, lstProjectOpp.size());
        //Changed the expected value to 2, since as of Phase 1 R3, creation of a SubprojectSite with a specified CMF will auto-generate a subproject external related entity
        System.assertEquals(2, lstExternalRelated.size());
        
        System.assertEquals(1, lstIssue.size());
        System.assertEquals(1, lstAction.size());
        System.assertEquals(1, lstChange.size());
        System.assertEquals(1, lstLesson.size());
        System.assertEquals(1, lstRisk.size());     
        
        //check if the source project is closed, because the source project have no subproject left
        System.assertEquals('Closed', lstProject.Project_Status__c);
    }
    
    static testMethod void testAlreadyCloseTargetProject() {
        createCustomSettings();
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();   
        insert testAccount;        
        
        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;        
        
        Project__c testProject_Source = IMP_TestFactory_Helper.buildProject(0);
        insert testProject_Source;
        
        Project__c testProject_Target = IMP_TestFactory_Helper.buildProject(0);
        testProject_Target.Project_Status__c = 'Closed';
        insert testProject_Target;
        
        SubProject__c testSubProject_Source = IMP_TestFactory_Helper.buildSubProject(testProject_Source.Id);
        testSubProject_Source.Project_Manager__c = UserInfo.getUserId();
        testSubProject_Source.Dealer_Group__c = testAccount.id;
        testSubProject_Source.Project_Type__c = 'Unhook';        
        insert testSubProject_Source;
        
        Project_Milestone__c testProjectMilestone =IMP_TestFactory_Helper.buildMilestoneStandard(testSubProject_Source.Id);        
        insert testProjectMilestone;
        
        Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.id);
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();      
        insert testProjectActivity;        
        
        Laser_Artwork_Order__c testLaser = IMP_TestFactory_Helper.buildLaserArtworkOrder(testContact.id);
        insert testLaser;
        
        CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        insert testCMFInfo;
        
        subProjectSite__c testSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.id,testSubProject_Source.id, testCMFInfo.Id);
        insert testSite;
        
        SubProject_External_Reference__c testExReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(testLaser.Id, testSubProject_Source.id, testProject_Source.id);        
        insert testExReference;
        
        SubProjectOpp__c testSubOpp = IMP_TestFactory_Helper.buildSubProjectOpportunity(testSubProject_Source.Id);
        testSubOpp.Project__c = testProject_Source.Id;
        insert testSubOpp;
        
        SubProject_External_Related_Entity__c testExRelated = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject_Source.Id);
        testExRelated.Project__c = testProject_Source.id;
        insert testExRelated;   
        
        Test.StartTest();
        
        testSubProject_Source.Project__c = testProject_Target.Id;
        String error = '';
        try
        {
            update testSubProject_Source;
        }catch(Exception ex)
        {
            error = ex.getMessage();
        }
        
        Test.stopTest();
        
        //check if the trigger will throw an error because the target project is already closed
        System.assert(error.contains('You cannot change the Project value to a project with a closed status.'));
    }
    
    static testMethod void positiveTestbutNoProjectClose()
    {
        createCustomSettings();
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();   
        insert testAccount;        
        
        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;        
        
        Project__c testProject_Source = IMP_TestFactory_Helper.buildProject(0);
        insert testProject_Source;
        
        Project__c testProject_Target = IMP_TestFactory_Helper.buildProject(0);
        insert testProject_Target;
        
        SubProject__c testSubProject_Source = IMP_TestFactory_Helper.buildSubProject(testProject_Source.Id);
        testSubProject_Source.Project_Manager__c = UserInfo.getUserId();
        testSubProject_Source.Dealer_Group__c = testAccount.id;
        testSubProject_Source.Project_Type__c = 'Unhook';
        insert testSubProject_Source;
        
        Project_Milestone__c testProjectMilestone =IMP_TestFactory_Helper.buildMilestoneStandard(testSubProject_Source.Id);
        insert testProjectMilestone;
        
        Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.id);
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();
        insert testProjectActivity;   
        
        SubProject__c testSubProject_Source2 = IMP_TestFactory_Helper.buildSubProject(testProject_Source.Id);
        testSubProject_Source2.Project_Manager__c = UserInfo.getUserId();
        testSubProject_Source2.Dealer_Group__c = testAccount.id;
        testSubProject_Source2.Project_Type__c = 'Unhook';
        insert testSubProject_Source2;
        
        Project_Milestone__c testProjectMilestone2 =IMP_TestFactory_Helper.buildMilestoneStandard(testSubProject_Source2.Id);
        insert testProjectMilestone2;
        
        Project_Activity__c testProjectActivity2 = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone2.id);
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();
        insert testProjectActivity2; 
        
        Test.StartTest();
        testSubProject_Source.Project__c = testProject_Target.Id;
        update testSubProject_Source;
        Test.stopTest();
        
        Project__c lstProject = [Select Project_Status__c from Project__c where Id =: testProject_Source.Id];
        
        //check if the source project is not closed, because the source project have subproject left
        System.assert(!'Closed'.equals(lstProject.Project_Status__c));
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
}