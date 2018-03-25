/**
 * This class was automatically created (from SFDC) when Customer Portal (Community) was turned on. 
 * If errors occur we may consider deleting it because it is generally not used.
 */
//2015-11-30 : vishal.bandari@cdk.com - RQ-05289:changed testSave method to add contact record type
@IsTest 
public with sharing class MyProfilePageControllerTest 
{
    static testmethod void testSetContactFields() 
    {
        User u = [
            select title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
            FROM User 
            WHERE id =: UserInfo.getUserId()
        ];

        Contact c = new Contact();

        MyProfilePageController.setContactFields(c, u);
    }
    
    static testmethod void testSave() 
    {
        // Modify the test to query for a portal user that exists in your org
        Profile P = DS_TestObjects.getStandardProfile();
        Id CustomerPortalProfileId = P != null ? P.Id : null;
        
        User u = new User(
            UserName='test-49847561573775159@cdk.com',
            Email='test-9234856347896523@cdk.com', 
            Alias='a89485',
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=CustomerPortalProfileId, 
            TimeZoneSIDKey='America/Chicago',
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            ADID__c='testus',
            FederationIdentifier = 'F19857'
        );
        
        List<User> existingPortalUsers = new list<User>{u};
        
        if (existingPortalUsers.isEmpty()) 
        {
            User currentUser = [
                select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                FROM User 
                WHERE id =: UserInfo.getUserId()
            ];
            
            MyProfilePageController controller = new MyProfilePageController();
            
            controller.edit();
            controller.cancel();

            Contact c = new Contact();
            c.LastName = 'TestContact';
            //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
            c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Internal HR Contact');
            insert c;

            c.title = currentUser.title;
            c.firstname = currentUser.firstname;
            c.lastname = currentUser.lastname;
            c.email = currentUser.email;
            c.phone = currentUser.phone;
            c.mobilephone = currentUser.mobilephone;
            c.fax = currentUser.fax;
            c.mailingstreet = currentUser.street;
            c.mailingcity = currentUser.city;
            c.mailingstate = currentUser.state;
            c.mailingpostalcode = currentUser.postalcode;
            c.mailingcountry = currentUser.country;
            controller.save();
        } 
        else 
        {
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';

            System.runAs(existingPortalUser) 
            {
                MyProfilePageController controller = new MyProfilePageController();
                
                controller.edit();
                controller.getIsEdit();

                controller.cancel();

                controller.getUser().Fax = randFax;
                controller.save();
                
                controller.changePassword();
            }

            // verify that the user and contact were updated
            existingPortalUser = [Select id, fax, Contact.Fax from User where id =: existingPortalUser.Id];
        }
    }
}