//2017-03-07 - ragashalini.koka@cdk.com - Created this class 
//Shows if the fields are present on the page layouts
//pagelayouts are considered if any they are assigned to any record types
//the field accessibility depends on the profile the user is assigned to
//Test Class : Layout_Test
public class Layouts {
    
    public static String objects{get;set;} 
   
    public Layouts(ALL_AngularInputFields_Controller angInputCtlr) {
        
        Set<String> objectSet = Schema.getGlobalDescribe().keySet();
        for(String key : Schema.getGlobalDescribe().keySet()) {
            Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(key).getDescribe();
            if(sobjectResult.isCustomSetting() || sobjectResult.getKeyPrefix() == null) {
                objectSet.remove(key);
            }
        }
        objects = JSON.serialize(objectSet);
        
    }
    
    //returns object Id of the Custom object
    public static String getObjectId(String objectName) {
        String query = 'SELECT Id FROM CustomObject WHERE DeveloperName =\'' + objectName.substring(0, objectName.indexOf('__c')) +'\'';
        HttpResponse response = getHttpResponse(query);
        Map<Id,String> recordMap = parseJSONResult(response.getBody(),'records');
        List<Id> objectIdList = new List<Id>(recordMap.keySet());
        if(objectIdList.size() > 0) {
            return objectIdlist[0];
        }
        return null;
    }
    
    static HttpResponse getHttpresponse(String query) {
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','OAuth ' + UserInfo.getSessionId());
        req.setMethod('GET');
        req.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v34.0/tooling/query/?q='+ encodedQuery);
        Http httpreq = new Http();		
        HttpResponse res = httpreq.send(req);        
        return res;
    }
    
    static Map<Id,String> parseJSONResult(String responseBody, String key) {
        Map<Id,String> IdToNameMap = new Map<Id,String>();
        Map<String, Object> responseMap =(Map<String, Object>)JSON.deserializeUntyped(responseBody);
        
        for(Object obj :  (List<Object>) responseMap.get(key)) {
            Map<String,object> objectMap = (Map<string,object>)JSON.deserializeUntyped(JSON.serializePretty(obj));
            IdToNameMap.put(String.valueOf(objectMap.get('Id')), String.valueOf(objectMap.get('Name')));
            
        }
        System.debug(IdToNameMap.size());
        return IdToNameMap;
    }
    
    @RemoteAction
    public static ObjectInfo getData(String objName) {
       
        ObjectInfo info = new ObjectInfo();
        String objId = objName;
        if(objName.endsWithIgnoreCase('__c')) {
            objId = getObjectId(objName);
        }
        String query = 'select ' + 'Id,Name' + ' from Layout where TableEnumOrId=\'' + objId  + '\''; 
        //System.debug('query---' + query );
        HttpResponse response = getHttpResponse(query);
        info.layoutIdToNameMap = parseJSONResult(response.getBody(), 'records'); 
        info.recordTypeSet = new Set<Id>();
        for(Schema.RecordTypeInfo rt : Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfos() ) {
            info.recordTypeSet.add(rt.getRecordTypeId());
        }
        info.fieldSet = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().keySet();
       
        return info;
    }
    
    public class ObjectInfo {
        Map<Id,String> layoutIdToNameMap;
        Set<Id> recordTypeSet;
        Set<String> fieldSet;
    }
}