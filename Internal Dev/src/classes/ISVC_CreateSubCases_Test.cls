@isTest
private class ISVC_CreateSubCases_Test {

    @testSetup
    static void dataSetup() {
        Integer batchSize = 3;

        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.country('United States').save();
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccountBuilder.getRecord().Id];

        List<Case> terminationCases = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder terminationCaseBuilder = new ISVC_Case_Builder();
            terminationCaseBuilder.recordTypeId(terminationRecordTypeId).accountId(personAccount.Id).contactId(personAccount.PersonContactId)
                    .subject('Termination Test Case 00'+i).category('Personnel').subCategory('Termination/Leaver').build();
            terminationCases.add(terminationCaseBuilder.getRecord());
        }
        ISVC_Case_Handler.triggerDisabled = true;
        insert terminationCases;
    }

    //Succesfull flow
    static testMethod void testCreateSubCases() {
        //Given: list of termination cases
        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        Map<Id, Case> parentCases = new Map<Id, Case>([
                SELECT Id, RecordTypeId, RecordType.DeveloperName, Category__c, Sub_Category__c, Employee_Location__c,
                        Subject, Description, AccountId, ContactId, Origin, Impact__c, Severity__c,
                        Effective_Date__c, Last_Work_Date__c, Last_Time_Worked__c, Last_Time_Worked_Timezone__c,
                        Forms_Additional_Hardware_Required__c , Forms_Cell_Phone__c , Forms_Change_Type__c , 
                        Forms_CIM_Agent__c , Forms_Cube__c , Forms_Department__c , Forms_Email_Distribution_Lists__c , 
                        Forms_Employee_AD_Id__c , Forms_First_Name__c , Forms_Headset__c , Forms_Hire_Type__c , 
                        Forms_Justification_for_Replacement__c , Forms_Last_Name__c , Forms_LinkedIn_Sales_Navigator__c , 
                        Forms_Network_Drive_Access__c , Forms_New_Or_Replacement__c , Forms_On_Behalf_Of_AD_Id__c , 
                        Forms_PC_Type__c , Forms_Preferred_Name__c , Forms_Salesforce_Access__c , Forms_Shipping_Address__c , 
                        Forms_Software_Requirements__c , Forms_Title__c , Forms_Transfer_Employee_AD_Id__c , 
                        Forms_Transfer_On_Behalf_Of_AD_Id__c , Forms_Work_Location__c , 
                        Terminated_Employee__c , Accent_CDK_Sales_Assist__c , Start_Date__c,
                        Deactivation__c
                FROM Case
                WHERE RecordTypeId = :terminationRecordTypeId]);

        String empLocation = parentCases.values()[0].Employee_Location__c;
        String combinedKey = ISVC_SubCaseSettings.getSubCaseTypeKey(ALL_RecordTypes_Utility.RT_TERMINATION, 'Personnel', 'Termination/Leaver');
        Set<String> subCaseTypes = new Set<String>{'AD Termination', 'CDK APP Termination', 'CPQ Termination', 'CDK Credit Card - Termination'};

        //When: create subcases for parent cases
        Test.startTest();
        ISVC_CreateSubCases.subCaseTypesTestMap = new Map<String, Map<String, Set<String>>>();
        ISVC_CreateSubCases.subCaseTypesTestMap.put(empLocation, new Map<String, Set<String>>{combinedKey => subCaseTypes});
        ISVC_CreateSubCases.createSubCasesForParentCases(parentCases.values());
        Test.stopTest();

        //Then: sub cases are created
        for(Case parentCase : [SELECT Id, (SELECT Id, Sub_Case_Type__c FROM Cases) FROM Case WHERE Id IN :parentCases.keySet()]){
            System.assertEquals(4, parentCase.Cases.size());
            for(Case subCase : parentCase.Cases){
                System.assert(String.isNotBlank(subCase.Sub_Case_Type__c));
            }
        }
    }
}