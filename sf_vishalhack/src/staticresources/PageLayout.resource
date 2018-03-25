// ragashalini.koka@cdk.com - Created this javascript static resource
var fields = [];
var uniqueFields = [];
var jQuery = jQuery.noConflict();
var app = angular.module('PageLayoutApp', ['inputFields','ui.grid','ui.grid.pinning','ui.grid.resizeColumns','ui.grid.autoResize','ui.grid.moveColumns','ui.grid.exporter']);
var columnPriority = [];
app.service('getDataService',['$q',function($q) {
    return function(selectedObject) {
        var deferred = $q.defer();
        if(selectedObject != null && selectedObject.length > 0) {
            
            Layouts.getData(selectedObject, function(result, event) {
                
                if(event.status) {
                    deferred.resolve(result);
                }
                else {
                    deferred.reject('failure');
                }
             
                
            });
        }
        else {
             angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
            deferred.reject('failure');
        }
        return deferred.promise;
        
    }
    
}]);

/*
   console.log(result);
                       
                      
                      
  */
app.controller('PageLayoutController', ['$scope','uiGridConstants', '$timeout', 'getDataService', function($scope, uiGridConstants,$timeout,getDataService){
   
    if(objects.length > 0) {    
        
        $scope.objectList = objects.sort().map(function(key) {
            return key.charAt(0).toUpperCase() + key.substr(1);
        });
        $scope.selectedObject = $scope.objectList[0];
        
        allFields = [];
        
    }
    
    $scope.pickListMap = {};
    $scope.pickListMap['object-field'] = {label:'',value:''}
    $scope.showPicklist = false;
    sforce.connection.sessionId = __sfdcSessionId;
	var prevObj = '';
    var prevLayout = '';
    var showData = false;
    $scope.layoutToFieldsMap = {};
    $scope.columns = [{field:'zzz',visible:false,enableHiding:false}];
    var layoutResult;
    fieldData = [];
    $scope.pageLayouts = ['Detail', 'Edit'];
    $scope.selectedPage = $scope.pageLayouts[0];
    $scope.gridData =  [];
    $scope.gridOptions = {
        rowHeight : 30,
        columnDefs : $scope.columns,
        enableGridMenu : true,
        excessColumns : 5,
        excessRows : 10,
        enableHorizontalScrollbar : 0,
        enableFiltering: true,
        data : $scope.gridData,
        exporterSuppressColumns: ['zzz']
    };
    $scope.gridOptions.onRegisterApi = function(gridApi){
        //set gridApi on scope
        $scope.gridApi = gridApi;
    }
    
    
    $scope.fetchData = function() {
      
        if(prevObj != $scope.selectedObject) {
            console.log('service call');
            angular.element(document.querySelector('.waitingSearchDiv')).removeClass('ng-hide');
            $scope.showPicklist = false;
            $scope.layoutToFieldsMap = {};
            $scope.selectedFields = '';
            allFields = {};
            
            var columnLength = $scope.columns.length;
            for(var i = 1;i<columnLength;i++) {
                $scope.columns.splice(1,1);
            }
            columnLength =  $scope.gridData.length;
            for(var i = 0;i < columnLength;i++ ) {
                $scope.gridData.splice(0,1);
            }
           
            getDataService($scope.selectedObject)
            .then(function(result) {
                
               
                // result.recordTypeSet
                try {
                    
                    prevObj = $scope.selectedObject;
                    //$scope.layouts = Object.values(result.layoutIdToNameMap);
                    layoutIdToNameMap = result.layoutIdToNameMap;
                    showData = true;
                    result.fieldSet.sort();
                    allFields = result.fieldSet.map(function(res) {
                        res = res.charAt(0).toUpperCase() + res.substr(1);
                        return {label : res,value : res};
                    });
                 
                    
                    console.log('record type length ', result.recordTypeSet.length);
                    layoutResult = sforce.connection.describeLayout($scope.selectedObject, result.recordTypeSet); 
                    console.log(layoutResult);
                       $scope.pickListMap['object-field'] = allFields;
                    $scope.showPicklist = true;
                    
                    classifyResult();
                
                }
                catch(err) {
                    console.log('exception raised : ', err);
                }
                
                   angular.element(document.querySelector('.waitingSearchDiv')).addClass('ng-hide');
             
                //  console.log($scope.columns, $scope.gridData);
            });
        }
    };
    
    console.log(fieldData);
    
    function classifyResult() {
        console.log($scope.selectedObject,prevObj,prevLayout,$scope.selectedPage);
        if(($scope.selectedObject == prevObj && prevLayout != $scope.selectedPage) || showData) {
            console.log('in classify result');
            showData = false;
            prevLayout = $scope.selectedPage;
            var layouts = layoutResult.getArray("layouts");
            if(layoutResult.recordTypeMappings.length) {
                //Controller doesnot give Master pagelayout while querying. So, adding it here
                for(var i = 0;i < layoutResult.recordTypeMappings.length; i++) {
                    if(layoutResult.recordTypeMappings[i].name == 'Master') {
                        layoutIdToNameMap[layoutResult.recordTypeMappings[i].layoutId] = 'Master';
                        break;
                        
                    }
                }
                
            }
            
            for (var i = 0; i < layouts.length; i++) {
                resetFields();
                var layout = layouts[i];
                var prop = 'detailLayoutSections';
                
                if($scope.selectedPage == 'Edit') {
                    prop = 'editLayoutSections';
                }
                console.log('prop',prop);
                layoutSections(layout[prop]);
                
                if(layoutResult.recordTypeMappings.length) {
                    $scope.layoutToFieldsMap[layoutIdToNameMap[layout['id']]] = getFields();
                }
                else {
                    $scope.layoutToFieldsMap[layoutIdToNameMap[layout['id']]] = getFields();
                }
                
              prevLayout = $scope.selectedPage;
                //console.log( $scope.layoutToFieldsMap[layoutIdToNameMap[layoutResult.recordTypeMappings[i].layoutId]]);
                // console.log( layoutIdToNameMap[layoutResult.recordTypeMappings[i].layoutId] , layoutResult.recordTypeMappings[i].layoutId);
            }
            console.log($scope.layoutToFieldsMap);
            var layoutIdToNameMapValues = Object.keys(layoutIdToNameMap).map(function(key) {
                return layoutIdToNameMap[key];
            })
            var columnData = formColumnData(layoutIdToNameMapValues, Object.keys($scope.layoutToFieldsMap));
            for(var i = 0;i < columnData.length;i++) {
                $scope.columns.push(columnData[i]);
            }
        }
        
    }
    
    $scope.displayGrid = function() {
    
      classifyResult();
        var dataLength = $scope.gridData.length;
        for(var i = 0;i < dataLength;i++ ) {
            $scope.gridData.splice(0,1);
        }
        var fields = $scope.selected;
        //console.log(fields);
        if(fields.length > 0) {
            
            fieldData = fields.split(';');
            
            var recordData = formDataArray($scope.layoutToFieldsMap,fieldData);
            for(var i = 0;i<recordData.length;i++) {
                $scope.gridData.push(recordData[i]);
            }
            
        }
        else {
            for(var i = 0;i < dataLength;i++ ) {
                $scope.gridData.splice(0,1);
            }
            
        }
       
            setHeightOfGrid();
      // reorderColumns();
    
        //console.log( $scope.gridData);
    };
  	
    $scope.hidePicklist = function() {
        $scope.showPicklist = false;
        $scope.selected = '';
          var dataLength = $scope.gridData.length;
         for(var i = 0;i < dataLength;i++ ) {
            $scope.gridData.splice(0,1);
        }
    }
    
    function reorderColumns() {
        var colMap = {};
        $scope.columns.map(function(col) {
            var name = col.name;
            
            if(name != 'Name' || name != 'zzz') {
                colMap[col.name] = col;
                if(columnPriority.indexOf(name) == -1) {
                    columnPriority.push(name);
                }
            }
            
        });
      
        var columnWithNoData = [];
        var colLength = $scope.columns.length;
        
        for(var i = 1;i <colLength;i++ ) {
            $scope.columns.splice(1,1);
        }
         //console.log('priority' ,    columnPriority);
        columnPriority.map(function(col) {
            
           $scope.columns.push(colMap[col]); 
           
        });
        console.log('columns after reorder', $scope.columns)
        //console.log('reorder' ,    $scope.columns);
    }
    
    
}]);

function setHeightOfGrid() {
    console.log('inresize');
    window.setTimeout(function() {
         var gridHeight = jQuery(window).height() - jQuery('.navbar').height() - 100;
           jQuery('.grid').height(gridHeight);
      
    })
    
}

function formDataArray(layoutToFieldsMap, fieldArr) {
    console.log(layoutToFieldsMap);
    var columnsArr = fieldArr;
    var gridData = [];
    var colPriorityMap = {};
    Object.keys(layoutToFieldsMap).map(function(layout) {
        colPriorityMap[layout] = 0;
    });
    
    columnsArr.map(function(col) {
        var gridObj = {};
        gridObj['Name'] = col;
        Object.keys(layoutToFieldsMap).map(function(layout) {
            gridObj[layout] = layoutToFieldsMap[layout].indexOf(col.toLowerCase()) > -1 ? true : false; 
            if(gridObj[layout]) {
               // console.log('in value');
                colPriorityMap[layout] = colPriorityMap[layout]+1;
            }
        });
        gridData.push(gridObj);
    });
   
    var colPriorityArr = [];
    columnPriority = [];
    for(var key in colPriorityMap) {
        colPriorityArr.push({'key' : key, 'value' : colPriorityMap[key]});
    }
   // console.log('before sort :' , colPriorityArr);
    colPriorityArr.sort(function(val1, val2) {
       return val2.value - val1.value; 
    });
  //   console.log('after sort :' , colPriorityArr);
    columnPriority = colPriorityArr.map(function(prop) {
        return prop.key;
    })
   
  //  console.log('column priority :', columnPriority);
   
    return  gridData;
    
    
}


function formColumnData(properties, usedLayouts) {
    var columns = [];
    var unusedCols = [];
    columns.push({name : 'Name',
                  label : 'Name',
                  enableHiding : false,
                  enableSorting : true,
                  pinnedLeft : true,
                  enableCellEdit : false,
                  enableFiltering : true,
                  minWidth : 240,
                 });
    
    properties.map(function(property) {
        var col = {};
        col.name = property;
        col.label = property;
        col.enableHiding = true;
        col.enableSorting = true;
        col.enableCellEdit = false;
        col.enablePinning = false;
        col.minWidth = 200;
        if(usedLayouts.indexOf(property) > -1) {
            col.cellTemplate = '<span class="customContent success" ng-if="COL_FIELD"><i class="glyphicon glyphicon-ok "/></span>'
            +'<span class="customContent failure" ng-if="!COL_FIELD"><i class="glyphicon glyphicon-remove "/></span>';
            columns.push(col);
        }
        else {
            col.cellTemplate = '<span class="customContent">NA</span>';
            unusedCols.push(col);
        }
        
        
    });
    // to ensure they appear at the end
    unusedCols.map(function(col) {
       columns.push(col); 
    });
    
    return columns;
    
}

function layoutSections(sections) {
    
    if(sections.length) {
        for (var i=0; i<sections.length; i++) {
            var section = sections[i];
            layoutRows(section.getArray("layoutRows"));
        }
    }
    else {
        layoutRows(sections.getArray("layoutRows"));
    }
}

function layoutRows(rows) {
    
    for (var i=0; i<rows.length; i++) {
        var row = rows[i];
        layoutItems(row.getArray("layoutItems"));
    }
}

function layoutItems(items) {
    
    for (var i=0; i<items.length; i++) {
        var item = items[i];
        
        if(item.hasOwnProperty('layoutComponents') && item.layoutComponents.hasOwnProperty('value')) {
            var labelValue = item.layoutComponents.value;
            if(labelValue !== 'undefined' && labelValue.length > 0) {
                if(fields.indexOf(labelValue) == -1) {
                    fields.push(labelValue.toLowerCase());
                }
                
            }
        }
    }
    
}

function resetFields() {
    fields = [];
}

function getFields() {
    return fields;
}
