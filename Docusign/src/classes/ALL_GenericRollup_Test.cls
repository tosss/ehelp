//Author: Anirudh Singh
//Description: This is a generic class for Rollup the Child to Parent.
//Dated: 2015-08-04
@isTest
public class ALL_GenericRollup_Test
{
    @TestSetup
    private static void setupTestData()
    {
        //For testing genericSumRollUp method.
        Account acc=DS_TestObjects.NewAccount();
        insert acc;
        
        Contact cont=new Contact();
        cont.FirstName='Con ';
        cont.LastName='Test ';
        cont.AccountId=acc.Id;
        insert cont;
        
        List<Laser_Artwork_Order__c> laoList=new List<Laser_Artwork_Order__c>();
        for(Integer i=0; i<10; i++)
        {
            Laser_Artwork_Order__c laoRef=IMP_TestFactory_Helper.buildLaserArtworkOrder(cont.Id);
            laoList.add(laoRef);
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
        
        //For testing genericConcatenateRollUp method- Lookups.
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
                Request_Team_Member__c reqTeamMemRecord=new Request_Team_Member__c();
                reqTeamMemRecord.Request__c=requestList[i].Id;
                reqTeamMemRecord.User__c=usersList[j].Id;
                reqTeamMemRecord.Role__c=roles[j];
                reqTeamMemList.add(reqTeamMemRecord);
            }
        }
        insert reqTeamMemList;
        
        //For testing genericConcatenateRollUp method- Strings.
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
    }
    
    private static testMethod void testGenericSumRollUp()
    {
        system.debug('Start testGenericSumRollUp---->');
        List<Laser_Ordered_Forms__c> lofList=[SELECT Id, Quantity__c, Laser_Artwork_Order__c FROM Laser_Ordered_Forms__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericSumRollUp(lofList, 'Laser_Artwork_Order__c', 'Laser_Artwork_Order__c', 'Total_Number_of_Forms__c', 'Quantity__c');
        test.stopTest();
        system.debug('End testGenericSumRollUp---->');
    }
    
    private static testMethod void testGenericConcatenateRollUpLookups()
    {
        system.debug('Start testGenericConcatenateRollUpLookups---->');
        List<Request_Team_Member__c> reqTeamMemList=[SELECT Id, Request__c, Role__c, User__c FROM Request_Team_Member__c];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericConcatenateRollUp(reqTeamMemList, 'Request__c', 'Request__c', 'All_Request_Team_Members__c', 'User__c', ',');
        test.stopTest();
        system.debug('End testGenericConcatenateRollUpLookups---->');
    }
    
    private static testMethod void testGenericConcatenateRollUpStrings()
    {
        system.debug('Start testGenericConcatenateRollUpStrings---->');
        List<Contact> contactList=[SELECT Id, Name, AccountId FROM Contact];
        
        test.startTest();
        ALL_GenericRollup_Helper.genericConcatenateRollUp(contactList, 'Account', 'AccountId', 'Description', 'Name', ';');
        test.stopTest();
        system.debug('End testGenericConcatenateRollUpStrings---->');
    }
}