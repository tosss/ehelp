/*-----------------------------------------------------------
Test Class for  - IMP_ProjectLog_Handler

2015-12-23 - venkata.shrivol@cdk.com  - Created
2016-06-06 - venkata.shrivol@cdk.com - updated this test class from Confidential checkbox to
									   Confidentiality_Status field
2016-12-05 -venkata.shrivol@cdk.com -commented the project object reference RQ-08305
-------------------------------------------------------------*/
@isTest
public class IMP_ProjectLog_Test 
{
	static list<String> recordTypesList = new list<String>{'Issue', 'Risk','Action Item','Change Request','Lesson Learned'};
	@testSetup
	static void createTestData()
	{
		/*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;*/
        
        list<Subproject__c> testSubList = new list<Subproject__c>();
        SubProject__c subprj1 = 	IMP_TestFactory_Helper.buildSubProject();
        subprj1.SubProject_Name__c = 'Test SubProject 1';
        subprj1.Confidentiality_Status__c ='Confidential';
		testSubList.add(subprj1);
		SubProject__c subprj2 = 	IMP_TestFactory_Helper.buildSubProject();
		subprj1.SubProject_Name__c = 'Test SubProject 2';
		testSubList.add(subprj2);
        insert testSubList;
        
        list<Project_Log__c> testLogList = new list<Project_Log__c>();
		Project_Log__c issueLogRecord =  IMP_TestFactory_Helper.buildIssueLog(subprj1.Id);
		Project_Log__c riskLogRecord =  IMP_TestFactory_Helper.buildRiskLog(subprj1.Id);
		Project_Log__c actionItemRecord =  IMP_TestFactory_Helper.buildActionItemLog(subprj2.Id);
		Project_Log__c changeRequestRecord =  IMP_TestFactory_Helper.buildChangeRequestLog(subprj2.Id);
		Project_Log__c lessonLearnedRecord =  IMP_TestFactory_Helper.buildLessonLearnedLog(null);
		testLogList.add(issueLogRecord);
		testLogList.add(riskLogRecord);
		testLogList.add(actionItemRecord);
		testLogList.add(changeRequestRecord);
		testLogList.add(lessonLearnedRecord);
		insert testLogList;
	}
	
	public static testMethod void projectLogHandlerInsertTest()
	{
		
		map<string, Project_Log__c> projectlogMapByRecType =	new map<string, Project_Log__c>();
		
		list<Project_Log__c> insertedTestRecords = 
		[
			select Id,RecordType.Name, SubProject_Confidentiality_Status__c, Sub_Project_Issue__r.Confidentiality_Status__c,
				Sub_Project_Risk__r.Confidentiality_Status__c,  Sub_Project_Action_Items__r.Confidentiality_Status__c,
				Sub_Project_Change_Request__r.Confidentiality_Status__c
			from Project_Log__c
			where  RecordType.Name IN :recordTypesList
		];	
		
		for(Project_Log__c plg:insertedTestRecords)
		{
			projectlogMapByRecType.put(plg.RecordType.Name, plg);	
		}
		
		system.assertEquals(projectlogMapByRecType.get('Issue').Sub_Project_Issue__r.Confidentiality_Status__c, 
				projectlogMapByRecType.get('Issue').SubProject_Confidentiality_Status__c);
		system.assertEquals(projectlogMapByRecType.get('Risk').Sub_Project_Risk__r.Confidentiality_Status__c,
		 		projectlogMapByRecType.get('Risk').SubProject_Confidentiality_Status__c);
		system.assertEquals(projectlogMapByRecType.get('Action Item').Sub_Project_Action_Items__r.Confidentiality_Status__c, 
				projectlogMapByRecType.get('Action Item').SubProject_Confidentiality_Status__c);
		system.assertEquals(projectlogMapByRecType.get('Change Request').Sub_Project_Change_Request__r.Confidentiality_Status__c, 
				projectlogMapByRecType.get('Change Request').SubProject_Confidentiality_Status__c);
		
		system.assertEquals(null, projectlogMapByRecType.get('Lesson Learned').SubProject_Confidentiality_Status__c);
		
	}
	
	public static testMethod void projectLogHandlerUpdateTest()
	{
		list<Project_Log__c> projLogList = [
			select Id, Sub_Project_Lessons_Learned__c
			from Project_Log__c 
			where recordType.Name= 'Lesson Learned'
			limit 1
		];
		Project_Log__c thisProjLog = projLogList.size()> 0 ? projLogList.get(0) : new Project_Log__c();
		
		list<SubProject__c> SubProjects = [
			select Id, Confidentiality_Status__c 
			from SubProject__c 
			where Confidentiality_Status__c = 'Confidential'
		];
		SubProject__c thisSubProject = SubProjects.size() > 0 ? SubProjects.get(0) : new SubProject__c();
		
		Test.startTest();
			thisProjLog.Sub_Project_Lessons_Learned__c = thisSubProject.Id;
			update thisProjLog;
		Test.stopTest();
		
		Project_Log__c updatedProjectLog = [
			select SubProject_Confidentiality_Status__c
			from Project_Log__c 
			where recordType.Name= 'Lesson Learned'
			limit 1
		];
		
		system.assertEquals(updatedProjectLog.SubProject_Confidentiality_Status__c, thisSubProject.Confidentiality_Status__c);
	}
	
	public static testMethod void subProjectUpdateTest()
	{
		
		list<SubProject__c> SubProjects = [
			select Id, Confidentiality_Status__c 
			from SubProject__c 
		];
		
		for(SubProject__c sub : SubProjects)
		{
			if(sub.Confidentiality_Status__c == 'Confidential')
			{
				sub.Confidentiality_Status__c = 'Restricted';	
			}
			else{
				sub.Confidentiality_Status__c = 'Confidential';
			}	
		}
		Test.startTest();
			update SubProjects;
		Test.stopTest();
		
		projectLogHandlerInsertTest();		 
	}    
}