//2016-03-08- anirudh.singh@cdk.com- Created this class in place of class IMP_Subproject_On_Laser_Extension. 
//                                   Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
public class IMP_SubProjectOnFormsOrder_Extension
{
    private Id formsOrderRecordId;
    
    public SubProject_External_Reference__c subProjectExternalReferenceRecord{get; set;}
    
    public IMP_SubProjectOnFormsOrder_Extension(ApexPages.StandardController stdController)
    {
        formsOrderRecordId=stdController.getId();
    }
    
    public void fetchSubProjectDetails()
    {
        system.debug('Start fetchSubProjectDetails---->');
        try
        {     
            if(formsOrderRecordId!=Null)
            {
                //2015-11-06 vishal.bandari@cdk.com RQ-05690 added Business_Alignment_Workshop_Date__c and Estimated_Install_Date_EID__c fields in SOQL
                //2015-12-15 vishal.bandari@cdk.com RQ-05938 added Training_Implementation_Client_Mgr__c fields in SOQL
                //2015-01-07 vishal.bandari@cdk.com RQ-06056 added Comments__c and Project_Type__c fields in SOQL
                //2015-02-15 vishal.bandari@cdk.com RQ-06313 added Subproject_Status__c fields in SOQL
                subProjectExternalReferenceRecord=[
                    SELECT SubProject__c, SubProject__r.Business_Alignment_Workshop_Date__c, 
                    SubProject__r.Comments__c, SubProject__r.Confidential__c, SubProject__r.Contract_Roll_Called__c,
                    SubProject__r.Estimated_Install_Date_EID__c, SubProject__r.Go_Live_Date__c, SubProject__r.Impact_Project_Numbers__c,
                    SubProject__r.Name, SubProject__r.Project_Manager__c, SubProject__r.Project_type__c, SubProject__r.SubProject_Status__c,
                    SubProject__r.Training_Implementation_Client_Mgr__c
                    FROM SubProject_External_Reference__c 
                    WHERE LAO_ID__c =: formsOrderRecordId
                    LIMIT 1
                ];
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception: '+ex.getMessage()+' at '+ex.getLineNumber());
        }
        system.debug('End fetchSubProjectDetails---->');
    }
}