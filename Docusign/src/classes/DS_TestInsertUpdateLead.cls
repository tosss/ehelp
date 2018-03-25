@isTest
public class DS_TestInsertUpdateLead 
{
	testMethod static void TestInsertUpdateLead()
	{
		string mgrId;
		User testMgr = [select Id, IsActive from User where IsActive = true limit 1]; 
		mgrId = testMgr.Id;
		//User testUser = [select Id, IsActive from User where ManagerId = :testMgr.Id and IsActive = true limit 1];
		Profile P = DS_TestObjects.getAdminProfile();
		Id ProfileId = P != null ? P.id : null;
		
		User leadOwner = new User();
			leadOwner.Firstname = 'Test';
			leadOwner.Lastname = 'User';
			leadOwner.Title = 'TestUser';
			leadOwner.Street = '1950 Hassel Rd.';
			leadOwner.City = 'Hoffman Estates';
			leadOwner.State = 'IL';
			leadOwner.Username = 'tuser1@adp.com';
			leadOwner.email = 'test1@adp.com';
			leadOwner.alias = 'testuser';
			leadOwner.MobilePhone = '2342342343';
			leadOwner.Fax = '3453453454';
			leadOwner.Extension = '3344';
			leadOwner.Country = 'USA';
			leadOwner.TimeZoneSidKey = 'America/Chicago';
			leadOwner.LocaleSidKey = 'en_US';
			leadOwner.EmailEncodingKey = 'ISO-8859-1';
			leadOwner.ProfileId = ProfileId;
			leadOwner.LanguageLocaleKey = 'en_US';
			leadOwner.ADID__c = 'tuser1';
		insert leadOwner;
		
		User leadOwner2 = new User();
			leadOwner2.Firstname = 'Test';
			leadOwner2.Lastname = 'User';
			leadOwner2.Title = 'TestUser';
			leadOwner2.Street = '1950 Hassel Rd.';
			leadOwner2.City = 'Hoffman Estates';
			leadOwner2.State = 'IL';
			leadOwner2.Username = 'tuser2@adp.com';
			leadOwner2.email = 'test1@adp.com';
			leadOwner2.alias = 'testuser';
			leadOwner2.MobilePhone = '2342342343';
			leadOwner2.Fax = '3453453454';
			leadOwner2.Extension = '3344';
			leadOwner2.Country = 'USA';
			leadOwner2.TimeZoneSidKey = 'America/Chicago';
			leadOwner2.LocaleSidKey = 'en_US';
			leadOwner2.EmailEncodingKey = 'ISO-8859-1';
			leadOwner2.ProfileId = ProfileId;
			leadOwner2.LanguageLocaleKey = 'en_US';
			leadOwner2.ADID__c = 'tuser2';
		insert leadOwner2;
		
    	Account a = new Account();
    	a.Name = 'Test Account';
    	a.Ownerid = mgrId;
    	insert a;	
				
		Lead testLead = New Lead();
			testLead.OwnerId = leadOwner.Id;
			testLead.Current_Account__c = a.Id;
			testLead.LeadSource = 'Trade Show - NADA';
			testLead.LastName = 'Jones';
			testLead.Company = 'ADP';
			testLead.Demo_Location__c = 'VIP';
			testLead.Demo_Date__c = Date.today();
		insert testLead;
		
		testLead.OwnerId = leadOwner2.Id;
		update testLead;
	}
}