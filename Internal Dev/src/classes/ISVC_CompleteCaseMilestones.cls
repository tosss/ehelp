// GLOBIT-3994: Create Auto Close Entitlement - Case Milestone Trigger
//
// 2017-10-25 marta.malinowska@cdk.com Created
// Implement Queueable so that we can call this class from within a batch job
public class ISVC_CompleteCaseMilestones implements Queueable {

    public static final String FIRST_RESPONSE = 'First Response';
    public static final String RESOLUTION = 'Resolution';
    public static Set<Id> caseIds = new Set<Id>();
    
    public ISVC_CompleteCaseMilestones(Set<Id> caseIds) {
    		ISVC_CompleteCaseMilestones.caseIds = caseIds;
    }
    
    public void execute(QueueableContext context) {
    		Map<Id, Case> cases = new Map<Id, Case>([SELECT Id, OwnerId, IsClosed FROM Case WHERE Id IN :ISVC_CompleteCaseMilestones.caseIds AND Status != 'Closed']);
        closeInternalSupportMilestones(cases);
    }

    @future
    public static void closeInternalSupportMilestones(Set<Id> caseIds){
        Map<Id, Case> cases = new Map<Id, Case>([SELECT Id, OwnerId, IsClosed FROM Case WHERE Id IN :caseIds AND Status != 'Closed']);
        closeInternalSupportMilestones(cases);
    }

    public static void closeInternalSupportMilestones(Map<Id, Case> cases){
        Map<Id, List<CaseMilestone>> openCaseMilestones = getOpenCaseMilestones(cases.keySet());
        List<CaseMilestone> caseMilestonesToClose = getInternalSupportMilestonesToClose(cases, openCaseMilestones);

        if(!caseMilestonesToClose.isEmpty()){
            Set<Id> caseIds = new Set<Id>();
            for(CaseMilestone caseMilestone : caseMilestonesToClose){
                caseMilestone.CompletionDate = System.now();
                caseIds.add(caseMilestone.CaseId);
            }
            update caseMilestonesToClose;
            List<Case> casesToUpdate = getCasesToUpdate(caseIds, cases);
            if(!casesToUpdate.isEmpty()){
                ISVC_Case_Handler.triggerDisabled = true;
                update casesToUpdate;
            }
        }
    }

    private static Map<Id, List<CaseMilestone>> getOpenCaseMilestones(Set<Id> caseIds){
        Map<Id, List<CaseMilestone>> caseMilestones = new Map<Id, List<CaseMilestone>>();
        for(CaseMilestone caseMilestone : [
                SELECT Id, CaseId, MilestoneType.Name, CompletionDate FROM CaseMilestone
                WHERE CaseId IN :caseIds AND CompletionDate = null]){
            if(!caseMilestones.containsKey(caseMilestone.CaseId)){
                caseMilestones.put(caseMilestone.CaseId, new List<CaseMilestone>());
            }
            caseMilestones.get(caseMilestone.CaseId).add(caseMilestone);
        }
        return caseMilestones;
    }

    private static List<CaseMilestone> getInternalSupportMilestonesToClose(Map<Id, Case> cases, Map<Id, List<CaseMilestone>> openCaseMilestones){
        List<CaseMilestone> caseMilestonesToClose = new List<CaseMilestone>();
        if(!openCaseMilestones.isEmpty()){
            Boolean isOwnerUser, isCaseClosed;
            for(Id caseId : cases.keySet()){
                isOwnerUser = cases.get(caseId).OwnerId.getSobjectType() == User.getSObjectType();
                isCaseClosed = cases.get(caseId).IsClosed;
                if(openCaseMilestones.containsKey(caseId)){
                    for(CaseMilestone caseMilestone : openCaseMilestones.get(caseId)){
                        if(caseMilestone.MilestoneType.Name == RESOLUTION && isCaseClosed){
                            caseMilestonesToClose.add(caseMilestone);
                        } else if(caseMilestone.MilestoneType.Name == FIRST_RESPONSE && (isOwnerUser || isCaseClosed)){
                            caseMilestonesToClose.add(caseMilestone);
                        }
                    }
                }
            }
        }
        return caseMilestonesToClose;
    }

    private static List<Case> getCasesToUpdate(Set<Id> caseIds, Map<Id, Case> cases){
        List<Case> casesToUpdate = new List<Case>();
        for(Id caseId : caseIds){
            if(cases.containsKey(caseId) && cases.get(caseId).IsClosed == false){
                casesToUpdate.add(new Case(Id=caseId,Trigger_Closing_A_Milestone__c=false));
            }
        }
        return casesToUpdate;
    }
}