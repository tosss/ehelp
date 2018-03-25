/**
 Test-Class for Updating Contract numbers in DealState record from Implementation data
 i.e.., for IMP_UpdateDealStateContractNum_Handler.cls
 */
@isTest
private class IMP_UpdateDealStateContNumHandler_Test {

    static testMethod void updateContractNumber_Test() {
    	
    	
    	
    	
    	User u = DS_TestObjects.NewUser_Inserted();
        Account acc = DS_TestObjects.NewAccount_Inserted(); 
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Oppo1';
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
        
        // Test
        list<String> tempContList = new list<String>();
        Account testChildAccount = IMP_TestFactory_Helper.buildAccount();
        insert testChildAccount;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        testProject.Dealer_Group__c = testChildAccount.Id;
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        testSubProject.Dealer_Group__c = testChildAccount.Id;
        testSubProject.Deal_Id__c = '12345';
        testSubProject.Project__c= testProject.id;
        insert testSubProject;
        
        SubProject_External_Related_Entity__c testEntity = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
        testEntity.Entity_Type__c = 'Contract';
        testEntity.Entity_Number__c = '123456';
        testEntity.SubProject__c = testSubProject.id;
        testEntity.Project__c = testProject.id;
        tempContList.add(testEntity.Entity_Number__c);
        insert testEntity;
        
         SubProject_External_Related_Entity__c testEntity2 = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
        testEntity2.Entity_Type__c = 'Contract';
        testEntity2.Entity_Number__c = '456789';
        testEntity2.SubProject__c = testSubProject.id;
        testEntity2.Project__c = testProject.id;
        tempContList.add(testEntity2.Entity_Number__c);
        insert testEntity2;
        
        
        Map<String, list<String>> contNumTest = new Map<String, list<String>>();
        
        
        contNumTest.put(testSubProject.Deal_Id__c ,tempContList);
        IMP_UpdateDealStateContractNum_Handler.updateContractNumbers(contNumTest);
        
        //contNumTest.put(testSubProject.Deal_Id__c ,testEntity2.Entity_Number__c );
        //IMP_UpdateDealStateContractNum_Handler.updateContractNumbers(contNumTest);
        
        
        
    }
}