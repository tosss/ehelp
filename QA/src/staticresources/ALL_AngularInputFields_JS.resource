/*********************************************************
* Author: Sanjay.Ghanathey@cdk.com
* Description: Salesforce Datatypes replication in AngularJS
* Test Class: NA
* 
* History:
* 2015-07-28 	Sanjay Ghanathey		Created
* 2015-07-29 	Sanjay Ghanathey		Added lookup directive
* 2015-07-29 	Sanjay Ghanathey		Added filter
* 2015-08-05 	Sanjay Ghanathey		Added picklist directive
* 2015-08-28 	Sanjay Ghanathey		Added date directive
* 2015-09-16 	Sanjay Ghanathey		Added multipicklist directive
* ********************************************************* */
var application = angular.module('inputFields',['ngAnimate','ui.bootstrap','angularMoment','ui.bootstrap.datetimepicker','ui.multiselect']);
/*var __salesforceBaseUrl;
window.onload = function(){
    var temp = document.getElementById('doTimeoutLocation');
    __salesforceBaseUrl = temp.value.substring(0,temp.value.indexOf('?'));
    if(typeof(__salesforceBaseUrl) == 'undefined' && __salesforceBaseUrl == null)
    {
        alert('Invalid __salesforceBaseUrl');
    }
}*/
/* ****************************************
* Author: Sanjay Ghanathey
* Description: To filter the queried records instead 
*              of calling remote action again
* **************************************** */
application.filter('lookupFilter', function($filter) {
    return function(data,value,displayName) {
        var filteredList = [];                
        angular.forEach(JSON.parse(data), function(o) {  
            if(angular.lowercase(o[displayName]).indexOf(angular.lowercase(value)) > -1)
            {
                filteredList.push(o);
            }
            
        });
        return filteredList;
    }
});

/* ****************************************
* Author: Sanjay Ghanathey
* Description: Directive to check what type of 
*              input field is being referred
* **************************************** */
application.directive('type',function($compile) {            
    return {                 
        controller: ['$scope', '$q','$http','$filter', function($scope, $q,$http,$filter) {  
            //test            
			$scope.sObjects = [];//ragashalini.koka@cdk.com - added
			$scope.setDateVal = 0;//ragashalini.koka@cdk.com - added
			//console.log('setDateVal value is' + $scope.setDateVal);
			//console.log('selected value ' + $scope.selected);
			
            $scope.dateData = function(){
                $scope.today = function() {
				if($scope.setDateVal == 0) {
                    $scope.selected = new Date();
					}
					else if($scope.setDateVal == 'empty') {
						$scope.selected = '';
					}
					else {
						 $scope.selected = new Date($scope.setDateVal);
					}
                    $scope.selectedDate = new Date();
                };
                $scope.today();
                
                $scope.clear = function () {
                    $scope.selected = null;
                };
                
                // Disable weekend selection
                /*$scope.disabled = function(date, mode) {
                    return ( mode === 'day' && ( date.getDay() === 0 || date.getDay() === 6 ) );
                };*/
                
                $scope.toggleMin = function() {
                    $scope.minDate = $scope.minDate ? null : new Date();
                };
                $scope.toggleMin();
                
                $scope.open = function($event) {
                    $scope.status.opened = true;
                };
                
                $scope.dateOptions = {
                    formatYear: 'yy',
                    startingDay: 1
                };
                
                $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
                $scope.format = $scope.formats[0];
                
                $scope.status = {
                    opened: false
                };
                
                var tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                var afterTomorrow = new Date();
                afterTomorrow.setDate(tomorrow.getDate() + 2);
                $scope.events =
                    [
                    {
                        date: tomorrow,
                        status: 'full'
                    },
                    {
                        date: afterTomorrow,
                        status: 'partially'
                    }
                ];
                
                $scope.getDayClass = function(date, mode) {
                    if (mode === 'day') {
                        var dayToCheck = new Date(date).setHours(0,0,0,0);
                        
                        for (var i=0;i<$scope.events.length;i++){
                            var currentDay = new Date($scope.events[i].date).setHours(0,0,0,0);
                            
                            if (dayToCheck === currentDay) {
                                return $scope.events[i].status;
                            }
                        }
                    }
                    
                    return '';
                };
                
                return $scope;
            };
            //test
            
            //Sanjay.Ghanathey@cdk.com 05-Aug-2015 Added picklist feature
            $scope.picklist = function(objectName,columnName){                     
                var deferred = $q.defer();                    
                setTimeout(function() {
                    deferred.notify('About to make a remote call.');                        
                    Visualforce.remoting.Manager.invokeAction(
                        'ALL_AngularInputFields_Controller.getPicklistValues',
                        objectName,columnName,
                        function(result, event){     
                            //console.log('remoteaction call made');
                            $scope.$apply(function () {
                                $scope.options = result;
                                if(typeof $scope.picklistMap != 'undefined') {
                                    $scope.picklistMap[objectName + '-' + columnName] = result;
                                }
                            });
                        }                         
                    ); }, 500);
                return deferred.promise;
            };            
            $scope.assignValuesToPicklistOptions = function(options) {
               // console.log('assigned vales without call');
                $scope.options = options;
            }
            $scope.getLookup = function(val){  
                $scope.sessionId = __sessionId;                 
                if(val.length<4)
                {
                    $scope.httpCallout = true;
                }
                else
                {
                    $scope.httpCallout = false;
                }
                
                if($scope.httpCallout)
                {    
					//console.log('http callout is true');
                    var deferred = $q.defer();                    
                    setTimeout(function() {
                        deferred.notify('About to make a remote call.');                                                   
                        var jsonItem = {};
                        jsonItem["objectName"] = $scope.ngObject;
                        jsonItem["columnNames"] = $scope.ngColumnNames;
                        jsonItem["searchString"] = val;
                        jsonItem["displayName"] = $scope.ngDisplayName;
                        //ragashalini.koka@cdk.com - commented Rest call and added Remote action call
                       /* var req = {                                        
                            method: 'POST',                                
                            headers:{                                           
                                'Authorization':'OAuth '+$scope.sessionId,
                                'Content-Type': 'application/json',                                            
                                'SalesforceProxy-Endpoint':__salesforceBaseUrl+'/services/apexrest/datatable/'
                            },                                                                                
                            url: '/services/proxy',
                            data: JSON.stringify(jsonItem)
                        }                            
                        
                        $http(req).success(
                            function(data, status, header, config){  
							//ragashalini.koka@cdk.com - added JSON.parse to $scope.sObjects 							
                                $scope.sObjects = JSON.parse(data);                                                                
                                deferred.resolve(JSON.parse(data));
                            }
                        ).error(
                            function(data, status, header, config ){
                            //    console.log('Error Fetching Data');
                             //   console.log(data, status, header, config);
                            }
                        );
                        
                    }, 1000);  */     
					
					
                    deferred.notify('About to make a remote call.');                        
                    Visualforce.remoting.Manager.invokeAction(
                        'ALL_AngularInputFields_Controller.retrieveLookupData',
                        jsonItem["objectName"],jsonItem["columnNames"],jsonItem["searchString"],
						jsonItem["displayName"],
                        function(result, event){                                                                   
                            if(event.status) {
								//console.log('inside event status');
								//console.log('fetched data for lookup' , JSON.parse(result));
								$scope.sObjects = JSON.parse(result);
								deferred.resolve(JSON.parse(result));
							}
							else {
								//console.log('fetched data for lookup failed');
								deferred.reject('Error Fetching Data');
							}
                        } , {escape: false,buffer: true}                        
                    );  }, 1000);


					
                    return  deferred.promise;   
                } // end of if
                else
                {
                    var deferred = $q.defer();
                    setTimeout(function() {
                        deferred.notify('About to make a remote call.');
                        var filteredResult = $filter('lookupFilter')($scope.sObjects,val,$scope.ngDisplayName);
                        deferred.resolve(filteredResult);
                    },1000);                    
                    return deferred.promise;
                }
            };
			//added method to display and store different values in lookahead
			$scope.formatDisplay = function(model) {
				//console.log('format Display' +  $scope.sObjects.length);
               for(var i = 0;i <  $scope.sObjects.length;i++) {
                	//console.log('id ' + $scope.sObjects[i]);
                    if(model ==  $scope.sObjects[i]['Id']) {
                    //    console.log('inside if format display');
                        return  $scope.sObjects[i][$scope.ngDisplayName];
                    }
                
                }
               // console.log("inside format display " + model);
            
            };
			//ragashalini.koka@cdk.com - added to display the field for given id 
			 $scope.getNameForId = function(recId,field,obj,calledFromLookup) {
            	//console.log(recId + field + obj + calledFromLookup);
                var deferred = $q.defer();                    
                setTimeout(function() {
                    deferred.notify('About to make a remote call.');                        
                    Visualforce.remoting.Manager.invokeAction(
                        'ALL_AngularInputFields_Controller.getNameForId',
                        recId,field,obj,
                        function(result, event){                                                                   
                            $scope.$apply(function () {
                                $scope.fieldDisplay = result; 
                              //  console.log('getNameForId' + result);
								if(calledFromLookup) {
									var defaultObj = {};
									defaultObj['Id'] = recId;
									defaultObj[field] = result;
									$scope.sObjects.push(defaultObj);
									 var html ='<span class="typeahead"><input type="text" style="display:inline;" ng-model="selected" placeholder="Start Typing" typeahead="sObj[\'Id\'] as sObj[ngDisplayName] for sObj in getLookup($viewValue)" typeahead-input-formatter="formatDisplay($model)" typeahead-loading="loading" typeahead-min-length="3" class="form-control ' + $scope.addNewClass + '"/><i style="display:inline;margin-left:-22px;" ng-class="{ \'fa fa-spinner fa-pulse\': loading == true }"></i></span>';
									 var e=angular.element(html);
							         $compile(e.contents())($scope);
								     $scope.iEle.replaceWith(e);
                                
								}
                                deferred.resolve(result); 
                            });
                        }                         
                    ); }, 500);
                return deferred.promise;
                
            
            };
           
			
        }],
        scope: {
            selected : '=?ngModel',
            picklistMap : '=?'
            
        },
        link: function(scope,iElement, iAttrs) {
            scope.ngObject = iAttrs.ngObject;
            scope.ngColumnNames = iAttrs.ngColumnnames;
            scope.ngDisplayName = iAttrs.ngDisplayname;
            if(iAttrs.type == 'lookup'){
				//ragashalini.koka@cdk.com - added if condition to work with tree grid app	
				scope.addNewClass = 'notReq';
				//ragashalini.koka@cdk.com - added if block 
				
			if(typeof iAttrs.isRequired != 'undefined') {
			
				if(iAttrs.isRequired == 'false') {
				
					scope.addNewClass = 'required';
				}
				
				
				
			}		
               var html ='<span class="typeahead"><input type="text" style="display:inline;" ng-model="selected" placeholder="Start Typing" typeahead="sObj[\'Id\'] as sObj[ngDisplayName] for sObj in getLookup($viewValue)" typeahead-input-formatter="formatDisplay($model)" typeahead-loading="loading" typeahead-min-length="3" class="form-control ' + scope.addNewClass + '"/><i style="display:inline;margin-left:-22px;" ng-class="{ \'fa fa-spinner fa-pulse\': loading == true }"></i></span>';
               var e=angular.element(html);
                if(iAttrs.app == 'TreeGrid' && typeof scope.selected != 'undefined' && iAttrs.ngDisplay != 'undefined') {
                    scope.iEle = iElement;
                    var defaultObj = {};
                    defaultObj['Id'] = scope.selected;
                    defaultObj[scope.ngDisplayName] =  iAttrs.ngDisplay;
                    scope.sObjects.push(defaultObj);
                    console.log('defaultObj' , defaultObj);
                    //scope.getNameForId(scope.selected,scope.ngDisplayName,scope.ngObject,true);
                    
                    
                }
              
                $compile(e.contents())(scope);
                
                iElement.replaceWith(e);
            }
			//ragashalini.koka@cdk.com - added to display the field for given id 
			else if(iAttrs.type == 'displayLookup') {
                //scope.getNameForId(iAttrs.text,iAttrs.display);
                var html ='<span>{{fieldDisplay}}</span>'; 
                var e=angular.element(html);
                e.on('load', scope.getNameForId(iAttrs.text,iAttrs.display,iAttrs.object,false));
                $compile(e.contents())(scope);
                iElement.replaceWith(e);
                
                
            }
            else if(iAttrs.type == 'picklist'){
				//ragashalini.koka@cdk.com - added if block 
				if(typeof iAttrs.display != 'undefined') {
					scope.selected=iAttrs.display;
					
				}
               
              
				var newClass = 'notReq';
				//ragashalini.koka@cdk.com - added if block 
				if(typeof iAttrs.isRequired != 'undefined') {
			
				if(iAttrs.isRequired == 'false') {
				
					newClass = 'required';
				}
				
				
				
			}	
              var keyForPicklistMap = scope.ngObject + '-' + scope.ngColumnNames;
				//ragashalini.koka@cdk.com - changed ng-options attribute 
                var html ='<ng-include ng-onload="picklist(ngObject,ngColumnNames)"><select class="form-control ' + newClass + '" ng-model="selected" ng-options="sObj.value as sObj.label for sObj in options"><option value="">-- Options --</option></select></ng-include>';
                var e=angular.element(html);
               
                if(typeof scope.picklistMap === 'undefined' || typeof scope.picklistMap[keyForPicklistMap] === 'undefined' ) {
                    e.on('load', scope.picklist(scope.ngObject,scope.ngColumnNames));
                    
                }
                
                else {
                    e.on('load', scope.assignValuesToPicklistOptions(scope.picklistMap[keyForPicklistMap]));
                      
                 }
                
                $compile(e.contents())(scope);
                iElement.replaceWith(e);    
            }
			else if(iAttrs.type == 'date' || iAttrs.type == 'customDate'){ 
                
			//ragashalini.koka@cdk.com - added minView attribute to differentiate html date and datetime shalini
				var minView = 'hour';
				
				if(typeof iAttrs.minView != 'undefined') {
					minView = iAttrs.minView;
				}			
				//ragashalini.koka@cdk.com - added date-value to set the date to the passed value instead of the current date 
				if(typeof iAttrs.dateValue != 'undefined') {
                  // console.log(iAttrs.dateValue);
				   if(iAttrs.dateValue == "" || iAttrs.dateValue == null) {
						scope.setDateVal = 'empty';
						//console.log('value is empty');
				   }
				   else {
					scope.setDateVal  = new Date(iAttrs.dateValue);
					//console.log('date val ' + scope.setDateVal); 
                    }
				}
				
				var newClass = 'notReq';
				//ragashalini.koka@cdk.com - added if block 
				if(typeof iAttrs.isRequired != 'undefined') {
			
				if(iAttrs.isRequired == 'false') {
				
					newClass = 'required';
				}
				
				
				
			}	
			//console.log('time zone' + iAttrs.timeZone);
				//ragashalini.koka@cdk.com - removed href attribute and added attribute directive format-date 
				//ragashalini.koka@cdk.com - changed data-datetimepicker-config dropdownselector attribute from 'dropdown2' to this
                var html ='<div class="dropdown"><a class="dropdown-toggle" id="dropdown2" role="button" data-toggle="dropdown"><div class="input-group"><input type="text"  class="form-control ' + newClass + '" ng-model="selected" time-zone="' + iAttrs.timeZone  + '" format-date view="'+ minView +'"/><span class="input-group-addon"><i class="glyphicon glyphicon-calendar"></i></span></div></a><ul class="dropdown-menu" role="menu" aria-labelledby="dLabel"><datetimepicker data-ng-model="selected" data-datetimepicker-config="{ dropdownSelector: this,minView: \'' + minView + '\'}"/></ul></div>';
                var e=angular.element(html);                
                $compile(e.contents())(scope);
                e.on('load', scope.dateData());                
                iElement.replaceWith(e);    
            }
                else if(iAttrs.type == 'multipicklist')
                {
				var newClass = 'notReq';
				//ragashalini.koka@cdk.com - added if block 
				if(typeof iAttrs.isRequired != 'undefined') {
			
				if(iAttrs.isRequired == 'false') {
				
					newClass = 'required';
				}
				
				
				
			}	
					//ragashalini.koka@cdk.com - changed ng-options attribute 
                    var html='<ng-include ng-onload="picklist(ngObject,ngColumnNames)"><multiselect multiple="true" ng-model="selected" options="sObj.value as sObj.label for sObj in options" class="input-xlarge ' + newClass + '" style="border-left:none !important"></multiselect></ng-include>';
                    var e=angular.element(html);
                    var keyForPicklistMap = scope.ngObject + '-' + scope.ngColumnNames;
                    
                    if(typeof scope.picklistMap === 'undefined' || typeof scope.picklistMap[keyForPicklistMap] === 'undefined' ) {
                        e.on('load', scope.picklist(scope.ngObject,scope.ngColumnNames));
                        
                    }
                    
                    else {
                        e.on('load', scope.assignValuesToPicklistOptions(scope.picklistMap[keyForPicklistMap]));
                        
                    }
                    $compile(e.contents())(scope);
                    iElement.replaceWith(e);
                }
        },
        restrict: 'A'
    }
});
application.directive('formatDate',function(){
	return {
		restrict:'A',
		require:'ngModel',
		 link: function (scope, element, attrs, ngModel) {
      
      //format text going to user (model to view)
      ngModel.$formatters.push(function(value) {
		  
		 // console.log('new directive'  + value);
		  var dateVal = new Date(value);
		 // console.log('inside new directive' + dateVal);
		  if(dateVal == 'Invalid Date') {
			  dateVal = '';
		  }
		  else {
			  var dateFormat = '';
			  //console.log('view attribute' + attrs.view);
			  if(attrs.view != "day") {
				  
				  var options = {hour: '2-digit', minute: '2-digit' };
				  if(attrs.timeZone != 'undefined') {
					  options['timeZone'] = attrs.timeZone;
				  }
				dateFormat = dateVal.toLocaleTimeString([], options);
			  }
			  dateVal = dateVal.toLocaleDateString() +' ' + dateFormat;
			   
		  }
		  
        return dateVal;
      });
      
      
    }
	}
	
});

(function (factory) {
    'use strict';    
    if (typeof define === 'function' && define.amd) {
        define(['angular', 'moment'], factory); // AMD        
    } else if (typeof exports === 'object') {
        module.exports = factory(require('angular'), require('moment')); // CommonJS
    } else {
        factory(window.angular, window.moment); // Browser global
    }
}(function (angular, moment) {    
    'use strict';
    angular.module('ui.bootstrap.datetimepicker', [])
    .constant('dateTimePickerConfig', {
        dropdownSelector: null,
        minuteStep: 5,
        minView: 'hour',
        startView: 'day'
    })
    .directive('datetimepicker', ['$log', 'dateTimePickerConfig', function datetimepickerDirective($log, defaultConfig) {
        
        function DateObject() {
            
            var tempDate = new Date();
            var localOffset = tempDate.getTimezoneOffset() * 60000;
            this.utcDateValue = tempDate.getTime();
            this.selectable = true;
            
            this.localDateValue = function () {
                return this.utcDateValue + localOffset;
            };
            
            var validProperties = ['utcDateValue', 'localDateValue', 'display', 'active', 'selectable', 'past', 'future'];
            
            for (var prop in arguments[0]) {                               
                if (validProperties.indexOf(prop) >= 0) {                    
                    this[prop] = arguments[0][prop];
                }
            }
        }
        
        var validateConfiguration = function validateConfiguration(configuration) {
            var validOptions = ['startView', 'minView', 'minuteStep', 'dropdownSelector'];
            
            for (var prop in configuration) {                
                if (validOptions.indexOf(prop) < 0) {
                    throw ('invalid option: ' + prop);
                }
            }
                        
            var validViews = ['minute', 'hour', 'day', 'month', 'year'];
            
            if (validViews.indexOf(configuration.startView) < 0) {
                throw ('invalid startView value: ' + configuration.startView);
            }
            
            if (validViews.indexOf(configuration.minView) < 0) {
                throw ('invalid minView value: ' + configuration.minView);
            }
            
            if (validViews.indexOf(configuration.minView) > validViews.indexOf(configuration.startView)) {
                throw ('startView must be greater than minView');
            }
            
            if (!angular.isNumber(configuration.minuteStep)) {
                throw ('minuteStep must be numeric');
            }
            if (configuration.minuteStep <= 0 || configuration.minuteStep >= 60) {
                throw ('minuteStep must be greater than zero and less than 60');
            }
			//ragashalini.koka@cdk.com - changed angular.isString to angular.isObject
            if (configuration.dropdownSelector !== null && !angular.isObject(configuration.dropdownSelector)) {
                throw ('dropdownSelector must be a object');
            }
            
            if (configuration.dropdownSelector !== null && ((typeof jQuery === 'undefined') || (typeof jQuery().dropdown !== 'function'))) {
                $log.error('Please DO NOT specify the dropdownSelector option unless you are using jQuery AND Bootstrap.js. ' +
                           'Please include jQuery AND Bootstrap.js, or write code to close the dropdown in the on-set-time callback. \n\n' +
                           'The dropdownSelector configuration option is being removed because it will not function properly.');
                delete configuration.dropdownSelector;
            }
        };
        
        return {
            restrict: 'E',
            require: 'ngModel',
            template: '<div class="datetimepicker table-responsive">' +
            '<table class="table table-striped  {{ data.currentView }}-view">' +
            '   <thead>' +
            '       <tr>' +
            '           <th class="left" data-ng-click="changeView(data.currentView, data.leftDate, $event)" data-ng-show="data.leftDate.selectable"><i class="glyphicon glyphicon-arrow-left"/></th>' +
            '           <th class="switch" colspan="5" data-ng-show="data.previousViewDate.selectable" data-ng-click="changeView(data.previousView, data.previousViewDate, $event)">{{ data.previousViewDate.display }}</th>' +
            '           <th class="right" data-ng-click="changeView(data.currentView, data.rightDate, $event)" data-ng-show="data.rightDate.selectable"><i class="glyphicon glyphicon-arrow-right"/></th>' +
            '       </tr>' +
            '       <tr>' +
            '           <th class="dow" data-ng-repeat="day in data.dayNames" >{{ day }}</th>' +
            '       </tr>' +
            '   </thead>' +
            '   <tbody>' +
            '       <tr data-ng-if="data.currentView !== \'day\'" >' +
            '           <td colspan="7" >' +
            '              <span    class="{{ data.currentView }}" ' +
            '                       data-ng-repeat="dateObject in data.dates"  ' +
            '                       data-ng-class="{active: dateObject.active, past: dateObject.past, future: dateObject.future, disabled: !dateObject.selectable}" ' +
            '                       data-ng-click="changeView(data.nextView, dateObject, $event)">{{ dateObject.display }}</span> ' +
            '           </td>' +
            '       </tr>' +
            '       <tr data-ng-if="data.currentView === \'day\'" data-ng-repeat="week in data.weeks">' +
            '           <td data-ng-repeat="dateObject in week.dates" ' +
            '               data-ng-click="changeView(data.nextView, dateObject, $event)"' +
            '               class="day" ' +
            '               data-ng-class="{active: dateObject.active, past: dateObject.past, future: dateObject.future, disabled: !dateObject.selectable}" >{{ dateObject.display }}</td>' +
            '       </tr>' +
            '   </tbody>' +
            '</table></div>',
            scope: {
                onSetTime: '&',
                beforeRender: '&'
            },
            replace: true,
            link: function link(scope, element, attrs, ngModelController) {
                
                var directiveConfig = {};
                
                if (attrs.datetimepickerConfig) {
                    directiveConfig = scope.$parent.$eval(attrs.datetimepickerConfig);
                }
                
                var configuration = {};
                
                angular.extend(configuration, defaultConfig, directiveConfig);
                
                validateConfiguration(configuration);
                
                var startOfDecade = function startOfDecade(unixDate) {
                    var startYear = (parseInt(moment.utc(unixDate).year() / 10, 10) * 10);
                    return moment.utc(unixDate).year(startYear).startOf('year');
                };
                
                var dataFactory = {
                    year: function year(unixDate) {
                        var selectedDate = moment.utc(unixDate).startOf('year');
                        // View starts one year before the decade starts and ends one year after the decade ends
                        // i.e. passing in a date of 1/1/2013 will give a range of 2009 to 2020
                        // Truncate the last digit from the current year and subtract 1 to get the start of the decade
                        var startDecade = (parseInt(selectedDate.year() / 10, 10) * 10);
                        var startDate = moment.utc(startOfDecade(unixDate)).subtract(1, 'year').startOf('year');
                        
                        var activeYear = ngModelController.$modelValue ? moment(ngModelController.$modelValue).year() : 0;
                        
                        var result = {
                            'currentView': 'year',
                            'nextView': configuration.minView === 'year' ? 'setTime' : 'month',
                            'previousViewDate': new DateObject({
                                utcDateValue: null,
                                display: startDecade + '-' + (startDecade + 9)
                            }),
                            'leftDate': new DateObject({utcDateValue: moment.utc(startDate).subtract(9, 'year').valueOf()}),
                            'rightDate': new DateObject({utcDateValue: moment.utc(startDate).add(11, 'year').valueOf()}),
                            'dates': []
                        };
                        
                        for (var i = 0; i < 12; i += 1) {
                            var yearMoment = moment.utc(startDate).add(i, 'years');
                            var dateValue = {
                                'utcDateValue': yearMoment.valueOf(),
                                'display': yearMoment.format('YYYY'),
                                'past': yearMoment.year() < startDecade,
                                'future': yearMoment.year() > startDecade + 9,
                                'active': yearMoment.year() === activeYear
                            };
                            
                            result.dates.push(new DateObject(dateValue));
                        }
                        
                        return result;
                    },
                    
                    month: function month(unixDate) {
                        
                        var startDate = moment.utc(unixDate).startOf('year');
                        var previousViewDate = startOfDecade(unixDate);
                        var activeDate = ngModelController.$modelValue ? moment(ngModelController.$modelValue).format('YYYY-MMM') : 0;
                        
                        var result = {
                            'previousView': 'year',
                            'currentView': 'month',
                            'nextView': configuration.minView === 'month' ? 'setTime' : 'day',
                            'previousViewDate': new DateObject({
                                utcDateValue: previousViewDate.valueOf(),
                                display: startDate.format('YYYY')
                            }),
                            'leftDate': new DateObject({utcDateValue: moment.utc(startDate).subtract(1, 'year').valueOf()}),
                            'rightDate': new DateObject({utcDateValue: moment.utc(startDate).add(1, 'year').valueOf()}),
                            'dates': []
                        };
                        
                        for (var i = 0; i < 12; i += 1) {
                            var monthMoment = moment.utc(startDate).add(i, 'months');
                            var dateValue = {
                                'utcDateValue': monthMoment.valueOf(),
                                'display': monthMoment.format('MMM'),
                                'active': monthMoment.format('YYYY-MMM') === activeDate
                            };
                            
                            result.dates.push(new DateObject(dateValue));
                        }
                        
                        return result;
                    },
                    
                    day: function day(unixDate) {
                        
                        var selectedDate = moment.utc(unixDate);
                        var startOfMonth = moment.utc(selectedDate).startOf('month');
                        var previousViewDate = moment.utc(selectedDate).startOf('year');
                        var endOfMonth = moment.utc(selectedDate).endOf('month');
                        
                        var startDate = moment.utc(startOfMonth).subtract(Math.abs(startOfMonth.weekday()), 'days');
                        
                        var activeDate = ngModelController.$modelValue ? moment(ngModelController.$modelValue).format('YYYY-MMM-DD') : '';
                        
                        var result = {
                            'previousView': 'month',
                            'currentView': 'day',
                            'nextView': configuration.minView === 'day' ? 'setTime' : 'hour',
                            'previousViewDate': new DateObject({
                                utcDateValue: previousViewDate.valueOf(),
                                display: startOfMonth.format('YYYY-MMM')
                            }),
                            'leftDate': new DateObject({utcDateValue: moment.utc(startOfMonth).subtract(1, 'months').valueOf()}),
                            'rightDate': new DateObject({utcDateValue: moment.utc(startOfMonth).add(1, 'months').valueOf()}),
                            'dayNames': [],
                            'weeks': []
                        };
                        
                        
                        for (var dayNumber = 0; dayNumber < 7; dayNumber += 1) {
                            result.dayNames.push(moment.utc().weekday(dayNumber).format('dd'));
                        }
                        
                        for (var i = 0; i < 6; i += 1) {
                            var week = {dates: []};
                            for (var j = 0; j < 7; j += 1) {
                                var monthMoment = moment.utc(startDate).add((i * 7) + j, 'days');
                                var dateValue = {
                                    'utcDateValue': monthMoment.valueOf(),
                                    'display': monthMoment.format('D'),
                                    'active': monthMoment.format('YYYY-MMM-DD') === activeDate,
                                    'past': monthMoment.isBefore(startOfMonth),
                                    'future': monthMoment.isAfter(endOfMonth)
                                };
                                week.dates.push(new DateObject(dateValue));
                            }
                            result.weeks.push(week);
                        }
                        
                        return result;
                    },
                    
                    hour: function hour(unixDate) {
                        var selectedDate = moment.utc(unixDate).startOf('day');
                        var previousViewDate = moment.utc(selectedDate).startOf('month');
                        
                        var activeFormat = ngModelController.$modelValue ? moment(ngModelController.$modelValue).format('YYYY-MM-DD H') : '';
                        
                        var result = {
                            'previousView': 'day',
                            'currentView': 'hour',
                            'nextView': configuration.minView === 'hour' ? 'setTime' : 'minute',
                            'previousViewDate': new DateObject({
                                utcDateValue: previousViewDate.valueOf(),
                                display: selectedDate.format('ll')
                            }),
                            'leftDate': new DateObject({utcDateValue: moment.utc(selectedDate).subtract(1, 'days').valueOf()}),
                            'rightDate': new DateObject({utcDateValue: moment.utc(selectedDate).add(1, 'days').valueOf()}),
                            'dates': []
                        };
                        
                        for (var i = 0; i < 24; i += 1) {
                            var hourMoment = moment.utc(selectedDate).add(i, 'hours');
                            var dateValue = {
                                'utcDateValue': hourMoment.valueOf(),
                                'display': hourMoment.format('LT'),
                                'active': hourMoment.format('YYYY-MM-DD H') === activeFormat
                            };
                            
                            result.dates.push(new DateObject(dateValue));
                        }
                        
                        return result;
                    },
                    
                    minute: function minute(unixDate) {
                        var selectedDate = moment.utc(unixDate).startOf('hour');
                        var previousViewDate = moment.utc(selectedDate).startOf('day');
                        var activeFormat = ngModelController.$modelValue ? moment(ngModelController.$modelValue).format('YYYY-MM-DD H:mm') : '';
                        
                        var result = {
                            'previousView': 'hour',
                            'currentView': 'minute',
                            'nextView': 'setTime',
                            'previousViewDate': new DateObject({
                                utcDateValue: previousViewDate.valueOf(),
                                display: selectedDate.format('lll')
                            }),
                            'leftDate': new DateObject({utcDateValue: moment.utc(selectedDate).subtract(1, 'hours').valueOf()}),
                            'rightDate': new DateObject({utcDateValue: moment.utc(selectedDate).add(1, 'hours').valueOf()}),
                            'dates': []
                        };
                        
                        var limit = 60 / configuration.minuteStep;
                        
                        for (var i = 0; i < limit; i += 1) {
                            var hourMoment = moment.utc(selectedDate).add(i * configuration.minuteStep, 'minute');
                            var dateValue = {
                                'utcDateValue': hourMoment.valueOf(),
                                'display': hourMoment.format('LT'),
                                'active': hourMoment.format('YYYY-MM-DD H:mm') === activeFormat
                            };
                            
                            result.dates.push(new DateObject(dateValue));
                        }
                        
                        return result;
                    },
                    
                    setTime: function setTime(unixDate) {
                        var tempDate = new Date(unixDate);
                        var newDate = new Date(tempDate.getTime() + (tempDate.getTimezoneOffset() * 60000));
                        
                        var oldDate = ngModelController.$modelValue;
                        ngModelController.$setViewValue(newDate);
                        
                        if (configuration.dropdownSelector) {
                            jQuery(configuration.dropdownSelector).dropdown('toggle');
                        }
                        
                        scope.onSetTime({newDate: newDate, oldDate: oldDate});
                        
                        return dataFactory[configuration.startView](unixDate);
                    }
                };
                
                var getUTCTime = function getUTCTime(modelValue) {
                    var tempDate = (modelValue ? moment(modelValue).toDate() : new Date());
                    return tempDate.getTime() - (tempDate.getTimezoneOffset() * 60000);
                };
                
                scope.changeView = function changeView(viewName, dateObject, event) {
                    if (event) {
                        event.stopPropagation();
                        event.preventDefault();
                    }
                    
                    if (viewName && (dateObject.utcDateValue > -Infinity) && dateObject.selectable && dataFactory[viewName]) {
                        var result = dataFactory[viewName](dateObject.utcDateValue);
                        
                        var weekDates = [];
                        if (result.weeks) {
                            for (var i = 0; i < result.weeks.length; i += 1) {
                                var week = result.weeks[i];
                                for (var j = 0; j < week.dates.length; j += 1) {
                                    var weekDate = week.dates[j];
                                    weekDates.push(weekDate);
                                }
                            }
                        }
                        
                        scope.beforeRender({
                            $view: result.currentView,
                            $dates: result.dates || weekDates,
                            $leftDate: result.leftDate,
                            $upDate: result.previousViewDate,
                            $rightDate: result.rightDate
                        });
                        
                        scope.data = result;
                    }
                };
                
                ngModelController.$render = function $render() {
                    scope.changeView(configuration.startView, new DateObject({utcDateValue: getUTCTime(ngModelController.$viewValue)}));
                };
            }
        };
    }]);
}));


angular.module('ui.multiselect', [])

//from bootstrap-ui typeahead parser
.factory('optionParser', ['$parse', function ($parse) {    
    var TYPEAHEAD_REGEXP = /^\s*(.*?)(?:\s+as\s+(.*?))?\s+for\s+(?:([\$\w][\$\w\d]*))\s+in\s+(.*)$/;
    
    return {
        parse: function (input) {
            
            var match = input.match(TYPEAHEAD_REGEXP), modelMapper, viewMapper, source;
            if (!match) {
                throw new Error(
                    "Expected typeahead specification in form of '_modelValue_ (as _label_)? for _item_ in _collection_'" +
                    " but got '" + input + "'.");
            }
            
            return {
                itemName: match[3],
                source: $parse(match[4]),
                viewMapper: $parse(match[2] || match[1]),
                modelMapper: $parse(match[1])
            };
        }
    };
}])

.directive('multiselect', ['$parse', '$document', '$compile', 'optionParser',
                           
                           function ($parse, $document, $compile, optionParser) {
                               return {
                                   restrict: 'E',
                                   require: 'ngModel',
                                   link: function (originalScope, element, attrs, modelCtrl) {
                                       
                                       var exp = attrs.options,
                                           parsedResult = optionParser.parse(exp),
                                           isMultiple = attrs.multiple ? true : false,
                                           required = false,
                                           scope = originalScope.$new(),
                                           changeHandler = attrs.change;
                                       
                                       scope.items = [];
                                       scope.header = 'Select';
                                       scope.multiple = isMultiple;
                                       scope.disabled = false;
									   //ragashalini.koka@cdk.com added addNewClass and if condition to style the required fields 
									   scope.addNewClass = 'notReq';
									   if(attrs.class.indexOf('required') != -1) {
										scope.addNewClass = attrs.class;
									   }
                                       
                                       originalScope.$on('$destroy', function () {
                                           scope.$destroy();
                                       });
                                       
                                       var popUpEl = angular.element('<multiselect-popup></multiselect-popup>');
                                       
                                       //required validator
                                       if (attrs.required || attrs.ngRequired) {
                                           required = true;
                                       }
                                       attrs.$observe('required', function(newVal) {
                                           required = newVal;
                                       });
                                       
                                       //watch disabled state
                                       scope.$watch(function () {
                                           return $parse(attrs.disabled)(originalScope);
                                       }, function (newVal) {
                                           scope.disabled = newVal;
                                       });
                                       
                                       //watch single/multiple state for dynamically change single to multiple
                                       scope.$watch(function () {
                                           return $parse(attrs.multiple)(originalScope);
                                       }, function (newVal) {
                                           isMultiple = newVal || false;
                                       });
                                       
                                       //watch option changes for options that are populated dynamically
                                       scope.$watch(function () {
                                           return parsedResult.source(originalScope);
                                       }, function (newVal) {
                                           if (angular.isDefined(newVal))
                                               parseModel();
                                       }, true);
                                       
                                       //watch model change
                                       scope.$watch(function () {
                                           return modelCtrl.$modelValue;
                                       }, function (newVal, oldVal) {                                         
                                           if (angular.isDefined(newVal)) {
                                               markChecked(newVal);
                                               scope.$eval(changeHandler);
                                           }
                                           getHeaderText();
                                           modelCtrl.$setValidity('required', scope.valid());
                                       }, true);
                                       
                                       function parseModel() {
									    //ragashalini.koka@cdk.com - added if block and selectedOptionsArr array variable 
										var selectedOptionsArr = [];
                                           if(typeof scope.selected !='undefined') {
                                              // console.log('inside parse model ' + scope.selected.replace(/ /g,''));
                                               selectedOptionsArr = scope.selected.replace(/ /g,'').split(';');
                                               
                                             //  console.log(selectedOptionsArr);
                                            }
                                           scope.items.length = 0;
                                           var model = parsedResult.source(originalScope);
                                           if(!angular.isDefined(model)) return;
                                           for (var i = 0; i < model.length; i++) {
                                               var local = {};
                                               local[parsedResult.itemName] = model[i];
											   //ragashalini.koka@cdk.com - added if block and isChecked variable and changed checked value to isChecked in scope.items.push 
											   var isChecked = false;
                                              
                                               if(selectedOptionsArr.indexOf(model[i].label) > -1) {
                                               	 // console.log('is checked true');	
                                                   isChecked = true;    
                                               }
                                               scope.items.push({
                                                   label: parsedResult.viewMapper(local),
                                                   model: model[i],
                                                   checked: isChecked
                                               });
                                           }
										    setModelValue(scope.multiple);
                                       }
                                       
                                       parseModel();
                                       
                                       element.append($compile(popUpEl)(scope));
                                       
                                       function getHeaderText() {                                            
                                           if (is_empty(modelCtrl.$modelValue)) return scope.header = '0';
                                           if (isMultiple) {
                                               var tempString="";
                                               tempString = modelCtrl.$modelValue + ' ';// + 'selected';
                                               //ragashalini.koka@cdk.com - changed : to ; 
											   scope.header = tempString.split(';').length;                
                                           } else {
                                               var local = {};
                                               local[parsedResult.itemName] = modelCtrl.$modelValue;              
                                               scope.header = parsedResult.viewMapper(local);
                                           }
                                       }
                                       
                                       function is_empty(obj) {
                                           if (!obj) return true;
                                           if (obj.length && obj.length > 0) return false;
                                           for (var prop in obj) if (obj[prop]) return false;
                                           return true;
                                       };
                                       
                                       scope.valid = function validModel() {
                                           if(!required) return true;
                                           var value = modelCtrl.$modelValue;
                                           return (angular.isArray(value) && value.length > 0) || (!angular.isArray(value) && value != null);
                                       };
                                       
                                       function selectSingle(item) {
                                           if (item.checked) {
                                               scope.uncheckAll();
                                           } else {
                                               scope.uncheckAll();
                                               item.checked = !item.checked;
                                           }
                                           setModelValue(false);
                                       }
                                       
                                       function selectMultiple(item) {
                                           item.checked = !item.checked;
                                           setModelValue(true);
                                       }
                                       
                                       function setModelValue(isMultiple) {
                                           var value;
                                           var final="";
                                           var count=0;
                                           if (isMultiple) {
                                               value = [];
                                               angular.forEach(scope.items, function (item) {
                                                   if (item.checked) {
                                                       
                                                       if(count!==0)
                                                       {                
															//ragashalini.koka@cdk.com - changed : to ; 
                                                           final = final + ";" + item.model.value;
                                                       }
                                                       else
                                                       {
                                                           final = item.model.value;
                                                           count = count+1;
                                                       }
                                                       value.push(item.model);                    
                                                   }
                                               })
                                           } else {
                                               angular.forEach(scope.items, function (item) {
                                                   if (item.checked) {
                                                       value = item.model;
                                                       return false;
                                                   }
                                               })
                                           }
                                           //value.push(final);              
                                           modelCtrl.$setViewValue(final);
                                       }
                                       
                                       function markChecked(newVal) {
                                           if (!angular.isArray(newVal)) {
                                               angular.forEach(scope.items, function (item) {
                                                   if (angular.equals(item.model, newVal)) {
                                                       item.checked = true;
                                                       return false;
                                                   }
                                               });
                                           } else {
                                               angular.forEach(newVal, function (i) {
                                                   angular.forEach(scope.items, function (item) {
                                                       if (angular.equals(item.model, i)) {
                                                           item.checked = true;
                                                       }
                                                   });
                                               });
                                           }
                                       }
                                       
                                       scope.checkAll = function () {
                                           if (!isMultiple) return;
                                           angular.forEach(scope.items, function (item) {
                                               item.checked = true;
                                           });
                                           setModelValue(true);
                                       };
                                       
                                       scope.uncheckAll = function () {
                                           angular.forEach(scope.items, function (item) {
                                               item.checked = false;
                                           });
                                           setModelValue(true);
                                       };
                                       
                                       scope.select = function (item) {
                                           if (isMultiple === false) {
                                               selectSingle(item);
                                               scope.toggleSelect();
                                           } else {
                                               selectMultiple(item);
                                           }
                                       }
                                   }
                               };
                           }])

.directive('multiselectPopup', ['$document', function ($document) {
    return {
        restrict: 'E',
        scope: false,
        replace: true,
        template: '<div class="dropdown ">'+
        '<button class="btn {{addNewClass}}" ng-click="toggleSelect()" ng-disabled="disabled">'+
        'Selected: <div class="badge" style="background-color:#5F6264 !important">{{header}}</div>'+
        '<span class="caret pull-right"></span>'+
        '</button>'+
        '<ul class="dropdown-menu">'+
        '<li>'+
        '<input class="form-control " type="text" ng-model="searchText.label" autofocus="autofocus" placeholder="Filter" />'+
        '</li>'+
        '<li ng-show="multiple">'+
        '<button class="btn-nobg btn-link btn-small" ng-click="checkAll()"><i class="glyphicon glyphicon-ok"></i> Check all</button>'+
        '<button class="btn-nobg btn-link btn-small" ng-click="uncheckAll()"><i class="glyphicon glyphicon-remove"></i> Uncheck all</button>'+
        '</li>'+
        '<li ng-repeat="i in items | filter:searchText">'+
        '<a ng-click="select(i); focus()">'+
        '<i ng-class="{\'glyphicon glyphicon-ok\': i.checked, \'glyphicon glyphicon-empty\': !i.checked}"></i>{{i.label}}</a>'+
        '</li>'+
        '</ul>'+
        '</div>',
        link: function (scope, element, attrs) {
            
            scope.isVisible = false;
            
            scope.toggleSelect = function () {
                if (element.hasClass('open')) {
                    element.removeClass('open');
                    $document.unbind('click', clickHandler);
                } else {
                    element.addClass('open');
                    $document.bind('click', clickHandler);
                    scope.focus();
                }
            };
            
            function clickHandler(event) {
                if (elementMatchesAnyInArray(event.target, element.find(event.target.tagName)))
                    return;
                element.removeClass('open');
                $document.unbind('click', clickHandler);
                scope.$apply();
            }
            
            scope.focus = function focus(){
                var searchBox = element.find('input')[0];
                searchBox.focus(); 
            }
            
            var elementMatchesAnyInArray = function (element, elementArray) {
                for (var i = 0; i < elementArray.length; i++)
                    if (element == elementArray[i])
                        return true;
                return false;
            }
            }
    }
}]);