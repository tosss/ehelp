//2017-01-11 - lalitha.adduru@cdk.com - refactored order accuracy trigger -	RQ-06026
trigger DS_OrderAccuracy on Order_Accuracy__c (before insert, before update) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert || trigger.isUpdate)
        {
            DS_OrderAccuracy_Handler.updateAccuracyEmailFields(Trigger.New);
        }
    }
}