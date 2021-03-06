//2015-11-27    vishal.bandari@cdk.com    RQ-05289:changed TestEmailMessageDelete method to add contact record type
//2016-01-06    vishal.bandari@cdk.com    changed email ids from adp to cdk
//2016-06-10- ragashalini.koka@cdk.com- moved Role__c from Contact to Contact_Relationship__c.
@IsTest
public class CB_PreventDeleteTriggers_Test
{
    public static testmethod void TestEmailMessageDelete()
    {
        // Custom Settings and Global Settings are not available by default in @IsTest Test Classes
        // So, data for them needs to be added 
        CustomSettings__c cs = new CustomSettings__c(
            DS_ContactBeforeInsertUpdate_On__c = false,
            WebIDTriggers_On__c = false
        ); 
        insert cs;
        
        GlobalSettings__c gs = new GlobalSettings__c(
            Email_2_Case_Prevent_Delete__c = true, 
            Email_2_Case_Email_Attachment_Profiles__c='',
            Email_2_Case_Email_Message_Profiles__c='',
            Email_2_Case_User__c = 'email2case@cdk.com'
        );
        insert gs;
        
        Trigger_Toggle__c tt = new Trigger_Toggle__c(
            Name = 'caseTriggers',
            On__c = false
        );
        insert tt;
        
        List<User> e2cPreExisting = [Select Id, UserName, Email, FirstName, LastName From User Where UserName = 'email2case@cdk.com'];
        User e2cUser = null;
        
        if(e2cPreExisting != null && e2cPreExisting.size() < 1)
        {
            Profile P = DS_TestObjects.getStandardProfile();
            e2cUser = new User(
                UserName = 'email2case@cdk.com',
                Email = 'email2case@cdk.com',
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
            );
            insert e2cUser;
        }
        else
        {
            e2cUser = e2cPreExisting[0];
        }
        
        // Profiles are available in @IsTest Test Classes by default
        Map<Id,Profile> profiles = new Map<Id,Profile>([Select Id, Name From Profile]);
        
        Account a = new Account(Name='Test Account EM001');
        insert a;
        
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Id RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        Contact co = new Contact(FirstName = 'Test', LastName='Contact EM001', RecordTypeId = RecordTypeId, AccountId=a.Id); // 9/29
        //2016-06-15- ragashalini.koka@cdk.com- Commented the below line and using ALL_SharedContacts_Helper for inserting Contact.
        //insert co;
        ALL_SharedContact_Helper.insertContact(co, null, null, null);
        
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
        c.Product_Category__c = 'Assets';
        c.Problem_Code__c = 'Background';
        c.Priority = 'Standard';
        
        //c.Escalation_Reason__c = 'Other Technical Issue';
        insert c;
        
        EmailMessage e1 = new EmailMessage();
        e1.ParentId = c.Id;
        insert e1;
        
        Blob a1Blob = Blob.valueOf('Test');
        Attachment a1 = new Attachment(Name='Test Attachment', ParentId=e1.Id, Body=a1Blob);
        insert a1;
        
        // try to delete the Attachment
        try
        {
            delete a1;
        }
        catch(Exception exc)
        {
            system.debug('!!! Expected Attachment Error !!! '+exc);
        }
        
        try 
        {
            // if the Attachment was not deleted, add the current Profile Name to the list of Profiles that have permission
            // to delete and try again
            if(!a1.IsDeleted)
            {
                gs.Email_2_Case_Email_Attachment_Profiles__c += profiles.get(UserInfo.getProfileId()).Name;
                update gs;
                delete a1;
            }
        }
        catch(Exception exc)
        {
            system.debug('!!! Unexpected Attachment Error !!! '+exc);
        }
        
        // try to delete the Email Message
        try
        {
            delete e1;
        }
        catch(Exception exc)
        {
            system.debug('!!! Expected Email Message Error !!! '+exc);
        }
        
        try 
        {
            // if the Email Message was not deleted, add the current Profile Name to the list of Profiles that have permission
            // to delete and try again
            if(!e1.IsDeleted)
            {
                gs.Email_2_Case_Email_Message_Profiles__c += profiles.get(UserInfo.getProfileId()).Name;
                update gs;
                delete e1;
            }
        }
        catch(Exception exc)
        {
            system.debug('!!! Unexpected Email Message Error !!! '+exc);
        }
    }
}