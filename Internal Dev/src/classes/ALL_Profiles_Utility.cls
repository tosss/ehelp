public class ALL_Profiles_Utility {
    //Profiles
    private static Profile companyCommunitiesUserProfile;
    private static Profile cdkAdminIntegrationUserProfile;
    private static Profile cdkAdminSystemAdministratorProfile;

    public static Id getCompanyCommunitiesUserProfileId(){
        ISVC_NewUserDefaults__mdt companyCommunitiesUserDefaults = ALL_CustomSettings_Utility.getCompanyCommunitiesUserDefaults();
        if(companyCommunitiesUserProfile == null){
            companyCommunitiesUserProfile = getProfile(companyCommunitiesUserDefaults.Profile_Name__c);
        }
        return companyCommunitiesUserProfile.Id;
    }

    public static Id getCdkAdminIntegrationUserProfileId(){
        if(cdkAdminIntegrationUserProfile == null){
            cdkAdminIntegrationUserProfile = getProfile('CDK - Admin - Integration User');
        }
        return cdkAdminIntegrationUserProfile.Id;
    }

    public static Id getCdkAdminSystemAdministratorProfileId(){
        if(cdkAdminSystemAdministratorProfile == null){
            cdkAdminSystemAdministratorProfile = getProfile('CDK - Admin - System Administrator');
        }
        return cdkAdminSystemAdministratorProfile.Id;
    }

    public static Profile getProfile(String profileName){
        Profile profile;
        if(String.isBlank(profileName)){
            profile = new Profile();
            return profile;
        }
        try {
            profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        } catch(QueryException ex){
            profile = new Profile();
        }
        return profile;
    }
}