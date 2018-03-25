/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for IMP_MilestoneMassUpdate_Controller
History
03/21/15	Rey Austral			Created
------------------------------------------------------------*/
@isTest
public class IMP_MilestoneMassUpdateController_Test 
{
    private static final Project__c project { get; set; }
    private static final SubProject__c subProject { get; set; }
    private static final Account account { get; set; }
    private static final User user_cdkAssignee { get; set; }
    private static final Contact contact_clientAssignee { get; set; }
    
    static 
    {
        project = IMP_TestFactory_Helper.buildProject(0);
        insert project;
        
        subProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
        insert subProject;
        
        account = IMP_TestFactory_Helper.buildAccount();
        insert account;
        
        user_cdkAssignee = IMP_TestFactory_Helper.buildUser();
        insert user_cdkAssignee;
        
        contact_clientAssignee = IMP_TestFactory_Helper.buildContact(account.Id);
        insert contact_clientAssignee;
    }
    
    static testMethod void externalIds_Test() 
    {
        Test.StartTest();
        
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        Laser_Artwork_Order__c laserArtworkOrder = IMP_TestFactory_Helper.buildLaserArtworkOrder(contact_clientAssignee.Id);
        laserArtworkOrder.A_P_Check_Order_Placed__c          = Date.today() - 5;
        laserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today() - 3;
        insert laserArtworkOrder;
        
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c subprojectExternalReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(laserArtworkOrder.Id, subProject.Id, project.Id);
        subprojectExternalReference.RecordTypeId = recordTypeInfo.get('LAO').getRecordTypeId();
        insert subprojectExternalReference;
        
        // --------------------------------------------------------------------
        // TESTING PROPER
        
      
        ApexPages.CurrentPage().getParameters().put('id', subproject.Id); 
        
        IMP_ExternalReferenceRecordTypes__c externalReferenceRecType = IMP_TestFactory_Helper.buildExternalReferenceRecordTypeItem(IMP_TestFactory_Helper.Enum_ExternalReferenceRecordTypes.LAO);
        insert externalReferenceRecType;
        IMP_MilestoneMassUpdate_Controller controller = new IMP_MilestoneMassUpdate_Controller();
       
        System.assertEquals(1, controller.externalIdMap.size());
        
        Test.StopTest();
    }
    
    static testMethod void siteValueOption_Test() 
    {
        Test.startTest();
         
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        createCustomSettings();
        
        String NAME_LITERAL_MP  = 'Manny Pacquiao';
        
        Account accountWithName = IMP_TestFactory_Helper.buildAccount();
        accountWithName.Name = NAME_LITERAL_MP;
        insert accountWithName;
        
        SubProject__c subProjectWithDealerGroup = IMP_TestFactory_Helper.buildSubProject(project.Id);
        subProjectWithDealerGroup.Dealer_Group__c = accountWithName.Id;
        insert subProjectWithDealerGroup;
        
        CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(accountWithName.Id);
        insert testCMFInfo;
        
        SubProjectSite__c subProjectSite1 = IMP_TestFactory_Helper.buildSubProjectSite(accountWithName.Id, subProjectWithDealerGroup.Id, testCMFInfo.Id);
        // subProjectSite1.CMF__c = cmfInfo1.Id;
        insert subProjectSite1;
        
        // --------------------------------------------------------------------
        // TESTING PROPER
    
        ApexPages.CurrentPage().getParameters().put('id', subProjectWithDealerGroup.Id);       
        IMP_MilestoneMassUpdate_Controller controller = new IMP_MilestoneMassUpdate_Controller();
        
        System.assertEquals(2, controller.siteOptionsList.size());
        System.assertEquals(subProjectSite1.Id, controller.siteOptionsList.get(1).getValue());
        
        Test.stopTest();
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
}