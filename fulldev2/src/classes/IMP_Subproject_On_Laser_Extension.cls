/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Extension for Subproject_On_LAO Visual Force Page
Created on:    30 July 2015.
Test Class:    IMP_UpdateFormsOrder_Test
Code Coverage: 100%
------------------------------------------------------------
History
30 July 2015    Vishal Bandari              RQ-04982: Added getRecordDetails method
2015-11-06      vishal.bandari@cdk.com      RQ-05690: Added Estimated_Install_Date_EID__c and Business_Alignment_Workshop_Date__c fields from Subproject.
2015-12-15      vishal.bandari@cdk.com      RQ-05938: Added Training_Implementation_Client_Mgr__c fields from Subproject.
2016-01-21      vishal.bandari@cdk.com      RQ-06056: Added Comments__c and Project_Type__c fields from Subproject.
2016-02-15      vishal.bandari@cdk.com      RQ-06313: Added Subproject_Status__c fields from Subproject.
------------------------------------------------------------*/
//2016-03-08- anirudh.singh@cdk.com- Commented this class due to naming standards issue. Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
public class IMP_Subproject_On_Laser_Extension
{
    /*private Id LAO_RecordId;
    
    public SubProject_External_Reference__c sperObj {get;set;}
    
    public IMP_Subproject_On_Laser_Extension(ApexPages.StandardController stdController)
    {
        LAO_RecordId = stdController.getId();
    }
    
    public void getSubprojectDetails()
    {
        try
        {     
            if(LAO_RecordId != null)
            {
                //2015-11-06 vishal.bandari@cdk.com RQ-05690 added Business_Alignment_Workshop_Date__c and Estimated_Install_Date_EID__c fields in SOQL
                //2015-12-15 vishal.bandari@cdk.com RQ-05938 added Training_Implementation_Client_Mgr__c fields in SOQL
                //2015-01-07 vishal.bandari@cdk.com RQ-06056 added Comments__c and Project_Type__c fields in SOQL
                //2015-02-15 vishal.bandari@cdk.com RQ-06313 added Subproject_Status__c fields in SOQL
                sperObj = [
                    SELECT SubProject__c, SubProject__r.Business_Alignment_Workshop_Date__c, 
                    SubProject__r.Comments__c, SubProject__r.Confidential__c, SubProject__r.Contract_Roll_Called__c,
                    SubProject__r.Estimated_Install_Date_EID__c, SubProject__r.Go_Live_Date__c, SubProject__r.Impact_Project_Numbers__c,
                    SubProject__r.Name, SubProject__r.Project_Manager__c, SubProject__r.Project_type__c, SubProject__r.SubProject_Status__c,
                    SubProject__r.Training_Implementation_Client_Mgr__c
                    FROM SubProject_External_Reference__c 
                    WHERE LAO_ID__c =: LAO_RecordId
                    LIMIT 1
                ];
            }
        }
        catch(Exception e)
        {
            System.debug('Exception: '+e.getMessage()+' At '+e.getLineNumber());
        }
    }*/
}