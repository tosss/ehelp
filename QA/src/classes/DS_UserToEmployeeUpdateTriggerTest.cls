@IsTest
public class DS_UserToEmployeeUpdateTriggerTest 
{ 
    static testMethod void testUserUpdate() 
    {
        User thisUser = [select Id from User where Id =  : UserInfo.getUserId()];
        Profile Pro = DS_TestObjects.getAdminProfile();
        ID PId = Pro != null ? Pro.Id : null;
        
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
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=p.Id, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='A'+Random1,
                    FederationIdentifier = 'F1'+Random1
                ); 
                
                ManagerUser.Title = 'TestUser';
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

            User Manager1 = ManagerList[0];
            User Manager2 = ManagerList[1];
            
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
                ); insert TempUser;
                
                TempUser.Title = 'TestUser';
                TempUser.Street = '1950 Hassel Rd';
                TempUser.City = 'Hoffman Estates';
                TempUser.MobilePhone = '5555554444';
                TempUser.PostalCode = '60169';
                TempUser.State = 'IL';
                TempUser.Country = 'USA';
                TempUser.Phone = '5555554444';
                TempUser.Fax = '5555554444';
                TempUser.Extension = '3344';
                TempUser.ProfileId = PId;
                UserList.add(TempUser);
            }
            
            update UserList; //insert UserList; // 10/1
            System.debug('UserList-------' + UserList);

            Test.startTest();
            
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
            
            for (Integer i = 0; i < UserList.size(); i++) {
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
			
            Test.stoptest();
            insert empinforList;
			
            for(Integer i = 0; i < UserList.size(); i++) {
                UserIdList.add(UserList[i].Id);
            }
            
            System.debug('UserIdList-----' + UserIdList);
            System.debug(UserList.size());
			
            List<User> QueriedUsers = New List<User>([
                SELECT Id, FirstName, lastname, username, alias, 
                	title, Street, City, State, Country, Phone, 
                	Email, Extension, Fax, MobilePhone, PostalCode
                FROM User
                WHERE id
                IN : UserIdList
            ]);
			
            List<User> UsersToUpdate = New List<User>();
            
            for(Integer i = 0; i < QueriedUsers.size(); i++) 
            {
                String UpdateIncrement = String.valueOf( i + ManagerList.size() + UserList.size() );
                String UpdateRandom = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
                String UpdateRandomUserName = ALL_UtilitiesRandom.RandomUserName('DS_UserToEmployeeUpdateTriggerTest'+UpdateIncrement);
                
                QueriedUsers[i].Username = UpdateRandomUserName;
                QueriedUsers[i].Email = UpdateRandomUserName;
                QueriedUsers[i].FirstName = 'Test' + i;
                QueriedUsers[i].LastName = 'User' + i;
                QueriedUsers[i].Title = 'TestUser';
                QueriedUsers[i].Street = '1950 Hassel Rd.';
                QueriedUsers[i].City = 'Hoffman Estates';
                QueriedUsers[i].MobilePhone = '1234567890';
                QueriedUsers[i].PostalCode = '1234' + i;
                QueriedUsers[i].State = 'IL';
                QueriedUsers[i].Country = 'USA';
                QueriedUsers[i].alias = 't' + i;
                QueriedUsers[i].Phone = '234234234' + i;
                QueriedUsers[i].Fax = '345345345' + i;
                QueriedUsers[i].Extension = '3344';
                QueriedUsers[i].ADID__c = 'tuser' + i;
                QueriedUsers[i].ManagerId = Manager2.Id;
                
                UsersToUpdate.add(QueriedUsers[i]);
            }
			
            update UsersToUpdate;
        }
    }
}