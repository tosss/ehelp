// 2015/11/26- lalitha.adduru@cdk.com- Created Trigger on Lead Object
//2016-03-11 lalitha.adduru@cdk.com Pardot should be able to bypass this trigger - RQ-06431
//2016-03-18 harisantosh.kadiyala@cdk.com RQ-06431
//2016-04-16- venkata.shrivol@cdk.com -commented out the afterUpdate reference to CreateOppUsingLead method
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on )while running trigger code - RQ-06909 
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
//2017-03-31 - lalitha.adduru@cdk.com - commented this class as it's moved to ALL_Lead - RQ-06389
trigger DS_UpdateLead on Lead (before insert, before update, after insert, after update)
{
    /*list<Lead> newLeadList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Lead');
    if(newLeadList != null && !newLeadList.isEmpty())
    {
 		GlobalSettings__c globalSettings = GlobalSettings__c.getInstance();
        String MgrMgrExcludeRoles = globalSettings.Lead_Owner_Mgrs_Mgr_Roles_to_Exclude__c;
        if(MgrMgrExcludeRoles != null)
        {
            MgrMgrExcludeRoles = MgrMgrExcludeRoles.toLowerCase();
        }
        //2016-03-11 lalitha.adduru@cdk.com - get the new leads that are not being created from pardot - RQ-06431
        List<Lead> leadsNotFromPardot = new List<Lead>();
        List<Lead> leadsFromPardot = new List<Lead>();
        
        if(newLeadList != null && !newLeadList.isEmpty())
        {  
            Set<Id> recordTypeIdSet = new Set<Id>();
            for(Lead newLead : newLeadList)
            {
                if(newLead.recordTypeId != null)
                {
                    recordTypeIdSet.add(newLead.recordTypeId);
                }
            }
            
            Map<Id,recordType> recordTypeToNameMap = new Map<Id,recordType>([SELECT id, name FROM recordType WHERE id in :recordTypeIdSet]);
            
            for(Lead newLead : newLeadList)
            {
                String CreatedByEmail = userinfo.getuseremail() == null ? '' : userinfo.getuseremail(); // changed from createdBy to userinfo as createdBy would be empty before insert
                system.debug('CreatedByEmail -->'+CreatedByEmail);
                String RecordTypeName = recordTypeToNameMap.get(NewLead.RecordTypeId) == null ? '' : recordTypeToNameMap.get(NewLead.RecordTypeId).name;
                
                // if the lead is not being created from pardot, add it to the list
                if(!(RecordTypeName == 'Marketing Lead'))
                {
                    leadsNotFromPardot.add(newLead);
                }
                else 
                {
                    leadsFromPardot.add(newLead);
                }
            }
            system.debug('leadsNotFromPardot --> '+leadsNotFromPardot);
        }
        
        if (Trigger.isBefore)
        {
            DS_UpdateLead_Handler updateLeadRef = new DS_UpdateLead_Handler();
            
            // 2014-02-24 MK - added Contact phone sync
            if (Trigger.isInsert)
            {       
                //2016-03-11 lalitha.adduru@cdk.com - Send leadsNotFromPardot instead of trigger.New  - RQ-06431
                updateLeadRef.ContactPhoneSync(Trigger.OldMap, leadsNotFromPardot);
            }
            // END 2014-02-24 MK - added Contact phone sync
            
            if(Trigger.isUpdate)
            {
                updateLeadRef.UpdateOwnerDetails(Trigger.OldMap, newLeadList, MgrMgrExcludeRoles);
                for(Lead ld:newLeadList)
                {
                    if(ld.Status == 'Converted to Opportunity')
                    {
                        ld.Cancel_Workflows__c = true;
                    }
                }
            }
            
            if(Trigger.isInsert)
            {
                updateLeadRef.updateVendorInstallDate(leadsNotFromPardot, MgrMgrExcludeRoles);
                set<String> leadOwnerSet = new set<String>();
                for(Lead ld:leadsFromPardot)
                {
                    leadOwnerSet.add(ld.OwnerId);
                }
                updateLeadRef.updateOwners(leadsFromPardot, leadOwnerSet,MgrMgrExcludeRoles);
            }
        }
        
        if(Trigger.isAfter)
        {
            DS_UpdateLead_Handler updateLeadRef = new DS_UpdateLead_Handler();
            
            if(Trigger.isInsert)
            {
                //2016-03-11 lalitha.adduru@cdk.com - Send leadsNotFromPardot instead of trigger.New - RQ-06431
                updateLeadRef.createLeadShare(leadsNotFromPardot);
            }
            //RQ-06420 - HariSantosh.kadiyala@cdk.com
            if(Trigger.isUpdate)
            {
                /* set<Id> LeadIds = new set<Id>();
//updateLeadRef.CreateOppUsingLead(Trigger.NewMap);
for(Lead l:Trigger.New)
{
Lead oldLead = Trigger.oldMap.get(l.Id);
if(l.Status =='Converted to Opportunity' && oldLead.Status != l.Status)
{
LeadIds.add(l.Id);
}

}
if(!LeadIds.isEmpty() && ALL_CheckRecursive.runCodeBlockOnce('CreateOppUsingLead'))
{
DS_UpdateLead_Handler.CreateOppUsingLead(LeadIds);
}
// updateLeadRef.CreateOppUsingLead(Trigger.NewMap);
            }
        }
                
    }*/
}