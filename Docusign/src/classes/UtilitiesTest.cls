@IsTest
public class UtilitiesTest
{
	public static testmethod void ListToString() {
		List<String> strings = UtilitiesTest.NewStringList(); Utilities.ListToString(strings); }
	
	public static testmethod void ListToCSV() {
		List<String> strings = UtilitiesTest.NewStringList(); Utilities.ListToCsv(strings); }

	public static testmethod void ListToParenthesisCsv() {
		List<String> strings = UtilitiesTest.NewStringList(); Utilities.ListToParenthesesCsv(strings); }
	
	public static testmethod void ListToInclusiveCondition() 
	{
		List<String> strings = UtilitiesTest.NewStringList(); 
		Utilities.ListToInclusiveCondition('test','',null);
		Utilities.ListToInclusiveCondition('where','id',new List<String>{'a'});
		Utilities.ListToInclusiveCondition('where','id',strings); 
	}
	
	public static testmethod List<String> NewStringList() { return new List<String>{'a','b','c','d','e'}; }
	
	public static testmethod void GetDataFromNestedFields()
	{
		Id i = DS_TestObjects.NewAccount_Inserted().Id;
		Account a = [Select Id, Name, CreatedById, CreatedBy.UserName, CreatedBy.CreatedBy.UserName 
			From Account Where Id = :i];
		
		Utilities.GetDataFromNestedFields('Name', a);
		Utilities.GetDataFromNestedFields('CreatedBy.CreatedBy.UserName', a);
	}
	
	public static testmethod void PutDataInNestedFields()
	{
		Id i = DS_TestObjects.NewAccount_Inserted().Id;
		Account a = [Select Id, Name, CreatedById, CreatedBy.UserName, CreatedBy.CreatedBy.UserName 
			From Account Where Id = :i];
		
		Utilities.PutDataInNestedFields('Name', a, 'New Name');
		Utilities.PutDataInNestedFields('CreatedBy.CreatedBy.UserName', a, 'Test CreatedBy CreatedBy UserName');
	}
	
    public static testmethod void RandomInteger()
    {
        Integer Random = Utilities.RandomInteger(1, 10);
        system.assert(1 <= Random && Random <= 10);
    }
    
    public static testmethod void CryptoRandom()
    {
        // long max value is 9223372036854775807 ((2^63)-1)
        long CryptoRandom = Utilities.CryptoRandom();
        system.assert(1 <= CryptoRandom && CryptoRandom <= 9223372036854775807L);
    }
    
    public static testmethod void TrueRandomUpToAMillion() 
    {
        // string length compare
        string TrueRandom = Utilities.TrueRandomUpToAMillion();
        system.assert(1 <= TrueRandom.length() && TrueRandom.length() <= 7);
    }
    
    public static testmethod void GetCurrentInstanceName() 
    {
        string InstanceName = Utilities.GetCurrentInstanceName();
        system.assert(InstanceName != null);
    }
    
    public static testmethod void RandomUserName() 
    {
        string RandomUserName = Utilities.RandomUserName('UtilitiesTest');
        system.assert(RandomUserName != null && RandomUserName.contains('UtilitiesTest'));
    }
    
    public static testmethod void PreventMultipleOnParent()
    {
        Account a1 = DS_TestObjects.NewAccount_Inserted();
        
        Contact c1 = DS_TestObjects.NewContact();
        c1.AccountId = a1.Id; insert c1;
        
        Utilities.PreventMultipleOnParent(new list<Contact>{c1},'Account','AccountId','Contacts','Error');
        
        Contact c2 = DS_TestObjects.NewContact();
        c2.AccountId = a1.Id;
        
        try
        {
            Utilities.PreventMultipleOnParent(new list<Contact>{c1,c2},'Account','AccountId','Contacts','Error');
        }
        catch(Exception exc)
        {
            system.debug(exc.getMessage());
        }
    }
    
    public static testmethod void BusinessDaysCounter()
    {
        // 2015-01-29 TBD
        return;
    }
    
    public static testmethod void DayOfWeek()
    {
        // 2015-01-29 TBD
        return;
    }
    
	public static testmethod void Job()
	{
		AsyncApexJob NewJob = DS_TestObjects.NewAsyncApexJob();
		Utilities.Job UtilitiesJob1 = new Utilities.Job(NewJob);
		Utilities.Job UtilitiesJob2 = new Utilities.Job();
	}
	
	public static testmethod void SendBatchCompleteMessage()
	{
		Utilities.Job UtilitiesJob = new Utilities.Job();
		Utilities.SendBatchCompleteMessage(UtilitiesJob, 'Title', 'Description', 'Message');
	}
}