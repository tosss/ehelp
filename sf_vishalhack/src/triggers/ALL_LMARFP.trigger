/*----------------------------------------------------------------------
* RQ-06982
* 2016-05-20 lalitha.adduru@cdk.com - RQ-06982
* Description: Trigger on CB_911_Escalation__c Object
Added functionality : Trigger to populate Contact Relationship Lookup on insert and on update(only when account or contact is changed)
* ---------------------------MODIFICATIONS-----------------------------
* 2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
* 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
* 2016-06-28 - vijay.manimaran@cdk.com Added the comments  header.
* 2016-07-01 - moved code to CB_LMARFP_Handler- siva.pragada@cdk.com
* 2017-04-10  - vishal.bandari@cdk.com - added beforeInsert and beforeUpdate method  - RQ-09018
------------------------------------------------------------------------*/
trigger ALL_LMARFP on LMA_RFP__c(before insert, after insert, before update, after update)
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            CB_LMARFP_Handler.beforeInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.IsUpdate)
        {
            CB_LMARFP_Handler.beforeUpdate(Trigger.New, Trigger.oldMap);
        }
    }
    else if(Trigger.IsAfter)
    {
        if(Trigger.IsInsert)
        {
            CB_LMARFP_Handler.afterInsert(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.IsUpdate)
        {
            CB_LMARFP_Handler.afterUpdate(Trigger.New, Trigger.oldMap);
        }
    }
    
}