// 2016-17-02 endiem@endiem.com - RQ-05509 - Test class for consulting project trigger and handler
@isTest
private class TRV_ConsultingProject_Test {
    
    private static testMethod void test_Consulting_Project_Handler() {
        
         List<User> lstUser = new List<User>();
        
        Account objAccount = new Account(Name = 'Test Account');
        insert objAccount;

        String Random = DS_TestObjects.NextTestUserRandom();
        Profile objProfile = [
            SELECT Id 
            From Profile 
            WHERE Name = 'ADPDS - Sales - Traver Sales'
        ];
        
        User newUser = new User(
            UserName = 'test-'+Random+'@cdk.com', 
            Email = 'test-'+Random+'@cdk.com', 
            Alias = Random.length()>8?Random.substring(4, Random.length()):Random,
            EmailEncodingKey = 'UTF-8', 
            FirstName = 'Apex',
            LastName = 'Test User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSIDKey = 'en_US', 
            profileid = objProfile.Id, 
            TimeZoneSIDKey = 'America/Chicago',
            ADID__c = Random.length()>8?Random.substring(4, Random.length()):Random
        );
        lstUser.add(newUser);

        User newUser1 = new User(
            UserName = 'testcdk-'+Random+'@cdk.com', 
            Email = 'testcdk-'+Random+'@cdk.com', 
            Alias = Random.length()>8?Random.substring(4, Random.length()):Random,
            EmailEncodingKey = 'UTF-8', 
            FirstName = 'Apex',
            LastName = 'Test User', 
            LanguageLocaleKey = 'en_US', 
            LocaleSIDKey = 'en_US', 
            profileid = objProfile.Id, 
            TimeZoneSIDKey = 'America/Chicago',
            ADID__c = Random.length()>8?Random.substring(4, Random.length())+'cdk':Random+'cdk'
        );
        lstUser.add(newUser1);

        insert lstUser;

        TRV_Resource__c objResource = new TRV_Resource__c(TRV_Resource__c = lstUser[0].Id);
        insert objResource; 

        TRV_Resource__c objResource1 = new TRV_Resource__c(TRV_Resource__c = lstUser[1].Id);
        insert objResource1; 
        
        Traver_Project__c objTraverProj = new Traver_Project__c(
            Account__c = objAccount.Id, 
            TRV_EPC__c = objResource.Id, 
            TRV_Process_Coach__c = objResource.Id,
            TRV_PSC__c = objResource.Id
        );
        insert objTraverProj;

        Traver_Project__c objTraverProject = new Traver_Project__c(Account__c = objAccount.Id);
        insert objTraverProject;
        
        map<Id, Traver_Project__c> mapTraverProjects = new map<Id, Traver_Project__c>([
            SELECT Id, TRV_Process_Coach_Email__c, TRV_EPC_Email__c, TRV_PSC_Email__c 
            FROM Traver_Project__c
        ]);
        
        system.assertEquals(null, mapTraverProjects.get(objTraverProject.Id).TRV_EPC_Email__c);
        system.assertEquals('test-'+Random+'@cdk.com', mapTraverProjects.get(objTraverProj.Id).TRV_EPC_Email__c);
        system.assertEquals('test-'+Random+'@cdk.com', mapTraverProjects.get(objTraverProj.Id).TRV_PSC_Email__c);
        system.assertEquals('test-'+Random+'@cdk.com', mapTraverProjects.get(objTraverProj.Id).TRV_Process_Coach_Email__c);

        objTraverProject.TRV_EPC__c = objResource1.Id;
        objTraverProject.TRV_Process_Coach__c = objResource1.Id;
        objTraverProject.TRV_PSC__c = objResource1.Id;
        update objTraverProject;
        
        Traver_Project__c objProject = [
            SELECT Id, TRV_Process_Coach_Email__c, TRV_EPC_Email__c, TRV_PSC_Email__c 
            FROM Traver_Project__c 
            WHERE Id =: objTraverProject.Id
        ];
        
        system.assertEquals('testcdk-'+Random+'@cdk.com', objProject.TRV_EPC_Email__c);
        system.assertEquals('testcdk-'+Random+'@cdk.com', objProject.TRV_PSC_Email__c);
        system.assertEquals('testcdk-'+Random+'@cdk.com', objProject.TRV_Process_Coach_Email__c);

        objTraverProject.TRV_EPC__c = null;
        objTraverProject.TRV_Process_Coach__c = null;
        objTraverProject.TRV_PSC__c = null;
        update objTraverProject;
        
        Traver_Project__c objUpdatedProject = [
            SELECT Id, TRV_Process_Coach_Email__c, TRV_EPC_Email__c, TRV_PSC_Email__c 
            FROM Traver_Project__c 
            WHERE Id =: objTraverProject.Id
        ];
        
        system.assertEquals(null, objUpdatedProject.TRV_EPC_Email__c);
        system.assertEquals(null, objUpdatedProject.TRV_PSC_Email__c);
        system.assertEquals(null, objUpdatedProject.TRV_Process_Coach_Email__c);
    }
}