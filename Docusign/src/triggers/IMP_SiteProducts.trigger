/*
*-----HISTORY--------
* 05/18/2015 Venkata Shrivol - Created
*
*
*
*
*/
trigger IMP_SiteProducts on Site_Product__c (before insert, after insert, before delete) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isDelete)
        {
            IMP_DeleteAnsOnSiteProdsDelete_Handler.deleteAnswers(Trigger.oldMap.keySet());
        }
    }
    if(Trigger.isInsert)
    {
        if(Trigger.isAfter)
        {
            IMP_AddAnsOnSiteProdsInsert_Handler.addAnswers(Trigger.newMap.keySet());
        }
    }
    
}