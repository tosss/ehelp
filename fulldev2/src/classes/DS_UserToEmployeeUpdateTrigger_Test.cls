// 2016-02-03 - lalitha.adduru@cdk.com modified the already existing test class - RQ-06386

@isTest
public class DS_UserToEmployeeUpdateTrigger_Test 
{
    @TestSetUp
    private static void setUp()
    {
        User thisUser = [
            SELECT Id 
            FROM User 
            WHERE Id =  : UserInfo.getUserId()
        ];
        
        Profile Pro = DS_TestObjects.getAdminProfile();
        ID PId = Pro != null ? Pro.Id : null;
        
        Contact newContact = DS_TestObjects.NewContact_Inserted();
        system.runAs(thisUser)
        {
            
            
            List<User> u = new List<User> ();
            List<User> u1 = new List<User> ();
            List<String> UserIdList = New List<String>();
            List<User> UserList = New List<User>();
            List<User> ManagerList = New List<User>();
            List<Employee_Information__c> empinforList = New List<Employee_Information__c>();
            List<Employee_Information__c> empinfoManagerList = New List<Employee_Information__c>();
            
            Profile p = DS_TestObjects.getStandardProfile();
            
            for(Integer i = 0; i < 2; i++) 
            {
                // pulled out of DS_TestObjects due to an error:
                //   DUPLICATE_USERNAME, Duplicate Username.
                //   The username already exists in this or another Salesforce organization.
                //   Usernames must be unique across all Salesforce organizations. 
                //   To resolve, use a different username (it doesn't need to match the user's email address).
                String Random1 = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
                String RandomUserName1 = ALL_UtilitiesRandom.RandomUserName('DS_UserToEmployeeUpdateTriggerTest'+String.valueOf(i));
                User ManagerUser = new User(
                    UserName=RandomUserName1, 
                    Email=RandomUserName1, 
                    Alias=Random1.length()>8?Random1.substring(4, Random1.length()):Random1,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test Manager', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=p.Id, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='A'+Random1,
                    FederationIdentifier = 'F1'+Random1
                );

                ManagerUser.Title = 'TestManager';
                ManagerUser.Street = '1950 Hassel Rd';
                ManagerUser.City = 'Hoffman Estates';
                ManagerUser.MobilePhone = '5555554444';
                ManagerUser.PostalCode = '60169';
                ManagerUser.State = 'IL';
                ManagerUser.Country = 'USA';
                ManagerUser.Phone = '5555554444';
                ManagerUser.Fax = '5555554444';
                ManagerUser.Extension = '3344';
                ManagerUser.ProfileId = PId;
                
                ManagerList.add(ManagerUser);
            }
            
            insert ManagerList;
            
            for(Integer i = 0; i < 10; i++) 
            {
                // pulled out of DS_TestObjects due to an error:
                //   DUPLICATE_USERNAME, Duplicate Username.
                //   The username already exists in this or another Salesforce organization.
                //   Usernames must be unique across all Salesforce organizations. 
                //   To resolve, use a different username (it doesn't need to match the user's email address).
                String Increment2 = String.valueOf( i + ManagerList.size() );
                String Random2 = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
                String RandomUserName2 = ALL_UtilitiesRandom.RandomUserName('DS_UserToEmployeeUpdateTriggerTest'+Increment2);
                User TempUser = new User(
                    UserName=RandomUserName2, 
                    Email=RandomUserName2, 
                    Alias=Random2.length()>8?Random2.substring(4, Random2.length()):Random2,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=p.Id, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='A'+Random2,
                    FederationIdentifier = 'F1'+Random2
                );
                
                if(i==0)
                {
                    User duplicateUser = new User(
                        UserName='Duplicate'+RandomUserName2, 
                        Email=RandomUserName2, 
                        Alias=Random2.length()>8?Random2.substring(4, Random2.length()):Random2,
                        EmailEncodingKey='UTF-8', 
                        FirstName='Apex',
                        LastName='Test User retired', 
                        LanguageLocaleKey='en_US', 
                        LocaleSIDKey='en_US', 
                        profileid=p.Id, 
                        TimeZoneSIDKey='America/Chicago',
                        EMP_Contact__c = newContact.id,
                        ADID__c='Dup A'+Random2,
                        FederationIdentifier = '__F1'+Random2,
                        isActive=true
                    );
                    UserList.add(duplicateUser);
                }
                UserList.add(TempUser);
            }
            
            insert userList;
            
            for (Integer i = 0; i < ManagerList.size(); i++) 
            {
                empinfoManagerList.add(
                    new Employee_Information__c(
                        Name = ManagerList[i].FirstName + '' + ManagerList[i].LastName,
                        work__c = ManagerList[i].Phone,
                        Ext__c = ManagerList[i].Extension,
                        //E_Mail__c = ManagerList[i].Email,
                        Fax__c = ManagerList[i].Fax,
                        Mobile__c = ManagerList[i].MobilePhone,
                        User__c = ManagerList[i].Id,
                        address__c = ManagerList[i].Street,
                        City__c = ManagerList[i].City,
                        State__c = ManagerList[i].State,
                        Postal__c = ManagerList[i].PostalCode,
                        Country__c = ManagerList[i].Country)
                );
            }
            
            insert empinfoManagerList;
            
            for (Integer i = 0; i < UserList.size(); i++) 
            {
                empinforList.add(
                    new Employee_Information__c(
                        Name = UserList[i].firstname + '' + UserList[i].Lastname,
                        work__c = UserList[i].Phone,
                        Ext__c = UserList[i].Extension,
                        //E_Mail__c = UserList[i].Email,
                        Fax__c = UserList[i].Fax,
                        Mobile__c = UserList[i].MobilePhone,
                        user__C = UserList[i].id,
                        address__c = UserList[i].Street,
                        City__c = UserList[i].City,
                        State__c = UserList[i].State,
                        Postal__c = UserList[i].PostalCode,
                        Manager__c = empinfoManagerList[0].Id,
                        Country__c = UserList[i].Country)
                );
            }
            
            insert empinforList;
        }
    }
    
    private static testmethod void testHandler()
    {
        Map<Id, User> newUserMap = new Map<Id, User>([
            SELECT id,phone,Extension,MobilePhone,fax,city,state,PostalCode,Country,firstName,LastName,federationIdentifier
            FROM User 
            WHERE firstName = 'Apex' AND LastName = 'Test User'
        ]);
        
        system.debug('newUserMap -- >'+newUserMap.values());
        DS_UserToEmployeeUpdateTrigger_Handler.preventContactOnNewSalesUser(newUserMap.values()); 
        Map<id,User> oldUserMap = new Map<Id, User>();
        for(User newUser : newUserMap.values())
        {
            User tempUser = newUser.clone(false, true);
            tempUser.id = null;
            oldUserMap.put(newUser.id, tempUser);
            newUser.Title = 'TestUser';
            newUser.Street = '1950 Hassel Rd';
            newUser.City = 'Hoffman Estates';
            newUser.MobilePhone = '5555554444';
            newUser.PostalCode = '60169';
            newUser.State = 'IL';
            newUser.Country = 'USA';
            newUser.Phone = '5555554444';
            newUser.Fax = '5555554444';
            newUser.Extension = '3344';
            newUser.firstName = 'modified firstName';
            newUser.LastName = 'modified Last Name';
        }
        
        DS_UserToEmployeeUpdateTrigger_Handler.UserToEmployee(newUserMap.values(), newUserMap, oldUserMap);
        
               
    }
}