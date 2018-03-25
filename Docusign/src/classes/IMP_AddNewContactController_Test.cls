/*----------------------------------
09/09/15  Venkata Shrivol - Created
Test Class for IMP_AddNewContact_Controller
 -----------------------------------*/
@isTest
private class IMP_AddNewContactController_Test 
{
	@testSetup static void insertTestData()
	{
		list<Account> accountList = new list<Account>();
		for(integer i=0;i<2;i++)
		{
			Account testAccount = new Account();
			testAccount.Name = 'Test Account'+ i;
			accountList.add(testAccount);
		}
		insert accountList;
		
		Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        list<CMF_Info__c> cmfList = new list<CMF_Info__c>();
        integer k=0;
        for(Account acc:accountList)
        {
        	
        	CMF_Info__c cmfInfo = new CMF_Info__c();
	        cmfInfo.Account__c = acc.Id; 
	        cmfInfo.Main_CMF__c = '321'+k;
	        cmfInfo.Ship_CMF__c = '321'+k;
	        cmfInfo.Status__c = 'A';
        	cmfList.add(cmfInfo);
        	k++;
        }
        insert cmfList;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        list<SubProjectSite__c> siteList = new list<SubProjectSite__c>();
        for(integer i=0;i<2;i++)
        {
        	SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(accountList.get(i).Id, testSubProject.Id, cmfList.get(i).Id);
        	siteList.add(testSubProjectSite);
        }
        insert siteList;		
	}

    static testMethod void myUnitTest() 
    {
    	SubProject__c testSubPrj = [
    	select Id, Count_of_SubProject_Sites__c, 
        (select Account__c, Account__r.Name from SubProjectSites__r)
        from SubProject__c where  SubProject_Name__c='Test SubProject Name' limit 1
    	];
    	
    	PageReference thisPage = Page.ALL_RecordsView;
    	Test.setCurrentPage(thisPage);
    	
        ApexPages.CurrentPage().getParameters().put('Id', testSubPrj.Id);
    	IMP_AddNewContact_Controller controllerObj = new IMP_AddNewContact_Controller();
        controllerObj.accountId = testSubPrj.SubProjectSites__r.get(0).Account__c;
    	controllerObj.getContactRoles();
    	controllerObj.getProjectRoles();
    	controllerObj.getSiteAccounts();
    	
    	string successString = IMP_AddNewContact_Controller.AddContactAndClientContact('TestFirst', 'TestLast',controllerObj.accountId, 'Accountant','System Administrator','','',testSubPrj.Id);
    	system.assertEquals(true, successString.contains('true'));
    	string failureString = IMP_AddNewContact_Controller.AddContactAndClientContact('', '',controllerObj.accountId, 'Accountant','System Administrator','','',testSubPrj.Id);
    	system.assertEquals(true, failureString.contains('exception'));
    }
}