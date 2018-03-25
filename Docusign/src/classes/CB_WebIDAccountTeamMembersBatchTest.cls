@IsTest
public class CB_WebIDAccountTeamMembersBatchTest
{
	public static testmethod void ProcessBatch()
	{
		CB_WebIDAccountTeamMembers_Test.SetupSettings();
		
		CB_WebIDAccountTeamMembersBatch b1 = new CB_WebIDAccountTeamMembersBatch();
		
		Account a = DS_TestObjects.NewAccount_Inserted();
		CB_WebIDAccountTeamMembersBatch b2 = new CB_WebIDAccountTeamMembersBatch(new List<Account>{a});
		
		String query = b1.st();
		
		List<Account> Accounts = Database.query(query);
		b1.ex(Accounts);
		
		b1.fn(null);
	}
}