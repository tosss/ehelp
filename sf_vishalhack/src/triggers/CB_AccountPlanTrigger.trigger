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
        
        if ((Trigger.isInsert || Trigger.isupdate) && 
            ALL_CheckRecursive.runCodeBlockOnce('daaAccountPlanHandler20151119'))
        {
            CB_DaaAccountPlanWebIdUpdate_Handler.daaAccountPlanHandler();             
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
    			string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Account_Plan__c', aPlan.RecordTypeId);
                
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
    			string RecordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Account_Plan__c', aPlan.RecordTypeId);
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