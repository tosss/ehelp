//2017-04-07- anirudh.singh@cdk.com- Commented the reference of Lets_Get_Started__c for RQ-08946.
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
        //2017-04-07- anirudh.singh@cdk.com- Commented the below line for RQ-08946.
        //t.Lets_Get_Started__c = Date.today();
        t.WhatId = testTraverProject.Id;
        insert t;
    }
}