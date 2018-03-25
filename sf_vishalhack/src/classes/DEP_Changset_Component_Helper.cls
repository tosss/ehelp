public class DEP_Changset_Component_Helper 
{
    public static void uniqueCheck(List<Change_Set_Component__c> newTrigger)
    {
        Set<String> sandboxNames = new Set<String>();
        Set<String> componentNames = new Set<String>();
        Set<String> ApiNames = new Set<String>();
        Map<String,Change_Set_Component__c> allComponents = new Map<String,Change_Set_Component__c>();
        for(Change_Set_Component__c changesetComponentObj : newTrigger)
        {
            sandboxNames.add(changesetComponentObj.Sandbox__c);
            componentNames.add(changesetComponentObj.Component_Name__c);
            ApiNames.add(changesetComponentObj.Component_Type__c);
            allComponents.put(changesetComponentObj.Sandbox__c+changesetComponentObj.Component_Name__c+changesetComponentObj.Component_Type__c,changesetComponentObj);
        }
        List<Change_Set_Component__c> componentSetComponent = [
            SELECT Change_Set__r.Name,Change_Set__r.CreatedBy.Name, Change_Set__r.LastModifiedBy.Name,Component_Type__c,
            Change_Set__r.CreatedBy.Email,Change_Set__r.LastModifiedBy.Email, Sandbox__c, Component_Name__c
            FROM Change_Set_Component__c
            WHERE (Sandbox__c IN: sandboxNames
            OR Component_Name__c IN: componentNames
            OR Component_Type__c IN: ApiNames)
        ];
        
        for(Change_Set_Component__c changesetComponentObj : componentSetComponent)
        {
            if(allComponents.containsKey(changesetComponentObj.Sandbox__c+changesetComponentObj.Component_Name__c+changesetComponentObj.Component_Type__c))
            {
                allComponents.get(changesetComponentObj.Sandbox__c+changesetComponentObj.Component_Name__c+changesetComponentObj.Component_Type__c).addError('Component is already used in '
                +changesetComponentObj.Change_Set__r.Name+', Please contact <a href="mailto:'+changesetComponentObj.Change_Set__r.CreatedBy.Email+'">'+changesetComponentObj.Change_Set__r.CreatedBy.Name+'</a>'
                +(changesetComponentObj.Change_Set__r.CreatedBy.Name != changesetComponentObj.Change_Set__r.LastModifiedBy.Name ? ' or <a href="mailto:'+changesetComponentObj.Change_Set__r.LastModifiedBy.Email+'">'+changesetComponentObj.Change_Set__r.LastModifiedBy.Name+'</a>':''));
            }
        }
    
    }
}