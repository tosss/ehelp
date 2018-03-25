//2017-05-05 - siva.pragad@cdk.com - edited and added attachmentPreventDelete
trigger ALL_Attachment on Attachment (before delete, after insert, after update) 
{
    if(Trigger.IsAfter)
    {
        ALL_Attachment_Handler.HandleNew(Trigger.New, Trigger.NewMap);
    }
    
    if(Trigger.isBefore && Trigger.isDelete)
    {
        ALL_Attachment_Handler.attachmentPreventDelete(Trigger.old);
    }
}