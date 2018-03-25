trigger DS_AVPRGMLink_Trigger on AVP_RGM_Link__c (after update) 
{
    if(Trigger.IsAfter && trigger.IsUpdate) 
    {
        DS_DealStateUpdateController_Handler.updateControllerEmail(Trigger.New, Trigger.oldMap);
    }
}