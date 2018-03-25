@Istest
public class ALL_LightningUtility_Test {
    @testSetup
    public static void testsetup()
    {
        Account accObj = DS_TestObjects.NewAccount_Inserted();
        Contact contObj = DS_TestObjects.NewContact_Inserted();
        Contact_Relationship__c crObj = DS_TestObjects.newContactRelationship();
        crObj.Account__c = accObj.Id;
        crObj.Contact__c = contObj.Id;
        insert crObj;
    }
    public static testmethod void test()
    {
        ALL_LightningUtility.getSearchList('Account', 'Name', 'Test');
        ALL_LightningUtility.getContactRelationshipSearchList('Contact_Relationship__c','Name','Test');
    }
}