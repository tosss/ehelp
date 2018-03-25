/*
*2016-05-31  -venkata.shrivol@cdk.com -Created
*2016-12-06  -venkata.shrivol@cdk.com - commented project object reference RQ-08305
*2017-02-03 - ragashalini.koka@cdko.com - Added parameters to match the methods for RQ-08334
*/
@isTest
public class ALL_NewContactDialog_Test 
{
	//generating the string values that are required to create a contact
    public static String firstName = 'CdkNewContact';
    public static String lastName = 'GlobalTesting';
    public static String role = 'Accountant';
    public static String projectRole = 'Agent';
    public static String email = 'cdkglobaltesting@testing.com';
    public static String phone = '1234-567-0981';
	
	@testSetup
	static void prepareTestData()
	{
		Account acc = DS_TestObjects.NewAccount();
		acc.Name = 'Test Accounting One';
		insert acc;
		
		/*Project__c testPrj = IMP_TestFactory_Helper.buildProject(0);
		insert testPrj;*/
		
		SubProject__c testSubPrj = IMP_TestFactory_Helper.buildSubProject();
		testSubPrj.SubProject_Name__c = 'Test SubProject';
		insert testSubPrj;
		
		CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(acc.Id);
		insert testCMFInfo;
		
		SubProjectSite__c testSite = IMP_TestFactory_Helper.buildSubProjectSite(acc.Id, testSubPrj.Id, testCMFInfo.Id);
		insert testSite;
	}    
	
	static testMethod void testRemoteAction()
	{
		list<SubProject__c> subProjectList = [select Id from SubProject__c where SubProject_Name__c = 'Test SubProject' limit 1];
        SubProject__c thisSubProject = subProjectList.size() > 0 ? subProjectList.get(0) : new SubProject__c();
        
		Account accName = [select Id from Account where name = 'Test Accounting One'];
		Test.startTest();
        ApexPages.currentPage().getParameters().put('id',thisSubProject.Id);
		
		ALL_NewContactDialog_Controller newDialogControllerInstance = new ALL_NewContactDialog_Controller();
		newDialogControllerInstance.getRelationshipRoles();
		newDialogControllerInstance.getProjectRoles();
		newDialogControllerInstance.getAccountMap();
         ALL_NewContactDialog_Controller.createNewContact(firstName, lastName, accName.Id, role, projectRole, email, phone, null, false, null, 'testing');
        
        Test.stopTest();
        
        system.assertEquals(1, [select Id from Contact where FirstName='CdkNewContact'].size());
	}
    
    static testMethod void testWebservice()
	{
		list<SubProject__c> subProjectList = [select Id from SubProject__c where SubProject_Name__c = 'Test SubProject' limit 1];
        SubProject__c thisSubProject = subProjectList.size() > 0 ? subProjectList.get(0) : new SubProject__c();
        
		list<Account> accList = [select Id from Account where name = 'Test Accounting One'];
        Account accName = accList.size() > 0 ? accList.get(0) : new Account();
		Test.startTest();
            ApexPages.currentPage().getParameters().put('id',thisSubProject.Id);
            
            ALL_NewContactDialog_Controller newDialogControllerInstance = new ALL_NewContactDialog_Controller();
            newDialogControllerInstance.getRelationshipRoles();
            newDialogControllerInstance.getProjectRoles();
            newDialogControllerInstance.getAccountMap();
            ALL_NewContactDialog_Controller.AddContactAndClientContact(firstName, lastName, accName.Id, role, projectRole, email, phone, null, true, thisSubProject.Id);
            
            list<Contact> conList = [select Id from Contact where firstName = 'CdkNewContact'];
            system.assertEquals(1, conList.size(), 'Contact did not get inserted');
        
        	list<SubProject_Client_Contact__c> clientConList = [select Id from SubProject_Client_Contact__c where SubProject__c = :thisSubProject.Id];
            system.assertEquals(1, clientConList.size());
            
            string duplicateResponse = ALL_NewContactDialog_Controller.AddContactAndClientContact(firstName, lastName, accName.Id, role, projectRole, email, phone, null, true, thisSubProject.Id);
            system.debug('---duplicateResponse----'+duplicateResponse);
            
            ALL_NewContactDialog_Controller.Response returnResponse = 
                (ALL_NewContactDialog_Controller.Response) JSON.deserialize(duplicateResponse, ALL_NewContactDialog_Controller.Response.Class);
            system.assertEquals(false, returnResponse.Success);
        	
        	Account acc = new Account(Name='Second Account');
        	insert acc;
        	
        	//3rd Webservice call to check
        	ALL_NewContactDialog_Controller.AddContactAndClientContact(firstName, lastName, acc.Id, role, projectRole, email, phone, null, true, thisSubProject.Id);
        	
        	list<SubProject_Client_Contact__c> clientConList2 = [select Id from SubProject_Client_Contact__c where SubProject__c = :thisSubProject.Id];
            system.assertEquals(2, clientConList2.size());
        	
        	list<Contact_Relationship__c> crtList = [select Id from Contact_Relationship__c where Account__c IN (:acc.Id, :accName.Id)];
        	system.assertEquals(2, crtList.size());
        
        Test.stopTest();
	}
    
    static testMethod void testOnCampaignMgrContactInsertion()
    {
    	list<Account> accList = [select Id from Account where name = 'Test Accounting One'];
        Account accName = accList.size() > 0 ? accList.get(0) : new Account();
        
        Campaign_Account_Members__c cam = new Campaign_Account_Members__c(Account__c = accName.Id, Campaign_Member_Status__c='Called');
        insert cam;
        
        Test.startTest();
        		ALL_NewContactDialog_Controller.createNewContact(firstName, lastName, cam.Id, role, projectRole, email, phone, null, false, null, 'campaign');
        Test.stopTest();
        
    }
}