public class DS_CreateIdForSystemAtDealerTest {

	testMethod static void testCreateIdForSystemAtDealer(){
		Account a = new Account();
			a.Name = 'New Test Class Account';
		insert a;
		Systems__c s = new Systems__c();
			s.Active__c = true;
			s.Name = 'ADP - 12000';
			s.Type__c = 'Leasing';
			s.Vendor_Code__c = 'ADP';
            s.SLXVendor_ID__c = '12345';
		insert s;
		// Test New Line for saving
		//c.CompositeExtID__c = c.Account__c + '' + sys.SLXVendor_ID__c + '' + '            ' + '' + sys.Type__c;
		System_at_Dealership__c sad = new System_at_Dealership__c();
			sad.Account__c = a.Id;
			sad.Box_Onsite__c = true; 
			sad.Install_Date__c = Date.ValueOf('2008-10-22'); 
			sad.System_Type__c = 'Leasing';
			sad.Vendor__c = s.Id;
		insert sad;	
	}
}