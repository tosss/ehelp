// 2015-12-08 endiem@endiem.com - RQ-05509 - Test class for Resource Management class
@isTest
private class TRV_ResourceManagement_Test {
    
    private static Traver_Coaching__c traver;
    private static TRV_Resource__c resource;
    
    private static void setupData(){
        
        User u1 = DS_TestObjects.NewUser();
        User u2 = DS_TestObjects.NewUser();
        User u3 = DS_TestObjects.NewUser();
        User u4 = DS_TestObjects.NewUser();
        User u5 = DS_TestObjects.NewUser();
        User u6 = DS_TestObjects.NewUser();
        User u7 = DS_TestObjects.NewUser();
        User u8 = DS_TestObjects.NewUser();
        User u9 = DS_TestObjects.NewUser();
        User u10 = DS_TestObjects.NewUser();
        insert new List<User>{u1,u2,u3,u4,u5,u6,u7,u8,u9,u10};
        
        
        Account objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        
        Traver_Project__c objTraverProj = new Traver_Project__c(Account__c = objAccount.Id);
        insert objTraverProj;
        
        TRV_Resource__c objResource0 = new TRV_Resource__c(TRV_Resource__c = u1.Id);
        insert objResource0;
        
        TRV_Resource__c objResource1 = new TRV_Resource__c(TRV_Resource__c = u2.Id);
        insert objResource1;
        
        resource = new TRV_Resource__c(
            TRV_Resource__c = u3.Id, 
            TRV_Region__c = 'Canada', 
            TRV_Status__c = 'FTE', 
            TRV_Role__c = 'PSC'
        );
        insert resource;
        
        traver = new Traver_Coaching__c(
            Status__c = 'Confirmed', 
            Traver_Project__c = objTraverProj.Id,
            TRV_Push_Reason__c = 'Test', 
            TRV_Completed_By__c = resource.Id
        );
        insert traver;
        
        Traver_Coaching__c objTraverCoach = new Traver_Coaching__c(
            Status__c = 'Confirmed', 
            Traver_Project__c = objTraverProj.Id,
            TRV_Push_Reason__c = 'Test',
            TRV_Completed_By__c = objResource0.Id
        );
        insert objTraverCoach;
        
        TRV_Skillset__c skillSet = new TRV_Skillset__c(
            TRV_B4B_Coaching__c = traver.Id, 
            TRV_Expertise_Major__c = 'Accounting',
            TRV_Expertise_Minor__c = 'Payroll',
            TRV_Resource__c = resource.Id,
            TRV_Skill_Level_Major__c = '1', 
            TRV_Skill_Level_Minor__c = '1'
        );
        insert skillSet;
    }
    
    private static testMethod void test_RM_Controller() {
        // Implement test code
        TRV_ResourceManagement_Controller demoContr = new TRV_ResourceManagement_Controller();
        
        system.assertEquals(4, demoContr.getStatus().size());
        system.assertEquals(4, demoContr.getSkillsetRole().size());
        system.assertEquals(7, demoContr.getLocation().size());
        
        TRV_ResourceManagement_Controller.getFilterPreferences();
        demoContr.resetFilters();
        
        system.assertEquals('', TRV_ResourceManagement_Controller.strSelectedRole);
    }
    
    private static testMethod void test_RM_Controller_WithoutFilters() {
        
        // Implement test code
        setupData();
        TRV_ResourceManagement_Controller demoContr = new TRV_ResourceManagement_Controller();
        system.assertEquals(3, TRV_ResourceManagement_Controller.getB4BCoaching('', '', '', '', '', '', '', '', false).size());
    }
    
    private static testMethod void test_UpdateB4BCoachingRecord() {
        
        // Implement test code
        setupData();
        TRV_ResourceManagement_Controller demoContr = new TRV_ResourceManagement_Controller();
        TRV_ResourceManagement_Controller.updateB4BCoachingRecord((String)traver.Id, (String)resource.Id, String.valueOf(Date.TODAY()));
    }
    
    private static testMethod void test_B4BWithFilters() {
        
        // Implement test code
        setupData();
        TRV_ResourceManagement_Controller demoContr = new TRV_ResourceManagement_Controller();
        system.assertEquals(2, TRV_ResourceManagement_Controller.getB4BCoaching('PSC', 'FTE', (String)resource.Id, 'Canada', 'Accounting', 'Payroll', '1', '1', false).size());
    }
}