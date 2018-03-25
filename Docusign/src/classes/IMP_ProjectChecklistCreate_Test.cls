/*------------------------------------------------------------
Author:      Alexander Daria
Company:     Cloud Sherpas
Description: Test class for IMP_ProjectChecklistCreate_Handler
Test Class:
History
09/01/14    Alexander Daria     Created
11/19/14    Samuel Oberes       Fixed assertions
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
public class IMP_ProjectChecklistCreate_Test {
    static testMethod void ValidateProjectChecklistCreate() {
        // --------------------------------------------------------------------
        // INITIALIZATION 

        List<Checklist_Item__c> checklistItems = new List<Checklist_Item__c>();

        // prepare 3 records for checklist category and checklist item
        for (Integer ctr = 1; ctr <= 3; ctr++) {
            Checklist_Category__c checklistCategory = IMP_TestFactory_Helper.buildChecklistCategory();
            checklistCategory.Active__c = true;
            insert checklistCategory;
            
            Checklist_Item__c checklistItem = IMP_TestFactory_Helper.buildChecklistItem(checklistCategory.Id);
            checklistItem.Active__c = true;
            insert checklistItem;
            checklistItems.add(checklistItem);
        }

        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        testProject.Name = 'TestProject';
        insert testProject;
        
        // --------------------------------------------------------------------
        // TESTING PROPER

        Test.startTest();

        Integer counterProjects            = [SELECT COUNT() FROM Project__c];
        Integer counterChecklistCategories = [SELECT COUNT() FROM Checklist_Category__c];
        Integer counterProjectChecklists   = [SELECT COUNT() FROM Project_Checklist__c];
        Integer counterChecklistItems      = [SELECT COUNT() FROM Checklist_Item__c];
        Integer counterChecklistAnswers    = [SELECT COUNT() FROM Checklist_Answer__c];

        System.assertEquals(1, counterProjects);            // expect 1 project to get created
        System.assertEquals(3, counterChecklistCategories); // expect 3 checklist categories to get created
        System.assertEquals(3, counterProjectChecklists);   // expect 3 project checklists to get created
        System.assertEquals(3, counterChecklistItems);      // expect 3 checklist items to get created
        System.assertEquals(3, counterChecklistAnswers);    // expect 3 checklist answers to get created because there were also 3 checklist items created

        // get the second checklist item and delete its associated checklist answer
        delete [SELECT Id FROM Checklist_Answer__c WHERE Item__c = :checklistItems.get(1).Id];

        // deletes the second checklist item
        delete (Checklist_Item__c)checklistItems.get(1);

        counterChecklistItems      = [SELECT COUNT() FROM Checklist_Item__c];
        counterChecklistAnswers    = [SELECT COUNT() FROM Checklist_Answer__c];
        counterProjectChecklists   = [SELECT COUNT() FROM Project_Checklist__c];

        System.assertEquals(2, counterChecklistItems);      // expect 2 checklist items to remain after deleting the second item
        System.assertEquals(2, counterChecklistAnswers);    // expect 2 checklist answers to remain after deleting the second item
        System.assertEquals(3, counterProjectChecklists);   // expect the 3 exisitng project checklists to be untouched and remain count at 3 because the already-created checklists' definition is finalized at the time of creation.

        // --------------------------------------------------------------------

        // Initially, we have 3 project checklists because we have 3 checklist categories
        System.assertEquals(3, [SELECT COUNT() FROM Project_Checklist__c WHERE Project__c = :testProject.ID]);

        // now all checklist categories will be deactivated
        List<Checklist_Category__c> checklistCategoryToUpdate = new List<Checklist_Category__c>();
        for (Checklist_Category__c cc : [SELECT Id, Active__c FROM Checklist_Category__c WHERE Active__c = true]) {
            cc.Active__c = false;
            checklistCategoryToUpdate.add(cc);
        }
        update checklistCategoryToUpdate;

        // expect that the previously created checklists are untouched
        System.assertEquals(3, [SELECT COUNT() FROM Project_Checklist__c WHERE Project__c = :testProject.ID]);

        // now create a new project
        Project__c testProject2 = IMP_TestFactory_Helper.buildProject(1);
        testProject2.Name = 'TestProject2';
        insert testProject2;

        // expect that the new project will have 0 project checklists because all checklist categories are not active
        System.assertEquals(0, [SELECT COUNT() FROM Project_Checklist__c WHERE Project__c = :testProject2.ID]);
        System.assertEquals(2, [SELECT COUNT() FROM Checklist_Item__c]);   // expect 2 checklist items still remaining because there weren't any active checklist categories
        System.assertEquals(2, [SELECT COUNT() FROM Checklist_Answer__c]); // expect 2 checklist answers still remaining because there weren't any active checklist categories


        Test.stopTest();
        
    }
}