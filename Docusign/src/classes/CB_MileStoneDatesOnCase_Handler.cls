public class CB_MileStoneDatesOnCase_Handler 
{
     
    @future
    public static void updateTargetDateTimeAI(Set<Id> newCaseIds)
    {
        Boolean runOnce = ALL_CheckRecursive.runOnce();
        system.debug('-----runOnce---'+runOnce);
        updateTargetDateTime(newCaseIds);
    }
    public static void updateTargetDateTime(Set<Id> newCaseIds)
    {
        try
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
            
           /* if(cnt > 0)*/{ update updateList; }  
        }
        catch(Exception ex){ system.debug('----Exception Caused------'+ex); }  
        
    }
    
    @future
    public static void updateCaseAU(Set<Id> csIds, map<id,String> tempMap, set<Id> targetCaseIds){
        if(tempMap.size() > 0){
            updateCase(csIds, tempMap, true);  
        }              
        Boolean runOnce = ALL_CheckRecursive.runOnce();
        system.debug('-----runOnce---'+runOnce);
        if(targetCaseIds.size() > 0){
            updateTargetDateTime(targetCaseIds);
        }        
    }
    
    public static void updateCaseBU(Set<Id> csIds, map<id,String> tempMap){
        updateCase(csIds, tempMap, false);   
    }
    public static void updateCase(Set<Id> csIds, map<id,String> tempMap, Boolean isAfter){
        
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