@isTest
public class EMP_AssociatePortalPage_Controller_Test {
    static testMethod void testStart() {        
        test.startTest();  
        
        CollaborationGroup objcollab = new CollaborationGroup();
        objcollab.Name ='Testing Name';
        objcollab.CollaborationType='Public';
        insert objcollab;
        
        Portal_page__c objPortal1 = new Portal_Page__c();
        objPortal1.Main_Content__c='test content';
        objPortal1.Title__c='Testing Title';
        objPortal1.Image_Title__c='Testing Title';
        objPortal1.Join_WebEx_meeting__c='Testing';
        objPortal1.join_by_phone__c='1234567890';
        objPortal1.Webex_url__c='Testing';
        objPortal1.View_Image__c=true;
        objPortal1.Chatter_Group__c=objcollab.id;
        objPortal1.name='Associate Portal';
        insert objPortal1;
        
        Portal_page__c objPortal = new Portal_Page__c();
        objPortal.Main_Content__c='test content';
        objPortal.Title__c='Testing Title';
        objPortal.Image_Title__c='Testing Title';
        objPortal.Join_WebEx_meeting__c='Testing';
        objPortal.join_by_phone__c='1234567890';
        objPortal.Webex_url__c='Testing';
        objPortal.View_Image__c=true;
        objPortal.Chatter_Group__c=objcollab.id;
        objPortal.name='Internal Support Community';
        objPortal.Page_Name__c = 'EMP_AssociatePortalPage';
        objPortal.parent_portal_page__c = objPortal1.id;
        objPortal.customer_portal__c = true;
        insert objPortal;
        
        Page_Component__c objpc = new Page_Component__c();
        objpc.name ='test';
        objpc.Component_Order__c='01';
        objpc.Portal_Page__c = objPortal.id;
        insert objpc;
        
        //parent_portal_page__r.name =: 'Associate Portal' 
        PageReference pageRef = Page.EMP_AssociatePortalPage;
        Test.setCurrentPage(pageRef); 
        
        EMP_AssociatePortalPage_Controller.subMenu objemp1 = new EMP_AssociatePortalPage_Controller.subMenu();
        
        EMP_AssociatePortalPage_Controller objemp = new EMP_AssociatePortalPage_Controller();
        objemp.refpage();
        
        objpc.Component_Order__c='02';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp2 = new EMP_AssociatePortalPage_Controller();
        
        objpc.Component_Order__c='03';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp3 = new EMP_AssociatePortalPage_Controller();
        
        objpc.Component_Order__c='04';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp4 = new EMP_AssociatePortalPage_Controller();
        
        objpc.Component_Order__c='05';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp5 = new EMP_AssociatePortalPage_Controller();
        
        objpc.Component_Order__c='06';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp6 = new EMP_AssociatePortalPage_Controller();
        
        objpc.Component_Order__c='07';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp7 = new EMP_AssociatePortalPage_Controller();
        
        objpc.Component_Order__c='08';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp8 = new EMP_AssociatePortalPage_Controller();
        
        objpc.Component_Order__c='09';
        update objpc;
        EMP_AssociatePortalPage_Controller objemp9 = new EMP_AssociatePortalPage_Controller();
        
        objemp.redirect();
        list<SelectOption> lsSel = objemp.getdropdownNames();
        
        
        test.stopTest();   

    }
}