@isTest
public class ALL_UtilitiesMiscellaneous_Test 
{
    public static testmethod void GetCurrentInstanceName() 
    {
        string InstanceName = ALL_UtilitiesMiscellaneous.GetCurrentInstanceName();
        system.assert(InstanceName != null);
    }
    
    public static testMethod void testIsProductionOrg()
    {
        boolean isProduction = ALL_UtilitiesMiscellaneous.isProductionOrg(); 
        system.assert(isProduction != null);
    }
    
    public static testmethod void Job()
	{
		//vijay commented for deployment to new instance
		/*AsyncApexJob NewJob = DS_TestObjects.NewAsyncApexJob();
		ALL_UtilitiesMiscellaneous.Job UtilitiesJob1 = new ALL_UtilitiesMiscellaneous.Job(NewJob);
		ALL_UtilitiesMiscellaneous.Job UtilitiesJob2 = new ALL_UtilitiesMiscellaneous.Job();*/
	}
    
    public static testmethod void SendBatchCompleteMessage()
	{
		ALL_UtilitiesMiscellaneous.Job UtilitiesJob = new ALL_UtilitiesMiscellaneous.Job();
		ALL_UtilitiesMiscellaneous.SendBatchCompleteMessage(UtilitiesJob, 'Title', 'Description', 'Message');
	}
    
    public static testmethod void PreventMultipleOnParent()
    {
        Account a1 = DS_TestObjects.NewAccount_Inserted();
        
        Contact c1 = DS_TestObjects.NewContact();
        c1.AccountId = a1.Id; insert c1;
        
        ALL_UtilitiesMiscellaneous.PreventMultipleOnParent(new list<Contact>{c1},'Account','AccountId','Contacts','Error');
        
        Contact c2 = DS_TestObjects.NewContact();
        c2.AccountId = a1.Id;
        
        try
        {
            ALL_UtilitiesMiscellaneous.PreventMultipleOnParent(new list<Contact>{c1,c2},'Account','AccountId','Contacts','Error');
        }
        catch(Exception exc)
        {
            system.debug(exc.getMessage());
        }
    }
    
    //2015-06-30 hemanth.kesapragada@cdk.com Added test method to test ShowDebugLogs in Utlilites class
    public static testMethod void testDebug()
    {
        CustomSettings__c.getOrgDefaults().Show_Debug__c = true;
        Integer accountNumber = 2345;
        ALL_UtilitiesMiscellaneous.showDebug = true;
        ALL_UtilitiesMiscellaneous.debug(accountNumber);
        
        String accountName = 'Test Account';
        ALL_UtilitiesMiscellaneous.showDebug = true;
        ALL_UtilitiesMiscellaneous.debug(accountName);
    }
    
    //2015-06-21 - siva.pragada@cdk.com - added below method
    static testMethod void testLogException()
    {
        try
        {  
            string s;
            list<string> stringList = s.split('.');
        } 
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.logException(e);
        } 
    }
    
    static testMethod void testForLogDMLException()
    {
        // commented by vijay for deployment to new instance
       /*
        try
        {
            Exception_Log__c log = new Exception_Log__c();
            insert log;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.logException(e);
        }
        */
    }
}