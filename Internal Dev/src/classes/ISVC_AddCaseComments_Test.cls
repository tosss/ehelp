@isTest
private class ISVC_AddCaseComments_Test {
    @testSetup
    static void dataSetup() {
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();

        ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
        problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case').save();
        Case problemCase = problemCaseBuilder.getRecord();

        List<Case> relatedCases = new List<Case>();
        ISVC_Case_Builder requestCaseBuilder = new ISVC_Case_Builder();
        requestCaseBuilder.recordTypeId(requestRecordTypeId).parentId(problemCase.Id).subject('Request Test Case').build();
        relatedCases.add(requestCaseBuilder.getRecord());
        ISVC_Case_Builder incidentCaseBuilder = new ISVC_Case_Builder();
        incidentCaseBuilder.recordTypeId(incidentRecordTypeId).parentId(problemCase.Id).subject('Incident Test Case').build();
        relatedCases.add(incidentCaseBuilder.getRecord());
        insert relatedCases;
    }

    //Succesfull flow
    static testMethod void testAddCaseCommentsOnlyToParentCase() {
        //Given: problem case
        Case problemCase = [SELECT Id FROM Case WHERE RecordTypeId = :ALL_RecordTypes_Utility.getProblemRecordTypeId()];
        PageReference pageRef = Page.ISVC_AddCaseComments;
        Test.setCurrentPage(pageRef);
        //When: add comments
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(problemCase);
        ISVC_AddCaseComments_Extension controller = new ISVC_AddCaseComments_Extension(stdController);
        controller.caseComment.CommentBody = 'Test Comment';
        controller.copyCommentsToRelatedCases = false;
        controller.addCaseComments();
        Test.stopTest();
        //Then: comments are added to case
        List<CaseComment> caseComments = [SELECT ParentId, CommentBody FROM CaseComment];
        System.assertEquals(1, caseComments.size());
        for(CaseComment caseComment : caseComments){
            System.assertEquals(problemCase.Id, caseComment.ParentId);
            System.assertEquals('Test Comment', caseComment.CommentBody);
        }
    }

    //Succesfull flow
    static testMethod void testAddCaseCommentsToAllRelatedCases() {
        //Given: problem case
        Case problemCase = [SELECT Id FROM Case WHERE RecordTypeId = :ALL_RecordTypes_Utility.getProblemRecordTypeId()];
        PageReference pageRef = Page.ISVC_AddCaseComments;
        Test.setCurrentPage(pageRef);
        //When: add comments and check to copy comments to all related cases
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(problemCase);
        ISVC_AddCaseComments_Extension controller = new ISVC_AddCaseComments_Extension(stdController);
        controller.caseComment.CommentBody = 'Test Comment';
        controller.copyCommentsToRelatedCases = true;
        controller.addCaseComments();
        Test.stopTest();
        //Then: comments are added to all cases
        List<CaseComment> caseComments = [SELECT CommentBody FROM CaseComment];
        System.assertEquals(3, caseComments.size());
        for(CaseComment caseComment : caseComments){
            System.assertEquals('Test Comment', caseComment.CommentBody);
        }
    }
}