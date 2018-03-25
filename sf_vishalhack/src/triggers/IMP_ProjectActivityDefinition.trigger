/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Consolidated Project Activity Definition triggers
Test Class:
History
07/28/2015    Kimiko Roberto    Created
09/15/2015    Rey Austral       Prevent deleting record that is active
------------------------------------------------------------*/
trigger IMP_ProjectActivityDefinition on Activity_Definition__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            
        }
        else if(Trigger.isUpdate)
        {
        
        }
        else if(Trigger.isDelete)
        {
            //2015-09-15 Rey Austral - Validate if the user can delete the record
            for(Activity_Definition__c actDef : trigger.old)
            {
                if (actDef.Active__c == true)
                {
                    actDef.addError(IMP_String_Utility.DELETE_ACTIVE_DEFINITION);
                }
                else if (actDef.Total_Task_Definition_Children__c > 0 )
                {
                    actDef.addError(IMP_String_Utility.DELETE_HAS_ACTIVE_CHILD_TASK);
                }
            }
        }
    }
    else if (Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            //get SFInstanceIdentifier from custom setting Custom_Settings__c; this will be part of the migrationId
            String SFInstanceIdentifier;
            CustomSettings__c cs = CustomSettings__c.getInstance();
            if(cs.SF_Instance_Identifier__c != null && cs.SF_Instance_Identifier__c != '')
            {
                SFInstanceIdentifier = cs.SF_Instance_Identifier__c;
            }
            //Assign a migration id to newly created definitions using the definition's name and SFInstanceIdentifier's value
            IMP_SetMigrationIDtoDefinitions_Handler.setMigrationId(trigger.new, Activity_Definition__c.getSObjectType().getDescribe(), SFInstanceIdentifier);
        }
        else if(Trigger.isUpdate)
        {
        
        }
        else if(Trigger.isDelete)
        {
        
        }
    }

}