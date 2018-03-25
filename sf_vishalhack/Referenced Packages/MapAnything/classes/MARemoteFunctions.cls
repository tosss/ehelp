/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MARemoteFunctions {
    global MARemoteFunctions() {

    }
    @RemoteAction
    global static sma.MARemoteFunctions.RAOutput DeleteFolder(String FolderId) {
        return null;
    }
    @RemoteAction
    global static sma.MARemoteFunctions.RAOutput DeleteSavedQuery(String SavedQueryId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> GetDevicesCurrentLocation(Integer version, List<String> deviceids) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> GetLiveDeviceHistory(String deviceId, String liveAPIVersion, String starttime, String endtime) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> GetRecords(String qry, List<String> Ids) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> GetShapeInfo(List<String> Ids) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> MapAnythingIORequestPOST(Map<String,String> options, String parameters) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> MapAnythingIORequest(Map<String,String> options, Map<String,String> parameters) {
        return null;
    }
    @RemoteAction
    global static sma.MARemoteFunctions.RAOutput MoveTreeNode(List<String> FolderArray, List<String> SavedQryArray) {
        return null;
    }
    @RemoteAction
    global static sma.MARemoteFunctions.RAOutput NewFolder(String FolderName, String UserId, String ParentId, String Order) {
        return null;
    }
    @RemoteAction
    global static sma.MARemoteFunctions.SavedQryResult PlotSavedQuery(String SavedQryID, Boolean ViewableAreaEnabled) {
        return null;
    }
    @RemoteAction
    global static sma.MARemoteFunctions.SavedQryResult PlotSavedQueryPhase2(sma.MARemoteFunctions.SavedQryResult SQR) {
        return null;
    }
    @RemoteAction
    global static sma.MARemoteFunctions.RAOutput RenameFolder(String FolderId, String NewName) {
        return null;
    }
    @RemoteAction
    global static void SetDefaultMapLocation(String UserId, Decimal MADefaultZoomLevel, Decimal MADefaultLatitude, Decimal MADefaultLongitude) {

    }
    @RemoteAction
    global static void StorePreferredMeasurementType(String UserId, String PreferredTypeOfMeasurement, String DefaultProximityRadius) {

    }
    @RemoteAction
    global static void UpdateObjects(List<SObject> sObjectList) {

    }
    @RemoteAction
    global static Map<String,Object> geoCodeRecord(String address) {
        return null;
    }
    @RemoteAction
    global static String getAWSRoute(String options) {
        return null;
    }
    @RemoteAction
    global static List<Map<String,Object>> getCustomDriveProfile(String travelMode) {
        return null;
    }
    @RemoteAction
    global static String getDataStuff(String options) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getEsriRoute(String authToken, String stops, String travelMode, Boolean optimize, Boolean preserveFirstStop, Boolean preserveLastStop) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getEsriToken() {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getEsriTravelMode(String authToken) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getRoute(String stringParams, String travelMode, String useTraffic) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> getServiceArea(Map<String,Object> options) {
        return null;
    }
    @RemoteAction
    global static sma.MARemoteFunctions.responseData googleAPISearch(String SearchTerm, Decimal Lat, Decimal Lng, Decimal Radius, String SearchType) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static Map<String,Object> processAJAXRequestReadOnly(Map<String,String> options) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> processAJAXRequest(Map<String,String> options) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> removeMapTile(String tileId) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> saveNewMapTile(String layerData) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> searchMAObjectsForRecords(String searchTerm) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> searchObjectForName(Map<String,Object> options) {
        return null;
    }
    @RemoteAction
    global static Map<String,Object> validateMABaseObjectTooltips(String objectId) {
        return null;
    }
global class PickListEntry {
    global String Color;
    global Decimal Count;
    global String RawValue;
    global String Value;
    global PickListEntry() {

    }
}
global class RAOutput {
    global Boolean IsSuccesfull;
    global String Output;
    global RAOutput() {

    }
}
global class SavedQryResult {
    global String aCity;
    global String aCountry;
    global String aState;
    global String aStreet;
    global String aZip;
    global String BaseObject;
    global String CleanCity;
    global String CleanCountry;
    global String CleanCounty;
    global String CleanDistrict;
    global String CleanPostalCode;
    global String CleanQuality;
    global String CleanSimilarity;
    global String CleanState;
    global String CleanStreet;
    global String ColorAssignment;
    global String DebugMessage;
    global String ErrorMessage;
    global Boolean HasErrors;
    global String IconColor;
    global String Latitude;
    global String LatitudeField;
    global String Longitude;
    global String LongitudeField;
    global sma__MASavedQry__c MASavedQry;
    global String ObjectType;
    global List<sma.MARemoteFunctions.PickListEntry> PickListEntries;
    global Map<String,sma.MARemoteFunctions.PickListEntry> PickListEntryMap;
    global String PicklistField;
    global String PicklistFieldFieldLabel;
    global String PicklistFieldFieldType;
    global sma.MARemoteFunctions.ToolTip PickListToolTip;
    global Decimal QryResultsSize;
    global Decimal RelatedListCount;
    global String SavedQryId;
    global List<sma.MARemoteFunctions.SavedQryResultRecord> SavedQryResultRecords;
    global String StoredQry;
    global sma.MARemoteFunctions.ToolTip ToolTip1;
    global sma.MARemoteFunctions.ToolTip ToolTip2;
    global sma.MARemoteFunctions.ToolTip ToolTip3;
    global sma.MARemoteFunctions.ToolTip ToolTip4;
    global sma.MARemoteFunctions.ToolTip ToolTip5;
    global sma.MARemoteFunctions.ToolTip ToolTip6;
    global sma.MARemoteFunctions.ToolTip ToolTip7;
    global sma.MARemoteFunctions.ToolTip ToolTip8;
    global String WholeQry;
    global SavedQryResult() {

    }
}
global class SavedQryResultRecord {
    global String aCityResult;
    global String aCountryResult;
    global String aStateResult;
    global String aStreetResult;
    global String aZipResult;
    global String BaseObject;
    global Decimal BatchAmount;
    global String CleanCity;
    global String CleanCountry;
    global String CleanCounty;
    global String CleanDistrict;
    global String CleanPostalCode;
    global String CleanQuality;
    global String CleanSimilarity;
    global String CleanState;
    global String CleanStreet;
    global String ContentKey;
    global String IconColor;
    global String Latitude;
    global String LatitudeField;
    global String Longitude;
    global String LongitudeField;
    global String MarkerAddress;
    global String MarkerIconText;
    global String ParentRecordId;
    global String PicklistFieldLabel;
    global String PicklistFieldValue;
    global String PicklistFieldValueEncoded;
    global String QryId;
    global String queryName;
    global String RecordId;
    global String RecordIdToUpdate;
    global Decimal RelatedListCount;
    global Boolean RequiresGeoCoding;
    global String ToolTip1L;
    global String ToolTip1V;
    global String ToolTip2L;
    global String ToolTip2V;
    global String ToolTip3L;
    global String ToolTip3V;
    global String ToolTip4L;
    global String ToolTip4V;
    global String ToolTip5L;
    global String ToolTip5V;
    global String ToolTip6L;
    global String ToolTip6V;
    global String ToolTip7L;
    global String ToolTip7V;
    global String ToolTip8L;
    global String ToolTip8V;
    global SavedQryResultRecord() {

    }
}
global class ToolTip {
    global String DisplayType;
    global String FieldLabel;
    global String FieldName;
    global String FormatedValue;
    global String RefFieldName;
    global String RefID;
    global String Value;
    global ToolTip(String pFieldName, Map<String,Schema.SObjectField> BaseObjectFields) {

    }
    global String GetValue(SObject Obj) {
        return null;
    }
}
global class responseData {
}
}
