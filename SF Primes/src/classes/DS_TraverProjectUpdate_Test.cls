@isTest
public class DS_TraverProjectUpdate_Test  
{	
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