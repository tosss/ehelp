@IsTest
public class DS_UserToEmployeeUpdateTest 
{
    testMethod static void testUserUpdate()
    {
        User u1 = DS_TestObjects.NewUser();
        u1.Title = 'TestUser';
        u1.Street = '1950 Hassel Rd.';
        u1.City = 'Hoffman Estates';
        u1.State = 'IL';
        u1.MobilePhone = '5552342343';
        u1.Fax = '5553453454';
        u1.Extension = '3344';
        u1.Country = 'USA';
        insert u1;
        
	    User QueriedUser = [
            select Id, Street, City, State, Country, Phone, Email, Extension, Fax, MobilePhone, PostalCode 
            from User 
            where id = :u1.Id 
            limit 1
        ];
        
        QueriedUser.Street = '14142 Pheasant';
        QueriedUser.City = 'Orlando Park';
        QueriedUser.State = 'IL';
        QueriedUser.Country = 'USA';
        QueriedUser.Phone = '5552342343';
        QueriedUser.Email = 'test@cdk.com';
        QueriedUser.Extension = '8588';
        QueriedUser.Fax = '9879879888'; 
        QueriedUser.MobilePhone = '7774564565';
        QueriedUser.PostalCode = '60457';
        update QueriedUser;
		
        System.debug('QueriedUser: ' + QueriedUser);
   		
        QueriedUser.City = 'Orlando Park';
        QueriedUser.State = 'MI';
        QueriedUser.Country = 'Mexico';
        QueriedUser.Phone = '5558884455';
        QueriedUser.Email = 'test_user@cdk.com';
        QueriedUser.Extension = '4843';
        QueriedUser.Fax = '9879879876'; 
        QueriedUser.MobilePhone = '2564564565';
        QueriedUser.PostalCode = '40456';
        update QueriedUser;
        
        list<Employee_Information__c> emp = [
            select Id, Name, User__c, Address__c, City__c, State__c 
            from Employee_Information__c 
            where User__c = :u1.Id
        ];
        
        System.debug(emp);
    }
    
}