/*
01/20/2015 - venkata.shrivol@cdk.com - Added logic to call Docusign API 
01/30/2015 - venkata.shrivol@cdk.com - Added logic to null the values if another envelope is sent. 
03/11/2015 - sanjay.ghanathey@cdk.com - Deal change type Network Needed then workflow will update PSE_Status__c to Open.
*/ 

trigger DS_DealState on Deal_State__c (before insert, after insert, before update, after update)
{
    // 2015-05-21 matt.keefe@cdk.com - this AVP RGM Change condition should not wrap the whole trigger...
    // it is preventing other Deal State trigger logic
    if(Trigger.isBefore && Trigger.isInsert) // before insert
    {
        string PageErrorMessage = 'Only one Deal State may be added per Opportunity. ';
        
        list<Deal_State__c> DealStatesToValidate = new list<Deal_State__c>();
        for(Deal_State__c ds : Trigger.New) 
        {
            if(ds.Opportunity__c != null) 
            {
                DealStatesToValidate.add(ds); 
                
                //sanjay.ghanathey@cdk.com 11-MAR-2015  
                //Deal change type Network Needed then workflow will update PSE_Status__c to Open
                if(ds.get('Network_Needed__c') != null && String.valueOf(ds.get('Network_Needed__c')).toLowerCase() == 'yes') {
                    ds.PSE_Status__c = 'Open'; }
                if(ds.Deal_From_Solution_Design__c == true) {
                    ds.PSE_Status__c = 'Open'; }
            } 
        }
        
        // only one deal state is allowed per Opportunity
        ALL_UtilitiesMiscellaneous.PreventMultipleOnParent(
            DealStatesToValidate, 'Opportunity', 'Opportunity__c', 'Deal_State__r', PageErrorMessage);
        
        // Added by SivaP 3/16/2015 for updating Deal State email fields from Account and Opportunity on Deal State
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_DealState_Handler_Insert'))
        {
            DS_DealState_Handler.DealStateEmailInserts(Trigger.new);
        }
        
        // Khan: commented out this code as it should be before update  DS_DealStateNullifyFields_Handler.nullifyFields(Trigger.New, Trigger.OldMap);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) // before update
    {
        // Added by SivaP 5/7/2015 for updating Deal State email fields from Account and Opportunity on Deal State
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_DealState_Handler_Update'))
        {
            DS_DealState_Handler.DealStateEmailInserts(Trigger.new);
            DS_DealState_Handler.updateSQTNSA(Trigger.new, Trigger.oldMap);
        } 
        //Khan: added nullify call before update
        DS_DealStateNullifyFields_Handler.nullifyFields(Trigger.New, Trigger.OldMap);             
    }
    
    if(Trigger.isAfter) // after insert and after update
    {
        // if a Deal Stated Secured document does not exist for any 
        //   of the inserted Deal States, add one for each
        DS_DealState_Handler.CreateDealStateSecured(Trigger.NewMap);
        
        // update the Deal State ID on Opportunity 
        //   if the Opportunity field is filled in on Deal State
        DS_DealState_Handler.UpdateOpportunityDealStateID(Trigger.New);
        
        
        
        if(Trigger.isUpdate) // after update
        {
            list<Deal_State__c> dsList = new list<Deal_State__c>();            
            DateTime oldValue = null;
            String oldExceptionPush = null;            
            
            for(Deal_State__c dsRec : Trigger.new)
            {
                oldValue = Trigger.oldMap.get(dsRec.id).CA_Approved_Date__c;
                oldExceptionPush = Trigger.oldMap.get(dsRec.id).Exception_Contract_Push__c;
                
                if((dsRec.CA_Approved_Date__c != null && oldValue == null) || (dsRec.Exception_Contract_Push__c != null && oldExceptionPush == null))
                {
                    // Case-1 Add deal state record for updating Contract number if If CA Approved date is filled in
                    // && Old/previous value in the field is null, For automatic update.
                    // Case-2 Exceptional Contract push is filled in, For manual update.
                    
                    dsList.add(dsRec);
                }
            }
            
            if(dsList != null && !dsList.isEmpty())
            {
                // Trigger to execute only once.
                if(ALL_CheckRecursive.runCodeBlockOnce('DS_CallDocusignAPI_Handler'))
                {
                    DS_CallDocusignAPI_Handler.prepareForUpdate(dsList); // Docusign API call.
                }
            }
        }
    }
}