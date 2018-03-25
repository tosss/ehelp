@isTest
public class DS_TaskRollUpHandler_Test 
{
    public static testmethod void TaskRollUp()
    {  
        list<Laser_Artwork_Order__c> LaoListToInsert = new list<Laser_Artwork_Order__c>();
        
        Laser_Artwork_Order__c lao1 = DS_TestObjects.NewLaserArtworkOrder();
        lao1.Order_Status__c = 'ordered';
        lao1.Number_Follow_up_Calls__c = null;
        LaoListToInsert.add(lao1);
        
        Laser_Artwork_Order__c lao2 = DS_TestObjects.NewLaserArtworkOrder();
        lao2.Order_Status__c = 'awip';
        LaoListToInsert.add(lao2);
        
        insert LaoListToInsert;
        
        list<task> TaskListToInsert = new list<task>();
        
        Task t1 = new Task();
        t1.WhatId = lao1.Id;
        t1.status = 'open';
        t1.Track_Follow_up__c = true;
        t1.subject = 'Important task';
        TaskListToInsert.add(t1);
        
        
        Task t2 = new Task();
        t2.WhatId = lao2.Id;
        t2.status = 'open';
        t2.Track_Follow_up__c = true;
        t2.subject = 'proofs follow-up';
        TaskListToInsert.add(t2);
        
        insert TaskListToInsert;        
    }     
}