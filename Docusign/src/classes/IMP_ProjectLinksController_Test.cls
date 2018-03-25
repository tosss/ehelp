/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Test class for IMP_ProjectLinksController
Test Class:
History
10/06/14    Kimiko Roberto      Created
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
private class IMP_ProjectLinksController_Test{
    
    static testMethod void IMP_ProjectLinksController_Test(){
        //enable custom setting for the links so we can use them to create the final URL
        IMP_ProjectLinksUrls__c urls = new IMP_ProjectLinksUrls__c();
        urls.Name = 'Contract';
        urls.URL_Value__c = 'http://dsiishe.hoffman.ds.adp.com/DwWeb/GUI/OnsiteDetail.aspx?contractid=';
        insert urls;
        
        IMP_ProjectLinksUrls__c urls2 = new IMP_ProjectLinksUrls__c();
        urls2.Name = 'Impact Project';
        urls2.URL_Value__c = 'http://dsiis1he/impact/navigationforms/mainpage.aspx?ProjectId=';
        insert urls2;
        
        IMP_ProjectLinksUrls__c urls3 = new IMP_ProjectLinksUrls__c();
        urls3.Name = 'NIS';
        urls3.URL_Value__c = '/apex/IMP_DisplayMission?param1=';
        insert urls3;
        
        IMP_ProjectLinksUrls__c urls4 = new IMP_ProjectLinksUrls__c();
        urls4.Name = 'RMS Request with Impact';
        urls4.URL_Value__c = 'http://dsiishe.hoffman.ds.adp.com/RMS/GUI/Queue.aspx?Projectid=';
        insert urls4;
        
        IMP_ProjectLinksUrls__c urls5 = new IMP_ProjectLinksUrls__c();
        urls5.Name = 'Solution_Design__c';
        urls5.URL_Value__c = 'http://dssawebtst1he.hoffman.ds.adp.com/saportal_test/SLX_NNA_createImplScopeXLS.asp';
        insert urls5;
        
        IMP_ProjectLinksUrls__c urls6 = new IMP_ProjectLinksUrls__c();
        urls6.Name = 'CMF';
        urls6.URL_Value__c = 'http://dsorbit1he.ds.ad.adp.com/ReportserverSQL2005?%2fVision%2fCase+Results+and+History+by+CMF&varCMF=';
        insert urls6;
        
        IMP_ProjectLinksUrls__c urls7 = new IMP_ProjectLinksUrls__c();
        urls7.Name = 'RMS Request without Impact';
        urls7.URL_Value__c = 'http://dsiishe.hoffman.ds.adp.com/RMS/GUI/Requests.aspx?RequestId=';
        insert urls7;

        //create test data for the links so it will be seen at the inline page of the subproject
        Account testChildAccount = IMP_TestFactory_Helper.buildAccount();
        insert testChildAccount;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        testProject.Dealer_Group__c = testChildAccount.Id;
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        testSubProject.Dealer_Group__c = testChildAccount.Id;
        insert testSubProject;
        
        SubProject_External_Related_Entity__c testEntity = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
        testEntity.Entity_Type__c = 'Impact Project';
        insert testEntity;
        
        SubProject_External_Related_Entity__c testEntity2 = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
        testEntity2.Entity_Type__c = 'Contract';
        insert testEntity2;
        
        SubProject_External_Related_Entity__c testEntity3 = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
        testEntity3.Entity_Type__c = 'RMS Request';
        insert testEntity3;
        
        RecordType recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'NIS'];
        
        SubProject_External_Reference__c testReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(null, testSubProject.Id, null);
        testReference.Mission_ID__c = '123';
        testReference.RecordTypeId = recordTypeId.Id;
        insert testReference;
        
        SubProject_External_Reference__c rectype = [SELECT Record_Type_Name__c FROM SubProject_External_Reference__c WHERE Id =: testReference.Id];

        List<Organization> orgList = [SELECT Id FROM Organization LIMIT 1];
        String orgId = '';
        
        for(Organization org : orgList){
            orgId = org.Id;
        }
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testSubProject);
        IMP_ProjectLinks_Controller cont = new IMP_ProjectLinks_Controller(sc);
        
        //check the complete urls values
        system.assertNotEquals(cont,null);
        //system.assert(cont.RMSLinks.get(testEntity.Entity_NUmber__c) == urls4.URL_Value__c + testEntity.Entity_Number__c);
        system.assert(cont.ImpactProjectLinks.get(testEntity.Entity_NUmber__c) == urls2.URL_Value__c + testEntity.Entity_Number__c);
        system.assert(cont.ContractLinks.get(testEntity2.Entity_NUmber__c) == urls.URL_Value__c + testEntity2.Entity_Number__c);
        system.assert(cont.MissionLinks.get(testReference.Mission_ID__c) == urls3.URL_Value__c + testReference.Mission_ID__c + '&organizationId=' + orgId);
            
    }
   
}