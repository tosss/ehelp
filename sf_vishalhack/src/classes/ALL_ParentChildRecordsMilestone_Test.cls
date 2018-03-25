//2016-12-05 -venkata.shrivol@cdk.com -commented the project object reference RQ-08305
//2016-12-12 -venkata.shrivol@cdk.com -commented this class as we have new version of UAT grid on subproject now
@isTest
private class ALL_ParentChildRecordsMilestone_Test
{
    //Author: Anirudh Singh
    //Date  : 7th April, 2015
    //Description: This is the test class for the class ALL_ParentChildRecords_Controller.
    //This will test the specific use-case for the Milestone/Activity/Task edit page functionality.
    
   /* @TestSetup static void setupTestData()
    {
        Project__c project=new Project__c();
        project.Name='Test Project';
        insert project;
        
        SubProject__c subProject=new SubProject__c();
        //subProject.Project__c=project.Id;
        insert subProject;
        
        List<Project_Milestone__c> milestoneList=new List<Project_Milestone__c>();
        for(Integer i=0; i<3; i++)
        {
            Project_Milestone__c milestone=new Project_Milestone__c();
            milestone.Description__c='Hardware / Network installed '+i;
            milestone.SubProject__c=subProject.Id;
            milestoneList.add(milestone);
        }
        insert milestoneList;
        
        List<Project_Activity__c> activityList=new List<Project_Activity__c>();
        for(Project_Milestone__c ms: milestoneList)
        {
            for(Integer j=0; j<2; j++)
            {
                Project_Activity__c activity= new Project_Activity__c();
                activity.Milestone__c=ms.Id;
                activity.Description__c='TEST DESCRIPTION '+j;
                activityList.add(activity);
            }
        }
        insert activityList;
        
        List<Project_Task__c> taskList=new List<Project_Task__c>();
        for(Project_Activity__c pa: activityList)
        {
            for(Integer j=0; j<1; j++)
            {
                Project_Task__c task=new Project_Task__c();
                task.Project_Activity__c=pa.Id;
                task.Description__c='TEST DESCRIPTION '+j;
                task.Expected_Time_Spent__c=1;
                taskList.add(task);
            }
        }
        insert taskList;
        
        List<ALL_JSTree_Relationship__c> jsTreeRelationshipList=new List<ALL_JSTree_Relationship__c>();
        
        ALL_JSTree_Relationship__c milesoneActivity=new ALL_JSTree_Relationship__c();
        milesoneActivity.Child_Create_Enabled__c=false;
        milesoneActivity.Child_Description__c='Activities';
        milesoneActivity.Child_FieldOrderSet__c='Activity_Sort_Commons';
        milesoneActivity.Child_Fieldset__c='Activity_Edit_Common';
        milesoneActivity.Child_Object__c='Project_Activity__c';
        milesoneActivity.Child_Relationship__c='Project_Activities__r';
        milesoneActivity.Field_To_Sort_Parent_Record__c='Description__c';
        milesoneActivity.Key__c='Milestone';
        milesoneActivity.Name='MilestoneActivityEdit';
        milesoneActivity.Order__c=1;
        milesoneActivity.Parent_Create_Enabled__c=false;
        milesoneActivity.Parent_Description__c='Milestones';
        milesoneActivity.Parent_FieldOrderSet__c='Milestone_Sort_Commons';
        milesoneActivity.Parent_Fieldset__c='Milestone_Edit_Common';
        milesoneActivity.Parent_Object__c='Project_Milestone__c';
        milesoneActivity.Parent_Relationship_Field_Name__c='Milestone__c';
        milesoneActivity.Parent_Requires_Children__c=true;
        milesoneActivity.Child_DisableCheckField__c='RMS_Owned_Flag__c';
        milesoneActivity.Child_FieldstoDisableForRow__c='RMS_Owner_Disable_Fields_Set';
        milesoneActivity.Parent_DisableCheckField__c='RMS_Owned_Flag__c';
        milesoneActivity.Parent_FieldstoDisableForRow__c='RMS_Owner_Disable_Fields_Set';
        jsTreeRelationshipList.add(milesoneActivity);
        
        ALL_JSTree_Relationship__c activityTask=new ALL_JSTree_Relationship__c();
        activityTask.Child_Create_Enabled__c=true;
        activityTask.Child_Description__c='Tasks';
        activityTask.Child_FieldOrderSet__c='Task_Sort_Commons';
        activityTask.Child_Fieldset__c='Task_Edit_Commons';
        activityTask.Child_Object__c='Project_Task__c';
        activityTask.Child_Relationship__c='Project_Tasks__r';
        activityTask.Field_To_Sort_Parent_Record__c='Description__c';
        activityTask.Grandparent_Display_Field__c='Description__c';
        activityTask.GrandParent_Relationship_Field__c='Milestone__c';
        activityTask.Key__c='Milestone';
        activityTask.Name='ActivityTaskEdit';
        activityTask.Order__c=2;
        activityTask.Parent_Create_Enabled__c=true;
        activityTask.Parent_Description__c='Activities';
        activityTask.Parent_FieldOrderSet__c='Activity_Sort_Commons';
        activityTask.Parent_Fieldset__c='Activity_Edit_Common';
        activityTask.Parent_Object__c='Project_Activity__c';
        activityTask.Parent_Relationship_Field_Name__c='Project_Activity__c';
        activityTask.Parent_Requires_Children__c=true;
        activityTask.Child_DisableCheckField__c='RMS_Owned_Flag__c';
        activityTask.Child_FieldstoDisableForRow__c='RMS_Owner_Disable_Fields_Set';
        activityTask.Parent_DisableCheckField__c='RMS_Owned_Flag__c';
        activityTask.Parent_FieldstoDisableForRow__c='RMS_Owner_Disable_Fields_Set';
        jsTreeRelationshipList.add(activityTask);
        
        insert jsTreeRelationshipList;
    }
    
    static testMethod void validateMilestoneActivitySave()
    {
        system.debug('Start validateMilestoneActivitySave---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Milestone__c ref: milestoneList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Activity__c ref: activityList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Milestone__c', 'Project_Activity__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        parentChildRef.displayQueryResult=queryResult;
        
        queryResult[0].parentSelected=true;
        queryResult[1].parentSelected=true;
        
        queryResult[0].childRecords[0].childSelected=true;
        queryResult[0].childRecords[1].childSelected=true;
        queryResult[1].childRecords[0].childSelected=true;
        queryResult[1].childRecords[1].childSelected=true;
        
        queryResult[0].parentRecord.put('Description__c', 'Confirm project schedule Test');
        //queryResult[0].parentRecord.put('Sort_Sequence__c', 2);
        queryResult[0].parentRecord.put('Planned_Start_Date__c', system.today()+2);
        //queryResult[1].parentRecord.put('Sort_Sequence__c', 1);
        queryResult[1].parentRecord.put('Planned_Start_Date__c', system.today()+10);
        queryResult[1].parentRecord.put('Planned_End_Date__c', system.today()+20);
        
        queryResult[0].childRecords[0].childRecord.put('CDK_Assignee_Role__c', 'A/R Conversion Specialist');
        queryResult[0].childRecords[0].childRecord.put('Description__c', 'RMS request approved Test 1');
        queryResult[0].childRecords[1].childRecord.put('Planned_Start_Date__c', system.today());
        queryResult[0].childRecords[1].childRecord.put('Planned_End_Date__c', system.today()-1);
        queryResult[1].childRecords[0].childRecord.put('Display_on_PSR__c', true);
        queryResult[1].childRecords[0].childRecord.put('Actual_Start_Date__c', system.today()+1);
        queryResult[1].childRecords[1].childRecord.put('Sequence__c', 1);
        pRef.getParameters().put('quickSaveScenario', 'Quick Save');
        parentChildRef.saveMethod(); //Quick Save Scenario
        
        queryResult[0].childRecords[1].childRecord.put('Planned_End_Date__c', system.today()+10);
        queryResult[1].childRecords[0].childRecord.put('CDK_Assignee__c', UserInfo.getUserId());
        queryResult[1].childRecords[0].childRecord.put('Actual_Start_Date__c', system.today());
        pRef.getParameters().put('saveScenario', 'Save'); //Save Scenario
        parentChildRef.saveMethod();
        
        parentChildRef.saveAndCloseMethod();
        
        parentChildRef.cancelMethod();
        test.stopTest();
        system.debug('End validateMilestoneActivitySave---->');
    }
    
    static testMethod void validateMilestoneActivityMassUpdate()
    {
        system.debug('Start validateMilestoneActivityMassUpdate---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Milestone__c ref: milestoneList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Activity__c ref: activityList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Milestone__c', 'Project_Activity__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Parent Mass Update
        parentChildRef.displayParentSelectionPanel();
        String objectTypeParent='Project_Milestone__c';
        List<String> idListParent=new List<Id>();
        idListParent.add(String.valueOf(queryResult[1].parentRecord.get('Id')));
        idListParent.add(String.valueOf(queryResult[2].parentRecord.get('Id')));
        List<String> fieldNamesListParent=new List<String>();
        fieldNamesListParent.add('Planned_Start_Date__c');
        fieldNamesListParent.add('Planned_End_Date__c');
        //fieldNamesListParent.add('Sort_Sequence__c');
        List<String> updatedfieldValuesParent=new List<String>();
        updatedfieldValuesParent.add('6/8/2015');
        updatedfieldValuesParent.add('6/11/2015');
        updatedfieldValuesParent.add('1');
        
        List<String> parentRecordIdsToBeDisabledList=new List<String>();
        parentRecordIdsToBeDisabledList.add(String.valueOf(queryResult[0].parentRecord.get('Id')));
        parentRecordIdsToBeDisabledList.add(String.valueOf(queryResult[1].parentRecord.get('Id')));
        
        List<String> parentFieldsToDisableForRowList=new List<String>();
        parentFieldsToDisableForRowList.add('planned start date');
        parentFieldsToDisableForRowList.add('actual start date');
        
        Map<String, String> massUpdateParent=ALL_ParentChildRecords_Controller.MassUpdate(objectTypeParent, idListParent, fieldNamesListParent, 
                                                                                          updatedfieldValuesParent, parentRecordIdsToBeDisabledList, 
                                                                                          parentFieldsToDisableForRowList);
        pRef.getParameters().put('recordsList', JSON.serialize(massUpdateParent));
        pRef.getParameters().put('typeOfUpdateScenario', 'parentRec');
        parentChildRef.errorOnRecords();
        
        //Child Mass Update
        parentChildRef.displayChildSelectionPanel();
        String objectTypeChild='Project_Activity__c';
        List<String> idListChild=new List<Id>();
        idListChild.add(String.valueOf(queryResult[0].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[0].childRecords[1].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[1].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[1].childRecords[1].childRecord.get('Id')));
        List<String> fieldNamesListChild=new List<String>();
        fieldNamesListChild.add('CDK_Assignee__c');
        fieldNamesListChild.add('Standard__c');
        fieldNamesListChild.add('Planned_Start_Date__c');
        fieldNamesListChild.add('Planned_End_Date__c');
        fieldNamesListChild.add('Sequence__c');
        List<String> updatedfieldValuesChild=new List<String>();
        updatedfieldValuesChild.add(UserInfo.getUserId());
        updatedfieldValuesChild.add('0');
        updatedfieldValuesChild.add('6/8/2015');
        updatedfieldValuesChild.add('6/11/2015');
        updatedfieldValuesChild.add('3');
        
        List<String> childRecordIdsToBeDisabledList=new List<String>();
        childRecordIdsToBeDisabledList.add(String.valueOf(queryResult[0].childRecords[1].childRecord.get('Id')));
        childRecordIdsToBeDisabledList.add(String.valueOf(queryResult[1].childRecords[0].childRecord.get('Id')));
        
        List<String> childFieldsToDisableForRowList=new List<String>();
        childFieldsToDisableForRowList.add('CDK Assignee');
        childFieldsToDisableForRowList.add('Sequence');
        
        Map<String, String> massUpdateChild=ALL_ParentChildRecords_Controller.MassUpdate(objectTypeChild, idListChild, fieldNamesListChild, 
                                                                                         updatedfieldValuesChild, childRecordIdsToBeDisabledList, 
                                                                                         childFieldsToDisableForRowList);
        pRef.getParameters().put('recordsList', JSON.serialize(massUpdateChild));
        pRef.getParameters().put('typeOfUpdateScenario', 'childRec');
        parentChildRef.errorOnRecords();
        parentChildRef.massUpdateMethod();
        test.stopTest();
        system.debug('End validateMilestoneActivityMassUpdate---->');
    }
    
    static testMethod void milestoneActivityFieldUpdateViewMode()
    {
        system.debug('Start milestoneActivityFieldUpdateViewMode---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Milestone__c ref: milestoneList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Activity__c ref: activityList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Milestone__c', 'Project_Activity__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Field Update in View Mode.
        pRef.getParameters().put('fieldName', 'Actual Start Date');
        pRef.getParameters().put('recordId', String.valueOf(queryResult[0].parentRecord.get('Id')));
        parentChildRef.displayFieldUpdatePanel();
        parentChildRef.objectToUpdateInViewMode.put('Actual_Start_Date__c', system.today()+10);
        parentChildRef.fieldUpdateInViewMode();
        
        pRef.getParameters().put('fieldName', 'Description');
        pRef.getParameters().put('recordId', String.valueOf(queryResult[0].childRecords[0].childRecord.get('Id')));
        parentChildRef.displayFieldUpdatePanel();
        parentChildRef.closeFieldUpdatePanel();
        test.stopTest();
        system.debug('End milestoneActivityFieldUpdateViewMode---->');
    }
    
    static testMethod void validateMilestoneActivityDelete()
    {
        system.debug('Start validateMilestoneActivityDelete---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Milestone__c ref: milestoneList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Activity__c ref: activityList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Milestone__c', 'Project_Activity__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Delete Scenario
        List<Id> childRecordsToBeDeleted=new List<Id>();
        childRecordsToBeDeleted.add(String.valueOf(queryResult[0].childRecords[0].childRecord.get('Id')));
        Map<String, String> childRecordsWithErrorMessagesMap=ALL_ParentChildRecords_Controller.deleteRecords(childRecordsToBeDeleted);
        pRef.getParameters().put('recordsList', JSON.serialize(childRecordsWithErrorMessagesMap));
        pRef.getParameters().put('typeOfUpdateScenario', 'childRec');
        parentChildRef.errorOnRecords();
        
        List<Id> parentRecordsToBeDeleted=new List<Id>();
        parentRecordsToBeDeleted.add(String.valueOf(queryResult[0].parentRecord.get('Id')));
        parentRecordsToBeDeleted.add(String.valueOf(queryResult[1].parentRecord.get('Id')));
        Map<String, String> parentRecordsWithErrorMessagesMap=ALL_ParentChildRecords_Controller.deleteRecords(parentRecordsToBeDeleted);
        pRef.getParameters().put('recordsList', JSON.serialize(parentRecordsWithErrorMessagesMap));
        pRef.getParameters().put('typeOfUpdateScenario', 'parentRec');
        parentChildRef.errorOnRecords();
        test.stopTest();
        system.debug('End validateMilestoneActivityDelete---->');
    }
    
    static testMethod void miscellaneousMilestoneActivityValidations()
    {
        system.debug('Start miscellaneousMilestoneActivityValidations---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Milestone__c ref: milestoneList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Activity__c ref: activityList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Milestone__c', 'Project_Activity__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        parentChildRef.createNewParentWGrandparent();
        String lookupFieldValue=ALL_ParentChildRecords_Controller.fetchUserId('anirudh singh', 'Project_Activity__c', 'CDK_Assignee__c');
        test.stopTest();
        system.debug('End miscellaneousMilestoneActivityValidations---->');
    }
    
    static testMethod void validateActivityTaskSave()
    {
        system.debug('Start validateActivityTaskSave---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        List<Project_Task__c> taskList=[SELECT Id FROM Project_Task__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Activity__c ref: activityList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Task__c ref: taskList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Activity__c', 'Project_Task__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> childColsWidths=parentChildRef.displayChildColumnsAndWidthList;
        List<ALL_ParentChildRecords_Controller.ColumnAndWidthsWrapper> parentColsWidths=parentChildRef.displayParentColumnsAndWidthList;
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Success Create New Parent Scenario
        parentChildRef.createNewParentWGrandparent();
        List<SelectOption> displayGrandparentOptions=parentChildRef.displayGrandparentOptions;
        parentChildRef.displayGrandparentOptions=displayGrandparentOptions;
        
        parentChildRef.selectedGrandparent=displayGrandparentOptions[0].getValue();
        parentChildRef.closeGrandparentPanel();
        queryResult[0].parentRecord.put('Description__c', 'Hardware / Network installed 3');
        queryResult[0].parentRecord.put('Planned_Start_Date__c', system.today());
        queryResult[0].parentRecord.put('Planned_End_Date__c', system.today()+10);
        queryResult[0].parentRecord.put('Display_on_PSR__c', false);
        pRef.getParameters().put('quickSaveScenario', 'Quick Save');
        parentChildRef.saveMethod();
        
        queryResult[0].childRecords[0].childRecord.put('Description__c', 'TEST DESCRIPTION 0');
        queryResult[0].childRecords[0].childRecord.put('Project_Activity__c', String.valueOf(queryResult[0].parentRecord.get('Id')));
        queryResult[0].childRecords[0].childRecord.put('Expected_Time_Spent__c', 90);
        parentChildRef.saveMethod();
        
        parentChildRef.selectedGrandparent=displayGrandparentOptions[1].getValue();
        parentChildRef.closeGrandparentPanel();
        queryResult[0].parentRecord.put('Description__c', 'Test Parent Create 2');
        queryResult[0].parentRecord.put('Actual_Start_Date__c', system.today()+10);
        queryResult[0].parentRecord.put('Actual_End_Date__c', system.today()+1);
        queryResult[0].parentRecord.put('Display_on_PSR__c', false);
        pRef.getParameters().put('quickSaveScenario', 'Quick Save');
        parentChildRef.saveMethod();
        
        parentChildRef.cancelMethod();
        test.stopTest();
        system.debug('End validateActivityTaskSave---->');
    }
    
    static testMethod void validateActivityTaskSaveNewRec()
    {
        system.debug('Start validateActivityTaskSaveNewRec---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        List<Project_Task__c> taskList=[SELECT Id FROM Project_Task__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Activity__c ref: activityList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Task__c ref: taskList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Activity__c', 'Project_Task__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        queryResult[1].parentSelected=true;
        queryResult[2].parentSelected=true;
        queryResult[3].parentSelected=true;
        queryResult[4].parentSelected=true;
        
        queryResult[1].childRecords[0].childSelected=true;
        queryResult[3].childRecords[0].childSelected=true;
        
        //Create New Child Scenario
        parentChildRef.parentId=String.valueOf(queryResult[1].parentRecord.get('Id'));
        parentChildRef.createNewChild();
        
        parentChildRef.parentId=String.valueOf(queryResult[1].parentRecord.get('Id'));
        parentChildRef.createNewChild();
        
        parentChildRef.parentId=String.valueOf(queryResult[4].parentRecord.get('Id'));
        parentChildRef.createNewChild();
        
        queryResult[1].childRecords[0].childRecord.put('Actual_End_Date__c', system.today()+1);
        
        //Update Scenario
        queryResult[1].parentRecord.put('Description__c', 'RMS request approved Test 1');
        queryResult[1].parentRecord.put('CDK_Assignee_Role__c', 'A/R Conversion Specialist');
        queryResult[1].parentRecord.put('Planned_Start_Date__c', system.today());
        queryResult[1].parentRecord.put('CDK_Assignee__c', UserInfo.getUserId());
        
        queryResult[2].parentRecord.put('Description__c', 'RMS request approved Test 2');
        queryResult[2].parentRecord.put('Planned_Start_Date__c', system.today());
        queryResult[2].parentRecord.put('Planned_End_Date__c', system.today()-1);
        
        queryResult[3].parentRecord.put('Description__c', 'RMS request approved Test 3');
        queryResult[3].parentRecord.put('Display_on_PSR__c', true);
        queryResult[3].parentRecord.put('Actual_Start_Date__c', system.today()+1);
        
        queryResult[4].parentRecord.put('Description__c', 'RMS request approved Test 4');
        queryResult[4].parentRecord.put('Display_on_PSR__c', true);
        queryResult[4].parentRecord.put('Actual_Start_Date__c', system.today());
        
        queryResult[1].childRecords[2].childRecord.put('Description__c', 'RMS request approved Task Test 1');
        queryResult[1].childRecords[2].childRecord.put('Expected_Time_Spent__c', 30);
        
        queryResult[3].childRecords[0].childRecord.put('Description__c', 'RMS request approved Task Test 2');
        queryResult[3].childRecords[0].childRecord.put('Actual_End_Date__c', system.today()+1);
        parentChildRef.saveMethod(); //Quick Save Scenario
        
        queryResult[2].parentRecord.put('CDK_Assignee__c', UserInfo.getUserId());
        queryResult[2].parentRecord.put('Planned_Start_Date__c', system.today()+1);
        queryResult[2].parentRecord.put('Planned_End_Date__c', system.today()+10);
        
        queryResult[3].parentRecord.put('CDK_Assignee__c', UserInfo.getUserId());
        queryResult[3].parentRecord.put('Actual_Start_Date__c', system.today()-1);
        
        queryResult[4].parentRecord.put('CDK_Assignee__c', UserInfo.getUserId());
        queryResult[4].parentRecord.put('Actual_Start_Date__c', system.today());
        
        queryResult[1].childRecords[0].childRecord.put('Actual_Start_Date__c', system.today()-10);
        queryResult[1].childRecords[0].childRecord.put('Actual_End_Date__c', null);
        
        queryResult[3].childRecords[0].childRecord.put('CDK_Assignee__c', UserInfo.getUserId());
        queryResult[3].childRecords[0].childRecord.put('Actual_Start_Date__c', system.today()-10);
        queryResult[3].childRecords[0].childRecord.put('Actual_End_Date__c', null);
        pRef.getParameters().put('saveScenario', 'Save');
        parentChildRef.saveMethod(); //Save Scenario
        
        parentChildRef.saveAndCloseMethod();
        
        parentChildRef.cancelMethod();
        test.stopTest();
        system.debug('End validateActivityTaskSaveNewRec---->');
    }
    
    static testMethod void validateActivityTaskMassUpdate()
    {
        system.debug('Start validateActivityTaskMassUpdate---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        List<Project_Task__c> taskList=[SELECT Id FROM Project_Task__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Activity__c ref: activityList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Task__c ref: taskList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Activity__c', 'Project_Task__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Parent Mass Update
        parentChildRef.displayParentSelectionPanel();
        String objectTypeParent='Project_Activity__c';
        List<String> idListParent=new List<Id>();
        idListParent.add(String.valueOf(queryResult[1].parentRecord.get('Id')));
        idListParent.add(String.valueOf(queryResult[2].parentRecord.get('Id')));
        idListParent.add(String.valueOf(queryResult[4].parentRecord.get('Id')));
        idListParent.add(String.valueOf(queryResult[5].parentRecord.get('Id')));
        List<String> fieldNamesListParent=new List<String>();
        fieldNamesListParent.add('CDK_Assignee__c');
        fieldNamesListParent.add('Display_on_PSR__c');
        fieldNamesListParent.add('Planned_Start_Date__c');
        fieldNamesListParent.add('Planned_End_Date__c');
        fieldNamesListParent.add('Sequence__c');
        List<String> updatedfieldValuesParent=new List<String>();
        updatedfieldValuesParent.add(UserInfo.getUserId());
        updatedfieldValuesParent.add('1');
        updatedfieldValuesParent.add('6/8/2015');
        updatedfieldValuesParent.add('6/11/2015');
        updatedfieldValuesParent.add('1');
        
        List<String> parentRecordIdsToBeDisabledList=new List<String>();
        parentRecordIdsToBeDisabledList.add(String.valueOf(queryResult[1].parentRecord.get('Id')));
        parentRecordIdsToBeDisabledList.add(String.valueOf(queryResult[3].parentRecord.get('Id')));
        
        List<String> parentFieldsToDisableForRowList=new List<String>();
        parentFieldsToDisableForRowList.add('planned start date');
        parentFieldsToDisableForRowList.add('actual start date');
        
        Map<String, String> massUpdateParent=ALL_ParentChildRecords_Controller.MassUpdate(objectTypeParent, idListParent, fieldNamesListParent, 
                                                                                          updatedfieldValuesParent, parentRecordIdsToBeDisabledList, 
                                                                                          parentFieldsToDisableForRowList);
        pRef.getParameters().put('recordsList', JSON.serialize(massUpdateParent));
        pRef.getParameters().put('typeOfUpdateScenario', 'parentRec');
        parentChildRef.errorOnRecords();
        
        //Child Mass Update
        parentChildRef.displayChildSelectionPanel();
        String objectTypeChild='Project_Task__c';
        List<String> idListChild=new List<Id>();
        idListChild.add(String.valueOf(queryResult[1].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[2].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[3].childRecords[0].childRecord.get('Id')));
        idListChild.add(String.valueOf(queryResult[5].childRecords[0].childRecord.get('Id')));
        List<String> fieldNamesListChild=new List<String>();
        fieldNamesListChild.add('CDK_Assignee__c');
        fieldNamesListChild.add('Standard__c');
        fieldNamesListChild.add('Planned_Start_Date__c');
        fieldNamesListChild.add('Planned_End_Date__c');
        fieldNamesListChild.add('Sequence__c');
        fieldNamesListChild.add('Actual_Start_Date__c');
        fieldNamesListChild.add('Actual_End_Date__c');
        List<String> updatedfieldValuesChild=new List<String>();
        updatedfieldValuesChild.add(UserInfo.getUserId());
        updatedfieldValuesChild.add('0');
        updatedfieldValuesChild.add('6/11/2015');
        updatedfieldValuesChild.add('6/8/2015');
        updatedfieldValuesChild.add('3');
        updatedfieldValuesChild.add('7/11/2015');
        updatedfieldValuesChild.add('6/11/2015');
        
        List<String> childRecordIdsToBeDisabledList=new List<String>();
        childRecordIdsToBeDisabledList.add(String.valueOf(queryResult[1].childRecords[0].childRecord.get('Id')));
        childRecordIdsToBeDisabledList.add(String.valueOf(queryResult[2].childRecords[0].childRecord.get('Id')));
        
        List<String> childFieldsToDisableForRowList=new List<String>();
        childFieldsToDisableForRowList.add('CDK Assignee');
        childFieldsToDisableForRowList.add('Sequence');
        
        Map<String, String> massUpdateChild=ALL_ParentChildRecords_Controller.MassUpdate(objectTypeChild, idListChild, fieldNamesListChild, 
                                                                                         updatedfieldValuesChild, childRecordIdsToBeDisabledList, 
                                                                                         childFieldsToDisableForRowList);
        pRef.getParameters().put('recordsList', JSON.serialize(massUpdateChild));
        pRef.getParameters().put('typeOfUpdateScenario', 'childRec');
        parentChildRef.errorOnRecords();
        parentChildRef.massUpdateMethod();
        test.stopTest();
        system.debug('End validateActivityTaskMassUpdate---->');
    }
    
    static testMethod void activityTaskFieldUpdateViewMode()
    {
        system.debug('Start activityTaskFieldUpdateViewMode---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        List<Project_Task__c> taskList=[SELECT Id FROM Project_Task__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Activity__c ref: activityList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Task__c ref: taskList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Activity__c', 'Project_Task__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        pRef.getParameters().put('fieldName', 'Actual Start Date');
        pRef.getParameters().put('recordId', String.valueOf(queryResult[0].parentRecord.get('Id')));
        parentChildRef.displayFieldUpdatePanel();
        parentChildRef.objectToUpdateInViewMode.put('Actual_Start_Date__c', system.today()+10);
        parentChildRef.fieldUpdateInViewMode();
        
        pRef.getParameters().put('fieldName', 'Description');
        pRef.getParameters().put('recordId', String.valueOf(queryResult[0].childRecords[0].childRecord.get('Id')));
        parentChildRef.displayFieldUpdatePanel();
        parentChildRef.closeFieldUpdatePanel();
        test.stopTest();
        system.debug('End activityTaskFieldUpdateViewMode---->');
    }
    
    static testMethod void validateActivityTaskDelete()
    {
        system.debug('Start validateActivityTaskDelete---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c FROM Project_Activity__c];
        List<Project_Task__c> taskList=[SELECT Id FROM Project_Task__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Activity__c ref: activityList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Task__c ref: taskList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Activity__c', 'Project_Task__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        //Delete Scenario
        List<Id> childRecordsToBeDeleted=new List<Id>();
        childRecordsToBeDeleted.add(String.valueOf(queryResult[0].childRecords[0].childRecord.get('Id')));
        Map<String, String> childRecordsWithErrorMessagesMap=ALL_ParentChildRecords_Controller.deleteRecords(childRecordsToBeDeleted);
        pRef.getParameters().put('recordsList', JSON.serialize(childRecordsWithErrorMessagesMap));
        pRef.getParameters().put('typeOfUpdateScenario', 'childRec');
        parentChildRef.errorOnRecords();
        
        List<Id> parentRecordsToBeDeleted=new List<Id>();
        parentRecordsToBeDeleted.add(String.valueOf(queryResult[0].parentRecord.get('Id')));
        parentRecordsToBeDeleted.add(String.valueOf(queryResult[1].parentRecord.get('Id')));
        Map<String, String> parentRecordsWithErrorMessagesMap=ALL_ParentChildRecords_Controller.deleteRecords(parentRecordsToBeDeleted);
        pRef.getParameters().put('recordsList', JSON.serialize(parentRecordsWithErrorMessagesMap));
        pRef.getParameters().put('typeOfUpdateScenario', 'parentRec');
        parentChildRef.errorOnRecords();
        
        parentChildRef.createNewParentWGrandparent();
        parentChildRef.cancelGrandparentPanel();
        
        parentChildRef.reloadMethod();
        
        test.stopTest();
        system.debug('End validateActivityTaskDelete---->');
    }
    
    static testMethod void miscellaneousValidations()
    {
        system.debug('Start miscellaneousValidations---->');
        SubProject__c subProject=[SELECT Id FROM SubProject__c LIMIT 1];
        List<Project_Milestone__c> milestoneList=[SELECT Id FROM Project_Milestone__c];
        List<Project_Activity__c> activityList=[SELECT Id, Milestone__c, Display_on_PSR__c FROM Project_Activity__c];
        
        List<String> parentIdsList=new List<String>();
        List<String> childIdsList=new List<String>();
        
        for(Project_Milestone__c ref: milestoneList)
        {
            parentIdsList.add(ref.Id);
        }
        
        for(Project_Activity__c ref: activityList)
        {
            childIdsList.add(ref.Id);
        }
        
        String parentSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(parentIdsList, '\',\'')+'\'';
        String childSelectedId='\''+ALL_UtilitiesString.ListToDelimitedString(childIdsList, '\',\'')+'\'';
        
        PageReference pRef=Page.ALL_RecordsView;
        pRef.getParameters().put('id', subProject.Id);
        pRef.getParameters().put('key', 'Milestone');        
        Test.setCurrentPage(pRef);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        test.startTest();
        ALL_RecordsView_Controller pageContRef=new ALL_RecordsView_Controller();
        pageContRef.somethingIsSelected('Project_Milestone__c', 'Project_Activity__c', parentSelectedId, childSelectedId);
        
        ALL_ParentChildRecords_Controller parentChildRef=new ALL_ParentChildRecords_Controller();
        pageContRef.attributesCollection.filterConditionChild='where Display_on_PSR__c=true limit 10';
        pageContRef.attributesCollection.filterConditionParent='where Planned_End_Date__c!=Null limit 10';
        parentChildRef.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult=parentChildRef.displayQueryResult;
        
        ALL_ParentChildRecords_Controller parentChildRef1=new ALL_ParentChildRecords_Controller();
        pageContRef.attributesCollection.filterConditionChild='limit 10';
        pageContRef.attributesCollection.filterConditionParent='limit 10';
        parentChildRef1.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef1.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult1=parentChildRef1.displayQueryResult;
        
        ALL_ParentChildRecords_Controller parentChildRef2=new ALL_ParentChildRecords_Controller();
        ALL_RecordsViewWrapper attributesCollection=new ALL_RecordsViewWrapper();
        pageContRef.attributesCollection.parentAPIName='abc';
        pageContRef.attributesCollection.filterConditionChild='';
        pageContRef.attributesCollection.filterConditionParent='';
        parentChildRef2.fetchAllAttributes=attributesCollection;
        parentChildRef2.pageController=new ALL_PageBase_Controller();
        
        List<ALL_ParentChildRecords_Controller.ParentWrapper> queryResult2=parentChildRef2.displayQueryResult;
        
        ALL_ParentChildRecords_Controller parentChildRef3=new ALL_ParentChildRecords_Controller();
        pageContRef.attributesCollection.dataAvailable=false;
        parentChildRef3.fetchAllAttributes=pageContRef.attributesCollection;
        parentChildRef3.pageController=new ALL_PageBase_Controller();
        test.stopTest();
        
        system.debug('End miscellaneousValidations---->');
    }*/
}