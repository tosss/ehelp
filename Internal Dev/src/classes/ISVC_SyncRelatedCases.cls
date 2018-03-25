// GLOBIT-3924: Create Publisher Action for updating Root Cause, Action Taken, and Status on related cases
//
// 2017-10-13 marta.malinowska@cdk.com Created
public class ISVC_SyncRelatedCases {

    private static final String STATUS_CLOSED = 'Closed';

    public static void closeCasesReletedToProblems(Map<Id, Case> problems){
        List<Case> relatedIncidentsToUpdate = new List<Case>();
        for(Case relatedIncident : [
                SELECT Id, ParentId FROM Case
                WHERE IsClosed = false AND ParentId IN :problems.keySet()]){
            Case parentProblem = problems.get(relatedIncident.ParentId);
            relatedIncident.Action_Taken__c = parentProblem.Action_Taken__c;
            relatedIncident.Root_Cause__c = parentProblem.Root_Cause__c;
            relatedIncident.Status = STATUS_CLOSED;
            relatedIncidentsToUpdate.add(relatedIncident);
        }
        if(!relatedIncidentsToUpdate.isEmpty()){
            update relatedIncidentsToUpdate;
        }
    }

    public static void closeRelatedCasesWhenParentCaseIsClosed(Map<Id, Case> parentCases){
        List<Case> relatedCasesToUpdate = new List<Case>();
        for(Case relatedCase : [
                SELECT Id, ParentId, Status FROM Case
                WHERE IsClosed = false AND ParentId IN :parentCases.keySet()]){
            Case parentCase = parentCases.get(relatedCase.ParentId);
            relatedCase.Status = parentCase.Status;
            relatedCase.Action_Taken__c = parentCase.Action_Taken__c;
            relatedCase.Root_Cause__c = parentCase.Root_Cause__c;
            relatedCasesToUpdate.add(relatedCase);
        }
        if(!relatedCasesToUpdate.isEmpty()){
            update relatedCasesToUpdate;
        }
    }

    public static void closeParentCasesIfAllRelatedCasesAreClosed(Set<Id> parentCaseIds){
        List<Case> parentCasesToUpdate = new List<Case>();
        for(Case parentCase : [
                SELECT Id, Status, Action_Taken__c, Root_Cause__c, (SELECT Id FROM Cases WHERE IsClosed = false)
                FROM Case WHERE Id IN :parentCaseIds AND IsClosed = false]){
            if(parentCase.Cases.isEmpty()) {
                parentCasesToUpdate.add(new Case(Id=parentCase.Id, Status=STATUS_CLOSED, Action_Taken__c = parentCase.Action_Taken__c, Root_Cause__c = parentCase.Root_Cause__c ));
            }
        }
        if(!parentCasesToUpdate.isEmpty()){
            update parentCasesToUpdate;
        }
    }
}