@isTest
public class ALL_SandboxRefresh_Test {
    
    //Toggle enable/disable debug logs
    private static final boolean GENERATE_DEBUG_LOGS = true;
    //TestMethod control variables
    private static final boolean RUN_ALL = true;
    private static final boolean RUN_UPDATE_EMAIL_BATCH = true;
    private static final boolean RUN_UPDATE_FIELDS_BATCH = true;
    private static final boolean RUN_DELETE_HR_CASES = true;
    
    @TestSetup
    public static void loadData()
    {
        setHeaderLogs('Inserting test data');
        List<Contact> contactList = new List<Contact>();
        for(Integer i=1;i<21;i++)
        {
            Contact contactObj = DS_TestObjects.NewContact();
            contactObj.Email = 'test'+i+'@cdk.com';
            contactObj.FirstName = 'Test';
            contactList.add(contactObj);
        }
        insert contactList;
        
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=1;i<21;i++)
        {
            Campaign campaignObj = new Campaign();
            campaignObj.Name = 'Test'+i;
            campaignObj.Description = 'Test Description'+i;
            campaignList.add(campaignObj);
        }
        insert campaignList;
       
        Sandbox_Refresh_Update_Email_ID__c csEmailObj = new Sandbox_Refresh_Update_Email_ID__c();
        csEmailObj.Field_Name__c = 'Email';
        csEmailObj.Object_Name__c = 'Contact';
        csEmailObj.Name = 'Record 1';
        insert csEmailObj;
        
        /*Sandbox_Refresh_Update_Email_ID__c csEmailObj2 = new Sandbox_Refresh_Update_Email_ID__c();
        csEmailObj2.Field_Name__c = 'FirstName';
        csEmailObj2.Object_Name__c = 'Contact';
        csEmailObj2.Name = 'Record 2';
        insert csEmailObj2;*/
        
        Sandbox_Refresh_Update_Fields__c csUpdateFieldObj1 = new Sandbox_Refresh_Update_Fields__c();
        csUpdateFieldObj1.Field_Name__c = 'Name';
        csUpdateFieldObj1.Object_Name__c = 'Campaign';
        csUpdateFieldObj1.Value__c = 'NewTest';
        csUpdateFieldObj1.Name='Record 1';
        insert csUpdateFieldObj1;
        
        /*Sandbox_Refresh_Update_Fields__c csUpdateFieldObj2 = new Sandbox_Refresh_Update_Fields__c();
        csUpdateFieldObj2.Field_Name__c = 'Description';
        csUpdateFieldObj2.Object_Name__c = 'Campaign';
        csUpdateFieldObj2.Value__c = '';
        csUpdateFieldObj2.Name='Record 2';
        insert csUpdateFieldObj2;*/
        
        Account accountObj = DS_TestObjects.NewAccount();
        accountObj.Name = 'CDK Global Account Test';
        insert accountObj;
        
        CustomSettings__c csObj = new CustomSettings__c();
        csObj.CDK_Global_Account_Id__c = accountObj.Id; 
        insert csObj;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = CaseRecordTypeInfo.get('HR').getRecordTypeId();
        Case caseObj = new Case();
        caseObj.AccountId = accountObj.Id;
        caseObj.RecordTypeId = rtId;
        insert caseObj;
    }
    
    public static testMethod void  testUpdateEmailIdBatch()
    {
        if(RUN_UPDATE_EMAIL_BATCH || RUN_ALL)
        {
            setHeaderLogs('Testing Update Email ID Batch');
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            System.runAs(currentUser)
            {
                Test.startTest();
                Contact contactObj  = [select FirstName,Email from Contact Limit 1];
                ALL_SandboxRefresh_Controller.runUpdateEmailIdBatch = true;
                ALL_SandboxRefresh_Controller.execute();
                Test.stopTest();
				
                List<AsyncApexJob> apexJobList = [
                    select id 
                    from AsyncApexJob 
                    where ApexClass.Name='ALL_Update_Email_ID_Batch' 
                    and Status='Completed' 
                    and JobType='BatchApex'
                ];
                
                System.assertEquals(1, apexJobList.size());
                
                Contact newContactObj  = [
                    select FirstName,Email 
                    from Contact 
                    where id=:contactObj.Id
                ];
                /*System.assertNotEquals(newContactObj.FirstName, contactObj.FirstName);*/
                
                String sandboxAppend  = ALL_UtilitiesMiscellaneous.GetCurrentInstanceName();
                
                String expectedEmail = contactObj.Email +'.'+sandboxAppend;
                System.assertEquals(expectedEmail, newContactObj.Email);
                
                /*String expectedFirstName = contactObj.FirstName+'.'+sandboxAppend;
                System.assertEquals(expectedFirstName, newContactObj.FirstName);*/
            }
        }
    }
    
    public static testMethod void testUpdateFieldsBatch()
    {
        if(RUN_UPDATE_FIELDS_BATCH || RUN_ALL)
        {
            setHeaderLogs('Testing Update Fields Batch');
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            System.runAs(currentUser)
            {
                Test.startTest();
                Campaign campaignObj  = [
                    select Name,Description 
                    from Campaign Limit 1
                ];
                
                ALL_SandboxRefresh_Controller.runUpdateFieldsBatch = true;
                ALL_SandboxRefresh_Controller.execute();
                Test.stopTest();
                
                List<AsyncApexJob> apexJobList = [
                    select id 
                    from AsyncApexJob 
                    where ApexClass.Name='ALL_Update_Fields_Batch' 
                    and Status='Completed' 
                    and JobType='BatchApex'
                ];
                
                System.assertEquals(1, apexJobList.size());
                
                Campaign newCampaignObj  = [select  Name,Description from Campaign where id=:campaignObj.Id];
                System.assertNotEquals(newCampaignObj.Name, campaignObj.Name);
                
                String expectedFieldValue = 'NewTest';
                System.assertEquals(expectedFieldValue, newCampaignObj.Name);
                
                //String expectedDescription = null;
                //System.assertEquals(expectedDescription, newCampaignObj.Description);
            }
        }
    }
    
    public static testMethod void testDeleteHRCases()
    {
        if(RUN_DELETE_HR_CASES || RUN_ALL)
        {
            setHeaderLogs('Testing Delete HR cases method');
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
            Map<String,Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            Id rtId = CaseRecordTypeInfo.get('HR').getRecordTypeId();
            
            Account accObj = [select id from Account order by createdDate desc limit 1];
            System.runAs(currentUser)
            {
                List<Case> casesList = [
                    select id 
                    from Case 
                    where recordTypeId=:rtId 
                    and AccountId=:accObj.Id 
                    limit 10000
                ];

                Test.startTest();
                
                ALL_SandboxRefresh_Controller.runDeleteHRCases = true;
                ALL_SandboxRefresh_Controller.execute();
                Test.stopTest();
                List<Case> newCasesList = [
                    select id 
                    from Case 
                    where recordTypeId=:rtId 
                    and AccountId=:accObj.Id 
                    limit 10000
                ];
                System.assertNotEquals(casesList.size(), newCasesList.size());
            }
        }
    }
    
    public static testMethod void testRunAllTasks()
    {
        if(RUN_ALL)
        {
            setHeaderLogs('Testing RunAllTasks method');
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            System.runAs(currentUser)
            {
                List<AsyncApexJob> apexJobList = [
                    select id 
                    from AsyncApexJob 
                    where Status='Completed' 
                    and JobType='BatchApex'
                ];
                test.startTest();
                ALL_SandboxRefresh_Controller.runAllTasks  = true;
                ALL_SandboxRefresh_Controller.execute();
                test.stopTest();
                List<AsyncApexJob> newApexJobList = [
                    select id 
                    from AsyncApexJob
                    where Status='Completed'
                    and JobType='BatchApex'
                ];
                System.assertNotEquals(apexJobList.size(), newApexJobList.size());
            }
        }
    }
    
    private static void setHeaderLogs(String txt)
    {
        if(GENERATE_DEBUG_LOGS)
        {
            //Genereate debug logs
            System.debug('**********************************');
            System.debug('***** '+txt);
            System.debug('**********************************');  
        }
        
    }
}