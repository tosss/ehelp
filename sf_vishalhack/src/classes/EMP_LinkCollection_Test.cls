//2016-07-28- anirudh.singh@cdk.com- Created this class for RQ-07332.
@isTest
public class EMP_LinkCollection_Test
{
    @TestSetup
    private static void setupData()
    {
        Id linkCollectionRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Page_Component__c', 'Link Collection');
        
        Page_Component__c linkCollectionRecord=new Page_Component__c();
        linkCollectionRecord.RecordTypeId=linkCollectionRecordTypeId;
        linkCollectionRecord.Name='Home Page Links';
        insert linkCollectionRecord;
        
        Id linkRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Page_Component__c', 'Link');
        
        List<Page_Component__c> linksList=new List<Page_Component__c>();
        for(Integer i=0; i<5; i++)
        {
            Page_Component__c linkRecord=new Page_Component__c();
            linkRecord.RecordTypeId=linkRecordTypeId;
            linkRecord.Name='Test Link '+i;
            linkRecord.Link_Text__c='Test Link '+i;
            linkRecord.Link_URL__c='https://www.testsite.com/Test'+i;
            linkRecord.Link_Use_ADID__c=true; // 2017-04-12 matt.keefe@cdk.com - RQ-08957
            linkRecord.Link_Target__c='_self';
            linkRecord.Parent_Component__c=linkCollectionRecord.Id;
            linksList.add(linkRecord);
        }
        
        linksList[0].Order__c=5;
        linksList[1].Order__c=2;
        linksList[2].Order__c=6;
        
        insert linksList;
    }
    
    private static testMethod void fetchLinkCollectionTestOne()
    {
        List<Page_Component__c> linksList=[SELECT Id FROM Page_Component__c WHERE Parent_Component__r.Name='Home Page Links'];
        
        Test.startTest();
        system.assertEquals(linksList.size(), EMP_LinkCollection_Controller.fetchLinkCollection('Home Page Links').size());
        Test.stopTest();
    }
    
    private static testMethod void fetchLinkCollectionTestTwo()
    {
        Test.startTest();
        system.assertEquals(0, EMP_LinkCollection_Controller.fetchLinkCollection('My Links').size());
        Test.stopTest();
    }
    
    private static testMethod void addSelectedLinkToUserLinksTest()
    {
        List<Page_Component__c> linksList=[SELECT Id FROM Page_Component__c WHERE Parent_Component__r.Name='Home Page Links'];
        
        Test.startTest();
        EMP_LinkCollection_Controller.addSelectedLinkToUserLinks(linksList[3].Id, 'Home Page Links');
        
        system.assertEquals(1, EMP_LinkCollection_Controller.fetchLinkCollection('My Links').size());
        Test.stopTest();
    }
    
    private static testMethod void removeSelectedLinkFromUserLinksTest()
    {
        List<Page_Component__c> linksList=[SELECT Id FROM Page_Component__c WHERE Parent_Component__r.Name='Home Page Links'];
        
        Test.startTest();
        EMP_LinkCollection_Controller.addSelectedLinkToUserLinks(linksList[3].Id, 'Home Page Links');
        
        List<EMP_LinkCollection_Controller.LinkWrapper> linksWrapperList=EMP_LinkCollection_Controller.fetchLinkCollection('My Links');
        system.assertEquals(1, linksWrapperList.size());
        
        EMP_LinkCollection_Controller.removeSelectedLinkFromUserLinks(linksWrapperList[0].link.Id);
        system.assertEquals(0, EMP_LinkCollection_Controller.fetchLinkCollection('My Links').size());
        Test.stopTest();
    }
}