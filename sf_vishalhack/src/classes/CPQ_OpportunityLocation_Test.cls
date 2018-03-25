//2016-09-22  -vishal.bandari@cdk.com - RQ-07834 : created Class 
//2016-11-23 - ragashalini.koka@cdk.com - Created a new user instead of querying directly from database
@IsTest
public class CPQ_OpportunityLocation_Test 
{
    @testsetup
    public static void setUpData()
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
      
        User userObj = [SELECT Id,Name,BigMachines__Login__c from User Where Id = :usr.Id];
        
        Opportunity oppObj;
        System.runAs(userObj) 
        {
            Account accObj = DS_TestObjects.NewAccount();
            accObj.Name = 'TestAccount 1';
            accObj.Make__c = 'Test Make';
            accObj.OEM__c = 'Test OEM';
            insert accObj;
            oppObj = DS_TestObjects.NewOpportunity();
            oppObj.AccountId = accObj.Id;
            oppObj.Name = 'TestOpportunity 1';
            insert oppObj;
        }
    }
    
    public static testmethod void setBuildingSite()
    {
        Account accObj = [SELECT Id FROM Account WHERE Name = 'TestAccount 1'];
        Opportunity oppObj = [SELECT Id FROM Opportunity WHERE Name = 'TestOpportunity 1'];
        Opportunity_Location__c oppLocSiteObj = [
            SELECT Id 
            FROM Opportunity_Location__c 
            WHERE RecordType.Name = 'Site' 
            AND Site__c =: accObj.Id 
            AND Opportunity__c =: oppObj.Id
        ];
        
        Opportunity_Location__c oppLocObj;
        oppLocObj = new Opportunity_Location__c();
        oppLocObj.Building_Name__c = 'Sample Building';
        oppLocObj.Site__c = accObj.Id;
        oppLocObj.Opportunity__c = oppObj.Id;
        oppLocObj.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Building');
        insert oppLocObj;      
        
        
        oppLocObj = [
            SELECT Id, Building_Site__c 
            FROM Opportunity_Location__c 
            WHERE Id = :oppLocObj.Id 
        ];
        
        System.assertEquals(oppLocSiteObj.Id, oppLocObj.Building_Site__c);
        
        delete oppLocObj;
        
    }
    
    public static testmethod void negativeMethod()
    {
        Account accObj;
        
        User userObj = [SELECT Id, Name, BigMachines__Login__c from User Where Profile.Name Like '%Baseline%' AND Name LIKE '%Test--User%' LIMIT 1];
        Opportunity oppObj;
        System.runAs(userObj) 
        {
            accObj = DS_TestObjects.NewAccount();
            accObj.Name = 'TestAccount 1';
            accObj.Make__c = 'Test Make';
            insert accObj;
            
            oppObj = DS_TestObjects.NewOpportunity();
            oppObj.AccountId = accObj.Id;
            oppObj.Name = 'TestOpportunity 1';
            insert oppObj;
        }

        Opportunity_Location__c oppLocObj = new Opportunity_Location__c();
        oppLocObj.Building_Name__c = 'Sample Building';
        oppLocObj.Site__c = accObj.Id;
        oppLocObj.Opportunity__c = oppObj.Id;
        oppLocObj.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Building');
        List<Database.SaveResult> saveResult;
        try
        {
            test.startTest();
            saveResult = Database.insert(new List<sobject>{oppLocObj}); 
            test.stopTest();
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('No Opportunity Location Site Found with Matching Site and Opportunity Details, Please create Opportunity Location Site first.'));
        }
    }
}