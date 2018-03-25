//2017-03-22 lalitha.adduru@cdk.com created this handler - RQ-08780
trigger ALL_EmployeeInformation on Employee_Information__c (before insert, before update) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            ALL_EmployeeInformation_Handler.setOwnerId(Trigger.New, Trigger.OldMap);
        }
    }

}