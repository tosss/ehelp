/*
Test Class for IMP_UpdateDealStateRollCallDate_Handler
*/
//2016-03-09- anirudh.singh@cdk.com- Commented this test class as it was not following naming standards.
//                                   Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
@isTest
private class IMP_UpdateDealSteRollCallDateHndler_Test {

    /*static testMethod void rollCallDateTest() 
    {
        User u = DS_TestObjects.NewUser_Inserted();
        Account acc = DS_TestObjects.NewAccount_Inserted(); 
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity1';
        opp.ADP_Opportunity_Owner__c = u.id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Plan';
        opp.Account = acc;
        insert opp; 
        
        Opportunity_Quotes__c oppQuote = new Opportunity_Quotes__c();
        oppQuote.Deal_ID__c = '12345';
        oppQuote.Opportunity__c =opp.id;
        oppQuote.Account__c = acc.id;
        insert oppQuote;
        
        Deal_State__c dealState = new Deal_State__c();
        dealState.SQT_Deal_ID__c = '12345';
        dealState.Opportunity__c = opp.id;
        dealState.CA_Approved_Date__c = datetime.now();
        insert dealState;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opportunity2';
        opp2.ADP_Opportunity_Owner__c = u.id;
        opp2.CloseDate = Date.Today();
        opp2.StageName = 'Plan';
        opp2.Account = acc;
        insert opp2; 
        
        Opportunity_Quotes__c oppQuote2 = new Opportunity_Quotes__c();
        oppQuote2.Deal_ID__c = '08972';
        oppQuote2.Opportunity__c =opp2.id;
        oppQuote2.Account__c = acc.id;
        insert oppQuote2;
        
        Deal_State__c dealState2 = new Deal_State__c();
        dealState2.SQT_Deal_ID__c = '08972';
        dealState2.Opportunity__c = opp2.id;
        dealState2.CA_Approved_Date__c = datetime.now();
        insert dealState2;
        
        //Test
        Account testChildAccount = IMP_TestFactory_Helper.buildAccount();
        insert testChildAccount;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        //testProject.Dealer_Group__c = testChildAccount.Id;
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        //testSubProject.Dealer_Group__c = testChildAccount.Id;
        testSubProject.Deal_Id__c = '12345';
        testSubProject.Project__c= testProject.id;
        testSubProject.Contract_Roll_Called__c = date.newinstance(2015, 02, 09);
        insert testSubProject;
        
        SubProject__c testSubProject2 = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        //testSubProject2.Dealer_Group__c = testChildAccount.Id;
        testSubProject2.Deal_Id__c = '08972';
        testSubProject2.Project__c= testProject.id;
        testSubProject2.Contract_Roll_Called__c = date.newinstance(2099, 07, 18);
        insert testSubProject2;
        
        
        
        Map<String, Date> rollCallDateTestMap = new Map<String, Date>();
        
        rollCallDateTestMap.put(testSubProject.Deal_Id__c,testSubProject.Contract_Roll_Called__c);
        rollCallDateTestMap.put(testSubProject2.Deal_Id__c,testSubProject2.Contract_Roll_Called__c);
        IMP_UpdateDealStateRollCallDate_Handler.updateRollCallDate(rollCallDateTestMap);
        
         //Map<String, Date> rollCallDateNullMap = new Map<String, Date>();
         //IMP_UpdateDealStateRollCallDate_Handler.updateRollCallDate(rollCallDateNullMap);
            
    }*/
}