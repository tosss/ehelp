@isTest
private class ISVC_AssignIncidentsToProblem_Test {
    @testSetup
    static void dataSetup() {
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();

        List<Case> cases = new List<Case>();
        //Incidents
        for(Integer i=0; i<10; i++){
            ISVC_Case_Builder incidentCaseBuilder = new ISVC_Case_Builder();
            incidentCaseBuilder.recordTypeId(incidentRecordTypeId).subject('Incident 000'+(i+1)).build();
            cases.add(incidentCaseBuilder.getRecord());
        }
        //Problems
        for(Integer i=0; i<35; i++){
            ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
            problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem 000'+(i+1)).build();
            cases.add(problemCaseBuilder.getRecord());
        }

        insert cases;
    }

    //Succesfull flow
    static testMethod void testAssignIncidentsToExistingProblem() {
        //Given:
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        List<Case> incidents = [SELECT Id, ParentId FROM Case WHERE RecordTypeId = :incidentRecordTypeId];
        PageReference pageRef = Page.ISVC_AssignIncidentsToProblem;
        Test.setCurrentPage(pageRef);
        //When:
        Test.startTest();
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(incidents);
        stdController.setSelected(incidents);
        ISVC_AssignIncidentsToProblem_Extension controller = new ISVC_AssignIncidentsToProblem_Extension(stdController);
        controller.searchText = '0003';
        controller.searchOpenProblems();
        controller.selectedProblemId = controller.openProblems[0].Id;
        controller.linkToProblem();
        Test.stopTest();
        //Then:
        Case selectedProblem = [SELECT Id FROM Case WHERE Subject = 'Problem 0003'];
        for(Case incident : [SELECT Id, ParentId FROM Case WHERE RecordTypeId = :incidentRecordTypeId]){
            System.assertEquals(selectedProblem.Id, incident.ParentId);
        }
    }

    //Succesfull flow
    static testMethod void testAssignIncidentsToNewProblem() {
        //Given:
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        List<Case> incidents = [SELECT Id, ParentId FROM Case WHERE RecordTypeId = :incidentRecordTypeId];
        PageReference pageRef = Page.ISVC_AssignIncidentsToProblem;
        Test.setCurrentPage(pageRef);
        //When:
        Test.startTest();
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(incidents);
        stdController.setSelected(incidents);
        ISVC_AssignIncidentsToProblem_Extension controller = new ISVC_AssignIncidentsToProblem_Extension(stdController);
        controller.createNewProblem();
        controller.newProblem.Subject = 'New Problem';
        controller.saveNewProblemAndLink();
        Test.stopTest();
        //Then:
        Case newProblem = [SELECT Id FROM Case WHERE Subject = 'New Problem'];
        for(Case incident : [SELECT Id, ParentId FROM Case WHERE RecordTypeId = :incidentRecordTypeId]){
            System.assertEquals(newProblem.Id, incident.ParentId);
        }
    }

    //Succesfull flow
    static testMethod void testPagination() {
        //Given:
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        List<Case> incidents = [SELECT Id, ParentId FROM Case WHERE RecordTypeId = :incidentRecordTypeId];
        PageReference pageRef = Page.ISVC_AssignIncidentsToProblem;
        Test.setCurrentPage(pageRef);
        //When:
        Test.startTest();
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(incidents);
        stdController.setSelected(incidents);
        ISVC_AssignIncidentsToProblem_Extension controller = new ISVC_AssignIncidentsToProblem_Extension(stdController);
        if(controller.getHasNextPage()){
            controller.nextPage();
        }
        if(controller.getHasPreviousPage()){
            controller.previousPage();
        }
        Test.stopTest();
        //Then:
        System.assertEquals(1, controller.getCurrentPageNumber());
        System.assertEquals(2, controller.getTotalPageNumber());
    }
}