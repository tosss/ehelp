// 2016-02-25 endiem@endiem.com - RQ-05509 - Test class for RM_Helper class
@isTest
private class TRV_RMHelper_Test {
    
    private static testMethod void test_Helper() {

        List<User> lstUser = [
            SELECT Id, Name 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
        ];
        
        Account objAccount = new Account(Name = 'Test Account');
        
        Account objAccount1 = new Account(Name = 'Test 5star Account');
        insert new List<Account>{objAccount, objAccount1};

        Traver_Project__c objTraverProj = new Traver_Project__c(Account__c = objAccount.Id);
        
        Traver_Project__c objTraverProj1 = new Traver_Project__c(Account__c = objAccount1.Id);
        insert new List<Traver_Project__c>{objTraverProj, objTraverProj1};
        
        TRV_Resource__c objResource = new TRV_Resource__c(TRV_Resource__c = lstUser[0].Id);
        TRV_Resource__c objResource1 = new TRV_Resource__c(TRV_Resource__c = lstUser[0].Id, TRV_Termination_Date__c = Date.Today());
        insert new List<TRV_Resource__c>{objResource, objResource1};
        
        Traver_Coaching__c objTraverCoach = new Traver_Coaching__c(
            Status__c = 'Scheduled', 
            Traver_Project__c = objTraverProj.Id,
            TRV_Push_Reason__c = 'Test', 
            TRV_Completed_By__c = objResource.Id
        );
        
        Traver_Coaching__c objTraverCoach1 = new Traver_Coaching__c(
            Status__c = 'Scheduled', 
            Traver_Project__c = objTraverProj1.Id,
            TRV_Push_Reason__c = 'Test', 
            TRV_Completed_By__c = objResource.Id,
            X5_Star_Guarantee__c = true
        );
        insert new List<Traver_Coaching__c>{objTraverCoach, objTraverCoach1};

        ApexPages.currentPage().getParameters().put('resourceId', objResource.Id);
        ApexPages.currentPage().getParameters().put('visitStartDate', String.valueOf(Date.Today()));
        ApexPages.currentPage().getParameters().put('ExMajor', '');
        ApexPages.currentPage().getParameters().put('ExMinor', '');
        ApexPages.currentPage().getParameters().put('skLevMajor', '');
        ApexPages.currentPage().getParameters().put('skLevMinor', '');

        TRV_ResourceManagement_Helper autoCompleteObj = new TRV_ResourceManagement_Helper();
        autoCompleteObj.redirectToFlow();

        system.assertEquals(true, autoCompleteObj.bRenderFlow);
        system.assertEquals('', autoCompleteObj.getmyID());

        autoCompleteObj.getB4BId();
        
        system.assertEquals(new List<Traver_Project__c>(), TRV_ResourceManagement_Helper.searchProject('Consu', objAccount.Id));
        
        system.assertEquals(2, TRV_ResourceManagement_Helper.searchAccount('Tes').size());
        
        system.assertEquals(false, TRV_ResourceManagement_Helper.five_Star_Gaurantee_B4B(objAccount.Id, objResource.Id));
        
        system.assertEquals(true, TRV_ResourceManagement_Helper.five_Star_Gaurantee_B4B(objAccount1.Id, objResource.Id));
        
        ApexPages.currentPage().getParameters().put('resourceId', objResource1.Id);
        ApexPages.currentPage().getParameters().put('visitStartDate', String.valueOf(Date.Today()+2));
        ApexPages.currentPage().getParameters().put('ExMajor', '');
        ApexPages.currentPage().getParameters().put('ExMinor', '');
        ApexPages.currentPage().getParameters().put('skLevMajor', '');
        ApexPages.currentPage().getParameters().put('skLevMinor', '');

        TRV_ResourceManagement_Helper autoCompleteObj1 = new TRV_ResourceManagement_Helper();
        autoCompleteObj1.redirectToFlow();
    }
}