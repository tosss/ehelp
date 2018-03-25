@isTest
public class ALL_UtilitiesMiscellaneous_Test 
{
    public static testmethod void GetCurrentInstanceName() 
    {
        string InstanceName = ALL_UtilitiesMiscellaneous.GetCurrentInstanceName();
        system.assert(InstanceName != null);
    }
    
    public static testmethod void Job()
	{
		AsyncApexJob NewJob = DS_TestObjects.NewAsyncApexJob();
		ALL_UtilitiesMiscellaneous.Job UtilitiesJob1 = new ALL_UtilitiesMiscellaneous.Job(NewJob);
		ALL_UtilitiesMiscellaneous.Job UtilitiesJob2 = new ALL_UtilitiesMiscellaneous.Job();
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
}