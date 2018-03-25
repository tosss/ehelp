//2016-12-22   vishal.bandari@cdk.com    RQ-08092-created the trigger
trigger DS_CDKDocusignCCs on CDK_Docusign_CCs__c (before insert,before update, before delete) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            DS_CDKDocusignCCs_Handler.beforeInsert(Trigger.new);
        }
        if(Trigger.IsUpdate)
        {
            DS_CDKDocusignCCs_Handler.beforeUpdate(Trigger.new);
        }
        if(Trigger.IsDelete)
        {
            DS_CDKDocusignCCs_Handler.beforeDelete(Trigger.old);
        }
    }
}