/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   To Update Forms_Order__c and Forms_Collection__c objects when Subproject__c is Updated
Test Class:    IMP_UpdateFormsOrder_Test
Created on:    15 July 2015.
Code Coverage: 100%
------------------------------------------------------------
History
15 July 2015    Vishal Bandari        -  RQ-04982: Added updateFormOrders method
28 July 2015    Siva.Pragada@cdk.com  -  added boolean check to see if the soql query is necessary. 
we need to query only when the field values change. 
28 July 2015    Siva.Pragada@cdk.com  -  separeated the update dml into separate transaction using future update method in Utilities class.
When we have cross object updates 
this would cause Recursive trigger error. We have cross object updates on FO to Task and Task to FO. 
28 July 2015    vishal.bandari@cdk.com - changed the update method to synchronous from future method
2015-11-04      vishal.bandari@cdk.com - RQ-05690: Added code to update Estimated_Install_Date__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com - RQ-05934: Added code to update Subproject__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com - RQ-05938: Added code to update Client_Manager__c field in Laser_Artwork_Order__c
2016-01-20      vishal.bandari@cdk.com - RQ-06056: Added code to update SubProject_Comments__c and Project_Type__c field in Laser_Artwork_Order__c
------------------------------------------------------------*/
//2016-03-03- anirudh.singh@cdk.com- Modified this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
public class IMP_UpdateFormsOrder_Handler 
{
    public static void updateFormOrders(Map<Id, SubProject__c> newSubProjectsMap, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start updateFormOrders---->');
        try
        {
            Boolean fieldValuesChanged=false;
            
            for(SubProject__c subProjectRecord: newSubProjectsMap.values())
            {
                SubProject__c oldSubProjectRecord=oldSubProjectsMap.get(subProjectRecord.Id);
                
                if(subProjectRecord.Go_Live_Date__c!=oldSubProjectRecord.Go_Live_Date__c || 
                   subProjectRecord.Project_Manager__c!= oldSubProjectRecord.Project_Manager__c ||  
                   subProjectRecord.ConfIdential__c!= oldSubProjectRecord.ConfIdential__c ||
                   subProjectRecord.Contract_Roll_Called__c!=oldSubProjectRecord.Contract_Roll_Called__c ||
                   subProjectRecord.Impact_Project_Numbers__c!=oldSubProjectRecord.Impact_Project_Numbers__c || 
                   subProjectRecord.Estimated_Install_Date_EId__c!=oldSubProjectRecord.Estimated_Install_Date_EId__c || 
                   subProjectRecord.Training_Implementation_Client_Mgr__c!=oldSubProjectRecord.Training_Implementation_Client_Mgr__c||
                   subProjectRecord.Comments__c!=oldSubProjectRecord.Comments__c ||
                   subProjectRecord.Project_Type__c!=oldSubProjectRecord.Project_Type__c
                  )
                {
                    fieldValuesChanged=true; 
                    break;
                } 
            }
            
            //added boolean check to see if the soql query is necessary. we need to query only when the field values change. 
            //2015-07-28 - Siva.Pragada@cdk.com
            if(fieldValuesChanged) 
            {
                Map<Id, SubProject_External_Reference__c> subProjectExternalReferenceMap=new Map<Id, SubProject_External_Reference__c>([
                    SELECT Id, LAO_Id__c, SubProject__c
                    FROM SubProject_External_Reference__c
                    WHERE SubProject__c IN: newSubProjectsMap.keySet() 
                    AND LAO_Id__c!=null
                ]);
                
                //2016-03-03- anirudh.singh@cdk.com- Commented the List and using Set now.
                //List<Id> requiredFormsOrderIds=new List<Id>();
                
                //2016-03-03- anirudh.singh@cdk.com- Earlier List was used, changed it to Set to have unique Ids.
                Set<Id> requiredFormsOrderIds=new Set<Id>();
                
                for(SubProject_External_Reference__c subProjectExternalReferenceRecord: subProjectExternalReferenceMap.values())
                {
                    requiredFormsOrderIds.add(subProjectExternalReferenceRecord.LAO_Id__c);
                }
                
                Map<Id, Laser_Artwork_Order__c> formsOrderMap=new Map<Id, Laser_Artwork_Order__c>([
                    SELECT Id, By_Pass_Forms_ValIdation_Rules__c, Project_Type__c, ConfIdential__c, Go_Live_Date__c, Client_Manager__c, SubProject_Comments__c,
                    Project_Manager__c, Roll_Call_Date__c, Impact_Project_Numbers__c, Estimated_Install_Date__c
                    FROM Laser_Artwork_Order__c
                    WHERE Id IN :requiredFormsOrderIds
                ]);
                
                Set<Laser_Artwork_Order__c> uniqueFormsOrder=new Set<Laser_Artwork_Order__c>();
                
                for(SubProject_External_Reference__c subProjectExternalReferenceRecord: subProjectExternalReferenceMap.values())
                {
                    SubProject__c newObj=newSubProjectsMap.get(subProjectExternalReferenceRecord.SubProject__c);
                    Laser_Artwork_Order__c laoObj=formsOrderMap.get(subProjectExternalReferenceRecord.LAO_Id__c);
                    laoObj.By_Pass_Forms_ValIdation_Rules__c=!laoObj.By_Pass_Forms_ValIdation_Rules__c;
                    laoObj.ConfIdential__c=newObj.ConfIdential__c;
                    laoObj.Go_Live_Date__c=newObj.Go_Live_Date__c;
                    laoObj.Project_Manager__c=newObj.Project_Manager__c;
                    laoObj.Roll_Call_Date__c=newObj.Contract_Roll_Called__c;
                    laoObj.Impact_Project_Numbers__c=newObj.Impact_Project_Numbers__c;
                    
                    //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to update on Estimated_Install_Date__c.
                    laoObj.Estimated_Install_Date__c=newObj.Estimated_Install_Date_EId__c;
                    
                    //2015-12-15 vishal.bandari@cdk.com RQ-05934 added code to update on Subproject__c.
                    laoObj.SubProject__c=newObj.Name;
                    
                    //2015-12-15 vishal.bandari@cdk.com RQ-05938 added code to update on Training_Implementation_Client_Mgr__c.
                    laoObj.Client_Manager__c=newObj.Training_Implementation_Client_Mgr__c;
                    
                    //2015-01-20 vishal.bandari@cdk.com RQ-06056 added code to update on SubProject_Comments__c and Project_Type__c.
                    laoObj.SubProject_Comments__c=newObj.Comments__c;
                    laoObj.Project_Type__c=newObj.Project_Type__c;
                    
                    if(!uniqueFormsOrder.contains(laoObj))
                    {
                        uniqueFormsOrder.add(laoObj);
                    }
                }
                
                //Utilities.SerializesObjectList(new List<sobject>(uniqueFormsOrder), 'Update');
                update new List<Laser_Artwork_Order__c>(uniqueFormsOrder);
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception---->'+ex.getMessage());
        }
        system.debug('End updateFormOrders---->');
    }
}