public class ALL_Picklists_Utility {

    //Case Picklists
    public static final String STATUS_RECONTACT_USER = 'Re-Contact User';
    private static Set<String> caseClosedStatuses;

    //Case Picklists
    public static Set<String> getClosedCaseStatuses(){
        if(caseClosedStatuses == null){
            caseClosedStatuses = new Set<String>();
            for(CaseStatus caseStatus : [SELECT ApiName FROM CaseStatus WHERE IsClosed = true]){
                caseClosedStatuses.add(caseStatus.ApiName);
            }
        }

        return caseClosedStatuses;
    }
}