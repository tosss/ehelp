// 2016-02-03 - lalitha.adduru@cdk.com modified the already existing test class - RQ-06386
// 2016-12-27 - ragashalini.koka@cdk.com - added method validateChangesOnTop5Record - RQ-08369
// 2017-03-22 - lalitha.adduru@cdk.com -modified the test class to insert a GlobalSetting record and its corresponding user - RQ-08780
@isTest
public class ALL_User_Test 
{
    @TestSetup
    private static void setupData()
    {
        GlobalSettings__c globalSettings = GlobalSettings__c.getOrgDefaults();
        globalSettings.Admin_Integration_Username__c = 'testadminuser@abc.com';
        upsert globalSettings GlobalSettings__c.Id;
        
        User adminUser= new User(
                    UserName='testadminuser@abc.com', 
                    Email='testadminuser@abc.com', 
                    Alias='teadmin',
                    EmailEncodingKey='UTF-8', 
                    FirstName='Test',
                    LastName='Admin', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=DS_TestObjects.getStandardProfile().Id, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='AdminTest',
                    FederationIDentifier = 'F1testAdmin'
                );
        insert adminUser; 
        
        User currentUser = [
            SELECT ID 
            FROM User 
            WHERE ID = :UserInfo.getUserID()
        ];
        
        Profile adminProfile = DS_TestObjects.getAdminProfile();
        ID adminProfileID = adminProfile != null ? adminProfile.ID : null;
        
     	Contact newContact = DS_TestObjects.NewContact_Inserted();
        
        system.runAs(currentUser)
        {            
            List<User> userList = New List<User>();
            List<User> managerList = New List<User>();
            List<Employee_Information__c> empinforList = New List<Employee_Information__c>();
            List<Employee_Information__c> empinfomanagerList = New List<Employee_Information__c>();           
            Profile standardProfile = DS_TestObjects.getStandardProfile();
            
            for(Integer i = 0; i < 2; i++) 
            {
                // pulled out of DS_TestObjects due to an error:
                //   DUPLICATE_USERNAME, Duplicate Username.
                //   The username already exists in this or another Salesforce organization.
                //   Usernames must be unique across all Salesforce organizations. 
                //   To resolve, use a different username (it doesn't need to match the user's email address).
                String random1 = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
                String randomUserName1 = ALL_UtilitiesRandom.RandomUserName('ALL_User_Test'+String.valueOf(i));
                User managerUser = new User(
                    UserName=randomUserName1, 
                    Email=randomUserName1, 
                    Alias=random1.length()>8 ? random1.substring(4, random1.length()) : random1,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test Manager', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=standardProfile.ID, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='A'+random1,
                    FederationIDentifier = 'F1'+random1
                );

                managerUser.Title = 'TestManager';
                managerUser.Street = '1950 Hassel Rd';
                managerUser.City = 'Hoffman Estates';
                managerUser.MobilePhone = '5555554444';
                managerUser.PostalCode = '60169';
                managerUser.State = 'IL';
                managerUser.Country = 'USA';
                managerUser.Phone = '5555554444';
                managerUser.Fax = '5555554444';
                managerUser.Extension = '3344';
                managerUser.ProfileID = adminProfileID;
                
                managerList.add(managerUser);
            }
            
            insert managerList;
            
            for(Integer i = 0; i < 10; i++) 
            {
                // pulled out of DS_TestObjects due to an error:
                // DUPLICATE_USERNAME, Duplicate Username.
                // The username already exists in this or another Salesforce organization.
                // Usernames must be unique across all Salesforce organizations. 
                // To resolve, use a different username (it doesn't need to match the user's email address).
                String increment2 = String.valueOf( i + managerList.size() );
                String random2 = ALL_UtilitiesRandom.trueRandomUpToAMillion();
                String randomUserName2 = ALL_UtilitiesRandom.randomUserName('ALL_User_Test'+increment2);
                User tempUser = new User(
                    UserName=randomUserName2, 
                    Email=randomUserName2, 
                    Alias=random2.length()>8?random2.substring(4, random2.length()):random2,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=standardProfile.ID, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='A'+random2,
                    FederationIDentifier = 'F1'+random2,
                    Hire_date__c = Date.today(),
                    ManagerID = managerList[0].ID,
                    Non_Interactive_User__c=false
                );
                
                if(i==0)
                {
                    User duplicateUser = new User(
                        UserName='Dup_'+randomUserName2, 
                        Email=randomUserName2, 
                        Alias=random2.length()>8 ? random2.substring(4, random2.length()) : random2,
                        EmailEncodingKey='UTF-8', 
                        FirstName='Apex',
                        LastName='Test User retired', 
                        LanguageLocaleKey='en_US', 
                        LocaleSIDKey='en_US', 
                        profileid=standardProfile.ID, 
                        TimeZoneSIDKey='America/Chicago',
                        EMP_Contact__c = newContact.id,
                        ADID__c='Dup A'+random2,
                        FederationIDentifier = '__F1'+random2,
                        isActive=true,
                        ManagerID = managerList[0].ID,
                        Non_Interactive_User__c=true
                    );
                    userList.add(duplicateUser);
                }
                userList.add(tempUser);
            }
            
            insert userList;
            
            for (Integer i = 0; i < managerList.size(); i++) 
            {
                empinfomanagerList.add(
                    new Employee_Information__c(
                        Name = managerList[i].FirstName + '' + managerList[i].LastName,
                        work__c = managerList[i].Phone,
                        Ext__c = managerList[i].Extension,
                        Fax__c = managerList[i].Fax,
                        Mobile__c = managerList[i].MobilePhone,
                        User__c = managerList[i].ID,
                        address__c = managerList[i].Street,
                        City__c = managerList[i].City,
                        State__c = managerList[i].State,
                        Postal__c = managerList[i].PostalCode,
                        Country__c = managerList[i].Country)
                );
            }
            
            insert empinfomanagerList;
            
            for (Integer i = 0; i < userList.size(); i++) 
            {
                empinforList.add(
                    new Employee_Information__c(
                        Name = userList[i].firstname + '' + userList[i].Lastname,
                        work__c = userList[i].Phone,
                        Ext__c = userList[i].Extension,
                        //E_Mail__c = userList[i].Email,
                        Fax__c = userList[i].Fax,
                        Mobile__c = userList[i].MobilePhone,
                        user__C = userList[i].id,
                        address__c = userList[i].Street,
                        City__c = userList[i].City,
                        State__c = userList[i].State,
                        Postal__c = userList[i].PostalCode,
                        Manager__c = empinfomanagerList[0].ID,
                        Country__c = userList[i].Country)
                );
            }
            
            insert empinforList;
            
            PermissionSet permObj1 = new PermissionSet();
            permObj1.Description='Test Description';
            permObj1.Label='Test Permission Set';
            permObj1.Name='TestPermissionSet1';
            insert permObj1; 
            
            Group groupObj1 = new Group();
            groupObj1.Name = 'Test Group1';
            groupObj1.DeveloperName='TestGroup1';
            groupObj1.DoesIncludeBosses = false;
            groupObj1.Type='Regular';
            insert groupObj1;
            
            List<Assign_PermissionSets__c> customSettingList = new List<Assign_PermissionSets__c>();
            Assign_PermissionSets__c customSettingObj1 = new Assign_PermissionSets__c();
            customSettingObj1.Name='Record 1';
            customSettingObj1.Field_Name__c='Title';
            customSettingObj1.Field_Value__c='Salesforce Developer';
            customSettingObj1.Operator__c='==';
            customSettingObj1.Group_ID__c=groupObj1.ID;
            customSettingObj1.Data_Type__c='String';
            customSettingObj1.Grouping_ID_Group__c='Group 1';
            customSettingList.add(customSettingObj1);
            
            Assign_PermissionSets__c customSettingObj2 = new Assign_PermissionSets__c();
            customSettingObj2.Name='Record 2';
            customSettingObj2.Field_Name__c='Department';
            customSettingObj2.Field_Value__c='Sales Automation';
            customSettingObj2.Group_ID__c=groupObj1.id;
            customSettingObj2.Operator__c='==';
            customSettingObj2.PermissionSet_ID__c=permObj1.ID;
            customSettingObj2.Data_Type__c='String';
            customSettingObj2.Grouping_ID_Permission_Set__c='Group 1';
            customSettingObj2.Grouping_ID_Group__c='Group 2';
            customSettingList.add(customSettingObj2);
            
            Assign_PermissionSets__c customSettingObj3 = new Assign_PermissionSets__c();
            customSettingObj3.Name='Record 3';
            customSettingObj3.Field_Name__c='Title';
            customSettingObj3.Field_Value__c='Salesforce Developer';
            customSettingObj3.Operator__c='==';
            customSettingObj3.PermissionSet_ID__c=permObj1.ID;
            customSettingObj3.Data_Type__c='String';
            customSettingObj3.Grouping_ID_Permission_Set__c='Group 1';
            customSettingList.add(customSettingObj3);   
            
            Assign_PermissionSets__c customSettingObj4 = new Assign_PermissionSets__c();
            customSettingObj4.Name='Record 4';
            customSettingObj4.Field_Name__c='EmployeeNumber';
            customSettingObj4.Field_Value__c='1111';
            customSettingObj4.Operator__c='>=';
            customSettingObj4.Group_ID__c=groupObj1.id;
            customSettingObj4.Data_Type__c='String';
            customSettingObj4.Grouping_ID_Group__c='Group 3';
            customSettingList.add(customSettingObj4);
            
            Assign_PermissionSets__c customSettingObj5 = new Assign_PermissionSets__c();
            customSettingObj5.Name='Record 5';
            customSettingObj5.Field_Name__c='Non_Interactive_User__c';
            customSettingObj5.Field_Value__c='FALSE';
            customSettingObj5.Operator__c='==';
            customSettingObj5.PermissionSet_ID__c=permObj1.ID;
            customSettingObj5.Data_Type__c='String';
            customSettingObj5.Grouping_ID_Permission_Set__c='Group 2';
            customSettingList.add(customSettingObj5);
            
            Assign_PermissionSets__c customSettingObj6 = new Assign_PermissionSets__c();
            customSettingObj6.Name='Record 6';
            customSettingObj6.Field_Name__c='Contractor__c';
            customSettingObj6.Field_Value__c='FALSE';
            customSettingObj6.Operator__c='==';
            customSettingObj6.PermissionSet_ID__c=permObj1.ID;
            customSettingObj6.Data_Type__c='String';
            customSettingList.add(customSettingObj6);
            
            Assign_PermissionSets__c customSettingObj7 = new Assign_PermissionSets__c();
            customSettingObj7.Name='Record 7';
            customSettingObj7.Field_Name__c='Contractor__c';
            customSettingObj7.Field_Value__c='FALSE';
            customSettingObj7.Operator__c='==';
            customSettingObj7.Group_ID__c=groupObj1.id;
            customSettingObj7.Data_Type__c='String';
            customSettingList.add(customSettingObj7);
            
            insert customSettingList;
            
            Date myDate = Date.today().addDays(-1);
            EMP_User_HireDate__c defaultHireDate = new EMP_User_HireDate__c(SetupOwnerID = Userinfo.getOrganizationID(), Hire_Date__c = myDate);
            insert defaultHireDate;
            
            //2016-12-27  ragashalini.koka@cdk.com  RQ-08369 - Added Account Top_5__c Record
            Account acc = DS_TestObjects.NewAccount_Inserted();
            Top_5__c top5Rec = new Top_5__c();
            top5Rec.OwnerId = userList[0].Id;
            top5Rec.Account__c = acc.Id;
            top5Rec.Status__c = 'Green';
            top5Rec.Comments__c = 'Test Comments';
            insert top5Rec;
        }
    }
    
    private static testmethod void testAllUserHandler()
    {
        Map<ID, User> newUserMap = new Map<ID, User>([
            SELECT ID, Email, phone, Title, Extension, MobilePhone, Department, EmployeeNumber, fax, city, state, PostalCode, Country, firstName, LastName,
            federationIdentifier, Non_Interactive_User__c, IsActive, Street, Name, Contractor__c, Non_Employee__c, Hire_Date__c, managerID
            FROM User 
            WHERE firstName = 'Apex' AND LastName = 'Test User'
        ]);
        
        //ALL_User_Handler.beforeInsert(newUserMap.values());
        test.startTest();
        ALL_User_Handler.afterInsert(newUserMap);
        test.stopTest();
        
        Map<id,User> oldUserMap = new Map<ID, User>();
        for(User newUser : newUserMap.values())
        {
            User tempUser = newUser.clone(false, true);
            tempUser.id = null;
            oldUserMap.put(newUser.id, tempUser);
            newUser.firstName = 'modified firstName';
            newUser.LastName = 'modified Last Name';
        }
        
        ALL_User_Handler.beforeUpdate(newUserMap, oldUserMap);
        ALL_User_Handler.afterUpdate(newUserMap, oldUserMap);
        
        oldUserMap.clear();
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
            newUser.firstName = 'modified firstNameUser';
            newUser.LastName = 'modified Last NameUser';
            newUser.Contractor__c = true;
            newUser.Non_Employee__c = true;
            newUser.Non_Interactive_User__c  = false;
            newUser.IsActive = true;
            newUser.ManagerID = null;
        }
        
        ALL_User_Handler.afterUpdate(newUserMap, oldUserMap);
        
        Boolean DateTimeLessThan = ALL_User_Handler.checkCondition(DateTime.now().format(), '<', DateTime.now().addDays(1), 'DateTime'); 
        
        Boolean DateTimeGreaterThan = ALL_User_Handler.checkCondition(DateTime.now().format(), '>', DateTime.now().addDays(1), 'DateTime');
        
        Boolean DateTimeLessThanEqual = ALL_User_Handler.checkCondition(DateTime.now().format(), '<=', DateTime.now(), 'DateTime');
        
        Boolean DateTimeGreaterThanEqual = ALL_User_Handler.checkCondition(DateTime.now().format(), '>=', DateTime.now(), 'DateTime');
        
        Boolean DateLessThan = ALL_User_Handler.checkCondition(Date.today(), '<', Date.today().addDays(1), 'Date');
        
        Boolean DateGreaterThan = ALL_User_Handler.checkCondition(Date.today(), '>', Date.today().addDays(1), 'Date');
        
        Boolean DateLessThanEqual = ALL_User_Handler.checkCondition(Date.today(), '<=', Date.today().addDays(1), 'Date');
        
        Boolean DateGreaterThanEqual = ALL_User_Handler.checkCondition(Date.today(), '>=', Date.today().addDays(1), 'Date'); 
        
        Boolean IntegerLessThan = ALL_User_Handler.checkCondition(1, '<', 2, 'Integer');
        
        Boolean IntegerGreaterThan = ALL_User_Handler.checkCondition(1, '>', 2, 'Integer');
        
        Boolean IntegerLessThanEqual = ALL_User_Handler.checkCondition(1, '<=', 1, 'Integer');
        
        Boolean IntegerGreaterThanEqual = ALL_User_Handler.checkCondition(1, '>=', 1, 'Integer');
        
        Boolean StringEqual = ALL_User_Handler.checkCondition('1', '==', '1', 'String');
        
        Boolean StringNotEqual = ALL_User_Handler.checkCondition('1', '!=', '2', 'String');
    }
    
    // 2016-12-27 - ragashalini.koka@cdk.com - added method validateChangesOnTop5Record - RQ-08369
    private static testmethod void validateChangesOnTop5Record() 
    {
        Top_5__c top5Rec = [SELECT Id, OwnerId, Owner_Manager__c, Owner_Manager_Mgr__c FROM Top_5__c LIMIT 1];
        User usr1 = [SELECT Id,Name FROM User WHERE Id != :top5Rec.OwnerId AND ManagerId=null LIMIT 1  ];
        Test.startTest();
        User usr2 = new User();
        usr2.Id = top5Rec.OwnerId;
        usr2.ManagerId = usr1.Id;
        update usr2;
       
        Test.stopTest();
        top5Rec = [SELECT Id, OwnerId, Owner_Manager__c, Owner_Manager_Mgr__c FROM Top_5__c WHERE Id=:top5Rec.Id];
     
        System.assertEquals(usr1.Id, top5Rec.Owner_Manager__c, 'Incorrect Manager field in Top5 Record');
        System.assertEquals(null, top5Rec.Owner_Manager_Mgr__c, 'Incorrect Manager Mgr field in Top5 Record');
    }
}