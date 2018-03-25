// GLOBIT-4019: Create subcase from parent Termination case
//
// 2017-10-17 marta.malinowska@cdk.com Created
public class ISVC_CreateSubCases {

    private static Map<Id, RecordType> caseRecordTypesMap;
    private static Map<Id, Account> accountsMap;
    @testVisible
    private static Map<String, Map<String, Set<String>>> subCaseTypesTestMap;
    private static Map<String, Map<String, Set<String>>> subCaseTypesMap;
    private static List<Case> subCasesToInsert;

    public static void createSubCasesForParentCases(List<Case> parentCases){
        caseRecordTypesMap = new Map<Id, RecordType>(ALL_RecordTypes_Utility.getCaseRecordTypes());
        accountsMap = getAccountsMap(parentCases);
        subCaseTypesMap = ISVC_SubCaseSettings.getSubCaseTypesMap();
        if(Test.isRunningTest() && subCaseTypesTestMap != null){
            subCaseTypesMap = subCaseTypesTestMap;
        }
        subCasesToInsert = getSubCasesToInsert(parentCases);
        insertSubCases();
    }

    private static Map<Id, Account> getAccountsMap(List<Case> parentCases){
        Set<Id> accountIds = new Set<Id>();
        for(Case parentCase : parentCases){
            if(String.isNotBlank(parentCase.AccountId)){
                accountIds.add(parentCase.AccountId);
            }
        }
        Map<Id, Account> accounts = new Map<Id, Account>([
                SELECT Id, LastName, FirstName
                FROM Account WHERE Id IN :accountIds]);
        return accounts;
    }

    private static List<Case> getSubCasesToInsert(List<Case> parentCases){
        List<Case> newSubCases = new List<Case>();

        String recordTypeName;
        String combinedKey;
        Map<String, Set<String>> tempMap;
        for(Case parentCase : parentCases){
            recordTypeName = caseRecordTypesMap.containsKey(parentCase.RecordTypeId) ? caseRecordTypesMap.get(parentCase.RecordTypeId).DeveloperName : '';
            combinedKey = ISVC_SubCaseSettings.getSubCaseTypeKey(recordTypeName, parentCase.Category__c, parentCase.Sub_Category__c);
            if(subCaseTypesMap.containsKey(parentCase.Employee_Location__c)){
                tempMap = subCaseTypesMap.get(parentCase.Employee_Location__c);
                if(tempMap.containsKey(combinedKey)){
                    for(String subCaseType : tempMap.get(combinedKey)){
                        newSubCases.add(createSubCase(parentCase, subCaseType));
                    }
                }
            }
        }
        return newSubCases;
    }

    private static void insertSubCases(){
        try {
            AssignmentRule assignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true];
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.assignmentRuleHeader.assignmentRuleId = assignmentRule.Id;
            for(Case subCase : subCasesToInsert){
                subCase.setOptions(dmlOptions);
            }
        } catch(QueryException ex){}

        insert subCasesToInsert;
    }

    private static Case createSubCase(Case parentCase, String subCaseType){
        Case newSubCase = new Case();
        newSubCase.ParentId = parentCase.Id;
        newSubCase.RecordTypeId = parentCase.RecordTypeId;
        newSubCase.Category__c = parentCase.Category__c;
        newSubCase.Sub_Category__c = parentCase.Sub_Category__c;
        newSubCase.Subject = createSubject(parentCase, subCaseType);
        newSubCase.Description = parentCase.Description;
        newSubCase.AccountId = parentCase.AccountId;
        newSubCase.ContactId = parentCase.ContactId;
        newSubCase.Origin = parentCase.Origin;
        newSubCase.Impact__c = parentCase.Impact__c;
        newSubCase.Severity__c = parentCase.Severity__c;
        newSubCase.Sub_Case_Type__c = subCaseType;
        newSubCase.Effective_Date__c = parentCase.Effective_Date__c;
        newSubCase.Last_Work_Date__c = parentCase.Last_Work_Date__c;
        newSubCase.Last_Time_Worked__c = parentCase.Last_Time_Worked__c;
        newSubCase.Last_Time_Worked_Timezone__c = parentCase.Last_Time_Worked_Timezone__c;
        copyFormFieldValuesToChildCases(parentCase, newSubCase);
        return newSubCase;
    }
    
    // GLOBIT-6367 The subject on all new hire child cases will contain the new hire first and last name
    private static String createSubject(Case parentCase, String subCaseType) {
    		if (parentCase.RecordTypeId == ALL_RecordTypes_Utility.getNewHireRequestRecordTypeId()) {
    			return subCaseType + ' - ' + parentCase.Forms_Last_Name__c + ', ' + parentCase.Forms_First_Name__c + ', ' + parentCase.Start_Date__c;
    		} else {
    			Account account = accountsMap.containsKey(parentCase.AccountId) ? accountsMap.get(parentCase.AccountId) : new Account();
    			return subCaseType + ' - ' + account.LastName + ', ' + account.FirstName;
    		}
    }
    
    // GLOBIT-6367 Clone form field values from parent case down to sub case
    // GLOBIT-6312 Clone terminated employee information from parent case to sub case
    private static void copyFormFieldValuesToChildCases(Case parentCase, Case childCase) {
    		childCase.Forms_Additional_Hardware_Required__c = parentCase.Forms_Additional_Hardware_Required__c;
		childCase.Forms_Cell_Phone__c = parentCase.Forms_Cell_Phone__c;
		childCase.Forms_Change_Type__c = parentCase.Forms_Change_Type__c;
		childCase.Forms_CIM_Agent__c = parentCase.Forms_CIM_Agent__c;
		childCase.Forms_Cube__c = parentCase.Forms_Cube__c;
		childCase.Forms_Department__c = parentCase.Forms_Department__c;
		childCase.Forms_Email_Distribution_Lists__c = parentCase.Forms_Email_Distribution_Lists__c;
		childCase.Forms_Employee_AD_Id__c = parentCase.Forms_Employee_AD_Id__c;
		childCase.Forms_First_Name__c = parentCase.Forms_First_Name__c;
		childCase.Forms_Headset__c = parentCase.Forms_Headset__c;
		childCase.Forms_Hire_Type__c = parentCase.Forms_Hire_Type__c;
		childCase.Forms_Justification_for_Replacement__c = parentCase.Forms_Justification_for_Replacement__c;
		childCase.Forms_Last_Name__c = parentCase.Forms_Last_Name__c;
		childCase.Forms_LinkedIn_Sales_Navigator__c = parentCase.Forms_LinkedIn_Sales_Navigator__c;
		childCase.Forms_Network_Drive_Access__c = parentCase.Forms_Network_Drive_Access__c;
		childCase.Forms_New_Or_Replacement__c = parentCase.Forms_New_Or_Replacement__c;
		childCase.Forms_On_Behalf_Of_AD_Id__c = parentCase.Forms_On_Behalf_Of_AD_Id__c;
		childCase.Forms_PC_Type__c = parentCase.Forms_PC_Type__c;
		childCase.Forms_Preferred_Name__c = parentCase.Forms_Preferred_Name__c;
		childCase.Forms_Salesforce_Access__c = parentCase.Forms_Salesforce_Access__c;
		childCase.Forms_Shipping_Address__c = parentCase.Forms_Shipping_Address__c;
		childCase.Forms_Software_Requirements__c = parentCase.Forms_Software_Requirements__c;
		childCase.Forms_Title__c = parentCase.Forms_Title__c;
		childCase.Forms_Transfer_Employee_AD_Id__c = parentCase.Forms_Transfer_Employee_AD_Id__c;
		childCase.Forms_Transfer_On_Behalf_Of_AD_Id__c = parentCase.Forms_Transfer_On_Behalf_Of_AD_Id__c;
		childCase.Forms_Work_Location__c = parentCase.Forms_Work_Location__c;
		childCase.Terminated_Employee__c = parentCase.Terminated_Employee__c;
		childCase.Accent_CDK_Sales_Assist__c = parentCase.Accent_CDK_Sales_Assist__c;
		childCase.Start_Date__c = parentCase.Start_Date__c;
		childCase.Deactivation__c = parentCase.Deactivation__c;
    }
}