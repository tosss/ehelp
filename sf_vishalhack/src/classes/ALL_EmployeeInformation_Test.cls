//2017-03-22 lalitha.adduru@cdk.com created this test class - RQ-08780
@isTest
public class ALL_EmployeeInformation_Test 
{
    @TestSetup
    public static void setupData()
    {
        GlobalSettings__c globalSettings = GlobalSettings__c.getOrgDefaults();
        globalSettings.Admin_Integration_Username__c = 'testadminuser@abc.com';
        upsert globalSettings GlobalSettings__c.Id;
        
        User adminUser= new User(
                    UserName='testadminuser@abc.com', 
                    Email='testadminuser@abc.com', 
                    Alias='teadmin',
                    EmailEncodingKey='UTF-8', 
                    FirstName='Test',
                    LastName='Admin', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=DS_TestObjects.getStandardProfile().Id, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='AdminTest',
                    FederationIDentifier = 'F1testAdmin'
                );
        insert adminUser; 
        
        User newUser = DS_TestObjects.NewUser();
        insert newUser;
        Employee_Information__c empInfo =  new Employee_Information__c(Name='Test Employee One',User__c = [Select id from User][0].Id);
        insert empInfo;
       
    }  
    
    public static testmethod void testEmpInfoHandler()
    {
        List<User> userList = [SELECT Id , isActive, Termination_Date__c from User where UserName != 'testadminuser@abc.com'];
        userList[0].isActive = false;
        userList[0].Termination_Date__c = Date.today();
        update userList[0];
    }

}