//2016-05-26 - vishal.bandari@cdk.com - created the class - RQ-07013
//2016-07-13 - ragashalini.koka@cdk.com - modified the class - RQ-07327
//2016-11-02 - ragashalini.koka@cdk.com - added the method updateServiceConnectVisitTracking - RQ-08117
//2017-05-12- anirudh.singh@cdk.com- Modified for RQ-09232
//2017-05-12- anirudh.singh@cdk.com- Formatted and corrected a few name casing. Used String.isNotEmpty method.
public class ALL_Task_Handler 
{
    public static void updatePrimaryAccountIds(List<sObject> newTasksList)
    {
        try
        {
            if(ALL_CheckRecursive.runCodeBlockOnce('UpdateTaskAccountIds'))
            {
                ALL_TaskEvent_Helper.populatePrimaryAccField(newTasksList);
            }
        }
        catch(Exception ex)
        {
            system.debug('ALL_Task_Handler Exception: '+ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
    //2016-11-02 - ragashalini.koka@cdk.com - update the DS_Service_Connect_Visit__c field on the Account
    public static void updateServiceConnectVisitTracking(Map<Id, sObject> newMap, String objectName) 
    {
        ALL_TaskEvent_Helper.updateServiceConnectVisitTracking(newMap, objectName);
    }
}