//2015-11-27 : vishal.bandari@cdk.com    RQ-05289:changed method DS_LSR_LAO_Owner_ChangeTestClass to add contact record type
//2015-01-06 : vishal.bandari@cdk.com    changed email ids from adp to cdk
//2016-06-10- ragashalini.koka@cdk.com  moved Role__c from Contact to Contact_Relationship__c and added code to increase the code coverage.
@isTest
public class DS_LSR_LAO_Owner_ChangeTestClass 
{
    testMethod static void DS_LSR_LAO_Owner_ChangeTestClass()
    {
        User testOwner = [select Id, email from User where IsActive = true limit 1];
        
        Profile P = DS_TestObjects.getAdminProfile();
        List<User> userList = new List<User>();
        for(Integer i = 0;i < 2;i++) {
            User laoOwner = new User();
            laoOwner.Firstname = 'Test';
            laoOwner.Lastname = 'User';
            laoOwner.Title = 'TestUser';
            laoOwner.Street = '1950 Hassel Rd.';
            laoOwner.City = 'Hoffman Estates';
            laoOwner.State = 'IL';
            laoOwner.Username = 'tuser' + i + '@cdk.com';
            laoOwner.email = 'test@cdk.com';
            laoOwner.alias = 'testuser';
            laoOwner.MobilePhone = '2342342343';
            laoOwner.Fax = '3453453454';
            laoOwner.Extension = '3344';
            laoOwner.Country = 'USA';
            laoOwner.TimeZoneSidKey = 'America/Chicago';
            laoOwner.LocaleSidKey = 'en_US';
            laoOwner.EmailEncodingKey = 'ISO-8859-1';
            laoOwner.ProfileId = P != null ? P.id : null;
            laoOwner.LanguageLocaleKey = 'en_US';
            laoOwner.ADID__c = 'testus' + i;
            userList.add(laoOwner);
        }
        
        insert userList;
        
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        
        Contact laoContact = new Contact();
        laoContact.FirstName = 'Tom';
        laoContact.Lastname = 'Smith';
        laoContact.Title__c = 'Technician';
        laoContact.Department__c = 'IT Systems';
        laoContact.AccountId = acc.Id;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        laoContact.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        //2016-06-15- ragashalini.koka@cdk.com- Added the below line for using ALL_SharedContacts_Helper for inserting Contact.
        ALL_SharedContact_Helper.insertContact(laoContact, 'Test Role', null, null);
        
        //2016-06-15- ragashalini.koka@cdk.com- Commented the below two lines as Role field is no longer present on Contact.
        //laoContact.Role__c = 'Test Role'; // 9/29
        //insert laoContact;
        
        system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ID From inserting Contact - ' + laoContact.id + ' - End of string');
        
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.OwnerId = userList[0].Id;
        lao.Total_Number_of_Forms__c = 10;
        lao.Stock_Order__c = '232333';
        lao.Stock_Order_Total__c = 600.00;
        lao.Prev_SO__c = '678909';
        lao.Order_Type__c = 'New Install - Other';
        lao.Order_Status__c = 'Approved';
        lao.Order_Priority__c = 'Standard';
        lao.Contract_PO__c = '123123';
        lao.Contact__c = laoContact.id;
        lao.Change_Notes__c = 'Notes added through test class';
        insert lao;
        
        lao.OwnerId = userList[1].Id;
        update lao;
    }
}