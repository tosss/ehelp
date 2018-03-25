public class ALL_Organization_Utility {
    private static Organization organization;

    public static String getSandboxSuffix(){
        if(organization == null){
            organization = getOrganization(UserInfo.getOrganizationId());
        }
        if(organization.IsSandbox){
            return UserInfo.getUserName().substringAfterLast('.');
        } else {
            return '';
        }
    }

    public static Organization getOrganization(Id organizationId){
        Organization organization;
        try{
            organization = [SELECT IsSandbox, InstanceName, DefaultLocaleSidKey, LanguageLocaleKey FROM Organization WHERE Id = :organizationId];
        } catch(QueryException ex){
            organization = new Organization();
        }
        return organization;
    }
}