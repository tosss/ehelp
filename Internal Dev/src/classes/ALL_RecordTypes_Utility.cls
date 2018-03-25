public class ALL_RecordTypes_Utility {

    //Person Account Record Types
    public static final String RT_PERSON_ACCOUNT = 'PersonAccount';
    public static final String RT_LOCATION_ACCOUNT = 'LocationAccount';
    //Case Record Types
    public static final String RT_INCIDENT = 'Incident';
    public static final String RT_PROBLEM = 'Problem';
    public static final String RT_REQUEST = 'Request';
    public static final String RT_TERMINATION = 'Termination';
    public static final String RT_NEW_HIRE_REQUEST = 'New_Hire_Request';
    //Asset Record Types
    public static final String RT_HARDWARE = 'Hardware';
    public static final String RT_SOFTWARE = 'Software';

    private static List<RecordType> accountRecordTypes;
    private static Map<String, Id> accountRecordTypesMap;
    private static List<RecordType> caseRecordTypes;
    private static Map<String, Id> caseRecordTypesMap;
    private static List<RecordType> assetRecordTypes;
    private static Map<String, Id> assetRecordTypesMap;

    //Person Account Record Types
    public static Id getPersonAccountRecordTypeId(){
        return getAccountRecordTypeId(RT_PERSON_ACCOUNT);
    }

    public static Id getLocationAccountRecordTypeId(){
        return getAccountRecordTypeId(RT_LOCATION_ACCOUNT);
    }

    private static Id getAccountRecordTypeId(String recordTypeName){
        if(accountRecordTypesMap == null){
            accountRecordTypesMap = getRecordTypesMap(getAccountRecordTypes());
        }
        if(accountRecordTypesMap.containsKey(recordTypeName)){
            return accountRecordTypesMap.get(recordTypeName);
        }
        return null;
    }

    public static List<RecordType> getAccountRecordTypes(){
        if(accountRecordTypes == null){
            accountRecordTypes = getRecordTypes('Account');
        }
        return accountRecordTypes;
    }

    //Case Record Types
    public static Id getIncidentRecordTypeId(){
        return getCaseRecordTypeId(RT_INCIDENT);
    }

    public static Id getProblemRecordTypeId(){
        return getCaseRecordTypeId(RT_PROBLEM);
    }

    public static Id getRequestRecordTypeId(){
        return getCaseRecordTypeId(RT_REQUEST);
    }

    public static Id getTerminationRecordTypeId(){
        return getCaseRecordTypeId(RT_TERMINATION);
    }

    public static Id getNewHireRequestRecordTypeId(){
        return getCaseRecordTypeId(RT_NEW_HIRE_REQUEST);
    }

    private static Id getCaseRecordTypeId(String recordTypeName){
        if(caseRecordTypesMap == null){
            caseRecordTypesMap = getRecordTypesMap(getCaseRecordTypes());
        }
        if(caseRecordTypesMap.containsKey(recordTypeName)){
            return caseRecordTypesMap.get(recordTypeName);
        }
        return null;
    }

    public static List<RecordType> getCaseRecordTypes(){
        if(caseRecordTypes == null){
            caseRecordTypes = getRecordTypes('Case');
        }
        return caseRecordTypes;
    }
    
    //Asset Record Types
    public static Id getHardwareRecordTypeId() {
    		return getAssetRecordTypeId(RT_HARDWARE);
    }
    
    public static Id getSoftwareRecordTypeId() {
    		return getAssetRecordTypeId(RT_SOFTWARE);
    }
    
    private static Id getAssetRecordTypeId(String recordTypeName) {
    		if(assetRecordTypesMap == null){
            assetRecordTypesMap = getRecordTypesMap(getAssetRecordTypes());
        }
        if(assetRecordTypesMap.containsKey(recordTypeName)){
            return assetRecordTypesMap.get(recordTypeName);
        }
        return null;
    }
    
    public static List<RecordType> getAssetRecordTypes() {
    		if (assetRecordTypes == null) {
    			assetRecordTypes = getRecordTypes('Asset');
    		}
    		return assetRecordTypes;
    }

    private static Map<String, Id> getRecordTypesMap(List<RecordType> recordTypes){
        Map<String, Id> recordTypesMap = new Map<String, Id>();
        for(RecordType recordType : recordTypes){
            recordTypesMap.put(recordType.DeveloperName, recordType.Id);
        }
        return recordTypesMap;
    }

    private static List<RecordType> getRecordTypes(String sObjectName){
        List<RecordType> recordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE IsActive = true AND SObjectType = :sObjectName];
        return recordTypes;
    }
}