/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   To Update Forms_Order__c when SubProject_External_Reference__c is inserted
Test Class:    IMP_SperToFormsOrderUpdate_Test
Created on:    07 September 2015.
Code Coverage: 100%
------------------------------------------------------------
History
07/15/15        Vishal Bandari          RQ-04982: Added updateFormOrders method
09/15/15        Siva Pragada            Added null checks for for loop lists and the objects obtained from the maps.
09/17/15        Venkata Shrivol         Added some touch-ups before update call to resolve test class error
2015-11-04      vishal.bandari@cdk.com  RQ-05690: Added code to update on Estimated_Install_Date__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com  RQ-05934: Added code to update Subproject__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com  RQ-05938: Added code to update Client_Manager__c field in Laser_Artwork_Order__c
2016-01-20      vishal.bandari@cdk.com  RQ-06056: Added code to update Project_type__c field in Laser_Artwork_Order__c
------------------------------------------------------------*/
global with sharing class IMP_SubProjectExternalReference_Handler 
{
    public static void beforeInsert(list<SubProject_External_Reference__c> newSObjects) 
    {
        //update the project field via trigger in the backend, rather than allowing the user 
        //to manually select the value of the project field while creating a new Project External Reference
        Set<Id> subProjectIds = new Set<Id>();
        List<SubProject_External_Reference__c> subprojectExternalToUpdate = new List<SubProject_External_Reference__c>();
        
        for(SubProject_External_Reference__c ser: newSObjects)
        {
            if(ser.SubProject__c != null)
            {
                subprojectExternalToUpdate.add(ser);
                
                //Add SubProject Id to set to be used for query in handler
                subProjectIds.add(ser.SubProject__c);
            }
        }
        
        //Process records
        if(!subprojectExternalToUpdate.isEmpty())
        {
            //Update Project value on SubProject External Reference based on SubProject's Project
            IMP_Project_Utility.updateProjectField(null, null,subprojectExternalToUpdate,null, subProjectIds);
        }
        
    }
    
    public static void beforeUpdate(list<SubProject_External_Reference__c> newSObjects, map<Id, SubProject_External_Reference__c> oldSObjectsById) 
    {
        
    }
    
    /*public static void beforeDelete(list<SubProject_External_Reference__c> oldSObjects, map<Id, SubProject_External_Reference__c> oldSObjectsById) 
    {
        
    }*/
    
    public static void afterInsert(list<SubProject_External_Reference__c> newSObjects) 
    {
        List<Id> laoIds = new List<Id>();
        List<Id> subprojectIds = new List<Id>();
        
        if(newSObjects != null && !newSObjects.isEmpty())
        {
            for(SubProject_External_Reference__c sper : newSObjects)
            {
                laoIds.add(sper.LAO_ID__c);
                subprojectIds.add(sper.SubProject__c);
            }
        }
        
        Map<Id,Subproject__c> subprojectMap = new Map<Id,Subproject__c>([
            SELECT Id, Name, Confidential__c, Go_Live_Date__c, Project_Manager__c,Project_Type__c,Comments__c, Contract_Roll_Called__c, Training_Implementation_Client_Mgr__c, Estimated_Install_Date_EID__c, Impact_Project_Numbers__c 
            FROM Subproject__c
            WHERE ID IN: subprojectIds
        ]);
        
        Map<Id,Laser_Artwork_Order__c> laoMap = new Map<Id,Laser_Artwork_Order__c>([
            SELECT Id, Confidential__c, Go_Live_Date__c, 
            Project_Manager__c, Roll_Call_Date__c, SubProject_Comments__c,
            Impact_Project_Numbers__c, By_Pass_Forms_Validation_Rules__c, Estimated_Install_Date__c, Client_Manager__c, Project_Type__c 
            FROM Laser_Artwork_Order__c
            WHERE ID IN: laoIds
        ]);
        
        if(newSObjects != null && !newSObjects.isEmpty() && laoMap != null && !laoMap.isEmpty())
        {
            for(SubProject_External_Reference__c sperObj : newSObjects)
            {
                Laser_Artwork_Order__c laoObj = laoMap.get(sperObj.LAO_ID__c);
                Subproject__c subProjectObj = subprojectMap.get(sperObj.SubProject__c);
                if(laoObj != null && subProjectObj != null)
                {
                    laoObj.By_Pass_Forms_Validation_Rules__c = !laoObj.By_Pass_Forms_Validation_Rules__c;
                    laoObj.Confidential__c = subProjectObj.Confidential__c;
                    laoObj.Go_Live_Date__c = subProjectObj.Go_Live_Date__c;
                    laoObj.Project_Manager__c = subProjectObj.Project_Manager__c;
                    laoObj.Roll_Call_Date__c = subProjectObj.Contract_Roll_Called__c;
                    laoObj.Impact_Project_Numbers__c = subProjectObj.Impact_Project_Numbers__c;
                    
                    //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to update on Estimated_Install_Date__c
                    laoObj.Estimated_Install_Date__c = subProjectObj.Estimated_Install_Date_EID__c;
                    
                    //2015-12-15 vishal.bandari@cdk.com RQ-05934 added code to update on Subproject__c
                    laoObj.SubProject__c                     = subProjectObj.Name;
                    
                    //2015-12-15 vishal.bandari@cdk.com RQ-05938 added code to update on Client_Manager__c
                    laoObj.Client_Manager__c = subProjectObj.Training_Implementation_Client_Mgr__c;
                    
                    //2016-01-20 vishal.bandari@cdk.com RQ-06056 added code to update on SubProject_Comments__c and Project_Type__c
                    laoObj.SubProject_Comments__c = subProjectObj.Comments__c;
                    laoObj.Project_Type__c = subProjectObj.Project_Type__c;
                    
                    laoMap.put(sperObj.LAO_ID__c,laoObj );
                }
            } 
        }
        if(laoMap != null && !laoMap.isEmpty())
        {
            update laoMap.values();
        } 
    }
    
    public static void afterUpdate(list<SubProject_External_Reference__c> newSObjects, map<Id, SubProject_External_Reference__c> oldSObjectsById) 
    {
        
    }
    
    /*public static void afterDelete(list<SubProject_External_Reference__c> oldSObjects, map<Id, SubProject_External_Reference__c> oldSObjectsById) 
    {
        
    }*/
    
    /*public static void afterUndelete(list<SubProject_External_Reference__c> newSObjects, map<Id, SubProject_External_Reference__c> oldSObjectsById) 
    {
        
    }*/
}