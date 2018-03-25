//2016-08-08 - vishal.bandari@cdk.com - created this class - RQ-07540.
//2016-10-19 - ragashalini.koka@cdk.com - added new record for the RQ-08013
//2016-11-21 - vishal.bandari@cdk.com - added code to test Parse Pending Approval String - RQ-08211
//2016-02-02 - vishal.bandari@cdk.com - added NA_test method to test clearing Parsed value for NA - RQ-08585
@IsTest
public class CPQ_BigMachinesQuote_Test 
{  
    @testSetup
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
      
        User userObj = [SELECT Id,Name,BigMachines__Login__c from User Where Id = :usr.Id];
        Opportunity oppObj;
        System.runAs(userObj) 
                     {
                         Account accObj = DS_TestObjects.NewAccount();
                         accObj.PartyID__c = '1245655';
                         insert accObj; 
                         oppObj = DS_TestObjects.NewOpportunity();
                         oppObj.AccountId = accObj.Id;
                         insert oppObj;
                     }
        
        BigMachines__Configuration_Record__c configObj = new BigMachines__Configuration_Record__c();
        configObj.BigMachines__action_id_copy__c = 'somevalue'; 
        configObj.BigMachines__action_id_open__c = 'somevalue'; 
        configObj.BigMachines__bm_site__c = 'somevalue';
        configObj.BigMachines__document_id__c = 'somevalue';
        configObj.BigMachines__process__c = 'somevalue'; 
        configObj.BigMachines__process_id__c = 'somevalue';
        configObj.BigMachines__version_id__c = 'somevalue';
        configObj.BigMachines__Is_Active__c = true;
        insert configObj;
        
        List<BigMachines__Quote__c> quoteList = new List<BigMachines__Quote__c>();
        
        BigMachines__Quote__c quoteObj1 = new BigMachines__Quote__c();
        quoteObj1.BigMachines__Account__c = oppObj.AccountId;
        quoteObj1.BigMachines__Opportunity__c = oppObj.Id;
        quoteObj1.BigMachines__Site__c = configObj.Id;
        quoteObj1.BigMachines__Status__c = 'Draft';
        
        //2016-11-21 - vishal.bandari@cdk.com - added code to test Parse Pending Approval String - RQ-08211
        quoteObj1.Pending_Approvals_From_Users_String__c = userObj.BigMachines__Login__c+',role,Pending Approval';
        
        quoteList.add(quoteObj1);
        
        BigMachines__Quote__c quoteObj2 = new BigMachines__Quote__c();
        quoteObj2.BigMachines__Account__c = oppObj.AccountId;
        quoteObj2.BigMachines__Opportunity__c = oppObj.Id;
        quoteObj2.BigMachines__Site__c = configObj.Id;
        quoteObj2.BigMachines__Status__c = 'Other';
        
        //2016-11-21 - vishal.bandari@cdk.com - added code to test Parse Pending Approval String - RQ-08211
        quoteObj2.Pending_Approvals_From_Users_String__c = userObj.BigMachines__Login__c+',role,Pending Approval';
        
        quoteList.add(quoteObj2);
        
        BigMachines__Quote__c quoteObj3 = new BigMachines__Quote__c();
        quoteObj3.BigMachines__Account__c = oppObj.AccountId;
        quoteObj3.BigMachines__Opportunity__c = oppObj.Id;
        quoteObj3.BigMachines__Site__c = configObj.Id;
        quoteObj3.BigMachines__Status__c = 'Order Submitted';
        quoteObj3.BigMachines__Is_Primary__c = true;
        quoteObj3.MSA_ARNA__c = true;
        quoteObj3.MSA_Digital__c = true;
        quoteObj3.MSA_IPNS__c = true;
        
        //2016-11-21 - vishal.bandari@cdk.com - added code to test Parse Pending Approval String - RQ-08211
        quoteObj3.Pending_Approvals_From_Users_String__c = userObj.BigMachines__Login__c+',role,Pending Approval';
        
        quoteList.add(quoteObj3);
        
        BigMachines__Quote__c quoteObj4 = new BigMachines__Quote__c();
        quoteObj4.BigMachines__Account__c = oppObj.AccountId;
        quoteObj4.BigMachines__Opportunity__c = oppObj.Id;
        quoteObj4.BigMachines__Site__c = configObj.Id;
        quoteObj4.BigMachines__Status__c = 'Order Submitted';
        quoteObj4.BigMachines__Is_Primary__c = true;
        
        //2016-11-21 - vishal.bandari@cdk.com - added code to test Parse Pending Approval String - RQ-08211
        quoteObj4.Pending_Approvals_From_Users_String__c = userObj.BigMachines__Login__c+',role,Pending Approval';
        
        quoteList.add(quoteObj4);
        
        insert quoteList;
       
        quoteList = [SELECT Pending_Approvals_From_Users_Parsed__c FROM BigMachines__Quote__c WHERE ID IN: quoteList];
      
        //2016-11-21 - vishal.bandari@cdk.com - added code to test Parse Pending Approval String - RQ-08211
        for(BigMachines__Quote__c quoteObj : quoteList)
        {
            System.assertEquals(userObj.Name+' - Pending Approval', quoteObj.Pending_Approvals_From_Users_Parsed__c,'Pending Approval String not parsed');
        }
        
        
        
    }
    public testmethod static void deleteTest()
    {   
        List<BigMachines__Quote__c> quoteList = [SELECT ID,BigMachines__Status__c FROM BigMachines__Quote__c];
        quoteList[0].BigMachines__Status__c = 'Draft';
        quoteList[1].BigMachines__Status__c = 'Other';
        update quoteList;
        delete quoteList[0];
        CPQ_BigMachinesQuote_Handler.beforeDelete(new List<BigMachines__Quote__c>{quoteList[1]});     
    }
    
    //2016-02-02 - vishal.bandari@cdk.com - added NA_test method to test clearing Parsed value for NA - RQ-08585
    public testmethod static void NA_test()
    {
        List<BigMachines__Quote__c> quoteList = [SELECT ID,BigMachines__Status__c FROM BigMachines__Quote__c];
        
        quoteList[0].Pending_Approvals_From_Users_String__c = 'NA';
        update quoteList[0];
        
        quoteList[0] = [SELECT Pending_Approvals_From_Users_Parsed__c FROM BigMachines__Quote__c WHERE ID = :quoteList[0].Id ];
        System.assertEquals(null, quoteList[0].Pending_Approvals_From_Users_Parsed__c,'Pending Approval String not parsed');
    }
}