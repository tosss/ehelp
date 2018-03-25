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
//2016-03-08- anirudh.singh@cdk.com- Modified this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
//2016-03-08- anirudh.singh@cdk.com- Re-written the whole test class.
@isTest
public class IMP_ReParentingSubProject_Test
{
    @TestSetup
    private static void setupData()
    {
        IMP_ProfilesToByPass__c profile=IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
        
        Account accountRecord=IMP_TestFactory_Helper.buildAccount();   
        insert accountRecord;
        
        Contact contactRecord=IMP_TestFactory_Helper.buildContact(accountRecord.Id);
        insert contactRecord;
        
        Project__c projectRecord=IMP_TestFactory_Helper.buildProject(0);
        insert projectRecord;
        
        SubProject__c subProjectRecord=IMP_TestFactory_Helper.buildSubProject(projectRecord.Id);
        subProjectRecord.Project_Manager__c=UserInfo.getUserId();
        subProjectRecord.Project_Type__c='Unhook';
        insert subProjectRecord;
        
        SubProjectOpp__c subProjectOppRecord=IMP_TestFactory_Helper.buildSubProjectOpportunity(subProjectRecord.Id);
        insert subProjectOppRecord;
        
        SubProject_External_Related_Entity__c subProjectExternalRelatedEntityRecord=IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(subProjectRecord.Id);
        subProjectExternalRelatedEntityRecord.Project__c=projectRecord.Id;
        insert subProjectExternalRelatedEntityRecord;
        
        Laser_Artwork_Order__c formsOrderRecord=IMP_TestFactory_Helper.buildLaserArtworkOrder(contactRecord.Id);
        insert formsOrderRecord;
        
        SubProject_External_Reference__c subProjectExternalReferenceRecord=IMP_TestFactory_Helper.buildSubProjectExternalReference(formsOrderRecord.Id, subProjectRecord.Id, projectRecord.Id);        
        insert subProjectExternalReferenceRecord;
        
        CMF_Info__c cmfInfoRecord=IMP_TestFactory_Helper.buildCMFInfo(accountRecord.Id);
        insert cmfInfoRecord;
        
        SubProjectSite__c subProjectSiteRecord=IMP_TestFactory_Helper.buildSubProjectSite(accountRecord.Id, subProjectRecord.Id, cmfInfoRecord.Id);
        insert subProjectSiteRecord;
        
        List<Project_Log__c> projectLogsList=new List<Project_Log__c>();
        Project_Log__c issue=IMP_TestFactory_Helper.buildIssueLog(projectRecord.Id, subProjectRecord.Id);
        projectLogsList.add(issue);
        
        Project_Log__c risk=IMP_TestFactory_Helper.buildRiskLog(projectRecord.Id, subProjectRecord.Id);
        projectLogsList.add(risk);
        
        Project_Log__c action=IMP_TestFactory_Helper.buildActionItemLog(projectRecord.Id, subProjectRecord.Id);
        projectLogsList.add(action);
        
        Project_Log__c change=IMP_TestFactory_Helper.buildChangeRequestLog(projectRecord.Id, subProjectRecord.Id);
        projectLogsList.add(change);
        
        Project_Log__c lesson=IMP_TestFactory_Helper.buildLessonLearnedLog(projectRecord.Id, subProjectRecord.Id);
        projectLogsList.add(lesson);
        insert projectLogsList;
    }
    
    private static testMethod void executeReParentTestOne()
    {
        Map<Id, SubProject__c> oldSubProjectMap=new Map<Id, SubProject__c>([SELECT Id, Project__c FROM SubProject__c]);
        SubProjectOpp__c subProjectOpp=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectOpp__c];
        SubProject_External_Related_Entity__c subProjectExternalRelatedEntity=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Related_Entity__c];
        SubProject_External_Reference__c subProjectExternalReference=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Reference__c];
        SubProjectSite__c subProjectSite=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectSite__c];
        List<Project_Log__c> projectLogsList=[
            SELECT Id, Project__c, Project_Action_Items__c, Project_Change_Request__c, 
            Project_Issue__c, Project_Lessons_Learned__c, Project_Risk__c, 
            Lookup_Field_API_Name_to_Subproject__c, LastModifiedDate 
            FROM Project_Log__c 
            ORDER BY Lookup_Field_API_Name_to_Subproject__c
        ];
        
        test.startTest();
        IMP_ReParentingSubProject_Helper.executeReParent(oldSubProjectMap, oldSubProjectMap);
        
        SubProjectOpp__c updatedSubProjectOpp=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectOpp__c];
        system.assertNotEquals(subProjectOpp.LastModifiedDate, updatedSubProjectOpp.LastModifiedDate, 'SubProjectOpp__c Updated');
        system.assertEquals(subProjectOpp.Project__c, updatedSubProjectOpp.Project__c, 'Project Value Not Updated');
        
        SubProject_External_Related_Entity__c updatedSubProjectExternalRelatedEntity=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Related_Entity__c];
        system.assertNotEquals(subProjectExternalRelatedEntity.LastModifiedDate, updatedSubProjectExternalRelatedEntity.LastModifiedDate, 'SubProject_External_Related_Entity__c Updated');
        system.assertEquals(subProjectExternalRelatedEntity.Project__c, updatedSubProjectExternalRelatedEntity.Project__c, 'Project Value Not Updated');
        
        SubProject_External_Reference__c updatedSubProjectExternalReference=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Reference__c];
        system.assertNotEquals(subProjectExternalReference.LastModifiedDate, updatedSubProjectExternalReference.LastModifiedDate, 'SubProject_External_Reference__c Updated');
        system.assertEquals(subProjectExternalReference.Project__c, updatedSubProjectExternalReference.Project__c, 'Project Value Not Updated');
        
        SubProjectSite__c updatedSubProjectSite=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectSite__c];
        system.assertNotEquals(subProjectSite.LastModifiedDate, updatedSubProjectSite.LastModifiedDate, 'SubProjectSite__c Updated');
        system.assertEquals(subProjectSite.Project__c, updatedSubProjectSite.Project__c, 'Project Value Not Updated');
        
        List<Project_Log__c> updatedProjectLogsList=[
            SELECT Id, Project__c, Project_Action_Items__c, Project_Change_Request__c, 
            Project_Issue__c, Project_Lessons_Learned__c, Project_Risk__c, 
            Lookup_Field_API_Name_to_Subproject__c, LastModifiedDate 
            FROM Project_Log__c 
            ORDER BY Lookup_Field_API_Name_to_Subproject__c
        ];
               
        system.assertEquals(projectLogsList[0].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[0].Lookup_Field_API_Name_to_Subproject__c, 'Action Item');
        system.assertNotEquals(projectLogsList[0].LastModifiedDate, updatedProjectLogsList[0].LastModifiedDate, 'Action Item Updated');
        system.assertEquals(projectLogsList[0].Project_Action_Items__c, updatedProjectLogsList[0].Project_Action_Items__c, 'Project Value Not Updated');
        
        system.assertEquals(projectLogsList[1].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[1].Lookup_Field_API_Name_to_Subproject__c, 'Change Request');
        system.assertNotEquals(projectLogsList[1].LastModifiedDate, updatedProjectLogsList[1].LastModifiedDate, 'Change Request Updated');
        system.assertEquals(projectLogsList[1].Project_Change_Request__c, updatedProjectLogsList[1].Project_Change_Request__c, 'Project Value Not Updated');
        
        system.assertEquals(projectLogsList[2].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[2].Lookup_Field_API_Name_to_Subproject__c, 'Issue');
        system.assertNotEquals(projectLogsList[2].LastModifiedDate, updatedProjectLogsList[2].LastModifiedDate, 'Issue Updated');
        system.assertEquals(projectLogsList[2].Project_Issue__c, updatedProjectLogsList[2].Project_Issue__c, 'Project Value Not Updated');
        
        system.assertEquals(projectLogsList[3].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[3].Lookup_Field_API_Name_to_Subproject__c, 'Lessons Learned');
        system.assertNotEquals(projectLogsList[3].LastModifiedDate, updatedProjectLogsList[3].LastModifiedDate, 'Lessons Learned Updated');
        system.assertEquals(projectLogsList[3].Project_Lessons_Learned__c, updatedProjectLogsList[3].Project_Lessons_Learned__c, 'Project Value Not Updated');
        
        system.assertEquals(projectLogsList[4].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[4].Lookup_Field_API_Name_to_Subproject__c, 'Risk');
        system.assertNotEquals(projectLogsList[4].LastModifiedDate, updatedProjectLogsList[4].LastModifiedDate, 'Risk Updated');
        system.assertEquals(projectLogsList[4].Project_Risk__c, updatedProjectLogsList[4].Project_Risk__c, 'Project Value Not Updated');
        
        Project__c projectRecord=[SELECT Project_Status__c FROM Project__c WHERE Id=:subProjectOpp.Project__c];
        System.assertNotEquals('Closed', projectRecord.Project_Status__c);
        test.stopTest();
    }
    
    private static testMethod void executeReParentTestTwo()
    {
        Map<Id, SubProject__c> oldSubProjectMap=new Map<Id, SubProject__c>([SELECT Id, Project__c FROM SubProject__c]);
        SubProjectOpp__c subProjectOpp=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectOpp__c];
        SubProject_External_Related_Entity__c subProjectExternalRelatedEntity=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Related_Entity__c];
        SubProject_External_Reference__c subProjectExternalReference=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Reference__c];
        SubProjectSite__c subProjectSite=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectSite__c];
        List<Project_Log__c> projectLogsList=[
            SELECT Id, Project__c, Project_Action_Items__c, Project_Change_Request__c, 
            Project_Issue__c, Project_Lessons_Learned__c, Project_Risk__c, 
            Lookup_Field_API_Name_to_Subproject__c, LastModifiedDate 
            FROM Project_Log__c 
            ORDER BY Lookup_Field_API_Name_to_Subproject__c
        ];
        
        //Creating a new Project.
        Project__c projectRecordNew=IMP_TestFactory_Helper.buildProject(0);
        insert projectRecordNew;
        
        Map<Id, SubProject__c> newSubProjectsMap=new Map<Id, SubProject__c>();
        SubProject__c subProjectRecordNew=new SubProject__c();
        subProjectRecordNew=oldSubProjectMap.values()[0].clone(true);
        subProjectRecordNew.Project__c=projectRecordNew.Id;
        newSubProjectsMap.put(subProjectRecordNew.Id, subProjectRecordNew);
        
        test.startTest();
        IMP_ReParentingSubProject_Helper.executeReParent(newSubProjectsMap, oldSubProjectMap);
        
        SubProjectOpp__c updatedSubProjectOpp=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectOpp__c];
        system.assertNotEquals(subProjectOpp.LastModifiedDate, updatedSubProjectOpp.LastModifiedDate, 'SubProjectOpp__c Updated');
        system.assertNotEquals(subProjectOpp.Project__c, updatedSubProjectOpp.Project__c, 'Project Value Updated');
        
        SubProject_External_Related_Entity__c updatedSubProjectExternalRelatedEntity=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Related_Entity__c];
        system.assertNotEquals(subProjectExternalRelatedEntity.LastModifiedDate, updatedSubProjectExternalRelatedEntity.LastModifiedDate, 'SubProject_External_Related_Entity__c Updated');
        system.assertNotEquals(subProjectExternalRelatedEntity.Project__c, updatedSubProjectExternalRelatedEntity.Project__c, 'Project Value Updated');
        
        SubProject_External_Reference__c updatedSubProjectExternalReference=[SELECT Id, Project__c, LastModifiedDate FROM SubProject_External_Reference__c];
        system.assertNotEquals(subProjectExternalReference.LastModifiedDate, updatedSubProjectExternalReference.LastModifiedDate, 'SubProject_External_Reference__c Updated');
        system.assertNotEquals(subProjectExternalReference.Project__c, updatedSubProjectExternalReference.Project__c, 'Project Value Updated');
        
        SubProjectSite__c updatedSubProjectSite=[SELECT Id, Project__c, LastModifiedDate FROM SubProjectSite__c];
        system.assertNotEquals(subProjectSite.LastModifiedDate, updatedSubProjectSite.LastModifiedDate, 'SubProjectSite__c Updated');
        system.assertNotEquals(subProjectSite.Project__c, updatedSubProjectSite.Project__c, 'Project Value Updated');
        
        List<Project_Log__c> updatedProjectLogsList=[
            SELECT Id, Project__c, Project_Action_Items__c, Project_Change_Request__c, 
            Project_Issue__c, Project_Lessons_Learned__c, Project_Risk__c, 
            Lookup_Field_API_Name_to_Subproject__c, LastModifiedDate 
            FROM Project_Log__c 
            ORDER BY Lookup_Field_API_Name_to_Subproject__c
        ];
        system.assertEquals(projectLogsList[0].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[0].Lookup_Field_API_Name_to_Subproject__c, 'Action Item');
        system.assertNotEquals(projectLogsList[0].LastModifiedDate, updatedProjectLogsList[0].LastModifiedDate, 'Action Item Updated');
        system.assertNotEquals(projectLogsList[0].Project_Action_Items__c, updatedProjectLogsList[0].Project_Action_Items__c, 'Project Value Updated');
        
        system.assertEquals(projectLogsList[1].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[1].Lookup_Field_API_Name_to_Subproject__c, 'Change Request');
        system.assertNotEquals(projectLogsList[1].LastModifiedDate, updatedProjectLogsList[1].LastModifiedDate, 'Change Request Updated');
        system.assertNotEquals(projectLogsList[1].Project_Change_Request__c, updatedProjectLogsList[1].Project_Change_Request__c, 'Project Value Updated');
        
        system.assertEquals(projectLogsList[2].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[2].Lookup_Field_API_Name_to_Subproject__c, 'Issue');
        system.assertNotEquals(projectLogsList[2].LastModifiedDate, updatedProjectLogsList[2].LastModifiedDate, 'Issue Updated');
        system.assertNotEquals(projectLogsList[2].Project_Issue__c, updatedProjectLogsList[2].Project_Issue__c, 'Project Value Updated');
        
        system.assertEquals(projectLogsList[3].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[3].Lookup_Field_API_Name_to_Subproject__c, 'Lessons Learned');
        system.assertNotEquals(projectLogsList[3].LastModifiedDate, updatedProjectLogsList[3].LastModifiedDate, 'Lessons Learned Updated');
        system.assertNotEquals(projectLogsList[3].Project_Lessons_Learned__c, updatedProjectLogsList[3].Project_Lessons_Learned__c, 'Project Value Updated');
        
        system.assertEquals(projectLogsList[4].Lookup_Field_API_Name_to_Subproject__c, updatedProjectLogsList[4].Lookup_Field_API_Name_to_Subproject__c, 'Risk');
        system.assertNotEquals(projectLogsList[4].LastModifiedDate, updatedProjectLogsList[4].LastModifiedDate, 'Risk Updated');
        system.assertNotEquals(projectLogsList[4].Project_Risk__c, updatedProjectLogsList[4].Project_Risk__c, 'Project Value Updated');
        
        update subProjectRecordNew;
        
        Project__c projectRecord=[Select Project_Status__c from Project__c where Id=:subProjectOpp.Project__c];
        System.assertEquals('Closed', projectRecord.Project_Status__c);
        test.stopTest();
    }
}