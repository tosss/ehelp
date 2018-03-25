// GLOBIT-5166: Create List View Button to assign multiple incidents to a problem
//
// 2017-10-10 marta.malinowska@cdk.com Created
public with sharing class ISVC_AssignIncidentsToProblem_Extension implements ALL_Pagination_Interface{

    private Id problemRecordTypeId;
    private List<Case> selectedCases;
    private List<Case> selectedIncidents { get; set; }
    private Integer totalNrOfOpenProblems;
    private Integer PAGE_SIZE = 20;
    private Integer offsetSize;

    public List<Case> openProblems { get; set; }
    public String searchText { get; set; }
    public Id selectedProblemId { get; set; }
    public Case newProblem { get; set; }
    public Boolean isAtLeastOneCaseSelected { get; set; }
    public Boolean isAtLeastOneIncidentSelected { get; set; }
    public Boolean isAnySelectedCaseNotIncident { get; set; }
    public Boolean isCreateNewProblemRequested { get; set; }

    public ISVC_AssignIncidentsToProblem_Extension(ApexPages.StandardSetController controller) {
        problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        isCreateNewProblemRequested = false;
        selectedCases = controller.getSelected();
        selectedIncidents = getSelectedIncidents();
        validateSelectedCases();
        searchOpenProblems();
    }

    private List<Case> getSelectedIncidents(){
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        List<Case> incidents = new List<Case>();
        for(Case selectedCase : [SELECT Id, RecordTypeId FROM Case WHERE Id IN :selectedCases]){
            if(selectedCase.RecordTypeId == incidentRecordTypeId){
                incidents.add(selectedCase);
            }
        }
        return incidents;
    }

    private void validateSelectedCases(){
        isAtLeastOneCaseSelected = !selectedCases.isEmpty();
        isAtLeastOneIncidentSelected = !selectedIncidents.isEmpty();
        isAnySelectedCaseNotIncident = selectedCases.size() > selectedIncidents.size();
        if(!isAtLeastOneIncidentSelected){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISVC_AtLeastOneIncidentNeedsToBeSelected));
        } else if(isAnySelectedCaseNotIncident){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.ISVC_SomeSelectedCasesAreNotTypeOfIncident));
        }
    }

    public PageReference searchOpenProblems(){
        setTotalRecordsSize();
        firstPage();
        return null;
    }

    public PageReference linkToProblem(){
        List<Case> incidentsToUpdate = new List<Case>();
        for(Case selectedIncident : selectedIncidents){
            Case incident = new Case();
            incident.Id = selectedIncident.Id;
            incident.ParentId = selectedProblemId;
            incidentsToUpdate.add(incident);
        }
        try {
            update incidentsToUpdate;
            return new PageReference('/'+selectedProblemId);
        } catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public PageReference createNewProblem(){
        newProblem = new Case();
        newProblem.RecordTypeId = problemRecordTypeId;
        isCreateNewProblemRequested = true;
        return null;
    }

    public PageReference saveNewProblemAndLink(){
        try {
            insert newProblem;
            selectedProblemId = newProblem.Id;
            return linkToProblem();
        } catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        return null;
    }

    private void setOpenProblems(Integer offsetSize){
        String query = 'SELECT Id, CaseNumber, Subject FROM Case' + getFilterConditions();
        query += ' LIMIT :PAGE_SIZE OFFSET :offsetSize';
        openProblems = Database.query(query);
    }

    private void setTotalRecordsSize(){
        String query = 'SELECT count() FROM Case' + getFilterConditions();
        totalNrOfOpenProblems = Database.countQuery(query);
    }

    private String getFilterConditions(){
        String filterConditions = ' WHERE RecordTypeId = :problemRecordTypeId AND IsClosed = false';
        if(String.isNotBlank(searchText)){
            filterConditions += ' AND Subject LIKE \'%'+String.escapeSingleQuotes(searchText)+'%\'';
        }
        return filterConditions;
    }

    public void firstPage(){
        offsetSize = 0;
        setOpenProblems(offsetSize);
    }

    public void lastPage(){
        offsetSize = totalNrOfOpenProblems - Math.mod(totalNrOfOpenProblems, PAGE_SIZE);
        setOpenProblems(offsetSize);
    }

    public void previousPage(){
        offsetSize = offsetSize - PAGE_SIZE;
        setOpenProblems(offsetSize);
    }

    public void nextPage(){
        offsetSize = offsetSize + PAGE_SIZE;
        setOpenProblems(offsetSize);
    }

    public Boolean getHasPreviousPage(){
        if(offsetSize > 0){
            return true;
        } else {
            return false;
        }
    }

    public Boolean getHasNextPage(){
        if((offsetSize + PAGE_SIZE) < totalNrOfOpenProblems){
            return true;
        } else {
            return false;
        }
    }

    public Integer getCurrentPageNumber(){
        return offsetSize / PAGE_SIZE + 1;
    }

    public Integer getTotalPageNumber(){
        Decimal nrOfPages = (Decimal) totalNrOfOpenProblems / PAGE_SIZE;
        return (Integer) nrOfPages.round(System.RoundingMode.CEILING);
    }
}