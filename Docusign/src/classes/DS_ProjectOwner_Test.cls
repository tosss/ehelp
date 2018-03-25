@IsTest
public class DS_ProjectOwner_Test 
{
	public static testmethod void TestProjectOwnerChange()
	{
		mpm3__Milestone1_Project__c p = new mpm3__Milestone1_Project__c(Name='Test Project T001');
		insert p;
		
		mpm3__Milestone1_Milestone__c m = new mpm3__Milestone1_Milestone__c(Name='Test Milestone M001', mpm3__Project__c=p.Id);
		insert m;
		
		
		User u = DS_TestObjects.NewUser_Inserted();
		u.ProfileId = UserInfo.getProfileId();
		u.IsActive = true;
		system.runas(DS_TestObjects.CurrentUser()) { update u; }
		
		p.OwnerId = u.Id;
		update p;
	}
}