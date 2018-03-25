//2016-11-09 - lalitha.adduru@cdk.com - created -  RQ-08111
trigger ALL_ADPDefaultTeamMembers on ADP_Default_Team_Members__c (after insert, after delete, after update) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            Map<String, List<ADP_Default_Team_Members__c>> filteredRecords = new Map<String, List<ADP_Default_Team_Members__c>>();
            filteredRecords = ALL_TriggerToggle_Handler.ToggleFilter(Trigger.New);
            if(filteredRecords.get('New OEM Sales Team Member') != null)
            {
                ALL_ADPDefaultTeamMembers_Handler.addRequiredAccountTeams(filteredRecords.get('New OEM Sales Team Member'));
            }
        }
        if(Trigger.isDelete)
        {
            Map<String, List<ADP_Default_Team_Members__c>> filteredRecords = new Map<String, List<ADP_Default_Team_Members__c>>();
            filteredRecords = ALL_TriggerToggle_Handler.ToggleFilter(Trigger.Old);
            if(filteredRecords.get('New OEM Sales Team Member') != null)
            {
                ALL_ADPDefaultTeamMembers_Handler.deleteRelatedAccountTeams(filteredRecords.get('New OEM Sales Team Member'));
            }
        }
        if(Trigger.isAfter)
        {
            if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('After Update Team Member'))
            {
                Map<String, List<ADP_Default_Team_Members__c>> filteredRecords = new Map<String, List<ADP_Default_Team_Members__c>>();
                filteredRecords = ALL_TriggerToggle_Handler.ToggleFilter(Trigger.New);
                if(filteredRecords.get('New OEM Sales Team Member') != null)
                {
                    ALL_ADPDefaultTeamMembers_Handler.updateRequiredAccountTeams(filteredRecords.get('New OEM Sales Team Member'), Trigger.OldMap);
                }           
            }
            
            
        }
    }
}