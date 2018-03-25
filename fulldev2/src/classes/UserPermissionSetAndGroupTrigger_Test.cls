@IsTest
public class UserPermissionSetAndGroupTrigger_Test
{
    public static testmethod void validateHandler()
    {
        EMP_Community_PermissionSet_Id__c newPermissionSet;
        
        EMP_Community_PublicGroup_Id__c newGroup;
        
        System.runAs (new User(Id = UserInfo.getUserId()))
        {
            newPermissionSet = new EMP_Community_PermissionSet_Id__c(
                PermissionSet_Id__c = '0PS40000001P3ww',
                Name = 'sample');
            insert newPermissionSet;
            
            newGroup = new EMP_Community_PublicGroup_Id__c(
                Public_Group_Id__c = '00G40000000bwu6',
                Name = 'sample');
            insert newGroup;
            
            
            User newUser = new User();
            Profile P = DS_TestObjects.getAdminProfile();
            Id profileId = P != null ? P.id : null;
            
            String temp_String = 'permissionandgroupTestSample';
            newUser.Firstname = 'permissionTest';
            newUser.Lastname = 'groupTest';
            newUser.Title = 'TestUser';
            newUser.Street = '1950 Hassel Rd.';
            newUser.City = 'Hoffman Estates';
            newUser.State = 'IL';
            newUser.Username = temp_string+'@cdk.com';
            newUser.email = temp_string+'@cdk.com';
            newUser.alias = 'tuser';
            newUser.profileid = profileid;
            newUser.FederationIdentifier = 'SampleId';
            newUser.MobilePhone = '2342342343';
            newUser.Fax = '3453453454';
            newUser.Extension = '3344';
            newUser.Country = 'USA';
            newUser.TimeZoneSidKey = 'America/Chicago';
            newUser.LocaleSidKey = 'en_US';
            newUser.EmailEncodingKey = 'ISO-8859-1';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.ADID__c = 'testu';
            newUser.Non_Interactive_User__c =false;
            insert newUser;
            
            User updatedUser = [
                SELECT id, contractor__c
                FROM User 
                WHERE id=:newUser.id
            ];
            updatedUser.contractor__c = true;
            update updatedUser;
            
            updatedUser = [
                SELECT id, Non_Interactive_User__c
                FROM User 
                WHERE id=:newUser.id
            ];
            updatedUser.Non_Interactive_User__c = true;
            update updatedUser;
        }        
    }
}