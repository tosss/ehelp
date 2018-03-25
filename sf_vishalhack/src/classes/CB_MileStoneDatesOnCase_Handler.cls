public class CB_MileStoneDatesOnCase_Handler 
{ 
    public static void updateCases(list<Case> completionDateCasesBU, Map<Id, Case> oldMap)
    {  
        Set<Id> csIds = new set<id>();
        
        Set<String> WaitingOnValueSet = new Set<String>(); //{'WaitingCustomer', 'WaitingSales', 'WaitingEnterprise Sales', 
            //'WaitingFinance', 'WaitingOther - Tier 3', 'Waiting3rd Party', 
            //'WaitingProgram Concerns', 'WaitingFinal Review/Approval'};
        
        Set<String> settings = CB_CaseWaitingOnPicklistValues__c.getAll().keySet();
        
        if(settings != null)
        {
            for(String pickValue: settings)
            {
                WaitingOnValueSet.add('Waiting' + pickValue);
            }
        }
        
        
        for(Case newCase: completionDateCasesBU)
        {                                          
            Case oldCase = oldMap.get(newCase.id);
            
            String newCombo = newCase.Status + newCase.Waiting_on__c;
            String oldCombo = oldCase.Status + oldCase.Waiting_on__c;
            boolean comboChanged = (newCombo != oldCombo);
            
            if(newCase.status.containsIgnoreCase('Closed')||
               (newCase.status.containsIgnoreCase('Resolved') && 
                !oldCase.status.containsIgnoreCase('Resolved') && 
                !oldCase.status.containsIgnoreCase('Closed'))) 
            {
                csIds.add(newCase.id);
            }
            
            if(ALL_CheckRecursive.runCodeBlockOnce('runOnce_4@Case'))
            {
                if(comboChanged && WaitingOnValueSet.contains(newCombo))
                {
                    newCase.IsStopped = true;  
                }
                
                if(!WaitingOnValueSet.contains(newCombo))
                {
                    newCase.IsStopped = false; 
                }
            }
        }  
               
        if(csIds.size() > 0)
        {
            CB_MileStoneDatesOnCase_Handler.updateCaseBU(csIds);                        
        }
        
    }
    
    @future
    public static void updateTargetDateTimeAI(Set<Id> newCaseIds)
    {
        //Boolean runOnce = ALL_CheckRecursive.runCodeBlockOnce('updateTargetDateTimeAI');
        //system.debug('-----runOnce---'+runOnce);
        updateTargetDateTime(newCaseIds);
    }
    public static void updateTargetDateTime(Set<Id> newCaseIds)
    {
        /*try
        {
            Integer cnt = 0;
            
            list<Case> updateList = [
                Select Id, Target_Date_Time__c,
                (SELECT Id, TargetDate FROM CaseMilestones limit 1) 
                From Case 
                where Id 
                IN: newCaseIds
            ];
            
            for(Case cs: updateList)
            {
                integer totalMileStones = (cs.CaseMilestones != null && !cs.CaseMilestones.isEmpty())?cs.CaseMilestones.size():0;
                CaseMilestone cm = totalMileStones > 0 ? cs.CaseMilestones[0] : new CaseMilestone();
                
                if(totalMileStones == 0){ cs.Target_Date_Time__c = null; }
                
				if(cm.TargetDate!= null && cs.Target_Date_Time__c != cm.TargetDate)
                {
                    cnt++;
                    cs.Target_Date_Time__c = cm.TargetDate;
                }                
            }
            
            if(cnt > 0){ update updateList; }  
        }
        catch(Exception ex){ system.debug('----Exception Caused------'+ex); } */
        
    }
    
    @future
    public static void updateCaseAU(Set<Id> csIds, set<Id> targetCaseIds){
        if(csIds.size() > 0){
            updateCase(csIds, true);  
        }              
        //ALL_CheckRecursive.runCodeBlockOnce('updateCaseAU');
        //system.debug('-----runOnce---'+runOnce);
        if(targetCaseIds.size() > 0){
            updateTargetDateTime(targetCaseIds);
        }        
    }
    
    public static void updateCaseBU(Set<Id> csIds){
        updateCase(csIds, false);   
    }
    public static void updateCase(Set<Id> csIds, Boolean isAfter){
        
        list<CaseMilestone> cmLst = [Select Id, CaseId, CompletionDate from CaseMilestone where CaseId in :csIds];
        for(CaseMilestone cm : cmLst){
            //cm.CompletionDate = closedCasesMap.get(cm.CaseId).SlaExitDate;
            if(!isAfter){
                cm.CompletionDate = System.now();
            }else{
                cm.CompletionDate = null;
            }
            
        }
        try{
        	update cmLst;   
        }catch(Exception e){
            system.debug('--------e-----'+e);
        }
    }

}