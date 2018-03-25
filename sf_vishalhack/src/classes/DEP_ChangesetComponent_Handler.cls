public class DEP_ChangesetComponent_Handler
{
    public static void beforeInsert(List<Change_Set_Component__c> newTrigger)
    {
        DEP_Changset_Component_Helper.uniqueCheck(newTrigger);
    }
    public static void beforeUpdate(List<Change_Set_Component__c> newTrigger, Map<Id,Change_Set_Component__c> oldMap)
    {
        
    }
    public static void beforeDelete(List<Change_Set_Component__c> oldTrigger)
    {
        
    }
    public static void afterInsert(List<Change_Set_Component__c> newTrigger)
    {
        
    }
    public static void afterUpdate(List<Change_Set_Component__c> newTrigger, Map<Id,Change_Set_Component__c> oldMap)
    {
        
    }
    public static void afterDelete(List<Change_Set_Component__c> oldTrigger)
    {
        
    }
}