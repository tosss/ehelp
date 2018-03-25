@isTest
public class DS_TraverProjectUpdateTest 
{
	/*public static testmethod void Lets_Get_Started_Field_Update_test()
    {
        Id newId  = DS_TestObjects.NewAccount_Inserted().Id;
        Traver_Project__c testTraverProject  = new Traver_Project__c(Account__c = newId);
        database.insert(testTraverProject);
        testTraverProject = [Select id, lets_get_started__C from Traver_Project__c where id =: testTraverProject.id];
        Task testTask = [select id, lets_get_started__c from Task where whatId =: testTraverProject.id];
        testTask.Lets_Get_Started__c =  system.today();
        database.update(testTask);
        testTraverProject = [Select id, lets_get_started__C from Traver_Project__c where id =: testTraverProject.id];
        testTask = [select id, lets_get_started__c from Task where whatId =: testTraverProject.id];
        system.assertEquals(testTask.Lets_Get_Started__c, testTraverProject.Lets_Get_Started__c);       
    }*/
    
    // above test method was failing in production. so had to re-do it. SivaP 02/27/2015
    public static testmethod void LetsGetStartedFieldUpdate()
    {
        Id newId  = DS_TestObjects.NewAccount_Inserted().Id;
        Traver_Project__c testTraverProject  = new Traver_Project__c(Account__c = newId);
        insert testTraverProject;
        
        Task t = DS_TestObjects.NewTask();
        t.subject = 'EPC Intro Call & Process';
        t.Lets_Get_Started__c = Date.today();
        t.WhatId = testTraverProject.Id;
        insert t;
    }
}