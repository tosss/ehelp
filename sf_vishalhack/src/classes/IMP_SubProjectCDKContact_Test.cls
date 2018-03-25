/*---------------------------------------
 * Test Class for : IMP_SubProjectCDKContact_Handler
------------------------------------------
2016-05-20 -venkata.shrivol@cdk.com -Created
2016-06-06 -venkata.shrivol@cdk.com -change the confidential boolean reference to confidentiality status field. 
2016-12-05 -venkata.shrivol@cdk.com -commented project object reference RQ-08305
----------------------------------------*/
@isTest
public class IMP_SubProjectCDKContact_Test 
{
	@testSetup
	static void prepareTestData()
	{
		//customSettings
		IMP_ProfilesToByPass__c imptoByPass = new IMP_ProfilesToByPass__c();
		imptoByPass.Name='SubProject_Sharing';
		imptoByPass.Profile__c = 'ADPDS - Admin - System Administrator,Cobalt Cast Iron Integration,ADPDS - Admin - System Administrator-fsalwen,ADPDS - Admin - Integration User';
		insert imptoByPass;
		
		list<User> testUsersList = new list<User>();
		User testUser1 = DS_TestObjects.NewUser();
		testUser1.FirstName = 'TestName1';
		testUsersList.add(testUser1);
		User testUser2 = DS_TestObjects.NewUser();
		testUser2.FirstName = 'TestName2';
		testUsersList.add(testUser2);	
		
		insert testUsersList;
		
		/*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;*/
        
        list<Subproject__c> testSubList = new list<Subproject__c>();
        SubProject__c subprj1 = 	IMP_TestFactory_Helper.buildSubProject();
        subprj1.SubProject_Name__c = 'Test SubProject 1';
        subprj1.Confidentiality_Status__c = 'Restricted';
        testSubList.add(subprj1);
		SubProject__c subprj2 = 	IMP_TestFactory_Helper.buildSubProject();
		subprj2.SubProject_Name__c = 'Test SubProject 2';
		subprj2.Confidentiality_Status__c = 'Restricted';
		testSubList.add(subprj2);
        insert testSubList;
        
        Project_Log__c testLog = IMP_TestFactory_Helper.buildRiskLog(subprj1.Id);
        insert testLog;
        
        list<SubProject_CDK_Contact__c> cdkContactsList = new list<SubProject_CDK_Contact__c>();
        SubProject_CDK_Contact__c testCdkContact = new SubProject_CDK_Contact__c();
        testCdkContact.CDK_Contact__c = testUser1.Id;
        testCdkContact.SubProject__c = subprj1.Id;
        testCdkContact.User_Visibility_Enabled__c = true;
        insert testCdkContact;
        
        
	}

	static testMethod void testCDKContactInsert()
	{
		list<Project_Log__c> projLogList = [select Id, Sub_Project_Risk__c from Project_Log__c where Sub_Project_Risk__r.SubProject_Name__c='Test SubProject 1'];
		Project_Log__c thisLog = projLogList.size() > 0 ? projLogList.get(0) : new Project_Log__c();
		
		list<SubProject__Share> sharedSubProjectRecord = [
		select Id from SubProject__Share
		where parentId = :thisLog.Sub_Project_Risk__c];
		
		system.assertEquals(2, sharedSubProjectRecord.size());
		
	} 
	
	static testMethod void testCDKContactDelete()
	{
		
		list<SubProject_CDK_Contact__c> cdkConList = [
			select Id, SubProject__c from SubProject_CDK_Contact__c 
			where SubProject__r.SubProject_Name__c='Test SubProject 1'];
		SubProject_CDK_Contact__c thisCDKContact = cdkConList.size() > 0 ? cdkConList.get(0) : new SubProject_CDK_Contact__c();
		
		list<Project_Log__c> projLogList = [select Id, Sub_Project_Risk__c from Project_Log__c where Sub_Project_Risk__r.SubProject_Name__c='Test SubProject 1'];
		Project_Log__c thisLog = projLogList.size() > 0 ? projLogList.get(0) : new Project_Log__c();
		
		Test.startTest();
			delete thisCDKContact;
		Test.stopTest();
		
		list<SubProject__Share> sharedSubProjectRecord = [
		select Id, parentId, userOrGroupId from SubProject__Share
		where parentId = :thisLog.Sub_Project_Risk__c];
		
		system.assertEquals(1, sharedSubProjectRecord.size());	
		
	}  
	
	static testMethod void onUserVisibilityFieldUpdate()
	{
		list<SubProject_CDK_Contact__c> cdkConList = [
			select Id from SubProject_CDK_Contact__c 
			where SubProject__r.SubProject_Name__c='Test SubProject 1'];
		SubProject_CDK_Contact__c thisCDKContact = cdkConList.size() > 0 ? cdkConList.get(0) : new SubProject_CDK_Contact__c();
		
		Test.startTest();
			thisCDKContact.User_Visibility_Enabled__c =false;
			update thisCDKContact;
		Test.stopTest();
		
		list<SubProject__Share> sharedSubProjectRecord = [
		select Id, parentId, userOrGroupId from SubProject__Share
		where parentId = :thisCDKContact.SubProject__c];
		
		system.assertEquals(1, sharedSubProjectRecord.size());
	}  
	
	static testMethod void onSubProjectAndUserFieldChange()
	{
		list<SubProject__c> insertedSubProjects = [
			select Id,SubProject_Name__c, (select Id from SubProject_CDK_Contacts__r)
			from SubProject__c where SubProject_Name__c IN ('Test SubProject 1','Test SubProject 2')];
		
		map<string, SubProject__c> subProjectMap = new map<String,SubProject__c>();
		for(SubProject__c sub:insertedSubProjects)
		{
			subProjectMap.put(sub.SubProject_Name__c, sub);	
		}
		
		list<User> userList = [select Id,FirstName from User where FirstName ='TestName2'];
		User thisUser = userList.size() > 0 ? userList.get(0) : new User();
		
		
		list<SubProject_CDK_Contact__c> cdkConList = subProjectMap.get('Test SubProject 1').SubProject_CDK_Contacts__r != null ? 
													 subProjectMap.get('Test SubProject 1').SubProject_CDK_Contacts__r :
													 new list<SubProject_CDK_Contact__c>();
													 
		SubProject_CDK_Contact__c thisContact = cdkConList.size() > 0 ? cdkConList.get(0) : new SubProject_CDK_Contact__c();
		
		Test.startTest();
			if(subProjectMap.get('Test SubProject 2')!=null)
			{
				thisContact.SubProject__c = subProjectMap.get('Test SubProject 2').Id;
			}
			if(thisUser!=null)
			{
				thisContact.CDK_Contact__c = thisUser.Id;
			}
			upsert thisContact;
		Test.stopTest();
		
		list<SubProject__Share> sharedSubProjectRecord = [
		select Id, parentId, userOrGroupId from SubProject__Share
		where parentId = :subProjectMap.get('Test SubProject 1').Id
        or parentId = :thisContact.SubProject__c];
		
		system.assertEquals(3, sharedSubProjectRecord.size());
	}
	
}