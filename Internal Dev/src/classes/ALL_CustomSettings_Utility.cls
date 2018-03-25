public class ALL_CustomSettings_Utility {

    private static ISVC_NewUserDefaults__mdt companyCommunitiesUserDefaults;
    private static ISVC_EntitlementSetting__mdt internalSupportEntitlementSetting;
    private static List<ISVC_SubCaseSetting__mdt> allSubCaseSettings;

    public static ISVC_NewUserDefaults__mdt getCompanyCommunitiesUserDefaults(){
        if(companyCommunitiesUserDefaults == null){
            companyCommunitiesUserDefaults = getNewUserDefaults('Company_Communities_User');
        }
        return companyCommunitiesUserDefaults;
    }

    public static ISVC_NewUserDefaults__mdt getNewUserDefaults(String name){
        ISVC_NewUserDefaults__mdt newUserDefaults;
        if(String.isBlank(name)){
            newUserDefaults = new ISVC_NewUserDefaults__mdt();
            return newUserDefaults;
        }
        try {
            newUserDefaults = [
                    SELECT Username_Suffix__c, Profile_Name__c, Email_Encoding__c, Language__c, Locale__c, Time_Zone__c
                    FROM ISVC_NewUserDefaults__mdt WHERE DeveloperName = :name];
        } catch(QueryException ex){
            newUserDefaults = new ISVC_NewUserDefaults__mdt();
        }
        return newUserDefaults;
    }

    public static ISVC_EntitlementSetting__mdt getInternalSupportEntitlementSetting(){
        if(internalSupportEntitlementSetting == null){
            internalSupportEntitlementSetting = getEntitlementSetting('Internal_Support');
        }
        return internalSupportEntitlementSetting;
    }

    public static ISVC_EntitlementSetting__mdt getEntitlementSetting(String name){
        ISVC_EntitlementSetting__mdt entitlementSetting;
        if(String.isBlank(name)){
            entitlementSetting = new ISVC_EntitlementSetting__mdt();
            return new ISVC_EntitlementSetting__mdt();
        }
        try {
            entitlementSetting = [
                    SELECT Entitlement_Process_Name__c, Entitlement_Name__c
                    FROM ISVC_EntitlementSetting__mdt WHERE DeveloperName = :name];
        } catch(QueryException ex){
            entitlementSetting = new ISVC_EntitlementSetting__mdt();
        }
        return entitlementSetting;
    }

    public static List<ISVC_SubCaseSetting__mdt> getAllSubCaseSettings(){
        if(allSubCaseSettings == null){
            allSubCaseSettings = [
                    SELECT Employee_Location__c, Case_Record_Type__c, Case_Category__c, Case_Sub_Category__c, Sub_Case_Type__c, Task_Subject__c
                    FROM ISVC_SubCaseSetting__mdt];
        }
        return allSubCaseSettings;
    }
}