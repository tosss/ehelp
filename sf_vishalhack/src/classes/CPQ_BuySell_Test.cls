//2016-10-13  ragashalini.koka@cdk.com - Created this class for the RQ-07918
@isTest
public class CPQ_BuySell_Test {
    
    @testSetup static void setupTestData() {
       
        Opportunity_Split_Defaults_Settings__c orgDefaults = new Opportunity_Split_Defaults_Settings__c();
        orgDefaults.AutoKeyRepAdds__c = 'ARM, ERM, NRM';
        orgDefaults.Name = 'Sample';
        orgDefaults.KeyRepChannels__c = 'Baseline, National, Enterprise - Seeman, Enterprise - Carson';
        orgDefaults.InsideInventoryChannels__c = 'Inside Sales, Inventory Sales';
        insert orgDefaults;
        
        User userObj = [SELECT Id from User Where Profile.Name Like '%Baseline%' and IsActive = true  LIMIT 1];
       
        Opportunity oppObj;
        System.runAs(userObj) 
        {
            List<Account> accList  = new List<Account>();
            Account accObj1 = DS_TestObjects.NewAccount();
            accObj1.Name = 'Test Acc1';
            accObj1.Key_Rep__c = userobj.Id;
            accList.add(accObj1);
            Account accObj2 = DS_TestObjects.NewAccount();
            accObj2.Name = 'Test Acc2';
            accObj2.Key_Rep__c = userobj.Id;
            accList.add(accObj2);
            insert accList;
            Account_Team__c accTeam = new Account_Team__c();
            accTeam.Account__c = accObj1.Id;
            accTeam.Team_Member__c = userObj.Id;
            accTeam.Account_Access__c = 'Read/Write';
            accTeam.Team_Role__c = 'Forecasting Baseline - Rep';
            accTeam.Opportunity_Access__c = 'Read/Write';
            accTeam.Case_Access__c = 'Private';
            insert accTeam;
            accTeam = new Account_Team__c();
            accTeam.Account__c = accObj1.Id;
            User insideSales = [Select Id from User Where  IsActive = true and Forecasting_Channel__c != null Limit 1];
           
            accTeam.Team_Member__c = insideSales.Id;
            accTeam.Account_Access__c = 'Read/Write';
            accTeam.Team_Role__c = 'Forecasting - Inside Sales Rep';
            accTeam.Opportunity_Access__c = 'Read/Write';
            accTeam.Case_Access__c = 'Private';
            insert accTeam;
            
            oppObj = DS_TestObjects.NewOpportunity();
            oppObj.AccountId = accObj1.Id;
            insert oppObj;
            System.runAs(insideSales) 
            {
                oppObj = DS_TestObjects.NewOpportunity();
                oppObj.AccountId = accObj1.Id;
                oppObj.ADP_Opportunity_Owner__c = insideSales.Id;
                insert oppObj;
                
            }
        }
    }
    
    testmethod static void validateBuySellAccount() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name LIKE '%Acc2%' LIMIT 1]; 
        CPQ_BuySell_Extension extension = new CPQ_BuySell_Extension(new ApexPages.StandardController(opp));
        extension.edit();
        extension.opportunityRecord.SLS_Buyer_Account__c = acc.Id;
        extension.save();
        extension.opportunityRecord.SLS_Buyer_Account__c = null;
        extension.save();
        List<Opportunity_Location__c> oppLocationList = [SELECT Id FROM Opportunity_Location__c WHERE Opportunity__c = :opp.Id];
        delete oppLocationList;
        Account newAccount = DS_TestObjects.NewAccount();
        newAccount.Key_Rep__c = UserInfo.getUserId();
        insert newAccount;
        extension.opportunityRecord.SLS_Buyer_Account__c = newAccount.Id;
        extension.save();
        extension.opportunityRecord.SLS_Buyer_Account__c = opp.Id;
        extension.save();
        extension.cancel();
        Test.stopTest();
    
    }

}