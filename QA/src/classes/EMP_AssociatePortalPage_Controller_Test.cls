@isTest
public class EMP_AssociatePortalPage_Controller_Test {
   
    static testMethod void testStart() {        
        test.startTest();  
        
        CollaborationGroup objcollab = new CollaborationGroup();
        objcollab.Name ='Testing Name';
        objcollab.CollaborationType='Public';
        insert objcollab;

        Portal_page__c objPortal = new Portal_Page__c();
        objPortal.name='India';
        objPortal.Page_Name__c = 'Associate Portal India';
        insert objPortal;
        
        portal_menu__c objMenu = new Portal_Menu__c();
        objMenu.Name='India';
        objMenu.Portal_Page__c = objPortal.id;
        objMenu.URL__c='testing';
        objMenu.Label__c='India';
        objMenu.Style_Class__c='testing';
        objMenu.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Menu__c', 'Portal Home');
        insert objMenu;
        
        
        Page_Component__c objpc = new Page_Component__c();
        objpc.name ='test';
        objpc.Component_Order__c='01';
        objpc.Portal_Page__c = objPortal.id;
        insert objpc;
        
        Page_Component__c objpc00 = new Page_Component__c();
        objpc00.name ='test';
        objpc00.Component_Order__c='00';
        objpc00.Portal_Page__c = objPortal.id;
        insert objpc00;
        
        Page_Component__c objpc2 = new Page_Component__c();
        objpc2.name ='test';
        objpc2.Component_Order__c='02';
        objpc2.Portal_Page__c = objPortal.id;
        insert objpc2;
        
        Page_Component__c objpc3 = new Page_Component__c();
        objpc3.name ='test';
        objpc3.Component_Order__c='03';
        objpc3.Portal_Page__c = objPortal.id;
        insert objpc3;
        
        Page_Component__c objpc4 = new Page_Component__c();
        objpc4.name ='test';
        objpc4.Component_Order__c='04';
        objpc4.Portal_Page__c = objPortal.id;
        insert objpc4;
        
        Page_Component__c objpc5 = new Page_Component__c();
        objpc5.name ='test';
        objpc5.Component_Order__c='05';
        objpc5.Portal_Page__c = objPortal.id;
        insert objpc5;
        
        Page_Component__c objpc6 = new Page_Component__c();
        objpc6.name ='test';
        objpc6.Component_Order__c='06';
        objpc6.Portal_Page__c = objPortal.id;
        insert objpc6;
        
        Page_Component__c objpc7 = new Page_Component__c();
        objpc7.name ='test';
        objpc7.Component_Order__c='07';
        objpc7.Portal_Page__c = objPortal.id;
        insert objpc7;
        
        Page_Component__c objpc8 = new Page_Component__c();
        objpc8.name ='test';
        objpc8.Component_Order__c='08';
        objpc8.Portal_Page__c = objPortal.id;
        insert objpc8;
        
        Page_Component__c objpc9 = new Page_Component__c();
        objpc9.name ='test';
        objpc9.Component_Order__c='09';
        objpc9.Portal_Page__c = objPortal.id;
        insert objpc9;
        
        Page_Component__c objpc10 = new Page_Component__c();
        objpc10.name ='test';
        objpc10.Component_Order__c='10';
        objpc10.Portal_Page__c = objPortal.id;
        insert objpc10;
        
        
        Page_Component__c objpc11 = new Page_Component__c();
        objpc11.name ='test';
        objpc11.Component_Order__c='11';
        objpc11.Portal_Page__c = objPortal.id;
        insert objpc11;
        
        
        Page_Component__c objpc12 = new Page_Component__c();
        objpc12.name ='test';
        objpc12.Component_Order__c='12';
        objpc12.Portal_Page__c = objPortal.id;
        insert objpc12;
        
        
        Page_Component__c objpc13 = new Page_Component__c();
        objpc13.name ='test';
        objpc13.Component_Order__c='13';
        objpc13.Portal_Page__c = objPortal.id;
        insert objpc13;
        
        
        Page_Component__c objpc14 = new Page_Component__c();
        objpc14.name ='test';
        objpc14.Component_Order__c='14';
        objpc14.Portal_Page__c = objPortal.id;
        insert objpc14;
        
        
        Page_Component__c objpc15 = new Page_Component__c();
        objpc15.name ='test';
        objpc15.Component_Order__c='15';
        objpc15.Portal_Page__c = objPortal.id;
        insert objpc15;
        
        
        Page_Component__c objpc16 = new Page_Component__c();
        objpc16.name ='test';
        objpc16.Component_Order__c='16';
        objpc16.Portal_Page__c = objPortal.id;
        insert objpc16;
        
        Page_Component__c objpc17 = new Page_Component__c();
        objpc17.name ='test';
        objpc17.Component_Order__c='17';
        objpc17.Portal_Page__c = objPortal.id;
        insert objpc17;
        
        
        Page_Component__c objpc18 = new Page_Component__c();
        objpc18.name ='test';
        objpc18.Component_Order__c='18';
        objpc18.Portal_Page__c = objPortal.id;
        insert objpc18;
        
        
        Page_Component__c objpc19 = new Page_Component__c();
        objpc19.name ='test';
        objpc19.Component_Order__c='19';
        objpc19.Portal_Page__c = objPortal.id;
        insert objpc19;
        
        Page_Component__c objpc20 = new Page_Component__c();
        objpc20.name ='test';
        objpc20.Component_Order__c='20';
        objpc20.Portal_Page__c = objPortal.id;
        insert objpc20;
        
        apexpages.currentpage().getparameters().put('home','India');
        apexpages.currentpage().getparameters().put('Page','India');
        
        EMP_AssociatePortalPage_Controller objc  = new EMP_AssociatePortalPage_Controller();
        objc.getAllNodes();
        objc.ScrollingMessage='testing';
        objc.SelectedCommunityHome='Selected Community Name';
        objc.PortalPageName='EMP_AssociatePortalPage';
        
        
        PageReference pageRef = Page.EMP_AssociatePortalPage;
        Test.setCurrentPage(pageRef); 
        
        EMP_AssociatePortalPage_Controller.HeaderMenuWrapper objemp1 = new EMP_AssociatePortalPage_Controller.HeaderMenuWrapper();
        objemp1.MainMenuLabel = 'Testing';
        objemp1.mainMenuRecordType ='Testing recordtype';
        
        EMP_AssociatePortalPage_Controller.SubMenuLabel objempp = new EMP_AssociatePortalPage_Controller.SubMenuLabel();
        objempp.subMenuHeader ='Testing submenu';
        objempp.menuIte1 ='testing menu item';
      
        
        test.stopTest();   
        
    }
    
}