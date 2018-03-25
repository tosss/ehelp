//2016-12-22   vishal.bandari@cdk.com    RQ-08092-created the class
@IsTest
public class DS_CDKDocusignCCs_Test {
  @TestSetup
    public static void setupData()
    {
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.AccountId = acc.Id;
        opp.RecordTypeId =  ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity','1 - Baseline Multi-channel Opportunity');
        insert opp;
        
        CDK_Docusign_CCs__c docusignObj = new CDK_Docusign_CCs__c();
        Contact conObj = DS_TestObjects.NewContact_Inserted();
        docusignObj.Contact__c = conObj.Id;
        docusignObj.Email__c = 'abc@abc.com';
        docusignObj.Required_CC_Contact__c = true;
        docusignObj.Opportunity__c = opp.Id;
        docusignObj.Last_Name__c  = 'Abc';
        docusignObj.First_Name__c = 'Abc';
        
        insert docusignObj;
    }
    
    public static testmethod void testData()
    {
        try
        {
            delete [Select Id from CDK_Docusign_CCs__c];
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Cannot remove Required CC'));
        }
    }
}