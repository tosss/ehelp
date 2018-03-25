//2016-07-18 - vishal.bandari@cdk.com - RQ-07371:created the class
//2016-08-10- anirudh.singh@cdk.com- Changed the API Name Opportunity_Site_Building__c to Opportunity_Locatio.n__c for RQ-07569.
//2016-11-21 - venkata.shrivol@cdk.com	- Added a new condition to the user query
//2016-11-23 - ragashalini.koka@cdk.com - Created a new user instead of querying directly from database
@IsTest
public class CPQ_SOWQuestions_Test 
{
    @testsetup
    public static void setupData()
    {
        
        Opportunity_Split_Defaults_Settings__c orgDefaults = new Opportunity_Split_Defaults_Settings__c();
        orgDefaults.AutoKeyRepAdds__c = 'ARM, ERM, NRM';
        orgDefaults.Name = 'Sample';
        orgDefaults.KeyRepChannels__c = 'Baseline, National, Enterprise - Seeman, Enterprise - Carson';
        orgDefaults.InsideInventoryChannels__c = 'Inside Sales, Inventory Sales';
        insert orgDefaults;
        
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name LIKE '%Baseline%' LIMIT 1];
        
        User usr = DS_TestObjects.NewUser();
        usr.FirstName = 'Test--User';
        usr.LastName = '1';
        usr.ProfileId = profileRecord.Id;
        insert usr;
    }
    
    public static testmethod void testWithOpportunitySiteValue()
    {
        User userObj = [SELECT Id, Name, BigMachines__Login__c from User Where Profile.Name Like '%Baseline%' AND Name LIKE '%Test--User%' LIMIT 1];
        System.runAs(userObj) 
        {
            Account accObj1=DS_TestObjects.NewAccount_Inserted();
            Opportunity oppObj1=DS_TestObjects.NewOpportunity();
            oppObj1.AccountId=accObj1.id;
            insert oppObj1;
            
            Opportunity_Location__c oppSite1=new Opportunity_Location__c();
            oppSite1.Building_Name__c = 'Site1';
            Id BuildingId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Building');
            oppSite1.RecordTypeId = BuildingId;
            oppSite1.Site__c=accObj1.Id;
            oppSite1.Opportunity__c=oppObj1.Id;
            insert oppSite1;
            
            List<Opportunity_Location__c> oppSiteList=[
                SELECT Id, Opportunity__c,Site__c, Solution_Design_Building_ID__c, Solution_Design_ID__c
                FROM Opportunity_Location__c
                Order By RecordType.Name
            ];
            
            SOW_Question__c sqObj=new SOW_Question__c();
            sqObj.Opportunity_Site_Building_ID__c=oppSiteList[0].Id;
            insert sqObj;
            
            sqObj=[
                SELECT Id, Opportunity__c, Site__c, Solution_Design_Building_ID__c, Solution_Design_ID__c, Opportunity_Site_Building_ID__c
                FROM SOW_Question__c 
                WHERE Id =: sqObj.Id 
            ];
            
            Id idValue=sqObj.Id;
            System.assertEquals(sqObj.Opportunity__c, oppSiteList[0].Opportunity__c);
            System.assertEquals(sqObj.Site__c, oppSiteList[0].Site__c);
            System.assertEquals(sqObj.Solution_Design_Building_ID__c, oppSiteList[0].Solution_Design_Building_ID__c);
            System.assertEquals(sqObj.Solution_Design_ID__c, oppSiteList[0].Solution_Design_ID__c);
            
            Map<Id,SOW_Question__c> sowMap=new Map<Id,SOW_Question__c>();
            sowMap.put(sqObj.Id,sqObj);
            
            sqObj=new SOW_Question__c();
            sqObj.Opportunity_Site_Building_ID__c=oppSiteList[1].Id;
            sqObj.Id=idValue;
            
            List<SOW_Question__c> sowList=new List<SOW_Question__c>();
            sowList.add(sqObj);
            
            CPQ_SOWQuestions_Handler.beforeUpdate(sowList, sowMap);
            
            System.assertEquals(sqObj.Opportunity__c, oppSiteList[1].Opportunity__c);
            System.assertEquals(sqObj.Site__c, oppSiteList[1].Site__c);
            System.assertEquals(sqObj.Solution_Design_Building_ID__c, oppSiteList[1].Solution_Design_Building_ID__c);
            System.assertEquals(sqObj.Solution_Design_ID__c, oppSiteList[1].Solution_Design_ID__c);   
        }
        
    }
    
    public static testmethod void testWithOutOpportunitySiteValue()
    {
      User userObj = [SELECT Id, Name, BigMachines__Login__c from User Where Profile.Name Like '%Baseline%' AND Name LIKE '%Test--User%' LIMIT 1];
         System.runAs(userObj) 
        {
            Account accObj2=DS_TestObjects.NewAccount_Inserted();
            
            Opportunity oppObj2=DS_TestObjects.NewOpportunity();
            oppObj2.AccountId=accObj2.id;
            insert oppObj2;
            
            
            Opportunity_Location__c oppSite2=new Opportunity_Location__c();
            oppSite2.Building_Name__c = 'Site2';
            oppSite2.Site__c=accObj2.Id;
            oppSite2.Opportunity__c=oppObj2.Id;
            Id BuildingId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Building');
            oppSite2.RecordTypeId = BuildingId;
            insert oppSite2;
            List<Opportunity_Location__c> oppSiteList=[
                SELECT Id, Opportunity__c, Site__c 
                FROM Opportunity_Location__c
                Order By RecordType.Name
            ];
            
            SOW_Question__c sqObj=new SOW_Question__c();
            sqObj.Opportunity__c=oppSiteList[0].Opportunity__c;
            sqObj.Site__c=oppSiteList[0].Site__c;
            insert sqObj;
            
            sqObj=[
                SELECT Id, Opportunity__c, Site__c, Solution_Design_Building_ID__c, Solution_Design_ID__c, Opportunity_Site_Building_ID__c
                FROM SOW_Question__c
                WHERE Id =: sqObj.Id 
            ];
            //System.assertEquals(sqObj.Opportunity_Site_Building_Id__c, oppSiteList[0].Id);
        }
    }
}