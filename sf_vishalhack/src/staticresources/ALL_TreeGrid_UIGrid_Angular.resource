/**************************************************************************************************
 * 2016-07-14 ragashalini.koka@cdk.com - changes on cancel and clearAllChanges
 * 2016-08-08 ragashalini.koka@cdk.com - fixed small bug on filter in onColumnFilterChanged method
 * 2016-12-14 ragashalini.koka@cdk.com - commented the discovery references in the code
***************************************************************************************************/
var treegridApp = angular.module('treegridApp', ['ngAnimate', 'ngTouch', 'ui.grid', 'ui.grid.treeView','ui.grid.edit','inputFields',
                                                 'ui.grid.pinning', 'ui.grid.selection','ui.bootstrap','angularMoment',
                                                 'ui.bootstrap.datetimepicker','ui.multiselect','ngSanitize','ui.grid.moveColumns',
                                                 'ui.grid.exporter','ui.grid.resizeColumns','ui.grid.autoResize','ui.grid.cellNav']);

treegridApp.service('getAllRecordsService',['$q',function($q) { 
    
    return function(treeId,levelOnePrentId) {
        var deferred = $q.defer();
         //console.log('calling service getAllRecordsService');
        
        ALL_TreeGridController_UIGrid.getRecordsOfAllLevels(treeId,levelOnePrentId,function(result,event) {
            // console.log('event',event);
            if(event.status) {
                
                deferred.resolve(JSON.parse(result));
                
            }
            else {
                 //console.log('event',event);
                angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                openReloadModal();
                deferred.reject('failure');    
            }
            
        },
                                                            {escape: false,buffer: true,timeout:30000}
                                                            
                                                           );
        
        
        
        return deferred.promise;
    }
    
}]); 

treegridApp.service('updateInsertRecordsService',['$q',function($q) { 
    
    return function(recordsUpdateList,recordsInsertList) {
        
        
        var deferred = $q.defer();
        // console.log('calling service updateInsertRecordsService');
        if(recordsUpdateList.length == 0 && recordsInsertList.length == 0) {
            // alert('No records found to update or insert');
            deferred.resolve('no records found to update or insert');
            
        }
        ALL_TreeGridController_UIGrid.updateInsertRecords(angular.toJson(recordsUpdateList),angular.toJson(recordsInsertList),function(result,event) {
            
            if(event.status) {
                
                deferred.resolve(result);
                
            }
            else {
                angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                openReloadModal();
                deferred.reject('failure');    
            }
            
        },
                                                          {escape: true,buffer: true,timeout:30000}
                                                          
                                                         );
        
        return deferred.promise;
    }
    
}]);         

treegridApp.service('deleteRecordsService',['$q', function($q) { 
    
    return function(recordsList) {
        var deferred = $q.defer();
        // console.log('calling service deleteRecordsService');
        ALL_TreeGridController_UIGrid.deleteRecords(recordsList,function(result,event) {
            
            if(event.status) {
                
                deferred.resolve(result);
                
            }
            else {
                angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                openReloadModal();
                deferred.reject('failure');    
            }
            
        },
                                                    {escape: true,buffer: true,timeout:30000}
                                                    
                                                   );
        
        return deferred.promise;
    }
    
}]);

treegridApp.service('getNameForIdService',['$q', function($q) { 
    
    return function(recId,field,objName) {
        var deferred = $q.defer();
        console.log('calling service name for ID');
        ALL_AngularInputFields_Controller.getNameForId(recId,field,objName,function(result,event) {
            
            if(event.status) {
                
                deferred.resolve(result);
                
            }
            else {
                angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                openReloadModal();
                deferred.reject('failure');    
            }
            
        },
                                                       {escape: true,buffer: true,timeout:30000}
                                                       
                                                      );
        
        return deferred.promise;
    }
    
}]);

treegridApp.service('getLevelOneRecords',['$q', function($q) {
    
    return function(parentId, objName, treeId) {
        var deferred = $q.defer();
        
        ALL_TreeGridController_UIGrid.getLevelOneIds(parentId, objName, treeId, function(result,event) {
            
            if(event.status) {
                
                deferred.resolve(result);
                
            }
            else {
                angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                openReloadModal();
                deferred.reject('failure');    
            }
            
        },
         {escape: true,buffer: true,timeout:30000}
                                                     
          );
        
        return deferred.promise;
    }
    
}]);  

treegridApp.service('getModifiedSiteCMFNames',['$q', function($q) {
       return function(parentId) {
        var deferred = $q.defer();
        
        ALL_TreeGridController_UIGrid.getSiteValues(parentId, function(result,event) {
        
            if(event.status) {
                
                deferred.resolve(result);
                
            }
            else {
                angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                openReloadModal();
                deferred.reject('failure');    
            }
            
        },
         {escape: true,buffer: true,timeout:30000}
                                                     
          );
        
        return deferred.promise;
    }
 
    
}]);

treegridApp.controller('treegridCtlr',
                       ['$scope', '$interval', '$compile','$filter',
                        '$timeout', '$sce', 'uiGridConstants', 'uiGridTreeViewConstants',
                        'getAllRecordsService', 'updateInsertRecordsService', 'deleteRecordsService', 'getNameForIdService','getLevelOneRecords','getModifiedSiteCMFNames',
                        function ($scope, $interval, $compile, $filter, $timeout, 
                                  $sce, uiGridConstants, uiGridTreeViewConstants,
                                  getAllRecordsService, updateInsertRecordsService,
                                  deleteRecordsService, getNameForIdService ,getLevelOneRecords,getModifiedSiteCMFNames) {
                            
                            $scope.objectMetadata = metadata;
                            $scope.searchOptions = searchOpts;
                            
                            $scope.maxHierarchyLevel = $scope.searchOptions.length - 1;
                            $scope.gridHeight = 0;
                            $scope.picklistValueMap = {};
                            $scope.keyPrefixMap = {};
                            $scope.hideEditInView = false;    
                            $scope.selectedObjectForMassUpdate = '';
                            $scope.addNewContact = false;
                            $scope.contactSavingError = '';
                            $scope.showSuccessMsg = false;
                            $scope.sobjectDataLookup = {};
                            $scope.disableButtonsWhenTasksDonotExist = false;
                            $scope.searchOptionsDuplicate = [{'ObjectAPIName__c':'All', 'DisplayName__c':'Search All'}];
                            $scope.selectedObject = $scope.searchOptionsDuplicate[0].ObjectAPIName__c;  
                            $scope.dataChanged = false;
                            $scope.columnOrderMap = {};
                            $scope.hasPermission = permission;
                            $scope.hasAddPermission = addPermission;
                            $scope.hasDeletePermission = deletePermission;
                             $scope.objectKeyPrefixIdentifier = {};
                             $scope.levelIndicator = {};
                            var actionBtnsVisibility = true;    
                            var errorMsgVisibility = false;
                            
                            var filterDetailsMap = {};
                            //console.log($scope.objectMetadata);
                            var selectedEditModeRecords = [];
                            var changedBackgroundRows = []
                            var selectedRecordLevel = -1;
                            
                            var editingRowId = '';
                            var dataBeforeFilter = [];
                            
                            //get the field and labels from JSON file and populates the data type from the data generated in the ALL_TreeGridObject
                            constructFieldsLabelsAndDataTypeArrays(customizedFieldsMap, metadata);
                            
                            var fields = getFields();
                            var labels = getLabels();
                            var dataType = getDatatype();
                            totalColumns = getColumnCount();
                            
                            var objectKeyPrefixIdentifierInverse = {};
                            var levelOfObjectsMap = {};
                            // var editableRMSOwnedFields = [];
                            var editableRMSOwnedMilestoneFields = getEditableMilestoneRMSFields();
                            var editableRMSOwnedActivityFields = getEditableActivityRMSFields();
                            var editableRMSOwnedTaskFields = getEditableTaskRMSFields();
                            var RMSOwnedDetails = {};
                            var newRecordIdList = [];  
                            var recordsToBeDeleted = [];
                            
                            var duplicateDataList = []; 
                            
                            var saveByDefault = false;
                            
                            var selectedEditRecords = [];
                            var indicator = ['M', 'A', 'T'];
                            
                            var callRequired = false;
                            var lookupFieldsMap = {}; 
                            var randomId = 0;
                            var insertNewRows = false; 
                            var options = [];
                            var currentMode = 'viewSave';
                            var currentEditingRowIdx = -1;
                            var changedRowId = [];
                            var tempInsertRow = [];
                            var errMsgsForDelete = {}                        
                            var childInfoRecordMap;
                             var useExpandedRowDetails = false;
                            var tempDataList = [];
                            var RMSOwnedRecords = [];
                            
                            var allRecordsResult = {};
                            var expandedRowIds = [];
                            
                            var newActivitiesCreated = {};                       
                            
                            var newRecordPositions = [];
                            var errMapDetails = {};
                            var changedRowIndx = [];
                            var inlineEdit = false;
                            var sortColumnsInfo = [];
                            var columnLookupFilter = {}    
                            var isInternalFilterOn = false;
                            var storeExpandedRows = true;                        
                            var sortInfoMap = {};           
                            var counter = 0;
                            var rowsExpandedBeforeFilter = [];
                            var recordsToBeSearched = [];
                            var filteredResults = [];
                            var filterSuccess  = false;
                            var searchMap = [];
                            var inverseChildMap = [];
                            recordIdsToBeShown = [];
                            
                            // controls the filter on the top of the grid
                            var currentIterationRecords = [];
             
                            $scope.dataList = [];
                            //self executing function which runs automatically
                            (function() {
                                Object.keys($scope.objectMetadata).map(function(key) {
                                    $scope.objectKeyPrefixIdentifier[$scope.objectMetadata[key].keyPrefix_c] = key;
                                });
                                
                                //console.log(objectKeyPrefixIdentifier);
                                objectKeyPrefixIdentifierInverse = _.invert( $scope.objectKeyPrefixIdentifier);
                                
                                for(var i = 0;i<$scope.searchOptions.length;i++) {
                                    option = $scope.searchOptions[i].ObjectAPIName__c.toLowerCase();
                                    levelOfObjectsMap[objectKeyPrefixIdentifierInverse[option]] = i;
                                    
                                    $scope.searchOptionsDuplicate.push($scope.searchOptions[i]);
                                    //control the Type column in the grid(display M/A/T)
                                    $scope.levelIndicator[i] = indicator[i];
                                }
                                //console.log('levelOfObjectsMap',levelOfObjectsMap)
                                setLevelObjectsMap(levelOfObjectsMap);
                                RMSOwnedDetails[0] = editableRMSOwnedMilestoneFields;
                                RMSOwnedDetails[1] = editableRMSOwnedActivityFields;
                                RMSOwnedDetails[2] = editableRMSOwnedTaskFields;
                                
                            })();
                            setSaveByDefault = function(status) {
                               // console.log('save' ,status)
                                saveByDefault = status;    
                                localStorage.setItem(currentUserId + 'BtnStatus',getBtnStatus())
                            }
                            scrollToCell = function(row,col) {
                                console.log('calling scroll to',row,col);
                                if($scope.gridOptions.columnDefs.length > col + 5) {
                                    
                                    $scope.gridApi.core.scrollTo( $scope.dataList[row], $scope.gridOptions.columnDefs[col+5]);
                                }
                            }
                            addRowsToChangedBackgroundRows = function(rowId) {
                                if(changedBackgroundRows.indexOf(rowId) == -1) {
                                    changedBackgroundRows.push(rowId);    
                                }
                            }
                            var initPickListValueMap = function() {
                                var keys = Object.keys($scope.objectMetadata);
                               // console.log('keys' + keys);
                                for(var i = 0;i < keys.length ; i++) {
                                    $scope.keyPrefixMap[$scope.objectMetadata[keys[i]].keyPrefix_c] = keys[i];
                                    var innerKeys = Object.keys($scope.objectMetadata[keys[i]]['picklistValuesMap']);
                                    for(var j = 0;j < innerKeys.length;j++) {
                                        $scope.picklistValueMap[innerKeys[j].toLowerCase()] = $scope.objectMetadata[keys[i]]['picklistValuesMap'][innerKeys[j]];
                                    }
                                }
                                newContactPicklistMap = contactPicklist;
                                keys = Object.keys(newContactPicklistMap);
                                for(var i = 0;i < keys.length;i++) {
                                    $scope.picklistValueMap[keys[i].toLowerCase()] = newContactPicklistMap[keys[i]];
                                }
                               // console.log('picklist value map' ,$scope.picklistValueMap,$scope.keyPrefixMap);
                            };
                            
                            initPickListValueMap();
                            
                               // formatting lookup fields to display name instead of Ids when exporting to CSV                        
                            exporterCallback = function(grid, row, col, input) {
                                //console.log('exporter row',row);
                                fieldAPI = col.name.split('.').length > 1 ? col.name.split('.')[1] : '';
                                if(fieldAPI == '') {
                                    if(col.name == 'level') {
                                        return $scope.levelIndicator[row.entity.level];  
                                    }
                                }
                                var type = getDataTypeForField(fieldAPI);
                                //console.log('exporter callback',fieldAPI,type);
                                if( (fieldAPI == 'Site__c' && !angular.isUndefined(row.entity.parentRec.Site__c))) {
                                    input = $scope.getCMFNameForSite(row.entity.parentRec.Site__c);
                                }
                                
                                if(type == 'REFERENCE') {
                                    
                                    if(!(typeof input === 'undefined')) {
                                        if(fieldAPI != 'Site__c') {
                                            if(!lookupFieldsMap.hasOwnProperty(input)) {
                                                $scope.getReferenceName(row.entity.parentRec,col.name);
                                            }
                                            input = lookupFieldsMap[input];
                                        }
                                        else {
                                            
                                            if( (fieldAPI == 'Site__c' && !angular.isUndefined(row.entity.parentRec.Site__c))) {
                                                input = $scope.getCMFNameForSite(row.entity.parentRec.Site__c);
                                            }
                                            else {
                                                input = '';
                                            }
                                        }
                                    }
                                }
                                
                                return input;
                            }; 
    
   							  //filter to search columnwise
                            function filterRecordsWithGivenProperties(dataList, columnKeys) {
                                
                                var properties = Object.keys(columnKeys);
                                var matchedRecordIds = [];
                                recordIdsToBeShown = [];
                                dataList.map(function(data) {
                                    record = data.parentRec;
                                    
                                    var obj = $scope.objectKeyPrefixIdentifier[_.invert( levelOfObjectsMap)[data.$$treeLevel]].toLowerCase();
                                    var fieldValues = Object.keys(_.invert(customizedFieldsMap['objects'][obj]));
                                    fieldValues.splice(fieldValues.indexOf('NULL'),1,'RMS_Owned_Flag__c');
                                    var satisfiedAllFilters = false;
                                    for(var i = 0;i < properties.length;i++) {
                                        var bypass = false;
                                        if(properties[i] == 'Actual_End_Date__c' && fieldValues.indexOf('Actual_End_Date__c') == -1 && fieldValues.indexOf('Actual_End_Date_Final__c') != -1) {
                                            
                                            bypass = true;
                                        }
                                        if(fieldValues.indexOf(properties[i]) != -1 || bypass) {
                                            
                                            var searchTxt = columnKeys[properties[i]];
                                            var val = record[properties[i]];
                                            var type = getDataTypeForField(properties[i]);
                                           
                                            
                                           if(record.hasOwnProperty(properties[i])) {
                                                if(properties[i] == 'Site__c') {
                                                    val =  $scope.getCMFNameForSite(val);
                                                }
                                                else if(type == 'REFERENCE') {
                                                    if(!lookupFieldsMap.hasOwnProperty(val)) {
                                                        $scope.getReferenceName(record,'parentRec.' + properties[i]);
                                                    }
                                                    val = lookupFieldsMap[val];                  
                                                }
                                                else if(type == 'DATE') {
                                                   // console.log('date in search',val);
                                                    
                                                    if(val.indexOf('T') > -1) {
                                                        val = val.substring(0,val.indexOf('T'));    
                                                    }
                                                    val = val.replace(/-/g,'/');
                                                    var splitDate = val.split('/');
                                                    if(splitDate.length > 2) {
                                                        val = splitDate[1] + '/' + splitDate[2] + '/' + splitDate[0];
                                                    }
                                                    
                                                }
                                                    else if(type == 'BOOLEAN') {
                                                        if(val) {
                                                            val = 'Yes';    
                                                        }
                                                        else {
                                                            val = 'No';    
                                                        }
                                                    }
                                                
                                                
                                                if(String(val).toLowerCase().indexOf(String(searchTxt).toLowerCase()) != -1) {
                                                    //console.log('mactching',String(val),String(searchTxt));
                                                    satisfiedAllFilters = true;
                                                }
                                                else {
                                                    
                                                    satisfiedAllFilters = false;
                                                    break;    
                                                }
                                            }
                                            else {
                                                if(bypass) {
                                                   if(record.hasOwnProperty('Actual_End_Date_Final__c') && searchTxt.toLowerCase() != 'null') {
                                                       
                                                        val = record['Actual_End_Date_Final__c'];
                                                        if(val.indexOf('T') > -1) {
                                                            val = val.substring(0,val.indexOf('T'));    
                                                        }
                                                        val = val.replace(/-/g,'/');
                                                        var splitDate = val.split('/');
                                                        if(splitDate.length > 2) {
                                                            val = splitDate[1] + '/' + splitDate[2] + '/' + splitDate[0];
                                                        }
                                                        
                                                        if(String(val).toLowerCase().indexOf(String(searchTxt).toLowerCase()) != -1) {
                                                             satisfiedAllFilters = true;
                                                        }
                                                    }
                                                    else if(!record.hasOwnProperty('Actual_End_Date_Final__c') && searchTxt.toLowerCase() == 'null') {
                                                         
                                                        satisfiedAllFilters = true;
                                                    }
                                                        else {
                                                            
                                                            satisfiedAllFilters = false;
                                                            break;
                                                        }
                                                }
                                                
                                                else if(searchTxt.toLowerCase() == 'null') {
                                                    satisfiedAllFilters = true;
                                                }
                                                else { 
                                                    satisfiedAllFilters = false;
                                                    break;
                                                }
                                            }
                                        }
                                        
                                        
                                        else {
                                            satisfiedAllFilters = false;
                                            break;
                                        }
                                    }
                                    
                                    
                                    if(satisfiedAllFilters) {
                                        //  console.log('matched all properties',record);
                                        matchedRecordIds.push(record.Id);
                                    }
                                    
                                });
                               // console.log('filteredRecords', matchedRecordIds);
                                return matchedRecordIds;
                            };
                            
                             //returns the relationshipName for the lookup field
                            $scope.getReferenceName = function(record,columnName) {
                                
                                // console.log('lookup fields map',lookupFieldsMap);
                                var columnAPI = (columnName.split('.').length > 1) ?  columnName.split('.')[1] : '';
                                
                                if(columnAPI != '' && record.hasOwnProperty(columnAPI) ) {
                                    var objName = $scope.objectKeyPrefixIdentifier[record.Id.substring(0,3)];
                                    // console.log(objName,columnAPI,$scope.objectMetadata[objName]);
                                    if($scope.objectMetadata[objName].fieldsMap.hasOwnProperty(columnAPI)) {
                                        
                                        var relationName = $scope.objectMetadata[objName].fieldsMap[columnAPI].relationshipName_c;
                                        //console.log('relationName' , relationName );
                                        try {
                                            var lookupId = record[columnAPI];
                                            //  console.log('lookup',record[columnAPI]);  
                                            
                                            if(lookupId != null && lookupId != '' && lookupId.length == 18) {
                                                if(!lookupFieldsMap.hasOwnProperty(lookupId) && record[relationName] != 'undefined' && lookupId == record[relationName].Id ) {
                                                    
                                                    lookupFieldsMap[lookupId] = record[relationName].Name;
                                                   // console.log('lookup fields map' , lookupFieldsMap);  
                                                    
                                                }
                                                else if(lookupId != record[relationName].Id && lookupId.length == 18 && !callRequired && !lookupFieldsMap.hasOwnProperty(lookupId) ) {
                                                    
                                                    // console.log('calling service in try');
                                                    callRequired = true;
                                                    // console.log('calling service in try value' ,lookupFieldsMap[lookupId] );
                                                    callServiceForReferenceName(record,columnAPI, $scope.objectMetadata[objName].fieldsMap[columnAPI].referenceTo_c,relationName,'Name' );
                                                    
                                                }
                                                
                                            }
                                            return lookupFieldsMap[lookupId];
                                        }
                                        catch(err) {
                                            // console.log('in catch' + record[columnAPI]);
                                            console.log(record[columnAPI].length == 18,callRequired,lookupFieldsMap.hasOwnProperty(record[columnAPI]));
                                            if(record[columnAPI].length == 18 && !callRequired && !lookupFieldsMap.hasOwnProperty(record[columnAPI])) {
                                                //console.log('calling service in catch');
                                                lookupFieldsMap[record[columnAPI]] = '';
                                                callRequired = true;
                                                //  console.log('objectname ' ,$scope.objectMetadata[objName].fieldsMap[columnAPI].referenceTo_c);
                                                callServiceForReferenceName(record,columnAPI, $scope.objectMetadata[objName].fieldsMap[columnAPI].referenceTo_c,relationName,'Name' );
                                                
                                            }
                                            else if(lookupFieldsMap.hasOwnProperty(record[columnAPI])) {
                                                record[relationName] = {Id:record[columnAPI],Name:lookupFieldsMap[record[columnAPI]]};
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                
                                return '';
                            };
                            //returns the CMF name for the given siteId
                            $scope.getCMFNameForSite = function(siteId) {
                                
                                if(!angular.isUndefined(siteId)) {
                                    var options =  $scope.picklistValueMap['subproject-site'];
                                    
                                    for(var i = 0;i < options.length;i++) {
                                        if(options[i].value.substring(0,15) == siteId.substring(0,15)) {
                                            var label = options[i].label.split('').reverse().join('');
                                            label = label.substring(label.indexOf('-') + 1);
                                            return label.split('').reverse().join('');
                                            
                                        }
                                    }
                                }
                                return '';
                            };
                            
                            fetchCMFForSite = function(siteId) {
                                return $scope.getCMFNameForSite(siteId);
                            }
                          
                            var callServiceForReferenceName = function(record,columnAPI,objectName,relationName,field) {
                                console.log('inside callService reference',field);
                                getNameForIdService(record[columnAPI],field,objectName)
                                .then(function(result) {
                                    console.log('service', result);
                                    lookupFieldsMap[record[columnAPI]] = result;
                                    if(field.indexOf('.') == -1) {
                                        record[relationName] = {Id:record[columnAPI],Name:result};
                                    }
                                    else if(field.indexOf('.') == -1 && columnAPI == 'Site__c') {
                                        record[relationName] = result;
                                    }
                                    callRequired = false;
                                    console.log(' lookupFieldsMap[record[columnAPI]]', lookupFieldsMap[record[columnAPI]]);
                                });
                                
                                
                            }
                            
                            //returns the object referred by the lookup field
                            $scope.getReferenceObject = function(record,columnName) {
                                var columnAPI = (columnName.split('.').length > 1) ?  columnName.split('.')[1] : '';
                                if(columnAPI != '') {
                                    var objName = $scope.objectKeyPrefixIdentifier[record.Id.substring(0,3)];
                                    if($scope.objectMetadata[objName].fieldsMap.hasOwnProperty(columnAPI)) {
                                        var referenceName = $scope.objectMetadata[objName].fieldsMap[columnAPI].referenceTo_c;
                                        // console.log('referenceName' , referenceName );
                                        return referenceName;
                                    }
                                }
                            };
                            
                            //returns T/F if the field has update(existing records)/create(new records) permissions
                            $scope.isUpdateable = function(record,columnName) {
                                // console.log('record Id length', record.Id.length);
                                var columnAPI = (columnName.split('.').length > 1) ?  columnName.split('.')[1] : '';
                                var objName = $scope.objectKeyPrefixIdentifier[record.Id.substring(0,3)];
                                if($scope.objectMetadata[objName].fieldsMap.hasOwnProperty(columnAPI)) {
                                    if(columnAPI != '') {
                                        
                                        if( record.Id.length == 18) {
                                            var allowUpdate = $scope.objectMetadata[objName].fieldsMap[columnAPI].isUpdateable_c;
                                            return allowUpdate;
                                            
                                        }
                                        
                                        else {
                                            var allowCreate = $scope.objectMetadata[objName].fieldsMap[columnAPI].isCreateable_c &&
                                                (!$scope.objectMetadata[objName].fieldsMap[columnAPI].isFormula_c);
                                            return allowCreate;
                                        }
                                    }
                                }
                                return false;
                            };
                          
                            //returns T/F to identify if the field is required
                            $scope.isNillable = function(record,columnName) {
                                var columnAPI = (columnName.split('.').length > 1) ?  columnName.split('.')[1] : '';
                                if(columnAPI != '') {
                                    var objName = $scope.objectKeyPrefixIdentifier[record.Id.substring(0,3)];
                                    if($scope.objectMetadata[objName].fieldsMap.hasOwnProperty(columnAPI)) {
                                        var allowNulls = $scope.objectMetadata[objName].fieldsMap[columnAPI].isNillable_c;
                                        
                                        return allowNulls;
                                    }
                                }
                                return true;
                            };
                            
                            $scope.columnDefs = [];
                            var reAssignColumnOrder = function() {
                                var gridColumns = $scope.gridApi.grid.columns;
                                var count = 1;
                                var assign = false;
                                for(var i = 0;i < gridColumns.length;i++) {
                                    var col = gridColumns[i];
                                    if(col.field == 'parentRec.Id') {
                                        assign = true;
                                        continue;
                                    }
                                    if(assign && col.field != 'treeBaseRowHeaderCol' && col.field != 'selectionRowHeaderCol') {
                                        $scope.columnOrderMap[col.field] = count++;
                                    }
                                }
                                //console.log('column order map', $scope.columnOrderMap);
                            };
                            
                            //controls the editability permissions on RMS Owned Records
                            $scope.checkEditabilityForRMSOwnedRecords = function(record,columnName) {
                                if(record.parentRec.RMS_Owned_Flag__c) {
                                    var fields = RMSOwnedDetails[record.level];
                                    var columnAPI = (columnName.split('.').length > 1) ?  columnName.split('.')[1] : '';
                                    if(columnAPI != '' ) {
                                        return !(fields.indexOf(columnAPI) != -1);
                                    }
                                }
                                return false;
                            };
                            
                            //changes the font color of the status
                            $scope.getFontColor = function(value) {
                                
                                value = value.toLowerCase();
                                if(value == 'complete') {
                                    return 'grey'; 
                                }
                                else if(value == 'at risk') {
                                    return 'red';
                                }
                                    else if(value == 'on target') {
                                        return 'green';
                                    }
                                        else {
                                            return 'black';    
                                        }
                                
                            }
                            
                            //show/hide the add child icon on the grid
                            $scope.allowCreateChild = function(level,idLength,RMSFlag) {
                                if(level <  $scope.maxHierarchyLevel && idLength == 18)  {
                                    
                                    if(RMSFlag && $scope.objectKeyPrefixIdentifier[_.invert( levelOfObjectsMap)[level]].toLowerCase() == 'project_activity__c') {
                                        return false;    
                                    }
                                    if($scope.objectKeyPrefixIdentifier[_.invert( levelOfObjectsMap)[level]].toLowerCase() == 'project_milestone__c' && !$scope.hasAddPermission)
                                    {
                                        console.log('add permissions');
                                        return false;    
                                    }
                                    return true;
                                }
                                return false;
                            };
                            
                            var reorderSequenceNo = function() {
                                var i = 0;
                                $scope.dataList.map(function(data) {
                                    data.sequence = i++;
                                });    
                            }
                            
                            $scope.insertRow = function(record) {
                                var sequence = record.sequence;
                                var level = record.level;
                                var rows = $scope.gridApi.grid.rows;
                                console.log('insert', $scope.objectKeyPrefixIdentifier[_.invert(levelOfObjectsMap)[level]].toLowerCase());
                                if(record.parentRec.RMS_Owned_Flag__c && $scope.objectKeyPrefixIdentifier[_.invert( levelOfObjectsMap)[level]].toLowerCase() == 'project_activity__c' ) {
                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                    angular.element(document.querySelector('#alertMsg')).html('<b>Info!! &nbsp;</b> Adding a task to an RMS owned activity is not allowed.' 
                                                                                              +'&nbsp;If you want to add a task for a non RMS scheduled associate, add a new activity and task.');
                                    return;
                                }
                                else if(randomId == 0) {
                                    insertNewRows  = true;
                                    $scope.gridApi.selection.clearSelectedRows();
                                }
                                
                                
                                if(sequence > -1) {
                                    
                                    $scope.gridApi.treeBase.expandRow(rows[sequence]);
                                }
                                var keyPrefix = _.invert( levelOfObjectsMap)[level + 1];
                                var childObject = $scope.objectKeyPrefixIdentifier[keyPrefix];
                                //console.log('childObjectName',childObject);
                                var newRow = {$$treeLevel:level+1}
                                var dataObj = {parentRec:{Id:keyPrefix + 'sno'+(randomId++)}};
                                console.log('fields',customizedFieldsMap['objects'][childObject]);
                                var fieldValues = Object.keys(_.invert(customizedFieldsMap['objects'][childObject]));
                                fieldValues.splice(fieldValues.indexOf('NULL'),1);
                               // console.log('fieldValue' , fieldValues);
                                dataObj.parentRec['attributes'] = {type : childObject };
                                fieldValues.map(function(field) {
                                    dataObj.parentRec[field] = ''; 
                                });
                                if($scope.objectKeyPrefixIdentifier[_.invert( levelOfObjectsMap)[level]].toLowerCase() == 'project_activity__c') {
                                    dataObj.parentRec['Description__c'] = $scope.dataList[sequence].parentRec['Description__c'];
                                }
                                
                                // dataObj.isSelected = true;
                                
                                
                                dataObj.parentId = record.parentRec.Id;
                                dataObj.parentAPI = $scope.objectMetadata[childObject].parentAPIName_c;
                                dataObj.level = level + 1;
                              //  console.log('new obj',dataObj);
                                $scope.dataList.splice(parseInt(sequence)+1,0,dataObj);
                                var idx = getIndexForId( record.parentRec.Id,tempDataList);
                                if(idx > -1 && sequence != -1 ) {
                                    tempDataList.splice(parseInt(idx)+1,0,dataObj);
                                }
                                idx = getIndexForId( record.parentRec.Id,dataBeforeFilter);
                                if(idx > -1 && sequence != -1) {
                                    dataBeforeFilter.splice(parseInt(idx)+1,0,dataObj);
                                }
                                if(sequence  == -1) {
                                    tempDataList.splice(parseInt(sequence)+1,0,dataObj);
                                    dataBeforeFilter.splice(parseInt(sequence)+1,0,dataObj);
                                }
                                /*   angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
             angular.element(document.querySelector('#alertMsg')).html('<b>Info!! &nbsp;</b>You have added a new activity or task.'+
                                                                       '&nbsp;Before saving this record, please ensure the row(s) of the activity or task you just added contains a checkmark in the second column.');
           */
            removeBackgroundOfRows();
            $timeout(function () {
                $scope.gridApi.selection.selectRow($scope.dataList[parseInt(sequence)+1]);
              //  console.log('excess rows checked',$scope.dataList[parseInt(sequence)+1]);
                if(($scope.dataList.length-1) > (parseInt(sequence)+2)) {
                    $scope.gridApi.core.scrollTo( $scope.dataList[parseInt(sequence)+2], $scope.gridOptions.columnDefs[6]);
                }
                else {
                    $scope.gridApi.core.scrollTo( $scope.dataList[parseInt(sequence)+1], $scope.gridOptions.columnDefs[6]);
                }
                focusToFirstField(dataObj.parentRec.Id);
                changedBackgroundRows.push(dataObj.parentRec.Id);
                reAssignErrors();
                // adjustHeightOfRows();
                
                
                reCalculateHeightOfGrid();
            });
            reorderSequenceNo();
            //setHeightOfGrid();
            //$scope.gridApi.core.handleWindowResize();
            
            //console.log('datalist after adding' , $scope.dataList);
        };
                            $scope.createNewParentRecord = function() {
                                var record = {sequence:-1, level:-1, parentRec:{Id:$scope.paramId}};
                                $scope.insertRow(record);
                            };
                            
                            //returns the data type for the field which is generally used to identify Reference fields, Date fields and render them correctly
                            getDataTypeForField = function(field) {
                                var type = '';
                                var idx = fields.indexOf(field);
                                if(idx != -1) {
                                    type = dataType[idx];       
                                }
                                return type;
                            };
                            
                            //CMF Name is displayed instead of Site. So default sorting algorithm sorts the column based on the site Ids.
                            //So, defined a custom sorting algorithm for Site
                            sortSite = function(a,b) {
                                // console.log('sorting site',a,b);
                                if(angular.isUndefined(a) && angular.isUndefined(b)) {
                                    
                                    return 0;    
                                }
                                else if(angular.isUndefined(a) && !angular.isUndefined(b)) {
                                    return 1;    
                                } 
                                    else if(!angular.isUndefined(a) && angular.isUndefined(b)) {
                                        return -1;    
                                    } 
                                        else {
                                            a =  $scope.getCMFNameForSite(a).toLowerCase();
                                            b =  $scope.getCMFNameForSite(b).toLowerCase();
                                            if(a == b) {
                                                return 0;    
                                            }
                                            else if(a > b) {
                                              //  console.log('sorting site1',a,b);
                                                return 1;    
                                            }
                                                else {
                                                    console.log('sorting site-1',a,b);
                                                    return -1;    
                                                }
                                        }
                                
                                
                            };
                            
                            //Name is displayed instead of Id for lookup fields. So default sorting algorithm sorts the column based on the Ids.
                            //So, defined a custom sorting algorithm for all lookup fields except Site(which requires CMF Name)
                            sortLookup = function(a,b) {
                                console.log('sort lookup', a,b);
                                if(angular.isUndefined(a) && angular.isUndefined(b)) {
                                    return 0;    
                                }
                                else if(angular.isUndefined(a) && !angular.isUndefined(b)) {
                                    return 1;    
                                } 
                                    else if(!angular.isUndefined(a) && angular.isUndefined(b)) {
                                        return -1;    
                                    } 
                                        else {
                                            try {
                                                a =  lookupFieldsMap[a].toLowerCase();
                                                b = lookupFieldsMap[b].toLowerCase();
                                                if(a == b) {
                                                    return 0;    
                                                }
                                                else if(a > b) {
                                                    return 1 ;  
                                                }
                                                    else {
                                                        return -1;    
                                                    }
                                            }
                                            catch(err) {
                                                
                                            }
                                        }
                                
                                
                            };
                            
                            //Due to a incapability of taking the function, the sorting algorithms are not getting loaded correctly if the grid config is taken from the local storage
                            //This method ensures that it adds the correct algorithm
                            addSortingAlgorithm = function() {
                                for(var i = 0;i<$scope.columnDefs.length;i++) {
                                    if($scope.columnDefs[i].name.indexOf('parentRec') != -1) {
                                        fieldAPI =  $scope.columnDefs[i].name.split('.')[1];
                                        var type = getDataTypeForField(fieldAPI);
                                        if(type.toUpperCase() == 'REFERENCE' || fieldAPI == 'Site__c') {
                                            if(fieldAPI == 'Site__c') {
                                                $scope.columnDefs[i].sortingAlgorithm = sortSite;    
                                            }
                                            else {
                                                $scope.columnDefs[i].sortingAlgorithm = sortLookup;
                                            }
                                        }
                                    }
                                }
                            }
                            
                            //configures the UI grid with the property names
                            //If the user has an entry in the local storage - configuration is taken from local storage 
                            //else it takes the default configurations
                            var setViewModeGridOptions = function() {
                                $scope.columnDefs = [];
                                var storageItem = localStorage.getItem(currentUserId);
                                var saveBtnStatus = localStorage.getItem(currentUserId + 'BtnStatus');
                                if(storageItem != null) {
                                    $scope.columnDefs = JSON.parse(storageItem);
                                    
                                    console.log('saveBtnStatus',saveBtnStatus);
                                    saveByDefault = false;
                                    if(saveBtnStatus == 'ON') {
                                        
                                        saveByDefault = true;
                                        toggleSwitch();
                                    }
                                    
                                    localStorage.setItem(currentUserId + 'BtnStatus',getBtnStatus());
                                    addSortingAlgorithm();
                                    console.log('saveByDefault',saveByDefault);
                                }
                                else {
                                    if(saveBtnStatus != null) {
                                        saveByDefault = false;
                                        if(saveBtnStatus == 'ON') {
                                            
                                            saveByDefault = true;
                                            toggleSwitch();
                                        }
                                    }
                                    
                                    var buttonsLayout = '<div class="ui-grid-cell-contents ng-binding ng-scope" style="text-align:center !important;cursor:pointer !important;color:black !important">'
                                    +'<i class="fa fa-info-circle test ng-hide" style="color:red;font-size:13px !important" onmouseover="toggleTooltip(this,\'show\')" onmouseleave="toggleTooltip(this,\'hide\')" id="err{{row.entity.parentRec.Id}}"></i>'
                                    +'<span ng-show="row.entity.edit || row.entity.hasOwnProperty(\'parentAPI\') "><a class="edit" style="font-size:15px !important;" ng-click=" grid.appScope.editRow(row.entity.parentRec.Id)" ng-hide="grid.appScope.saveInEdit || !grid.appScope.hasPermission" title="Edit" >Edit</a><span ng-if="!grid.appScope.saveInEdit" ng-show="!row.entity.parentRec.RMS_Owned_Flag__c && grid.appScope.hasDeletePermission"> | </span>' 
                                    +'<a class="del"  style="font-size:15px !important;" ng-show="!row.entity.parentRec.RMS_Owned_Flag__c && row.entity.parentRec.Id.length==18 && grid.appScope.hasDeletePermission" ng-click=" grid.appScope.delRow(row.entity.parentRec.Id)" title="Delete">Del</a>&nbsp;&nbsp'
                                    +'</span>'
                                    +'<span ng-show="!row.entity.edit && row.entity.parentRec.Id.length==18 && !row.entity.hasOwnProperty(\'parentAPI\')">'
                                    +'<a class="save" style="font-size:15px !important;"  ng-click=" grid.appScope.saveRow(row.entity.parentRec.Id)" title="Save">Save</a> | ' 
                                    +'<a class="cancel" style="font-size:15px !important;"  ng-click=" grid.appScope.cancelRowEdit(row.entity.parentRec.Id)" title="Cancel">Cancel</a>&nbsp;&nbsp;'  
                                    +'</span>'
                                    +'</div>';
                                    $scope.columnDefs.push({name : 'Action',
                                                            displayName : 'Action',
                                                            minWidth : 115,
                                                            pinnedLeft : true ,
                                                            enableCellEdit :false,
                                                            cellTemplate : buttonsLayout,
                                                            visible : $scope.hasPermission,
                                                            enableFiltering : false,
                                                            enableHiding : false,
                                                            enableColumnMenu : false,
                                                            enableSorting : false,
                                                            enableColumnMoving : false
                                                           }); 
                                    
                                    var errMsgLayout = '<div class="ui-grid-cell-contents ng-binding ng-scope" style="text-align:center !important">' 
                                    +'<i class="fa fa-child" title="Add Child" aria-hidden="true" style="font-size:13px !important" ng-click="grid.appScope.insertRow(row.entity)" ng-show="grid.appScope.allowCreateChild(row.entity.level,row.entity.parentRec.Id.length,row.entity.parentRec.RMS_Owned_Flag__c)"></i>&nbsp;'
                                    + '</div>';
                                    $scope.columnDefs.push({name : 'Msg',
                                                            displayName : '',
                                                            minWidth : 25,
                                                            pinnedLeft : true ,
                                                            enableCellEdit :false,
                                                            cellTemplate : errMsgLayout,
                                                            visible : false,
                                                            enableFiltering : false,
                                                            enableHiding: false,
                                                            enableColumnMenu: false,
                                                            enableSorting: false,
                                                            enableColumnMoving : false
                                                           });  
                                    
                                    var columnIndicator = '<div class="ui-grid-cell-contents ng-binding ng-scope" style="text-align:center !important">' 
                                    +'<span>{{grid.appScope.levelIndicator[row.entity.level]}}</span>'
                                    + '</div>';
                                    $scope.columnDefs.push({name : 'level',
                                                            displayName : 'Type',
                                                            minWidth : 55,
                                                            pinnedLeft : true ,
                                                            enableCellEdit :false,
                                                            cellTemplate : columnIndicator,
                                                            visible : false,
                                                            enableFiltering : false,
                                                            enableHiding: true,
                                                            enableColumnMenu: false,
                                                            enableSorting: false,
                                                            enableColumnMoving : false 
                                                            
                                                           });  
                                    
                                    var RMSMsg = '<div class="ui-grid-cell-contents ng-binding ng-scope" style="text-align:center !important">' 
                                    +'<span ng-show="row.entity.parentRec.RMS_Owned_Flag__c"><b  class="fa-YES" title="RMS Owned"/>&nbsp;&nbsp;</span>'
                                    +'<span ng-show="!row.entity.parentRec.RMS_Owned_Flag__c"><b  class="fa-NO" title="Not RMS Owned"/>&nbsp;&nbsp;</span>'
                                    + '</div>';
                                    $scope.columnDefs.push({name : 'parentRec.RMS_Owned_Flag__c',
                                                            displayName : 'RMS',
                                                            minWidth : 50,
                                                            pinnedLeft : true ,
                                                            enableCellEdit :false,
                                                            cellTemplate : RMSMsg,
                                                            visible : true,
                                                            enableFiltering : true,
                                                            enableHiding: true,
                                                            enableColumnMenu: true,
                                                            enableSorting: true,
                                                            enableColumnMoving : false 
                                                            
                                                           });  
                                    var initialHiddenCols = getInitialHideColumns();
                                    for(var i = 0;i< fields.length;i++) {
                                        var name = 'parentRec.'+  fields[i];
                                        var label = labels[i];
                                        filterDetailsMap[name] = '';
                                        var measuredWidth = calculateWidth(labels[i],i);
                                        var columnVisibility = (initialHiddenCols.indexOf(fields[i]) == -1) ? true : false;
                                        var editableCellTemplate = buildCellTemplate(dataType[i],fields[i]);
                                        var cellTemplate = buildCellTemplateView(dataType[i],(i==1) ? true : false,fields[i]);
                                        if(fields[i].toLowerCase() == 'risk_gauge_color__c') {
                                          //  console.log('measured width is' ,measuredWidth );
                                            measuredWidth = 47;
                                        }
                                        var enableHiding = true;
                                        if(fields[i].toLowerCase() == 'id') {
                                            enableHiding = false;
                                        }
                                        var sortingAlgorithm = null;
                                        var column = { name : name,
                                                      displayName : label,
                                                      visible : columnVisibility,
                                                      minWidth : measuredWidth*2.2,
                                                      pinnedLeft : (i == 1) ? true : false,
                                                      cellTemplate : cellTemplate,       
                                                      editableCellTemplate : editableCellTemplate,
                                                      enableCellEdit: true,
                                                      enableHiding : enableHiding
                                                      
                                                     }
                                        if(dataType[i] == 'REFERENCE' || fields[i].toLowerCase() == 'site__c') {
                                            if(fields[i].toLowerCase() == 'site__c') {
                                                column['sortingAlgorithm'] = sortSite;
                                            }
                                            else {
                                                column['sortingAlgorithm'] = sortLookup;
                                            }
                                        }
                                        $scope.columnDefs.push(column);    
                                        
                                    }
                                }
                                //console.log('column defs' ,$scope.columnDefs );
                                
                            };
                           
                            setViewModeGridOptions();
                           
                            //setting some of the grid properties and this is given as reference in the VF page for initializing grid
                            $scope.gridOptions = {
                                enableSorting: true,
                                enableFiltering: true,
                                showTreeExpandNoChildren: false,
                                rowTemplate: '<div class="level{{row.entity.level}} rec" onmouseenter="onRowHover(this,\'enter\')" onmouseleave="onRowHover(this,\'leave\')" recId="{{row.entity.parentRec.Id}}"><div ng-repeat="(colRenderIndex, col) in colContainer.renderedColumns track by col.colDef.name" class="ui-grid-cell"  ui-grid-cell></div></div>',
                                rowHeight:42,
                                columnDefs: $scope.columnDefs,
                                enableHorizontalScrollbar : 0, 
                                enableGridMenu: true,
                                exporterMenuPdf: false,
                                exporterMenuCsv: true,
                                scrollThreshold : 2,
                                excessColumns : 5,
                                 excessRows : 20,
                                exporterCsvFilename: 'MAT.csv',
                                exporterSuppressColumns : getSuppressedColumnsForExport(),
                                exporterFieldCallback : exporterCallback,
                                useExternalFiltering : true,
                                gridMenuCustomItems: [
                                    {
                                        title: 'Clear All Filters',
                                        action: function ($event) {
                                            clearFilters();
                                        },
                                        order:10
                                    }
                                ],
                                data : 'dataList'
                            }; 
                            
                            fetchLevelOneRecords = function() {
                                console.log('fetching level one records');
                                angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                getLevelOneRecords($scope.paramId, $scope.searchOptions[0].ObjectAPIName__c,$scope.searchOptions[0].TreegridIdentifier__c)
                                .then(function(result) {
                                    $scope.levelOneIdList = result;
                                    console.log('level 1 ', $scope.levelOneIdList);
                                    angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                    fetchAllRecords();
                                });
                            };
                            
                            removeBackgroundOfRows = function() {
                                removeBackgroundToRowEdited(changedBackgroundRows);
                            };
                            reAssignErrors = function() {
                                //console.log('reassigned errors');
                                hideErrors();
                                assignPreviousErrors(errMapDetails);
                               // console.log('changedBackgroundRows',changedBackgroundRows);
                                addBackgroundToRowEdited(changedBackgroundRows);
                                reorderSequenceNo();
                                $scope.gridApi.grid.refresh();
                            }
                            $scope.isFilteredRecord = function(recId) {
                                
                                if(($scope.searchValue.length > 2 || isInternalFilterOn) && recordIdsToBeShown.indexOf(recId) == -1) {
                                    return false;   
                                }
                                return true;
                            };
                            $scope.saveInView = false;
                            $scope.saveInEdit = false;
                            
                            //called when Edit is clicked on the row
                            //changes the row from view to edit mode
                            $scope.editRow = function(recId) {
                                reAssignColumnOrder();
                                var rowIdx = getIndexForId(recId,$scope.dataList);
                                if(currentEditingRowIdx < 0 && changedRowIndx.length == 0) {
                                    currentEditingRowIdx= rowIdx;
                                    //$scope.gridOptions.rowHeight = 70;
                                    console.log('changeCellEditableCondition3');
                                    changeCellEditableCondition(false);
                                    $scope.hideEditInView = true;
                                    
                                    $scope.dataList[rowIdx].edit = false;
                                    $scope.dataList[rowIdx].isView = false;
                                    
                                    
                                    changedRowId = [];
                                    
                                    changedRowId.push($scope.dataList[rowIdx].parentRec.Id);
                                    addBackgroundToRowEdited(changedRowId);
                                    changedBackgroundRows.push($scope.dataList[rowIdx].parentRec.Id);
                                    
                                    rowIdx = getIndexForId(recId,dataBeforeFilter);
                                    dataBeforeFilter[rowIdx].edit = false;
                                    dataBeforeFilter[rowIdx].isView = false;
                                }
                                else if(changedRowIndx.length != 0) {
                                    console.log('edit 2');
                                    
                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                    angular.element(document.querySelector('#alertMsg')).html('<b>Info!! &nbsp;</b>You are in Inline Edit Mode and have made a change.' 
                                                                                              + '&nbsp;Before continuing, you must Save or Cancel your changes.');
                                    
                                }
                                
                                    else if(currentEditingRowIdx > -1) {
                                        console.log('edit 3');
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Info!! &nbsp;</b>Edit already in progress.');
                                    }
                                
                                setHeightOfGrid();
                                $scope.gridApi.core.handleWindowResize();
                                
                                $timeout(function(){
                                    //adjustHeightOfRows();
                                });
                                
                            };
                            
                            //called when Save is clicked on the row
                            //saves the single row which is in edit mode
                            $scope.saveRow = function(recId) {
                                var rowIdx = getIndexForId(recId,$scope.dataList);
                                var saveArr = [];
                                console.log('save arr' ,$scope.dataList[rowIdx]);
                                saveArr.push($scope.dataList[rowIdx].parentRec);
                                saveArr = checkAndModifyProperties(saveArr);
                                callSaveRecordsService(saveArr,[]);
                                // console.log('saveArr',saveArr);
                                changeCellEditableCondition(true);
                            };
                            
                            //called when Cancel is clicked on the row
                            //changes the rows from edit to view mode
                            $scope.cancelRowEdit = function(recId) {
                                var rowIdx = getIndexForId(recId,$scope.dataList);
                                $scope.dataList[rowIdx].edit = true;
                                $scope.dataList[rowIdx].isView = true;
                                $scope.dataList[rowIdx].parentRec = angular.copy(tempDataList[getIndexForId(recId,tempDataList)].parentRec);
                                $scope.dataChanged = false; 
                                $scope.gridOptions.rowHeight = 42;
                                angular.element(document.querySelector('#err' +$scope.dataList[rowIdx].parentRec.Id)).addClass('ng-hide');
                                currentEditingRowIdx = -1;
                               // console.log('changeCellEditableCondition5');
                                changeCellEditableCondition(true);
                                $scope.hideEditInView = false;
                                errMsgsForDelete = {};
                                errMapDetails = {};
                                changedBackgroundRows = [];
                                $scope.closeAlert(); 
                                
                                removeBackgroundToRowEdited(changedRowId);
                                changedRowId = [];
                                changedBackgroundRows.splice(changedBackgroundRows.indexOf(recId),1);
                                //console.log('calling index fr id');
                                rowIdx = getIndexForId(recId,dataBeforeFilter);
                               // console.log('row cancel',rowIdx,recId);
                                dataBeforeFilter[rowIdx].edit = true;
                                dataBeforeFilter[rowIdx].isView = true;
                                $timeout(function(){
                                    //adjustHeightOfRows();
                                });
                            };   
                            
                            //called when Delete is clicked on the row
                            //deletes a single row
                            $scope.delRow = function(recId) {
                                if($scope.dataChanged) {
                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                    angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>You have changed some records. Please save or cancel the changes before deleting.');
                                    return;
                                    
                                }
                                var rowIdx = getIndexForId(recId,$scope.dataList);
                                var deleteRecordsList = [];
                                if(rowIdx > -1) {
                                    deleteRecordsList.push($scope.dataList[rowIdx].parentRec.Id);
                                    callDeleteRecordsService(deleteRecordsList);
                                }
                            };
                            $scope.deleteRecords = function() {
                                
                                var deleteRecordsList = [];
                                var rows = $scope.gridApi.selection.getSelectedRows();
                                var cntRMS = 0;
                                rows.map(function(row) {
                                    row.isSelected = false;
                                    if(!row.parentRec.RMS_Owned_Flag__c) {
                                        deleteRecordsList.push(row.parentRec.Id);
                                    }
                                    else {
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>RMS record(s) is/are selected. Selecting Delete will not have an effect on them.');
                                        cntRMS++;
                                    }
                                });
                                if(deleteRecordsList.length > 0) {
                                    $timeout(function() {
                                        callDeleteRecordsService(deleteRecordsList);
                                    },1500);
                                }
                                else {
                                    if(cntRMS == 0) {
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>No records found to delete.');
                                    }
                                    else {
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>RMS record(s) is/are selected. Selecting Delete will not have an effect on them.');
                                        
                                    }
                                    setHeightOfGrid();
                                    $scope.gridApi.core.handleWindowResize();
                                }
                            };
                            
                            var callDeleteRecordsService = function(deleteRecordsList) {
         //console.log('current mode in delete' , currentMode);
     
                                angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                $scope.disableForDelete = true;
                                errMapDetails = {};
                                hideErrors();
                                errMsgsForDelete = {};
                                recordsToBeDeleted = deleteRecordsList;
                                if(deleteRecordsList.length > 0 && $scope.objectKeyPrefixIdentifier[deleteRecordsList[0].substring(0,3)].toLowerCase() != 'project_milestone__c') {
                                    deleteRecordsList = processRecordsForDelete(childInfoRecordMap,deleteRecordsList);
                                    errMsgsForDelete = getErrToParents();
                                }
                                
                                console.log('errMsgsForDelete',errMsgsForDelete);
                                hideErrors();
                                deleteRecordsService(deleteRecordsList)
                                .then(function(result) {
                                    $scope.disableForDelete = false;
                                    angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                    //  console.log('delete result' ,result);
                                    
                                    if(Object.keys(result).length == 0) {
                                        if(Object.keys(errMsgsForDelete).length == 0) {
                                            angular.element(document.querySelector('#alertMain')).attr('class','alert alert-success');
                                            angular.element(document.querySelector('#alertMsg')).html('<b>Congrats!!&nbsp;</b>Records deleted Successfully.');
                                        }
                                        else {
                                            angular.element(document.querySelector('#alertMain')).attr('class','alert alert-danger');
                                            angular.element(document.querySelector('#alertMsg')).html('<b>Sorry!!&nbsp;</b>Some records couldn\'t be deleted.');
                                        }
                                        //console.log(' $scope.levelOneIdList', $scope.levelOneIdList);
                                        expandedRowIds = [];
                                        getRowsExpanded();
                                        if(deleteRecordsList.length > 0 && $scope.levelOneIdList[0].length > 0) {
                                            if(deleteRecordsList[0].substring(0,3) == $scope.levelOneIdList[0].substring(0,3)) {
                                                afRenderPage();
                                            }
                                            else {
                                                fetchAllRecords();    
                                            }
                                        } 
                                        
                                    }
                                    if(Object.keys(result).length != 0 || Object.keys(errMsgsForDelete).length != 0 ) {
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-danger');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Sorry!!&nbsp;</b>Some records couldn\'t be deleted.');
                                        Object.keys(errMsgsForDelete).map(function(key) {
                                            result[key] = errMsgsForDelete[key];    
                                        });
                                        angular.forEach(Object.keys(result),function(key) {
                                            var errHTML = '<table><tr><th><b class="fa fa-info-circle ng-hide"/>&nbsp;&nbsp;</th><th>Errors</th></tr>' 
                                            + '<tr><td></td><td><ul>'
                                            angular.forEach(result[key],function(err) {
                                                errHTML += '<li style="cursor:default !important">'+ err + '</li>'; 
                                            });
                                            
                                            errHTML += '</ul></td></tr></table>';
                                            errMapDetails[key] = errHTML; 
                                            jQuery('#err' + key).tooltip({title: errHTML, html: true, placement: "auto bottom"});
                                            angular.element(document.querySelector('#err' + key)).removeClass('ng-hide');
                                        });
                                        
                                    }
                                    setHeightOfGrid();
                                    $scope.gridApi.core.handleWindowResize();
                                   // console.log('errMapDetails while deleting',errMapDetails);
                                    $timeout(function(){
                                        //   adjustHeightOfRows();
                                    });
                                });
     };
                            var changeCellEditableCondition = function(value) {
                                //console.log('change editable cell condition called' , value, $scope.columnDefs);
                                for(var i = 2;i< $scope.columnDefs.length;i++) {
                                    $scope.columnDefs[i].cellEditableCondition  = value;
                                }
                                
                                $scope.gridApi.grid.refresh();  
                                 
                            };
                            
                            //returns the index of array which matches the Id
                            getIndexForId = function(recId,recList) {
                                for(var i = 0;i < recList.length;i++) {
                                    if( recList[i].parentRec.Id == recId) {
                                        //   console.log('found id',i);
                                        return i;    
                                    }
                                }
                                return -1;
                            }
                            
                            
                            $scope.isSubProject = isSubProj;
                           // $scope.showDiscovery = discoveryVisible;
                          
                            $scope.paramId = rootId;
                            $scope.timezone = zone;
                            $scope.levelOneIdList = parentIdList;
                            
                            //formats date in the Salesforce format (mm/dd/yyyy)
                            $scope.getFormattedDate = function(value,view,record,columnAPI) {
                               
                                if(columnAPI.split('.')[1].toLowerCase().indexOf('actual_end_date__c') != -1) {
                                    
                                    if(!record.hasOwnProperty('Actual_End_Date__c') && record.hasOwnProperty('Actual_End_Date_Final__c')) {
                                        value = record['Actual_End_Date_Final__c'];
                                    }
                                }
                              
                               
                              
                                var  aDate = new Date(value);
                                
                                if (aDate && aDate != 'Invalid Date') {
                                    
                                    aDate = new Date(aDate.getTime() + aDate.getTimezoneOffset() * 60000);
                                    var dt = $filter('date')(aDate, 'MM/dd/yyyy');
                                    //console.log('after format' ,dt);
                                   
                                    return dt;
                                    var month = dt.substring(0, dt.indexOf('/'));
                                    var day = dt.substring(dt.indexOf('/') + 1, dt.lastIndexOf('/'));
                                    var year = dt.substring(dt.lastIndexOf('/') + 1, dt.length);
                                    return (month.length < 2 ? '0' + month : month) + '/' + (day.length < 2 ? '0' + day : day) + '/' + year;
                                }
                              
                            };
                            
                            //function to populate a map with the recordId as key and their corresponding children(as ',' separated values) as value
                            //used to identify children when parentId is given (mostly helpful in search)
                            initChildInfoRecordMap = function(allRecords) {
                                var keyArr = Object.keys(allRecords);
                                for(var i = 0;i<keyArr.length;i++){
                                    var key = allRecords[keyArr[i]]['parentRec']['attributes']['type'].toLowerCase();
                                    var childName = getChildData(key);
                                    if(childName != null) {
                                        var childRelationName = $scope.objectMetadata[childName.toLowerCase()].childRelationshipName_c;
                                        if(allRecords[keyArr[i]]['parentRec'].hasOwnProperty(childRelationName)) {
                                            var childRecArr =  allRecords[keyArr[i]]['parentRec'][childRelationName]['records'];
                                            //forming a string of child Ids for each parent record and those Ids are separated by ','
                                            var idString ='';
                                            angular.forEach(childRecArr,function(rec){
                                                idString += rec.Id + ',';
                                                
                                            });
                                            //  console.log('idstring' + idString.substring(0,idString.length-1));
                                            childInfoRecordMap[keyArr[i]] = idString.substring(0,idString.length-1);
                                        }
                                    }
                                }
                               // console.log('child info record map' , childInfoRecordMap);
                                
                            };
                            
                            //used to show/hide columns in view mode and edit mode
                            //Eg: Add child column will be only visible in edit mode
                            var changeColumnsVisibilty = function() {
                                console.log('massupdate checking' , currentMode);
                                var addChildVisibility = true;
                                if((currentMode == 'editSave' || currentMode == 'viewSave') && !$scope.disableButtonsWhenTasksDonotExist) {
                                    $scope.viewInEdit = false;
                                    $scope.saveInEdit = false;
                                    $scope.hideEdit = false;
                                    actionBtnsVisibility = $scope.hasPermission;
                                    addChildVisibility = false;
                                    $scope.gridOptions.rowHeight = 42;
                                    $scope.columnDefs[0].minWidth = 115;
                                    // setDataMode(true);
                                }
                                else if(currentMode == 'editQuickSave' || $scope.disableButtonsWhenTasksDonotExist ) {
                                    $scope.viewInEdit = false;
                                    $scope.saveInEdit = true;
                                    actionBtnsVisibility = $scope.hasPermission;
                                    //setDataMode(false);//changed height 70 to 45
                                    $scope.gridOptions.rowHeight = 42;
                                    $scope.columnDefs[0].minWidth = 70;
                                    // $scope.columnDefs[0].width = 70;
                                }
                                $scope.columnDefs[0].visible = $scope.hasPermission;
                                $scope.columnDefs[1].visible = addChildVisibility;
                                $scope.gridApi.core.notifyDataChange(uiGridConstants.dataChange.COLUMN);
                                $scope.gridApi.grid.refresh();    
                            };
                            
                            //used to keep the records checked if deletion is not successful 
                            var checkUnsuccessfulDeleteRecords = function() {
                                recordsToBeDeleted.map(function(recId) {
                                    var idx = getIndexForId(recId, $scope.dataList);
                                    if(idx != -1) {
                                        $scope.gridApi.selection.selectRow($scope.dataList[idx]);
                                    }
                                });
                            };
                            
                            //used to keep the records checked if addition is not successful
                            var checkNewlyAddedRowsIfErrorExists = function() {
                                $timeout(function() {
                                    reorderSequenceNo();
                                    
                                    Object.keys(errMapDetails).map(function(key) {
                                        if(key.length < 18) {
                                            var idx = getIndexForId(key, $scope.dataList);
                                            //console.log('error on new records',key,idx);
                                            if(idx != -1) {
                                                $scope.gridApi.selection.selectRow($scope.dataList[idx]);
                                            }
                                        }
                                        
                                    });
                                    removeBackgroundOfRows();
                                    reAssignErrors();
                                    //hideErrors();
                                    console.log('err mapdetails',errMapDetails);
                                });
                                
                            };
                            
                            var checkNewRecords = function() {
                                tempInsertRow.map(function(row) {
                                    if(row.Id.length < 18) {
                                        var idx = getIndexForId(row.Id, $scope.dataList);
                                        //console.log('error on new records',key,idx);
                                        if(idx != -1) {
                                            $scope.gridApi.selection.selectRow($scope.dataList[idx]);
                                        }
                                    }
                                });
                            }
                            
                            //gets the updated data 
                            fetchAllRecords = function() {
                                $scope.isView = true;
                                childInfoRecordMap = {};
                                angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                $scope.isLoadRequired = false;
                                $scope.disableAllPreviousCheckboxes = false;
                                var levelOneParentId = null ;  
                                $scope.disableAllPreviousCheckboxes = false;
                                if($scope.paramId.length != 0) {
                                    levelOneParentId = $scope.paramId;  
                                }
                                $scope.disableButtons = true;
                                closeReloadModal();
                                getAllRecordsService(treeIdentifier,levelOneParentId)
                                .then(function(result) { 
                                    
                                    if(result != null && $scope.levelOneIdList.length > 0 && Object.keys(result).length > 0) {
                                        $scope.saveInView = false;
                                        currentEditingRowIdx = -1;
                                        changedRowIndx = [];
                                        RMSOwnedRecords = [];
                                        if(Object.keys(errMsgsForDelete).length == 0 ) {
                                            errMapDetails = {};
                                        }
                                        $scope.hideEditInView = false;
                                        // console.log('result' , Object.keys(result));
                                        allRecordsResult = result;
                                        initChildInfoRecordMap(result);
                                        $scope.gridOptions.data = [];
                                        // console.log('all records',result[$scope.levelOneIdList[0]]);
                                        var dataList = {}; 
                                        $scope.totalLevelOneRecords = $scope.levelOneIdList.length;
                                        $scope.fixedDisplayCnt = $scope.levelOneIdList.length;
                                        var idx = -1;
                                        for(var i = 0;i<$scope.levelOneIdList.length;i++) {
                                            if(!angular.isUndefined(result[$scope.levelOneIdList[i]]) && 
                                               !angular.isUndefined(result[$scope.levelOneIdList[i]]['parentRec'])) {
                                                idx = i;
                                                break;
                                            }
                                        }
                                        if(idx > -1) {
                                            var key = result[$scope.levelOneIdList[idx]]['parentRec']['attributes']['type'].toLowerCase();
                                        }
                                        
                                        
                                        
                                        // dataList = {};
                                        angular.forEach($scope.levelOneIdList,function(key){
                                            dataList[key] = result[key];
                                            
                                        });
                                        
                                        
                                        var dataArr = [];
                                        Object.keys(dataList).map(function(key) {
                                            dataArr.push(dataList[key]);
                                        });
                                       // console.log('dataArr' ,  dataArr );
                                        buildHierarchy(dataArr,allRecordsResult, childInfoRecordMap,$scope.navigationList);
                                        $scope.dataList = [];
                                        convertHierarchyToFlatStructure( dataArr, 0, $scope.dataList );
                                        angular.forEach($scope.dataList, function( row, index){
                                            row.sequence = index;
                                            row.isView = $scope.isView;
                                            row.edit = true;
                                            row.level = levelOfObjectsMap[row.parentRec.Id.substring(0,3)];
                                            if(row.parentRec.RMS_Owned_Flag__c) {
                                                RMSOwnedRecords.push(row.parentRec.Id);
                                            }
                                        });
                                        totalRecords = $scope.dataList.length;
                                        //console.log('dataArr',$scope.dataList[1],$scope.dataList[2] );
                                        //console.log('RMSOwnedRecords',RMSOwnedRecords);
                                       // console.log('$scope.dataList',$scope.dataList);
                                        tempDataList = angular.copy($scope.dataList);
                                        dataBeforeFilter = angular.copy($scope.dataList);
                                        duplicateDataList = angular.copy($scope.dataList);
                                       // console.log('expandedRowIds', expandedRowIds);
                                        $scope.dataChanged = false; 
                                        $timeout(function(){
                                           if(Object.keys(errMsgsForDelete).length > 0 ) {    
                                                checkUnsuccessfulDeleteRecords();
                                                
                                            }
                                           // console.log('errors while saving',errMapDetails);
                                            
                                            //adjustHeightOfRows();
                                            if(newRecordIdList.length > 0) {
                                                addTasksToNewActivities();
                                            }
                                            rowsExpandedBeforeFilter = angular.copy(expandedRowIds);
                                            expandRows(expandedRowIds);
                                          
                                        }); 
                                        if(angular.element(document.querySelector('#alertMain')).attr('class').indexOf('info') != -1 || Object.keys(errMsgsForDelete).length != 0) {
                                            $scope.closeAlert();     
                                        }
                                        if(Object.keys(errMsgsForDelete).length != 0) {
                                            hideErrors();
                                            assignPreviousErrors(errMapDetails); 
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    randomId = 0;
                                    insertNewRows = false;
                                    $scope.disableButtons = false;
                                    $scope.selectedObjectForMassUpdate = '';
                                    
                                    setDataMode(currentMode);
                                    changeColumnsVisibilty();
                                    if($scope.searchValue.length > 2) {
                                        $scope.filterModified();
                                    }
                                    else {
                                        onColumnFilterChanged();    
                                    }
                                    
                                    
                                    
                                    
                                    angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                    
                                    reorderSequenceNo();
                                    
                                    
                                });
                                console.log('current mode in fetch records', currentMode);
                                
                                hideErrors();
                                
                            };
                            fetchAllRecords(); 
                            var addTasksToNewActivities = function() {
                                console.log('in methid addTasksToNewActivities');
                                newActivitiesCreated = {};
                                newRecordIdList.map(function(newRecId){
                                    var idx = getIndexForId(newRecId, $scope.dataList);
                                    if( $scope.objectKeyPrefixIdentifier[newRecId.substring(0,3)].toLowerCase() == 'project_activity__c' && idx > -1) {
                                        console.log('added is project activity',$scope.dataList[idx]);  
                                        newActivitiesCreated[newRecId] = 0;
                                        expandedRowIds.push(newRecId);
                                        $scope.insertRow($scope.dataList[idx]);
                                    }    
                                    
                                });
                                if(Object.keys(newActivitiesCreated).length > 0) {
                                    $scope.disableButtonsWhenTasksDonotExist = true;  
                                    
                                } 
                                //console.log('new taks',expandedRowIds);
                                $timeout(function() {
                               		 //expandRows(expandedRowIds);
                                });

                                
                            };
                            var getChildData = function(key) {
                                var childName = null;
                                for(var i = 0;i<$scope.searchOptions.length;i++) {
                                    var value = $scope.objectMetadata[$scope.searchOptions[i].ObjectAPIName__c.toLowerCase()];
                                    if(!angular.isUndefined(value.parentName_c) &&
                                       value.parentName_c != null) {
                                        if(value.parentName_c.toLowerCase() != key) {
                                            continue;    
                                        }
                                        childName = $scope.searchOptions[i].ObjectAPIName__c.toLowerCase();
                                        break;
                                    }
                                    
                                }
                                return childName;
                                
                            };  
                            
                            //identifies the rows edited in inline mode and only returns those records for update
                            var getUpdatedList = function() {
                                
                                var updatedDataList = [];
                                var recordsProcessed = [];
                                changedBackgroundRows.map(function(recId) {
                                    if(!angular.isUndefined(recId) && recId.length == 18 && recordsProcessed.indexOf(recId) == -1) {
                                        recordsProcessed.push(recId); 
                                        var idx = getIndexForId(recId, $scope.dataList);
                                        if(idx > -1) {
                                            updatedDataList.push($scope.dataList[idx].parentRec);
                                        }
                                    }
                                    
                                    
                                    
                                });
                                return updatedDataList;
                                
                            };
                            
                            //identifies the modified rows and newly added rows in Edit mode
                            var getAllDataForUpdate = function() {
                                var allDataList = [];
                                newRecordPositions = [];
                                $scope.gridApi.selection.getSelectedRows().map(function(row) {
                                    if(row.parentRec.Id.length != 18) {
                                        newRecordPositions.push(row.sequence);
                                    }
                                });
                                var groupMap = {};
                                
                                /*    for(var i = 0;i < $scope.dataList.length;i++) {
            
            var currentRec = $scope.dataList[i];
            console.log('current rec',currentRec);
            if(currentRec.parentRec.Id.length == 18) {
                //  console.log('verifying',currentRec.parentRec);
                var idx = getIndexForId(currentRec.parentRec.Id,tempDataList);
                if(angular.toJson(currentRec.parentRec) != angular.toJson(tempDataList[idx].parentRec)) {
                    //  console.log($scope.dataList[i]);
                    if(currentRec.hasOwnProperty('$$treeLevel')) {
                        if(angular.isUndefined(groupMap[currentRec['$$treeLevel']])) {
                            groupMap[currentRec['$$treeLevel']] = [];
                        }
                        groupMap[currentRec['$$treeLevel']].push(currentRec.parentRec);
                    }
                    else {
                        if(angular.isUndefined(groupMap['leaf'])) {
                            groupMap['leaf'] = [];
                        }
                        groupMap['leaf'].push(currentRec.parentRec);
                    }
                }
            }
           
        }*/
                                
                                changedBackgroundRows.map(function(recId) {
                                    if(!angular.isUndefined(recId) && recId.length == 18) {
                                        var idx = getIndexForId(recId, $scope.dataList);
                                        var currentRecord = $scope.dataList[idx];
                                        if(currentRecord.hasOwnProperty('$$treeLevel')) {
                                            if(angular.isUndefined(groupMap[currentRecord['$$treeLevel']])) {
                                                groupMap[currentRecord['$$treeLevel']] = [];
                                            }
                                            groupMap[currentRecord['$$treeLevel']].push(currentRecord.parentRec);
                                        }
                                        else {
                                            if(angular.isUndefined(groupMap['leaf'])) {
                                                groupMap['leaf'] = [];
                                            }
                                            groupMap['leaf'].push(currentRecord.parentRec);
                                        }
                                        
                                        
                                    }
     });
        var allData = [];
       //console.log('Object.keys(groupMap)',groupMap);
         Object.keys(groupMap).map(function(key) {
           
                 groupMap[key].map(function(rec) {
                     //console.log(rec);
                    allData.push(rec);
                });
            });
        console.log('alldata', allData);
       console.log('newRecordPositions',newRecordPositions);
        return allData;
   
    
    };
                            
                            //returns the new records by removing the tempId assgined to them
                            var getAllDataForInsert = function() {
                                tempInsertRow = [];
                                var recToInsert = [];
                                var i = 0;
                                newRecordPositions.map(function(pos) {
                                    $scope.dataList[pos].parentRec[$scope.dataList[pos].parentAPI] = $scope.dataList[pos].parentId;
                                    $scope.dataList[pos].Id = 'sno' + (i++);
                                    var newRec = angular.copy($scope.dataList[pos].parentRec);
                                    tempInsertRow.push(angular.copy(newRec));
                                    delete newRec['Id'];
                                    recToInsert.push(newRec);
                                    
                                });
                                console.log('rec to insert' ,recToInsert);
                                return recToInsert;
                            };
                           
                            //this method is no longer used
                            var checkEditInViewMode = function() {
                                console.log('changeCellEditableCondition6');
                                changeCellEditableCondition(true);
                                $scope.isView = true;
                                if(changedRowIndx.length > 0) {
                                    changedRowIndx.map(function(idx) {
                                        $scope.dataList[idx].parentRec = tempDataList[idx].parentRec;
                                    });    
                                }
                                
                            };
                            
                            //called when save or quick save is clicked
                            $scope.saveChanges = function(mode) {
                                
                                currentMode = mode;
                                //    console.log('current mode in save' ,currentMode);
                                
                                var updatedDataList = [];
                                var insertDataList = [];
                                if(mode == 'viewSave') {
                                    updateDataList = getUpdatedList();
                                    
                                }
                                else {
                                    updateDataList = getAllDataForUpdate();
                                    insertDataList = getAllDataForInsert();
                                }
                               // console.log('updateDataList' , updateDataList);
                                updateDataList = checkAndModifyProperties(updateDataList);
                                insertDataList = checkAndModifyProperties(insertDataList);
                                //console.log('updateDataList after modified' , updateDataList);
                                
                                $scope.disableButtons = true;
                                callSaveRecordsService(updateDataList,insertDataList);
                                
                                
                            };
                            
                            var getAssignedIdOfNewRecord = function(key) {
                                for(var i = 0;i < newRecordPositions.length;i++) {
                                    if($scope.dataList[newRecordPositions[i]].Id == key) {
                                        return $scope.dataList[newRecordPositions[i]].parentRec.Id;
                                    }
                                }
                            };
                            var assignIdToRecord = function(oldId,newId) {
                                for(var i = 0;i < newRecordPositions.length;i++) {
                                    if($scope.dataList[newRecordPositions[i]].Id == oldId) {
                                        $scope.dataList[newRecordPositions[i]].parentRec.Id = newId;
                                    }
                                }
                            };
                            var callSaveRecordsService = function(updateDataList,insertDataList) {
                                if(insertDataList.length > 0 && currentMode != 'editQuickSave') {
                                    changeModeIfNewActivityExists() ;   
                                }
                                if(Object.keys(newActivitiesCreated).length > 0) {
                                    //  console.log('new activities exist',$scope.disabledForSave,  $scope.disableButtons);
                                    
                                    if(insertDataList.length == 0 || !checkIfTasksExistsForActivities(insertDataList,'Project_Activity__c')) {
                                        $scope.disableButtonsWhenTasksDonotExist = true;
                                        $scope.disabledForSave = false;
                                        $scope.disableButtons = false;
                                        updateDataList =  revertModifiedProperties(updateDataList);
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>Please create Tasks for new Activities.');
                                        return;
                                    }
                                    
                                    
                                    
                                }
                                $scope.disableButtonsWhenTasksDonotExist = false;
                                hideErrors();
                                newRecordIdList = [];
                                // console.log('updatelist',updateDataList,'insertist',insertDataList);
                                errMapDetails = {};
                                errMsgsForDelete = {};
                                $scope.disabledForSave = true;
                                removeBackgroundToRowEdited(changedBackgroundRows);
                                changedBackgroundRows = [];
                                getRowsExpanded();
                                $scope.gridApi.selection.clearSelectedRows();
                                angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                updateInsertRecordsService(updateDataList,insertDataList)
                                .then(function(result) {
                                    $scope.disabledForSave = false;
                                    console.log('result' ,result);
                                    angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                    $scope.disableButtons = false;
                                    var isErr = false;
                                    if( Object.keys(result).length == 0) {
                                        //save success 
                                        //console.log('succesfully saved');
                                        if(!useExpandedRowDetails) {
                                            expandedRowIds = [];
                                            
                                        }
                                        getRowsExpanded();
                                        newActivitiesCreated = {};
                                        fetchAllRecords();
                                        changeColumnsVisibilty(); 
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-success');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Congrats!!&nbsp;</b>Records saved successfully.');
                                        
                                    }
                                    else if(result.hasOwnProperty('ERROR')) {
                                        //console.log('error while deserializing');
                                        angular.element(document.querySelector('#alertMain')).attr('class','alert alert-danger');
                                        angular.element(document.querySelector('#alertMsg')).html('<b>Sorry!!&nbsp;</b>Some records couldn\'t be saved. Please ensure that the data entered is correct.');
                                        if(insertDataList.length > 0) {
                                            checkNewRecords();
                                        }
                                    }
                                        else {
                                            //$scope.columnDefs[1].visible = true;
                                            //$scope.gridApi.grid.refresh();
                                            console.log('changeCellEditableCondition7');
                                            if(changedRowIndx.length == 0) {
                                                changeCellEditableCondition(false);
                                            }
                                            changedRowIndx = [];
                                            
                                            angular.forEach(Object.keys(result),function(keys) { 
                                                
                                                var splitId = keys.split("|");
                                                // var  key = splitId[0];
                                                var errHTML = '<table><tr><th><b class="fa fa-info-circle ng-hide"/>&nbsp;&nbsp;</th><th>Errors</th></tr>' 
                                                + '<tr><td></td><td><ul>';
                                                
                                                // console.log('all errors' + result[keys]  );
                                                angular.forEach(result[keys],function(err) { 
                                                    errHTML += '<li style="cursor:default !important">'+ err + '</li>'; 
                                                    
                                                });
                                                
                                                errHTML += '</ul></td></tr></table>';
                                                if(errHTML.indexOf('insert success') == -1) {
                                                    isErr = true; 
                                                    if(keys.indexOf('sno') != -1) {
                                                        keys = getAssignedIdOfNewRecord(keys);
                                                    }
                                                    
                                                    console.log('save not successful');   
                                                    // jQuery('#err' + keys).tooltip({title: errHTML, html: true, placement: "auto bottom"});
                                                    //  console.log('err title' , angular.element(document.querySelector('#err' + keys)).attr('title'));
                                                    //angular.element(document.querySelector('#err' + keys)).removeClass('ng-hide');
                                                    errMapDetails[keys] = errHTML; 
                                                    console.log('err map details', errMapDetails);
                                                    console.log('datalist' ,$scope.dataList);
                                                    //checkEditInViewMode();
                                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-danger');
                                                    angular.element(document.querySelector('#alertMsg')).html('<b>Sorry!!&nbsp;</b>Some records couldn\'t be saved.');
                                                    
                                                }
                                                else {
                                                    if(splitId.length > 1) {
                                                        // console.log('split id' + splitId[1] + angular.element(document.querySelector('.'+ splitId[1] + 'Fix')).length);
                                                        // var successfullyInsertedRow = angular.element(document.querySelector('.'+ splitId[1] + 'Fix')).removeClass('newrecordtableFix').addClass('newrecordtableInsertedFix').removeClass(splitId[1] + 'Fix').addClass(splitId[0] + 'Fix');
                                                        
                                                        /*  angular.element(successfullyInsertedRow).attr('id',splitId[0]);
                                    successfullyInsertedRow = angular.element(document.querySelector('.'+splitId[1] + 'Flow')).removeClass('newrecordtableFlow').addClass('newrecordtableInsertedFlow').removeClass(splitId[1] + 'Flow').addClass(splitId[0] + 'Flow');
                                    angular.element(successfullyInsertedRow).attr('id',splitId[0]);
                                    // $scope.expansionTree[splitId[0]] = true;
                                    angular.element(document.querySelector('#error' + splitId[1] + 'Fix')).attr('id','error'+splitId[0] + 'Fix');
                                    angular.element(document.querySelector('#error' + splitId[1])).attr('id','error'+splitId[0]);
                                    //  console.log('level one ids before' + $scope.levelOneIdList);*/
                                                        
                                                        assignIdToRecord(splitId[1],splitId[0]);
                                                        
                                                        newRecordIdList.push(splitId[0]);
                                                        if($scope.levelOneIdList.length > 0 ) {
                                                            if($scope.levelOneIdList[0].substring(0,3) == splitId[0].substring(0,3)) {
                                                                $scope.levelOneIdList.unshift(splitId[0]);
                                                                //    console.log('level one ids after' + $scope.levelOneIdList);
                                                            }
                                                        }
                                                    }
                                                }
                                                //console.log('error messages' + keys + result[keys]);
                                            });
                                            
                                            
                                            if(result != 'no records found to update or insert') {
                                                if(isErr) {
                                                    
                                                    // alert('Records failed to update');
                                                    
                                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-danger');
                                                    angular.element(document.querySelector('#alertMsg')).html('<b>Sorry!!&nbsp;</b>Some Records failed to update.');
                                                    $timeout(function() {
                                                        
                                                        if(newRecordIdList.length > 0) {
                                                            addTasksToNewActivities();
                                                        }
                                                        if(Object.keys(errMapDetails).length > 0) {
                                                            // console.log('errors while saving',errMapDetails);
                                                            checkNewlyAddedRowsIfErrorExists();    
                                                        }    
                                                        $timeout(function() {
                                                            console.log('in timeout for applying errors');
                                                            applyErrorsAndBackground();
                                                            // removeBackgroundOfRows();
                                                            //reAssignErrors();
                                                        });
                                                    });
                                                    
                                                }
                                                else  {
                                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-success');
                                                    angular.element(document.querySelector('#alertMsg')).html('<b>Congrats!!&nbsp;</b>Records updated Successfully.');
                                                    newActivitiesCreated = {};
                                                    afRenderPage();
                                                    //fetchAllRecords();
                                                    
                                                    
                                                }
                                            }
                                            
                                            else if(result == 'no records found to update or insert') {
                                                /* $scope.alertCls = "alert alert-info";
                            $scope.isAlertVisible = true;      
                            $scope.alertMessage =  '<strong><i class="fa fa-icon-info-sign"/> &nbsp;&nbsp;Info!!</strong>No records found to update.Please ensure that the records are checked if they are newly created';*/
                                                angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                                angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>No records found to update. Please ensure that the records are checked if they are newly created.');
                                                
                                            }
                                            
                                            
                                        }
                                    console.log('updateDataList',updateDataList);
                                    updateDataList =  revertModifiedProperties(updateDataList);
                                    setHeightOfGrid();
                                    $scope.gridApi.core.handleWindowResize();
                                    $timeout(function(){
                                        //adjustHeightOfRows();
                                    });
                                    
                                    if(Object.keys(errMapDetails).length > 0) {
                                        console.log('errmap details',errMapDetails);
                                        changedBackgroundRows = Object.keys(errMapDetails).slice(0);
                                        console.log('background', changedBackgroundRows);
                                        addBackgroundToRowEdited(changedBackgroundRows);
                                    }
                                });
    
         };
                            var checkIfTasksExistsForActivities = function(newRecordsList, parentAPIName) {
                                
                                newRecordsList.map(function(rec) {
                                    var key = rec[parentAPIName];
                                    if(newActivitiesCreated.hasOwnProperty(key)) {
                                        newActivitiesCreated[key] = Number(newActivitiesCreated[key]) + 1;
                                    }
                                });
                                var keys = Object.keys(newActivitiesCreated)
                                var keysLength = keys.length;
                                for(var i = 0;i < keysLength;i++) {
                                    if(newActivitiesCreated[keys[i]] <= 0) {
                                        return false;    
                                    }
                                }
                                return true;
                            };
                            
                            //when a new activity is created - even the user clicks on Save it should work like Quick Save because a new task should be created 
                            var changeModeIfNewActivityExists = function() {
                                for(var i = 0;i<tempInsertRow.length;i++) {
                                    // console.log('change mode',tempInsertRow[i]);
                                    if($scope.objectKeyPrefixIdentifier[tempInsertRow[i].Id.substring(0,3)].toLowerCase() == 'project_activity__c' ) {
                                        console.log('current mode changed');
                                        currentMode = 'editQuickSave';
                                        break;
                                    }
                                }
                            };
                            
                            //called when users accepts the slowness and goes to edit screen
                            proceedToEdit = function() {
                                
                                $scope.gridApi.treeBase.collapseAllRows();
                                $scope.gridOptions.excessRows = 10;
                                $scope.gridApi.selection.clearSelectedRows();
                                reorderSequenceNo();
                                $scope.hideEdit = true;
                                $scope.hideEditInView = false;  
                                console.log('changeCellEditableCondition1');
                                changeCellEditableCondition(false);
                                //changed height 70 to 45
                                $scope.gridOptions.rowHeight = 42;
                                // $scope.isView = false;
                                $scope.saveInView = false;
                                $scope.saveInEdit = true;
                                actionBtnsVisibility = $scope.hasPermission;
                                currentMode = 'editQuickSave';
                                
                                $scope.columnDefs[0].visible = $scope.hasPermission;
                                $scope.columnDefs[0].minWidth = 70;
                                // $scope.columnDefs[0].width = 70;
                                $scope.selectedObjectForMassUpdate = '';
                                $scope.columnDefs[1].visible = true;
                                console.log('columnDefs' ,$scope.columnDefs );
                                $scope.gridApi.core.notifyDataChange(uiGridConstants.dataChange.COLUMN);
                                $scope.gridApi.grid.refresh();
                                getRowsExpanded();
                                removeBackgroundToRowEdited(changedBackgroundRows);
                                changedBackgroundRows = [];
                                
                                $timeout(function() {
                                    //  expandRows(expandedRowIds);
                                    // adjustHeightOfRows();
                                });
                                for(var i = 0;i < $scope.dataList.length;i++) {
                                    $scope.dataList[i]['isView'] = false;
                                    //tempDataList['isView'] = false;
                                    
                                }
                                for(var i = 0;i < dataBeforeFilter.length;i++) {
                                    dataBeforeFilter[i]['isView'] = false;
                                    
                                }
                                for(var i = 0;i < tempDataList.length;i++) {
                                    tempDataList[i]['isView'] = false;
                                    
                                }
                                //console.log('expandedRowIds edit last' ,expandedRowIds);
                                
                            }
                            
                            //called when Edit is clicked on the top of the page is clicked
                            //goes to Edit mode directly if one/more level 1 records are checked
                            //otherwise displays a dialog to intimate the user about the slowness
                            $scope.onEditClicked = function() {
                                reAssignColumnOrder();
                                // console.log('selected rows', $scope.gridApi.selection.getSelectedRows());
                                var selectedLevelOneRecordIds = getSelectedLevelOneRecords($scope.gridApi.selection.getSelectedRows());
                                selectedEditRecords = selectedLevelOneRecordIds;
                                if(selectedLevelOneRecordIds.length > 0 && $scope.objectKeyPrefixIdentifier[selectedLevelOneRecordIds[0].substring(0,3)].toLowerCase() == $scope.searchOptions[0].ObjectAPIName__c.toLowerCase() ) {
                                    selectedEditModeRecords =  getIdOfChildRecordsToUpdate(childInfoRecordMap,$scope.searchOptions.length,selectedLevelOneRecordIds);
                                    console.log('expandedRowIds',expandedRowIds);
                                    getRowsExpanded();
                                    $scope.dataList = getSelectedRecordsForEditMode(tempDataList,selectedEditModeRecords);
                                    tempDataList = angular.copy($scope.dataList);
                                    useExpandedRowDetails = true;
                                    proceedToEdit();
                                }
                                else {
                                    openEditScreenModal();
                                    
                                }
                                //console.log('selected data list' , $scope.dataList);
                            
                                
                            };
                            
                            //this is used decide the view/edit mode based on the button clicked
                            var setDataMode = function() {
                                var flag = false;
                                if((currentMode == 'editSave' || currentMode == 'viewSave') &&  !$scope.disableButtonsWhenTasksDonotExist) {
                                    $scope.gridOptions.excessRows = 20;
                                    flag = true;
                                    selectedEditModeRecords = [];
                                    changeCellEditableCondition(true);
                                }
                                else {
                                    if(selectedEditModeRecords.length > 0) {
                                        /*     if(newRecordIdList.length > 0) {
                    newRecordIdList.map(function(recId){
                        selectedEditModeRecords.push(recId);
                  });
                    
                }*/
                selectedEditModeRecords =  getIdOfChildRecordsToUpdate(childInfoRecordMap,$scope.searchOptions.length,selectedEditRecords);
                $scope.dataList = getSelectedRecordsForEditMode(tempDataList,selectedEditModeRecords);    
                tempDataList  = angular.copy($scope.dataList);
                
                reorderSequenceNo();
            }
            else {
                selectedEditModeRecords = [];
            }
        }
        
        $scope.dataList.map(function(data){
            data['isView'] = flag;
        });
        dataBeforeFilter.map(function(data){
            data['isView'] = flag;
        });
        tempDataList.map(function(data){
            data['isView'] = flag;
        });
    };
                            var assignChangeToTempDataList = function(record) {
                                //console.log('record after cell edit',record['Id']);
                                for(var i = 0;i < dataBeforeFilter.length;i++) {
                                    
                                    if(dataBeforeFilter[i].parentRec['Id'] == record['Id']) {
                                        //console.log('record after cell edit match');
                                        dataBeforeFilter[i].parentRec = angular.copy(record);
                                        break;
                                    }
                                }
                            }
                            

                            //called when the filters on the column changes
                            var onColumnFilterChanged = function() {
                                // getRowsExpanded();
                                //console.log('column filter modified called');
                                columnLookupFilter = {}
                                if($scope.saveInEdit) {
                                    //console.log('filter on',tempDataList,$scope.dataList);
                                    applyNewChangesToOldList(tempDataList,$scope.dataList);
                                    applyNewChangesToOldList(dataBeforeFilter, $scope.dataList);
                                    
                                }
                                
                                var gridColumns = $scope.gridApi.grid.columns;
                                startAssigning = false;
                                for(var i = 0;i< gridColumns.length;i++) {  
                                    var filterTerm = gridColumns[i].filters[0].term;
                                    // console.log(gridColumns[i].colDef.name.split('.')[1]);
                                    if(gridColumns[i].colDef.name == 'parentRec.RMS_Owned_Flag__c' && !(typeof filterTerm === 'undefined' || filterTerm == null || filterTerm.length == 0)) {
                                        if(filterTerm.toLowerCase() == 'y') {
                                            columnLookupFilter['RMS_Owned_Flag__c'] = 'true';
                                        }
                                        else if(filterTerm.toLowerCase() == 'n') {
                                            columnLookupFilter['RMS_Owned_Flag__c'] = 'false';    
                                        }
                                            else {
                                                  columnLookupFilter['RMS_Owned_Flag__c'] = '--noresult--'
                                            }
                                    }
                                    else if(gridColumns[i].colDef.name.split('.')[1] == 'Id') {
                                        startAssigning = true;
                                        continue;
                                    }
                                    if(startAssigning) {
                                        
                                        if(typeof filterTerm === 'undefined' || filterTerm == null || filterTerm.length == 0) {
                                            continue;    
                                        }
                                        var columnName = gridColumns[i].colDef.name.split('.')[1];
                                        if(columnName == 'Site__c') {
                                           // columnName = 'CMF__c';
                                        }
                                        columnLookupFilter[columnName] = filterTerm; 
                                    }
                                    
                                    
                                }
                               // console.log('column lookup filter', columnLookupFilter);
                                if(Object.keys(columnLookupFilter).length > 0) {
                                    isInternalFilterOn = true;
                                    if(storeExpandedRows) {
                                        storeExpandedRows = false;
                                        if(tempDataList.length == dataBeforeFilter.length) {
                                            expandedRowIds = [];
                                        }
                                        // console.log('column filter expanded rows before',expandedRowIds);
                                        getRowsExpanded();
                                        rowsExpandedBeforeFilter = angular.copy(expandedRowIds);
                                         //console.log('column filter expanded rows after',expandedRowIds);
                                    }
                                    //2016-08-08 ragashalini.koka@cdk.com - fixed small bug on filter in onColumnFilterChanged method
                                   if($scope.searchValue.length > 2) {
                                      	isInternalFilterOn = false;
                                        $scope.filterModified();
                                       	isInternalFilterOn = true;
                                        filteredResults = filterRecordsWithGivenProperties($scope.dataList, columnLookupFilter);
                                    }
                                    else {
                                        if(tempDataList.length == dataBeforeFilter.length) {
                                            filteredResults = filterRecordsWithGivenProperties(dataBeforeFilter, columnLookupFilter);
                                        }
                                        else {
                                            filteredResults = filterRecordsWithGivenProperties(tempDataList, columnLookupFilter);
                                        }
                                        
                                    }
                                    showResultsOfFilter();
                                }
                                
                                //console.log('columnLookupFilter',columnLookupFilter,Object.keys(columnLookupFilter).length);
                                
                                if(Object.keys(columnLookupFilter).length == 0) {
                                    if( String(angular.element(document.querySelector('#alertMsg')).html()).indexOf('No results found for the given search.') != -1) {
                                        $scope.closeAlert();
                                    } 
                                    isInternalFilterOn = false;
                                    if($scope.searchValue.length > 2) {
                                        // console.log('calling filter modified');
                                        $scope.filterModified();
                                    }
                                    else {
                                        if(tempDataList.length == dataBeforeFilter.length) {
                                            $scope.dataList = angular.copy(dataBeforeFilter);   
                                        }
                                        else {
                                            $scope.dataList = angular.copy(tempDataList);   
                                        }
                                        
                                        storeExpandedRows = true;
                                        
                                        $timeout(function() {
                                            //console.log('column filter collapsed expand rows',rowsExpandedBeforeFilter);
                                            $scope.gridApi.treeBase.collapseAllRows();
                                          
                                                expandRows(rowsExpandedBeforeFilter);
                                            
                                            rowsExpandedBeforeFilter = [];
                                        });
                                    }
                                   // console.log('columnwise filters',$scope.dataList.length);
                                }
                                /*     $timeout(function() {
            reorderSequenceNo();
            reAssignErrors();
             setHeightOfGrid();
           $scope.gridApi.core.handleWindowResize();
        });*/
                                applyErrorsAndBackground();
                                
                                
                            };
                         
                            $scope.gridOptions.onRegisterApi = function(gridApi){
                                //set gridApi on scope
                                $scope.gridApi = gridApi;
                                gridApi.edit.on.afterCellEdit($scope,function(rowEntity, colDef, newValue, oldValue){
                                    var record = rowEntity.parentRec;
                                    
                                    var fieldAPI = colDef.name.split('.')[1];
                                    //   console.log('oldvalue',oldValue,'newValue',newValue,colDef, rowEntity.parentRec[fieldAPI]);
                                    var idx = fields.indexOf(fieldAPI);
                                    var type = (idx>-1) ? dataType[idx] : null; 
                                    if(type.toUpperCase() == 'DATE') {
                                        if(fieldAPI.toLowerCase().indexOf('actual_end_date__c') != -1) {
                                            if(!record.hasOwnProperty('Actual_End_Date__c') && record.hasOwnProperty('Actual_End_Date_Final__c')) {
                                                newValue = record['Actual_End_Date_Final__c'];
                                            }
                                        }
                                        
                                        var newDate = formatDate(newValue);
                                       
                                        if(newDate.indexOf('NaN') != -1) {
                                            newDate = '';    
                                        }
                                        rowEntity.parentRec[colDef.name.split('.')[1]] = newDate ;
                                        
                                    }
                                    
                                    /*if(fieldAPI == 'Sequence__c') {
                if(newValue != null && !isNaN(Math.floor(newValue))) {
                    rowEntity.parentRec[fieldAPI] = Math.floor(newValue);
                }
            }*/
            
            // console.log('newvalue',$scope.dataList[rowEntity.sequence].parentRec);
            if($scope.hideEdit || currentEditingRowIdx > -1) {
                
                // $scope.gridOptions.rowHeight = 70;
            }
            else {
                //  $scope.gridOptions.rowHeight = 40;
            }
            
            assignChangeToTempDataList(rowEntity.parentRec);
            $scope.$apply();
            inlineEdit = false;
            $timeout(function() {
                //   adjustHeightOfRows();
            });
            // console.log('oldvalue',oldValue,'newValue',newValue,colDef, rowEntity.parentRec[fieldAPI]);
        });
       
       gridApi.edit.on.beginCellEdit($scope, function(rowEntity, colDef) {
           
           var objName = $scope.objectKeyPrefixIdentifier[rowEntity.parentRec.Id.substring(0,3)];
           var columnAPI = colDef['name'].split('.')[1];
           var checkUpdateability = true;
           var record = rowEntity.parentRec;
           editingRowId = rowEntity.parentRec.Id;
           if(!$scope.saveInView && $scope.objectMetadata[objName].fieldsMap.hasOwnProperty(columnAPI) 
              && !$scope.objectMetadata[objName].fieldsMap[columnAPI].isUpdateable_c ) {
               
           }
           else if(!$scope.checkEditabilityForRMSOwnedRecords(rowEntity,colDef.name)) {    
               
               if(columnAPI.toLowerCase().indexOf('actual_end_date__c') != -1) {
                   if(!record.hasOwnProperty('Actual_End_Date__c') && record.hasOwnProperty('Actual_End_Date_Final__c')) {
                       columnAPI = 'Actual_End_Date_Final__c';
                       checkUpdateability = false;  
                   }
                   else {
                       checkUpdateability = true;  
                   }
               }
               if(checkUpdateability && $scope.objectMetadata[objName].fieldsMap.hasOwnProperty(columnAPI) && $scope.objectMetadata[objName].fieldsMap[columnAPI].isUpdateable_c) {
                   $scope.saveInView = true;
                   changedRowId = [];
                   changedRowId.push(editingRowId);
                   addBackgroundToRowEdited(changedRowId);
                   if(changedBackgroundRows.indexOf(editingRowId) == -1) {
                       changedBackgroundRows.push(editingRowId);
                   }
                   inlineEdit = true;
                   $scope.hideEditInView = true;
                   
               }
               
               //console.log('current editing row index' , currentEditingRowIdx);
               if(changedRowIndx.indexOf(rowEntity.sequence) == -1 && currentEditingRowIdx < 0) {
                   changedRowIndx.push(rowEntity.sequence);
                   
               }
               else if(currentEditingRowIdx > -1) {
                   angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                   angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>Edit already in progress.');
                   
               }
               
               // $scope.gridOptions.rowHeight = 70;
               
               // $scope.gridApi.grid.refresh();
               //inlineEdit = true;
               //$scope.hideEditInView = true;
               //setHeightOfGrid();
               //$scope.gridApi.core.handleWindowResize();
               $timeout(function() {
                   // adjustHeightOfRows();
                   reCalculateHeightOfGrid();
               });
           }
       });
       
       gridApi.selection.on.rowSelectionChanged($scope, function(row) {
           
           
           setHeightOfGrid();
           $scope.gridApi.core.handleWindowResize();
           // console.log('selected' ,rowEntity);   
           if(!insertNewRows && row.entity.parentRec.Id.length == 18 ) {
               
               var keyPrefix = row.entity.parentRec.Id.substring(0,3);
               if(row.isSelected) {
                   
                   if($scope.selectedObjectForMassUpdate == '') {
                       $scope.selectedObjectForMassUpdate = $scope.objectKeyPrefixIdentifier[keyPrefix];
                       /* if(row.entity.parentRec.RMS_Owned_Flag__c) {
                           angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                           angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>RMS record(s) is/are selected. Selecting Delete will not have an effect on them.');
                       }
                       else {
                           angular.element(document.querySelector('#alertMain')).addClass('ng-hide');
                       }*/
                   }
                   else {
                       if($scope.selectedObjectForMassUpdate != $scope.objectKeyPrefixIdentifier[keyPrefix]) {
                           row.isSelected = false;
                       }
                   }
               }
               else {
                   if(gridApi.selection.getSelectedRows().length == 0) {
                       $scope.selectedObjectForMassUpdate = '';
                   }
               }
               console.log('$scope.selectedObjectForMassUpdate',$scope.selectedObjectForMassUpdate);
           }
           else if((row.entity.parentRec.Id.length == 18 && insertNewRows)) {
               
               row.isSelected = false;
           }
           
               else if(row.entity.parentRec.Id.length < 18 && insertNewRows) {
                   if(!row.isSelected) {
                       angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                       angular.element(document.querySelector('#alertMsg')).html('<b>Info!! &nbsp;</b>You have added a new activity or task.'+
                                                                                 '&nbsp;Before saving this record, please ensure the row(s) of the activity or task you just added contains a checkmark in the second column.');
                       
                   }
               }
           
       });
       
       gridApi.core.on.sortChanged( $scope, function(grid, sortColumns) {
           
           sortColumnsInfo = sortColumns;
           //fix to change the sort numbers when sort on any column is removed
           //console.log('sort columns' ,sortColumns);
           var priority = 0;
           var sortValue = -1;
           //console.log('sort columns',sortColumns.length,Object.keys(sortInfoMap).length);
           if(sortColumns.length < Object.keys(sortInfoMap).length) {
               var keys =  Object.keys(sortInfoMap);
               for(var i = 0;i <  keys.length;i++) {
                   var found = false;
                   for(var j = 0;j < sortColumns.length;j++) {
                       if(keys[i] == sortColumns[j].colDef.name) {
                           found = true;   
                           break;
                       }
                       
                   }
                   if(!found) {
                       sortValue = sortInfoMap[keys[i]]
                       delete sortInfoMap[keys[i]];
                       break;
                   }
               }
               if(sortValue != -1) {
                   Object.keys(sortInfoMap).map(function(key) {
                       if(sortInfoMap[key] > sortValue) {
                           sortInfoMap[key] -= 1;
                       }
                   });
               }
               console.log('sort info map change',sortInfoMap);    
           }
           
           for(var i = (sortColumns.length-1);i >= 0;i--) {
               //  sortColumns[i].sort.priority = priority++;
               if(sortValue == -1) {
                   sortInfoMap[sortColumns[i].colDef.name] = sortColumns[i].sort.priority;
               }
               else {
                   sortColumns[i].sort.priority = sortInfoMap[sortColumns[i].colDef.name];
               }
           }
           //  console.log('sortInfoMap',sortInfoMap);
           if(saveByDefault) {
               storeGridConfig();
           }
           applyErrorsAndBackground();
           
       });
       gridApi.core.on.filterChanged( $scope, function(column) {
           //console.log('called filter change',counter);
           if(saveByDefault) {
               storeGridConfig();
           }
           counter++;
           if(counter == 1) {
               $timeout(function() { 
                   counter = 0;
                   onColumnFilterChanged();
               },700);
           }
       });
       if(gridApi.colResizable && saveByDefault ) {
           gridApi.colResizable.on.columnSizeChanged($scope,function() {
               storeGridConfig();
           });
       }
       
       if(gridApi.core && saveByDefault) {
           gridApi.core.on.columnVisibilityChanged($scope,function() {
               storeGridConfig();
           });    
       }
       
       if(gridApi.colMovable ) {
           
           gridApi.colMovable.on.columnPositionChanged($scope,function(colDef, originalPosition, newPosition) {
               reAssignColumnOrder();
               if(saveByDefault) {
                   storeGridConfig();
               }
           });
           
       }
       
       if(gridApi.pinning) {
           gridApi.pinning.on.columnPinned($scope, function(colDef,container) {
               console.log('col pinned',colDef,container.length);
               if(container.length == 0) {
                   colDef['pinnedLeft'] = false;
                   colDef['pinnedRight'] = false;
               }
               else if(container.toLowerCase() == 'left') {
                   colDef['pinnedLeft'] = true;
                   colDef['pinnedRight'] = false;
               }
                   else if(container.toLowerCase() == 'right') {
                       colDef['pinnedRight'] = true;
                       colDef['pinnedLeft'] = false;
                   }
               if(saveByDefault) {
                   storeGridConfig();
               }
               reAssignColumnOrder();
           })
       }
       
       gridApi.core.on.scrollEnd($scope,function() {
           // console.log('scrolling end in grid');
           
           $timeout(function() {
               applyErrorsAndBackground();
           });
           
       });
       
   };   
							
                            //this is not currently in use                            
                            var clearSortOnColumns = function() {
                                if(sortColumnsInfo.length > 0) {
                                    for(var i = 0;i < sortColumnsInfo.length;i++) {
                                        sortColumnsInfo[i].sort.direction = null;
                                    }
                                    //console.log('temp data list', tempDataList);
                                    $scope.dataList = angular.copy(tempDataList);
                                }
                                
                            };
                            
                            //clears the filters present on the columns and header
                            var clearFilters = function() {
                                
                                $scope.searchValue = '';
                                // console.log('clear filters',$scope.searchValue);
                                var gridColumns = $scope.gridApi.grid.columns;
                                for(var i = 0 ;i < gridColumns.length;i++) {
                                    gridColumns[i].filters[0].term ='';
                                }
                                onColumnFilterChanged();
                            }
                            
                            //returns T/F
                            //T - if the mentioned property is present in the object (Eg:CDK_Assignee__c in activity)
                            //F - if the mentioned property is not present in the object (Eg:CDk_Assignee__c in milestone)
                            $scope.isOwnProperty = function(recId,columnAPI) {
                                
                                var objName = $scope.objectKeyPrefixIdentifier[recId.substring(0,3)];
                                //to display Site__c as normal text
                                if((objName == 'project_task__c' || objName == 'project_activity__c') && columnAPI.toLowerCase() == 'site__c') {
                                    return false;
                                }
                                var fieldMap = customizedFieldsMap['objects'][objName];
                                var fieldsList = Object.keys(fieldMap).map(function(key){
                                    return fieldMap[key];
                                });
                                
                                
                                // console.log('fieldslist',fieldsList);
                                //console.log('api',objName,columnAPI,fieldsList);
                                //console.log(objName,'recId', recId,'columnAPI',columnAPI,$scope.objectMetadata[objName].fieldsMap[columnAPI]); 
                                try {
                                    
                                    if(fieldsList.indexOf(columnAPI) != -1 && $scope.objectMetadata[objName].fieldsMap[columnAPI].isAccessible_c) {
                                        
                                        return true;    
                                    }
                                    else if(columnAPI.toLowerCase().indexOf('actual_end_date__c') != -1 ) { 
                                        
                                        //workaround for actual end dates since the properties are different for parent and child
                                        if($scope.objectMetadata[objName].fieldsMap['Actual_End_Date_Final__c'].isAccessible_c && fieldsList.indexOf('Actual_End_Date_Final__c') != -1) {
                                            return true;    
                                        }
                                    }
                                    
                                    
                                }
                                catch(err) {
                                    // console.log('catch',objName,columnAPI);
                                }
                                
                                return false;
                            };
                            
                            //called when Mass Update is clicked
                            $scope.onMassUpdate  = function() {
                                
                                
                                $scope.isDisabled = true;
                                $scope.isUpdateEnabled();
                                $scope.getFieldsMap();
                                
                            };
                            
                            //disables or enables the Next button on the field selection modal
                            //disables - when no fields are selected
                            //enables - when one/more fields are selected
                            $scope.isUpdateEnabled = function() {
                                
                                var massUpdateChkBoxes = angular.element(document.querySelector('.showFieldsToUpdate')).find('input:checkbox');
                                $scope.isDisabled = true;
                                
                                for(var i = 0;i < massUpdateChkBoxes.length;i++) {
                                    //console.log(document.querySelector('#' + angular.element(massUpdateChkBoxes[i]).attr('id')).checked);
                                    if(document.querySelector('#' + angular.element(massUpdateChkBoxes[i]).attr('id')).checked) {
                                        $scope.isDisabled = false;
                                        break;
                                    }
                                    
                                }
                                
                            };
                            
                            //populates the fields for the selected object for Mass Update
                            //RMS Owned rules are followed
                            //If only RMS records are selected - RMS editable fields will be shown
                            //If only non RMS/combination of RMS and Non RMS are selected - all the fields editable will be shown
                            $scope.getFieldsMap = function() {
                                selectedRecordLevel = -1;
                                try{
                                    $scope.alertMsgForCombinationOfRMSAndNonRms = '';
                                    $scope.selectedObjectFields = {};
                                    //console.log(customizedFieldsMap['objects'],$scope.selectedObjectForMassUpdate);
                                    var selectedRowsForMassUpdate = $scope.gridApi.selection.getSelectedRows();
                                    var RMSFields = [];
                                    
                                    if(selectedRowsForMassUpdate.length > 0) {
                                        selectedRecordLevel = selectedRowsForMassUpdate[0].level;
                                        if(areAllRMSRows(selectedRowsForMassUpdate)) {
                                            
                                            RMSFields = RMSOwnedDetails[selectedRecordLevel];
                                            console.log('RMS Fields',RMSFields);
                                        }
                                        if(getAnyRMSRecord()) {
                                            $scope.alertMsgForCombinationOfRMSAndNonRms = '<b>Please Note :</b> For certain fields (e.g. Planned Dates, Actual Dates, Assignees, etc.),' 
                                            +'updates will ONLY be applied to your selected records which are NOT RMS-scheduled.'
                                        }
                                    }
                                    var fieldMap = customizedFieldsMap['objects'][$scope.selectedObjectForMassUpdate];
                                    
                                    Object.keys(fieldMap).sort().map(function(key) {
                                        value = fieldMap[key];
                                        $scope.selectedObjectFields[value] = $scope.objectMetadata[$scope.selectedObjectForMassUpdate].fieldsMap[value];
                                    });
                                    
                                    if(RMSFields.length > 0) {
                                        var keys = Object.keys($scope.selectedObjectFields);
                                        keys.map(function(key) {
                                            if(RMSFields.indexOf(key) == -1) {
                                                delete $scope.selectedObjectFields[key];    
                                            }
                                        });
                                    }
                                }
                                catch(err) {
                                    
                                }
                                
                            };
                            
                            //returns the list of selected fields for Mass Update
                            $scope.getSelectedFields = function() {
                                
                                var massUpdateChkBoxes = angular.element(document.querySelector('.showFieldsToUpdate')).find('input:checkbox');
                                //  var anyFieldSelected = false;
                                $scope.massUpdateFieldsSelected = [];
                                
                                for(var i = 0;i < massUpdateChkBoxes.length;i++) {
                                    // console.log(document.querySelector('#' + angular.element(massUpdateChkBoxes[i]).attr('id')).checked);
                                    if(document.querySelector('#' + angular.element(massUpdateChkBoxes[i]).attr('id')).checked ) {
                                        $scope.massUpdateFieldsSelected.push(angular.element(massUpdateChkBoxes[i]).attr('id'));
                                    }
                                    
                                }
                            };
                            
                            //gets the list of records to be mass updates with the given field values
                            //RMS Owned rules are followed
                            $scope.massUpdateFields = function() {
                                
                                var rows = $scope.gridApi.selection.getSelectedRows();     
                                //console.log('rows',rows);
                                $scope.recordsToBeMassUpdated = [];
                                var massUpdateObj = {};
                                
                                for(var j = 0;j<$scope.massUpdateFieldsSelected.length;j++) { 
                                    var dataType = angular.element(document.querySelector('#massUpdateRecords')).find('span[id=' + $scope.massUpdateFieldsSelected[j]+']').attr('dataType');
                                    var fieldValue = angular.element(document.querySelector('#massUpdateRecords')).find('span').find('#' + $scope.massUpdateFieldsSelected[j]).text()
                                    switch(dataType) {
                                        case 'DATE' :  massUpdateObj[$scope.massUpdateFieldsSelected[j]] = formatDate(new Date(fieldValue));
                                            if(massUpdateObj[$scope.massUpdateFieldsSelected[j]].indexOf('NaN') != -1) {
                                                massUpdateObj[$scope.massUpdateFieldsSelected[j]]=null;
                                            }   
                                            
                                            break;
                                        case 'DATETIME' :  var d = new Date(fieldValue);
                                            massUpdateObj[$scope.massUpdateFieldsSelected[j]] = d.getTime();
                                            if(String(massUpdateObj[$scope.massUpdateFieldsSelected[j]]).indexOf('NaN') != -1) {
                                                massUpdateObj[$scope.massUpdateFieldsSelected[j]]=null;
                                            }
                                            break;
                                        case 'BOOLEAN' :massUpdateObj[$scope.massUpdateFieldsSelected[j]] = fieldValue;
                                            if(massUpdateObj[$scope.massUpdateFieldsSelected[j]] == null || massUpdateObj[$scope.massUpdateFieldsSelected[j]] == "") {
                                                massUpdateObj[$scope.massUpdateFieldsSelected[j]] = false;
                                            } 
                                            break;
                                        default :  massUpdateObj[$scope.massUpdateFieldsSelected[j]] = fieldValue;
                                            
                                            
                                            if(massUpdateObj[$scope.massUpdateFieldsSelected[j]] == "") {
                                                
                                                massUpdateObj[$scope.massUpdateFieldsSelected[j]] = null;
                                                
                                            }
                                            
                                            break;
                                            
                                    }
                                }
                                console.log('massUpdateObj',massUpdateObj);
                                recordsToBeMassUpdated = [];
                                var RMSFields = [];
                                console.log('handling RMS and Non RMS',selectedRecordLevel);
                                if(selectedRecordLevel > -1) {
                                    RMSFields = RMSOwnedDetails[selectedRecordLevel];
                                    console.log('handling RMS and Non RMS',RMSFields);
                                }
                                rows.map(function(row){
                                    row.isSelected = false;
                                    if(!row.parentRec.RMS_Owned_Flag__c) {    
                                        Object.keys(massUpdateObj).map(function(prop) {
                                            row.parentRec[prop] = massUpdateObj[prop];
                                        });
                                        recordsToBeMassUpdated.push(row.parentRec);
                                    }
                                    else {
                                        Object.keys(massUpdateObj).map(function(prop) {
                                            console.log('handling RMS and Non RMS',prop,RMSFields.indexOf(prop));
                                            if(RMSFields.indexOf(prop) != -1) {
                                                row.parentRec[prop] = massUpdateObj[prop];
                                            }
                                        });
                                        recordsToBeMassUpdated.push(row.parentRec);
                                    }
                                    
                                }); 
                                
                                $scope.selectedObjectForMassUpdate = '';
                                $scope.massUpdateFieldsSelected = [];
                                recordsToBeMassUpdated = checkAndModifyProperties(recordsToBeMassUpdated);
                                //  console.log('massupdate' ,recordsToBeMassUpdated);
                                currentMode = ($scope.saveInEdit) ? 'editQuickSave' : 'viewSave';
                                $scope.selectedObjectForMassUpdate = ''
                                callSaveRecordsService(recordsToBeMassUpdated,[]);
                                
                                
                                
                            };
                            
                            $scope.getValue = function(key) {
                                var idx = fields.indexOf(key);
                                if(idx > -1) {
                                    return labels[idx];    
                                }
                            }
                            
                            //converts the hierarchial JSON data to a format followed to display the tree structure in UI Grid
                            var convertHierarchyToFlatStructure = function( childArray, currentLevel, dataArray ){
                                angular.forEach(childArray, function( childNode ){
                                    childNode.$$treeLevel = currentLevel;
                                    dataArray.push( childNode );
                                    convertHierarchyToFlatStructure( childNode.children, currentLevel + 1, dataArray );
                                });
                            };
                            
                            //called when Cancel is clicked on the top
                            $scope.onCancel = function() {
                                if(Object.keys(newActivitiesCreated).length > 0) {
                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                    angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>Please create Tasks for new Activities.');
                                    return;
                                }
                                currentMode = 'viewSave';
                                $scope.viewInEdit = false;
                                $scope.saveInEdit = false;
                                $scope.hideEdit = false;
                                actionBtnsVisibility = $scope.hasPermission;
                                errMsgsForDelete = {};
                                errMapDetails = {};
                                changedBackgroundRows = [];
                                $scope.columnDefs[0].visible = $scope.hasPermission;
                                $scope.columnDefs[0].minWidth = 115;
                                $scope.columnDefs[1].visible = false;
                                $scope.gridApi.core.notifyDataChange(uiGridConstants.dataChange.COLUMN);
                                $scope.gridApi.grid.refresh();
                              //  console.log('columns' , $scope.columnDefs[0],$scope.columnDefs[1]);
                                $scope.gridOptions.rowHeight = 42;
                                
                                changeCellEditableCondition(true);
                                $scope.closeAlert();
                               // console.log('lengths', $scope.dataList.length, tempDataList.length,expandedRowIds);
                                if(!useExpandedRowDetails) {
                                    //expandedRowIds = [];
                                    
                                }
                                //getRowsExpanded();
                                useExpandedRowDetails = false;
                                removeBackgroundToRowEdited(changedBackgroundRows);
                                changedBackgroundRows = [];
                                fetchAllRecords();
                                if(String(jQuery('#alertMsg').html()).indexOf('Please check the new records to be saved') != -1) {
                                    jQuery('#alertMain').addClass('ng-hide').removeClass('alert-info').removeClass('alert');
                                    jQuery('#alertMsg').html('');
                                }
                                
                            };
                            
                            //called when Clear All Changes is clicked on the top
                            $scope.onClearAllChanges = function() {
                                if(Object.keys(newActivitiesCreated).length > 0) {
                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                    angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>Please create Tasks for new Activities.');
                                    return;
                                }
                                currentMode = 'editQuickSave';
                                removeBackgroundToRowEdited(changedBackgroundRows);
                                changedBackgroundRows = [];
                                errMsgsForDelete = {};
                                errMapDetails = {};
                                changedBackgroundRows = [];
                                $scope.closeAlert();
                                getRowsExpanded();
                                fetchAllRecords();
                            };
                            
                            //called when Refresh is clicked on the top
                            $scope.onRefreshClicked = function() {
                                //console.log('current mode in refresh',currentMode);
                                removeBackgroundToRowEdited(changedBackgroundRows);
                                errMsgsForDelete = {};
                                errMapDetails = {};
                                changedBackgroundRows = [];
                                expandedRowIds = [];  
                                getRowsExpanded();
                                afRenderPage();
                            };
                            
                            //called when Cancel is clicked on Add Contact modal
                            $scope.closeContactDialog = function() {
                                $scope.contactSavingError ='';
                                $scope.addNewContact = false; 
                                $scope.showSuccessMsg = false;
                            };
                            
                            //called when Save is clicked on Add Contact modal
                            $scope.onContactSaved = function() {
                                $scope.contactSavingError = '';
                                $scope.showSuccessMsg = false;
                                //console.log('save clicked');
                                var contactObject = {};
                                contactObject['firstName'] = angular.element(document.querySelector('#ctctFirstName')).html();
                                contactObject['lastName'] = angular.element(document.querySelector('#ctctLastName')).html();
                                contactObject['email'] =  angular.element(document.querySelector('#ctctEmail')).html();;
                                contactObject['phone'] =  angular.element(document.querySelector('#ctctPhone')).html();
                                contactObject['accId'] =  angular.element(document.querySelector('#accSite')).html();
                                contactObject['ctctRole'] =  angular.element(document.querySelector('#contactRole')).html();
                                contactObject['projectRole'] =  angular.element(document.querySelector('#projectRole')).html();
                                contactObject['subprojectId'] = $scope.paramId; 
                                //console.log('after save' + angular.element(document.querySelector('#projectRole')).html());
                                
                                
                                var requiredKeys = ['firstName','lastName','accId','ctctRole','projectRole'];
                                
                                var error = validateContactObject(contactObject,requiredKeys);
                                
                                $scope.contactSavingError = error;
                                // console.log('error' + error +  $scope.contactSavingError);
                                if(error.length == 0) {
                                    angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                    ALL_TreeGridController_UIGrid.addNewContact(angular.toJson(contactObject),function(result,event) {
                                        angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                        
                                        if(event.status) {
                                            
                                            if(result.length == 0) {
                                                //console.log('result' + result);
                                                $scope.showSuccessMsg = true;
                                                angular.element(document.querySelector('#ctctTable')).addClass('ng-hide');
                                                angular.element(document.querySelector('#ctctSuccess')).removeClass('ng-hide');
                                                angular.element(document.querySelector('#contactSave')).addClass('ng-hide'); 
                                                angular.element(document.querySelector('#contactCancel')).addClass('ng-hide');
                                                angular.element(document.querySelector('#ctctSuccessBtn')).removeClass('ng-hide');
                                            }
                                            else {
                                                for(var i = 0;i < result.length;i++){
                                                    $scope.contactSavingError += '<li>' + result[i] + '</li>';
                                                }
                                                 $scope.$apply();
                                            }
                                        }
                                        
                                    });
                                }
                            };
                            
                            //controls the message to be displayed when Display PSR is selected
                            $scope.displayPSR = function(PSRValue,objects) {
                                $scope.showActionButtonsforPSR = true;
                                $scope.PSRObj = {PSRValue : PSRValue, objects : objects};
                                console.log($scope.PSRObj); 
                                if($scope.selectedObjectForMassUpdate == '') {
                                    $scope.PSRDisplayMsg = '<p>You did not check any Milestones so this is an "ALL-OR-NOTHING" action - this action will update ALL Milestone records on this Subproject.'     
                                    + '<br><br>If you want this change to apply to specific Milestones, first check the box next to the desired Milestone(s) on the Milestone Display Page and then rerun this action.'
                                    + '<br><br>You can further customize what displays on your PSR through the Milestone Edit Page, either individually through single records or in volume through Mass Update.'   
                                    + '<br><br><b>Do you wish to proceed?</b></p>';
                                }
                                else if( $scope.selectedObjectForMassUpdate.toLowerCase() == $scope.searchOptions[0].ObjectAPIName__c.toLowerCase()) {
                                    $scope.PSRDisplayMsg = '<p>Since you selected one or more Milestones this action will only update the selected Project Milestone records on this Subproject.  It will not change the Display on PSR value for Milestones that are not selected'  
                                    +'<br><br>If you want this change to apply to ALL Milestones, verify that you have not checked the box next to any Milestone on the Milestone Display Page and then rerun this action.'
                                    +'<br><br>You can further customize what displays on your PSR through the Milestone Edit Page, either individually through single records or in volume through Mass Update.'   
                                    +'<br><br><b>Do you wish to proceed?</b></p>' ;
                                }
                                    else {
                                        $scope.showActionButtonsforPSR = false;
                                        $scope.PSRDisplayMsg = '<p>You have selected an Activity or Task and this action is only supported if you check a Milestone or if no items are checked.  Please uncheck any Activities and Tasks.' 
                                        +'<br><br> If you want to enable/disable PSR display on selected Activities or Tasks, this can be accomplished through the Milestone Edit Page.</p>';
                                    }
                                
                            };
                            
                            //called when PSR display is accepted 
                            $scope.confirmPSR = function() {
                                console.log('after ok clicked' , $scope.PSRObj);
                                updateRecordsWithPSR($scope.PSRObj['PSRValue'], $scope.PSRObj['objects']);
                            };
                            
                            //the records selected will be updated with the given PSR value
                            var updateRecordsWithPSR = function(PSRValue,objects) {
                                
                                var recordsToBeUpdated = [];
                                var objectKeyMap = {};
                                
                                if(objects.indexOf('M') != -1) {
                                    objectKeyMap[ $scope.objectMetadata['project_milestone__c'].keyPrefix_c] = 'project_milestone__c';
                                    
                                }
                                if(objects.indexOf('A') != -1) {
                                    objectKeyMap[ $scope.objectMetadata['project_activity__c'].keyPrefix_c] = 'project_activity__c';
                                    
                                }
                                if(objects.indexOf('T') != -1) {
                                    objectKeyMap[ $scope.objectMetadata['project_task__c'].keyPrefix_c] = 'project_task__c';
                                    
                                    
                                }
                                var recIdList;
                                if(($scope.selectedObjectForMassUpdate == '' || $scope.selectedObjectForMassUpdate.toLowerCase() != $scope.searchOptions[0].ObjectAPIName__c.toLowerCase())) {
                                    recIdList = Object.keys(allRecordsResult);
                                }
                                else {
                                    var selectedLevelOneRecordIds = getSelectedLevelOneRecords($scope.gridApi.selection.getSelectedRows());
                                    
                                    recIdList =  getIdOfChildRecordsToUpdate(childInfoRecordMap,Object.keys(objectKeyMap).length,selectedLevelOneRecordIds);
                                    
                                } 
                                
                                // console.log('selected records for PSR update' , recIdList.length);
                                recordsToBeUpdated =   recordsWithPSRValue(recIdList,objectKeyMap,PSRValue);
                                console.log('updated records' ,recordsToBeUpdated,recordsToBeUpdated.length);
                                //angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                //  $scope.disableButtons = true;
                                callSaveRecordsService(recordsToBeUpdated,[]);
                                $scope.selectedObjectForMassUpdate = '';
                                
                            };
                            
                            //used to hide alert
                            hideAlert = function() {
                                angular.element(document.querySelector('#alertMain')).addClass('ng-hide'); 
                                setHeightOfGrid();
                                if(tempDataList.length == dataBeforeFilter.length) {
                                    //expandedRowIds = [];    
                                }
                                getRowsExpanded();
                                $scope.gridApi.core.handleWindowResize();    
                            }
                             //calls hide alert
                            $scope.closeAlert = function() {
                                
                                hideAlert();
                                
                            };
                            
                            //controls the buttons M, MA, MAT on the page
                            $scope.expandToLevel = function(treeLevel) {
                                $scope.gridApi.treeBase.collapseAllRows();
                                treeLevel -= 1;
                                if(treeLevel  > 0) {
                                    var rows = $scope.gridApi.grid.rows;
                                    
                                    rows.map(function(row) {
                                        if(row.entity.level < treeLevel) {
                                            $scope.gridApi.treeBase.expandRow(row);
                                        }
                                    });
                                    
                                    
                                }
                                if($scope.dataList.length > 0) {
                                    $scope.gridApi.core.scrollTo( $scope.dataList[0], 0);
                                }
                                $timeout(function(){
                                    // adjustHeightOfRows();
                                    applyErrorsAndBackground();
                                });
                                expandedRowIds = []; 
                                getRowsExpanded();
                                
                            };
                            
                            // updates an array with the rows which are in expanded state at a particular point of time
                            // used to maintain hierarchy when the data in the grid is refreshed
                            getRowsExpanded = function() {
                                
                                var rows = $scope.gridApi.grid.rows;
                                
                                rows.map(function(row) {
                                    if(row.treeNode.state == 'expanded' ) { 
                                        expandedRowIds.push(row.entity.parentRec.Id);
                                        
                                    }
                                });
                              //  console.log('list of rows expanded' , expandedRowIds);
                                
                            };
                            $scope.searchValue = '';
                            
                            //called when the search box or dropdown displaying the objects is modified
                            $scope.filterModified = function() {
                                
                                console.log('filter modified called');
                                $scope.closeAlert();
                                // getRowsExpanded();
                                // console.log('expand inside filter',expandedRowIds);
                                recordIdsToBeShown = [];
                                
                                console.log('search value',$scope.searchValue,'selected object',$scope.selectedObject);
                                console.log('storeExpandedRows',storeExpandedRows);
                                if($scope.saveInEdit) {
                                    //console.log('filter on',tempDataList,$scope.dataList);
                                    applyNewChangesToOldList(tempDataList,$scope.dataList);
                                    applyNewChangesToOldList(dataBeforeFilter, $scope.dataList);
                                    
                                }
                                
                                if($scope.searchValue.length > 2) {
                                    if(storeExpandedRows) {
                                        storeExpandedRows = false;
                                        if(tempDataList.length == dataBeforeFilter.length) {
                                            console.log('expand equal length',expandedRowIds);
                                            expandedRowIds = [];
                                        }
                                        
                                        console.log('expandedRowIds before',expandedRowIds);
                                        getRowsExpanded();
                                        rowsExpandedBeforeFilter = angular.copy(expandedRowIds);
                                        console.log('expandedRowIds after',expandedRowIds);
                                    }
                                    var searchObjectKeyPrefix = 'All' ;
                                    if($scope.selectedObject != 'All') {
                                        searchObjectKeyPrefix = objectKeyPrefixIdentifierInverse[$scope.selectedObject.toLowerCase()];
                                    }
                                    
                                    recordsToBeSearched = getRecordsToBeSearched(searchObjectKeyPrefix,allRecordsResult);
                                    if(!isInternalFilterOn && tempDataList.length == dataBeforeFilter.length) {
                                        
                                        recordsToBeSearched = refineRecordsTobeSearched(recordsToBeSearched, dataBeforeFilter);
                                        
                                    }
                                    else if(!isInternalFilterOn && tempDataList.length != dataBeforeFilter.length) {
                                        
                                        recordsToBeSearched = refineRecordsTobeSearched(recordsToBeSearched, tempDataList);
                                        
                                        
                                    }
                                        else if(isInternalFilterOn) {
                                            
                                            recordsToBeSearched = refineRecordsTobeSearched(recordsToBeSearched, $scope.dataList);
                                           
                                        }
                                    setSearchValue($scope.searchValue);
                                    filterRecords();
                                }
                                else {
                                    if(!isInternalFilterOn) {
                                        
                                        if(tempDataList.length == dataBeforeFilter.length) {
                                            
                                            $scope.dataList = angular.copy(dataBeforeFilter);   
                                        }
                                        else {
                                            
                                            $scope.dataList = angular.copy(tempDataList);   
                                        }
                                        storeExpandedRows = true;
                                        
                                        $timeout(function() {
                                            $scope.gridApi.treeBase.collapseAllRows();
                                            //console.log('expanded rows 2',rowsExpandedBeforeFilter );
                                           
                                            expandRows(rowsExpandedBeforeFilter);
                                            
                                            rowsExpandedBeforeFilter = [];
                                        });
                                        
                                        // console.log('expandedRowIds',expandedRowIds);
                                    }
                                    else {
                                        onColumnFilterChanged();    
                                    }
                                }
                                //adjustHeightOfRows();
                                /* removeBackgroundOfRows();
       $timeout(function() {
            reorderSequenceNo();
            reAssignErrors();
             setHeightOfGrid();
           $scope.gridApi.core.handleWindowResize();
        });*/
                                 applyErrorsAndBackground();
                             };
                            //formats the number to display 2 decimal places for all number fields other than Sequence__c field
                            $scope.getFormattedNumber = function(value,field) {
                                
                                if(!angular.isUndefined(value) && value == 0) {
                                    // console.log('number 1');
                                    if(field.toLowerCase().indexOf('sequence__c') == -1) {
                                        console.log('formatting number',parseFloat(value).toFixed(2));
                                        return !isNaN(parseFloat(value).toFixed(2)) ? parseFloat(value).toFixed(2) : value ;
                                    }
                                }
                                if(!angular.isUndefined(value) && value != null && value != '') {
                                    //  console.log('number 2');
                                    if(field.toLowerCase().indexOf('sequence__c') == -1) {
                                        value = fixedDown(value,2);
                                        return (isFinite(value) && !isNaN(parseFloat(value).toFixed(2))) ? parseFloat(value).toFixed(2) : value ;
                                    } 
                                    
                                }
                                if(angular.isUndefined(value) || value == null || value == '') {
                                    //console.log('undefined value');
                                    return null;
                                    
                                }
                                
                                if(value != null && value != '') {
                                    // console.log('number 3');
                                    return !isNaN(Math.floor(value)) ? Math.floor(value) : value ;
                                }
                                if(isNaN(Math.floor(value))) {
                                    //console.log('number 4'); 
                                    value = null;    
                                }
                                return value;
                            };
                            //this method is currently no in use
                            var adjustHeightOfRows = function() {
                                //console.log('adjustHeightOfRows' , currentMode);
                                /* $timeout(function() {
        fixHeightsOfNonFilteredRows(recordIdsToBeShown);
    });*/
    /*if(currentEditingRowIdx > -1 || inlineEdit) {
         console.log('check 3');
        setElementsToOriginalHeight("50px");
       
    }
     else if(currentMode.indexOf('view') != -1 || currentMode.indexOf('editSave') != -1) {
         console.log('check 1');
         setElementsToOriginalHeight("50px");    
     }
     else if(currentMode.indexOf('edit') != -1 && currentMode.indexOf('editSave') == -1) {
             console.log('check 2');
         setElementsToOriginalHeight("50px"); 
     }*/  
    
    
}
                            // forms a new data list containing only the filtered rows
                            var showResultsOfFilter = function() {
                                recordsToBeExpanded = [];
                              // console.log('length of filtered results',filteredResults);
                                if(filteredResults.length == 0) {
                                    angular.element(document.querySelector('#alertMain')).attr('class','alert alert-info');
                                    angular.element(document.querySelector('#alertMsg')).html('<b>Info!!&nbsp;</b>No results found for the given search.');
                                    $scope.dataList = [];
                                    
                                }
                                
                                else {
                                    //getChildIdsOfFilteredRecords(filteredResults);
                                    $scope.closeAlert(); 
                                    // recordIdsToBeShown = filteredResults.slice();
                                    var allRecordsToBeShown = filteredResults.slice()
                                    inverseChildMap = _.invert(childInfoRecordMap)
                                    inverseChildMapKeys = Object.keys(inverseChildMap);
                                    getParentIdsOfFilteredRecords(filteredResults);
                                    allRecordsToBeShown.push.apply(allRecordsToBeShown, recordIdsToBeShown);
                                    //console.log('allRecordsToBeShown',allRecordsToBeShown,recordIdsToBeShown);
                                    $scope.dataList = getSelectedRecordsForEditMode(dataBeforeFilter,allRecordsToBeShown);
                                   	console.log('filtered data',$scope.dataList);
                                    $timeout(function(){
                                        //console.log('expanded rows 3',expandedRowIds );
                                        expandRows(recordIdsToBeShown);
                                    });
                                    
                                    
                                }
                                angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-show');
                                applyErrorsAndBackground();
                                $timeout(function() {
                                    // adjustHeightOfRows();
                                    angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                });
                                
                                setHeightOfGrid();
                                $scope.gridApi.core.handleWindowResize();
                                
                                
                            };
                            
                            //used to adjust the height of grid after some events like resize zooming etc.
                            reCalculateHeightOfGrid = function() {
                                //console.log('calling recalculate');
                                setHeightOfGrid();
                                $scope.gridApi.core.handleWindowResize();    
                            }
                            
                            //called to filter the records when header filter is changed
                            var filterRecords = function() {
                                filteredResults = [];
                                
                                if(recordsToBeSearched.length > 0) { 
                                    // console.log('filteredOtherLevelResults inside if');
                                    
                                    for(var i = 0;i < recordsToBeSearched.length; i++) {
                                        
                                        filterSuccess = false;   
                                        
                                        
                                        var isFiltered = searchDeeperLevelsOfRecord(recordsToBeSearched[i]);  
                                       // console.log('isFiltered' ,isFiltered  );
                                        if(isFiltered ) { 
                                            filteredResults.push(recordsToBeSearched[i].Id);
                                            
                                        }
                                        
                                    }
                                    
                                }
                              // console.log('filtered results ' , filteredResults);
                                showResultsOfFilter();
                                
                            };
                            
                            //this method is not in use currently - relates to search functionality
                            var getChildIdsOfFilteredRecords = function(records) {
                                currentIterationRecords = [];
                                
                                records.map(function(record) {
                                    if(childInfoRecordMap.hasOwnProperty(record)) {
                                        if(recordIdsToBeShown.indexOf(record) == -1) {
                                            recordIdsToBeShown.push(record);
                                        }
                                        childInfoRecordMap[record].split(',').map(function(rec) {
                                            recordIdsToBeShown.push(rec);
                                            currentIterationRecords.push(rec);
                                            
                                        });
                                    }
                                });
                                
                                if(currentIterationRecords.length > 0) {
                                    getChildIdsOfFilteredRecords(currentIterationRecords);
                                }
                                
                            };
                            
                            //this method gets the parentIds of the filtered child records (as parents should be shown along with children when filter is applied)
                            var getParentIdsOfFilteredRecords = function(records) {
                                currentIterationRecords = [];
                               // console.log('filter getting parent');
                                records.map(function(record) {
                                    inverseChildMapKeys.map(function(key) {
                                        if(key.indexOf(record) != -1) {
                                            if(recordIdsToBeShown.indexOf(inverseChildMap[key]) == -1) {
                                                recordIdsToBeShown.push(inverseChildMap[key]);
                                                currentIterationRecords.push(inverseChildMap[key]);
                                            }
                                        }
                                    });        
                                });
                                if(currentIterationRecords.length > 0) {
                                    getParentIdsOfFilteredRecords(currentIterationRecords);
                                }
                            };
                            
                            //used to expand the rows with the given rowIds
                            //this method is used to retain the hierarchy after the data in grid is refreshed by maintaining the tree structure
                            var expandRows = function(recIds) {
                                //console.log('in expanded rows',recIds);
                                var rows = $scope.gridApi.grid.rows;
                                rows.map(function(row) {
                                    if(recIds.indexOf(row.entity.parentRec.Id) != -1) {
                                        $scope.gridApi.treeBase.expandRow(row);
                                    }
                                });
                                
                            };
                            
                            //this method is useful to enable or disabled some buttons like Cancel, Clear All Changes etc.
                            //enables - if any change to the data is found
                            //disables - if no change to the data is found
                            isDataChanged = function() {
                                // console.log('calling compare data')
                                $timeout(function() {
                                    
                                    $scope.dataChanged = compareData($scope.dataList, duplicateDataList);
                                   // console.log('data changed' , $scope.dataChanged);
                                    
                                },100);
                                
                            };
                            setDataChanged = function() {
                                $scope.dataChanged = true;    
                            }
                            
                            $scope.isValidValue = function(value) {
                                if(!(typeof value ==='undefined' || value == null || value.length == 0))  {
                                    if(!isNaN(parseFloat(value)) && isFinite(value)) {
                                        return true;
                                    }
                                    else {
                                        return false;
                                    }
                                }
                                
                                else {
                                    return true;
                                }
                                
                            }
                            
                            //this method is used to store the grid configuration in the local storage
                            storeGridConfig = function() {
                                console.log('sve by default', saveByDefault);
                                var columnDefs = [];
                                var gridColumns = $scope.gridApi.grid.columns;
                                for(var i = 0;i < gridColumns.length;i++) {
                                    var col = gridColumns[i];
                                    
                                    if(col.field != 'treeBaseRowHeaderCol' && col.field != 'selectionRowHeaderCol') {
                                        
                                        var json = {};
                                        json.cellClass = col.cellClass;
                                        json.cellFilter = col.cellFilter;
                                        json.cellTemplate = col.cellTemplate;
                                        json.displayName = col.displayName;
                                        json.drawnWidth = col.drawnWidth;
                                        json.enableFiltering = col.enableFiltering;
                                        json.enableSorting = col.enableSorting;
                                        json.name = col.field;
                                        json.filter = col.filter;
                                        json.filterCellFiltered = col.filterCellFiltered;
                                        json.filterHeadTemplate = col.filterHeadTemplate;
                                        json.headerCellClass = col.headerCellClass;
                                        json.headerCellFilter = col.headerCellFilter;
                                        json.headerCellTemplate = col.headerCellTemplate;
                                        json.headerClass = col.headerClass;
                                        json.sort = col.sort;
                                        json.type = col.colDef.type;
                                        json.sortingAlgorithm = col.sortingAlgorithm;
                                        json.enablePinning = col.colDef.enablePinning;
                                        json.pinnedLeft = col.colDef.pinnedLeft;
                                        json.pinnedRight = col.colDef.pinnedRight;
                                        json.sortCellFiltered = col.sortCellFiltered;
                                        json.suppressRemoveSort = col.suppressRemoveSort;
                                        json.visible = col.visible;
                                        json.footerCellTemplate = col.footerCellTemplate;
                                        json.width = col.width;
                                        json.minWidth = col.minWidth;
                                        json.enableColumnResizing = col.enableColumnResizing;
                                        
                                        json.enableColumnMenu = col.colDef.enableColumnMenu;
                                        json.enableCellEdit = col.colDef.enableCellEdit;
                                        json.enableHiding = col.colDef.enableHiding;
                                        
                                        json.editableCellTemplate = col.editableCellTemplate;
                                        
                                        columnDefs.push(json);
                                        //console.log('col',json);              
                                    }
                                }
                                //console.log('columnDefs',JSON.stringify(columnDefs));
                                if(typeof(Storage) !== 'undefined') {
                                    localStorage.setItem(currentUserId, JSON.stringify(columnDefs));
                                    localStorage.setItem(currentUserId + 'BtnStatus',getBtnStatus());
                                    console.log('local storage',localStorage.getItem(currentUserId + 'BtnStatus'));
                                    //localStorage.removeItem(currentUserId); 
                                }
                            }
                            
                            //called when Save is clicked on the User Config part
                            onSaveConfigClicked = function() {
                                angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                storeGridConfig();
                                $timeout(function() {
                                    angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                },300);
                            };
                            
                            //called after user clicks on Site link and does Save or Cancel Operations
                            //As the display is CMF Name insted of Site name and if the user does any modifications to CMF Name on the Site, the picklist will not reflect the changed
                            //site name, as they are loading during the initial page load
                            //So, inorder to reflect the changes if any, this method is used
                            refreshPicklistValuesForSite = function(siteId) {
                                console.log('comparing prefix',spsPrefix,siteId.substring(0,3));
                                if(spsPrefix == siteId.substring(0,3)) {
                                    angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
                                     getModifiedSiteCMFNames($scope.paramId)
                                     .then(function(result) { 
                                         angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
                                       $scope.picklistValueMap['subproject-site'] = result;
                                         console.log('modified values of cmf site',$scope.picklistValueMap['subproject-site']);
                                         fetchAllRecords();
                                     });
                                }
                                else {
                                    fetchAllRecords();
                                }
                              
                            }
             
                        }]);


//shifting inline edit mode with custom directives to view mode            
treegridApp.directive('uiSelectWrap',['$document', 'uiGridEditConstants',function($document, uiGridEditConstants){
    
    return function link($scope, $elm, $attr) {
    $document.on('click', docClick);
    
    function docClick(evt) {
      
      if (jQuery(evt.target).closest('.select-container').size() === 0) {
          
        $scope.$emit(uiGridEditConstants.events.END_CELL_EDIT);
        $document.off('click', docClick);
      }
    }
  };
    

}]);
 //formats the number to have 2 decimal places
treegridApp.directive('formatNumber',function(){
    return {
        restrict:'A',
        require:'ngModel',
         link: function (scope, element, attrs, ngModel) {
      
             //format text going to user (model to view)
              ngModel.$formatters.push(function(value) {
                  //  console.log('formatter number',value,attrs.field);
                 if(!angular.isUndefined(value) && value != null && value == 0) {
                    
                    if(attrs.field.toLowerCase().indexOf('sequence__c') == -1) {
                       // console.log('planned days1',value,parseFloat(value).toFixed(2));
                        if(isFinite(value)) {
                            var val =  parseFloat(value).toFixed(2);
                            
                            if(!isNaN(val)) {
                                return val;    
                            }
                        }
                        return value;
                        // return parseFloat(value).toFixed(2);
                        
                    }
                     else {
                         //   console.log('floor value is',value,  Math.floor(value));
                         if(value != null && value != '' && !isNaN(Math.floor(value))) {
                             return Math.floor(value);
                         }
                         return value;  
                     }
                 }
                 if(!angular.isUndefined(value) && value != null && value != '') {
                      
                     if(attrs.field.toLowerCase().indexOf('sequence__c') == -1) {
                        
                        // console.log('planned days2',value,parseFloat(value).toFixed(2), Number(val));
                         if(isFinite(value)) {
                              value = fixedDown(value,2);
                         var val = parseFloat(value).toFixed(2);
                            
                             
                             if(!isNaN(val)) {
                                 return val;    
                             }
                         }
                         return value;
                         // return parseFloat(value).toFixed(2);
                        
                         
                     }
                     else {
                         // console.log('number6');
                        // console.log('floor value is',value,  Math.floor(value));
                           if(value != null && value != '' && !isNaN(Math.floor(value))) {
                             return Math.floor(value);
                         }
                         if(value == null) {
                         	return null;    
                         }
                         return value;  
                     }
                 }
             });
   
      
    }
    }
    
});

