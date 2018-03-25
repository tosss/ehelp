/********************************************************************************************************
 * 2016-08-08 ragashalini.koka@cdk.com - fixed small bug on filter in searchDeeperLevelsOfRecord method
 * 2016-09-19 ragashalini.koka@cdk.com - changed the formatDate function for the RQ-07818
*********************************************************************************************************/
var jQuery = jQuery.noConflict();

jQuery(document).ready(function(){
    // console.log('ready')
    jQuery('[data-toggle="tooltip"]').tooltip();
   
  setHeightOfGrid();
     
});


var navigationList = [];
var metadata;
var fields = [];
var labels = [];
var dataType = [];
var totalColumns = [];
var searchValue = '';
var htmlElementId = 1;
var newRecordAdded = false;
var anyRMSRecord = false;
var cellTemplateCnt = 0;
var inlineTemplateCnt = 0;
var errToParents = {};
var levelOfObjectsMap = {};
var preventRecursion = false;
var lookupElement = null;

function setNavigationList(keys,parentKey) {
    keys.map(function(key) {
        navigationList.push({child:key,parent:parentKey});
    });
    
    
    
}

function setHeightOfGrid() {
   // console.log('set height',jQuery('#alertMain').height());
     var screenHeight = jQuery(window).height();
    var btnHolderHeight = jQuery('#buttonContainer').height();
    //to ensure the it doesn't go out of the screen
    var additionalHeight = 10
	var alertHeight = 0;
    if(!jQuery('#alertMain').hasClass('ng-hide')) {
        alertHeight = 50;
    }
    //console.log('alertHeight',alertHeight);
    var calculatedHeight = screenHeight - btnHolderHeight - additionalHeight - alertHeight;  
    jQuery('.grid').height(calculatedHeight);
}

function getNavigationList() {
    return navigationList;
}

function setLevelObjectsMap(levelOfObjects) {
    levelOfObjectsMap = levelOfObjects;
}

function buildHierarchy(dataArr,allRecords,childInfoMap) {
  // console.log(childInfoMap);
 	//setNavigationList(Object.keys(data),'root');
    expandStructure(dataArr,allRecords,childInfoMap)
   // console.log('data formed arr' ,dataArr);
  
    
}

function expandStructure(dataArr,allRecords,childInfoMap) {
    
    dataArr.map(function(data){
        var recId = data['parentRec']['Id'];
        data['children'] = [];
        if(data.isChildPresent) {
        	 var childRecords = getChildren(childInfoMap[recId].split(','),allRecords,recId);
            Object.keys(childRecords).map(function(key){
                data['children'].push(childRecords[key]);
                
            });
            expandStructure( data['children'],allRecords,childInfoMap);
        }
        
    });
    
    
 
   
}

function getChildren(keys,allRecords,parentKey) {
    var childObj = {}
        keys.map(function(key) {
        	childObj[key] = allRecords[key];
            navigationList.push({child:key,parent:parentKey});
            
    });
    return childObj;
}

function formatDate(date) {
   // console.log('date sent is ' + date);// 2016-05-10
   
   // sets the year to the current year if year is not entered 
    if(typeof date !== 'undefined' && String(date).indexOf('/') != -1) {
       var arrayLength = String(date).split('/').length;
        if(arrayLength >= 2  ) {
              var tempDate = new Date();
            if(String(date).charAt(String(date).length - 1) == '/' ) {
            	 date += tempDate.getFullYear();
               
            }
            else  {
                //2016-06-19 ragashalini.koka@cdk.com - added the condition to ensure that year is only added when there is no year mentioned
                if(arrayLength == 2) {
                    date += '/' + tempDate.getFullYear();
                }
                
            }
           
        }
    }
   
    var d = new Date(date);
   
    
    if(d.getTimezoneOffset() > 0) {
    d = new Date(d.getTime() + d.getTimezoneOffset() * 60000);
    }
       month = '' + (d.getMonth() + 1),
       day = '' + d.getDate(),
       year = d.getFullYear();
  
                  
    
    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;
    
    return [year, month, day].join('-');
    
}

function getRecordsToBeSearchedAll(recordMap) {
    var properties = Object.keys(recordMap);
    var recordsToBeSearched = [];
    for(var i = 0;i < properties.length;i++) {
       recordsToBeSearched.push(recordMap[ properties[i]].parentRec);
       
    }
    //console.log('record map' ,recordsToBeSearched);
    return recordsToBeSearched;

}

function validateContactObject(contactObject, requiredKeys) {
    
    for(var i = 0;i < requiredKeys.length;i++) {
        if(contactObject[requiredKeys[i]].length == 0) {
            return 'Please fill the mandatory fields';
        }
    }
    return '';
}

function getRecordsToBeSearched(startKey, recordMap) {
    var properties = Object.keys(recordMap);
    var recordsToBeSearched = [];
   
    if(startKey == 'All') {
    	recordsToBeSearched = getRecordsToBeSearchedAll(recordMap)
    }
    else {
        for(var i = 0;i < properties.length;i++) {
            //checking if the prefix matches with key
            var key = properties[i];
            if(key.substring(0,3) == startKey) {
                recordsToBeSearched.push(recordMap[key].parentRec);
            }
        }
    }
   // console.log('record map' ,recordsToBeSearched);
    return recordsToBeSearched;

}

function recordsWithPSRValue(records, objectKeyMap, PSRValue) {
    var updatedRecords = [];
     records.filter(function(record){
        if(objectKeyMap.hasOwnProperty(record.substring(0,3))) {
           
            updatedRecords.push({attributes : {type: objectKeyMap[record.substring(0,3)]}, id : record , Display_on_PSR__c : PSRValue});
            
        }
        
    });
    console.log('modified PSR',updatedRecords );
    return updatedRecords;
}

function getIdOfChildRecordsToUpdate(childInfoMap,totalObjects,selectedRecords) {
    var recordIdList = selectedRecords;
    
    for(var i = 0;i < totalObjects-1;i++) {
         console.log('selected records' , selectedRecords);
        var newSet = [];
        selectedRecords.forEach(function(record) {
            if(typeof childInfoMap[record] != 'undefined') {
                newSet = newSet.concat(childInfoMap[record].split(',')); 
            }
        });
        
        recordIdList = recordIdList.concat(newSet);
        selectedRecords = newSet;
        
        
    }
    return recordIdList;
    
}

function findDatatype(fieldName) {
    var keys = Object.keys(metadata);
    for(var i = 0;i < keys.length;i++) {
        if(metadata[keys[i]].fieldsMap.hasOwnProperty(fieldName)) {
            return metadata[keys[i]].fieldsMap[fieldName].fieldType_c;
        }
    }
    
}

function constructFieldsLabelsAndDataTypeArrays(customizedFieldsMap, objectMetadata) {
     fields = ['Id'];
     labels = ['Id'];  
     dataType = ['Id'];
     metadata = objectMetadata;
    var keys = Object.keys(customizedFieldsMap['fields']).sort();
    var fieldMap = customizedFieldsMap['fields']; 
    var labelMap = customizedFieldsMap['labels'];    
    keys.map(function(key) {
        fields.push(fieldMap[key]);
        labels.push(labelMap[key]);
        dataType.push(findDatatype(fieldMap[key]));
      
    });
      totalColumns = fields.length;
        //  console.log('labels', fields ,labels,dataType);
    }

function calculateWidth(field,idx) {
    var mycanvas = document.createElement("canvas");
    var ctx = mycanvas .getContext("2d");
    var measuredWidth = ctx.measureText(field).width;
    if(idx == 1) {
        measuredWidth = 110;
    }
    else if(idx == 2) {
         measuredWidth = 60;
    }
    else if(measuredWidth < 45) {
        measuredWidth = 50
    }
        else if(measuredWidth > 65 ) {
            measuredWidth = 65;
        }
            else {
                measuredWidth = 60  ; 
            }
    return measuredWidth;
}

function getFields() {
    return fields;
}

function getLabels() {
    return labels;
}

function getDatatype() {
	return dataType;
}

function getColumnCount() {
    return totalColumns;
}

function getEditableMilestoneRMSFields() {
    return  ['Process_Step__c','Comments__c','Display_on_PSR__c','Sequence__c'];
}

function getEditableActivityRMSFields() {
    return ['Comments__c','Display_on_PSR__c','CDK_Assignee_Role__c','Client_Assignee__c','Sequence__c','Department__c'];
}

function getEditableTaskRMSFields() {
    return ['Display_on_PSR__c','Sequence__c','Comments__c','CDK_Assignee_Role__c','Client_Assignee__c']
}

function getSelectedLevelOneRecords(rows) {
    var selectedLevelOneRecordIds  =  rows.map(function(row) {
        
        return row.parentRec.Id;
        
    });
    return selectedLevelOneRecordIds;
}

//format the fields in the way salesforce accepts                        
function checkAndModifyProperties(recordList) {
  // console.log('recordsList',recordList);
    recordList.map(function(record) {
        Object.keys(record).map(function(key) {
            var idx = fields.indexOf(key);
            if(idx != -1 || key == 'Actual_End_Date_Final__c') {
                var type ;
                if(idx != -1) {
                 type = dataType[idx];
                }
              
                else if(key == 'Actual_End_Date_Final__c') {
                    type = 'DATE';
                }
                
                if(type.toLowerCase() == 'date') {
                    record[key] = formatDate(record[key]);
                    if(record[key].indexOf('NaN') != -1) {
                        record[key] = null;
                    }
                }
                else if(type.toLowerCase() == 'datetime') {
                    var d = new Date(record[key]);
                    record[key] = d.getTime();
                }
                    else if(type.toLowerCase() != 'boolean' && (angular.isUndefined(record[key]) || record[key] == null || record[key] == '')) {
                  
                        record[key] = null;
                    }
                	 
            }
            if(key == 'Sequence__c') {
               // console.log('seq floor',record[key]);
                if(record[key] != null && !isNaN(Math.floor(record[key]))) {
                    record[key] = Math.floor(record[key]);
                }
            }
        });
        
    });
    return recordList;
}

//workaround to fix date fields to display correctly
function revertModifiedProperties(recordList) {
    recordList.map(function(record) {
        Object.keys(record).map(function(key) {
            var idx = fields.indexOf(key);
            if(idx != -1) {
                var type = dataType[idx];
                
                if(type.toLowerCase() == 'date' || type.toLowerCase() == 'datetime') {
                   // console.log('record[key]',record[key]);
                    if(record[key] == null) {
                        record[key] = '';    
                    }
                }
                
                
            }
        });
        
    });
    return recordList;
}

function searchDeeperLevelsOfRecord(referenceObj) {
  var filterSuccess = false;
    var properties = Object.keys(referenceObj);
   
   // console.log('search value', searchValue);
    for(var j = 0; j < properties.length; j++) {
        
        if(properties[j] != 'attributes' && properties[j] != 'children' && properties[j] != 'isExpanded' &&  properties[j] != 'Id'
           && properties[j] != 'RMS_Owned_Flag__c' && properties[j] != 'done' && properties[j] != 'totalSize'){
            var val = referenceObj[properties[j]];
            if(properties[j] == 'Site__c') {
                val = fetchCMFForSite(val)
            }            
            var idx = fields.indexOf(properties[j]);
            var type = '';
            
            if(idx > -1) {
                type = dataType[idx]; 
            }
          
            if(angular.isObject(val)) {
              //console.log('object');
                
                if(searchDeeperLevelsOfRecord(val)) {
                    return true;
                }
            }
            else {
             /*   if(type.toUpperCase() == 'DATE' || type.toUpperCase() == 'DATETIME') {
                    var enteredDate = new Date(searchValue);
                    var actualDate = new Date(val);
                    if(type.toUpperCase() == 'DATE') {
                        actualDate.setHours(0,0,0,0);
                    }
                 
                    if(enteredDate.getTime() == actualDate.getTime()) {
                        filterSuccess = true;
                        break;
                    }
                }*/
                if(type.toUpperCase() == 'DATE' || properties[j] == 'Actual_End_Date_Final__c') {
                    val = val.replace(/-/g,'/');
                   var splitDate = val.split('/');
                    if(splitDate.length > 2) {
                         val = splitDate[1] + '/' + splitDate[2] + '/' + splitDate[0];
                    }
                   
                    //console.log('replace', val,searchValue, String(val).toLowerCase().indexOf(searchValue.toLowerCase()));
                }
                else if(type.toUpperCase() == 'BOOLEAN') {
                    if(val) {
                        val = 'Yes';
                    }
                    else {
                        val = 'No';
                    }
                }
                if(String(val) != null && String(val) != "" && (String(val).toLowerCase().indexOf(searchValue.toLowerCase()))!= -1) {
                    
                 //  console.log('matched value', val);
                    filterSuccess = true;
                    return filterSuccess;
                    break;
                   
                }
                
                
            }
            
        }
    }
  
          return filterSuccess;   
};

function fixHeightsOfNonFilteredRows(recordIdsToBeShown) {
    if(recordIdsToBeShown.length > 0) {
        console.log('total element with class' , jQuery('.grid').find("[class*='rec']").length);
        jQuery('.grid').find("[class*='rec']").each(function() {
            var id = jQuery(this).attr('recId');
            if(recordIdsToBeShown.indexOf(id) == -1) {
                jQuery(this).parent().parent().css('height',"0px"); 
            }
        });
    }
}

function setElementsToOriginalHeight(height) {
    jQuery('.grid').find("[class*='rec']").each(function() {
        var id = jQuery(this).attr('recId');
        
        jQuery(this).parent().parent().css('height',height);
       
        
    });
}

function setSearchValue(searchTxt) {
    searchValue = searchTxt;
}

function areAllRMSRows(rows) {
    var isRMS = true;
    anyRMSRecord = false;
    var cntRMS = 0;
    var cntNonRMS = 0;
    rows.map(function(row){
        if(row.parentRec.RMS_Owned_Flag__c) {
           cntRMS++;
        }
        else {
             isRMS = false;
             cntNonRMS++;
        }
        
    });
    if(cntRMS > 0 && cntNonRMS > 0) {
        anyRMSRecord = true
    }
   
    return isRMS;
}

function getAnyRMSRecord() {
    return anyRMSRecord;
}

function getHideColumnMenuCols() {
	var hideColumnMenuCols = ['Action', 'Msg', 'RMS','parentRec.Id'];
    return hideColumnMenuCols;
}

function getEnableHidingCols() {
	var enableHidingCols = ['Action', 'Msg', 'parentRec.Id'];
    return enableHidingCols;
}

 //inline edit template                     
function buildCellTemplate(type,field) {
         var start = '<div class="ui-grid-cell-contents" cellId="inline{{row.entity.parentRec.Id}}' 
    + inlineTemplateCnt++ + '"><ui-select-wrap><div class="select-container">';
         var end = '</div></ui-select-wrap></div>';
           
         var middle ='';
           if(field == 'Risk_Gauge_Color__c') {
               middle +=  '<span ng-bind-html="COL_FIELD">';
           }  
   		 else if(field == 'Site__c') {
             middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,\'Site__c\')">' 
                +'<span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">'
                +'<a ng-if="row.entity.parentRec.Site__c" href="/{{row.entity.parentRec.Site__c}}/e?retURL=%2Fapex%2FcloseMe" target="_blank">{{grid.appScope.getCMFNameForSite(COL_FIELD)}}</a></span>' 
                +'<span ng-if=" grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">'
                + '<ui-select-wrap><div class="select-container"><input ctype="picklist" ng-Object="SubProject"  ng-columnNames="Site"  is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}" ng-model="MODEL_COL_FIELD" picklist-map="grid.appScope.picklistValueMap"/>'
                +'</div></ui-select-wrap></span>'
                +'</span>'
                +'<span ng-if="!grid.appScope.isOwnProperty(row.entity.parentRec.Id,\'Site__c\')">'
                +'{{grid.appScope.getCMFNameForSite(row.entity.parentRec.Site__c)}}</span>';
        
   		 }
           else {
               switch(type.toUpperCase()) {
                   case 'STRING':middle +=  '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}">{{COL_FIELD }}  </span>'
                   +'<span ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"><input type="text" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid-editor"/></span>' 
                   +'</span>';
                       break;
                   case 'NUMBER':middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if=" !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">{{COL_FIELD}}</span>'
                   +'<input type="number" ng-if=" grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid-editor"/></span>';
                       break;
                   case 'PHONE' : middle +='<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">{{COL_FIELD}}</span>' 
                   +'<input type="phone" ng-if=" grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid-editor"/></span>';
                       break;
                   case 'EMAIL' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if=" !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}">{{COL_FIELD }}  </span>'
                   +'<input type="email" ng-if=" grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid-editor"/></span>';
                       break;
                   case 'URL' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if=" !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}">{{COL_FIELD }}  </span>'
                   +'<input type="url" ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid-editor"/></span>'; 
                       break;
                   case 'CURRENCY' :middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">{{COL_FIELD}}</span>'
                   +'<input type="currency" ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid-editor"/></span>';
                       break;
                   case 'REFERENCE' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">{{grid.appScope.getReferenceName(row.entity.parentRec,col.field) }}</span>'
                   +'<span ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"><ui-select-wrap><div class="select-container">'
                   +'<input ctype="lookup" ng-model="MODEL_COL_FIELD" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}" ng-object="{{grid.appScope.getReferenceObject(row.entity.parentRec,col.field)}}" ng-columnNames="Id,Name" ng-displayName="Name" ng-display="{{grid.appScope.getReferenceName(row.entity.parentRec,col.field)}}" app="TreeGrid"/>';
                       +'</span>'
                       break;
                   case 'PICKLIST' :middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) ||grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}">{{COL_FIELD  }}   </span>' 
                   + '<span ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"><input ctype="picklist" ng-Object="{{grid.appScope.objectKeyPrefixIdentifier[row.entity.parentRec.Id.substring(0,3)]}}"  ng-columnNames="{{col.field.split(\'.\')[1].toLowerCase()}}" ng-model="MODEL_COL_FIELD" picklist-map="grid.appScope.picklistValueMap" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  />';
                       + '</span>';                       
                       break; 
                   case 'MULTIPICKLIST' : middle +='<span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}">{{COL_FIELD }}  </span>'
                   + '<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"> <input ctype="multipicklist"  ng-Object="{{grid.appScope.objectKeyPrefixIdentifier[row.entity.parentRec.Id.substring(0,3)]}}" class="form-control" ng-columnNames="{{col.field.split(\'.\')[1].toLowerCase()}}" picklist-map="grid.appScope.picklistValueMap" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  ng-model="MODEL_COL_FIELD"/>'
                   +'</span>';
                       break;
                   case 'TEXTAREA' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}">{{COL_FIELD | limitTo:100}} {{COL_FIELD.length > 100 ?\'...\':\'\'}} </span>' 
                   +'<textarea  ng-model="MODEL_COL_FIELD" rows="1" ng-if=" grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="form-control" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid editor"/></span>';
                       break;
                   case 'DOUBLE' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">{{grid.appScope.getFormattedNumber(COL_FIELD,col.field.split(\'.\')[1])}}</span>'
                   +'<input type="text" ng-class="grid.appScope.isValidValue(MODEL_COL_FIELD) ? \'noBorder\' : \'addBorder\'" ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ui-grid-editor="ui-grid-editor" format-number field="{{col.field.split(\'.\')[1]}}" onkeyup="checkInput(this,event)" onkeydown="keydownClicked(this,event,false)"/></span>';
                      break;
                   case 'BOOLEAN' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"><span ng-if="COL_FIELD">Yes</span><span ng-if="!COL_FIELD">No</span></span>'
                   +'<input type="checkbox" ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" ui-grid-editor="ui-grid-editor" onclick="keydownClicked(this,event,false)" onkeydown="keydownClicked(this,event,false)"/></span>';
                       break;
                   case 'ADDRESS' :  middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if=" !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}">{{COL_FIELD | limitTo:100}} {{COL_FIELD.length > 100 ?\'...\':\'\'}} </span>'
                   +'<textarea rows="1" ng-model="MODEL_COL_FIELD" ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="form-control" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid editor" onkeydown="keydownClicked(this,event,false)"/></span>';
                       break;
                   case 'DATE': middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="!grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">{{grid.appScope.getFormattedDate(COL_FIELD,"day",row.entity.parentRec,col.field)}}</span>'
                   + '<span ng-if=" grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">'
                   +  '<input ctype="customDate" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  ng-model="MODEL_COL_FIELD" mo-date-input="yyyy-dd-MM" min-view="day" is-required="true" date-value="{{MODEL_COL_FIELD}}"  time-zone="{{grid.appScope.timezone}}"/>'
                   + '</span></span>';
                       break;
                   case 'DATETIME' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if=" !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">{{grid.appScope.getFormattedDate(COL_FIELD,"hour")}}</span>'
                   + '<span ng-if="grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">'
                   +  '<input ctype="customDate" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  ng-model="MODEL_COL_FIELD" is-required="true" mo-date-input="yyyy-dd-MM" min-view="hour" date-value="{{MODEL_COL_FIELD}}" time-zone="{{grid.appScope.timezone}}"/>'
                   + '</span></span>';
                       break;
                       
                   default : break;
                       
                       
               }
           } 
         return start + middle + end;
     }
       
function buildCellTemplateView(type,showAsLink,field) {
    var addClass = 'noStyle';
   
    if(field == 'Description__c') {
      addClass = "desc applyItalics" ; 
    }
    var start = '<div class="ui-grid-cell-contents ' + addClass + '{{row.entity.level}}" ondblclick="doubleClickedCell(this)" cellId="{{row.entity.parentRec.Id}}' 
    + cellTemplateCnt++ + '">';
           var end = '</div>';
           
           var middle = ''; 
           
           if(showAsLink) {
               middle = '<a href="/{{row.entity.parentRec.Id}}/e?retURL=%2Fapex%2FcloseMe"  target="_blank">';
           }
           // handling special cases
            
           if(field == 'CMF__c') {
               //navigate to site page when clicked on CMF
               middle +=  '<a ng-if="row.entity.parentRec.Site__c" href="/{{row.entity.parentRec.Site__c}}/e?retURL=%2Fapex%2FcloseMe" target="_blank"><span  title="{{COL_FIELD}}">{{COL_FIELD}}</span>' + '</a>' +
                   			'<span ng-if="!row.entity.parentRec.Site__c"  title="{{COL_FIELD}}">{{COL_FIELD}}</span>';
               
           }
    	  
    	  else if(field == 'Site__c') {
        		middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,\'Site__c\')">' 
                +'<span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">'
                +'<a ng-if="row.entity.parentRec.Site__c" href="/{{row.entity.parentRec.Site__c}}/e?retURL=%2Fapex%2FcloseMe" target="_blank">{{grid.appScope.getCMFNameForSite(COL_FIELD)}}</a></span>' 
                +'<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">'
                + '<ui-select-wrap><div class="select-container"><input type="hidden" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/><input ctype="picklist" ng-Object="SubProject"  ng-columnNames="Site"  is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}" ng-model="MODEL_COL_FIELD" picklist-map="grid.appScope.picklistValueMap"/> '
                +'</div></ui-select-wrap></span>'
                +'</span>'
                +'<span ng-if="!grid.appScope.isOwnProperty(row.entity.parentRec.Id,\'Site__c\')">'                                                                    
                +'{{grid.appScope.getCMFNameForSite(row.entity.parentRec.Site__c)}}</span>'
      		}
  	 	
           else if(field == 'Status__c') {
               middle +=  '<span  title="{{COL_FIELD}}" style="color: {{grid.appScope.getFontColor(COL_FIELD)}}">{{COL_FIELD}}</span>';
                  
           } 
           else if(field == 'Risk_Gauge_Color__c') { 
               middle +=  '<span ng-bind-html="COL_FIELD">'; 
                  
           } 
           else {
               switch(type.toUpperCase()) {
                   case 'STRING':middle +=  '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}" class="showIcon">{{COL_FIELD }} </span>' + (showAsLink ? '</a>':'') 
                   +'<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"><input type="text" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" onkeydown="keydownClicked(this,event,false)" ui-grid-editor="ui-grid-editor" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}" /></span>' 
                   +'</span>'
                   break;
                   case 'NUMBER':middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">{{COL_FIELD}}</span>'
                   +'<input type="number" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid-editor" onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/></span>';
                       break;
                   case 'PHONE' : middle +='<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">{{COL_FIELD}}</span>' 
                   +'<input type="phone" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid-editor" onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/></span>';
                       break;
                   case 'EMAIL' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}" class="showIcon">{{COL_FIELD }}  </span>'
                   +'<input type="email" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid-editor" onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/></span>';
                       break;
                   case 'URL' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}" class="showIcon">{{COL_FIELD }}  </span>'
                   +'<input type="url" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid-editor" onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}" /></span>'; 
                       break;
                   case 'CURRENCY' :middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">{{COL_FIELD}}</span>'
                   +'<input type="currency" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid-editor" onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/></span>';
                       break;
                   case 'REFERENCE' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) ||grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field) " class="showIcon"><a href="/{{COL_FIELD}}" target="_blank">{{grid.appScope.getReferenceName(row.entity.parentRec,col.field)}}</a></span>'
                   +'<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">'
                   +'<ui-select-wrap><div class="select-container"><input type="hidden" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/><input ctype="lookup" ng-model="MODEL_COL_FIELD" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}" ng-object="{{grid.appScope.getReferenceObject(row.entity.parentRec,col.field)}}" ng-columnNames="Id,Name" ng-displayName="Name"  ng-display="{{grid.appScope.getReferenceName(row.entity.parentRec,col.field)}}" app="TreeGrid"/>'
                   +'</div></ui-select-wrap></span></span>';
                       break;
                   case 'PICKLIST' :middle += '<ui-select-wrap><div class="select-container"><span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])">' 
                   +'<span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}" class="showIcon">{{COL_FIELD }}  </span>' 
                   + '<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"><input type="hidden" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/><input ctype="picklist" ng-Object="{{grid.appScope.objectKeyPrefixIdentifier[row.entity.parentRec.Id.substring(0,3)]}}"  ng-columnNames="{{col.field.split(\'.\')[1].toLowerCase()}}" ng-model="MODEL_COL_FIELD" picklist-map="grid.appScope.picklistValueMap" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  />'
                   +'</span></div></ui-select-wrap>';
                       
                       break; 
                   case 'MULTIPICKLIST' : middle += '<ui-select-wrap><div class="select-container">'
                       +'<span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}" class="showIcon">{{COL_FIELD }}  </span>'
                       + '<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)"> <input ctype="multipicklist"  ng-Object="{{grid.appScope.objectKeyPrefixIdentifier[row.entity.parentRec.Id.substring(0,3)]}}" class="form-control" ng-columnNames="{{col.field.split(\'.\')[1].toLowerCase()}}" picklist-map="grid.appScope.picklistValueMap" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  ng-model="MODEL_COL_FIELD"/>'
                       +'</div></ui-select-wrap>';
                                                                                        
                       break;
                   case 'TEXTAREA' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}" class="showIcon">{{COL_FIELD | limitTo:100}} {{COL_FIELD.length > 100 ?\'...\':\'\'}} </span>' + (showAsLink ? '</a>':'') 
                   +'<textarea rows="1"  ng-model="MODEL_COL_FIELD" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field) && !grid.appScope.hideEditInView" class="form-control" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid editor"  onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/>'
                   + '<textarea rows="1" ng-model="MODEL_COL_FIELD" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field) && grid.appScope.hideEditInView" class="form-control" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid editor"  onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/></span>';
                       break;
                   case 'DOUBLE' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">{{grid.appScope.getFormattedNumber(COL_FIELD,col.field.split(\'.\')[1])}}</span>'
                   +'<input type="text"  ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" class="form-control input-sm" ui-grid-editor="ui-grid-editor" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}" onkeyup="checkInput(this,event)" onkeydown="keydownClicked(this,event,false)" field="{{col.field.split(\'.\')[1]}}" format-number /></span>';
                    break;
                   case 'BOOLEAN' : middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon"><span ng-if="COL_FIELD">Yes</span><span ng-if="!COL_FIELD">No</span></span>'
                   +'<input type="checkbox" ng-class="grid.appScope.isValidValue(MODEL_COL_FIELD) ? \'noBorder\' : \'addBorder\'" class="form-control" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" ng-model="MODEL_COL_FIELD" ui-grid-editor="ui-grid-editor" onclick="keydownClicked(this,event,false)" onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/></span>';
                       break;
                   case 'ADDRESS' :  middle += '<span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])"><span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" title="{{COL_FIELD}}" class="showIcon">{{COL_FIELD | limitTo:100}} {{COL_FIELD.length > 100 ?\'...\':\'\'}} </span>' + (showAsLink ? '</a>':'') 
                   +'<textarea  ng-model="MODEL_COL_FIELD" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field) && !grid.appScope.hideEditInView" class="form-control" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid editor"  onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/>'
                   + '<textarea rows="1" ng-model="MODEL_COL_FIELD" ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field) && grid.appScope.hideEditInView" class="form-control" ng-class="{\'required\':!grid.appScope.isNillable(row.entity.parentRec,col.field)}" ui-grid-editor="ui-grid editor"  onkeydown="keydownClicked(this,event,false)" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/></span>';
                       break;
                   case 'DATE': middle += '<ui-select-wrap><div class="select-container"><span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])">'
                   +'<span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">{{grid.appScope.getFormattedDate(COL_FIELD,"day",row.entity.parentRec,col.field)}}</span>'
                   + '<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">'
                   +  '<input type="hidden" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/><input ctype="customDate" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  ng-model="MODEL_COL_FIELD" mo-date-input="yyyy-dd-MM" min-view="day" is-required="true" date-value="{{MODEL_COL_FIELD}}" time-zone="{{grid.appScope.timezone}}"/>'
                   + '</span></span></div></ui-select-wrap>';
                       break;
                   case 'DATETIME' : middle += '<ui-select-wrap><div class="select-container"><span ng-if="grid.appScope.isOwnProperty(row.entity.parentRec.Id,col.field.split(\'.\')[1])">'
                   +'<span ng-if="row.entity.isView || !grid.appScope.isUpdateable(row.entity.parentRec,col.field) || grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)" class="showIcon">{{grid.appScope.getFormattedDate(COL_FIELD,"hour")}}</span>'
                   + '<span ng-if="!row.entity.isView && grid.appScope.isUpdateable(row.entity.parentRec,col.field) && !grid.appScope.checkEditabilityForRMSOwnedRecords(row.entity,col.field)">'	
                   +  '<input type="hidden" id="cell-{{grid.appScope.columnOrderMap[col.field]}}-{{row.entity.sequence}}"/><input ctype="customDate" is-required="{{grid.appScope.isNillable(row.entity.parentRec,col.field)}}"  ng-model="MODEL_COL_FIELD" is-required="true" mo-date-input="yyyy-dd-MM" min-view="hour" date-value="{{MODEL_COL_FIELD}}" time-zone="{{grid.appScope.timezone}}"/>'
                   + '</span></span></div></ui-select-wrap>';
                       break;
                       
                   default : break;
                       
                       
               }
           }
           return start + middle + end;
       }

function assignIdsToNavigateThroughHtmlElements() {
    return 'cell-' + (htmlElementId++);    
}

function assignPreviousErrors(errMapDetails) {
    //console.log('errMapDetails', errMapDetails);
    Object.keys(errMapDetails).map(function(key) { 
      //jQuery('#err' + key).tooltip();
       // jQuery('#err' + key).tooltip({title: errMapDetails[key], html: true, placement: "auto bottom"});
        				
        jQuery('#err' + key).attr('data-html',true)
        .attr('data-original-title', errMapDetails[key]).attr('data-placement','auto bottom')
        .tooltip('show');
        //console.log('err title' , angular.element(document.querySelector('#err' + key)));
        jQuery('#err' + key).removeClass('ng-hide');
        
    });
    
}

function toggleTooltip(ele,toggle) {
    jQuery(ele).tooltip(toggle);
}
 
function hideErrors() {
   
    jQuery('.grid').find("[id*='err']").each(function() {
        
            jQuery(this).addClass('ng-hide');
        	jQuery(this).tooltip('hide');
        	
    });
   /* var ele = jQuery('#alertMain');
    if(ele.hasClass('alert-info') && String(jQuery('#alertMsg').html()).indexOf('Please check the new records to be saved') != -1) {
        ele.removeClass('ng-hide');
    }*/
}

function getSelectedRecordsForEditMode(dataList, recIds) {
    return dataList.filter(function(data) {
       
        if(recIds.indexOf(data.parentRec.Id) != -1) {
            return data;
        }
       
        
    });
    
}

//returns the columns that are to be hidden initially when the page loads
function getInitialHideColumns() {
    return ['Id', 'Risk_Gauge_Color__c', 'Sequence__c', 'Department__c', 'Migration_Status__c', 'Reason__c', 'Reason_Missed_Planned_End_Date__c'];
}

function openAddMilestone(type,objectId) {
   // console.log(type,objectId);
    if(type == 'standard' || type == "product") {
        var url = '/apex/IMP_AddMilestones?subProjectId=' + objectId + '&type=' + type;
      window.open(url, 'windowPopup','location=1,status=1,scrollbars=1,resizable=1, width=800' + ',height=600');
       
    } 
    else if(type == 'standard=product') {
      
         var url = '/apex/IMP_MilestonePopup?subProjectId=' + objectId + '&type=' + type;
        window.open(url, 'windowPopup','location=1,status=1,scrollbars=1,resizable=1, width=800' + ',height=600');
    }
    
}

//called from Add Milestones page
function afRenderPage() {
    newRecordAdded = true;
    
    fetchLevelOneRecords();
    
  // fetchAllRecords();
}

function getNewRecordAdded() {
    return newRecordAdded;
}

function findCurrentVisibilityIdx(rows, recId) {
  //  console.log('length' ,rows.length);
    for(var i = 0;i < rows.length;i++) {
        if(rows[i].entity.parentRec.Id == recId) {
            console.log('visible', i);
            return i;
        }
    }
}

function getSuppressedColumnsForExport() {
    var suppressedArray = ['Action','Msg','parentRec.Id','parentRec.Risk_Gauge_Color__c'];
    return suppressedArray;
}

function setNewRecordAdded() {
    newRecordAdded = false;
}

function refineRecordsTobeSearched(recordsToBeSearched, dataList) {
    var recIdMap = {};
    var refinedResults = [];
    recordsToBeSearched.map(function(record) {
        recIdMap[record.Id] = record;
    });
    
    dataList.map(function(data) {
        key = data.parentRec.Id;
        if(recIdMap.hasOwnProperty(key)) {
            refinedResults.push(data.parentRec);
        }
        
    });
   // console.log('refined results',recIdMap, refinedResults);
    return refinedResults;
}

function populateActualCountOfRecords(childInfoMap, recordIds) {
    var countMap = {};
    recordIds.map(function(recId){
        countMap[recId] = childInfoMap[recId].split(',').length;
    });
    return countMap;
}

// ensure that there is atleast one child for parent
function processRecordsForDelete(childInfoMap, deleteRecordsList) {
    var processedList = [];
    var actualCountOfRecordsForEachParent = {};
    var countOfRecordsForEachParent = {};
    var childToParentMap = {};
    errToParents = {};
    deleteRecordsList.map(function(recId){
        var parentId = getParentDetailsOfRecord(childInfoMap, recId);
        childToParentMap[recId] = parentId;
        if(countOfRecordsForEachParent.hasOwnProperty(parentId)) {
            countOfRecordsForEachParent[parentId] = Number(countOfRecordsForEachParent[parentId]) + 1;
        }
        else {
             countOfRecordsForEachParent[parentId] = 1;
        }
        
    });
   actualCountOfRecordsForEachParent = populateActualCountOfRecords(childInfoMap,Object.keys(countOfRecordsForEachParent));
    
  //  console.log('countOfRecordsForEachParent',countOfRecordsForEachParent,actualCountOfRecordsForEachParent);
    deleteRecordsList.map(function(recId){
        var parentId = childToParentMap[recId];
        if(countOfRecordsForEachParent[parentId] != actualCountOfRecordsForEachParent[parentId]) {
            processedList.push(recId);
        }
        else {
            errToParents[parentId] = new Array('All child records can\'t be deleted. A record should have at least one child.');
        }
        
    });
  // console.log('processed list ofr delete', processedList);
    
    return processedList;
}

function getErrToParents() {
    return errToParents;
}

function getParentDetailsOfRecord(childInfoMap, childId) {
    inverseChildMap  = _.invert(childInfoMap);
    var keys = Object.keys(inverseChildMap);
    keysCnt = keys.length;
    for(var i = 0; i < keysCnt;i++) {
        if(keys[i].indexOf(childId) != -1) {
            return inverseChildMap[keys[i]];
        }
    }
    
}

function applyNewChangesToOldList(oldList, newList) {
    newList.map(function(record){
        var idx = getIndexForId(record.parentRec.Id,oldList);
        if(idx > -1) {
            //oldList[idx].parentRec = JSON.parse(JSON.stringify(record.parentRec));
            Object.keys(record.parentRec).map(function(key) {
               var value = record.parentRec[key];
                if(getDataTypeForField(key).toLowerCase() == 'date') {
                 //   console.log('formatting date',value,formatDate(value));
                    value = formatDate(value);
                }
                oldList[idx].parentRec[key] = value;
                
            });
            
        }
        
    });
    
}

function applyErrorsAndBackground() {
    removeBackgroundOfRows();
    setTimeout(function() {
        reCalculateHeightOfGrid();
        reAssignErrors();
        
    });
}

function compareData(data, oldData) {
//   console.log('in compare data');
    for(var i = 0;i < data.length;i++) {
        var idx = getIndexForId(data[i].parentRec.Id, oldData);
       
        if(idx == -1) {
            return true;
        }
        
        if(idx > -1) {
            var record = data[i].parentRec;
            var oldRecord = oldData[idx].parentRec;
            
            var keys = Object.keys(record);
          
            for(var j = 0;j < keys.length;j++) {
                var property = keys[j];
                if(!oldRecord.hasOwnProperty(property) && record[property] == null) {
                   
                	continue;
                }
                else if(!oldRecord.hasOwnProperty(property) && record[property].length != 0) {
                    //console.log('record has no property', record[property]);
                 
                    return true;
                }
                else {
                    var oldValue = oldRecord[property];
                    var value = record[property];
                    
                    if(getDataTypeForField(property).toLowerCase() == 'date') {
                        oldValue = formatDate(oldValue);
                        value = formatDate(value);
                    }
                    if(typeof oldValue !== 'undefined' && String(oldValue).toLowerCase() != String(value).toLowerCase()) {
                       // console.log('data comparision',oldValue,oldRecord,record);
                        return true;
                    }
                }
            }
        }
    }
  
    return false;
}

function focusToFirstField(recId) {
    var elements = jQuery( "[recId='" + recId + "']").find('.desc');
    console.log('elements text area', elements.length);
   for(var i = 0;i < elements.length;i++) {
        var ele = jQuery(elements[i]).find('textarea').focus();
       console.log('text area',ele);
       if(ele.length > 0) {
           //console.log('text area 1', ele[0].find('textarea'));
         // jQuery(ele[0]).find('textarea').focus();
           console.log('text area2',ele[0]);
          // break;
       }
    }
}

function keydownClicked(ele,event,changeData) {
  //console.log('changeData',changeData);
   keyClickCount = 0;
   // console.log('id',ele.id);
   //contains key codes of keys like enter,shift,arrows etc.
    var exceptionalKeys = [13,16,17,18,20,33,34,35,36,37,38,39,40,45,91,93];
   	var addBgToRow = false;
    if(event.keyCode == 9) {
        
         //console.log(jQuery(ele).nextAll('input,select').first().focus()); 
         //jQuery(ele).nextAll('input,select').first().focus();
         
         
         var cellId = ele.id.split('-');
         var row = cellId[2];
         var col = parseInt(cellId[1]) + 1;
         if(typeof row === 'undefined' || typeof col === 'undefined') {
             
             console.log('undefined row or column id');
             var prevEle = jQuery(ele).closest('.customdatepicker').prev();
            //console.log('undefined', test.attr('id'));
              cellId = prevEle.attr('id').split('-');
              row = cellId[2];
              col = parseInt(cellId[1]);
         }
         
         found = false;
         console.log('cell id is ',cellId);
         //scrollToCell(Number(row),Number(col));
         while(row < totalRecords) {
             while(col <= totalColumns) {
                 var newId = 'cell-' + col + '-' +  row;
                // console.log('newId' ,newId);
                 // console.log('newid' ,newId);
                 if(document.getElementById(newId) != null) {
                     var newEle = document.getElementById(newId)
                     if(newEle.type == 'hidden') {
                         
                         jQuery('#' + newEle.id).next().find('select,input').focus();    
                         
                         // jQuery('#' + newEle.id).next().find('select,input').select();  
                     }
                     else {
                         jQuery('#' + newId).focus();
                         // jQuery('#' + newId).select();
                     }	
                     found = true;
                     preventRecursion = false;
                     break;
                 }
                 
                 col++;
             }
             if(found) {
                 break;
             }
             row++;
             col = 1;
         }
         
       /*  if(!found) {
            console.log('not found');
        	//searchForTab(ele,event);
                    
         }*/
         if(row >= totalRecords && !found && !preventRecursion) {
            // console.log('greater',found);
             preventRecursion = true;
         	keydownClicked({id:'cell-0-0'},event);
         }
        
     }
    else if(changeData) {
        setDataChanged(true);
        lookupElement = ele;
        addBgToRow = true;
    }
     else if(exceptionalKeys.indexOf(event.keyCode) == -1 ) {
         
        // console.log('in data changed');
         addBgToRow = true;
         setTimeout(function() {
             isDataChanged();
         },100);
        
    }  
    
    if(addBgToRow) {
        var recId = jQuery(ele).closest('.rec').attr('recId');
         addRowsToChangedBackgroundRows(recId);
         addBackgroundToRowEdited(new Array(recId));
    }    
            
         
}

function changeBackground(ele) {
     var recId = jQuery(ele).closest('.rec').attr('recId');
    console.log('recId',recId);
    if(typeof recId !== 'undefined') {
        addRowsToChangedBackgroundRows(recId);
        addBackgroundToRowEdited(new Array(recId));
    }
}

function adjustLookupHeight() {
    if(lookupElement != null && lookupElement !== 'undefined') {
        var top = lookupElement.getBoundingClientRect().top;
        var halfWindowHeight = jQuery(window).height()/2 + 50;
        var nextEle = jQuery(lookupElement).next();
        console.log(nextEle);
        var nextEleTop = nextEle[0].getBoundingClientRect().top;
        var nextEleHeight = nextEle.height();
        console.log('look up',top,nextEleTop,halfWindowHeight,lookupElement);
      if(top > halfWindowHeight) {
            console.log('look up up');
           nextEleTop = jQuery(lookupElement).position().top - nextEleHeight - 15;
        }
        else {
           
               nextEleTop =  jQuery(lookupElement).position().top + jQuery(lookupElement).height();
            
            console.log('look up down');
        }
        jQuery(nextEle).css('top',nextEleTop + 'px');
     	console.log('height',jQuery(lookupElement).height(),nextEle.height(),nextEleTop);
    }
}

function searchForTab(ele, event) {
     var cellId = ele.id.split('-');
         var row = cellId[2];
         var col = parseInt(cellId[1]) + 1;
      console.log('not found' );
             var row = cellId[2];
            // col = parseInt(cellId[1]) + 1; 
            col = parseInt(cellId[1])
             var newId = 'cell-1-' + row;
           console.log(newId,document.getElementById(newId));
             if(document.getElementById(newId) != null) {
                 //console.log('new id' ,newId , totalColumns);
                   
                 while(col <= totalColumns) {
                     newId = 'cell-' + col + '-' + row;
                     console.log('newId' ,newId);
                    // console.log('newid' ,newId);
                     if(document.getElementById(newId) != null) {
                        var newEle = document.getElementById(newId);
                       if(newEle.type == 'hidden') {
                       	jQuery('#' + newEle.id).next().find('select,input').focus();    
                        //jQuery('#' + newEle.id).next().find('select,input').select();  
                       }
                      else {
                          console.log('in else part');
                          
                            jQuery('#' + newId).focus();
                          		//jQuery('#' + newId).select();
                       }
                         
                         found = true;
                         break;
                     }
                     
                     col++;
                     
                 }
                 
                 
             }
             
    if(col >= totalColumns && !found &&  keyClickCount == 0) {
        keyClickCount = 1;
        searchForTab({id:'cell-1-'+ row}, event);
       
    }
    
             

        
}

function datepickerClicked(ele) {
    
   var top = ele.getBoundingClientRect().top;
   var halfWindowHeight = jQuery(window).height()/2 + 50;
    
    //console.log('top', top,'halfWindowHeight', halfWindowHeight); 
    if(top > halfWindowHeight) {
        jQuery(ele).removeClass('dropdown').addClass('dropup');
    }
    else {
        jQuery(ele).removeClass('dropup').addClass('dropdown');
    }
    var recId = jQuery(ele).closest('.rec').attr('recId');
    if(typeof recId !== 'undefined') {
        addRowsToChangedBackgroundRows(recId);
        addBackgroundToRowEdited(new Array(recId));
    }
}

function onRowHover (ele,action) {
  
 var recId = jQuery(ele).attr('recId');
  
  jQuery( "[recId='" + recId + "']").each(function() {
      
      if(action == 'enter') {
        
          	jQuery(this).addClass('rowHover');    
    }
    else if(action == 'leave') {
       
        jQuery(this).removeClass('rowHover');
    }
      
  });
    
 }

function addBackgroundToRowEdited(recIds) {
 //  console.log('added class for background', recIds);
    recIds.map(function(recId) {
        var elements = jQuery( "[recId='" + recId + "']");
        elements.each(function(){
            
            jQuery(this).addClass('editingRowBackground');
        });  
        
    });
}

function removeBackgroundToRowEdited(recIds) {
  // console.log('ids to remove background', recIds);
    recIds.map(function(recId) {
        var elements = jQuery( "[recId='" + recId + "']");
        elements.each(function(){
            jQuery(this).removeClass('editingRowBackground');
        });  
        
    });
   
    var elements = jQuery('.rec');
    elements.each(function() {
        var key = jQuery(this).attr('recId').substring(0,3);
            var classAttr = 'rec level' + levelOfObjectsMap[key];
            jQuery(this).attr('class',classAttr);
        
    });
}

function doubleClickedCell(ele) {
    //console.log('capturing double click event in cell',jQuery(ele).attr('cellId'));
    setTimeout(function() {
        jQuery( "[cellId='inline" + jQuery(ele).attr('cellId') + "']").find('input,textarea').select();
    }, 40);
    
}

function getBtnStatus() {
   if(jQuery('#off').hasClass('btn-primary')) {
        return 'OFF';
    }
    else {
         return 'ON';
    }
}

function toggleSwitch() {
    jQuery('#on').toggleClass('btn-primary').toggleClass('btn-default');
    jQuery('#off').toggleClass('btn-primary').toggleClass('btn-default');
    if(jQuery('#off').hasClass('btn-primary')) {
        setSaveByDefault(false);
        jQuery('#showSaveBtn').css('display','block');
    }
    else {
         setSaveByDefault(true);
        jQuery('#showSaveBtn').css('display','none');
    }
}

function openReloadModal() {
    //console.log('open modal clicked');
   jQuery('#reloadModal').modal('show');
}

function closeReloadModal() {
   // console.log('modal closed');
      jQuery('#reloadModal').modal('hide');
}

function openEditScreenModal() {
    jQuery('#editBtnWarning').modal('show');
}

function confirmEdit() {
  
     expandedRowIds = [];   
     getRowsExpanded();
    //console.log('before edit',expandedRowIds);
     proceedToEdit();
    
    
}

function resetConfig() {
     localStorage.clear();
    jQuery('.waitingSearchDiv').removeClass('ng-hide');
    location.reload();
   
}

function checkInput(ele,event) {
    console.log('double input clicked',event.keyCode);
    var value = ele.value;
    var lastChar = value.charAt(value.length - 1);
    console.log('number checking',(typeof value ==='undefined' || value == null || value.length == 0), !isNaN(parseFloat(value)) && isFinite(value));
    if(!(typeof value ==='undefined' || value == null || value.length == 0))  {
        if(!isNaN(parseFloat(value)) && isFinite(value)) {
            jQuery(ele).css('border','solid 1px #d4d4d4').attr('title','')
        }
        else {
             jQuery(ele).css('border','solid 2px red').attr('title','Please enter valid input.')
        }
    }
    
    else {
         jQuery(ele).css('border','solid 1px #d4d4d4').attr('title','')
    }
    /*if((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105) || event.keyCode == 190 ||  event.keyCode == 110
      || event.keyCode == 8 || event.keyCode == 46) {
       //console.log('double',ele.value); 
    }
    else {
       //ele.value = value.replace(lastChar,'');
       jQuery(ele).css('border','solid 2px red').attr('title','Please enter valid input.')
    }*/
}

function fixedDown( str ,digits) {
    var re = new RegExp("(\\d+\\.\\d{" + digits + "})(\\d)"),
        m = str.toString().match(re);
    return m ? parseFloat(m[1]) : str.valueOf();
    console.log('fixed down');
};

jQuery(document).on('click','.ui-grid-icon-plus-squared,.ui-grid-icon-minus-squared',function() {
    setTimeout(function() {
        applyErrorsAndBackground();
    });
    
})

jQuery(document).on('focus','input,textarea',function() {
    //console.log('element focussed');
    jQuery(this).select();
})

jQuery(document).on('click','.switch',function() {
    //console.log('toggled');
   toggleSwitch();
    setTimeout(function() {
        jQuery('#moreDropdown').addClass('open');
        
    });
    
})

jQuery(document).on('click',".ui-grid-menu-button",function () {
    jQuery("button.ui-grid-menu-item:contains('Clear all filters')").hide();
  })

jQuery(document).on('keydown',function(e) {
    //disables window search(Ctrl + F) and F12
    if ((e.ctrlKey === true && e.keyCode === 70) /*|| e.keyCode === 123*/ ) {
        e.preventDefault();
        return false;
    }
})

jQuery(document).on('contextmenu',function(e) {
    //disable right click
    //return false;
})

