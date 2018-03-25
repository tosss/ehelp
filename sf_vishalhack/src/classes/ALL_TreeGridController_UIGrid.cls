/***********************************************************************************************************************
* RQ-04476  
* Author: Ragashalini.Koka@cdk.com
* Description: Angular TreeGrid implementation using the Wrapper Class
* Test Class: ALL_TreeGrid_Test

* ---------------------------History----------------------------------------------------------------------
*04/11/2016  ragashalini.koka@cdk.com   Modified the 'order by' condition  as per the existing M_A_T view
										Enabling search on lookup fields
*04/15/2016  ragashalini.koka@cdk.com   Added logic to add new contact 
* 2016-12-13  venkata.shrivol@cdk.com    commented the Count_of_Discovery_Wbks_on_SubProject__c reference
*2017-02-03 - ragashalini.koka@cdk.com - Made changes for RQ-08334
*2017-03-22   ragashalini.koka@cdk.com - Made changes on getRecordsOfAllLevels method for RQ-08881 
* ************************************************************************************************************************ */


global class ALL_TreeGridController_UIGrid { 
    
    public static Integer totalLevelOneRecords{get;set;}
    public static String allObjects{get;set;} 
    public static String timezone{get;set;}
    // public static String salesforceURL{get;set;}
    public static String objectMetadata{get;set;}
    public static String levelOneIds{get;set;}
    public static String customizedFieldsData{get;set;}
    public static String levelOneParentName{get;set;}
    public static String subProjectName{get;set;}
    public static String rootParentName{get;set;}
    //public static Integer cntOfDiscovery{get;set;}
    public static String sortCondition;
    public static String newContactPicklistValues{get;set;}
    public static Decimal countOfChildSites{get;set;}
    public static String documentIdForLogo{get;set;}
    public static Boolean hasPermission { get; set; }
    public static Boolean hasAddPermission { get; set; }
    public static Boolean hasDeletePermission { get; set; }
    public static String subprojectSitePrefix {get;set;}
    
    public ALL_TreeGridController_UIGrid(ALL_AngularInputFields_Controller angInputCtlr) {
        try{
            List<Document> documentsList = [SELECT Id FROM Document WHERE Name LIKE '%CDK Logo (115 x 70)%' LIMIT 1];
            if(documentsList.size() > 0) {
                documentIdForLogo = documentsList[0].Id;
            }   
            String objectName = ApexPages.currentPage().getParameters().get('object');
            String treeId = ApexPages.currentPage().getParameters().get('treeId');
            String queryCondition = '';
            //salesforceURL = System.Url.getSalesforceBaseUrl().getHost();
            //System.debug('URL' + String.valueof(salesforceURL));
            timezone = String.valueOf(UserInfo.getTimeZone());
            subprojectSitePrefix = '';
            List<ALL_Treegrid_Object__c> treegridObjectList = [
                SELECT ObjectAPIName__c, ParentAPIName__c, DisplayName__c, TreegridIdentifier__c
                FROM ALL_Treegrid_Object__c
                WHERE TreegridIdentifier__c =: treeId 
                ORDER BY CreatedDate
                
            ];
            System.debug('objectname ' + objectName );
            System.debug('treeid' + treegridObjectList);
            
            if(ApexPages.currentPage().getParameters().get('id') != null)
            {
                
                ALL_Treegrid_Object__c treeGridObject = null;
                for(ALL_Treegrid_Object__c treeGridObj : treegridObjectList) {
                    
                    if(treeGridObj.TreegridIdentifier__c.equalsIgnoreCase(treeId)){
                        
                        if(treeGridObj.ObjectAPIName__c.equalsIgnoreCase(objectName)) {
                            treeGridObject = treeGridObj;
                            break;
                        }
                    }
                }
                
                if(treeGridObject != null) {
                    queryCondition = ' WHERE ' + treeGridObject.ParentAPIName__c + '=\'' + ApexPages.currentPage().getParameters().get('id') + '\'';
                }
                Id refId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
                String sObjName = refId.getSObjectType().getDescribe().getName();
                rootParentName = sObjName.toLowerCase();
                //hardcoded value - only runs this block if the object is subproject__c
                if(sObjName.equalsIgnoreCase('subproject__c')) {
                    
                    List<SObject> parentRecord = [
                        SELECT Name, SubProject_Name__c
                        //, Count_of_Discovery_Wbks_on_SubProject__c 
                        FROM SubProject__c
                        WHERE Id = :refId
                    ];
                    if(parentRecord.size() > 0) {
                        levelOneParentName = String.valueOf(parentRecord[0].get('Name'));
                        subProjectName = String.valueOf(parentRecord[0].get('SubProject_Name__c'));
                        //cntOfDiscovery = Integer.valueOf(parentRecord[0].get('Count_of_Discovery_Wbks_on_SubProject__c'));
                    } 
                    assignPermissions();
                    initAddNewContactValues(refId);
                }
                subprojectSitePrefix = String.valueOf(SubProjectSite__c.sobjecttype.getDescribe().getKeyPrefix());            
                
            }
            
            
            System.debug('treegridObjectList' + treegridObjectList);
            Map <String,ALL_TreeGridObject> objectsFieldsMap = new  Map <String,ALL_TreeGridObject>();
            if(treegridObjectList.size()>0) {
                allObjects = JSON.serialize(treegridObjectList);
                
                for(ALL_Treegrid_Object__c obj : treegridObjectList) {
                    ALL_TreeGridObject treeGridObj = new ALL_TreeGridObject(obj.ObjectAPIName__c,treeId);
                    objectsFieldsMap.put(obj.ObjectAPIName__c.toLowerCase(), treeGridObj);
                }
                System.debug('map' + objectsFieldsMap);
                objectMetadata = JSON.serialize(objectsFieldsMap);
                
            }
            
            
            String query = 'SELECT Id FROM ' + objectName + queryCondition + ' ' + objectsFieldsMap.get(objectName.toLowerCase()).sortSequence_c;
            Map<Id,SObject> levelOneRecordsMap = new Map<Id,SObject>(Database.query(query));
            
            
            totalLevelOneRecords = Integer.valueOf(levelOneRecordsMap.size());
            //to get the count of level records satisfying the given criteria
            levelOneIds = JSON.serialize(levelOneRecordsMap.keySet());
            
            List<StaticResource> srList = new List<StaticResource>();
            srList = [
                SELECT Name, Body 
                FROM StaticResource 
                WHERE Name like '%TreeGrid_UIGridJSON%'
            ];
            if(srList.size() > 0){
                Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(srList[0].Body.toString());
                customizedFieldsData = JSON.serialize(jsonMap);
            }
            System.debug('customized fields data' + srList[0].Body.toString());
            
        }
        catch(Exception e) {
            System.debug(e.getMessage() + e.getLineNumber());
        }    
        
    }
    
    //2017-03-22 ragashalini.koka@cdk.com - Made the condition parentIdList.size() on entire for loop instead of using it for query condition for RQ-08881
    //uses n+1 SOQLs where 'n' is the hierarchy level and may run into governor limits
    @RemoteAction
    global static String getRecordsOfAllLevels(String treeId, String levelOneParentId) {
        Map<Id,ParentChild> recordMap = new Map<Id,ParentChild>();
        try {
            
            
            List<ALL_Treegrid_Object__c> treegridObjectList = [
                SELECT ObjectAPIName__c, ParentAPIName__c, DisplayName__c, TreegridIdentifier__c,
                ParentName__c, ParentRelationShipName__c
                FROM ALL_Treegrid_Object__c
                WHERE TreegridIdentifier__c =: treeId 
                ORDER BY CreatedDate
                
            ];
            
            Map <String,ALL_TreeGridObject> objectsFieldsMap = new  Map <String,ALL_TreeGridObject>();
            if(treegridObjectList.size()>0) {
                
                for(ALL_Treegrid_Object__c obj : treegridObjectList) {
                    ALL_TreeGridObject treeGridObj = new ALL_TreeGridObject(obj.ObjectAPIName__c,treeId);
                    objectsFieldsMap.put(obj.ObjectAPIName__c.toLowerCase(), treeGridObj);
                }
                System.debug('map' + objectsFieldsMap);
                
            }
            
            List<String> parentIdList = new List<Id>();
            if(levelOneParentId != null) {
                parentIdList.add(levelOneParentId);
                
            }
            for(ALL_Treegrid_Object__c treegridObj : treegridObjectList) {
                
                //  String columns = String.join(new List<String>(objectsFieldsMap.get((treegridObj.ObjectAPIName__c.toLowerCase())).fieldsMap.keySet()), ',');
                if(parentIdList.size() > 0) {
                    String columns = '';
                    Map<String,ALL_TreeGridObject.ALL_TreeGridFields> tempFieldsMap =  objectsFieldsMap.get((treegridObj.ObjectAPIName__c.toLowerCase())).fieldsMap;
                    for(String s : tempFieldsMap.keySet()) {
                        columns += s + ',';
                        //spl cond
                        /* if(s.equalsIgnoreCase('Account__c')) {
columns += 'Site__c' + ',';
}*/
                        if(tempFieldsMap.get(s).fieldType_c.equalsIgnoreCase('REFERENCE')) {
                            //fix to display the acount name instead of site name
                            /*if(s.equalsIgnoreCase('Site__c')) {
columns += 'Account__c' + ',';
}*/
                            columns += tempFieldsMap.get(s).relationshipName_c + '.Name' + ',';
                            
                        }   
                    }
                    System.debug('columns' + columns);
                    columns = columns.removeEnd(',');
                    
                    String hierarchialFields = getHierarchialFields(treegridObjectList,treegridObj.ObjectAPIName__c,treeId);
                    
                    String queryCondition = '';
                    queryCondition = ' WHERE ' + treegridObj.ParentAPIName__c + ' IN : parentIdList';
                    
                    String childName =  getChildName(objectsFieldsMap,treegridObj.ObjectAPIName__c.toLowerCase());
                    System.debug('childname is' + childName);
                    String childQuery = '';
                    if(childName != null) {
                        childQuery = ',(SELECT id FROM ' + childName + ' ' + sortCondition + ')';
                    }
                    
                    String query = 'SELECT ' + columns + hierarchialFields + childQuery +' FROM ' + treegridObj.ObjectAPIName__c + queryCondition + ' ORDER BY createddate desc';
                    System.debug('formed query is' + query);
                    List<SObject> currentRecordList = Database.query(query);
                    System.debug('curretnrecordlist' + currentRecordList);
                    Set<String> currentRecordIdSet = new Set<String>();
                    for(SObject obj : currentRecordList )   {
                        currentRecordIdSet.add(obj.Id);
                        Boolean isChildPresent = false;
                        if(childName != null && obj.getSObjects(childName) != null) {
                            if(obj.getSObjects(childName).size() != 0) {
                                isChildPresent = true; 
                            }
                        }
                        recordMap.put(obj.Id, new ParentChild(obj, isChildPresent));
                    }
                    
                    //clears the list and assigns them with new Ids
                    parentIdList.clear();
                    if(currentRecordIdSet.size() > 0) {
                        parentIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(currentRecordIdSet), List<String>.class));
                        
                    }
                }
            }
            System.debug(recordMap +','+ recordMap.size());
            
        }
        catch(Exception e) {
            recordMap.clear();
            System.debug(e.getMessage() + e.getLineNumber());
        }
        
        return JSON.serialize(recordMap);
        
        
    }
    
    @RemoteAction
    public static Set<Id> getLevelOneIds(String parentId, String objectName, String treeId) {
        ALL_TreeGridObject treeGridObj = new ALL_TreeGridObject(objectName, treeId);
        String query = 'SELECT Id FROM ' + objectName + ' WHERE ' + treeGridObj.parentAPIName_c  + '=\'' + parentId + '\' ' + treeGridObj.sortSequence_c;
        Map<Id,SObject> recordsMap = new Map<Id,SObject>(Database.query(query));
        return recordsMap.keySet();
    }
    
    
    public static String getHierarchialFields(List<ALL_Treegrid_Object__c> treegridObjectList ,String searchObj,String treeIdentifier) {
        Map<String,ALL_Treegrid_Object__c> treeGridObjectsMap = new Map<String,ALL_Treegrid_Object__c>();
        for(ALL_Treegrid_Object__c obj : treegridObjectList) {
            treeGridObjectsMap.put(obj.ObjectAPIName__c, obj);
        }
        
        List<String> navigationList = new List<String>();
        String rootParent = searchObj;
        
        while(rootParent != null || rootParent == '' ) {
            
            navigationList.add(rootParent);
            
            rootParent = treeGridobjectsMap.get(rootParent).ParentName__c;
            
        }
        if(navigationList.size() > 0) {
            System.debug('navigation list' + navigationList );
            navigationList.remove(navigationList.size() - 1);
            ALL_TreeGridObject treeGridObj = new ALL_TreeGridObject(searchObj,treeIdentifier);
            
            Set<String> columnsSet = new Set<String>();
            
            
            
            String hierarchialFields = '';
            String queryCondition = '';
            List<String> hierarchialFieldsList = new List<String>();
            for(Integer i = 0;i<navigationList.size();i++) {
                
                hierarchialFields += treeGridobjectsMap.get(navigationList[i]).ParentRelationShipName__c + '.Id.';
                hierarchialFieldsList.add(hierarchialFields.removeEnd('.').remove('.Id') + '.Id');
            }
            
            System.debug('hierarchial' + hierarchialFields);
            System.debug('hierarchial fields list' + hierarchialFieldsList);
            
            
            if(hierarchialFieldsList.size() > 0) {
                
                
                hierarchialFields = ',' + String.join(hierarchialFieldsList, ',');
                
            }
            else {
                hierarchialFields = '';
                
            }
            return hierarchialFields;
        }
        return '';
    }
    
    global static String getChildName(Map <String,ALL_TreeGridObject> objectsFieldsMap, String objectName) {
        String childName  = null;
        for(String key : objectsFieldsMap.keySet()) {
            if(objectsFieldsMap.get(key).parentName_c!= null ) {
                if(!objectsFieldsMap.get(key).parentName_c.equalsIgnoreCase(objectName)) {
                    continue;
                }
                childName = objectsFieldsMap.get(key).childRelationshipName_c;
                sortCondition = objectsFieldsMap.get(key).sortSequence_c;
                break;
            }
        }
        return childName;
    }
    
    
    
    
    //update and insert records
    @RemoteAction 
    global static Map<String,List<String>> updateInsertRecords(String jsonStringUpdate, String jsonStringInsert ) {
        
        Map<String,List<String>> errDetailsMap = new Map<String,List<String>>();
        try {
            System.debug(jsonStringUpdate);
            
            List<SObject> recUpdateList = (List<SObject>)JSON.deserialize(jsonStringUpdate, List<SObject>.class);
            System.debug('records list size ' + recUpdateList.size());
            //System.debug(recUpdateList[0]);  
            //performs update of records
            Database.SaveResult[] srList = Database.update(recUpdateList,false);
            for(Integer i = 0;i<recUpdateList.size();i++) {
                Database.SaveResult sr = srList[i];
                SObject currentObject = recUpdateList[i];
                if(sr.isSuccess()) {
                    System.debug('update success' + sr.getId());
                }
                else {
                    List<String> errorMsgsList = new List<String>();
                    System.debug('length of errors' + sr.getErrors());
                    for(Database.Error err : sr.getErrors()) {
                        
                        System.debug(err.getStatusCode() + ': ' + err.getMessage() + err.getFields());
                        errorMsgsList.add(err.getMessage());
                        
                    }
                    System.debug('update' + currentObject.get('Id'));
                    errDetailsMap.put(String.valueOf(currentObject.get('Id')), errorMsgsList);
                }
            }
            
            //performs insert operation on records
            List<SObject> recInsertList = (List<SObject>)JSON.deserialize(jsonStringInsert, List<SObject>.class);
            System.debug('records list size ' + recInsertList.size());
            // System.debug(recInsertList[0]);  
            
            srList = Database.insert(recInsertList,false);
            for(Integer i = 0;i<recInsertList.size();i++) {
                Database.SaveResult sr = srList[i];
                List<String> errorMsgsList = new List<String>();
                if(sr.isSuccess()) {
                    errorMsgsList.add('insert success');
                    //inserting the newly assinged id and referring id in VF page separated by '|' operator
                    errDetailsMap.put(String.valueOf(sr.getId() + '|' + 'sno' + (i)), errorMsgsList);
                }
                else {
                    
                    System.debug('length of errors' + sr.getErrors());
                    for(Database.Error err : sr.getErrors()) {
                        
                        System.debug(err.getStatusCode() + ': ' + err.getMessage() + err.getFields());
                        errorMsgsList.add(err.getMessage());
                        
                    }
                    
                    errDetailsMap.put(String.valueOf('sno' + (i) ), errorMsgsList);
                }
            }
            
            
            
            return errDetailsMap;
        }
        catch(Exception e) {
            System.debug('exception while updating ' + e.getCause() + e.getLineNumber() + e.getMessage());
            errDetailsMap.put('ERROR',new List<String>{'deserialization error'}); 
            return errDetailsMap;
        }
        
        
        
    }
    
    
    
    @RemoteAction
    global static Map<String,List<String>> deleteRecords(List<String> recordIdList) {
        Map<String,List<String>> errDetailsMap = new Map<String,List<String>>();
        try {
            
            List<Database.DeleteResult> drList = Database.delete(recordIdList, false);
            for(Integer i = 0;i < drList.size();i++) {
                Database.DeleteResult dr = drList[i];
                if(dr.isSuccess()) {
                    
                    
                }
                else {
                    
                    List<String> errorMsgsList = new List<String>();
                    System.debug('length of errors' + dr.getErrors());
                    for(Database.Error err : dr.getErrors()) {
                        
                        System.debug(err.getStatusCode() + ': ' + err.getMessage() + err.getFields());
                        errorMsgsList.add(err.getMessage());
                        
                    }
                    System.debug('delete' + recordIdList);
                    errDetailsMap.put(recordIdList[i], errorMsgsList);
                    
                    
                    
                }
            }
            
        }
        catch(Exception e) {
            System.debug('exception while deleting');
        }
        return errDetailsMap;
    }
    
    //2016-06-30 ragashalini.koka@cdk.com commented the code as the similar functionality is exists in getRecordsOfAllLevels()
    /*  @RemoteAction
//works till 6 levels of hierarchy
global static String searchRecords(String searchTxt,List<Id> levelOneIdList, String searchObj, String treeIdentifier) {
try{
List<ALL_Treegrid_Object__c> treegridObjectList = [

SELECT ObjectAPIName__c, ParentName__c, ChildRelationshipName__c,ParentAPIName__c,ParentRelationshipName__c, TreegridIdentifier__c
FROM ALL_Treegrid_Object__c
WHERE TreegridIdentifier__c =: treeIdentifier 
ORDER BY CreatedDate

];
Map<String,ALL_Treegrid_Object__c> treeGridobjectsMap = new Map<String,ALL_Treegrid_Object__c>();
for(ALL_Treegrid_Object__c obj : treegridObjectList) {
treeGridobjectsMap.put(obj.ObjectAPIName__c, obj);
}
System.debug('ALL_Treegrid_Object__c' +treeGridobjectsMap);
List<String> navigationList = new List<String>();
String rootParent = searchObj;

while(rootParent != null || rootParent == '' ) {

navigationList.add(rootParent);

rootParent = treeGridobjectsMap.get(rootParent).ParentName__c;

}
if(navigationList.size() > 0) {
System.debug('navigation list' + navigationList );
navigationList.remove(navigationList.size() - 1);
ALL_TreeGridObject treeGridObj = new ALL_TreeGridObject(searchObj,treeIdentifier);

Set<String> columnsSet = new Set<String>();


if(treeGridObj.objectAPIName_c != null) {

for(String s : treeGridObj.fieldsMap.keySet()) {
columnsSet.add(s);
if(treeGridObj.fieldsMap.get(s).fieldType_c.equalsIgnoreCase('REFERENCE')) { 
columnsSet.add(treeGridObj.fieldsMap.get(s).relationshipName_c + '.Name');
}   
}


}



String columns = '';

if(columnsSet.size() > 0) {
columns = String.join(new List<String>(columnsSet),',');
}
System.debug(columns);
String hierarchialFields = '';
String queryCondition = '';
List<String> hierarchialFieldsList = new List<String>();
for(Integer i = 0;i<navigationList.size();i++) {

hierarchialFields += treeGridobjectsMap.get(navigationList[i]).ParentRelationShipName__c + '.Id.';
hierarchialFieldsList.add(hierarchialFields.removeEnd('.').remove('.Id') + '.Id');
}

System.debug('hierarchial' + hierarchialFields);
System.debug('hierarchial fields list' + hierarchialFieldsList);


if(hierarchialFieldsList.size() > 0) {

queryCondition = hierarchialFieldsList[hierarchialFieldsList.size()-1];
System.debug('qc' + queryCondition );

hierarchialFields = ',' + String.join(hierarchialFieldsList, ',');
}
else {
hierarchialFields = '';
}
String orderByCond = ' ORDER BY createddate desc';

// String query = 'SELECT Id,Description__c' + hierarchialFields + ' FROM ' + searchObj + ' WHERE ' + queryCondition + ' IN : levelOneId' + 
//    ' AND (' + columns + ')' + orderByCond; 

String query = 'SELECT ' + columns + hierarchialFields + ' FROM ' + searchObj + ' WHERE ' + queryCondition + 
' IN : levelOneIdList' + orderByCond; 
System.debug('query formed is' + query);
Map<Id,SObject> totalResult = new Map<id,SObject>(Database.query(query));


List<SObject> searchResults = filterResult(totalResult,columnsSet,searchTxt);
System.debug('searchResults' + searchResults);
return ( searchResults.size()>0 ? JSON.serialize(searchResults) : '');
}

}
catch(Exception e) {
System.debug(e.getMessage() + e.getLineNumber());

}

return '';

}

private static List<SObject> filterResult(Map<Id,SObject> totalResult, Set<String> fields, String searchTxt) {
List<SObject> filteredList = new List<SObject>();
for(Id recId : totalResult.keySet()) {

for(String field : fields) {

if(field.contains('.')) {

String value = getFieldValueForHierarchy(totalResult.get(recId),field);
System.debug('hierarchy value' + value);
if(value.containsIgnoreCase(searchTxt)) {
filteredList.add(totalResult.get(recId));
break;
}
}

else if((totalResult.get(recId).get(field) != null) && (String.valueOf(totalResult.get(recId).get(field)).containsIgnoreCase(searchTxt))) {
filteredList.add(totalResult.get(recId));
break;
}
}
}
return filteredList;

}*/
    
    public static String getFieldValueForHierarchy(SObject objRef, String field) {
        List<String> relationHierarchyList = field.split('\\.');
        SObject innermostSObject = objRef;
        Integer i = 0;
        for(i = 0; i < relationHierarchyList.size() - 1; i++) {
            
            innermostSObject = innermostSObject.getSObject(relationHierarchyList[i]);
            
        }
        
        String fieldValue = '';
        if(innermostSObject != null) {
            fieldValue = String.valueOf(innermostSObject.get(relationHierarchyList[i]));
        }
        return fieldValue; 
        
    }
    
    @RemoteAction 
    global static String getObjectName(List<Id> recIdList) {
        String objectNames = '';
        System.debug('reccList' + recIdList);
        for(Id recId : recIdList) {
            objectNames += recId.getSObjectType().getDescribe().getName() + ',';
        } 
        return objectNames.removeEnd(',');
        
    }
    
    public static void initAddNewContactValues(Id refId) {
        Map<String,List<ALL_AngularInputFields_Controller.Picklist>> roleMap = new Map<String,List<ALL_AngularInputFields_Controller.Picklist>>();
        List<ALL_AngularInputFields_Controller.Picklist> contactRoleList =  new List<ALL_AngularInputFields_Controller.Picklist>();
        List<ALL_AngularInputFields_Controller.Picklist> projectRoleList =  new List<ALL_AngularInputFields_Controller.Picklist>();
        
        roleMap.put('Contact-Role__c', ALL_AngularInputFields_Controller.getPicklistValues('Contact', 'Role__c'));
        roleMap.put('SubProject_Client_Contact__c-Role__c', ALL_AngularInputFields_Controller.getPicklistValues('SubProject_Client_Contact__c', 'Role__c'));
        
        SubProject__c subProject = [
            SELECT Id, Count_of_SubProject_Sites__c, 
            (SELECT Account__c, CMF_Numbers__c, Account__r.Name, CMF_Name__r.Name FROM SubProjectSites__r ORDER BY CMF_Name__r.Name)
            FROM SubProject__c 
            WHERE ID = :refId LIMIT 1
        ];
        
        if(subProject != null) {
            
            List<SubProjectSite__c> siteList = new List<SubProjectSite__c>(); 
            
            countOfChildSites = subProject.Count_of_SubProject_Sites__c;
            if(subProject.SubProjectSites__r.size() > 0) {
                List<ALL_AngularInputFields_Controller.Picklist> pickListForSiteOnContact = new List<ALL_AngularInputFields_Controller.Picklist>();
                List<ALL_AngularInputFields_Controller.Picklist> pickListForSite = new List<ALL_AngularInputFields_Controller.Picklist>();
                siteList = subProject.SubProjectSites__r;
                
                if(siteList != NULL && siteList.size() > 0) {
                    
                    for(SubProjectSite__c site : siteList) {
                        
                        if(site.Account__c != NULL && site.Account__r.Name != NULL){
                            
                            ALL_AngularInputFields_Controller.Picklist picklistObj = new ALL_AngularInputFields_Controller.Picklist();
                            picklistObj.label = site.Account__r.Name.replaceAll('\'','');
                            picklistObj.value = site.Account__c;
                            pickListForSiteOnContact.add(picklistObj);     
                            
                        }
                        if(site.CMF_Name__r.Name != NULL && site.CMF_Numbers__c != NULL ) {
                            ALL_AngularInputFields_Controller.Picklist picklistObj = new ALL_AngularInputFields_Controller.Picklist();
                            picklistObj.label = site.CMF_Name__r.Name.replaceAll('\'','') + '-' + site.CMF_Numbers__c;
                            picklistObj.value = site.Id;
                            pickListForSite.add(picklistObj);
                        }
                    }   
                    roleMap.put('Account-Site', pickListForSiteOnContact);
                    roleMap.put('Subproject-Site', pickListForSite); 
                }       
                
                
            }
        }
        
        
        newContactPicklistValues = JSON.serialize(roleMap); 
        
        
    }
    
    @RemoteAction
    public static List<ALL_AngularInputFields_Controller.Picklist> getSiteValues(String subprojectId) {
        SubProject__c subProject = [
            SELECT Id, Count_of_SubProject_Sites__c, 
            (SELECT Account__c, CMF_Numbers__c, Account__r.Name, CMF_Name__r.Name FROM SubProjectSites__r ORDER BY CMF_Name__r.Name)
            FROM SubProject__c 
            WHERE ID = :subprojectId LIMIT 1
        ];
        List<ALL_AngularInputFields_Controller.Picklist> pickListForSite = new List<ALL_AngularInputFields_Controller.Picklist>();
        if(subProject != null) {
            
            List<SubProjectSite__c> siteList = new List<SubProjectSite__c>(); 
            
            countOfChildSites = subProject.Count_of_SubProject_Sites__c;
            if(subProject.SubProjectSites__r.size() > 0) {
                
                
                siteList = subProject.SubProjectSites__r;
                
                if(siteList != NULL && siteList.size() > 0) {
                    
                    for(SubProjectSite__c site : siteList) {
                        if(site.CMF_Name__r.Name != NULL && site.CMF_Numbers__c != NULL ) {
                            ALL_AngularInputFields_Controller.Picklist picklistObj = new ALL_AngularInputFields_Controller.Picklist();
                            picklistObj.label = site.CMF_Name__r.Name.replaceAll('\'','') + '-' + site.CMF_Numbers__c;
                            picklistObj.value = site.Id;
                            pickListForSite.add(picklistObj);
                        }
                    }   
                    
                    
                }       
                
                
            }
        }
        
        return pickListForSite;
    }
    
    public static void assignPermissions() {
        hasPermission = true;
        if (!IMP_Project_Utility.checkUserPermission('Project_Milestone__c', 'PermissionsEdit'))
        {
            hasPermission = false;
        }
        
        //Check if the user has Edit Permission
        if (!IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsEdit'))
        {
            hasPermission = false;
        }
        hasAddPermission = true;
        //Check if the user has Create/Add Permission
        if (!IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsCreate'))
        {
            hasAddPermission = false;
        }
        
        hasDeletePermission = true;
        if (!IMP_Project_Utility.checkUserPermission('Project_Task__c', 'PermissionsDelete') ||
            !IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsDelete') ||
            !IMP_Project_Utility.checkUserPermission('Project_Milestone__c', 'PermissionsDelete'))
        {
            hasDeletePermission = false;
        }
        
    }
    //2017-02-03 - ragashalini.koka@cdk.com - Added parameter mobilePh for RQ-08334
    @Remoteaction
    public static List<String> addNewContact(String jsonStr) 
    { 
        System.debug('jsonstring'+jsonStr);
        
        Map<String,Object> ctctObjMap = (Map<String,Object>)JSON.deserializeUntyped(jsonStr);
        
        ALL_NewContactDialog_Controller.Response returnResponse = 
            ALL_NewContactDialog_Controller.contactInsertionHelper(
                String.valueOf(ctctObjMap.get('firstName')), 
                String.valueOf(ctctObjMap.get('lastName')), 
                String.valueOf(ctctObjMap.get('accId')), 
                String.valueOf(ctctObjMap.get('ctctRole')), 
                String.valueof(ctctObjMap.get('projectRole')),
                String.valueOf(ctctObjMap.get('email')), 
                String.valueOf(ctctObjMap.get('phone')),
                null,
                true, 
                String.valueOf(ctctObjMap.get('subprojectId')));
        
        /*Contact newContact = new Contact();
newContact.FirstName = String.valueOf(ctctObjMap.get('firstName'));
newContact.LastName = String.valueOf(ctctObjMap.get('lastName'));
newContact.AccountId = Id.valueOf(String.valueOf(ctctObjMap.get('accId')));
newContact.Role__c = String.valueOf(ctctObjMap.get('ctctRole'));
newContact.Email = String.valueOf(ctctObjMap.get('email'));
newContact.Phone = String.valueOf(ctctObjMap.get('phone'));*/
        
        List<String> errorList = new List<String>();
        System.debug('add contact' + returnResponse.Success + returnResponse.Message );
        
        if(returnResponse.Success == false)
        {
            errorList.add(returnResponse.Message); 
        }
        //Database.SaveResult saveRes = Database.insert(newContact,false);
        //addErrorsToList(saveRes,errorList);    
        
        /*SubProject_Client_Contact__c newSPCC = new SubProject_Client_Contact__c();
newSPCC.Client_Contact__c = newContact.Id;
newSPCC.SubProject__c =  Id.valueOf(String.valueOf(ctctObjMap.get('subprojectId')));
newSPCC.Role__c = String.valueof(ctctObjMap.get('projectRole'));
saveRes = Database.insert(newSPCC,false);
addErrorsToList(saveRes,errorList);*/
        
        return errorList;
        
        
    }
    
    private static void addErrorsToList(Database.SaveResult saveRes, List<String> errorList) {
        
        if(!saveRes.isSuccess()) {
            for(Database.Error err : saveRes.getErrors()) {
                errorList.add(err.getMessage());
            }
        }
        
    }
    
    
    //inner class to hold a record and boolean to find whether it has child or not 
    global class ParentChild {
        public SObject parentRec;
        public Boolean isChildPresent;
        
        public ParentChild(SObject parentRec, Boolean isChildPresent) {
            
            this.parentRec = parentRec;
            this.isChildPresent = isChildPresent;
            
        }
    }
    
    
}