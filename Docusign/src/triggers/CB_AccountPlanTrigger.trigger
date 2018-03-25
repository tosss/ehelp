/*
03/05/2015 Venkata Shrivol - Updated Trigger logic to pass the Creative Case limit
                             from DAA Account Plan to related WebID and cases;
*/
Trigger CB_AccountPlanTrigger on Account_Plan__c(Before Update, Before Insert, Before Delete, After Insert, After Update) 
{
    if (Trigger.isBefore) 
    {
        if (Trigger.isUpdate) 
        {
            if (CB_AccountPlanTriggerHandler.hasAlreadyRanBeforeUpdate == false) 
            {
                CB_AccountPlanTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }
        
        if (Trigger.isInsert || Trigger.isupdate) 
        {
            map<Id, Account_Plan__c> DaaAccountPlansMap = new map<Id, Account_Plan__c>();
            
            for (Account_plan__c ap : Trigger.New) 
            {
                // set Unique AP ID
                ap.Unique_AP_ID__c = string.valueof(ap.webid__C) + ap.recordtypeid;
                
                // Collect WebIds on the DAA Account Plans for request RQ-03704           
                string RecordTypeName = Utilities.getRecordTypeNameOfAnySObject('Account_Plan__c', ap.RecordTypeId);
                
                if(RecordTypeName == 'DAA Account Plan')
                {
                   DaaAccountPlansMap.put(ap.Id, ap);
                } 
            }
            
            // this is for RQ-03704: updating WebId DA_Echelon_Level__c with AP(DAA account Plan)'s DA_Echelon_Level__c field
            CB_DaaAccountPlanWebIdUpdate_Handler.WebIdUpdateMethod(DAAAccountPlansMap, Trigger.new, Trigger.oldMap); system.debug(DAAAccountPlansMap);
        }
        
        if(Trigger.isDelete)
        {
            CB_DaaAccountPlanWebIdUpdate_Handler.APDeleted(Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter)
    {
    	if(Trigger.isInsert)
        {
    		map<Id, decimal> cclimitMap = new map<Id, decimal>();
            
    		for(Account_plan__c aPlan : Trigger.new)
    		{
    			string RecordTypeName = Utilities.getRecordTypeNameOfAnySObject('Account_Plan__c', aPlan.RecordTypeId);
                
    			if(aPlan.Creative_Case_Limit__c!= null && RecordTypeName == 'DAA Account Plan')
    			{
    				cclimitMap.put(aPlan.WebID__c, aPlan.Creative_Case_Limit__c);
    			}
    		}
    		// To update the Creative case limit from Account Plan to related WebID's and cases
    		if(!cclimitMap.isEmpty())
            {
    			CB_CretiveCseLimitUpdteWebIDCase_Handler.creativeCaseLimitUpdate(cclimitMap);
    		}
    		
    	}
        
    	if(Trigger.isUpdate)
        {
    		map<Id, decimal> cclimitMap = new map<Id, decimal>();
    		decimal oldLimitValue = null;
            
    		for(Account_plan__c aPlan : Trigger.new)
    		{
    			string RecordTypeName = Utilities.getRecordTypeNameOfAnySObject('Account_Plan__c', aPlan.RecordTypeId);
    			oldLimitValue = Trigger.oldMap.get(aPlan.Id).Creative_Case_Limit__c;
                
    			if((aPlan.Creative_Case_Limit__c!= null) && 
                   (oldLimitValue!= aPlan.Creative_Case_Limit__c) && 
                   (RecordTypeName == 'DAA Account Plan'))
                {
    				cclimitMap.put(aPlan.WebID__c, aPlan.Creative_Case_Limit__c);
    			}
    		}
    		// To update the Creative case limit from Account Plan to related WebID's and cases
    		if(!cclimitMap.isEmpty())
            {
    			CB_CretiveCseLimitUpdteWebIDCase_Handler.creativeCaseLimitUpdate(cclimitMap);
    		}
    	}
    } 
}