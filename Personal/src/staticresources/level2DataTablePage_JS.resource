angular.module("DataTableApp",[]);
            
            //Controller
            
            angular.module("DataTableApp").controller("DetailsController",function($scope,$window,$compile, $filter){
                
                
                sforce.connection.sessionId = '{!$Api.Session_ID}';
                $scope.objectName = getObjectName();
                $scope.sobjectDetail = sforce.connection.describeSObject($scope.objectName);
                $scope.fields = new Array();
                $scope.RecordTypes = new Array();
                $scope.ChildRelationShips = new Array();
                $scope.parentRecordsList = new Array();
                $scope.parentAndChildRecordsList = new Array();
                $scope.ChildRelationShipFields = new Array();
                $scope.selectedChildDetails;
                $scope.selectedChildRelationName;
                $scope.childRecordsPerParent = new Array();
                $scope.showTable = false;
                $scope.searchText = '';
                $scope.OrderByfieldName = 'Id';
                $scope.isReverseOrdered = false;
                $scope.childOrderByfieldName = 'Id';
                $scope.isChildReverseOrdered = false;
                $scope.limitParentRecords = 10;
                $scope.limitChildRecords = 10;
                $scope.recordsPerPage = 2;
                $scope.pageNumber = 1;
                $scope.totalPages = $scope.limitParentRecords;
                $scope.recordsInDisplay = new Array();
                $scope.showToolbar = false;
                $scope.showParentFields = false;
                $scope.showChildFields = false;
                $scope.queryCondition='';
                $scope.childQueryCondition ='';
                $scope.collapseChild = false;
                $scope.showDisplayButton = false;
                $scope.deleteRecords = false;
                $scope.updateRecords = false;
                $scope.massUpdateRecords = false;
                $scope.createNewParent = false;
                $scope.createNewChild = false;
                $scope.showParentFieldsForMassUpdate = false;
                $scope.showChildFieldsForMassUpdate = false;
                $scope.fieldsSelectedForMassUpdate = false;
                $scope.massUpdateParentChildSelection = null;
                $scope.showSelectedFieldsButton = false;
                $scope.referenceArray = new Array();
                $scope.errors = new Array();
                $scope.logs = new Array();
                $scope.showErrors = false;
                $scope.showLogs = false;
                $scope.captureUpdate = true;
                $scope.captureInsert = true;
                $scope.captureMassUpdate = true;
                $scope.captureQuery = true;
                $scope.captureDelete = true;
                $scope.captureUpdateError = true;
                $scope.captureInsertError = true;
                $scope.captureMassUpdateError = true;
                $scope.captureQueryError = true;
                $scope.captureDeleteError = true;
                $scope.errorOrder = false;
                $scope.logOrder =false;
                $scope.childToParentFieldName ='';
                $scope.parentRecordName='';

                $scope.setReferences = function(type){
                    var valueSet = false;
                    for(var i=0;i<$scope.referenceArray.length;i++)
                    {
                        if($scope.referenceArray[i].type == type)
                        {
                            valueSet = true;
                        }
                    }
                    if(!valueSet)
                    {
                        var typeValue = sforce.connection.query("select id, name from "+type+" order by name asc limit 50000");
                        $scope.referenceArray.push({type:type,values:typeValue.getArray('records')});
                    }
                }
                
                for(var i=0;i<$scope.sobjectDetail.fields.length;i++){
                    $scope.fields.push({selected:false,sortSelected:false,massUpdate:false,sortReverse:false,showField:true,fieldDetail:$scope.sobjectDetail.fields[i]});
                    if($scope.sobjectDetail.fields[i].type=='reference')
                    {
                        $scope.setReferences($scope.sobjectDetail.fields[i].referenceTo);
                    }
                }

                for(var i=0;i<$scope.sobjectDetail.childRelationships.length;i++){
                    $scope.ChildRelationShips.push({selected:false,ChildRelationshipDetail:$scope.sobjectDetail.childRelationships[i]});
                }

                if($scope.sobjectDetail.recordTypeInfos != undefined){
                    for(var i=0;i<$scope.sobjectDetail.recordTypeInfos.length;i++)
                    {
                        $scope.RecordTypes.push({selected:false,RecordTypeDetail:$scope.sobjectDetail.recordTypeInfos[i]});
                    }
                }
                
                $scope.displayTableButton = function(){
                    var checkParentFields=false;
                    for(var i=0;i<$scope.fields.length;i++){
                        checkParentFields = checkParentFields || $scope.fields[i].selected;}
                    var checkRelationSelected = false;
                    for(var i=0;i<$scope.ChildRelationShips.length;i++){
                        checkRelationSelected = checkRelationSelected || $scope.ChildRelationShips[i].selected;}
   					var childRelationFieldsSelected = false;
                    for(var i=0;i<$scope.ChildRelationShipFields.length;i++){
                        childRelationFieldsSelected = childRelationFieldsSelected || $scope.ChildRelationShipFields[i].selected;}
                    $scope.showDisplayButton = (!$scope.showTable) && childRelationFieldsSelected &&  checkRelationSelected && checkParentFields;
                    
                }
                
                $scope.getParentRecords = function(showTable){
                    
                    if(showTable || $scope.showTable)
                    {
                        var selectedFields = new Array();
                        for(var i=0;i<$scope.fields.length;i++)
                        { 
                            if($scope.fields[i].selected)
                            {
                                selectedFields.push($scope.fields[i].fieldDetail.name);
                            }
                        }
                        if(selectedFields.length==0)
                        {
                            selectedFields.push('Id');
                        }
                        var result = sforce.connection.query('select '+selectedFields.join(',')+' from '+ $scope.objectName+($scope.queryCondition==''?'':' where '+$scope.queryCondition +' ')+($scope.limitParentRecords.trim()==''?'':' Limit '+$scope.limitParentRecords));
                        
                        $scope.parentRecordsList = result.getArray('records');}
                    if(!$scope.showTable)
                    {
                        $scope.showTable = showTable;
                    }
                    $scope.paginateTable();
                }
                               
                $scope.getParentChildRecords = function(showTable){
                    
                    if(showTable || $scope.showTable)
                    {
                        var selectedFields = new Array();
                        for(var i=0;i<$scope.fields.length;i++)
                        { 
                            selectedFields.push($scope.fields[i].fieldDetail.name);
                        }
                        if(selectedFields.length==0)
                        {
                            selectedFields.push('Id');
                        }
                        var selectedChildFields = new Array();
                        for(var i=0;i<$scope.ChildRelationShipFields.length;i++)
                        { 
                            selectedChildFields.push($scope.ChildRelationShipFields[i].fieldDetail.name);
                        }
                        if(selectedChildFields.length==0)
                        {
                            selectedChildFields.push('Id');
                        }
                        var childQuery = '(select '+selectedChildFields.join(',')+' from '+ $scope.selectedChildRelationName+($scope.childQueryCondition==''?'':' where '+$scope.childQueryCondition +' ')+($scope.limitChildRecords==''?' ) ':' Limit '+$scope.limitChildRecords+' )'); 
                        var result;
                        try
                        {
                            result= sforce.connection.query('select '+selectedFields.join(',')+' ,'+childQuery+' from '+ $scope.objectName+($scope.queryCondition==''?'':' where '+$scope.queryCondition +' ')+($scope.limitParentRecords==''?'':' Limit '+$scope.limitParentRecords));
                        }
                        catch(error)
                        {
                            var errorString = {time:$scope.getDateTime(),operation:'Retrieve',message:error.faultstring};
                            $scope.errors.push(errorString);
                            $scope.captureQueryError =true;
                            $scope.showErrors = true;
                            $scope.showToolbar =false;
                            $scope.showLogs = false;
                            $scope.showParentFields = false;
                            $scope.showChildFields = false;
                        }
                        if(result!=undefined && result.getBoolean('done'))
                        {
                            $scope.parentAndChildRecordsList = result.getArray('records');
                            var output= {time:$scope.getDateTime(),operation:'Retrieve',message:"Retrieved "+$scope.parentAndChildRecordsList.length+" records successfully"};
                            $scope.logs.push(output);
                        }
                    }
                    if(!$scope.showTable)
                    {
                        $scope.showTable = showTable;
                    }
                    $scope.paginateTable();
                    
                    $scope.referenceArray = new Array();
                    for(var i=0;i<$scope.sobjectDetail.fields.length;i++){
                        if($scope.sobjectDetail.fields[i].type=='reference')
                        {
                            $scope.setReferences($scope.sobjectDetail.fields[i].referenceTo);
                        }
                    }
                    
                    $scope.getChildToParentRelation();
                }
                                
                $scope.getChildToParentRelation = function(){
                    var parentAPIName = '';
                    var ParentId;
                    var search = new Array();
                    for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                    {
                        if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]!=undefined && $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length>0)
                        {
                            ParentId = $scope.parentAndChildRecordsList[i]['Id'];
                            search = $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'];
                            break;
                        }
                    }
                    search = search[0].toString().split(',');
                    var expectedNames = new Array();
                    for(var i=0;i<search.length;i++)
                    {
                        if(search[i].indexOf(ParentId)>0)
                        {
                            expectedNames.push({name:search[i].split(':')[0].replace('{',''),isValue:false});
                        }
                    }
                    if(expectedNames.length > 1)
                    {
                        for(var i=0;i<expectedNames.length;i++)
                        {
                            for(var j=0;j<$scope.parentAndChildRecordsList.length;j++)
                            {
                                if($scope.parentAndChildRecordsList[j][$scope.selectedChildRelationName]!=undefined && $scope.parentAndChildRecordsList[j][$scope.selectedChildRelationName]['records'].length>0)
                                {
                                	for(var k=0;k<$scope.parentAndChildRecordsList[j][$scope.selectedChildRelationName]['records'].length;k++)
                                    {
                                        if(!Array.isArray($scope.parentAndChildRecordsList[j][$scope.selectedChildRelationName]['records'][k]))
                                        {
                                            if($scope.parentAndChildRecordsList[j][$scope.selectedChildRelationName]['records'][k][expectedNames[i]]!=$scope.parentAndChildRecordsList[j]['Id'])
                                            {
                                                expectedNames[i].isValue=false;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        var count =0;
                        for(var i=0;i<expectedNames.length;i++)    
                        {
                            if(expectedNames[i].isValue)
                            {
                                count++;
                            }
                        }
                        if(count==1)
                        {
                            for(var i=0;i<expectedNames.length;i++)    
                            {
                                if(expectedNames[i].isValue)
                                {
                                    $scope.childToParentFieldName = expectedNames[i].name;
                                }
                            }
                        }
                    }
                    else if(expectedNames.length == 1)
                    {
                        $scope.childToParentFieldName = expectedNames[0].name;
                    }
                    $scope.childToParentFieldName = $scope.childToParentFieldName.trim();
                }
                
                $scope.getChildRecords = function(record){
                    if(record!=null && record!=undefined)
                    {
                        if(record[$scope.selectedChildRelationName]!=null)
                        {
                            if(Array.isArray(record[$scope.selectedChildRelationName]['records']))
                            {
                                return record[$scope.selectedChildRelationName]['records'];
                            }
                            var result = new Array();
                            result.push(record[$scope.selectedChildRelationName]['records']);
                            return result;
                        }
                    }
                    return new Array();
                }
                
                $scope.getDateTime = function(){
                    var now     = new Date(); 
                    var year    = now.getFullYear();
                    var month   = now.getMonth()+1; 
                    var day     = now.getDate();
                    var hour    = now.getHours();
                    var minute  = now.getMinutes();
                    var second  = now.getSeconds(); 
                    if(month.toString().length == 1) {
                        var month = '0'+month;
                    }
                    if(day.toString().length == 1) {
                        var day = '0'+day;
                    }   
                    if(hour.toString().length == 1) {
                        var hour = '0'+hour;
                    }
                    if(minute.toString().length == 1) {
                        var minute = '0'+minute;
                    }
                    if(second.toString().length == 1) {
                        var second = '0'+second;
                    }   
                    var dateTime = year+'/'+month+'/'+day+' '+hour+':'+minute+':'+second;   
                    return dateTime;
                }
                
                $scope.sortSelectedOrReveresed = function(label,fields){
                    for(var i=0;i<fields.length;i++)
                    {
                        if((fields[i].sortSelected || fields[i].sortReverse) && fields[i].fieldDetail.label.trim().toLowerCase() == label.trim().toLowerCase())
                        {
                            fields[i].sortSelected = !fields[i].sortSelected;
                            fields[i].sortReverse = !fields[i].sortReverse;
                            break;
                        }
                        if(fields[i].fieldDetail.label.trim().toLowerCase() == label.trim().toLowerCase())
                        {
                            fields[i].sortSelected = true;
                        }
                        else
                        {
                            fields[i].sortSelected = false; 
                            fields[i].sortReverse = false;
                        }
                    }
                }
                
                $scope.logsFilter = function(operation){
                    switch(operation)
                    {
                        case 'Insert': return $scope.captureInsert;
                        case 'Update': return $scope.captureUpdate;
                        case 'Delete': return $scope.captureDelete;
                        case 'Retrieve': return $scope.captureQuery;
                        case 'Mass Update': return $scope.captureMassUpdate;
                    }
                }
                
                $scope.errorsFilter = function(operation){
                    switch(operation)
                    {
                        case 'Insert': return $scope.captureInsertError;
                        case 'Update': return $scope.captureUpdateError;
                        case 'Delete': return $scope.captureDeleteError;
                        case 'Retrieve': return $scope.captureQueryError;
                        case 'Mass Update': return $scope.captureMassUpdateError;
                    }
                }
                
                $scope.getSelectedRelatedListFields = function(relationName){
                    $scope.selectedChildRelationName = relationName;
                    $scope.ChildRelationShipFields = new Array();
                    var remainingIndex;
                    for(var i=0;i<$scope.ChildRelationShips.length ;i++)
                    {
                        if($scope.ChildRelationShips[i].selected)
                        {
                            if(relationName.toUpperCase().trim() == $scope.ChildRelationShips[i].ChildRelationshipDetail.relationshipName.toUpperCase().trim())
                            {
                                remainingIndex = i+1;
                                $scope.selectedChildDetails = sforce.connection.describeSObject($scope.ChildRelationShips[i].ChildRelationshipDetail.childSObject);
                                
                                if($scope.selectedChildDetails!=undefined)
                                {
                                    for(var j=0;j<$scope.selectedChildDetails.fields.length;j++)
                                    {
                                        $scope.ChildRelationShipFields.push({selected:false,sortReverse:false,massUpdate:false,sortSelected:false,showField:true,fieldDetail:$scope.selectedChildDetails.fields[j]});
                                    }
                                }
                            }
                            else
                            {
                                $scope.ChildRelationShips[i].selected= false;
                            }
                        }
                    }
                    
                    for(var i=remainingIndex;i<$scope.ChildRelationShips.length;i++)
                    {
                        if($scope.ChildRelationShips[i] != undefined)
                        {
                            $scope.ChildRelationShips[i].selected= false;
                        }
                    }
                }
                
                $scope.order = function(fieldName){
                    if($scope.OrderByfieldName.trim().toLowerCase() == fieldName.trim().toLowerCase())
                    {
                        $scope.isReverseOrdered = !($scope.isReverseOrdered);
                    }
                    else
                    {
                        $scope.OrderByfieldName = fieldName;
                        $scope.isReverseOrdered = false;
                    }
                }
                
                $scope.deleteSelectedRecords = function(){
                    var count=0;
                    var deleteIdsList = new Array();
                    for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                    {
                        if($scope.parentAndChildRecordsList[i].deleteRecord)
                        {
                            count++;
                            deleteIdsList.push($scope.parentAndChildRecordsList[i]['Id']);
                        }
                        if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName])
                        {
                            if(Array.isArray($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']))
                            {
                                for(var j=0;j<$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length;j++)
                                {
                                    if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j].deleteRecord)
                                    {
                                        count++;
                                        deleteIdsList.push($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j]['Id']);
                                        console.log($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']);
                                    }
                                }
                            }
                            else
                            {
                                if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].deleteRecord)
                                {
                                    count++;
                                    deleteIdsList.push($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']['Id']);
                                }
                            }
                        }
                    }
                    var confirmResult = confirm('Are You Sure you want to delete '+count+' records selected?');
                    if(confirmResult)
                    {
                        var delResult = sforce.connection.deleteIds(deleteIdsList);
                        for(var i=0;i<delResult.length;i++)
                        {
                            if (delResult[i].getBoolean("success")) {
                                $scope.logs.push({time:$scope.getDateTime(),operation:'Delete',message:" record with id " + deleteIdsList[i] + " deleted"});
                            } else {
                                $scope.errors.push({time:$scope.getDateTime(),operation:'Delete',message:" "+deleteIdsList[i]+" failed, "+"Cause: "+delResult[i].errors.message});
                                $scope.showErrors = true;
                                $scope.captureDeleteError =true;
                                $scope.showToolbar =false;
                                $scope.showLogs = false;
                                $scope.showParentFields = false;
                                $scope.showChildFields = false;
                            }
                            
                        }
                        $scope.getParentChildRecords(false);
                        cancel();
                    }
                }
                
                $scope.updateable = function(field){
                    if(field.fieldDetail.updateable=='true')
                        return true;
                    return false;
                }
                
                $scope.unique = function(field){
                    if(field.fieldDetail.unique =='true')
                        return true;
                    return false;
                }
                
                $scope.insertParentRecord = function(element){
                    try
                    {
                    	var insertResult = sforce.connection.upsert("Id", [$scope.newParentRecord]);
                    }
                    catch(error)
                    {
                        $scope.errors.push({time:$scope.getDateTime(),operation:'Insert',message:error.errors.message});
                        $scope.captureInsertError = true;
                        $scope.showErrors = true;
                        $scope.showToolbar =false;
                        $scope.showLogs = false;
                        $scope.showParentFields = false;
                        $scope.showChildFields = false;
                    }
                    if(insertResult[0].getBoolean('success'))
                    {
                        $scope.getParentChildRecords(false);
                        $scope.logs.push({time:$scope.getDateTime(),operation:'Insert',message:insertResult[0].id+" is created successfully"});
                    }
                    $scope.createNewParent = false;
                }
                
                $scope.insertChildRecord = function(element){
                    try
                    {
                    	var insertResult = sforce.connection.upsert("Id", [$scope.newChildRecord]);
                    }
                    catch(error)
                    {
                        $scope.errors.push({time:$scope.getDateTime(),operation:'Insert',message:error.errors.message});
                        $scope.showErrors = true;
                        $scope.captureInsertError = true;
                        $scope.showToolbar =false;
                        $scope.showLogs = false;
                        $scope.showParentFields = false;
                        $scope.showChildFields = false;
                    }
                    if(insertResult[0].getBoolean('success'))
                    {
                        $scope.getParentChildRecords(false);
                        $scope.logs.push({time:$scope.getDateTime(),operation:'Insert',message:insertResult[0].id+" is created successfully"});
                    }
                    $scope.createNewChild = false;
                }
                
                $scope.childOrder = function(fieldName){
                    if($scope.childOrderByfieldName.trim().toLowerCase() == fieldName.trim().toLowerCase())
                    {
                        $scope.childIsReverseOrdered = !($scope.childIsReverseOrdered);
                    }
                    else
                    {
                        $scope.childOrderByfieldName = fieldName;
                        $scope.childIsReverseOrdered = false;
                    }
                }
                
                $scope.paginateTable = function(){
                    $scope.totalPages = Math.ceil($scope.parentAndChildRecordsList.length / $scope.recordsPerPage);
                    
                    var requiredRecords = new Array();
                    
                    if(parseInt($scope.pageNumber)==0){
                        $scope.pageNumber =1;
                    }
                    else if(parseInt($scope.pageNumber)>parseInt($scope.totalPages)){
                        $scope.pageNumber =$scope.totalPages;
                    }
                    
                    var startIndex =  ($scope.pageNumber-1) * $scope.recordsPerPage;
                    
                    for(var i=startIndex;i<(startIndex+$scope.recordsPerPage) && i<$scope.parentAndChildRecordsList.length;i++){
                        requiredRecords.push($scope.parentAndChildRecordsList[i]);
                    }
                    
                    $scope.recordsInDisplay = requiredRecords;
                }
                
                $scope.instantiateNewRecord = function(type,parentRecord){
                    if(type == 'parent')
                    {
                        if(!$scope.fieldsSelectedForMassUpdate)
                        {
                            $scope.createNewParent = true;
                        }
                        
                        $scope.newParentRecord = new sforce.SObject($scope.objectName);
                        
                    }
                    else if(type == 'child')
                    {
                        if(!$scope.fieldsSelectedForMassUpdate)
                        {
                            $scope.createNewChild = true; 
                        }
                        $scope.newChildRecord = new sforce.SObject($scope.selectedChildDetails.name);
                        if(!$scope.massUpdateRecords && $scope.childToParentFieldName!=undefined && $scope.childToParentFieldName!=null && $scope.childToParentFieldName.length>0)
                        {
                            $scope.newChildRecord[$scope.childToParentFieldName.trim()] = parentRecord;
                            $scope.setParentRecord();
                        }
                        
                    }
                }  
                
                $scope.updateRecordsMethod = function(){
                    if($scope.massUpdateParentChildSelection == 'Parent' && $scope.newParentRecord!=null)
                    { 
                        var updateParentList =  new Array();
                        var requiredIds = new Array();
                        var selectedMassUpdateFields = new Array();
                        for(var i=0;i<$scope.fields.length;i++)
                        {
                            if($scope.fields[i].massUpdate)
                            {
                                selectedMassUpdateFields.push($scope.fields[i].fieldDetail.name);
                            }
                        }
                        selectedMassUpdateFields.push('Id');
                        for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                        {
                            if($scope.parentAndChildRecordsList[i].updateRecord)
                            {
                                requiredIds.push('\''+$scope.parentAndChildRecordsList[i]['Id']+'\'');
                            }
                        }
                        updateParentList = sforce.connection.query('select '+selectedMassUpdateFields.join(',')+' from '+$scope.objectName+' where id in ( '+requiredIds.join(',')+' )');
                        updateParentList = updateParentList['records'];
                        if(!Array.isArray(updateParentList))
                        {
                            var newArray = new Array();
                            newArray.push(updateParentList);
                            updateParentList = newArray;
                        }
                        for(var i=0;i<$scope.fields.length;i++)
                        {
                            if($scope.fields[i].massUpdate)
                            {
                                for(j=0;j<updateParentList.length;j++)
                                {
                                    if($scope.fields[i].fieldDetail.type=="datetime" ||$scope.fields[i].fieldDetail.type=="date")
                                    {
                                        $scope.newParentRecord[$scope.fields[i].fieldDetail.name] = $scope.newParentRecord[$scope.fields[i].fieldDetail.name].toJSON();
                                    }
                                    updateParentList[j][$scope.fields[i].fieldDetail.name] = $scope.newParentRecord[$scope.fields[i].fieldDetail.name];
                                }
                            }
                        }
                        if(updateParentList.length>0)
                        {
                            var updateResult = sforce.connection.update(updateParentList);
                            $scope.getParentChildRecords(false);
                            $scope.cancel();
                            for(var i=0;i<updateResult.length;i++)
                            {
                                if(updateResult[i].getBoolean('success'))
                                {
                                    
                                    $scope.logs.push({time:$scope.getDateTime(),operation:'Mass Update',message:'update on record '+updateResult[i].id+ ' successful'});
                                }
                                else
                                {
                                    $scope.errors.push({time:$scope.getDateTime(),operation:'Mass Update',message:'update failed cause'+updateResult[i].errors.message});
                                    $scope.showErrors = true;
                                    $scope.captureUpdateError = true;
                                    $scope.showToolbar =false;
                                    $scope.showLogs = false;
                                    $scope.showParentFields = false;
                                    $scope.showChildFields = false;
                                }
                            }
                        }
                    }
                    else if($scope.massUpdateParentChildSelection == 'Child' && $scope.newChildRecord!=null)
                    { 
                        var updateChildList =  new Array();
                        var requiredIds = new Array();
                        var selectedMassUpdateFields = new Array();
                        
                        for(var i=0;i<$scope.ChildRelationShipFields.length;i++)
                        {
                            if($scope.ChildRelationShipFields[i].massUpdate)
                            {
                                selectedMassUpdateFields.push($scope.ChildRelationShipFields[i].fieldDetail.name);
                            }
                        }
                        selectedMassUpdateFields.push('Id');
                        
                        for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                        {
                            if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] !=null && $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] !=undefined)
                            {
                                if(Array.isArray($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']))
                                {
                                    for(var j=0;j<$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length;j++)
                                    {
                                        if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j].updateRecord)
                                        {
                                            requiredIds.push('\''+$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j]['Id']+'\'');
                                        }
                                    }
                                }
                                else if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'] != undefined)
                                {
                                    if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].updateRecord)
                                    {
                                        requiredIds.push('\''+$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']['Id']+'\'');
                                    }
                                }
                            }
                        }
                        updateChildList = sforce.connection.query('select '+selectedMassUpdateFields.join(',')+' from '+$scope.selectedChildDetails.name+' where id in ( '+requiredIds.join(',')+' )');
                        updateChildList = updateChildList['records'];
                        if(!Array.isArray(updateChildList))
                        {
                            var newArray = new Array();
                            newArray.push(updateChildList);
                            updateChildList = newArray;
                        }
                        
                        for(var i=0;i<$scope.ChildRelationShipFields.length;i++)
                        {
                            if($scope.ChildRelationShipFields[i].massUpdate)
                            {
                                for(j=0;j<updateChildList.length;j++)
                                {
                                    if($scope.ChildRelationShipFields[i].fieldDetail.type=="datetime" ||$scope.ChildRelationShipFields[i].fieldDetail.type=="date")
                                    {
                                        $scope.newChildRecord[$scope.ChildRelationShipFields[i].fieldDetail.name] = $scope.newChildRecord[$scope.ChildRelationShipFields[i].fieldDetail.name].toJSON();
                                    }
                                    updateChildList[j][$scope.ChildRelationShipFields[i].fieldDetail.name] = $scope.newChildRecord[$scope.ChildRelationShipFields[i].fieldDetail.name];
                                }
                            }
                        }
                        if(updateChildList.length>0)
                        {
                            var updateResult = sforce.connection.update(updateChildList);
                            $scope.getParentChildRecords(false);
                            $scope.cancel();
                            for(var i=0;i<updateResult.length;i++)
                            {
                                if(updateResult[i].getBoolean('success'))
                                {
                                    $scope.logs.push({time:$scope.getDateTime(),operation:'Mass Update',message:'update on record '+updateResult[i].id+ ' successful'});
                                }
                                else
                                {
                                    $scope.errors.push({time:$scope.getDateTime(),operation:'Mass Update',message:'update failed cause'+updateResult[i].errors.message});
                                    $scope.showErrors = true;
                                    $scope.captureUpdateError = true;
                                    $scope.showToolbar =false;
                                    $scope.showLogs = false;
                                    $scope.showParentFields = false;
                                    $scope.showChildFields = false;
                                }
                            }                                
                        }
}
                        else
                        {
                            var updateParentList = new Array();
                            var updateChildList = new Array();
                            var requiredParentIds = new Array();
                            var requiredChildIds = new Array();
                            for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                            {
                                if($scope.parentAndChildRecordsList[i].updateRecord)
                                {
                                    requiredParentIds.push('\''+$scope.parentAndChildRecordsList[i]['Id']+'\'');
                                }
                            }
                            for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                            {
                                if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] !=null)
                                {
                                    if(Array.isArray($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']))
                                    {
                                        for(var j=0;j<$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length;j++)
                                        {
                                            if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j].updateRecord)
                                            {
                                                requiredChildIds.push('\''+$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j]['Id']+'\'');
                                            }
                                        }
                                    }
                                    else if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'] != undefined)
                                    {
                                        if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].updateRecord)
                                        {
                                            requiredChildIds.push('\''+$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']['Id']+'\'');
                                        }
                                    }
                                }
                            }
                            var selectedFields = new Array();
                            for(var i=0;i<$scope.fields.length;i++)
                            { 
                                if($scope.fields[i].fieldDetail.updateable=='true' && $scope.fields[i].selected && $scope.fields[i].fieldDetail.name!='Id')
                                {
                                    selectedFields.push($scope.fields[i].fieldDetail.name);
                                }
                            }
                            selectedFields.push('Id');
                            var selectedChildFields = new Array();
                            for(var i=0;i<$scope.ChildRelationShipFields.length;i++)
                            { 
                                if($scope.ChildRelationShipFields[i].fieldDetail.updateable=='true' && $scope.ChildRelationShipFields[i].selected && $scope.ChildRelationShipFields[i].fieldDetail.name!='Id')
                                {
                                    selectedChildFields.push($scope.ChildRelationShipFields[i].fieldDetail.name);
                                }
                            }
                            selectedChildFields.push('Id');
                            
                            if(requiredParentIds.length>0)
                            {
                                updateParentList = sforce.connection.query('select '+selectedFields.join(',')+' from '+$scope.objectName+' where id in ( '+requiredParentIds.join(',') +' )');
                                updateParentList = updateParentList['records'];
                                if(!Array.isArray(updateParentList))
                                {
                                    var newArray = new Array();
                                    newArray.push(updateParentList);
                                    updateParentList = newArray;
                                }
                                var count=0;
                                for(var i=0;i<$scope.parentAndChildRecordsList.length && count<updateParentList.length;i++)
                                {
                                    for(var j=0;j<updateParentList.length;j++)
                                    {
                                        if(updateParentList[j]['Id']==$scope.parentAndChildRecordsList[i]['Id'])
                                        {
                                            count++;
                                            for(var k=0;k<$scope.fields.length;k++)
                                            {
                                                if($scope.fields[k].selected && $scope.fields[k].fieldDetail.updateable=='true')
                                                {
                                                    if($scope.fields[k].fieldDetail.type=='date' || $scope.fields[k].fieldDetail.type=='datetime')
                                                    {
                                                        $scope.parentAndChildRecordsList[i][$scope.fields[k].fieldDetail.name] = $scope.parentAndChildRecordsList[i][$scope.fields[k].fieldDetail.name].toJSON();
                                                    }
                                                    updateParentList[j][$scope.fields[k].fieldDetail.name] = $scope.parentAndChildRecordsList[i][$scope.fields[k].fieldDetail.name];
                                                }
                                            }
                                        }
                                    }
                                }
                                var updateResult = sforce.connection.update(updateParentList);
                                for(var i=0;i<updateResult.length;i++)
                                {
                                    if(updateResult[i].getBoolean('success'))
                                    {
                                        
                                        $scope.logs.push({time:$scope.getDateTime(),operation:'Update',message:'update on record '+updateResult[i].id+ ' successful'});
                                    }
                                    else
                                    {
                                        $scope.errors.push({time:$scope.getDateTime(),operation:'Update',message:'update failed cause'+updateResult[i].errors.message});
                                        $scope.showErrors = true;
                                        $scope.captureUpdateError = true;
                                        $scope.showToolbar =false;
                                        $scope.showLogs = false;
                                        $scope.showParentFields = false;
                                        $scope.showChildFields = false;
                                    }
                                }
                            }
                            if(requiredChildIds.length>0)
                            {
                                updateChildList = sforce.connection.query('select '+selectedChildFields.join(',')+' from '+$scope.selectedChildDetails.name+' where id in ( '+requiredChildIds.join(',') +' )');
                                updateChildList = updateChildList['records'];
                                if(!Array.isArray(updateChildList))
                                {
                                    var newArray = new Array();
                                    newArray.push(updateChildList);
                                    updateChildList = newArray;
                                }
                                var count=0;
                                for(var i=0;i<$scope.parentAndChildRecordsList.length && count<updateChildList.length;i++)
                                {
                                    if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] !=null && $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] !=undefined)
                                    {
                                        if(Array.isArray($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']))
                                        {
                                            for(var j=0;j<$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length;j++)
                                            {
                                                for(var k=0;k<updateChildList.length;k++)
                                                {
                                                    
                                                        console.log(updateChildList[k]['Id'],$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j]['Id']);
                                                    if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j]['Id'] == updateChildList[k]['Id'])
                                                    {
                                                        for(var l=0;l<$scope.ChildRelationShipFields.length;l++)
                                                        {
                                                            if($scope.ChildRelationShipFields[l].selected && $scope.ChildRelationShipFields[l].fieldDetail.updateable=='true')
                                                            {
                                                                count++;
                                                                if($scope.ChildRelationShipFields[l].fieldDetail.type=='datetime' || $scope.ChildRelationShipFields[l].fieldDetail.type=='date')
                                                                {
                                                                    $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j][$scope.ChildRelationShipFields[l].fieldDetail.name] = $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j][$scope.ChildRelationShipFields[l].fieldDetail.name].toJSON();
                                                                }
                                                                updateChildList[k][$scope.ChildRelationShipFields[l].fieldDetail.name] = $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j][$scope.ChildRelationShipFields[l].fieldDetail.name];
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'] != undefined)
                                        {
                                            if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].updateRecord)
                                            {
                                                for(var k=0;k<updateChildList.length;k++)
                                                {
                                                    if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']['Id'] == updateChildList[k]['Id'])
                                                    {
                                                        for(var l=0;l<$scope.ChildRelationShipFields.length;l++)
                                                        {
                                                            if($scope.ChildRelationShipFields[l].selected && $scope.ChildRelationShipFields[l].fieldDetail.updateable=='true')
                                                            {
                                                                count++;
                                                                if($scope.ChildRelationShipFields[l].fieldDetail.type=='datetime' || $scope.ChildRelationShipFields[l].fieldDetail.type=='date')
                                                                {
                                                                    $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][$scope.ChildRelationShipFields[l].fieldDetail.name] = $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][$scope.ChildRelationShipFields[l].fieldDetail.name].toJSON();
                                                                }
                                                                updateChildList[k][$scope.ChildRelationShipFields[l].fieldDetail.name] = $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][$scope.ChildRelationShipFields[l].fieldDetail.name];
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                var updateResult = sforce.connection.update(updateChildList);
                                for(var i=0;i<updateResult.length;i++)
                                {
                                    if(updateResult[i].getBoolean('success'))
                                    {
                                        
                                        $scope.logs.push({time:$scope.getDateTime(),operation:'Update',message:'update on record '+updateResult[i].Id+ ' successful'});
                                    }
                                    else
                                    {
                                        $scope.errors.push({time:$scope.getDateTime(),operation:'Update',message:'update failed cause'+updateResult[i].errors.message});
                                        $scope.showErrors = true;
                                        $scope.captureUpdateError = true;
                                        $scope.showToolbar =false;
                                        $scope.showLogs = false;
                                        $scope.showParentFields = false;
                                        $scope.showChildFields = false;
                                    }
                                }
                            }
                        }
                    $scope.getParentChildRecords(false);
                    $scope.cancel();
                }
                
                $scope.showDeleteButton = function(){
                    for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                    {
                        if($scope.parentAndChildRecordsList[i].deleteRecord)
                        {
                            return true;
                        }
                        if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] != null)
                        {
                            if(Array.isArray($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']))
                            {
                                for(var j=0;j<$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length;j++)
                                {
                                    if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j].deleteRecord)
                                    {
                                        return true;
                                    }
                                }
                            }
                            else if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'] != undefined)
                            {
                                if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].deleteRecord)
                                {
                                    return true;
                                }
                            }
                        }
                    }
                    return false;
                }
                
                $scope.showSelectedFieldsButtonValidate = function(){
                    if($scope.massUpdateParentChildSelection == 'Parent')
                    { 
                        for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                        {
                            if($scope.parentAndChildRecordsList[i].updateRecord)
                            {
                                $scope.showSelectedFieldsButton =  true;
                                return null;
                            }
                        }
                    }
                    else if($scope.massUpdateParentChildSelection == 'Child')
                    {
                        for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                        {
                            if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] != null)
                            {
                                if(Array.isArray($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']))
                                {
                                    for(var j=0;j<$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length;j++)
                                    {
                                        if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j].updateRecord)
                                        {
                                            $scope.showSelectedFieldsButton = true;
                                            return null;
                                        }
                                    }
                                }
                                else if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'] != undefined)
                                {
                                    if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].updateRecord)
                                    {
                                        $scope.showSelectedFieldsButton = true;
                                        return null;
                                    }
                                }
                            }
                        }
                    }
                        
                    $scope.showSelectedFieldsButton =  false;
                }
                
                $scope.validate = function(type){
                    if(type=='parent')
                    {
                        var isValid = true;
                        for(var i=0;i<$scope.fields.length;i++)
                        {
                            if($scope.fields[i].fieldDetail.nillable == 'false' && $scope.fields[i].fieldDetail.updateable == 'true')
                            {
                                var value = $scope.newParentRecord[$scope.fields[i].fieldDetail.name];
                                if(value==undefined || value==null || value.trim()=='')
                                {
                                    
                                    isValid =false;
                                }
                            }
                        }
                        if(isValid)
                        {
                            $scope.insertParentRecord();
                        }
                    }
                    else if(type=='child')
                    {
                        var isValid = true;
                        for(var i=0;i<$scope.ChildRelationShipFields.length;i++)
                        {
                            if($scope.ChildRelationShipFields[i].fieldDetail.nillable == 'false' && $scope.ChildRelationShipFields[i].fieldDetail.updateable == 'true')
                            {
                                var value = $scope.newChildRecord[$scope.ChildRelationShipFields[i].fieldDetail.name];
                                if(value==undefined || value==null || value.trim()=='')
                                {
                                    isValid =false;
                                }
                            }
                        }
                        if(isValid)
                        {
                            $scope.insertChildRecord();
                        }
                    }
                }
                
                $scope.setValuesButtonValidate = function(type){
                    if(type=='parent')
                    {
                        for(var i=0;i<$scope.fields.length;i++)
                        {
                            if($scope.fields[i].massUpdate)
                            {
                                return true;
                            }
                        }
                    }
                    else if(type=='child')
                    {
                        for(var i=0;i<$scope.ChildRelationShipFields.length;i++)
                        {
                            if($scope.ChildRelationShipFields[i].massUpdate)
                            {
                                return true;
                            }
                        }
                    }
                    return false;
                }
                
                $scope.setForUpdate = function(field,record){
                    if(field.fieldDetail.updateable == 'true')
                    {
                        $scope.updateRecords = true;
                        record.updateRecord = true;
                        $scope.deleteRecords = false;
                        $scope.massUpdateRecords = false;
                    }
                }
                
                $scope.cancel = function(){
                    $scope.createNewParent = false;
                    $scope.createNewChild = false;
                    $scope.newParentRecord = null;
                    $scope.newChildRecord = null;
                    $scope.deleteRecords = false;
                    $scope.updateRecords = false;
                    $scope.massUpdateRecords = false;
                    $scope.showParentFieldsForMassUpdate = false;
                    $scope.showChildFieldsForMassUpdate = false;
                    $scope.fieldsSelectedForMassUpdate = false;
                    $scope.massUpdateParentChildSelection = null;
                    $scope.showSelectedFieldsButton = false;
                    $scope.fieldsSelectedForMassUpdate = false;
                    $scope.searchText = '';
                    for(var i=0;i<$scope.fields.length;i++)
                    {
                        $scope.fields[i].massUpdate =false;
                    }
                    for(var i=0;i<$scope.ChildRelationShipFields.length;i++)
                    {
                        $scope.ChildRelationShipFields[i].massUpdate =false;
                    }
                    for(var i=0;i<$scope.parentAndChildRecordsList.length;i++)
                    {
                        $scope.parentAndChildRecordsList[i].updateRecord =false;
                        $scope.parentAndChildRecordsList[i].deleteRecord =false;
                        if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName] != null)
                        {
                            if(Array.isArray($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']))
                            {
                                for(var j=0;j<$scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].length;j++)
                                {
                                    $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j].updateRecord =false;
                                    $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'][j].deleteRecord =false;
                                }
                            }
                            else if($scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records']!=undefined)
                            {
                                $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].updateRecord =false;
                                $scope.parentAndChildRecordsList[i][$scope.selectedChildRelationName]['records'].deleteRecord =false;
                            }
                        }
                    }
                    $scope.showTable = true;
                    console.log($scope.showTable)
                }
                
                $scope.cancelUpdate = function(){
                    $scope.getParentChildRecords(false);
                    $scope.cancel();
                }
                
                $scope.changePageNumber = function(amount){
                    $scope.pageNumber = parseInt($scope.pageNumber) + parseInt(amount);
                    $scope.paginateTable();
                }
                
                $scope.setParentRecord = function(){
                    var parentId = $scope.newChildRecord[$scope.childToParentFieldName.trim()] ; 
                    for(var i=0;i<$scope.referenceArray.length;i++)
                    {
                        for(var j=0;j<$scope.referenceArray[i].values.length;j++)
                        {
                            if($scope.referenceArray[i].values[j].Id == parentId)
                            {
                                $scope.parentRecordName = $scope.referenceArray[i].values[j].Name;
                                break;
                            }
                        }
                    }
                }

            });
            
            //Directives
            
            //Field Selection Directives
            
            angular.module("DataTableApp").directive("fieldsTree",function(){
                return {
                    template:'<div class="panel-heading"><h1 class="panel-title">{{objectName}}</h1></div><div class="panel-body"><span ng-repeat="field in fields" style="padding-left:3%;" ng-show="!massUpdateRecords || (updateable(field) && !unique(field))" ><input ng-click="displayTableButton();" ng-show="!massUpdateRecords" type="checkbox" ng-model="field.selected"/><input ng-show="massUpdateRecords" type="checkbox" ng-model="field.massUpdate"/> {{field.fieldDetail.label}}&nbsp;<br/></span><hr ng-show="massUpdateRecords"/><table width="100%" ng-show="massUpdateRecords"><tr><td width="50%"><button ng-click="instantiateNewRecord(\'parent\',null);fieldsSelectedForMassUpdate=true;" ng-show="setValuesButtonValidate(\'parent\');">Set Values</button></td><td width="50%"><button ng-click="cancel();">Cancel</button></td></tr></table></div>',
                    restrict:'E'
                };
            });
            
            angular.module("DataTableApp").directive("relationTree",function(){
                return {
                    template:'<div class="panel-heading"><h1 class="panel-title">{{objectName}} RelatedList</h1></div><div class="panel-body"><span ng-repeat="childRelation in ChildRelationShips" style="padding-left:3%;" ng-show="!!childRelation.ChildRelationshipDetail.relationshipName"><input type="checkbox" ng-click="getSelectedRelatedListFields(childRelation.ChildRelationshipDetail.relationshipName);displayTableButton();"   ng-model="childRelation.selected"/> {{childRelation.ChildRelationshipDetail.relationshipName}}&nbsp;<br/></span></div>',
                    restrict:'E'
                };
            });
            
            angular.module("DataTableApp").directive("childFieldsTree",function(){
                return {
                    template:'<div class="panel-heading"><h1 class="panel-title">{{selectedChildDetails.label}}</h1></div><div class="panel-body"><span ng-repeat="field in ChildRelationShipFields" style="padding-left:3%;" ng-show="!massUpdateRecords || (updateable(field) && !unique(field))"><input ng-click="displayTableButton();" ng-show="!massUpdateRecords" type="checkbox" ng-model="field.selected"/><input ng-show="massUpdateRecords" type="checkbox" ng-model="field.massUpdate"/> {{field.fieldDetail.label}}&nbsp;<br/></span><hr ng-show="massUpdateRecords"/><table width="100%" ng-show="massUpdateRecords"><tr><td width="50%"><button ng-click="instantiateNewRecord(\'child\',null);fieldsSelectedForMassUpdate=true;" ng-show="setValuesButtonValidate(\'child\');">Set Values</button></td><td width="50%"><button ng-click="cancel();">Cancel</button></td></tr></table></div>',
                    restrict:'E'
                };
            });
            
            //Input and Output field related Directives
            
            angular.module("DataTableApp").directive("inputField",function($compile){
                return {
                    template:'<span ng-switch on="type" >'+
                    		'<span ng-switch-when="date"><input ng-class={required:required(field)} type="datetime-local" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                            '<span ng-switch-when="datetime"><input ng-class={required:required(field)} type="datetime-local" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                            '<span ng-switch-when="currency"><input ng-class={required:required(field)} type="currency" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                    		'<span ng-switch-when="int"><input ng-class={required:required(field)} min="1" type="number" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                            '<span ng-switch-when="number"><input ng-class={required:required(field)} min="1" type="number" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                            '<span ng-switch-when="double"><input ng-class={required:required(field)} min="0.01" type="number" ng-model="value[field.fieldDetail.name]" step="any" id="inputValue" /></span>'+
                            '<span ng-switch-when="id"><input ng-class={required:required(field)} type="text" pattern=".{15,18}" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                            '<span ng-switch-when="phone"><input ng-class={required:required(field)} type="phone" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                            '<span ng-switch-when="url"><input ng-class={required:required(field)} type="url" ng-model="value[field.fieldDetail.name]" id="inputValue" /></span>'+
                            '<span ng-switch-when="picklist"><select ng-class={required:required(field)} ng-model="value[field.fieldDetail.name]" id="inputValue"><option ng-repeat="option in picklistvalues" ng-show="option.active" ng-bind="option.label">{{option.label}}</option></select></span>'+
                            '<span ng-switch-when="email"><input ng-class={required:required(field)} type="email" ng-model="value[field.fieldDetail.name]" id="inputValue"/></span>'+
                            '<span ng-switch-when="reference"><look-up record="value" references="references" field="field" type="referenceto"></look-up></span>'+
                            '<span ng-switch-when="boolean"><input ng-class={required:required(field)} ng-model="value[field.fieldDetail.name]"  type="checkbox"  id="inputValue" /></span>'+ 
                            '<span ng-switch-when="textarea"><textarea ng-class={required:required(field)} id="inputValue" ng-model="value[field.fieldDetail.name]"></textarea></span>'+	
                    		'<span ng-switch-when="address"><textarea ng-class={required:required(field)} id="inputValue" ng-model="value[field.fieldDetail.name]"></textarea></span>'+	
                    		'<span ng-switch-when="text"><input type="text" ng-class={required:required(field)}  ng-model="value[field.fieldDetail.name]" id="inputValue"/></span>'+
                    		'<span ng-switch-when="text"><input type="string" ng-class={required:required(field)} ng-model="value[field.fieldDetail.name]" id="inputValue"/></span>'+
                            '<span ng-switch-default ><input type="text" ng-class={required:required(field)} ng-model="value[field.fieldDetail.name]" id="inputValue"/></span>'+
                        '</span>',
                    scope:{
                        type:'=',
                        value: '=',
                        picklistvalues: '=',
                        referenceto: '=',
                        field: '=',
                        references: '='
                        },
                    restrict:'E',
                    link:function(scope,element)
                    {
                        if(scope.value != null || scope.value != undefined)
                        {
                            if(scope.type=='datetime')
                            {
                                if(scope.value[scope.field.fieldDetail.name]!=null || scope.value[scope.field.fieldDetail.name]!=undefined)
                                {
                                    var dateTime = scope.value[scope.field.fieldDetail.name];
                                    dateTime = dateTime.replace('Z','').split('T');
                                    var date = dateTime[0].split('-');
                                    var time = dateTime[1].split(':');
                                    var seconds = time[2].split('.');
                                    scope.value = new Date(date[0],date[1],date[2],time[0],time[1],seconds[0],seconds[1]);
                                }
                                else
                                {
                                    scope.value = new Date();
                                }
                                
                            }
                            else if(scope.type=='date')
                            {
                                if(scope.value[scope.field.fieldDetail.name]!=null || scope.value[scope.field.fieldDetail.name]!=undefined)
                                {
                                    var dateTime = scope.value[scope.field.fieldDetail.name];
                                    dateTime = dateTime.replace('Z','').split('T');
                                    var date = dateTime[0].split('-');
                                    scope.value[scope.field.fieldDetail.name] = new Date(date[0],date[1],date[2],0,0,0,0);
                                }
                                else
                                {
                                    scope.value[scope.field.fieldDetail.name] = new Date();
                                }
                                
                            }
                        }
                        
                        
                        scope.required = function(field)
                        {
                            if(field.fieldDetail.nillable=='true')
                                return false;
                            return true;
                        }
                    }
                };
            });
            
            angular.module("DataTableApp").directive("lookUp",function(){
            	return{
                    scope:{
                     type: '=',
                        record : '=',
                        field : '=',
                        references : '='
                    },
                    template :'<span>'+
                    '<input type="text" ng-class={required:required(field)} ng-change="updateValues();" ng-model="searchText" id="inputValue"/>'+
                    '<div class="lookupMode" ng-show="autoComplete" style="z-index:3;display:block;position:absolute;background-color:white;width:234px;min-height:0px;border-top:solid black 1px;">'+
                    '<ul style="list-style-type:none;padding-left:initial;display:inline-block;">'+
                    '<li ng-repeat="recordValues in lookupvalues" value="{{recordValues[\'Id\']}}" ng-click="selectedValue(recordValues);" style="margin-left:1px;padding-left:4px;padding-right:4px;width:234px;border-bottom: solid black 1px;border-left: solid black 1px;border-right: solid black 1px;" ng-class="{focussed:hover}" ng-mouseenter="hover = true" ng-mouseleave="hover = false">'+
                    '{{recordValues["Name"]}}'+
                    '</li>'+
                    '</ul>'+
                    '</div>'+
                    '</span>',
                    restrict :'E',
                    link: function (scope, element,attrs) {
                        scope.searchText = ' ';
                        scope.autoComplete = false;
                        scope.typeValues = new Array();
                        
                        for(var i=0;i<scope.references.length;i++)
                        {
                            if(scope.references[i].type == scope.type)
                            {
                                scope.typeValues = scope.references[i].values;
                            }
                        }
                        
                        scope.updateValues = function()
                        {
                            scope.lookupvalues = new Array();
                            var count = 0;
                            for(var i=0;i<scope.typeValues.length && count<5;i++)
                            {
                                if(scope.typeValues[i].Name.toLowerCase().indexOf(scope.searchText.toLowerCase()) >= 0)
                                {
                                    count++;
                                    scope.lookupvalues.push(scope.typeValues[i]);
                                }
                            }
                            if(count<5)
                            {
                                var dbValues =  sforce.connection.query("select id, name from "+scope.type+" where name like '%"+scope.searchText+"%' order by name asc limit 5");
                                if(Array.isArray(dbValues['records']))
                                {
                                    scope.lookupvalues = dbValues['records'];
                                }
                                else
                                {
                                    var arrayList = new Array();
                                    arrayList.push(dbValues['records']);
                                    scope.lookupvalues = arrayList;
                                }
                            }
                            scope.autoComplete = true;
                        }
                        
                        scope.selectedValue = function(records)
                        {
                            scope.searchText = records['Name'];
                            scope.record[scope.field.fieldDetail.name] = records['Id'];
                            scope.autoComplete = false;
                        }
                        
                        scope.required = function(field)
                        {
                            if(field.fieldDetail.nillable=='true')
                                return false;
                            return true;
                        }
                    }
                };
            });
            
            angular.module("DataTableApp").directive("outputField",function($compile){
                return {
                    template:'<span ng-switch on="type" >'+
                            '<span ng-switch-when="reference"><hyperlink record="value" references="references" field="field" type="referenceto"></hyperlink></span>'+
                            
                    		'<span ng-switch-default ><output ng-show="(val!=undefined && val!=null && val!=\'\') || value.updateRecord" type="text" ng-bind="value[field.fieldDetail.name]" id="outputValue"/><output ng-show="(val==undefined || val==null || val==\'\') && !value.updateRecord" type="text" id="outputValue"/></span>'+
                        '</span>',
                    scope:{
                        type:'=',
                        value: '=',
                        referenceto: '=',
                        field: '=',
                        references: '='
                        },
                    restrict:'E',
                    link:function(scope,element)
                    {
                        scope.val =  scope.value[scope.field.fieldDetail.name];
                    }
                };
                
            });
            
            angular.module("DataTableApp").directive("hyperlink",function($compile, $window){
                return {
                    template:'<a id="outputValue" href="/{{Id}}">{{Name}}</a>',
                    scope:{
                        type:'=',
                        record: '=',
                        field: '=',
                        references: '='
                        },
                    restrict:'E',
                    link:function(scope,element)
                    {
                        scope.Id = scope.record[scope.field.fieldDetail.name];
                        scope.Name = '';
                        for(var i=0;i<scope.references.length;i++)
                        {
                            if(scope.references[i].type == scope.type)
                            {
                                for(var j=0;j<scope.references[i].values.length;j++)
                                {
                                    if(scope.references[i].values[j].Id == scope.Id )
                                    {
                                        scope.Name = scope.references[i].values[j].Name;
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                    }
                };
            }); 
            
            //Sidebar Directives
            
            angular.module("DataTableApp").directive("parentToolBar",function(){
                return {
                    template:'<div class="panel-heading"  ng-click="showParentFields=!showParentFields;"><h1 class="panel-title">{{objectName}}</h1></div><div class="panel-body"><span ng-repeat="field in fields" ng-show="field.selected"   style="padding-left:3%;"><input type="checkbox" ng-model="field.showField"/> {{field.fieldDetail.label}}&nbsp;<br/></span></div>',
                    restrict:'E'
                };
            });
            
            angular.module("DataTableApp").directive("childToolBar",function(){
                return {
                    template:'<div class="panel-heading"  ng-click="showChildFields=!showChildFields;"><h1 class="panel-title">{{selectedChildDetails.label}}</h1></div><div class="panel-body"><span ng-repeat="field in ChildRelationShipFields" ng-show="field.selected"   style="padding-left:3%;"><input type="checkbox" ng-model="field.showField"/> {{field.fieldDetail.label}}&nbsp;<br/></span></div>',
                    restrict:'E'
                };
            }); 
                        
            angular.module("DataTableApp").directive("logs",function(){
                return {
                    template:'<div class="panel-heading" ng-click="showLogs=!showLogs;"><h1 class="panel-title">Logs</h1></div><div class="panel-body"><filterlogs/><hr/><table><tr ng-click="logOrder=!logOrder;"><th width="35%">Time</th><th width="20%">Operation&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>Message</th></tr><tr ng-repeat="log in logs | orderBy : \'time\' :logOrder" ng-show="logsFilter(log.operation);"><td width="35%">{{log.time}}</td><td width="20%">{{log.operation}}</td><td>{{log.message}}</td></tr></table></div>',
                    restrict:'E'
                };
            });

            angular.module("DataTableApp").directive("filterlogs",function(){
                return {
                    template:'<table><tr><td width="20%">Retrieve&nbsp;&nbsp;<input type="checkbox" ng-model="captureQuery"/></td><td width="20%">Insert&nbsp;&nbsp;<input type="checkbox" ng-model="captureInsert"/></td><td width="20%">Update&nbsp;&nbsp;<input type="checkbox" ng-model="captureUpdate"/></td><td width="20%">Delete&nbsp;&nbsp;<input type="checkbox" ng-model="captureDelete"/></td><td width="20%">Mass Update&nbsp;&nbsp;<input type="checkbox" ng-model="captureMassUpdate"/></td></tr></table>',
                    restrict:'E'
                };
            });
            
            angular.module("DataTableApp").directive("errors",function(){
                return {
                    template:'<div class="panel-heading" ng-click="showErrors=!showErrors;"><h1 class="panel-title">Errors</h1></div><div class="panel-body"><filtererrors/><hr/><table><tr ng-click="errorOrder=!errorOrder;"><th width="35%">Time</th><th width="20%">Operation&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th >Message</th></tr><tr ng-repeat="error in errors | orderBy : \'time\' :errorOrder" ng-show="errorsFilter(error.operation);"><td>{{error.time}}</td><td>{{error.operation}}</td><td>{{error.message}}</td></tr></table></div>',
                    restrict:'E'
                };
            });
            
            angular.module("DataTableApp").directive("filtererrors",function(){
                return {
                    template:'<table><tr><td width="20%">Retrieve&nbsp;&nbsp;<input type="checkbox" ng-model="captureQueryError"/></td><td width="20%">Insert&nbsp;&nbsp;<input type="checkbox" ng-model="captureInsertError"/></td><td width="20%">Update&nbsp;&nbsp;<input type="checkbox" ng-model="captureUpdateError"/></td><td width="20%">Delete&nbsp;&nbsp;<input type="checkbox" ng-model="captureDeleteError"/></td><td width="20%">Mass Update&nbsp;&nbsp;<input type="checkbox" ng-model="captureMassUpdateError"/></td></tr></table>',
                    restrict:'E'
                };
            });
            
            //New Object Creation Directives
            
            angular.module("DataTableApp").directive("newParentObject",function(){
                return {
                    template:'<div class="panel-heading">'+
                    '<h1 class="panel-title">{{objectName}}</h1></div>'+
                    '<div class="panel-body">'+
                    '<table class="table table-striped table-hover success">'+
                    '<tr ng-repeat="field in fields" style="padding-left:3%;" ng-show="(updateable(field) && !massUpdateRecords) || field.massUpdate">'+
                    '<td>{{field.fieldDetail.label}} &nbsp;</td>'+
                    '<td>'+ 
                    '<input-field references="referenceArray" field="field" type="field.fieldDetail.type" value="newParentRecord" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</td>'+
                    '</tr>'+ 
                    '<tr >'+
                    '<td><button class="createRecordButton" ng-click="validate(\'parent\');"  type="parent"  ng-show="!massUpdateRecords">Create {{objectName}}</button><button ng-click="updateRecordsMethod();"  ng-show="massUpdateRecords">Update Records</button></td>'+
                    '<td>'+ 
                    '<button ng-click="cancel();">Cancel</button>'+
                    '</td>'+
                    '</tr>'+
                    '</table>'+
                    '</div>',
                    restrict:'E'
                };
            });
            
            angular.module("DataTableApp").directive("newChildObject",function(){
                return {
                    template:'<div class="panel-heading">'+
                    '<h1 class="panel-title">{{selectedChildDetails.label}}</h1></div>'+
                    '<div class="panel-body">'+
                    '<table class="table table-striped table-hover success">'+
                    '<tr ng-repeat="field in ChildRelationShipFields" style="padding-left:3%;" ng-show="(updateable(field) && !massUpdateRecords) || field.massUpdate">'+
                    '<td>{{field.fieldDetail.label}} &nbsp;</td>'+
                    '<td ng-show="field.fieldDetail.name!=childToParentFieldName || massUpdateRecords">'+ 
                    '<input-field references="referenceArray" field="field" type="field.fieldDetail.type" value="newChildRecord" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</td>'+
                    '<td ng-show="field.fieldDetail.name==childToParentFieldName && !massUpdateRecords">'+ 
                    '<a href="/{{newChildRecord[field.fieldDetail.name]}}">{{parentRecordName}} </a>'+
                    '</td>'+
                    '</tr>'+
                    '<tr >'+
                    '<td><button  class="createRecordButton" ng-click="validate(\'child\');"  type="child" ng-show="!massUpdateRecords">Create {{selectedChildDetails.label}}</button><button ng-click="updateRecordsMethod();"  ng-show="massUpdateRecords">Update Records</button></td>'+
                    '<td>'+ 
                    '<button ng-click="cancel();">Cancel</button>'+
                    '</td>'+
                    '</tr>'+
                    '</table>'+
                    '</div>',
                    restrict:'E'
                };
            });
            
            //Table Directives
            
            angular.module("DataTableApp").directive("parentTable",function(){
            return {
                    template:'<table><tr><td width="50%">Search: &nbsp;&nbsp;&nbsp;<input ng-model="searchText" placeholder={{objectName}} >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>'+
                    '<td ng-show="!massUpdateRecords && !updateRecords && !deleteRecords"><button ng-click="instantiateNewRecord(\'parent\',null);">Create New {{objectName}}</button></td></tr></table><hr/>'+
                    '<table class="table table-striped table-hover" border="1" >'+
                    '<tr style="background-color: #428bca;border-color: #000000;" >'+
                    '<th  ng-repeat="field in fields"  ng-show="field.selected  && field.showField" ng-click="order(field.fieldDetail.name);sortSelectedOrReveresed(field.fieldDetail.label,fields);" style="background-color: #428bca;border-color: #000000;width:20%;color:#ffffff;">'+
                    '{{field.fieldDetail.label}}&nbsp;&nbsp;&nbsp;<span ng-show="field.sortSelected">&#x25B2;</span><span ng-show="field.sortReverse">&#x25BC;</span>'+
                    '</th>'+
                    '<th ng-show="massUpdateRecords && massUpdateParentChildSelection == \'Parent\'" style="background-color: #428bca;border-color: #000000;width:20%;color:#ffffff;">Select</th>'+
                    '<th ng-show="deleteRecords" style="background-color: #428bca;border-color: #000000;width:20%;color:#ffffff;">Select</th>'+
                    '</tr>'+
                    '<tr class="info" ng-repeat="record in recordsInDisplay | search:searchText | orderBy:OrderByfieldName:isReverseOrdered">'+
                    '<td class="dataHolder" ng-repeat="field in fields" ng-show="field.selected && field.showField" style="width:20%;" ng-dblclick="setForUpdate(field,record);">'+
                    '<span class="viewMode" updateable="{{field.fieldDetail.updateable}}" >'+
                     '<output-field  references="referenceArray"  field="field" type="field.fieldDetail.type" value="record" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</span>'+
                    '<span class="editMode" style="display:none;" >'+
                    '<input-field  references="referenceArray"  field="field" type="field.fieldDetail.type" value="record" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</span>'+ 
                    '</td>'+
                    '<td ng-show="massUpdateRecords  && massUpdateParentChildSelection == \'Parent\'"><input type="checkbox" ng-click="showSelectedFieldsButtonValidate();" ng-model="record.updateRecord"></td>'+
                    '<td ng-show="deleteRecords"><input type="checkbox" ng-model="record.deleteRecord"></td>'+
                    '</tr>'+
                    '</table>',
                    restrict:'E',
                    link: function(scope, element, attrs)
                    { 
                    }
                };
            });
            
            angular.module("DataTableApp").directive("parentChildTable",function(){
                return {
                    template:'<table><tr><td width="50%">Search: &nbsp;&nbsp;&nbsp;<input ng-model="searchText" placeholder={{objectName}} >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>'+
                    '<td ng-show="!massUpdateRecords && !updateRecords && !deleteRecords"><button ng-click="instantiateNewRecord(\'parent\',null);">Create New {{objectName}}</button></td></tr></table><hr/>'+
                    '<table class="table table-striped table-hover" border="1" ng-repeat="record in recordsInDisplay | search:searchText | orderBy:OrderByfieldName:isReverseOrdered">'+
                    '<tr style="background-color: #428bca;border-color: #000000;" ng-show="(!collapseChild || $first)">'+
                    '<th  ng-repeat="field in fields"  ng-show="field.selected  && field.showField" ng-click="order(field.fieldDetail.name);sortSelectedOrReveresed(field.fieldDetail.label,fields);" style="background-color: #428bca;border-color: #000000;width:20%;color:#ffffff;">'+
                    '{{field.fieldDetail.label}}&nbsp;&nbsp;&nbsp;<span ng-show="field.sortSelected">&#x25B2;</span><span ng-show="field.sortReverse">&#x25BC;</span>'+
                    '</th>'+
                    '<th ng-show="massUpdateRecords && massUpdateParentChildSelection == \'Parent\'" style="background-color: #428bca;border-color: #000000;width:20%;color:#ffffff;">Select</th>'+
                    '<th ng-show="deleteRecords" style="background-color: #428bca;border-color: #000000;width:20%;color:#ffffff;">Select</th>'+
                    '</tr>'+
                    '<tr class="info">'+
                    '<td class="dataHolder" ng-repeat="field in fields" ng-show="field.selected && field.showField" style="width:20%;" ng-dblclick="setForUpdate(field,record);">'+
                    '<span class="viewMode" updateable="{{field.fieldDetail.updateable}}" >'+
                     '<output-field  references="referenceArray"  field="field" type="field.fieldDetail.type" value="record" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</span>'+
                    '<span class="editMode" style="display:none;" >'+
                    '<input-field  references="referenceArray"  field="field" type="field.fieldDetail.type" value="record" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</span>'+ 
                    '</td>'+
                    '<td ng-show="massUpdateRecords  && massUpdateParentChildSelection == \'Parent\'"><input type="checkbox" ng-click="showSelectedFieldsButtonValidate();" ng-model="record.updateRecord"></td>'+
                    '<td ng-show="deleteRecords"><input type="checkbox" ng-model="record.deleteRecord"></td>'+
                    '</tr>'+
                   				 '<tr ng-show="!collapseChild">'+
                    				'<td colspan="1000">'+
                                        '<table class="table table-striped table-hover success">'+
                    						'<tr>'+
                    '<td><b><span class="collapseIcon">[+]&nbsp;&nbsp;</span>{{selectedChildRelationName}}({{getChildRecords(record).length}})</b></td>'+
                    							'<td><input ng-model="searchChildText" placeholder={{selectedChildRelationName}} ng-show="getChildRecords(record).length>0"/></td>'+
                    '<td ng-show="!massUpdateRecords && !updateRecords && !deleteRecords"><button ng-click="instantiateNewRecord(\'child\',record.Id);">Create New {{selectedChildDetails.name}}</button></td>'+
                    						'</tr>'+
                                            '<tbody class="childBody">'+
                                            '<tr style="width:20%;background-color: #15A14C;border-color: #000000;color:#ffffff;">'+
                    
                                                '<th ng-repeat="field in ChildRelationShipFields" ng-show="field.selected && field.showField" ng-click="childOrder(field.fieldDetail.name);sortSelectedOrReveresed(field.fieldDetail.label,ChildRelationShipFields);" style="width:20%;background-color: #15A14C;border-color: #000000;color:#ffffff;">'+
                                                        '{{field.fieldDetail.label}}&nbsp;&nbsp;&nbsp;<span ng-show="field.sortSelected">&#x25B2;</span><span ng-show="field.sortReverse">&#x25BC;</span>'+
                                                '</th>'+
                    '<th ng-show="massUpdateRecords  && massUpdateParentChildSelection == \'Child\'" style="width:20%;background-color: #15A14C;border-color: #000000;color:#ffffff;">Select</th>'+
                    '<th ng-show="deleteRecords" style="width:20%;background-color: #15A14C;border-color: #000000;color:#ffffff;">Select</th>'+
                                            '</tr>'+
                                            '<tr class="success" ng-repeat="childRecord in getChildRecords(record) | search:searchChildText | orderBy:childOrderByfieldName:childIsReverseOrdered">'+
                                                
                    '<td ng-repeat="field in ChildRelationShipFields" class="dataHolder" ng-dblclick="setForUpdate(field,childRecord);" ng-show="field.selected && field.showField" style="width:20%;">'+	
                    
                    '<span class="viewMode" updateable="{{field.fieldDetail.updateable}}" >'+
                    '<output-field  references="referenceArray"  field="field" type="field.fieldDetail.type" value="childRecord" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</span>'+
                    '<span class="editMode" style="display:none;" >'+
                    '<input-field references="referenceArray"  field="field" type="field.fieldDetail.type" value="childRecord" picklistvalues="field.fieldDetail.picklistValues" referenceto="field.fieldDetail.referenceTo" />'+
                    '</span>'+
                                                '</td>'+
                    '<td ng-show="massUpdateRecords   && massUpdateParentChildSelection == \'Child\'"><input ng-click="showSelectedFieldsButtonValidate();" type="checkbox" ng-model="childRecord.updateRecord"></td>'+
                    '<td ng-show="deleteRecords"><input type="checkbox" ng-model="childRecord.deleteRecord"></td>'+
                                            '</tr>'+
                                            '</tbody>'+
                                        '</table>'+
                    				'</td>'+
                    			'</tr>'+
                    '</table>',
                    restrict:'E',
                    link: function(scope, element, attrs)
                    { 
                    }
                };
            });
           
            //Filters
            
            angular.module("DataTableApp").filter('search', function(){
                return function(records,word) 
                {
                    var filtered = new Array();
                    if(word!='' && word!=undefined)
                    {
                        for(var i=0;i<records.length;i++)
                        {
                            if(records[i].toString().toLowerCase().indexOf(word.toLowerCase())>0)
                            {
                                filtered.push(records[i]);
                            }
                        }
                        return filtered;
                    }
                    return records;
                };
            });