// GLOBIT-5302 Sub Case Creation

// 2017-10-30 Marta.Malinowska@cdk.com
public class ISVC_SubCaseSettings {

    private static Map<String, Set<String>> tempMap;

    public static Map<String, Map<String, Set<String>>> getSubCaseTypesMap(){
        Map<String, Map<String, Set<String>>> subCaseTypesMap = new Map<String, Map<String, Set<String>>>();
        String mainKey;
        String secondKey;

        for(ISVC_SubCaseSetting__mdt subCaseSetting : ALL_CustomSettings_Utility.getAllSubCaseSettings()){
            mainKey = subCaseSetting.Employee_Location__c;
            secondKey = getSubCaseTypeKey(subCaseSetting.Case_Record_Type__c, subCaseSetting.Case_Category__c, subCaseSetting.Case_Sub_Category__c);
            if(String.isNotBlank(subCaseSetting.Sub_Case_Type__c)){
                addSubCaseSetting(subCaseTypesMap, mainKey, secondKey, subCaseSetting.Sub_Case_Type__c);
            }
        }
        return subCaseTypesMap;
    }

    public static Map<String, Map<String, Set<String>>> getTaskSubjectsMap(){
        Map<String, Map<String, Set<String>>> taskSubjectsMap = new Map<String, Map<String, Set<String>>>();
        String mainKey;
        String secondKey;

        for(ISVC_SubCaseSetting__mdt subCaseSetting : ALL_CustomSettings_Utility.getAllSubCaseSettings()){
            mainKey = subCaseSetting.Employee_Location__c;
            secondKey = getTaskSubjectKey(subCaseSetting.Case_Record_Type__c, subCaseSetting.Case_Category__c, subCaseSetting.Case_Sub_Category__c, subCaseSetting.Sub_Case_Type__c);
            if(String.isNotBlank(subCaseSetting.Task_Subject__c)){
                addSubCaseSetting(taskSubjectsMap, mainKey, secondKey, subCaseSetting.Task_Subject__c);
            }
        }
        return taskSubjectsMap;
    }

    private static void addSubCaseSetting(Map<String, Map<String, Set<String>>> subCaseSettingsMap, String mainKey, String secondKey, String value){
        if(!subCaseSettingsMap.containsKey(mainKey)){
            subCaseSettingsMap.put(mainKey, new Map<String, Set<String>>());
        }
        tempMap = subCaseSettingsMap.get(mainKey);
        if(!tempMap.containsKey(secondKey)){
            tempMap.put(secondKey, new Set<String>());
        }
        tempMap.get(secondKey).add(value);
    }

    public static String getSubCaseTypeKey(String type, String category, String subcategory){
        String combainedKey = type + '-' + category + '-' + subcategory;
        return combainedKey;
    }

    public static String getTaskSubjectKey(String type, String category, String subcategory, String subCaseType){
        String combainedKey = type + '-' + category + '-' + subcategory + '-' + subCaseType;
        return combainedKey;
    }
}