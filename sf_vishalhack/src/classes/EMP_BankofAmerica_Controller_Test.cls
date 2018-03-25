/*----------------------------------------------------------------------
* RQ-06791 BankofAmerica
* vijay.manimaran@cdk.com - created this class  
* 
* ---------------------------MODIFICATIONS-----------------------------
* 2016-09-19 Vijay.manimaran@cdk.com  Updated logic 
------------------------------------------------------------------------*/


@istest
public class EMP_BankofAmerica_Controller_Test {
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
        Id CaseRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Procurement');
        Id ContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');

        Account a = new Account(
            Name = 'CDK Global',
            RecordTypeId = AccountRecordTypeId
        ); { insert a; }
                
        User u = [select id from user Limit 1];
      
        Contact contactObj1 = DS_TestObjects.NewContact();
        contactObj1.RecordTypeId = ContactRecordTypeId;
        contactObj1.AccountId = a.Id;
        contactobj1.User__c = U.id;
        insert contactObj1;
        
        Contact contactObj = DS_TestObjects.NewContact();
        contactobj.User__c = UserInfo.getUserId();
        contactobj.HR_Manager__c = contactObj1.Id;
        insert contactobj;
        
        String hiddenCardValue = 'newTravelCard';
        String checkCardRequested ='newTravelCard';
        String Acknowledgementval = 'TravelPolicy';
        String Acknowledgementval1 = 'Pcards';
        String Acknowledgementval2 = 'SMMP';
        String Acknowledgementval3 = 'Termscondition';
        
        string checkcard = EMP_BankofAmerica_Controller.checkCardRequested(checkCardRequested);
        EMP_BankofAmerica_Controller BOA = new EMP_BankofAmerica_Controller();
        BOA.hiddenCardValue = 'newTravelCard';
        String AckPolicy =  EMP_BankofAmerica_Controller.Acknowledgment(Acknowledgementval);
        BOA.policyExistingCheck();
        BOA.submitforApporval();
        List<EMP_Policy__c> policyList = BOA.policyExistingCheck();
        Case c = new Case(
            AccountId = a.Id,
            RecordTypeId = CaseRecordTypeId,
            Subject = 'Test',
            Description = 'Test',
            Status = 'Open',
            Type = 'Customer Buy/Sell',
            Assumption_Approved__c = 'Yes',
            End_Billing_Date__c = Date.Today(),
            Seller__c = a.Id,
            Buyer_Contact_Details__c = 'Test',
            BOA_Selectedcard__c = 'newTravelCard',
            BOA_Manageremail__c = contactObj.HR_Manager__r.user__r.Email,
            BOA_Manager__c = contactObj.HR_Manager__c,
            BOA_State_Province__c = 'Illinois',  
            BOA_Mailing_Address__c = 'test',
            BOA_city__c ='test',
            BOA_zipcode__c ='123456'
        ); 
        
        { 
            insert c; 
        }
        
        
        EMP_BankofAmerica_Controller BOA1 = new EMP_BankofAmerica_Controller();
        BOA1.hiddenCardValue = 'Pcard';
        BOA1.policyExistingCheck();
        BOA1.submitforApporval();
        String AckPolicy1 =  EMP_BankofAmerica_Controller.Acknowledgment(Acknowledgementval1);         
        String AckPolicy3 =  EMP_BankofAmerica_Controller.Acknowledgment(Acknowledgementval3);
        EMP_BankofAmerica_Controller.deletePolicies();
        
        EMP_BankofAmerica_Controller BOA2 = new EMP_BankofAmerica_Controller();
        BOA2.hiddenCardValue ='newTravelCard';
        EMP_BankofAmerica_Controller.NEW_TRAVELCARD = 'Travel & Expense Policy Acknowledge';
        
        EMP_Policy__c policyAck = new EMP_Policy__c();
        policyAck.Name = 'Travel & Expense Policy Acknowledge';
        policyAck.Acknowledgement_Status__c = false;
        policyAck.Date_of_Acknowledgement__c = system.now();
        policyAck.Employee_Contact__c = contactObj.Id;
        policyAck.Policy_Type__c = 'Bank of America';
        policyAck.User_Name__c = userInfo.getuserId();
        insert policyAck;
        
        
        EMP_Policy__c policyAck1 = new EMP_Policy__c();
        policyAck1.Name = 'Terms and Condition Acknowledged';
        policyAck1.Acknowledgement_Status__c = false;
        policyAck1.Date_of_Acknowledgement__c = system.now();
        policyAck1.Employee_Contact__c = contactObj.Id;
        policyAck1.Policy_Type__c = 'Bank of America';
        policyAck1.User_Name__c = userInfo.getuserId();
        insert policyAck1;
        //BOA2.policyExistingCheck();
        BOA2.submitforApporval();
        
        EMP_BankofAmerica_Controller BOA3 = new EMP_BankofAmerica_Controller();
        BOA3.hiddenCardValue ='Pcard';
        EMP_BankofAmerica_Controller.PCARD = 'Pcard Policy Acknowledged';
        testdata('Pcard Policy Acknowledged',false );
        testdata('Pcard SMMP Acknowledged',false );
        testdata('Terms and Condition Acknowledged',false );
        BOA3.submitforApporval();
        
        test.stopTest();
    }
        public static void testdata(string AckName, Boolean Ackstatus)
        {
        Id AccountRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'ADPDS Other Account');
        Id CaseRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Procurement');
        Account a = new Account(
            Name = 'Test Account 001 Test',
            RecordTypeId = AccountRecordTypeId
        ); 
            { insert a; }
        
        Contact contactObj = DS_TestObjects.NewContact_Inserted();
        contactobj.User__c = UserInfo.getUserId();
        update contactobj;
        
        EMP_Policy__c policyAck5 = new EMP_Policy__c();
        policyAck5.Name = AckName;
        policyAck5.Acknowledgement_Status__c = Ackstatus;
        policyAck5.Date_of_Acknowledgement__c = system.now();
        policyAck5.Employee_Contact__c = contactObj.Id;
        policyAck5.Policy_Type__c = 'Bank of America';
        policyAck5.User_Name__c = userInfo.getuserId();
        insert policyAck5;
    }
}