/*--------------------------------------
RQ-05471 - SubProject Privacy Phase-II
2016-02-05 -venkata.shrivol@cdk.com - created
---------------MODIFICATIONS-----------------------
2016-05-09 -venkata.shrivol@cdk.com -modified as per the new restrictions on sharing objects
-----------------------------------------*/
trigger IMP_SubProjectCDKContact on SubProject_CDK_Contact__c (after insert, after update, before delete) 
{
  if(Trigger.isAfter)
  {
  	if(Trigger.isInsert)
  	{
  		IMP_SubProjectCDKContact_Handler.afterInsert(Trigger.NewMap);
  	}
  	else if(Trigger.isUpdate)
  	{
  		IMP_SubProjectCDKContact_Handler.afterUpdate(Trigger.NewMap, Trigger.oldMap);
  	}
  }
 else if(Trigger.isBefore)
  {
  	if(Trigger.isDelete)
  	{
  		IMP_SubProjectCDKContact_Handler.beforeDelete(Trigger.oldMap);
  	}
  }
     
}