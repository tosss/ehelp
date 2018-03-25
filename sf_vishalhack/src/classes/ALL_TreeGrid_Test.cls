/***********************************************************************************************
* RQ-04476  
* Author: Ragashalini.Koka@cdk.com
* Description: Test class for the ALL_TreeGridController_UIGrid
*
* History
* 2016-03-02   Ragashalini.Koka@cdk.com   modified test class using the IMP_TestFactory_Helper
* 2016-04-14   Ragashalini.Koka@cdk.com   added sortfieldset values in testSetup
* 2016-12-05   venkata.shrivol@cdk.com	  commented project object reference RQ-08305
* 2016-12-06   venkata.shrivol@cdk.com    temporarily commented the whole class
* 2016-12-07   ragashalini.koka@cdk.com   changed the SOQL queries using the Project reference
* *********************************************************************************************** */

@isTest
private class ALL_TreeGrid_Test {
    
   /* @testSetup static void setupTestData() {
        
        /*Project__c project = IMP_TestFactory_Helper.buildProject(1);
       
        insert project;*/
        
     /*   SubProject__c subProject =  IMP_TestFactory_Helper.buildSubProject();
        insert subProject;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        CMF_Info__c cmfInfo = new CMF_Info__c();
        cmfInfo.Name = 'A Test CMF Info';
        cmfInfo.Account__c = acc.Id;
        cmfInfo.Status__c = 'A';
        insert cmfInfo;
        
        SubProjectSite__c subprojectSite = IMP_TestFactory_Helper.buildSubProjectSite(acc.Id, subProject.Id, cmfInfo.Id);
        subprojectSite.CMF_Numbers__c = '1234567';
        insert subprojectSite;
        List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
        for(Integer i=0; i<3; i++) {
            Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, 'Test Milestone Description '+i);
            milestoneList.add(milestone);
        }
        insert milestoneList;
        
        List<Project_Activity__c> activityList=new List<Project_Activity__c>();
        
        for(Project_Milestone__c ms: milestoneList) {
            Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(ms.Id);
            activity.CDK_Assignee__c = UserInfo.getUserId();
            activityList.add(activity);
        }
        
        insert activityList;
        
        List<Project_Task__c> taskList=new List<Project_Task__c>();
        for(Project_Activity__c pa: activityList) {
           Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(pa.Id);
           taskList.add(task);
        }
        insert taskList;
        
        
        List<String> treeGridNameList = new List<String>{'Test-001','Test-002','Test-003'};
        List<String> treeGridObjectChildRelationshipNameList = new List<String>{'Project_Milestones__r','Project_Activities__r','Project_Tasks__r'};
        List<String> treeGridObjectParentAPINameList = new List<String>{'SubProject__c','Milestone__c','Project_Activity__c'};            
        List<String> treeGridObjectParentRelationshipNameList = new List<String>{'SubProject__r','Milestone__r','Project_Activity__r'};            
        String treeGridObjectTreeGridIdentifier= 'TEST';                
        List<String> treeGridObjectAPINameList = new List<String>{'Project_Milestone__c','Project_Activity__c','Project_Task__c'};            
        List<String> treeGridObjectDisplayNameList = new List<String>{'Project Milestone','Project Activity','Project Task'};            
        List<String> treeGridObjectParentNameList = new List<String>{null,'Project_Milestone__c','Project_Activity__c'};            
                    
        List<ALL_Treegrid_Object__c> treeGridObjectList  = new List<ALL_Treegrid_Object__c>();
        
        for(Integer i = 0; i < 3; i++) {
            ALL_Treegrid_Object__c treeGridObject = new ALL_Treegrid_Object__c();
            treeGridObject.Name = treeGridNameList[i];
            treeGridObject.ChildRelationshipName__c = treeGridObjectChildRelationshipNameList[i];
            treeGridObject.ParentAPIName__c = treeGridObjectParentAPINameList[i];
            treeGridObject.ParentRelationshipName__c = treeGridObjectParentRelationshipNameList[i];
            treeGridObject.TreegridIdentifier__c = treeGridObjectTreeGridIdentifier;
            treeGridObject.ObjectAPIName__c = treeGridObjectAPINameList[i];
            treeGridObject.DisplayName__c = treeGridObjectDisplayNameList[i];
            treeGridObject.ParentName__c = treeGridObjectParentNameList[i];
            treeGridObjectList.add(treeGridObject);
        }
        insert treeGridObjectList;
        
        List<ALL_TreeGrid_Field__c> treeGridFieldList  = new List<ALL_TreeGrid_Field__c>();
        List<String> fieldSetNamesList = new List<String>{'Milestone_UI_Grid','Activity_UI_Grid','Task_UI_Grid'};
        List<String> sortFieldsetList = new List<String>{'Milestone_Sort_Commons','Activity_Sort_Commons','Task_Sort_Commons'};    
            for(Integer i = 0; i < 3 ;i++) {
                ALL_TreeGrid_Field__c treeGridField = new ALL_TreeGrid_Field__c();
                treeGridField.Name = treeGridNameList[i];
                treeGridField.TreegridIdentifier__c = treeGridObjectTreeGridIdentifier;
                treeGridField.ObjectAPIName__c = treeGridObjectAPINameList[i];
                treeGridField.FieldSetName__c = fieldSetNamesList[i];
                treeGridField.Sort_Fieldset__c = sortFieldsetList[i];
                treeGridFieldList.add(treeGridField);
            }
        
        insert treeGridFieldList;
        
    }  
    
    static testmethod void validateInitialization() {
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_TreeGrid'));
        
        String objectName = 'Project_Milestone__c';
        String treeGridIdentifier = 'TEST';
        SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
        System.currentPageReference().getParameters().put('object',objectName);
        System.currentPageReference().getParameters().put('id',subProject.Id);
        System.currentPageReference().getParameters().put('treeId',treeGridIdentifier);
        
        
        ALL_TreeGridController_UIGrid treeGridObj = new ALL_TreeGridController_UIGrid(new ALL_AngularInputFields_Controller());
        
        
    }
    
    
    
    static testmethod void validateGetObjectName() {
        List<Project_Milestone__c> milestoneList = [
            SELECT Id 
            FROM Project_Milestone__c
            WHERE Description__c LIKE '%Test Milestone Description%'
            LIMIT 1
        ];
        test.startTest();
        if(milestoneList.size() > 0) {
            String actualObjectName = ALL_TreeGridController_UIGrid.getObjectName(new List<String>{String.valueOf(milestoneList[0].Id)});
            String expectedObjectName = milestoneList[0].Id.getSObjectType().getDescribe().getName();
            System.assertEquals(expectedObjectName, actualObjectName);
        }
        test.stopTest();
        
    }
    
    static testmethod void validateUpdateInsertRecords() {
        
        List<Project_Milestone__c> milestoneUpdateList = [
            SELECT Id,Description__c
            FROM Project_Milestone__c
            WHERE Description__c 
            LIKE '%Test Milestone Description%'
            LIMIT 2
        ];
        test.startTest();
        if(milestoneUpdateList.size() > 1) {
            String updatedDescription =  'Updated' + milestoneUpdateList[0].Description__c ;
            milestoneUpdateList[0].Description__c = updatedDescription;
            milestoneUpdateList[1].Description__c = '';
            
           SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
            
            
            List<Project_Milestone__c> milestoneInsertList = new List<Project_Milestone__c>();
            Project_Milestone__c milestone1 = new Project_Milestone__c();
            Project_Milestone__c milestone2 = new Project_Milestone__c();
            milestone1.Description__c = 'Inserted Test Milestone Description';
            milestone1.SubProject__c=subProject.Id;
            
            milestoneInsertList.add(milestone1);
            milestoneInsertList.add(milestone2);
            
            ALL_TreeGridController_UIGrid.updateInsertRecords(JSON.serialize(milestoneUpdateList),JSON.serialize(milestoneInsertList));
            List<Id> milestoneUpdateIdList = new List<Id>{milestoneUpdateList[0].Id,milestoneUpdateList[1].Id};
                milestoneUpdateList = [
                    SELECT Id,Description__c
                    FROM Project_Milestone__c
                    WHERE Id IN : milestoneUpdateIdList
                    
                ];
            
            milestoneInsertList = [
                SELECT Id,Description__c 
                FROM Project_Milestone__c
                WHERE Description__c LIKE '%Inserted Test Milestone Description%'
            ];
            
            
            System.assertEquals(updatedDescription, milestoneUpdateList[0].Description__c);
            System.assertEquals(1,milestoneInsertList.size());
            test.stopTest();
            
        } 
        ALL_TreeGridController_UIGrid.updateInsertRecords('','');
    }
    
 /*   static testmethod void validateMassUpdateFields() {
        String objectName = 'Project_Milestone__c';
        String treeGridIdentifier = 'TEST';
        test.startTest();
        Map<String,ALL_TreeGridObject.ALL_TreeGridFields> fieldMap = ALL_TreeGridController_UIGrid.massUpdateFields(objectName,treeGridIdentifier);
        System.assert(fieldMap.size() > 0);
        test.stopTest();
    }*/
    
   /* static testmethod void validateDeleteRecords() {
        
        List<Project_Milestone__c> milestoneList = [
            SELECT Id 
            FROM Project_Milestone__c
            WHERE Description__c LIKE '%Test Milestone Description%'
            LIMIT 1
        ];
        
        SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
        
        
        List<Project_Milestone__c> milestoneInsertList = new List<Project_Milestone__c>();
        Project_Milestone__c milestone1 = new Project_Milestone__c();
        milestone1.Description__c = 'Deleting Test Milestone Description';
        milestone1.SubProject__c=subProject.Id;
        milestoneInsertList.add(milestone1);
        insert milestoneInsertList;
        delete milestoneInsertList;
        List<Id> milestoneDeleteIdList = new List<Id>();
        if(milestoneList.size() > 0) {
            
            milestoneDeleteIdList.add(milestoneList[0].Id);
        }
        milestoneDeleteIdList.add(milestone1.Id);
        
        Test.startTest();
        ALL_TreeGridController_UIGrid.deleteRecords(milestoneDeleteIdList);
        milestoneDeleteIdList.clear();
        
        Test.stopTest(); 
    }
    //2016-06-30 ragashalini.koka@cdk.com commented as the function no longer exists in the class
   /* static testmethod void validateSearchRecords() {
        String objectName = 'Project_Activity__c';
        String treeGridIdentifier = 'TEST';
        String searchTxt = 'Test';
        
        Map<Id,Project_Milestone__c> milestoneMap = new Map<Id,Project_Milestone__c>([
            SELECT Id 
            From Project_Milestone__c
            WHERE Description__c LIKE '%Test Milestone Description%'
        ]);
        
        test.startTest();
        ALL_TreeGridController_UIGrid.searchRecords(searchTxt,new List<Id>(milestoneMap.keySet()), objectName, treeGridIdentifier);
        ALL_TreeGridController_UIGrid.searchRecords('koka',new List<Id>(milestoneMap.keySet()), objectName, treeGridIdentifier);
        objectName = 'Project_Milestone__c';
        ALL_TreeGridController_UIGrid.searchRecords(searchTxt,new List<Id>(milestoneMap.keySet()), objectName, treeGridIdentifier);
        objectName = 'Project Activity';
        ALL_TreeGridController_UIGrid.searchRecords(searchTxt,new List<Id>(milestoneMap.keySet()), objectName, treeGridIdentifier);
        test.stopTest();
        
        
    }*/
    
  /*  static testMethod void validateGetRecordsOfAllLevels() {
        
        String treeGridIdentifier = 'TEST';
        
       SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
        
        test.startTest();
        
        ALL_TreeGridController_UIGrid.getRecordsOfAllLevels(treeGridIdentifier,subproject.id);
        ALL_TreeGridController_UIGrid.getRecordsOfAllLevels(treeGridIdentifier,'abc');
        test.stopTest();
        
        
    }
    
    static testmethod void validateGetLevelOneIds() {
          String treeGridIdentifier = 'TEST';
        
        SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
        
        test.startTest();
        
        ALL_TreeGridController_UIGrid.getLevelOneIds(subproject.id,'Project_Milestone__c', treeGridIdentifier);
       
        test.stopTest();
        
        
    }
    
    static testmethod void validateGetFieldValueForHierarchy() {
         String treeGridIdentifier = 'TEST';
        
       SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
        
        test.startTest();
        
        ALL_TreeGridController_UIGrid.getFieldValueForHierarchy(subproject,'Project__r.Name');
       
        test.stopTest();
    }
    
    static testmethod void validateAddNewContact() {
         String treeGridIdentifier = 'TEST';
        
        SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
        
        test.startTest();
        
        ALL_TreeGridController_UIGrid.addNewContact('{"firstName":"test","lastName":"tetst","email":"","phone":"","accId":"0018A000001nHI2QAM","ctctRole":"Account Executive","projectRole":"Business Operations Advocate","subprojectId":"a428A000000N9crQAC"}');
       
        test.stopTest();
        
    }
    static testmethod void validateGetSiteValues() {
            String treeGridIdentifier = 'TEST';
        
        SubProject__c subproject = [
            SELECT Id,  Project__r.Name
            FROM SubProject__c 
            LIMIT 1
        ];
        
        test.startTest();
        
        ALL_TreeGridController_UIGrid.getSiteValues(subproject.Id);
        test.stopTest();
        
    }
   */ 
}