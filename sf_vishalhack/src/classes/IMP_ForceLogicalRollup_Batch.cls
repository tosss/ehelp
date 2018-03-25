/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: 
Test Class: 
History
10/20/15    Kimiko Roberto      Created

------------------------------------------------------------*/
global class IMP_ForceLogicalRollup_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    
    public String query = 'Select Id, Force_Rollup__c,SubProject_ID__c from Project_Activity__c ';
    // public String statusNotEqualTo = '';
    public Integer milestoneCount;
    global List<Project_Activity__c> tempProjectActivityList {get;set;}
    
    //start
    global Database.QueryLocator start(Database.BatchableContext info)
    {
       // List<SubProject__c> subProjectIdList = [Select Id FROM SubProject__c WHERE SubProject_Status__c !=: statusNotEqualTo AND Count_of_Milestones_on_SubProject__c > :milestoneCount];
       List<SubProject__c> subProjectIdList = [Select Id FROM SubProject__c WHERE Count_of_Milestones_on_SubProject__c > :milestoneCount];
       Set<String> subProjectIdSet = new Set<String>();
       system.Debug('***subProjectIdList: '+ subProjectIdList);
       if(subProjectIdList != null && !subProjectIdList.isEmpty())
       {
           for(SubProject__c sp : subProjectIdList)
           {
               String tempIdString = sp.Id;
               tempIdString = tempIdString.substring(0,15);
               subProjectIdSet.add(tempIdString);
           }
           system.Debug('***subProjectIdSet: '+ subProjectIdSet);
           query += 'WHERE SubProject_ID__c IN: subProjectIdSet';
       }
       system.Debug('***query: '+ query);
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Project_Activity__c> projectActivityList)
    {
        system.Debug('***projectActivityList: '+ projectActivityList); 
        tempProjectActivityList = new List<Project_Activity__c>();
        if(projectActivityList!= null && !projectActivityList.isEmpty())
        {
            
            for(Project_Activity__c pa: projectActivityList)
            {
                pa.Force_Rollup__c = true;
            }
                
            update projectActivityList;
            
            //update the force rollup again to false
            for(Project_Activity__c pa: projectActivityList)
            {
                pa.Force_Rollup__c = false;
            }
                
            update projectActivityList;
            
            tempProjectActivityList.addAll(projectActivityList);
            system.Debug('***tempProjectActivityList: '+ tempProjectActivityList);
        }
        
    }     
    
    global void finish(Database.BatchableContext info)
    {
       /* 
       system.Debug('*** before update tempProjectActivityList: '+ tempProjectActivityList);
       if(tempProjectActivityList != null && !tempProjectActivityList.isEmpty())
        {
            for(Project_Activity__c pa: tempProjectActivityList)
            {
                pa.Force_Rollup__c = false;
            }
                
            update tempProjectActivityList;
        }
        
        system.Debug('***after update tempProjectActivityList: '+ tempProjectActivityList);
        */
    }  
    
    
}