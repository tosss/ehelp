/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MapAnythingPhone {
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse Check_In(String savedQueryId, String userid, String RecordId, String tooltip1, String cLatitude, String cLongitude, String cAcc, String cDistance, String fieldSet, String fields) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse Check_Out(String checkInId, String cLat, String cLong, String cAccuracy, String cDistance, String fieldSet, String fields) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.MAFolder GetCorpMAFolder(String ParentId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.MAFolder GetPersonalMAFolder(String ParentId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.MAFolder GetRecentMAFolder(String ParentId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse analyzeQuery(String queryId, String currentUserId, String visibleAreaOnly, String includeMetadata, String offset, String nearByLimit, String baseObjectId, String recordIdsStr, String markerColor, String tooltipFieldsString, String DynamicStr, String mapHeight, String mapWidth, String mapLat, String mapLong) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse deleteRoute(String routeId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse getFavInfo(String folderId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse getRoute(String routeId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse getRoutes(Integer month, Integer year, String userId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse getTooltips(String linkId, String tooltipsString, String baseObject, String tooltips) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse saveRoute(String saveType, String rteId, String rteName, Integer rteDay, Integer rteMonth, Integer rteYear, String usId, String rteWaypoints, String rteOptions) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingPhone.APIResponse updateSettings(String userId, String jsonString) {
        return null;
    }
global class APIResponse {
}
global class MAFolder {
    global String Id;
    global String ParentId;
    global List<sma__MALocation__c> SubFavorites;
    global List<sma__MAFolder__c> SubFolders;
    global List<sma__MASavedQry__c> SubSavedQueries;
    global MAFolder() {

    }
}
}
