/*-----------------------------------------------------
2015-12-21 - venkata.shrivol@cdk.com  - Created
 
-------------------------------------------------------*/

trigger IMP_ProjectLog on Project_Log__c (after insert, before insert, before update, after update) 
{
 	if(Trigger.isBefore)
 	{
 		if(Trigger.isUpdate)
 		{
 			IMP_ProjectLog_Handler.beforeUpdate(Trigger.new, Trigger.oldMap);
 		}
 		if(Trigger.isInsert)
 		{
 			IMP_ProjectLog_Handler.beforeInsert(Trigger.new);
 		}
 	}
    
}