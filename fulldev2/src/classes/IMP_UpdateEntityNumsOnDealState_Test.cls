/**------------------------------
 Test-Class for Updating entity numbers in DealState record from Implementation data
 i.e.., for IMP_UpdateEntityNumsOnDealState_Handler.cls

****HISTORY****
09/01/2015 - Venkata Shrivol - Renamed to IMP_UpdateEntityNumsOnDealState_Test  
							   and updated accordingly for modified handler class
-------------------------------------- */
@isTest
private class IMP_UpdateEntityNumsOnDealState_Test {

    @testSetup static void updateEntityNumbers_Test() 
    {
    		
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
        //dealState.CA_Approved_Date__c = datetime.now();
        insert dealState;
        
        // Test
        list<IMPDS_SpereToDealState__c> customSettingsList = new list<IMPDS_SpereToDealState__c>();
        for(integer i=0;i<2;i++)
        {
            IMPDS_SpereToDealState__c testSetting = new IMPDS_SpereToDealState__c();
            if(i==0){
                testSetting.Name='Contract';
            }
            else{
              testSetting.Name='Impact Project';  
            }
            customSettingsList.add(testSetting);
        }
        insert customSettingsList;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        //testProject.Dealer_Group__c = acc.Id;
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        //testSubProject.Dealer_Group__c = acc.Id;
        testSubProject.Deal_Id__c = '12345';
        testSubProject.Project__c= testProject.id;
        insert testSubProject;
        
        list<SubProject_External_Related_Entity__c> entityList = new list<SubProject_External_Related_Entity__c>();
        for(integer i=2;i<6;i++)
        {
            SubProject_External_Related_Entity__c testEntity = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
            if(math.mod(i,2)==0){
                testEntity.Entity_Type__c = 'Contract';
            }
            else{
                testEntity.Entity_Type__c = 'Impact Project';
            }
            testEntity.Entity_Number__c = i+'8793323';
            testEntity.SubProject__c = testSubProject.id;
            testEntity.Project__c = testProject.id;
            entityList.add(testEntity);
        }
        insert entityList;
        
        entityList.clear();
        
        for(integer i=0;i<2;i++)
        {
            SubProject_External_Related_Entity__c testEntity = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
            if(i==0){
                testEntity.Entity_Type__c = 'Contract';
            }
            else{
                testEntity.Entity_Type__c = 'Impact Project';
            }
            testEntity.Entity_Number__c = i+'1231231';
            testEntity.SubProject__c = testSubProject.id;
            testEntity.Project__c = testProject.id;
            entityList.add(testEntity);
        }
        insert entityList;
        
        
        //system.debug('----entityList------------'+entityList);
    }
    
    static testMethod void updateOnDealStateTest()
    {
    	Deal_State__c ds = [select Contract_Number_s__c, Impact_Project_Number__c from Deal_State__c where SQT_Deal_ID__c = '12345' limit 1];
        system.assertNotEquals(null, ds.Contract_Number_s__c);
        system.assertNotEquals(null, ds.Impact_Project_Number__c);
        system.assertEquals(true, ds.Contract_Number_s__c.contains('8793323'));
        system.assertEquals(true, ds.Impact_Project_Number__c.contains('8793323'));
    }
}