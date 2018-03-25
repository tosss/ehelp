@IsTest
public class CB_PreventDeleteTriggers_Test
{
    public static testmethod void TestEmailMessageDelete()
    {
        // Custom Settings and Global Settings are not available by default in @IsTest Test Classes
    	// So, data for them needs to be added 
        CustomSettings__c cs = new CustomSettings__c(
            DS_ContactBeforeInsertUpdate_On__c = false,
            WebIDTriggers_On__c = false); 
        
        
        GlobalSettings__c gs = new GlobalSettings__c(
            Email_2_Case_Prevent_Delete__c = true,             
            Email_2_Case_User__c = 'email2case@adp.com'); 
        
        
        ALL_Profile_Access_Settings__c profileSettings  = new ALL_Profile_Access_Settings__c(
            Email_2_Case_Email_Attachment__c = false, 
            Email_2_Case_Email_Message__c = false
        );
        
        insert new list<sObject>{ profileSettings, gs, cs};
       
        Trigger_Toggle__c tt = new Trigger_Toggle__c(
        	Name = 'caseTriggers',
        	On__c = false);
        insert tt;
        
        List<User> e2cPreExisting = [Select Id, UserName, Email, FirstName, LastName From User Where UserName = 'email2case@adp.com'];
        User e2cUser = null;
        
        if(e2cPreExisting != null && e2cPreExisting.size() < 1)
        {
            Profile P = DS_TestObjects.getStandardProfile();
	        e2cUser = new User(
	            UserName = 'email2case@adp.com',
	            Email = 'email2case@adp.com',
	            Alias = 'atest',
	            CommunityNickname = 'e2c54321',
	            EmailEncodingKey = 'UTF-8',
	            FirstName = 'Email2Case',
	            LastName = 'Test User',
	            LanguageLocaleKey = 'en_US', 
	            LocaleSIDKey = 'en_US',
	            profileid = P != null ? P.Id : null, 
	            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
	            TimeZoneSIDKey = 'America/Chicago',
	            ADID__c = 'e2cTest'
	        ); insert e2cUser;
        }
        else
        {
        	e2cUser = e2cPreExisting[0];
        }
        
        // Profiles are available in @IsTest Test Classes by default
        Map<Id,Profile> profiles = new Map<Id,Profile>([Select Id, Name From Profile]);
        
        Account a = new Account(Name='Test Account EM001');
        insert a;
        
        Contact co = new Contact(FirstName = 'Test', LastName='Contact EM001', AccountId=a.Id, Role__c='Test Role'); // 9/29
        insert co;
        
        WebID__c w = new WebID__c(Name='test-em001-webid', Account__c=a.Id);
        insert w;
        
        Case c = new Case();
        c.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Case' and Name like '%tier 1%'].id;
        c.AccountId = a.Id;
        c.WebID__c = w.Id;
        c.ContactId = co.Id;
        c.Status = 'Open';
        c.Subject = 'Test';
        c.Origin = 'Email';
        c.Origin_Type__c = 'INB-Customer';
        c.Product_Category__c = 'Email';
        c.Priority = '2-TWO Business Days';
        c.Escalation_Reason__c = 'Other Technical Issue';
        insert c;
        
        EmailMessage e1 = new EmailMessage();
        e1.ParentId = c.Id;
        insert e1;
        
        Blob a1Blob = Blob.valueOf('Test');
        Attachment a1 = new Attachment(Name='Test Attachment', ParentId=e1.Id, Body=a1Blob);
        insert a1;
        
        // try to delete the Attachment
        try { delete a1; } catch(Exception exc) { system.debug('!!! Expected Attachment Error !!! '+exc); }
        
        try 
        {
            // if the Attachment was not deleted, add the current Profile Name to the list of Profiles that have permission
            // to delete and try again
            if(!a1.IsDeleted)
            {
                profileSettings.Email_2_Case_Email_Attachment__c = true;
            	update profileSettings;
            	delete a1;
            }
        } catch(Exception exc) { system.debug('!!! Unexpected Attachment Error !!! '+exc); }
            
        // try to delete the Email Message
        try { delete e1; } catch(Exception exc) { system.debug('!!! Expected Email Message Error !!! '+exc); }
        
        try 
        {
            // if the Email Message was not deleted, add the current Profile Name to the list of Profiles that have permission
            // to delete and try again
            if(!e1.IsDeleted)
            {
                profileSettings.Email_2_Case_Email_Message__c = true;
            	update profileSettings;
            	delete e1;
            }
        } catch(Exception exc) { system.debug('!!! Unexpected Email Message Error !!! '+exc); }
    }
}