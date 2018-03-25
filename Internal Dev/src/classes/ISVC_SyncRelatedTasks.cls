// GLOBIT-4019: Create tasks after an owner of sub case is changed from queue to individual user
//
// 2017-10-19 marta.malinowska@cdk.com Created
public class ISVC_SyncRelatedTasks {

    private static final String CASE_STATUS_CLOSED = 'Closed';

    public static void closeSubCaseIfRelatedTasksAreClosed(Set<Id> caseIds){
        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        List<Case> casesToUpdate = new List<Case>();
        for(Case subCase : [
                SELECT Id, Status, (SELECT Id FROM Tasks WHERE IsClosed = false)
                FROM Case WHERE RecordTypeId = :terminationRecordTypeId AND Id IN :caseIds]){
            if(subCase.Tasks.isEmpty()){
                casesToUpdate.add(new Case(Id=subCase.Id, Status=CASE_STATUS_CLOSED));
            }
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
    }
}