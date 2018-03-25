public class DEP_Changeset_Handler 
{
    public static void beforeInsert(List<Change_Set__c> newTrigger)
    {
        
    }
    public static void beforeUpdate(List<Change_Set__c> newTrigger, Map<Id,Change_Set__c> oldMap)
    {
        
    }
    public static void beforeDelete(List<Change_Set__c> oldTrigger)
    {
        
    }
    public static void afterInsert(List<Change_Set__c> newTrigger)
    {
        List<Change_Set_Deployment__c> unifiedDeployments = new List<Change_Set_Deployment__c>();
        for(Change_Set__c changeSetObj : newTrigger)
        {
            if(!changeSetObj.Major_Release__c)
            {
                unifiedDeployments.add(new Change_Set_Deployment__c(
                    Sandbox__c = 'ap1 Production',
                    Change_Set__c = changeSetObj.Id,
                    Sandbox_Type__c = 'QA',
                    Deployment_Strategy__c = 'RunLocalTests',
                    Deployment_Order__c = 1
                ));
            }
        }
        if(unifiedDeployments.size() > 0)
        {
            insert unifiedDeployments;
        }
    }
    public static void afterUpdate(List<Change_Set__c> newTrigger, Map<Id,Change_Set__c> oldMap)
    {
        
    }
    public static void afterDelete(List<Change_Set__c> oldTrigger)
    {
        
    }
}