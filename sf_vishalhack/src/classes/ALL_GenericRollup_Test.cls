//Author: Anirudh Singh
//Description: This is a generic class for Rollup the Child to Parent.
//Dated: 2015-08-04
//2016-10-10 - venkata.shrivol@cdk.com	- changed the profile name from 'LFD' to 'FFC - Forms' inside query on profile
@isTest
public class ALL_GenericRollup_Test
{
    @TestSetup
    private static void setupTestData()
    {
        /*For testing genericConcatenateRollUp method- Strings.*/
        List<Account> accountList=new List<Account>();
        for(Integer i=0; i<10; i++)
        {
            Account accRec=new Account();
            accRec.Name='Acc Test '+i;
            accountList.add(accRec);
        }
        insert accountList;
        
        List<Contact> contactList=new List<Contact>();
        for(Account accRec: accountList)
        {
            for(Integer i=0; i<10; i++)
            {
                Contact con=new Contact();
                con.FirstName='Con ';
                con.LastName='Test '+i;
                con.AccountId=accRec.Id;
                contactList.add(con);
            }
        }
        insert contactList;
        /*For testing genericConcatenateRollUp method- Strings.*/
        
        
        /*For testing genericCountRollUp method.*/
        List<EMP_Policy__c> policyRecords=new List<EMP_Policy__c>();
        
        for(Integer i=0; i<contactList.size(); i++)
        {
            for(Integer j=0; j<4; j++)
            {
                EMP_Policy__c policyRec=new EMP_Policy__c();
                policyRec.Name='Admin '+i;
                policyRec.Employee_Contact__c=contactList[i].Id;
                if(i==j)
                {
                    policyRec.Acknowledgement_Status__c=true;
                }
                policyRecords.add(policyRec);
            }
        }
        insert policyRecords;
        /*For testing genericCountRollUp method.*/
        
        
        /*For testing genericSumRollUp method.*/
        Account acc=DS_TestObjects.NewAccount();
        insert acc;
        
        Contact cont=new Contact();
        cont.FirstName='Con ';
        cont.LastName='Test ';
        cont.AccountId=acc.Id;
        insert cont;
        
        User LAS_User=DS_TestObjects.NewUser();
        LAS_User.ProfileId=[Select Id, Name From Profile Where Name like '%LAS%' Limit 1].Id;
        
        //2016-10-10 - venkata.shrivol@cdk.com	- changed the profile name from 'LFD' to 'FFC - Forms' inside query on profile
        User LFD_User=DS_TestObjects.NewUser();
        LFD_User.ProfileId=[Select Id, Name From Profile Where Name like '%FFC - Forms%' Limit 1].Id;
        
        List<Laser_Artwork_Order__c> laoList=new List<Laser_Artwork_Order__c>();
        for(Integer i=0; i<10; i++)
        {
            Laser_Artwork_Order__c laserArtworkOrder=new Laser_Artwork_Order__c();
            laserArtworkOrder.Artwork_Vision_Case__c='123456789-1';
            laserArtworkOrder.Change_Notes__c='Test Change Notes';
            laserArtworkOrder.Contract_PO__c='12345678';
            laserArtworkOrder.Estimated_Install_Date__c=Date.today();
            laserArtworkOrder.FE_Date__c=Date.today();
            laserArtworkOrder.LAS_Name__c=LAS_User.Id;
            laserArtworkOrder.LFD_Name__c=LFD_User.Id;
            laserArtworkOrder.Order_Priority__c='Standard';
            laserArtworkOrder.Order_Status__c='Sold';
            laserArtworkOrder.Order_Type__c='Buy/Sell - Other';
            laserArtworkOrder.Owner_Email__c='matt_keefe@adp.com';
            laserArtworkOrder.Prev_SO__c='SO# 123';
            laserArtworkOrder.Project__c='00001';
            laserArtworkOrder.Stock_Order__c='Stock #123';
            laserArtworkOrder.Total_Number_of_Forms__c=5;
            laoList.add(laserArtworkOrder);
        }
        insert laoList;
        
        Laser_Ordered_Forms_Catalog_Numbers__c laserCatalogObj=new Laser_Ordered_Forms_Catalog_Numbers__c();
        laserCatalogObj.Category__c='Backer';
        laserCatalogObj.Catalog_Number_Must_Be_Unique__c='1';
        insert laserCatalogObj;
        
        List<Laser_Ordered_Forms__c> lofList=new List<Laser_Ordered_Forms__c>();
        for(Integer i=0; i<laoList.size(); i++)
        {
            Laser_Ordered_Forms__c laserFormObj=new Laser_Ordered_Forms__c();
            laserFormObj.Catalog_Number__c=laserCatalogObj.Id;
            laserFormObj.Quantity__c=i+1;
            laserFormObj.Laser_Artwork_Order__c=laoList[i].Id;
            lofList.add(laserFormObj);
        }
        insert lofList;
        /*For testing genericSumRollUp method.*/
        
        
        /*For testing genericConcatenateRollUp method- Lookups.*/
        List<Request__c> requestList=new List<Request__c>();
        for(Integer i=0; i<10; i++)
        {
            Request__c reqRecord=new Request__c();
            reqRecord.Name='Test Description '+i;
            reqRecord.Details__c='Test Details'+i;
            reqRecord.User_Groups_Impacted__c='ALL';
            reqRecord.User__c=UserInfo.getUserId();
            reqRecord.Deployment_Strategy__c='In FULLDEV Only';
            reqRecord.Status__c='Open';
            reqRecord.Internal_Priority__c='3 Medium';
            requestList.add(reqRecord);
        }
        insert requestList;
        
        List<User> usersList=new List<User>();
        
        List<String> randomNumbersList=new List<String>();
        for(Integer i=0; i<6; i++)
        {
            String randomNum=ALL_UtilitiesRandom.TrueRandomUpToAMillion();
            randomNumbersList.add(randomNum);
        }
        
        List<String> randomUserNamesList=new List<String>();
        for(Integer i=0; i<6; i++)
        {
            String randomUserName=ALL_UtilitiesRandom.RandomUserName('RequestTeamMember'+i);
            randomUserNamesList.add(randomUserName);
        }
        
        //List of System Admin Profiles
        List<Profile> adminProfiles=[
            SELECT Id, Name 
            FROM Profile 
            WHERE PermissionsModifyAllData=true AND PermissionsApiEnabled=true AND Name LIKE '%System Administrator%' 
            LIMIT 1
        ];
        
        if(adminProfiles!=Null && !adminProfiles.isEmpty())
        {
            Profile adminProfile=adminProfiles.get(0);
            
            for(Integer i=0; i<6; i++)
            {
                User testUser=new User(
                    UserName=randomUserNamesList[i], 
                    Email=randomUserNamesList[i], 
                    Alias=randomNumbersList[i].length()>8?randomNumbersList[i].substring(4, randomNumbersList[i].length()):randomNumbersList[i],
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User'+i, 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileId=AdminProfile.Id, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='A'+randomNumbersList[i],
                    FederationIdentifier='F'+randomNumbersList[i]
                );
                testUser.putSObject('Profile', adminProfile);
                usersList.add(testUser);
            }
        }
        insert usersList;
        
        //2/2/2016- lalitha.adduru@cdk.com added this to run local tests during deployment RQ-5919 (Temporary)
        //2016-02-19 matt.keefe@cdk.com removed these lines as they are no longer needed (direct reference back in place)
        //Request_Dereference_Fields__c rdf = new Request_Dereference_Fields__c();
        //rdf.QA_Testers_API_Name__c = 'QA_Engineers__c';
        //rdf.Technical_Reviewers_Field_API_Name__c = 'Code_Reviewers__c';
        //insert rdf;
        
        List<Request_Team_Member__c> reqTeamMemList=new List<Request_Team_Member__c>();
        
        List<String> roles=new List<String>();
        roles.add('Business Analyst');
        roles.add('Code Reviewer');
        roles.add('External Developer');
        roles.add('Release Manager');
        roles.add('SF Config Admin');
        roles.add('SF Developer');
        
        for(Integer i=0; i<requestList.size(); i++)
        {
            for(Integer j=0; j<usersList.size(); j++)
            {
                Request_Team_Member__c reqTeamMemRecord = new Request_Team_Member__c();
                reqTeamMemRecord.Request__c = requestList[i].Id;
                reqTeamMemRecord.User__c = usersList[j].Id;
                reqTeamMemRecord.Role__c = roles[j];
                reqTeamMemList.add( reqTeamMemRecord );
            }
        }
        
        
        insert reqTeamMemList;
        /*For testing genericConcatenateRollUp method- Lookups.*/
    }
    
    private static testMethod void testGenericSumRollUp()
    {
        system.debug('Start testGenericSumRollUp---->');
        List<Laser_Ordered_Forms__c> lofList=[SELECT Id, Quantity__c, Laser_Artwork_Order__c FROM Laser_Ordered_Forms__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericSumRollUp(lofList, 'Laser_Artwork_Order__c', 'Forms__r', 'Laser_Artwork_Order__c', 'Total_Number_of_Forms__c', 'Quantity__c', '');
        test.stopTest();
        system.debug('End testGenericSumRollUp---->');
    }
    
    private static testMethod void testGenericSumRollUpWhereCond1()
    {
        system.debug('Start testGenericSumRollUpWhereCond1---->');
        List<Laser_Ordered_Forms__c> lofList=[SELECT Id, Quantity__c, Laser_Artwork_Order__c FROM Laser_Ordered_Forms__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericSumRollUp(lofList, 'Laser_Artwork_Order__c', 'Forms__r', 'Laser_Artwork_Order__c', 'Total_Number_of_Forms__c', 'Quantity__c', 'Quantity__c!=0');
        
        List<Laser_Ordered_Forms__c> lofToDeleteList=new List<Laser_Ordered_Forms__c>();
        lofToDeleteList.add(lofList[4]);
        lofToDeleteList.add(lofList[9]);
        
        database.delete(lofToDeleteList);
        ALL_GenericRollup_Helper.genericSumRollUp(lofList, 'Laser_Artwork_Order__c', 'Forms__r', 'Laser_Artwork_Order__c', 'Total_Number_of_Forms__c', 'Quantity__c', 'Quantity__c!=0');
        test.stopTest();
        system.debug('End testGenericSumRollUpWhereCond1---->');
    }
    
    private static testMethod void testGenericSumRollUpWhereCond2()
    {
        system.debug('Start testGenericSumRollUpWhereCond2---->');
        List<Laser_Ordered_Forms__c> lofList=[SELECT Id, Quantity__c, Laser_Artwork_Order__c FROM Laser_Ordered_Forms__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericSumRollUp(lofList, 'Laser_Artwork_Order__c', 'Forms__r', 'Laser_Artwork_Order__c', 'Total_Number_of_Forms__c', 'Quantity__c', 'WHERE Quantity__c!=0');
        test.stopTest();
        system.debug('End testGenericSumRollUpWhereCond2---->');
    }
    
    private static testMethod void testGenericConcatenateRollUpLookups()
    {
        system.debug('Start testGenericConcatenateRollUpLookups---->');
        List<Request_Team_Member__c> reqTeamMemList=[SELECT Id, Request__c, Role__c, User__c FROM Request_Team_Member__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericConcatenateRollUp(reqTeamMemList, 'Request__c', 'Request_Team_Members__r', 'Request__c', 'All_Request_Team_Members__c', 
                                                          'User__c', 'Name', ',', '');
        test.stopTest();
        system.debug('End testGenericConcatenateRollUpLookups---->');
    }
    
    private static testMethod void testGenericConcatenateRollUpStrings()
    {
        system.debug('Start testGenericConcatenateRollUpStrings---->');
        List<Contact> contactList=[SELECT Id, Name, AccountId FROM Contact];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericConcatenateRollUp(contactList, 'Account', 'Contacts', 'AccountId', 'Description', 'Name', '', ';', '');
        
        List<Contact> contactsToDeleteList=new List<Contact>();
        contactsToDeleteList.add(contactList[4]);
        contactsToDeleteList.add(contactList[9]);
        
        database.delete(contactsToDeleteList);
        ALL_GenericRollup_Helper.genericConcatenateRollUp(contactList, 'Account', 'Contacts', 'AccountId', 'Description', 'Name', '', ';', '');
        test.stopTest();
        system.debug('End testGenericConcatenateRollUpStrings---->');
    }
    
    private static testMethod void testGenericConcatenateRollUpStringsWhereCond1()
    {
        system.debug('Start testGenericConcatenateRollUpStringsWhereCond1---->');
        List<Contact> contactList=[SELECT Id, Name, AccountId FROM Contact];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericConcatenateRollUp(contactList, 'Account', 'Contacts', 'AccountId', 'Description', 'Name', '', ';', 'Status__c!=\'Active\'');
        test.stopTest();
        system.debug('End testGenericConcatenateRollUpStringsWhereCond1---->');
    }
    
    private static testMethod void testGenericConcatenateRollUpStringsWhereCond2()
    {
        system.debug('Start testGenericConcatenateRollUpStringsWhereCond2---->');
        List<Contact> contactList=[SELECT Id, Name, AccountId FROM Contact];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericConcatenateRollUp(contactList, 'Account', 'Contacts', 'AccountId', 'Description', 'Name', '', ';', 'where Status__c!=\'Active\'');
        test.stopTest();
        system.debug('End testGenericConcatenateRollUpStringsWhereCond2---->');
    }
    
    private static testMethod void testGenericCountRollUp()
    {
        system.debug('Start testGenericCountRollUp---->');
        List<EMP_Policy__c> policyList=[SELECT Id, Acknowledgement_Status__c, Employee_Contact__c FROM EMP_Policy__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericCountRollUp(policyList, 'Contact', 'Policies__r', 'Employee_Contact__c', 'Total_Policies__c', '');
        
        List<EMP_Policy__c> policiesToDeleteList=new List<EMP_Policy__c>();
        policiesToDeleteList.add(policyList[3]);
        policiesToDeleteList.add(policyList[10]);
        
        database.delete(policiesToDeleteList);
        
        ALL_GenericRollup_Helper.genericCountRollUp(policyList, 'Contact', 'Policies__r', 'Employee_Contact__c', 'Total_Policies__c', '');
        test.stopTest();
        system.debug('End testGenericCountRollUp---->');
    }
    
    private static testMethod void testGenericCountRollUpWhereCond1()
    {
        system.debug('Start testGenericCountRollUpWhereCond1---->');
        List<EMP_Policy__c> policyList=[SELECT Id, Acknowledgement_Status__c, Employee_Contact__c FROM EMP_Policy__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericCountRollUp(policyList, 'Contact', 'Policies__r', 'Employee_Contact__c', 'Total_Policies__c', 'where Acknowledgement_Status__c=false');
        test.stopTest();
        system.debug('End testGenericCountRollUpWhereCond1---->');
    }
    
    private static testMethod void testGenericCountRollUpWhereCond2()
    {
        system.debug('Start testGenericCountRollUpWhereCond2---->');
        List<EMP_Policy__c> policyList=[SELECT Id, Acknowledgement_Status__c, Employee_Contact__c FROM EMP_Policy__c];
        
        test.startTest();
        
        List<EMP_Policy__c> policiesToUpdateList=new List<EMP_Policy__c>();
        for(EMP_Policy__c policy: policyList)
        {
            if(!policy.Acknowledgement_Status__c)
            {
                policy.Acknowledgement_Status__c=true;
                policiesToUpdateList.add(policy);
            }
        }
        update policiesToUpdateList;
        
        ALL_GenericRollup_Helper.genericCountRollUp(policyList, 'Contact', 'Policies__r', 'Employee_Contact__c', 'Total_Policies__c', 'Acknowledgement_Status__c=false');
        test.stopTest();
        system.debug('End testGenericCountRollUpWhereCond2---->');
    }
}