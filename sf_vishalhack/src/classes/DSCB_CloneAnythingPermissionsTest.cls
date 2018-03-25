@IsTest
public class DSCB_CloneAnythingPermissionsTest 
{
    public static testmethod void SetPermissionsTest()
    {
        // insert new custom clone records settings
        DSCB_CloneAnything_Test.GetCloneRecordsSettings();
        
        list<Profile> Profiles = new list<Profile>{DS_TestObjects.getAdminProfile()};
        
        DSCB_CloneAnythingPermissions PermissionsController = new DSCB_CloneAnythingPermissions();
        
        PermissionsController.SavePermissions();
    }
}