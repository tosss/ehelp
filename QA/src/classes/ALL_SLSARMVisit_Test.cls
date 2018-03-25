//2016-02-09- lalitha.adduru@cdk.com- created the test class for All_SLSARMVisit_Handler

@isTest
public class ALL_SLSARMVisit_Test {
    
    @testSetUp public static void setUp()
    {
        Account testAccount = new Account(Name='testAccount');       
        insert testAccount;
        testAccount.Region__c = 'West';
        update testAccount;
        
        AVP_RGM_Link__c rgmLink = new AVP_RGM_Link__c(ARM_Supervisor__c = UserInfo.getUserId(),Region__c='West');
        insert rgmLink;
        
        Contact testContact = new Contact(Salutation='Ms.',FirstName='TestFirstName',LastName='TestLastName',AccountId=testAccount.Id);
        insert testContact;        
        
        SLS_ARM_Visit__c ARMVisit = new SLS_ARM_Visit__c(Account__c = testAccount.id,Main_Contact_Name__c = testContact.id,Visit_Range_From__c = Datetime.newInstance(2016, 2, 9), Visit_Range_To__c = Datetime.newInstance(2016, 2, 9).addDays(2) );
		insert ARMVisit;        
    }
    
    public static testmethod void  testARMVisitTrigger()
    {
        List<SLS_ARM_Visit__c> triggerNew  = new List<SLS_ARM_Visit__c>();
        triggerNew = [select id, Account__c , ARM_Supervisor__c from SLS_ARM_Visit__c];        
        All_SLSARMVisit_Handler.setSupervisor(triggerNew);
    }

}