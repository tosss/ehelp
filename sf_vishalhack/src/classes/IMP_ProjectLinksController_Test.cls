/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Test class for IMP_ProjectLinksController
Test Class:
History
10/06/14    Kimiko Roberto      Created
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
10/06/15    Venkata Shrivol		modified as per the re-factored code.
12/5/16      Venkata Shrivol	commented project object reference RQ-08305
------------------------------------------------------------*/
@isTest
private class IMP_ProjectLinksController_Test{
    
    static testMethod void IMP_ProjectLinksController_Test()
    {
    	list<IMP_ProjectLinksUrls__c> customSettingsList = new list<IMP_ProjectLinksUrls__c>();
        //enable custom setting for the links so we can use them to create the final URL
        IMP_ProjectLinksUrls__c urls = new IMP_ProjectLinksUrls__c();
        urls.Name = 'Contract';
        urls.URL_Value__c = 'http://dsiishe.hoffman.ds.adp.com/DwWeb/GUI/OnsiteDetail.aspx?contractid=';
        customSettingsList.add(urls);
        
        IMP_ProjectLinksUrls__c urls2 = new IMP_ProjectLinksUrls__c();
        urls2.Name = 'Impact Project';
        urls2.URL_Value__c = 'http://dsiis1he/impact/navigationforms/mainpage.aspx?ProjectId=';
        customSettingsList.add(urls2);
        
        IMP_ProjectLinksUrls__c urls3 = new IMP_ProjectLinksUrls__c();
        urls3.Name = 'NIS';
        urls3.URL_Value__c = '/apex/IMP_DisplayMission?param1=';
        customSettingsList.add(urls3);
        
        IMP_ProjectLinksUrls__c urls4 = new IMP_ProjectLinksUrls__c();
        urls4.Name = 'RMS Request with Impact';
        urls4.URL_Value__c = 'http://dsiishe.hoffman.ds.adp.com/RMS/GUI/Queue.aspx?Projectid=';
        customSettingsList.add(urls4);
        
        IMP_ProjectLinksUrls__c urls5 = new IMP_ProjectLinksUrls__c();
        urls5.Name = 'Solution_Design__c';
        urls5.URL_Value__c = 'http://dssawebtst1he.hoffman.ds.adp.com/saportal_test/SLX_NNA_createImplScopeXLS.asp';
        customSettingsList.add(urls5);
        
        IMP_ProjectLinksUrls__c urls6 = new IMP_ProjectLinksUrls__c();
        urls6.Name = 'CMF';
        urls6.URL_Value__c = 'http://dsorbit1he.ds.ad.adp.com/ReportserverSQL2005?%2fVision%2fCase+Results+and+History+by+CMF&varCMF=';
        customSettingsList.add(urls6);
        
        IMP_ProjectLinksUrls__c urls7 = new IMP_ProjectLinksUrls__c();
        urls7.Name = 'RMS Request without Impact';
        urls7.URL_Value__c = 'http://dsiishe.hoffman.ds.adp.com/RMS/GUI/Requests.aspx?RequestId=';
        customSettingsList.add(urls7);

		insert customSettingsList;
		
        //create test data for the links so it will be seen at the inline page of the subproject
        Account testChildAccount = IMP_TestFactory_Helper.buildAccount();
        insert testChildAccount;
        
        Opportunity testOpp = DS_TestObjects.NewOpportunity();
        testOpp.AccountId = testChildAccount.Id;
        insert testOpp;
        
        /*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        //testProject.Dealer_Group__c = testChildAccount.Id;
        insert testProject;*/
        
        list<SubProject__c> subProjectList = new list<SubProject__c>();
        for(Integer i=0;i<2;i++)
        {
        	SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
        	subProjectList.add(testSubProject);
        }
        
        //testSubProject.Dealer_Group__c = testChildAccount.Id;
        insert subProjectList;
        
        list<SubProject_External_Related_Entity__c>  spereList = new list<SubProject_External_Related_Entity__c>();
        SubProject_External_Related_Entity__c testEntity = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(subProjectList.get(0).Id);
        testEntity.Entity_Type__c = 'Impact Project';
        spereList.add(testEntity);
        
        SubProject_External_Related_Entity__c testEntity2 = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(subProjectList.get(0).Id);
        testEntity2.Entity_Type__c = 'Contract';
        spereList.add(testEntity2);
        
        SubProject_External_Related_Entity__c testEntity3 = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(subProjectList.get(0).Id);
        testEntity3.Entity_Type__c = 'RMS Request';
        spereList.add(testEntity3);
        
        SubProject_External_Related_Entity__c testEntity4 = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(subProjectList.get(1).Id);
        testEntity4.Entity_Type__c = 'CMF';
        spereList.add(testEntity4);
        
        SubProject_External_Related_Entity__c testEntity5 = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(subProjectList.get(1).Id);
        testEntity5.Entity_Type__c = 'Impact Project';
        spereList.add(testEntity5);
        
        insert spereList;
        
        Id recordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('SubProject_External_Reference__c','NIS');
        
        SubProject_External_Reference__c testReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(null, subProjectList.get(0).Id);
        testReference.Mission_ID__c = '123';
        testReference.RecordTypeId = recordTypeId;
        insert testReference;
        
        SubProjectOpp__c testSubOpp = IMP_TestFactory_Helper.buildSubProjectOpportunity(subProjectList.get(1).Id);
        testSubOpp.Opportunity__c = testOpp.Id;
        insert testSubOpp;
        
        Solution_Design__c testSolDesign = new Solution_Design__c();
        testSolDesign.Name='12345678';
        testSolDesign.Opportunity__c = testOpp.Id;
        insert testSolDesign;

        string orgId = UserInfo.getOrganizationId();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(subProjectList.get(0));
        IMP_ProjectLinks_Controller cont = new IMP_ProjectLinks_Controller(sc);
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(subProjectList.get(1));
        IMP_ProjectLinks_Controller cont1 = new IMP_ProjectLinks_Controller(sc1);
        
        
        //check the complete urls values
        system.assertNotEquals(cont,null);
        system.assert(cont.finalMap.get('Contract').get(0).get(testEntity2.Entity_NUmber__c) == urls.URL_Value__c + testEntity2.Entity_Number__c);
        system.assert(cont.finalMap.get('NIS').get(0).get(testReference.Mission_ID__c) == urls3.URL_Value__c + testReference.Mission_ID__c + '&organizationId=' + orgId);
		            
    }
   
}