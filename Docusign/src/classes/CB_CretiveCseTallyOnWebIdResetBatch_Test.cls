/*-----------------------------------------------------
* 08/03/2015  -Venkata Shrivol  -Created
* Description - Test class for CB_CreativeCaseTallyOnWebIdReset_Batch
* ----HISTORY------

-------------------------------------------------------*/
@isTest 
private class CB_CretiveCseTallyOnWebIdResetBatch_Test 
{
	static testMethod void prepareWebIDCaseAccPlanData()
	{
		//User u = DS_TestObjects.NewUser_Inserted();
    	Account acc = DS_TestObjects.NewAccount_Inserted();
    	
    	Contact testContact = new Contact();
    	testContact.FirstName = 'First';
    	testContact.LastName = 'Last';
    	testContact.AccountId = acc.Id;
    	insert testContact;
    	
    	list<WebID__c> testWebIdList = new list<WebID__c>();
    	for(integer i=0;i<2;i++)
    	{
    		WebID__c testId = new WebID__c();
	    	testId.Account__c = acc.Id;
	    	if(i==0){
	    		testId.Name = 'gmps-test';
                testId.Creative_Case_Tally__c = 5;
	    	}
	    	else{
	    		testId.Name = 'holden-test';
                testId.Creative_Case_Tally__c = 0;
	    	}
	    	testId.Status__c = 'Active';
	    	testWebIdList.add(testId);
    	}
    	insert testWebIdList;
    	
    	String caseRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative');
    	
    	list<Case> testCaseList = new list<Case>();
    	for(integer j=0;j<testWebIdList.size();j++)
    	{
    		for(integer k=0;k<5;k++)
    		{
    			Case testCase = new Case();
		    	testCase.RecordTypeId = caseRecordTypeId;
		    	testCase.AccountId = acc.Id;
		    	testCase.ContactId = testContact.Id;
		    	testCase.WebID__c= testWebIdList.get(j).Id;
		    	testCase.Problem_Code__c = 'Power Brand';
                if(j==0)
                {
                   testCase.Creative_Case_Tally__c = 5; 
                }
                else
                {
                    testCase.Creative_Case_Tally__c = 0;
                }
		    	testCase.Status = 'Open';
		    	testCaseList.add(testCase);
    		}
    	}
    	insert testCaseList;
    	
    	String accountPlanRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'DAA Account Plan');
    	
    	list<Account_Plan__c> accPlanList = new list<Account_Plan__c>();
    	for(integer i=0;i<testWebIdList.size();i++)
    	{
    		Account_Plan__c testPlan = new Account_Plan__c();
	    	testPlan.WebID__c = testWebIdList.get(i).Id;
	    	testPlan.Account__c = acc.Id;
            if(i==0)
            {
                testPlan.Creative_Case_Tally__c = 5; 
            }
            else
            {
                testPlan.Creative_Case_Tally__c = 0;
            }
	    	accPlanList.add(testPlan);
    	}
    	insert accPlanList;
    	
    	//string testQuery = 'SELECT ID, Creative_Case_Tally__c, (Select Id,Creative_Case_Tally__c, RecordType.Name, WebId__c, Status from Cases__r), (Select Id,Creative_Case_Tally__c, RecordType.Name, WebId__c, Status from Account_Plans__r)  from WebID__c';
    	
    	Test.startTest();
    	CB_CreativeCaseTallyOnWebIdReset_Batch executeBatchTest = new CB_CreativeCaseTallyOnWebIdReset_Batch();
        //executeBatchTest.query = testQuery;
    	Database.executeBatch(executeBatchTest);
    	Test.stopTest();
	}

}