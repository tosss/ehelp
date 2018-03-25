//2016-10-05- anirudh.singh@cdk.com- Created this test class for ALL_MassCreateOppSites_Extension Extension, used for ALL_MassCreateOppSites Visualforce Page.
//2017-04-21- ragashalini.koka@cdk.com- Modified this test class as a new validation rule is added for Account on PartyId field.
@isTest
public class ALL_MassCreateOppSites_Test
{
    @TestSetup
    private static void setupData()
    {
        list<sObject> settingsObjects = new list<sObject>{ 
            new Trigger_Toggle__c(Name='001', Code_Reference__c='CDK_Default_Team', On__c=false, RecordType_Name__c=null, sObject__c='Account'),
                new Trigger_Toggle__c(Name='002', Code_Reference__c='CDK_Default_Team', On__c=true, RecordType_Name__c='CDK OEM/Brand', sObject__c='Account')
                };
                    insert settingsObjects;    
        
        List<Account> accsList=new List<Account>();
        Id accRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('CDK OEM/Brand').getRecordTypeId();
        
        //2017-04-21 ragashalini.koka@cdk.com - Added PartyID__c field for Account
        for(Integer i=0; i<2; i++)
        {
            Account accRecord=new Account();
            accRecord.Name='Test Account '+i;
            accRecord.RecordTypeId=accRecordTypeId;
            accRecord.PartyID__c=String.valueOf(Math.round(Math.random()*1000));
            accsList.add(accRecord);
        }
        insert accsList;
        
        Account childAccRecord=DS_TestObjects.NewAccount();
        childAccRecord.ParentId=accsList[0].Id;
        insert childAccRecord;
        
        Account grandChildAccRecord=DS_TestObjects.NewAccount();
        grandChildAccRecord.ParentId=childAccRecord.Id;
        insert grandChildAccRecord;
        
        Opportunity oppRecord=DS_TestObjects.NewOpportunity();
        oppRecord.AccountId=accsList[0].Id;
        insert oppRecord;
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId= :siteRecordTypeId AND Opportunity__c= :oppRecord.Id AND Site__c= :accsList[0].Id];
    }
    
    private static testMethod void constructorTestOne()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        
        Opportunity oppRecord=[SELECT Id, Name, AccountId FROM Opportunity];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_MassCreateOppSites'));
        System.currentPageReference().getParameters().put('id', oppRecord.AccountId);
        System.currentPageReference().getParameters().put('oppId', oppRecord.Id);
        
        test.startTest();
        ALL_MassCreateOppSites_Extension extensionController=new ALL_MassCreateOppSites_Extension(new ALL_AccountHierarchy_Controller());
        test.stopTest();
    }
    
    private static testMethod void constructorTestTwo()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_MassCreateOppSites'));
        System.currentPageReference().getParameters().put('id', oppRecord.AccountId);
        System.currentPageReference().getParameters().put('oppId', Null);
        
        test.startTest();
        ALL_MassCreateOppSites_Extension extensionController=new ALL_MassCreateOppSites_Extension(new ALL_AccountHierarchy_Controller());
        test.stopTest();
    }
    
    private static testMethod void constructorTestThree()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_MassCreateOppSites'));
        System.currentPageReference().getParameters().put('oppId', '837957832');
        
        test.startTest();
        ALL_MassCreateOppSites_Extension extensionController=new ALL_MassCreateOppSites_Extension(new ALL_AccountHierarchy_Controller());
        test.stopTest();
    }
    
    private static testMethod void constructorTestFour()
    {
        Opportunity oppRecord=[SELECT Id,Name, AccountId FROM Opportunity];
        Opportunity_Location__c oppSiteRecord = [select Id from Opportunity_Location__c where Opportunity__c=: oppRecord.Id limit 1];
        
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_MassCreateOppSites'));
        System.currentPageReference().getParameters().put('id', oppRecord.AccountId);
        System.currentPageReference().getParameters().put('oppId', oppRecord.Id);
        
        test.startTest();
        ALL_MassCreateOppSites_Extension extensionController=new ALL_MassCreateOppSites_Extension(new ALL_AccountHierarchy_Controller());
        test.stopTest();
    }
    
    private static testMethod void createOpportunitySitesTestOne()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        List<Account> accsList=[SELECT Id FROM Account WHERE ParentId!=Null];
        
        List<String> accountIdsList=new List<String>{accsList[0].Id, accsList[1].Id};
            
            test.startTest();
        Map<Id, String> accIdAndErrorsMap=ALL_MassCreateOppSites_Extension.createOpportunitySites(accountIdsList, oppRecord.Id);
        test.stopTest();
        system.assertEquals(0, accIdAndErrorsMap.size());
    }
    
    private static testMethod void createOpportunitySitesTestTwo()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        Account accRecordNotInHierarchy=[SELECT Id FROM Account WHERE Name='Test Account 1'];
        
        List<String> accountIdsList=new List<String>{accRecordNotInHierarchy.Id};
            
            test.startTest();
        Map<Id, String> accIdAndErrorsMap=ALL_MassCreateOppSites_Extension.createOpportunitySites(accountIdsList, oppRecord.Id);
        test.stopTest();
        system.assertEquals(0, accIdAndErrorsMap.size());
    }
    
    private static testMethod void createOpportunitySitesTestThree()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        Account accRecordNotInHierarchy=[SELECT Id FROM Account WHERE Name='Test Account 1'];
        
        test.startTest();
        Map<Id, String> accIdAndErrorsMap=ALL_MassCreateOppSites_Extension.createOpportunitySites(new List<String>{oppRecord.Id}, accRecordNotInHierarchy.Id);
        test.stopTest();
        system.assertEquals(1, accIdAndErrorsMap.size());
    }
    
    /*private static testMethod void deleteOppSiteTestOne()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        
        test.startTest();
        Map<Id, String> accIdAndErrorsMap=ALL_MassCreateOppSites_Extension.deleteOppSite(oppRecord.AccountId, oppRecord.Id);
        
        ALL_MassCreateOppSites_Extension.deleteOppSite(oppRecord.AccountId, oppRecord.Id);
        test.stopTest();
        system.assertEquals(0, accIdAndErrorsMap.size());
    }*/
    
    /*private static testMethod void deleteOppSiteTestTwo()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        Account accRecordNotInHierarchy=[SELECT Id FROM Account WHERE Name='Test Account 1'];
        
        test.startTest();
        Map<Id, String> accIdAndErrorsMap=ALL_MassCreateOppSites_Extension.deleteOppSite(accRecordNotInHierarchy.Id, oppRecord.Id);
        test.stopTest();
        system.assertEquals(0, accIdAndErrorsMap.size());
    }*/
    
    private static testMethod void fetchManuallyAddedSitesTestOne()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        Account accRecordNotInHierarchy=[SELECT Id FROM Account WHERE Name='Test Account 1'];
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        
        Opportunity_Location__c opportunitySiteRef=new Opportunity_Location__c();
        opportunitySiteRef.RecordTypeId=siteRecordTypeId;
        opportunitySiteRef.Opportunity__c=oppRecord.Id;
        opportunitySiteRef.Site__c=accRecordNotInHierarchy.Id;
        insert opportunitySiteRef;
        
        List<String> accIdsManuallyAddedList=new List<String>{accRecordNotInHierarchy.Id};
            String accIdsManuallyAdded=JSON.serialize(accIdsManuallyAddedList);
        
        String accColumnsToBeFetched='Name, Region__c, Group__c, BillingCity, BillingState, Key_Rep__c, Key_DOS__c, Designated_DSM__c, Site_Type__c, Website';
        
        List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper> columnNameLabelWrapperList=new List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper>();
        ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper recOne=new ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper();
        recOne.columnName='Name';
        recOne.columnLabel='Account Name';
        columnNameLabelWrapperList.add(recOne);
        
        ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper recTwo=new ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper();
        recTwo.columnName='Region__c';
        recTwo.columnLabel='Region';
        columnNameLabelWrapperList.add(recTwo);
        
        String colNameLabelMap=JSON.serialize(columnNameLabelWrapperList);
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_MassCreateOppSites'));
        System.currentPageReference().getParameters().put('accIdsManuallyAdded', accIdsManuallyAdded);
        System.currentPageReference().getParameters().put('accColumnsToBeFetched', accColumnsToBeFetched);
        System.currentPageReference().getParameters().put('colNameLabelMap', colNameLabelMap);
        
        test.startTest();
        ALL_MassCreateOppSites_Extension extensionController=new ALL_MassCreateOppSites_Extension(new ALL_AccountHierarchy_Controller());
        extensionController.fetchManuallyAddedSites();
        test.stopTest();
        
        system.assertEquals(1, extensionController.displayManuallyAddedAccsList.size());
    }
    
    private static testMethod void fetchManuallyAddedSitesTestTwo()
    {
        Opportunity oppRecord=[SELECT Id, AccountId FROM Opportunity];
        Account accRecordNotInHierarchy=[SELECT Id FROM Account WHERE Name='Test Account 1'];
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        
        Opportunity_Location__c opportunitySiteRef=new Opportunity_Location__c();
        opportunitySiteRef.RecordTypeId=siteRecordTypeId;
        opportunitySiteRef.Opportunity__c=oppRecord.Id;
        opportunitySiteRef.Site__c=accRecordNotInHierarchy.Id;
        insert opportunitySiteRef;
        
        List<String> accIdsManuallyAddedList=new List<String>{accRecordNotInHierarchy.Id};
        String accIdsManuallyAdded=JSON.serialize(accIdsManuallyAddedList);
        
        String accColumnsToBeFetched='Test, Region__c, Group__c, BillingCity, BillingState, Key_Rep__c, Key_DOS__c, Designated_DSM__c, Site_Type__c, Website';
        
        List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper> columnNameLabelWrapperList=new List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper>();
        ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper recOne=new ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper();
        recOne.columnName='Test';
        recOne.columnLabel='Account Name';
        columnNameLabelWrapperList.add(recOne);
        
        String colNameLabelMap=JSON.serialize(columnNameLabelWrapperList);
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_MassCreateOppSites'));
        System.currentPageReference().getParameters().put('accIdsManuallyAdded', accIdsManuallyAdded);
        System.currentPageReference().getParameters().put('accColumnsToBeFetched', accColumnsToBeFetched);
        System.currentPageReference().getParameters().put('colNameLabelMap', colNameLabelMap);
        
        test.startTest();
        ALL_MassCreateOppSites_Extension extensionController=new ALL_MassCreateOppSites_Extension(new ALL_AccountHierarchy_Controller());
        extensionController.fetchManuallyAddedSites();
        test.stopTest();
        
        system.assertEquals(0, extensionController.displayManuallyAddedAccsList.size());
    }
}