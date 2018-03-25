// 2015-11-01 Vijay.Manimaran@cdk.com Created test class for EMP_AssociatePortalPage_Controller
// 2015-11-04 Guolong.Li@cdk.com Modified to use testSetup
//2015-04-25 Vijay.Manimaran@cdk.com modified test data

@isTest
public class EMP_AssociatePortalPage_Controller_Test {
    
    @testSetup static void prepareTestData()
    {
        CollaborationGroup collabGroup = new CollaborationGroup();
        collabGroup.Name ='Testing Name';
        collabGroup.CollaborationType='Public';
        insert collabGroup;
        
        Portal_page__c portalPage = new Portal_Page__c();
        portalPage.name='US';
        portalPage.Page_Name__c = 'US';
        insert portalPage;
        
        portal_menu__c portalMenu = new Portal_Menu__c();
        portalMenu.Name='US';
        portalMenu.Portal_Page__c = portalPage.id;
        portalMenu.URL__c='testing';
        portalMenu.Label__c='India';
        portalMenu.Style_Class__c='testing';
        portalMenu.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Menu__c', 'Portal Home');
        insert portalMenu;
        
        portal_menu__c portalMenu2 = new Portal_Menu__c();
        portalMenu2.Name='India';
        portalMenu2.Portal_Page__c = portalPage.id;
        portalMenu2.URL__c='testing';
        portalMenu2.Label__c='India';
        portalMenu2.Style_Class__c='testing';
        portalMenu2.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Menu__c', 'Stand Alone');
        insert portalMenu2;
        
        List<Page_Component__c> pageComponents = new List<Page_Component__c>();
        for(Integer ctr=0; ctr < 21; ctr++)
        {
            Page_Component__c pgComponent = new Page_Component__c();
            pgComponent.name ='test';
            String orderCtr = '';
            if(ctr < 10)
            {
                orderCtr = '0'+ string.valueof(ctr);
            }else{ 
                orderCtr = string.valueof(ctr);
            }
            pgComponent.Component_Order_Picklist__c = orderCtr;
            pgComponent.Portal_Page__c = portalPage.id;
            pgComponent.VFPageName__c='EMP_Nopage';
            //pgComponent.Component_Order_Picklist__c='00';
            pageComponents.add(pgComponent);
        }
        insert pageComponents;
    }
    
    static testMethod void testStart() {        
        test.startTest();  
        
        apexpages.currentpage().getparameters().put('home','US');
        apexpages.currentpage().getparameters().put('Page','US');
        
        EMP_AssociatePortalPage_Controller portalPageCtrl  = new EMP_AssociatePortalPage_Controller();
        portalPageCtrl.getAllNodes();
        portalPageCtrl.ScrollingMessage='testing';
        portalPageCtrl.SelectedCommunityHome='Selected Community Name';
        portalPageCtrl.PortalPageName='EMP_AssociatePortalPage';
        
        PageReference pageRef = Page.EMP_AssociatePortalPage;
        Test.setCurrentPage(pageRef); 
        
        EMP_AssociatePortalPage_Controller.HeaderMenuWrapper hdrMenuWrapper = new EMP_AssociatePortalPage_Controller.HeaderMenuWrapper();
        hdrMenuWrapper.MainMenuLabel = 'Testing';
        hdrMenuWrapper.mainMenuRecordType ='Testing recordtype';
        
        EMP_AssociatePortalPage_Controller.SubMenuLabel subMenuLabel = new EMP_AssociatePortalPage_Controller.SubMenuLabel();
        subMenuLabel.subMenuHeader ='Testing submenu';
        subMenuLabel.menuIte1 ='testing menu item';
        test.stopTest();
    }
}