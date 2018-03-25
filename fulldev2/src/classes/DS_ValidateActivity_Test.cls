@IsTest
public class DS_ValidateActivity_Test
{
	public static Integer BAC_NUMBER_MULTIPLIER = 111;
	
	public static testmethod void AddActivityError()
	{
		DS_ValidateActivity.BAC_AddActivityError(new Account(), 'Test Error Message');
		DS_ValidateActivity.BAC_AddActivityError(new Task(), 'Test Error Message');
		DS_ValidateActivity.BAC_AddActivityError(new Event(), 'Test Error Message');
	}
	
	public static testmethod void AddContactDataToActivities()
	{
		Contact c = DS_TestObjects.NewContact_Inserted();
		Task t = DS_TestObjects.NewTask(); t.WhoId = c.Id;
		
		DS_ValidateActivity.AddContactDataToActivities(new List<sObject>{t});
	}
	
	public static testmethod void GetActivityAccountId()
	{
		// Task without data
		Task t1 = new Task();
		DS_ValidateActivity.GetActivityAccountId(t1);
		
		// Task with AccountId
		Task t2 = DS_TestObjects.NewTask_Inserted(); // query needed get get system AccountId value
		t2 = [Select Id, Subject, AccountId, WhatId, WhoId From Task Where Id = :t2.Id Limit 1];
		DS_ValidateActivity.GetActivityAccountId(t2);
		
		// Task with WhatId
		Task t3 = DS_TestObjects.NewTask(); 
        t3.WhatId = DS_TestObjects.NewAccount_Inserted().Id;
		DS_ValidateActivity.GetActivityAccountId(t3);
		
		// Task with WhoId
		Task t4 = DS_TestObjects.NewTask(); 
        t4.WhoId = DS_TestObjects.NewContact_Inserted().Id;
		DS_ValidateActivity.GetActivityAccountId(t4);
	}
	
	public static testmethod Map<Id, List<sObject>> BAC_FilterActivitiesByAccountId()
	{
		Account a = DS_TestObjects.NewAccount_Inserted();
		
		List<Task> Tasks = new List<Task>();
		for(Integer i = 0; i < 10; i++) { 
			Task t = DS_TestObjects.NewTask(); 
			t.Subject = 'Test Task ' + String.valueOf(i); 
			t.WhatId = a.Id;
			t.BAC__c = String.valueOf(BAC_NUMBER_MULTIPLIER*(i+1)); 
			Tasks.add(t); 
		}
		
		Task TaskWithoutAccount = DS_TestObjects.NewTask();
		TaskWithoutAccount.BAC__c = String.valueOf(BAC_NUMBER_MULTIPLIER);
		Tasks.add(TaskWithoutAccount);
		
		DS_ValidateActivity.BAC_FilterActivitiesByAccountId(Tasks);
		
		return new Map<Id, List<sObject>> { a.Id => Tasks };
	}
	
	public static testmethod Map<Id, Set<String>> BAC_QueryValidBACsByAccountId()
	{
		Account a = DS_TestObjects.NewAccount_Inserted();
		
		List<Business_Site__c> BusinessSites = new List<Business_Site__c>();
		// only add five because there needs to be a Task BAC that does not match a Business Site BAC
		for(Integer i=0; i<5; i++) 
		{
			BusinessSites.add(new Business_Site__c(BAC__c = String.valueOf(BAC_NUMBER_MULTIPLIER*(i+1)), Account__c = a.Id));
			BusinessSites.add(new Business_Site__c(BAC__c = String.valueOf(BAC_NUMBER_MULTIPLIER*(i+1)), Account__c = a.Id));
		}
		insert BusinessSites;
		
		Set<Id> AccountIds = new Set<Id>(); AccountIds.add(a.Id);
		Map<Id, Set<String>> BACsByAccountId = DS_ValidateActivity.BAC_QueryValidBACsByAccountId(AccountIds);
		
		return BACsByAccountId;
	}
	
	public static testmethod void BAC_ProcessActivities()
	{
		Account a = DS_TestObjects.NewAccount_Inserted();
		
		List<sObject> GeneratedActivities = new List<sObject>(); 
		Set<String> GeneratedBACs = new Set<String>();
		
		for(List<sObject> GeneratedActivitiesList : BAC_FilterActivitiesByAccountId().values()) {
			for(sObject s : GeneratedActivitiesList) {
				s.put('WhatId', a.Id); GeneratedActivities.add(s); } }
		
		for(Set<String> GeneratedBACsSet : BAC_QueryValidBACsByAccountId().values()) {
			GeneratedBACs.addAll(GeneratedBACsSet); }
		
		Map<Id, List<sObject>> ActivitiesByAccountId = new Map<Id, List<sObject>> { a.Id => GeneratedActivities };
		Map<Id, Set<String>> BACNumbersByAccountId = new Map<Id, Set<String>> { a.Id => GeneratedBACs };
		
		DS_ValidateActivity.BAC_ProcessActivities(ActivitiesByAccountId, BACNumbersByAccountId);
	}
	
	public static testmethod void TestValidateBAC()
	{
		Task t = DS_TestObjects.NewTask_Inserted();
		DS_ValidateActivity.Validate(new List<Task>{t});
		
		Event e = DS_TestObjects.NewEvent_Inserted();
		DS_ValidateActivity.Validate(new List<Event>{e});
	}
}