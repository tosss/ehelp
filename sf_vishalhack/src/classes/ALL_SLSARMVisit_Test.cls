//2016-02-09- lalitha.adduru@cdk.com- created the test class for All_SLSARMVisit_Handler
//2017-01-31 - ragashalini.koka@cdk.com - Added code for RQ-08537
@isTest
public class ALL_SLSARMVisit_Test {
    
    @testSetUp public static void setUp()
    {
        Account testAccount = new Account(Name='testAccount');       
        insert testAccount;
        testAccount.Region__c = 'West';
        update testAccount;
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name ='ADPDS - Admin - System Administrator' LIMIT 1];
        User mgrUser = DS_TestObjects.NewUser();
        mgrUser.ProfileId = userProfile.Id;
        insert mgrUser;
        
        User currentUser = DS_TestObjects.NewUser();
        currentUser.ManagerId = mgrUser.Id;
        currentUser.Title = 'ARM';
        currentUser.ProfileId = userProfile.Id;
        insert currentUser;
        
        System.runAs(currentUser) {
            AVP_RGM_Link__c rgmLink = new AVP_RGM_Link__c(ARM_Supervisor__c = UserInfo.getUserId(),Region__c='West');
            insert rgmLink;
            
            Contact testContact = new Contact(Salutation='Ms.',FirstName='TestFirstName',LastName='TestLastName',AccountId=testAccount.Id);
            insert testContact;        
            
            SLS_ARM_Visit__c ARMVisit = new SLS_ARM_Visit__c(Account__c = testAccount.Id,Main_Contact_Name__c = testContact.id);
            ARMVisit.Visit_Start_Date__c = System.today();
            ARMVisit.Length_of_visit__c = '1';
            ARMVisit.Reason_for_the_Visit__c = 'Test Reason';
            insert ARMVisit;        
        }
    }
    
    public static testmethod void  testARMVisitTrigger()
    {
        List<SLS_ARM_Visit__c> triggerNew  = new List<SLS_ARM_Visit__c>();
        triggerNew = [select id, Account__c , ARM_Supervisor__c from SLS_ARM_Visit__c];        
        All_SLSARMVisit_Handler.setSupervisor(triggerNew);
    }
    
    static testmethod void validateApproval() {
        List<SLS_ARM_Visit__c> ARMList = [SELECT Id FROM SLS_ARM_Visit__c];
        if(ARMList.size() > 0) {
            List<ProcessInstance> processInstanceList = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :ARMList[0].Id];
            System.debug('processInstanceList :' + processInstanceList);
            System.assert(processInstanceList.size() > 0);
        }
    }
   

}