/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MapAnythingMobile {
    @RemoteAction
    global static sma.MapAnythingMobile.MAFolder GetCorpMAFolder(String ParentId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingMobile.MAFolder GetPersonalMAFolder(String ParentId) {
        return null;
    }
    @RemoteAction
    global static sma.MapAnythingMobile.MAFolder GetRecentMAFolder(String ParentId) {
        return null;
    }
global class MAFolder {
    global String Id;
    global String ParentId;
    global List<sma__MALayer__c> SubDataLayers;
    global List<sma__MALocation__c> SubFavorites;
    global List<sma__MAFolder__c> SubFolders;
    global List<sma__MASavedQry__c> SubSavedQueries;
    global MAFolder() {

    }
}
}
