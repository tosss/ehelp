@IsTest
public class DS_CreateCompCampAccMember_Test 
{
	public static testmethod void testCompositeCampaignAccountMember()
    {
		Campaign c = new Campaign();
        c.Name = 'Test Case for Campaign';
        c.Status = 'In Progress';	
		insert c;
        
		Account a = new Account();
		a.Name = 'Test Case for Account';
		insert a;
        
		Campaign_Account_Members__c  cam = new Campaign_Account_Members__c();
        cam.Account__c = a.Id;
        cam.Campaign__c = c.Id;	
        cam.Campaign_Member_Status__c = 'Test'; 
		insert cam;
	}
}