@IsTest(seeAllData=True)
public class DS_CMFNumberLookup_Test 
{
	public static testmethod void TestCMFNumberChanges() 
	{
		mpm3__Milestone1_Project__c p = new mpm3__Milestone1_Project__c(Name='Test Project T001');
		insert p;
		
		Account a = new Account(Name='Test Account T001');
		insert a;
		
		String TempCMFNumber = String.valueOf(DateTime.now().millisecond()*1234);
		
		CMF_Info__c cmf = new CMF_Info__c(Name='Test CMF Info T001', Account__c=a.Id, Ship_CMF__c=TempCMFNumber);
		insert cmf;
		
		p.CMF_Number__c = TempCMFNumber;
		update p;
		
		p.CMF_Number__c = 'ABCDEFGH'; // invalid number
		update p;
	}
}