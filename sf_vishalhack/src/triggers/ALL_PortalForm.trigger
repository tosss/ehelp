/*******************************************************************************
** RQ-08648 02/22/2017 Created Vijay.Manimaran@cdk.com

********************************************************************************* */
trigger ALL_PortalForm on Portal_Form__c (before insert, before update, after update) {
    system.debug('am here ');
    
    if(Trigger.isBefore)
    {
        
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_PortalForm_Handler_Update')){
            ALL_PortalForm_Handler.insertUpdateWorkflow(Trigger.new);     	
        }
    } 
    
    if(Trigger.isAfter && ALL_CheckRecursive.runCodeBlockOnce('AccountHandlerAfterDelete'))
    {            
        Id portalFormsRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'Manager Termination Form');
        Id portalFormsPRCRecordTypeID =ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Portal_Form__c', 'COM Bank of America');
        set<ID> portalFormsIds = new set<ID>();
        set<ID> updateportalFormsIds = new set<ID>();
        for(Portal_Form__c PF: Trigger.new){
                                            system.debug('am in delete');

            if(PF.Mgr_Term_Form_Completed__c == true || PF.PRC_Status__c == 'Closed'){
                                system.debug('am in delete');

                portalFormsIds.add(PF.Id);
            }
            if(PF.RecordTypeId == portalFormsPRCRecordTypeID || PF.RecordTypeId == portalFormsRecordTypeID){
                updateportalFormsIds.add(PF.Id);
            }
        }
        if(!portalFormsIds.isEmpty()){
            ALL_PortalForm_Handler.deletePortalForms(portalFormsIds);
        }
        if(!updateportalFormsIds.isEmpty()){
            ALL_PortalForm_Handler.updatePortalForms(updateportalFormsIds);
        }
    }
}