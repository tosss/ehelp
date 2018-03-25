/*----------------------------------------------------------------------
* RQ-07014
* 2016-05-30 -vishal.bandari@cdk.com - created  
* Description: Test Class for ALL_Contact_Relationship_Handler, ALL_ContactRelationship_Helper
* ---------------------------MODIFICATIONS-----------------------------
* 2016-05-31 - lalitha.adduru@cdk.com - wrote testmethod to test ALL_ContactRelationship_Helper class
* 2016-06-13 - venkata.shrivol@cdk.com - added two more testMethods
* 2016-06-16 - venkata.shrivol@cdk.com - changed the reference of NewContactRelationship method from 
*                                         DS_TestObjects to IMP_TestFactoryHelper
* 2016-06-16 - vijay.manimaran@cdk.com - Added the testdata for triggers line 65 to 108
* 2016-06-28 - vijay.manimaran@cdk.com code formatted and added Header comments, renamed the testclass.
* 2017-02-24 ragashalini.koka@cdk.com - Moved the Opportunity code from testSetup to testmethod from test setup to avoid SOQL limits for RQ-08532
* 2017-02-28 - ragashalini.koka@cdk.com - Added testmethod validateUpdateCRStatusofDuplicateAccount for RQ-08685
* 2017-02-28 - ragashalini.koka@cdk.com - Added testmethod validateAfterDelete for RQ-08685
------------------------------------------------------------------------*/

@IsTest
public class ALL_ContactRelationship_Test 
{
    @TestSetup
    public static void setupData()
    {
        List<Account> accountList = new List<Account>();
        Account accountObj1 = DS_TestObjects.NewAccount();
        accountObj1.Name = 'Test 1';
        accountList.add(accountObj1);
        Account accountObj2 = DS_TestObjects.NewAccount();
        accountObj2.Name = 'Test 2';
        accountList.add(accountObj2);
        Account accountObj3 = DS_TestObjects.NewAccount();
        accountObj3.Name = 'Test 3';
        accountList.add(accountObj3);
        insert accountList;
        
        Contact contactObj = DS_TestObjects.NewContact_Inserted();
        
        List<Contact_Relationship__c> contactRelationshipList = new List<Contact_Relationship__c>();
        Contact_Relationship__c contactRelationshipObj1 = IMP_TestFactory_Helper.buildContactRelationship(accountObj1.Id,contactObj.Id);
        contactRelationshipObj1.Role__c = 'Accountant';
        contactRelationshipList.add(contactRelationshipObj1);
        Contact_Relationship__c contactRelationshipObj2 = IMP_TestFactory_Helper.buildContactRelationship(accountObj2.Id,contactObj.Id);
        contactRelationshipObj2.Role__c = 'Account Director';
        contactRelationshipList.add(contactRelationshipObj2);
        Contact_Relationship__c contactRelationshipObj3 = IMP_TestFactory_Helper.buildContactRelationship(accountObj3.Id,contactObj.Id);
        contactRelationshipList.add(contactRelationshipObj3);
        insert contactRelationshipList;
        
        //2017-03-31 - siva.pragada@cdk.com - service connect test addition
        Case newCase = DS_TestObjects.newCase();
        newCase.Contact_Name_Relationship__c = contactRelationshipObj1.ID;
        insert newCase;
        
        //2016-05-31 - lalitha.adduru@cdk.com - to test ALL_ContactRelationship_Helper class on Account Plan object
        Account_Plan__c testAccountPlan = DS_TestObjects.NewAccountPlan_Inserted();
        
        //2016-06-10 - lalitha.adduru@cdk.com - to test ALL_ContactRelationship_Helper class on Contact Report Assignment object
        WebId__c testWebId = DS_TestObjects.NewWebID_Inserted();
        testWebId.Account__c = accountObj3.Id;
        update testWebId;
        Contact_Report_Assignment__c testContactReport = new Contact_Report_Assignment__c(WebID__c = testWebId.Id,Account__c = accountObj3.Id,Contact__c = contactObj.Id);
        insert testContactReport;
        system.debug('***** testContactReport' +testContactReport);
        testContactReport.Primary__c = true;
        update testContactReport;
        
        //2016-06-10 - lalitha.adduru@cdk.com - to test ALL_ContactRelationship_Helper class on OEM District object
        CB_OEM_District__c testOEMDistrict = new CB_OEM_District__c(Status__c = 'Active');
        insert testOEMDistrict;
        testOEMDistrict.CB_Region_Account__c = accountObj3.Id;
        testOEMDistrict.Zone_Manager_After_Sales__c = contactObj.Id;
        update testOEMDistrict;
        
        CB_911_Escalation__c testEscalation = new CB_911_Escalation__c(
            Account__c= accountObj3.Id ,
            What_Product_s_need_a_911__c = '',
            Why__c='Dealer Request',
            Target_Date_Requested__c = date.today(),
            Requested_By__c = UserInfo.getUserId(),
            Target_Date_to_Complete__c = date.today(),
            status__c ='Completed'
        );
        insert testEscalation;
        
        testEscalation.Account__c = accountObj3.Id;
        testEscalation.Dealer_Contact_Name__c = contactObj.Id;
        update testEscalation;        
        
        Agency_Account_Contact__c testAgency = new Agency_Account_Contact__c(
            Agency_Account__c= accountObj3.Id 
        );
        insert testAgency;
        
        testAgency.Agency_Account__c = accountObj3.Id;
        testAgency.contact__c = contactObj.Id;
        update testAgency; 
        
        //2016-06-10 - lalitha.adduru@cdk.com - to test ALL_ContactRelationship_Helper class on LMA RFP object
        LMA_RFP__c testLMARFP = new LMA_RFP__c(Docusign_Envelope_Status__c = 'testStatus');
        insert testLMARFP;
        testLMARFP.LMA__c = accountObj3.Id;
        testLMARFP.LMA_Contact__c = contactObj.Id;
        update testLMARFP;
    }
    
    //2016-06-13 - venkata.shrivol@cdk.com - added this method 
    public static testMethod void consolidatedRolesTestOnInsert()
    {
        list<String> consolidatedRoles= new list<String>();
        Test.startTest();
        for(Contact_Relationship__c crt:[select Id, Role__c from Contact_Relationship__c ])
        {
            if(crt.Role__c!=null && crt.Role__c!='')
            {
                consolidatedRoles.add(crt.role__c);
            }
        }
        consolidatedRoles.sort();
        string roles = String.join(consolidatedRoles, '; ');
        list<Contact> insertedConList = [select Consolidated_Roles__c from Contact];
        Contact thisContact = insertedConList.size() > 0 ? insertedConList.get(0) : new Contact();
        system.assertEquals(roles, thisContact.Consolidated_Roles__c);
        Test.stopTest();
    }
    
    public static testmethod void afterUpdatetest()
    {
        Test.startTest();
        //Test-1 : Status change from Active to inactive
        Contact contactObj = [Select Id, AccountId, Dealer_Group__c, Consolidated_Roles__c From Contact Limit 1];
        Contact_Relationship__c contactRelationshipObj= [
            Select Id, Status__c, Account__c from Contact_Relationship__c where  Account__c = :contactObj.Dealer_Group__c 
            Limit 1];
        contactRelationshipObj.Status__c = 'Inactive';
        contactRelationshipObj.Role__c='';
        update contactRelationshipObj;
        contactObj = [Select Id, AccountId,Status__c, Dealer_Group__c From Contact Limit 1];
        System.assertNotEquals(contactRelationshipObj.Account__c,contactObj.Dealer_Group__c );
        System.assertEquals('Active',contactObj.Status__c );
        
        //Test-2 : Status change from Inactive to active
        contactRelationshipObj= [Select Id, Status__c, Account__c from Contact_Relationship__c where  Status__c='Inactive' Limit 1];
        contactRelationshipObj.Status__c = 'Active';
        update contactRelationshipObj;
        contactObj  = [Select Id, AccountId,Status__c, Dealer_Group__c From Contact Limit 1];
        System.assertEquals(contactRelationshipObj.Account__c,contactObj.Dealer_Group__c );
        System.assertEquals('Active',contactObj.Status__c );
        
        List<Contact_Relationship__c> contactRelationshipList= [Select Id, Status__c, Account__c from Contact_Relationship__c];
        for(Contact_Relationship__c contactRelationship : contactRelationshipList)
        {
            contactRelationship.Status__c = 'Inactive';
        }
        update contactRelationshipList;
        contactObj = [Select Id, AccountId,Status__c, Dealer_Group__c From Contact Limit 1];
        System.assertEquals(null,contactObj.Dealer_Group__c );
        System.assertEquals('Inactive',contactObj.Status__c );
        
        Test.stopTest();
    }
    
    //2016-06-13 - venkata.shrivol@cdk.com - added this method 
    public static testMethod void beforeDeleteTest()
    {
         Test.startTest();
        list<Contact_Relationship__c> conList = [select Id from Contact_Relationship__c where Status__c = 'Active' and Role__c = 'Accountant'];   
        Contact_Relationship__c thisContactRel = conList.size() > 0 ? conList.get(0) : new Contact_Relationship__c();
       
        if(thisContactRel.Id !=null)
        {
            delete thisContactRel; 
        }
        Contact contactObj = [Select Consolidated_Roles__c from Contact Limit 1];
        
        system.assertEquals(false, contactObj.Consolidated_Roles__c.contains('Accountant'));
        Test.stopTest();
    }
    
    //2016-06-13 - venkata.shrivol@cdk.com - added this method
    public static testMethod void roleUpdateTest()
    {
         Test.startTest();
        Contact_Relationship__c contactRelationshipObj= [
            Select Id, Status__c, Account__c from Contact_Relationship__c where  Status__c='Active' 
            and Role__c = 'Accountant' Limit 1];
       
        contactRelationshipObj.Role__c = null;
        update contactRelationshipObj;
       
        
        Contact contactObj = [Select Consolidated_Roles__c from Contact Limit 1];
        system.debug('********** contactobj' +contactobj.Consolidated_Roles__c);
        system.assertEquals(false, contactObj.Consolidated_Roles__c.contains('Accountant'));
         Test.stopTest();
    }
    
    //2016-05-31 - lalitha.adduru@cdk.com - wrote this test method to test ALL_ContactRelationship_Helper class
    //2016-06-09 - lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
    public static testmethod void assignContactRelationshipTest()
    {      
        List<Account> accountList = new List<Account>();
        accountList = [
            SELECT Id
            FROM Account
            WHERE Name = 'Test 1'
        ];
        system.debug('Existing account(from test setup) -->'+accountList);
        
        List<Contact> contactList = new List<Contact>();
        contactList = [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
        system.debug('Existing contact(from test setup) -->'+contactList);
        
        List<Contact_Relationship__c> contactRelationshipList = new List<Contact_Relationship__c>();
        contactRelationshipList = [
            SELECT Id
            FROM Contact_Relationship__c
            WHERE Account__c = :accountList[0].Id AND Contact__c = :contactList[0].Id
        ];
        system.debug('Existing contactRelationshipList(from test setup) -->'+contactRelationshipList);
        
        List<Account_Plan__c> accountPlanList = new List<Account_Plan__c>();
        accountPlanList = [
            SELECT Id, SEO_Decision_Made_By__c, SEO_Decision_Made_By_Relationship__c, Account__c
            FROM Account_Plan__c
        ];
        system.debug('Existing accountPlanList(from test setup) -->'+accountPlanList);
        
        Map<Id, Account_Plan__c> oldMap = new Map<Id, Account_Plan__c>();
        for(Account_Plan__c accountPlan : accountPlanList)
        {
            Account_Plan__c clonedAccountPlan = accountPlan.clone(false,true,true,true);
            oldMap.put(accountPlan.Id, clonedAccountPlan);
        }
        
        accountPlanList[0].Account__c = accountList[0].Id;
        accountPlanList[0].SEO_Decision_Made_By__c = contactList[0].Id;
        
        Map<String, String> contactToCRMap = new Map<String, String>();
        contactToCRMap.put('SEO_Decision_Made_By__c','SEO_Decision_Made_By_Relationship__c');
        
         //2017-03-31 - siva.pragada@cdk.com - adding additional governor limits - service connect test addition
        Test.StartTest();
        ALL_ContactRelationship_Helper.assignContactRelationship(accountPlanList, oldMap, 'Account__c', null, contactToCRMap);
        system.assertEquals(contactRelationshipList[0].Id, accountPlanList[0].SEO_Decision_Made_By_Relationship__c);
        
        accountPlanList[0].Account__c = null;
        oldMap.get(accountPlanList[0].Id).Account__c = accountList[0].Id;
        ALL_ContactRelationship_Helper.assignContactRelationship(accountPlanList, oldMap, 'Account__c', null, contactToCRMap);
        Test.StopTest();
        
        system.assertEquals(null, accountPlanList[0].SEO_Decision_Made_By_Relationship__c);
        
    }

    //2017-02-24 ragashalini.koka@cdk.com - Moved the Opportunity code from testSetup to testmethod from test setup to avoid SOQL limits for RQ-08532
    private static testmethod void validateOpportunityCR() {
        Test.startTest();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1]; 
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.CB_Dealership_Primary_Contact__c = con.Id;
        opp.AccountId = acc.Id;
        insert Opp;
        
        Opportunity_Influencers__c testInflu = new Opportunity_Influencers__c(
            contact__c = con.Id,
            Opportunity__c = opp.id
        );
        insert testInflu;
        Test.stopTest();
        Contact_Relationship__c cr = [SELECT Id FROM Contact_Relationship__c WHERE Contact__c = :con.Id AND Account__c = :acc.Id LIMIT 1];
        opp = [SELECT Id, Contact_Relationship__c FROM Opportunity WHERE Id = : opp.Id];
        System.assertEquals(cr.Id, opp.Contact_Relationship__c);

    }    
    //2017-02-28 ragashalini.koka@cdk.com - Added the method to validate the status of CRs of Duplicate Accounts for RQ-08685
    private static testmethod void validateUpdateCRStatusOfDuplicateAccount() {
        Test.startTest();
        Account acc = DS_TestObjects.NewAccount();
        acc.Duplicate__c = true;
        insert acc;
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Contact_Relationship__c cr = new Contact_Relationship__c();
        cr.Account__c = acc.Id;
        cr.Status__c = 'Active';
        cr.Contact__c = con.Id;
        insert cr;
        cr = [SELECT Id, Status__c FROM Contact_Relationship__c WHERE Id = :cr.Id];
        Test.stopTest();
        System.assertEquals('Inactive', cr.Status__c);
    }
    //2017-03-20 ragashalini.koka@cdk.com - Added this to validate after delete
    private static testmethod void validateAfterDelete() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<Contact_Relationship__c> crList = [SELECT Id FROM Contact_Relationship__c WHERE Contact__c = :con.Id];
        delete crList;
        con = [SELECT Id, Status__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Inactive', con.Status__c); 
        
    }
}