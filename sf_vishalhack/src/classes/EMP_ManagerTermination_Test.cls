/*******************************************************************************
** RQ-08648 05/08/2017 Created Vijay.Manimaran@cdk.com

********************************************************************************* */

@isTest
public class EMP_ManagerTermination_Test {
    @Testsetup
    public static void setupData()
    {               
        
        Id AccountRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'ADPDS Other Account');
        Id ContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id workFlowRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('WorkFlow__c', 'COM - Employees Termination');
        
        User ur = DS_TestObjects.NewUser();
        insert ur;
        Account a = new Account(
            Name = 'CDK Global',
            RecordTypeId = AccountRecordTypeId
        ); 
        {
            insert a;
        }
        User u = [select id from user Limit 1];
        
        Contact contactObj1 = DS_TestObjects.NewContact();
        contactObj1.RecordTypeId = ContactRecordTypeId;
        contactObj1.AccountId = a.Id;
        contactobj1.User__c = U.id;
        insert contactObj1;
        
        Contact contactObj = DS_TestObjects.NewContact();
        contactObj.RecordTypeId = ContactRecordTypeId;
        contactobj.User__c = UserInfo.getUserId();
        contactobj.AccountId = a.Id;
        contactobj.HR_Manager__c = contactObj1.Id;
        insert contactobj;
        String checkAccessValue_1 = EMP_ManagerTermination_Controller.checkAccess();
        
        Contact contactObj3 = DS_TestObjects.NewContact();
        contactObj3.RecordTypeId = ContactRecordTypeId;
        contactObj3.AccountId = a.Id;
        contactobj3.User__c = U.id;
        contactobj3.HR_Manager__c = contactobj.Id;
        contactObj3.FirstName = 'testing';
        contactObj3.LastName = 'test_LastName';
        insert contactobj3;
        testBankofAmericaController(); 
    }
    
    static testMethod void testBankofAmericaController() 
    {
        test.startTest();
        EMP_ManagerTermination_Controller MRGT = new EMP_ManagerTermination_Controller();
        String checkAccessValue_2 = EMP_ManagerTermination_Controller.checkAccess();
        Contact contactSelected = [Select id, FirstName from Contact where FirstName ='testing'];
        EMP_ManagerTermination_Controller.managerReport('');
        EMP_ManagerTermination_Controller.managerReport(Null);
        Portal_Form__c portalForms = new Portal_Form__c();
        portalForms.Contact__c = contactSelected.id;
        EMP_ManagerTermination_Controller.managerReport(portalForms.Contact__c);
        EMP_ManagerTermination_Controller.createPortalForms(portalForms);
        EMP_ManagerTermination_Controller.fetchPendingTermination();
        EMP_ManagerTermination_Controller.fetchAssociateTerminated(portalForms.Contact__c);
        Portal_Form__c pforms =[select id from Portal_Form__c];
        EMP_ManagerTermination_Controller.insertAssociate(portalForms, pforms.id, 'false');
        EMP_ManagerTermination_Controller.insertAssociate(portalForms, pforms.id, 'true');

        test.stopTest();
    }
}