@isTest
public class EMP_Corpcard_Test {

    @Testsetup
    public static void setupData()
    {               
        User u = DS_TestObjects.NewUser();
        insert u;
        
    }
    
    static testMethod void testBankofAmericaController() 
    {
        test.startTest();
        Id AccountRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'ADPDS Other Account');
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        Id ContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        User u = DS_TestObjects.NewSecondUser_Inserted();
        Contact contactObj = DS_TestObjects.NewContact();
        contactobj.User__c = UserInfo.getUserId();
        contactObj.RecordTypeId = ContactRecordTypeId;
        contactobj.Vendor_ID__c='123456';
        contactobj.FirstName = 'test_first';
        contactobj.LastName = 'test_last';
        contactobj.Email='test_email@test.com';
        insert contactobj;
        
        Contact contactObj1 = DS_TestObjects.NewContact_Inserted();
 
        
        list<Portal_Form__c> pforms = EMP_Corpcard_Controller.pendingRequest();
    	String s = EMP_Corpcard_Controller.checkCardRequested('TravelExpenseCard');
        list<Portal_Form__c> portalList = EMP_Corpcard_Controller.employeePortalResults('searchEmployee','test_first');
        list<Portal_Form__c> portalList_1 = EMP_Corpcard_Controller.employeePortalResults('pcardAccess',contactObj1.User__c);
        contact c = [select id,user__c,email from contact where email = 'test_email@test.com'];
        // list<Portal_Form__c> portalList_1 = EMP_Corpcard_Controller.portalFormsList();
		Boolean cardAccess = EMP_Corpcard_Controller.cardAccess();
        String TEPolicy = EMP_Corpcard_Controller.Acknowledgment('TEPolicy');
        String TCPolicy = EMP_Corpcard_Controller.Acknowledgment('TCPolicy');
        String PCPolicy = EMP_Corpcard_Controller.Acknowledgment('PCPolicy');
        String MEPolicy = EMP_Corpcard_Controller.Acknowledgment('MEPolicy');
        String FPolicy = EMP_Corpcard_Controller.Acknowledgment('');
		list<EMP_Policy__c> policyList = EMP_Corpcard_Controller.policyExistingCheck();
        String pcardEnabledAccess = EMP_Corpcard_Controller.pcardEnabledAccess('pcardAccess');
        String pcardEnabledAccesssearchEmployee = EMP_Corpcard_Controller.pcardEnabledAccess('searchEmployee');
        
        Portal_Form__c PF = new Portal_Form__c();
        PF.BOA_NameOnCard__c = Userinfo.getFirstName() +' '+Userinfo.getLastName();
        PF.BOA_Beginning_Date__c = system.today();
        PF.BOA_SelectedCard__c = 'Increase' +' '+ system.now();
        PF.BOA_NameOnCard__c = Userinfo.getFirstName() +' '+Userinfo.getLastName();
        PF.BOA_Card_Type__c = 'PCard';
        PF.PRC_Status__c = 'Open';    
        PF.BOA_sendEmail__c = true;
        PF.RecordTypeId = portalFormsRecordTypeID;
        String submitforApporval = EMP_Corpcard_Controller.submitforApporval(PF, 'Travel & Expense Card');
        String submitforApporvalPCard = EMP_Corpcard_Controller.submitforApporval(PF, 'PCard');
        String submitforApporvalLimitIncrease = EMP_Corpcard_Controller.submitforApporval(PF, 'Increase Limit on Travel or PCard');
        String submitforApporvalpcardAccess = EMP_Corpcard_Controller.submitforApporval(PF, 'pcardAccess');
        WorkFlow__c wf = new WorkFlow__c();
        insert wf;

        Portal_Form__c PF_1 = new Portal_Form__c();
        PF_1.BOA_NameOnCard__c = Userinfo.getFirstName() +' '+Userinfo.getLastName();
        PF_1.BOA_Card_Type__c = 'PCard';
        PF_1.BOA_sendEmail__c = true;
        PF_1.RecordTypeId = portalFormsRecordTypeID;
		PF_1.WorkFlow__c = wf.id;
        insert PF_1;

        string name = Userinfo.getFirstName() +' '+Userinfo.getLastName();
        Portal_Form__c pform = EMP_Corpcard_Controller.fetchPortalForm(wf.id);
        Portal_Form__c ps =[select id, name,contact__r.HR_Manager__c from Portal_Form__c where BOA_NameonCard__c =: name];
        system.debug('pf'+pf_1.Name);
        String udpatefetch = EMP_Corpcard_Controller.updatePortalForm(Ps.Name, 'pcardAccess');
        String sendEmail = EMP_Corpcard_Controller.updatePortalForm(Ps.Name, 'sendEmail');
		String Approval = EMP_Corpcard_Controller.ApprovalReject(ps, 'Approve', '');
        EMP_Corpcard_Controller.deletePolicies();
		        
        test.stopTest();
    }
    public static void testdata(string AckName, Boolean Ackstatus)
    {
        Id AccountRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'ADPDS Other Account');
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
    }
}