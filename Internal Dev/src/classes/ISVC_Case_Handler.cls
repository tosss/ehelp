// GLOBIT-3991 Assign business hours based on case contact
// GLOBIT-5302/5303/5297 Sub Case Creation

// 2017-11-14 stephen.li@cdk.com Created
public class ISVC_Case_Handler implements ALL_TriggerHandler_Interface {

    public static Boolean triggerDisabled = false;
    private Id problemRecordTypeId;
    private Id incidentRecordTypeId;
    private Id requestRecordTypeId;
    private Id terminationRecordTypeId;
    private Id newHireRequestRecordTypeId;
    private List<Case> casesToAssignEntitlements = new List<Case>();
    private List<Case> casesToCreateSubCases = new List<Case>();
    private List<Case> subCasesToCreateTasks = new List<Case>();
    private Map<Id, Case> casesToCompleteMilestones = new Map<Id, Case>();
    private Set<Id> casesToCompleteMilestonesAsync = new Set<Id>();
    private Map<Id, Case> problemsToCloseRelatedCases = new Map<Id, Case>();
    private Map<Id, Case> casesToCloseRelatedCases = new Map<Id, Case>();
    private Set<Id> parentCasesToCheckStatus = new Set<Id>();

    public Boolean isDisabled(){
        ALL_TriggerToggle__c triggerToggle = ALL_TriggerToggle__c.getInstance();
        Boolean isTriggerDisabled = triggerToggle.AllTriggersDisabled__c || triggerToggle.CaseTriggerDisabled__c || triggerDisabled;
        return isTriggerDisabled;
    }
    
    /**
     * GLOBIT-3991
     * When the case contact is populated and the case business hours
     * is missing, this method will set the case business hours to
     * be the same as the business hours on the case contact.
     */
    private void assignBusinessHours(List<Case> cases) {
    		Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
    		for(Case c : cases) {
    			if (c.ContactId != null && c.BusinessHoursId == null) {
    				if (caseMap.containsKey(c.ContactId)) {
	    				caseMap.get(c.ContactId).add(c);
	    			} else {
	    				List<Case> cList = new List<Case>();
	    				cList.add(c);
	    				caseMap.put(c.ContactId, cList);
	    			}
    			}
    		}
    		
    		for (Contact c : [SELECT Id, account.business_hours__c FROM Contact WHERE Id in: caseMap.keySet() AND accountId != null]) {
    			for (Case obj : caseMap.get(c.Id)) {
    				obj.BusinessHoursId = c.account.business_hours__c;
    			}
    		}
    }
    
    // GLOBIT 6312 - Termination case uses a special account field to hold the terminated employee information
    private void copyTerminatedEmployeeToCaseAccount(List<Case> cases) {
    		for (Case c : cases) {
    			if (c.RecordTypeId == ALL_RecordTypes_Utility.getTerminationRecordTypeId() && c.Terminated_Employee__c != null) {
    				c.accountId = c.Terminated_Employee__c;
    			}
    		}
    }

    public void beforeInsert(List<SObject> newItems) {
        List<Case> newCases = (List<Case>) newItems;
        incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Set<String> caseClosedStatuses = ALL_Picklists_Utility.getClosedCaseStatuses();
        
        assignBusinessHours(newCases);
        copyTerminatedEmployeeToCaseAccount(newCases);

        Boolean isIncident, isRequest, isClosed, isOwnerUser;
        for(Case newCase : newCases){
            isIncident = newCase.RecordTypeId == incidentRecordTypeId;
            isRequest = newCase.RecordTypeId == requestRecordTypeId;
            isClosed = caseClosedStatuses.contains(newCase.Status);
            isOwnerUser = newCase.OwnerId.getSobjectType() == User.getSObjectType();
            if((isIncident || isRequest) && isClosed){
                newCase.First_Call_Resolution__c = true;
            }
            if((isIncident || isRequest) && !isClosed && String.isBlank(newCase.EntitlementId)){
                casesToAssignEntitlements.add(newCase);
            }
            if((isIncident || isRequest) && isOwnerUser){
                newCase.Trigger_Closing_A_Milestone__c = true;
            }
        }
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Case> newCases = (Map<Id, Case>) newItems;
        Map<Id, Case> oldCases = (Map<Id, Case>) oldItems;
        incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Set<String> caseClosedStatuses = ALL_Picklists_Utility.getClosedCaseStatuses();
        
        assignBusinessHours(newCases.values());

        Case newCase, oldCase;
        Boolean isIncident, isRequest, isStatusChangedToClosed, isOwnerChangedToUser;
        for(Id caseId : newCases.keySet()) {
            newCase = newCases.get(caseId);
            oldCase = oldCases.get(caseId);

            isIncident = newCase.RecordTypeId == incidentRecordTypeId;
            isRequest = newCase.RecordTypeId == requestRecordTypeId;
            isStatusChangedToClosed = newCase.Status != oldCase.Status && caseClosedStatuses.contains(newCase.Status);
            isOwnerChangedToUser = oldCase.OwnerId.getSobjectType() == Group.getSObjectType() && newCase.OwnerId.getSobjectType() == User.getSObjectType();
            if((isIncident || isRequest) && (isOwnerChangedToUser || isStatusChangedToClosed)){
                newCase.Trigger_Closing_A_Milestone__c = true;
            }
        }
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, Case> newCases = (Map<Id, Case>) newItems;
        incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        newHireRequestRecordTypeId = ALL_RecordTypes_Utility.getNewHireRequestRecordTypeId();

        Boolean isIncident, isRequest, isTermination, isNewHireRequest, isOwnerUser;
        for(Case newCase : newCases.values()){
            isIncident = newCase.RecordTypeId == incidentRecordTypeId;
            isRequest = newCase.RecordTypeId == requestRecordTypeId;
            isTermination = newCase.RecordTypeId == terminationRecordTypeId;
            isNewHireRequest = newCase.RecordTypeId == newHireRequestRecordTypeId;
            isOwnerUser = newCase.OwnerId.getSobjectType() == User.getSObjectType();
            if((isTermination || isNewHireRequest || isRequest) && String.isBlank(newCase.ParentId)){
                casesToCreateSubCases.add(newCase);
            }
            if((isIncident || isRequest) && isOwnerUser){
                casesToCompleteMilestonesAsync.add(newCase.Id);
            }
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Case> newCases = (Map<Id, Case>) newItems;
        Map<Id, Case> oldCases = (Map<Id, Case>) oldItems;
        problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        newHireRequestRecordTypeId = ALL_RecordTypes_Utility.getNewHireRequestRecordTypeId();

        Case newCase, oldCase;
        Boolean isProblem, isIncident, isRequest, isTermination, isNewHireRequest, isStatusChangedToClosed, isOwnerChangedToUser;
        for(Id caseId : newCases.keySet()){
            newCase = newCases.get(caseId);
            oldCase = oldCases.get(caseId);
            isProblem = newCase.RecordTypeId == problemRecordTypeId;
            isIncident = newCase.RecordTypeId == incidentRecordTypeId;
            isRequest = newCase.RecordTypeId == requestRecordTypeId;
            isTermination = newCase.RecordTypeId == terminationRecordTypeId;
            isNewHireRequest = newCase.RecordTypeId == newHireRequestRecordTypeId;
            isStatusChangedToClosed = newCase.Status != oldCase.Status && newCase.IsClosed;
            isOwnerChangedToUser = oldCase.OwnerId.getSobjectType() == Group.getSObjectType() && newCase.OwnerId.getSobjectType() == User.getSObjectType();
            if((isTermination || isNewHireRequest || isRequest) && isOwnerChangedToUser && String.isNotBlank(newCase.ParentId)){
                subCasesToCreateTasks.add(newCase);
            }
            if((isIncident || isRequest) && (isOwnerChangedToUser || isStatusChangedToClosed)){
                casesToCompleteMilestones.put(caseId, newCase);
            }
            if(isProblem && (isStatusChangedToClosed || newCase.Close_Related_Cases__c)){
                problemsToCloseRelatedCases.put(newCase.Id, newCase);
            }
            if((isTermination || isNewHireRequest || isRequest) && isStatusChangedToClosed){
                if(String.isBlank(newCase.ParentId)){
                    casesToCloseRelatedCases.put(newCase.Id, newCase);
                } else {
                    parentCasesToCheckStatus.add(newCase.ParentId);
                }
            }
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    public void andFinally(){
        if(!casesToAssignEntitlements.isEmpty()){
            ISVC_EntitlementAssignments.assignEntitlementsToCases(casesToAssignEntitlements);
        }
        if(!casesToCreateSubCases.isEmpty()){
            ISVC_CreateSubCases.createSubCasesForParentCases(casesToCreateSubCases);
        }
        if(!subCasesToCreateTasks.isEmpty()){
            ISVC_CreateSubCaseTasks.createTasksForParentSubCases(subCasesToCreateTasks);
        }
        if(!casesToCompleteMilestonesAsync.isEmpty()){
        		if (System.isBatch()) {
        			System.enqueueJob(new ISVC_CompleteCaseMilestones(casesToCompleteMilestonesAsync));
        		} else {
        			ISVC_CompleteCaseMilestones.closeInternalSupportMilestones(casesToCompleteMilestonesAsync);
        		}
        }
        if(!casesToCompleteMilestones.isEmpty()){
            ISVC_CompleteCaseMilestones.closeInternalSupportMilestones(casesToCompleteMilestones);
        }
        if(!problemsToCloseRelatedCases.isEmpty()){
            ISVC_SyncRelatedCases.closeCasesReletedToProblems(problemsToCloseRelatedCases);
        }
        if(!casesToCloseRelatedCases.isEmpty()){
            ISVC_SyncRelatedCases.closeRelatedCasesWhenParentCaseIsClosed(casesToCloseRelatedCases);
        }
        if(!parentCasesToCheckStatus.isEmpty()){
            ISVC_SyncRelatedCases.closeParentCasesIfAllRelatedCasesAreClosed(parentCasesToCheckStatus);
        }
    }
}