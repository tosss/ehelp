
MAData = {
	CensusLayer: null,
	Markers: [],

	domain: "https://product-api-prod.cloudbilt.com/demographicsv6",
    // domain: "http://prod-v1-mapanythingapis.elasticbeanstalk.com/data/v1",
    
    groupByData: null,
    sandbox: false,
    
	orgId: '',
    unit: '',
    
    markerLimit: 100,
    markerImage: 'oil',
    
	//Initialize all of the goodies
	Init: function(orgId) {
	    
	    //console.log('ORG ID:', orgId);
	    
	    MAData.orgId = orgId;

		MAData.StopPropagation();
		MAData.GetCountries();
		MAData.GetCountriesV2();
		
	},

	//Handles propagation of clicks on the menu
	StopPropagation: function() {

		//stop propagation of click events to avoid closing the menu
		$('#countryplaceholder, #datasourceplaceholder, #topicplaceholder, #groupbyplaceholder').on('click', function (e) {
			e.stopPropagation();
		});
	},

	//Handles clicks on the map
	HandleClick: function(e, markerData, marker) {

		//create a new info bubble and show loading
		var $tooltipContent = $('#tooltip-demographic-template').clone().attr('id', 'tooltip-content').addClass('demographics').show();

		$tooltipContent.find('.tooltip-loader').show();

		//send request to get new demographic data
		//setTimeout (function () {
        //get the country and topic
		var country = $('table.DemographicTable').find('#country option:selected').val();
		var topic = $('table.DemographicTable').find('#topic option:selected').val();
		var topicname = $('table.DemographicTable').find('#topic option:selected').text();
		var datasource = $('table.DemographicTable').find('#datasource option:selected').val();
		
		//get all of the grouping data
		var groupby = $('table.DemographicTable').find('#groupby option:selected').val();

        //lat and lng of the click event
		var lat = e.latLng.lat();
		var lng = e.latLng.lng();
    		
		if(markerData === null || markerData === undefined) {
    		$.getJSON( MAData.domain + '/info/index.php?action=get_point_info&sandbox=' + MAData.sandbox + '&topic_id=' + topic + '&file_id=' + datasource + '&level_id=' + groupby + '&orgid=' + MAData.orgId + '&lat=' + lat + '&lng=' + lng + '&callback=?&apikey=' + MA.APIKey, function( data ) {
    			//console.log(data);
    
    			if (data.success && data.data.header.levels !== undefined)
    			{
    			    //console.log(data);
    			    
        		    MA.demographicsInfoBubble = MA.Map.InfoBubble.show({
            			position: e.latLng,
            			minWidth: 200,
            			content: $tooltipContent.get(0)
            		});
    
    			    
                    MAData.BuildHeader(data.data.header, $tooltipContent);
                    MAData.BuildTabs(data.data.tabs, $tooltipContent);
                    
                    //init tabs
    				$tooltipContent.find('.tabs').tabs({
    					activate: function( event, ui ) {
    						setTimeout(function () {
    							try { MA.demographicsInfoBubble.padding_changed(); MA.demographicsInfoBubble.panToView(); } catch (err) {}
    						}, 500);
    					}
    				});
    
    				//hide loading and adjust pan
    				$tooltipContent.find('.tooltip-loader').hide();
    				MA.demographicsInfoBubble.padding_changed();
    				MA.demographicsInfoBubble.panToView();
    			}
    			else
    			{
    				MA.Map.InfoBubble.hide();
    			}
    		});
    		
		} else {
		    
            MA.demographicsInfoBubble = MA.Map.InfoBubble.show({
    			position: e.latLng,
    			minWidth: 500,
    			content: $tooltipContent.get(0),
    			anchor: marker,
    			markerData: markerData
    		});
			    
            MAData.BuildHeader(markerData.header, $tooltipContent);
            
            //console.log('markerData:',markerData);
            
            MAData.BuildTabs(markerData.tabs, $tooltipContent);
            MAData.BuildActionsTab(
                [
                    { 'action': 'Create Record', 'type': 'Standard Action', label: 'Click2Create<sup>TM</sup>'},
                    { 'action': 'Add to Route', 'type': 'Standard Action', label: 'Add to Route'}
                ], 
                $tooltipContent
            );
            
            //MAData.test = $tooltipContent.closest('div');
            
            //init tabs
			$tooltipContent.find('.tabs').tabs({
				activate: function( event, ui ) {
					setTimeout(function () {
						try { MA.demographicsInfoBubble.padding_changed(); MA.demographicsInfoBubble.panToView(); } catch (err) {}
					}, 500);
				}
			});

			//hide loading and adjust pan
			$tooltipContent.find('.tooltip-loader').hide();
			MA.demographicsInfoBubble.padding_changed();
			MA.demographicsInfoBubble.panToView();
		}
	},
	
	
	//Builds and appends the HTML for the info bubble header
	BuildHeader: function(headerData, $element) {
	    var newHTML = '';
	    
	    //handle all of the levels: state, county, etc.
	    var len = headerData.levels.length;
	    for(var ii=0; ii<len; ii++) {
	        newHTML += '<tr><td style="font-weight:bold; font-size: 12px; ">' + headerData.levels[ii].label + ':</td><td style="font-size: 12px;">' + headerData.levels[ii].value + '</td></tr>';
	    }
	    
	    //add in the single topic-specific header
	    newHTML += '<tr><td style="font-weight:bold; font-size: 12px; ">' + headerData.label + ':</td><td style="font-size: 12px;">' + headerData.value + '</td></tr>';
	    
	    $element.find( '.tooltip-table' ).append( newHTML );
	},
	
	
	//Builds and appends the tab data to the proper tabs
	BuildTabs: function(tabData, $element) {
	    var tabs = $element.find('#madata-tabs');
	    
	    //handle all of the tabs.
	    var len = tabData.length;
        for(var ii=0; ii<len; ii++) {
            if(tabData[ii].values.length > 0) {
    	        tabs.find('ul').append('<li><a href="#tab-' + tabData[ii].id + '">' + tabData[ii].name + '</a></li>');
    	        var dataHTML = '<div id="tab-' + tabData[ii].id + '"><table id="'+ tabData[ii].id + '-table">';
    	        
    	        var valCount = tabData[ii].values.length;
    	        for(var jj=0; jj<valCount; jj++) {
    	            dataHTML += '<tr><td style="font-weight:bold; font-size: 12px; padding-right:10px">' + tabData[ii].values[jj].label + ':</td><td style="float:left; font-size: 12px;">' + tabData[ii].values[jj].formatted_value + '</td></tr>';
    	        }
    	        
    	        dataHTML += '</table></div>';
    	        
    	        tabs.append(dataHTML);
            }
	    }
	},
	
	
	//Builds the actions tab
	BuildActionsTab: function(actionData, $element) {
	    var tabs = $element.find('#madata-tabs');
	    
	    //handle all of the tabs.
	    var len = actionData.length;
        tabs.find('ul').append('<li><a href="#tab-buttonActions">Actions</a></li>');
        var dataHTML = '<div id="tab-buttonActions"><table id="buttonActions-table">';
        
        var counter = 1;
	    for(var ii=0; ii<len; ii++) {
	        
	        var buttonHTML = '<td><button class="MAbutton button-silver button-small actionButton" onclick="MAData.doButtonAction(\''+actionData[ii].type+'\',\''+actionData[ii].action+'\')" data-action="' + actionData[ii].action + '" data-type="' + actionData[ii].type + '">' + actionData[ii].label + '</button></td>';
	        
	        if(counter === 1) {
	            dataHTML += '<tr>' + buttonHTML;
	            dataHTML += ii === len-1 ? '</tr>' : '';
	            counter++;
	        } else if(counter === 2) {
	            dataHTML += buttonHTML;
	            dataHTML += ii === len-1 ? '</tr>' : '';
	            counter++;
	        } else if(counter === 3) {
                dataHTML += buttonHTML + '</tr>';
                counter = 1;
	        }
	        
	    }
	    
        dataHTML += '</table></div>';
        tabs.append(dataHTML);
	},
	
	createRecordFromDataLayer : {
	    getDataLayerc2cOptions : function () {
	        //clear the previous options
	        var $selectList = $('#dataLayerSelction .createrecordDataLayer2-dataType').empty();
	        
	        //loop over queries to ge types
	        var layers = $('#PlottedQueriesTable .DataLayer');
	        var lI = layers.length;
	        var tempOptions = {};
	        var selectOptionsHTML = '';
	        while(lI--) {
	            var $layer = $(layers[lI]);
	            var layerType = $layer.attr('data-type');
	            var layerName = $layer.find('.basicinfo-name').text();
	            var uid = $layer.attr('uid');
	            if(layerType.indexOf('dmp') >= 0) {
	                layerType = 'dmp-v1';
	            }
	            else {
	                layerType = 'navport-v1';
	            }
	            
	            selectOptionsHTML += '<option data-uid="'+uid+'" value="'+layerType+'">'+layerName+'</options>';
	        }
	        $selectList.append(selectOptionsHTML);
	        selectOptionsHTML = null;
	        tempOptions = null;
	        layers = null;
	        
	    },
	    
	    cancel_Record : function () {
	        ClosePopupWindow();
	        
	        //reset all values
	        $('#CreateRecordDataLayerPopup .createrecord-step').show();
	        $('#createrecordDataLayer-step2').hide();
	    },
	    
	    launch_popupV2 : function (options) {
	        options = $.extend({
        		isMassAction : false,
        		dataLayers : []
        	}, options || {});
        	
        	if(!options.layerType) {
        	    return;
        	}
        	
        	
	        //launch the popup
            var popup = MA.Popup.showMAPopup({
				template: $('#templates .CreateRecordDataLayerPopup2').clone(),
                popupId : 'createDataLayerRecordV2',
				width : 500,
				title: 'Click2Create<sup>TM</sup>',
				buttons: [
					{
						text: '<b>Continue</b>',
						type: 'button-blue step1',
						keepOpen : true,
						onTap: function(e) {
							//get the password and name
							MAData.createRecordFromDataLayer.create_step_2_V2();
						}
					},
					{
						text: '<b>Finish</b>',
						type: 'button-blue step2 hidden',
						keepOpen : true,
						//keepOpen : true,
						onTap: function(e) {
							MAData.createRecordFromDataLayer.saveDataLayerRecordV2();
						}
					},
					{ 
						text: 'Cancel',
						type: 'button-silver',
					}
				]
			});
			
			$('#createDataLayerRecordV2 .MA2-loading-mask').removeClass('hidden');
			$('#createDataLayerRecordV2').data({'popup':popup,'isMassAction': options.isMassAction,'dataLayers': options.dataLayers,'dataType' : options.layerType});
	        
			//get data
            $.ajax({
                url: MA.resources.Tooltip+"?securityToken="+securityToken+"&action=getClick2CreateDataLayerSettings&core.apexpages.devmode.url=0",
                type: 'POST',
                dataType: 'JSON',
                data: {
                    dataType : options.layerType
                },
                success: function (response) {
                    if (response.success) {
                        //launch the popup
                        var $objectPicklist = $('#createDataLayerRecordV2 .createrecordDataLayer2-object').empty();
	                    $('#createDataLayerRecordV2 .createrecordDataLayer2-fieldset-errors').empty().hide();
                         //try to parse the data
                        if(response.data) {
                            var data = MA.Util.removeNamespace(response.data);
                            try {
                                var settings = JSON.parse(data.Settings__c);
                                $('#createDataLayerRecordV2').data('settings',settings);
                                //add options to select list for available base objects
                                var c2cSettings = settings['C2C'];
                                
                                for (var key in c2cSettings) {
                                    var baseObjData = c2cSettings[key];
                                    $objectPicklist.append($('<option />').attr('value', key).text(baseObjData.objLabel));
                                }
                                
                            }
                            catch(e){
                                
                            }
                        }
                        if(response.settings) {
                            //if we have settings we were able to update the record settings, otherwise use the backup saved in settins__c (legacy)
                            $('#createDataLayerRecordV2').data('recordTypes',response.settings);
                        }
                        
                        //update the record types
                        MAData.createRecordFromDataLayer.object_Change_V2();
                        $('#createDataLayerRecordV2 .MA2-loading-mask').addClass('hidden');
                        
                    }
                    else if (!response.success) {
                        popup.close();
                        //show error message
                        MA.Popup.showMAAlert({
                            title: 'Data Layer Error',
                            template: response.message,
                            okText : 'Ok',
                            okType : 'button-blue'
                        });
                    }
                    else {
                        popup.close();
                        MA.Popup.showMAAlert({
                            title: 'Data Layer Error',
                            template: 'Unable to continue, please contact support.',
                            okText : 'Ok',
                            okType : 'button-blue'
                        });
                    }
                }
            });
	    },
	    
	    create_step_2_V2 : function () {
	        //grab the popup data again
            var $popup = $('#createDataLayerRecordV2');
            $('#createDataLayerRecordV2 .MA2-loading-mask').addClass('hidden');
            var settings = $popup.data('settings');
            var c2cSettings = settings['C2C'];
            var currentSelection = $popup.find('.createrecordDataLayer2-object').val();
            var objc2cSettings = c2cSettings[currentSelection];
            var recordTypes = objc2cSettings.recordTypes;
            var fieldSetOptions = objc2cSettings.fieldSetOptions;
            var fieldSetName = 'missing';
            //grab the fieldset for the selected record type
            var recordTypeId = $popup.find('.createrecordDataLayer2-recordtype').val();
            
            //loop over fieldsets
            for (var f = 0; f < fieldSetOptions.length; f++) {
                var fs = fieldSetOptions[f];
                
                if(fs.RecordTypeId == recordTypeId) {
                    fieldSetName = fs.FieldSetAPIName;
                }
            }
            
            //hide the step 1 button , show step 2
            $('#createDataLayerRecordV2 .step1').addClass('hidden');
            $('#createDataLayerRecordV2 .createrecordDataLayer2-step1').hide();
            $('#createDataLayerRecordV2 .step2').removeClass('hidden');
            $('#createDataLayerRecordV2 .createrecordDataLayer2-step2').show();
            
                
            $("#createDataLayerRecordV2 .createrecordDataLayer-fieldset").html('Loading...').load(MA.resources.Click2Create, "sobject=" + $('#createDataLayerRecordV2 .createrecordDataLayer2-object').val() + '&fieldset=' + fieldSetName + '&recordtypeid=' + (recordTypeId || '') + '&platform=desktop', function () {
                
                if(!$('#createDataLayerRecordV2').data('isMassAction')){
                    //build json data to send
                    var jsonData = {
                        uIds : [],
                        tableNames : [],
                        sfdcData : [],
                        topicData : [],
                        dataType : $('#createDataLayerRecordV2').data('dataType')
                    }
                    var markers = $popup.data('dataLayers') || [];
                    var mI = markers.length;
                    while(mI--) {
                        var marker = markers[mI];
                        jsonData.uIds.push(marker.data.marker.uid);
                        jsonData.tableNames.push(marker.data.marker.table);
                    }
                
                    if(objc2cSettings.fields) {
                        var fields = objc2cSettings.fields;
                        //loop over the saved data layer fields and try to update
                        for(var key in fields) {
                            var field = fields[key];
                            jsonData.topicData.push({topic_id:key,field:field});
                        }
                    }
                
                    //get data
                    MAData.createRecordFromDataLayer.getC2CDataFromServer(jsonData,function(res) {
                        if(res.success) {
                            //console.log(res.data);
                            var markerData = res.data[0];
                            for(var sfdcId in markerData) {
                                var fieldValue = markerData[sfdcId];
                                //try and find a matching field
                                try {
                                    var $input = $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="'+sfdcId+'"]');
                                    var $row = $input.closest('tr');
                                    $row.addClass('autoPopDataLayer');
                                    
                                    //fill in the rows
                                    if($input.length > 0) {
                                        if(!$('#createDataLayerRecordV2').data('isMassAction')){
                                            $input.find('.get-input').val(fieldValue);
                                        }
                                    }
                                    else {
                                        //append to bottom hidden
                                        var rowTemp = '<tr style="display:none;"><td class="field::'+sfdcId+' fieldInput" data-field="'+sfdcId+'" data-type="string"><input class="get-input '+sfdcId+'" value="'+fieldValue+'"/></td></tr>';
                                        $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldSetTable').append(rowTemp);
                                    }
                                }
                                catch(e) {
                                    
                                }
                            }
                        }
                        
                        //update the lat lng fields
                        if(!$('#createDataLayerRecordV2').data('isMassAction')){
                            try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__Geolocation_Longitude__s"]').find('.get-input').val(markerInfo.markerData.lng); } catch (err) {}
                            try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__Geolocation_Latitude__s"]').find('.get-input').val(markerInfo.markerData.lat); } catch (err) {}
                            try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__MALongitude__c"]').find('.get-input').val(markerInfo.markerData.lng); } catch (err) {}
                            try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__MALatitude__c"]').find('.get-input').val(markerInfo.markerData.lat); } catch (err) {}
                        }
                        
                        $('#createDataLayerRecordV2 .MA2-loading-mask').remove('hidden');
                    });
                }
                else {
                    if(objc2cSettings.fields) {
                        var fData = objc2cSettings.fields;
                        //loop over the saved data layer fields and try to update
                        for(var id in fData) {
                            var fieldData = fData[id];
                            
                            var $input = $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="'+fieldData+'"]');
                            var $row = $input.closest('tr');
                            $row.addClass('autoPopDataLayer');
                        }
                    }
                }
            });
            
	    },
	    
	    getC2CDataFromServer : function (json,callback) {
	        $.ajax({
                url: MAData.domain+"/click2create/index.php?action=get_click2create_info&debug=false",
                type: 'POST',
                dataType: 'JSON',
                data: {
                    data: JSON.stringify(json)
                }
	        })
            .success(function (response) {
                //console.log(response);
                callback(response);
            })
            .error(function (res) {
                //console.log(res);
                callback(res);
            });
	    },
	    
	    object_Change_V2 : function () {
	        var $popup = $('#createDataLayerRecordV2');
            
            var settings = $popup.data('settings');
            var c2cSettings = settings['C2C'];
            var currentSelection = $popup.find('.createrecordDataLayer2-object').val();
            var objc2cSettings = c2cSettings[currentSelection];
            
            //empty the recordType Selection and update
            var $recordTypePicklist = $popup.find('.createrecordDataLayer2-recordtype').empty();
            //check if we were able to get updated recordTypes
            try {
                var recordTypesObj = $popup.data('recordTypes');
                recordTypesObj = recordTypesObj[currentSelection];
                recordTypes = recordTypesObj.recordTypes;
                for (var rt = 0; rt < recordTypes.length; rt++) {
                    var redtype = recordTypes[rt];
                    if(redtype.available) {
                        var name = redtype.master === true ? redtype.name + ' (System Default)' : redtype.name;
                        $recordTypePicklist.append($('<option />').attr('value', redtype.recordTypeId).text(name));
                    }
                }
            }
            catch(e) {
                //legacy
                recordTypes = objc2cSettings.recordTypes;
                
                for (var r = 0; r < recordTypes.length; r++) {
                    var rtype = recordTypes[r];
                    $recordTypePicklist.append($('<option />').attr('value', rtype.id).text(rtype.label));
                }
            }
	    },

        create_step_2 : function () {
            //grab the popup data again
            var $popup = $('#CreateRecordDataLayerPopup');
            
            var settings = $popup.data('settings');
            var c2cSettings = settings['C2C'];
            var currentSelection = $popup.find('#createrecordDataLayer-object').val();
            var objc2cSettings = c2cSettings[currentSelection];
            var recordTypes = objc2cSettings.recordTypes;
            var fieldSetOptions = objc2cSettings.fieldSetOptions;
            
            //grab the fieldset for the selected record type
            var recordTypeId = $('#createrecordDataLayer-recordtype').val();
            var fieldSetName = 'missing';
            
            //loop over fieldsets
            for (var f = 0; f < fieldSetOptions.length; f++) {
                var fs = fieldSetOptions[f];
                
                if(fs.RecordTypeId == recordTypeId) {
                    fieldSetName = fs.FieldSetAPIName;
                }
            }
            
            //grab the marker data
            var markerData = MA.demographicsInfoBubble.markerData;
            
            $('#CreateRecordDataLayerPopup .createrecord-step').hide();
            $('#createrecordDataLayer-step2').show();
            $('#createDataLayerRecordV2 .MA2-loading-mask').removeClass('hidden');
            
            $("#createrecordDataLayer-fieldset").html('Loading...').load(MA.resources.Click2Create, "sobject=" + $('#createrecordDataLayer-object').val() + '&fieldset=' + fieldSetName + '&recordtypeid=' + (recordTypeId || '') + '&platform=desktop', function () {
                //update fields
                $('#createDataLayerRecordV2 .MA2-loading-mask').addClass('hidden');
                if(objc2cSettings.fields) {
                    var fields = objc2cSettings.fields;
                    //loop over the saved data layer fields and try to update
                    for(var key in fields) {
                        var field = fields[key];
                        //try and find a matching field
                        try {
                            var $input = $('#createrecordDataLayer-fieldset .fieldInput[data-field="'+field+'"]');
                            
                            //insert the default data for these
                            for(var t = 0; t < markerData.tabs.length; t++) {
                                //loop over these values 
                                var tab = markerData.tabs[t];
                                for(var tt = 0; tt < tab.values.length; tt++) {
                                    var value = tab.values[tt];
                                    //console.log(value);
                                    if(key == value.topic_id) {
                                        if($input.length > 0) {
                                            $input.find('.get-input').val(value.value);
                                        }
                                        else {
                                            //append to bottom hidden
                                            var rowTemp = '<tr style="display:none;"><td class="field::'+field+' fieldInput" data-field="'+field+'" data-type="string"><input class="get-input '+field+'" value="'+value.value+'"/></td></tr>';
                                            $('#createrecordDataLayer-fieldset .fieldSetTable').append(rowTemp);
                                        }
                                    }
                                }
                            }
                        } catch (err) {}
                    }
                }
                
                //update the lat lng fields
                try { jQuery('#createrecordDataLayer-fieldset .fieldInput[data-field="sma__Geolocation_Longitude__s"]').find('.get-input').val(markerData.marker.markerData.lng); } catch (err) {}
                try { jQuery('#createrecordDataLayer-fieldset .fieldInput[data-field="sma__Geolocation_Latitude__s"]').find('.get-input').val(markerData.marker.markerData.lat); } catch (err) {}
                try { jQuery('#createrecordDataLayer-fieldset .fieldInput[data-field="sma__MALongitude__c"]').find('.get-input').val(markerData.marker.markerData.lng); } catch (err) {}
                try { jQuery('#createrecordDataLayer-fieldset .fieldInput[data-field="sma__MALatitude__c"]').find('.get-input').val(markerData.marker.markerData.lat); } catch (err) {}
                
            });    
        },
        
        saveDataLayerRecordV2 : function () {
            var $popup = $('#createDataLayerRecordV2');
            var isMassAction = $('#createDataLayerRecordV2').data('isMassAction');
            var dataLayers = $('#createDataLayerRecordV2').data('dataLayers');
            var settings = $popup.data('settings');
            var c2cSettings = settings['C2C'];
            var currentSelection = $popup.find('.createrecordDataLayer2-object').val();
            var objc2cSettings = c2cSettings[currentSelection];
            var recordTypes = objc2cSettings.recordTypes;
            var fieldSetOptions = objc2cSettings.fieldSetOptions;
            
            //grab the fieldset for the selected record type
            var recordTypeId = $popup.find('.createrecordDataLayer2-recordtype').val();
            var fieldSetName = 'missing';
            
            //grab the marker data
            //var markerData = MA.demographicsInfoBubble.markerData;
            
            //loop over fieldsets
            for (var f = 0; f < fieldSetOptions.length; f++) {
                var fs = fieldSetOptions[f];
                
                if(fs.RecordTypeId == recordTypeId) {
                    fieldSetName = fs.FieldSetAPIName;
                }
            }
            
            $('#createDataLayerRecordV2 .MA2-loading-mask .updateText').text('Retrieving Data...');
            $('#createDataLayerRecordV2 .MA2-loading-mask').removeClass('hidden');
            
            //now grab fields from the field set
            var sfdcFieldData = [];
            $popup.find('.createrecordDataLayer-fieldset [class^="field::"]').each(function () 
            {
                var fieldName = $(this).attr('data-field');
                var fieldType = $(this).attr('data-type');
                var fieldObj = {
                    field : fieldName,
                    fieldType : fieldType,
                    value : ''
                };
                var value = '';
                if(fieldType == 'picklist' && !$(this).find('select').is(':disabled')) {
                    //find the select value
                    value = $(this).find('select').val();
                }
                else if (fieldType == 'reference') 
                {
                    console.log($(this));
                    if($(this).find('select').length === 0 && $(this).find('input').val() != '000000000000000') 
                    {
                        value = $(this).find('input').val();
                    }
                    else if($(this).find('select').length == 1 && $(this).find('span.lookupInput').length == 1) 
                    {
                        if($(this).find('input').val() == '000000000000000') {
                            value = '';
                        }
                        else {
                            value = $(this).find('input').val();
                        }
                    }
                    else 
                    {
                        value = $(this).find('select').val();
                    }
                }
                else if (fieldType == 'boolean') {
                    if($(this).find('input').is(':checked')) {
                        value = 'true';
                    }
                    else {
                        value = 'false';
                    }
                }
                else 
                {
                    value = $(this).find('.get-input').val();
                }
        
                //if(value != '' && value != undefined)
                if(value != undefined && value != null && value != 'null' && value != '') 
                {
                    fieldObj.value = value;
                    sfdcFieldData.push(fieldObj);
                }
            });
            
            var jsonData = {
                uIds : [],
                tableNames : [],
                sfdcData : sfdcFieldData,
                topicData : [],
                dataType : $('#createDataLayerRecordV2').data('dataType')
            }
            var markers = $popup.data('dataLayers') || [];
            var mI = markers.length;
            while(mI--) {
                var marker = markers[mI];
                jsonData.uIds.push(marker.data.marker.uid);
                jsonData.tableNames.push(marker.data.marker.table);
            }
        
            if(objc2cSettings.fields) {
                var fields = objc2cSettings.fields;
                //loop over the saved data layer fields and try to update
                for(var key in fields) {
                    var field = fields[key];
                    if(field != '') {
                        var phpFix = key.replace('dmp_','');
                        jsonData.topicData.push({topic_id:phpFix,field:field});
                    }
                }
            }
            
            //queue the data in chunks
            MAData.createRecordFromDataLayer.getC2CDataFromServer(jsonData,function(res) {
                var arrayOfRecords = [];
        		var tempArray = [];
        		var ID_CHUNK_SIZE = 50;
        	
        	    //Split the Ids returned in the Id only query into groups of ID_CHUNK_SIZE
        		if(res.success && res.data.length > 0){
        		    var allRecordsCount = res.data.length;
        			for(var d = 0; d < allRecordsCount; d++){
        				tempArray.push(res.data[d]);
        
        				if(tempArray.length == ID_CHUNK_SIZE){
        					arrayOfRecords.push(tempArray);
        					tempArray = [];
        				}
        			}
        
        			//Add any ids from the last loop that may not have hit ID_CHUNK_SIZE array size
        			if(tempArray.length > 0){
        				arrayOfRecords.push(tempArray);
        			}	
        			
        			//Build the results object and then send this
        			var results = {
        			    errors : [],
        			    warnings : [],
            			totals : {
            			    success : 0,
            			    failure : 0
            			},
            			failures : [],
            			records : [],
            			remaining : res.data.length
        			};
        			var apexError = {
        			    hasError : false,
        			    msg : ''
        			};
        			var q = async.queue(function (options, callback) {
        			    $.ajax({
                            url: MA.resources.Tooltip+"?securityToken="+securityToken+"&action=createDataLayerRecordV2&core.apexpages.devmode.url=0",
                            type: 'POST',
                            dataType: 'JSON',
                            data: options
                        })
                        .success(function(res) {
        			        if(res.success) {
                                //get the data
                                if(res.data) {
                                    var data = res.data;
                                    var totals = data.totals || {success : 0, failure : 0};
                                    //add these to main results
                                    results.errors = results.errors.concat(data.errors || []);
                                    results.warnings = results.warnings.concat(data.warnings || []);
                                    results.failures = results.failures.concat(data.failures || []);
                                    results.records = results.records.concat(data.records || []);
                                    results.totals.success += totals.success;
                                    results.totals.failure += totals.failure;
                                    
                                    //update status
                                    
                                    var remaining = results.remaining - (totals.success + totals.failure);
                                    $('#createDataLayerRecordV2 .MA2-loading-mask .updateText').text('Adding Records to Salesforce: ' + remaining + ' of ' + allRecordsCount);
                                }
        			        }
        			        callback({success:true});
                        }).
                        error(function(res) {
                            //send an error callback and stop proccesses
                            callback({success:false,err:res});
                        });
        			});
        			q.concurrency=5;
        			
        			//create queue
        			for(var i = 0; i < arrayOfRecords.length; i++){
        				//Clone the options object
        				//var queryOptions = layerOptions;
        				var ajaxData = {
        				    objectType: $popup.find('.createrecordDataLayer2-object').val(),
                            recordTypeId: $popup.find('.createrecordDataLayer2-recordtype').val() || '',
                            fieldSetName: fieldSetName,
                		    jsonData :  JSON.stringify(arrayOfRecords[i])
        				}
        				//Add to the queue, will a call back to handle errors
        				q.push(ajaxData,function(res){
        					if(!res.success){
        					    //clear out remaining tasks because all attempts will fail
        						apexError.msg = res.error || 'An unknown error has occured';
        						var totals = results.totals;
        						apexError.hasError = true;
        						q.tasks = [];
        					}
        				});
        			}
        			
        			q.drain = function(){
                        //close this popup and open another with more data about success if mass action
                        var popupData = $('#createDataLayerRecordV2').data();
                        var popup = popupData.popup;
                        popup.close();
                        
                        var totals = results.totals;
                        var errors = results.errors;
                        var warnings = results.warnings;
                        var records = results.records;
                            
                        if(apexError.hasError) {
                            var bodyHTML = '<div class="info-header" style="font-weight:bold; text-align: center;"><span style="font-size:24px;" class="MAIcon ion-android-sad"></span> Oh snap, something went wrong</div>'+
                                            '<div class="msg-wrap" style="max-height:400px;overflow:auto; padding: 15px 0;">'+
                                                '<div style="text-align: center;" class="errors-wrap">'+apexError.msg+'</div>'+
                                                '<div style="text-align: center;" class="errors-wrap">'+totals.success+' successful, '+totals.failure+' failures</div>'+
                                            '</div>';
                                            
                            var confirmPopup = MA.Popup.showMAAlert({
                                title: 'Click2Create<sup>TM</sup> Error',
                                template: bodyHTML,
                                cancelText : 'Close',
                                width: 300
	           			    });
                        }
                        else {
                            if((!popupData.isMassAction || popupData.dataLayers.length == 1) && records.length == 1) {
                                var record = records[0];
                                MAData.createC2CDLIcon(popupData,record.id);
                            }
                            else {
                                //create a popup with more info
                                //check if any warnings
                                var warningHTML = '';
                                var warningDisplay = 'none';
                                if(warnings.length>0) {
                                    warningDisplay = 'block';
                                    var warn = warnings[0];
                                    warningHTML += '<div>'+warn+'</div>'
                                }
                                else {
                                    warningHTML += '<div>No warnings to report.</div>';
                                }
                                var errorsHTML = '';
                                var errorDisplay = 'none';
                                if(errors.length>0) {
                                    for(var e = 0; e < errors.length; e++) {
                                        errorDisplay = 'block';
                                        if(e === 20) {break;}
                                        var err = errors[e];
                                        errorsHTML += '<div>'+err+'</div>';
                                    }
                                }
                                else {
                                  errorsHTML  += '<div>No errors to report.</div>';
                                }
                                //build the popup body
                                bodyHTML = '<div class="info-header" style="font-weight:bold;text-align:center;">Successfully created '+totals.success + ' records with ' + totals.failure + ' failure(s)</div>'+
                                            '<div class="msg-wrap" style="max-height:400px;overflow:auto; padding: 15px 0;">'+
                                                '<div class="errors-wrap" style="margin-bottom: 15px; display:'+errorDisplay+';"><div style="font-weight:bold;color:#CB2929;">Errors:</div>'+errorsHTML+'</div>'+
                                                '<div class="warnings-wrap" style="display:'+errorDisplay+';"><div style="font-weight:bold; color: #c93;">Warnings:</div>'+warningHTML+'</div>'+
                                            '</div>';
                                //open new popup with more info
                                var confirmPopup = MA.Popup.showMAAlert({
                                    title: 'Click2Create<sup>TM</sup> Results',
                                    template: bodyHTML,
                                    width: 400
    	           			    });
                            }
                        }
        			}
        		}
            });
        }
	},
	
	createC2CDLIcon : function (popupData,recordId) {
        //get the first record
        var dataLayerInfo = popupData.dataLayers[0];
        recordId = recordId || '';
        var recordName = dataLayerInfo.title || '';
        var markerShape = MA.Marker.shapes['Favorite'];
        var marker;
        if (!(window.ActiveXObject) && "ActiveXObject" in window) {
            marker = new RichMarker({
                map: MA.map,
                position: dataLayerInfo.getPosition(),
                anchor: markerShape.anchor.Rich,
                flat: true,
                zIndex: 1000,
                title: recordName,
                record: { record: { Id: recordId } },
                content: MA.Marker.createSVG({ type: 'Marker', color: '#FF8800:Favorite' })
            });
        }
        else {
            marker = new google.maps.Marker({
                map: MA.map,
                position: dataLayerInfo.getPosition(),
                icon: {
                    url: 'data:image/svg+xml;base64,'+CryptoJS.enc.Base64.stringify(CryptoJS.enc.Utf8.parse(MA.Marker.createSVG({ type: 'Marker', color: '#FF8800:Favorite' }))),
                    anchor: markerShape.anchor
                },
                zIndex: 1000,
                title: recordName,
                record: { record: { Id: recordId } }
            });
        }
        marker.record.marker = marker;
        MA.Map.click2CreateMarkers.push(marker);

        //handle marker click
        google.maps.event.addListener(marker, 'click', function ()
        {
            //create tooltip content
            var $tooltipContent = $([
                '<div>',
                    '<div class="tooltip-header">',
                        '<div class="name"><a target="_blank" style="font-family: helvetica,arial,sans-serif;font-size: 12px;color: #2265BB;font-weight: bold;text-decoration: none;white-space: normal;" /></div>',
                        '<div class="address" style="margin: 3px 0 5px 0;padding: 0;font-family: helvetica,arial,sans-serif;font-size: 11px;font-weight: bold;text-decoration: none;color: #000;white-space: normal;" />',
                    '</div>',
                    '<div class="layout-tooltip">',
                        '<div class="buttonset-section-columns">',
                            '<div class="buttoncolumn"><div class="actionbutton">Add to Route</div></div>' +
                            '<div class="buttoncolumn"><div class="actionbutton">Take Me There</div></div>' +
                            //'<div class="buttoncolumn"><div class="actionbutton checkin">Check In</div></div>' +
                            '<div class="buttoncolumn"><div class="actionbutton">Remove Marker</div></div>' +
                        '</div>',
                    '</div>',
                '</div>'
            ].join(''));

            //populate values
            if (sforce && sforce.one) {
                $tooltipContent.find('.name a').attr('href', '#').text(recordName).click(function () { sforce.one.navigateToSObject(recordId) });
            }
            else {
                $tooltipContent.find('.name a').attr('href', MA.SitePrefix+'/'+recordId).text(recordName);
            }
            //$tooltipContent.find('.address').text(geoResponse.result.FormattedAddress).click(function () { launchNativeGPS(marker.getPosition().lat(), marker.getPosition().lng()); });

            //update check in button to check out if needed
            if (marker.record.record.Tasks) {
                 $.each(marker.record.record.Tasks.records || [], function (index, task) {
                     if (!task.IsClosed) {
                         $tooltipContent.find('.actionbutton.checkin').data('CheckInId', task.Id).text('Check Out');
                         return false;
                     }
                 });
            }

            //launch infobubble
            MA.Map.InfoBubble.show({
                position: this.getPosition(),
                anchor: marker,
                minWidth: 420,
                content: $tooltipContent.get(0)
            });

            //handle action button clicks
            $tooltipContent.find('.actionbutton').click(function () {
                switch ($(this).text())
                {
                    case 'Add to Route':
                        var c2cRec = {
                            id : recordId,
                            baseObject : '{C2C}'+$('#createrecord-object').val()
                        }
                        MAActionFramework.standardActions['Add to Trip'].ActionValue({
                            customMarkers: [{ type: 'dataLayer', title: recordName, latlng: marker.getPosition(), address: '', c2cRec : c2cRec }]
                        });

                    break;
                    case 'Take Me There':

                        MAActionFramework.standardActions['Take Me There'].ActionValue({
                            customMarkers: [{ type: 'dataLayer', title: recordName, latlng: marker.getPosition(), address: '' }]
                        });

                    break;
                    case 'Remove Marker':

                        marker.setMap(null);

                    break;
                }
                MA.Map.InfoBubble.hide();
            });
        });

        
        
        //click the marker
        google.maps.event.trigger(marker, 'click');
	},
	
	deleteDataLayer : function (layerId) {
        $.ajax({
           url: MA.resources.Tree+"?securityToken="+securityToken+"&action=delete_layer",
           type: 'POST',
           dataType: 'JSON',
           data: {
               id : layerId
           }
        })
        .done(function(res) {
           if (NewLayerNavigationEnabled())
        	{
        	    MALayers.refreshFolder();
        	    showSuccess($('#mapdiv'), 'Successfully deleted this data layer.');
        	}
            else
            {
                var layerId = res.id;
                if (layerId)
            	{
            		//update
            		var $node = $('#SQTree li[id="'+layerId+'"]');
            		$node.remove();
            		showSuccess($('#mapdiv'), 'Successfully deleted this data layer.');
            	}
            }
        })
        .error(function(res) {
           console.log(res);
        });
	},
	
	wizard : {
	    firstOpen : true,
	    resetPopup : function (keepHeader) {
	        if(!keepHeader) {
    	        // clear out name desc...
    	        $('#dl-details').click()
    	        $('#MADataLayerEditor .dl-label').val('');
    	        $('#MADataLayerEditor .dl-desc').val('');
    	        MA.Util.resetCombobox($("#countryV2"))
    	        $('#MADataLayerEditor').removeData();
    	        $('#dl-legend-options .dl-legend-title').val('');
	            $('#dl-legend-options .dl-legend-subtitle').val('');
	        }
	        $('#MADataLayerEditor').removeData('popupData');
	        $('#MADataLayerEditor').removeData('topicData');
	        $('#MADataLayerEditor').removeData('levelData');
	        $('#MADataLayerEditor').removeData('layerType');
	        $('#MADataLayerEditor').removeData('topics');
	        //reset the data source tab
	        MA.Util.resetCombobox($("#datasourceV2"));
	        MA.Util.resetCombobox($("#topicV2"));
	        MA.Util.resetCombobox($("#groupbyV2"));
	        $('.dl-legend-topic').val($('.dl-legend-topic option:first').val());
	        $('#MADataLayerEditor .notificationMsg').removeClass('error').text('').hide();
	        //clear any stored data
	        $('#MADataLayerEditor .dl-autoLegend').attr('disabled','disabled');
	        
	        //empty data selctions
	        $('#datasourceV2').find('option:gt(0)').remove();
	        $('#topicV2').find('option:gt(0)').remove();
	        $('#groupbyV2').find('option:gt(0)').remove();
	        $('#dl-legend-options .dl-legend-topic').empty();
            $('#dl-legend-opacity .dl-legend-opacity').val('50');
	        
	        //empty filters
	        $('#dl-filters-wrapper').empty();
	        $('#dl-legend-info-wrapper').empty();
	        $('#dl-tooltip-header-info-wrapper .dl-tooltip-rows').empty();
	        $('#dl-tooltip-tabs-wrap .dl-tooltip-tabs-wrapper').empty();
	        
            //empty legend
            $('#dl-legend-options .dl-legend-step1, #dl-legend-options .dl-legend-step2,#dl-legend-options .rightPanel').addClass('hidden');

	        //create to tooltip header row
	        
	        MAData.wizard.createToolipRow({element:$('#dl-tooltip-header-addRow'),type:'header'});
	    },
        launchPopup : function (options) {
            //reset the info
            MAData.wizard.resetPopup();
            LaunchPopupWindow($('#MADataLayerEditor'),900);
            var $popup = $('#MADataLayerEditor');
            $popup.data('folder-id',options.folderId);
            $popup.data('folder-id-actual',options["folder-id-actual"]);
            
            if(options.layerId) {
                $popup.data('layer-id',options.layerId);
                var isClone = options.isClone || false;
                $popup.data('isClone',isClone);
                $popup.find('.savePlotDataLayer').text('Save and Refresh');
                $popup.data('isRefresh',true);
                $popup.data('plottedLayer',options.plottedLayer);
                //get the layer info
                MAData.wizard.getLayerInfo({id:options.layerId, isClone: isClone});
            }
            else {
                $popup.find('.savePlotDataLayer').text('Save and Plot');
                $popup.data('isRefresh',false);
            }
            
            if(options.saveOnly) {
                $popup.find('.savePlotDataLayer').text('Save and Plot');
                $popup.data('isRefresh',false);
            }
            
            //init combobox
            if(MAData.wizard.firstOpen) {
                $popup.find('.DemographicTable select').combobox();
                MAData.wizard.firstOpen = false;
            }
            
        },
        getLayerInfo : function (options) {
            var id = options.id;
            $('#getLayerLoading').show();
            //get the data
            $.ajax({
               url: MA.resources.Tree+"?securityToken="+securityToken+"&action=get_layer",
               type: 'POST',
               dataType: 'JSON',
               data: {
                   layerId : id
               }
           })
           .done(function(res) {
               if(res.success) {
                   $popup = $('#MADataLayerEditor').attr('isLoading','true');
                   var data = res.data;
                   
                   //update the name and desc
                   $popup.find('.dl-label').val(data.Name);
                   $popup.find('.dl-desc').val(data.sma__Description__c);
                   
                   //update the data source
                   var options;
                   try{
                        options = JSON.parse(data.sma__Options__c);
                   }
                   catch(e) {
                       //can't parse json, show error
                       $('#getLayerLoading').hide();
                       $('#MADataLayerEditor .notificationMsg').addClass('error').text('Something went wrong and this layer has been corrupted, it will need to be recreated.').show();
                       return;
                   }
                   
                   
                    //update the data source
                    var intervalOpen = true;
                    var legendFinished = false;
                    var filterTopicsFinished = false;
                    var popupFinished = false;
                    var int = setInterval(function(){
                       //wait for country options
                       if($('#countryV2 option').length > 1) {
                            clearInterval(int);
                            //update country
                            //$popup.find('#countryV2').val(options.country_id).change();
                            $popup.find('#countryV2').val(options.country_id).next().find('input').val($popup.find('#countryV2 option:selected').text());
                            $popup.find('#countryV2').change();
                            
                            //wait for source options
                            var int1 = setInterval(function(){
                               if($('#datasourceV2 option').length > 1) {
                                   clearInterval(int1);
                                   //update the source and wait for next select
                                   $popup.find('#datasourceV2').val(options.file_id).next().find('input').val($popup.find('#datasourceV2 option:selected').text());
                                   $popup.find('#datasourceV2').change();
                                   
                                   //wait for topic options
                                   var int2 = setInterval(function(){
                                       if($('#topicV2 option').length > 1) {
                                            clearInterval(int2);
                                            //update the source and wait for next select
                                            $popup.find('#topicV2').val(options.topic_id).next().find('input').val($popup.find('#topicV2 option:selected').text());
                                            $popup.find('#topicV2').change();

                                           //wait for level options
                                           var int3 = setInterval(function(){
                                               if($('#groupbyV2 option').length > 1) {
                                                   clearInterval(int3);
                                                   //update the source and wait for next select
                                                   $popup.find('#groupbyV2').val(options.level_id).next().find('input').val($popup.find('#groupbyV2 option:selected').text());
                                                   $popup.find('#groupbyV2').change();
                                                   intervalOpen = false;
                                               }
                                           },100);
                                       }
                                   },100);
                               }
                           },100);
                       }
                    },100);
                   
                   //let's make sure all intervals are cleared if something goes wrong or after 10 sec
                   setTimeout(function() {
                       if(intervalOpen) {
                           try{clearInterval(int1);}catch(e){}
                           try{clearInterval(int2);}catch(e){}
                           try{clearInterval(int3);}catch(e){}
                           
                           //show error and return
                           MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                           return;
                       }
                   },10000);
                   
                   //if we have no issues, let's update the rest of the info
                   var nextIndex = 1;
                   var updateLayerInt = setInterval(function() {
                       if(!intervalOpen){
                           
                           clearInterval(updateLayerInt);
                           //update the filters
                           var filters = options.filters || [];
                           if(filters.length > 0) {
                               //get the topics
                               MAData.wizard.getFilterTopics(function (res) {
                                   if(res.success) {
                                       //loop over the filters and create rows
                                       for(var f = 0; f < filters.length; f++) {
                                           var filter = filters[f];
                                           //create rows 
                                           MAData.wizard.createFilterRow(filter);
                                           filterTopicsFinished = true;
                                       }
                                   }
                                   else {
                                       filterTopicsFinished = true;
                                   }
                               });
                           }
                           else {
                               filterTopicsFinished = true;
                           }
                           
                            //update the popup
                            var popup = options.popup || {};
                            var header = popup.header || [];
                            var tabs = popup.tabs || [];
                            var opacity = options.opacity || 50;
                            $popup.find('.dl-legend-opacity').val(opacity);
                            $('#dl-legend-options .rightPanel').removeClass('hidden');
                            if($('#MADataLayerEditor').data('layerType') == 'polygon') {
                                $('#dl-legend-opacity').removeClass('hidden');
                            }
                            //make sure we have popup info
                            MAData.wizard.getPopupTopics(function(res) {
                              if(res.success) {
                                    var popupData = res.data;
                                    
                                    //empty the headers
                                    $('#dl-tooltip-header-info-wrapper .dl-tooltip-rows').empty();
                                    for(var h = 0; h < header.length; h++) {
                                        var hRow = header[h];
                                        //create the row
                                        MAData.wizard.createToolipRow({element:$('#dl-tooltip-header-addRow'),type:'header',data:hRow}); 
                                    }
                                    for(var t = 0; t < tabs.length; t++) {
                                        var tab = tabs[t];
                                        MAData.wizard.createTooltipTab(tab);
                                    }
                                    popupFinished = true;
                                    
                                    
                                }
                                else {
                                    popupFinished = true;
                                }
                            });
                            
                            if(!$('#MADataLayerEditor').data('topics')) {
                                $.getJSON( MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&level_id=" + $('#groupbyV2').val(), function( data ) {
                
                        			if (data.success && data.data.length > 0)
                        			{
                        			    //store the data for easy creation later
                        			    $('#MADataLayerEditor').data('topics',data.data);
                        			    
                        			    var filterSelectHTML = '<select class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
                
                        				filterSelectHTML += '<option value="" disabled selected>Please select a topic</option>';
                        
                        				$.each(data.data, function( index, value ) {
                                           filterSelectHTML += '<option data-type="'+value.filter_type+'" value="' + value.topic_id + '">'+ value.topic_name +'</option>';
                        				});
                        			    
                        			    //update the legend topics
                        			    //temp change to disable strings
                				        $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                				        
                				        
                				        //update the legend
                                       //update the title and subtitle
                                       $('#dl-legend-options .rightPanel').removeClass('hidden');
                                       $('#dl-legend-options .dl-legend-title').val(options.legend.title);
                                       $('#dl-legend-options .dl-legend-subtitle').val(options.legend.subTitle);

                                       
                                       var legendRows = options.legend.rows || [];
                                       //empty the legend rows just to be sure
                                       $('#dl-legend-info-wrapper').empty();
                                       for(var l = 0; l < legendRows.length; l++) {
                                           var row = legendRows[l];
                                           
                                           if(l === 0) {
                                               //only update the topic on the first legend
                                               $('#dl-legend-options .dl-legend-topic').val(row.topic_id).change();
                                           }
                                           
                                           //update the topic select
                                           row.isSaved = true;
                                           if(row.values && row.values == '--Other--') {
                                               row.isOther = true;
                                           }
                                           MAData.wizard.createLegendRow(row);
                                       }
                                       legendFinished = true;
                        			}
                        			else {
                        			    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                        			    
                        			    var filterSelectHTML = '<select class="dl-filter-topic">';
                
                        				filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
                        				filterSelectHTML += '</select>';
                        				$('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                        				legendFinished = true;
                        			}
                        		});
                            }
                            else {
                                
                            }
                           
                       }
                   },500);
                   
                   //interval for everything complete
                   var completeInt = setInterval(function() {
                       //console.log(popupFinished,legendFinished,filterTopicsFinished,!intervalOpen);
                       if(popupFinished && legendFinished && filterTopicsFinished && !intervalOpen) {
                           clearInterval(completeInt);
                           $('#dl-legend-options .rightPanel').removeClass('hidden');
                           $popup.find('.dl-legend-auto').val('custom');
                            if($('#MADataLayerEditor').data('layerType') == 'polygon') {
                                $('#dl-legend-opacity').removeClass('hidden');
                            }
                          $('#getLayerLoading').hide();
                          $('#MADataLayerEditor').attr('isLoading','false');
                       }
                   },500);
               }
           })
           .error(function(res) {
               console.log(res);
               $('#getLayerLoading').hide();
           });
        },
        closePopup : function () {
            ClosePopupWindow();
            MAData.wizard.resetPopup();
        },
        globalTimeout : null,
        changeTab : function (tab) {
            $tab = $(tab);
            var tabId = $tab.attr('id');
            $('#MADataLayerEditor .DemographicTable .ui-combobox input').removeClass('error');
            
            if(tabId == 'dl-details') {
                $('.dl-panel').addClass('hidden');
                $('.dl-panel[data-id="'+tabId+'"]').removeClass('hidden');
                MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                $tab.addClass('active');
                return;
            }
            
            //make sure we have a name and desc before continuing
            if(tabId != 'dl-details'){
                $('#MADataLayerEditor .dl-label').removeClass('error');
                if($('#MADataLayerEditor .dl-label').val() == '') {
                    $('#MADataLayerEditor .dl-label').addClass('error');
                    return;
                }
            }
            
            //make sure we have a data source selected 
            if(tabId != 'dl-dataSource') {
                //loop over data source selections
                if($('#countryV2').val() == '--') {
                    $('#countryV2').next().find('input').addClass('error');
                    return;
                }
                else if($('#datasourceV2').val() == '--') {
                    $('#datasourceV2').next().find('input').addClass('error');
                    return;
                }
                else if($('#topicV2').val() == '--') {
                    $('#topicV2').next().find('input').addClass('error');
                    return;
                }
                else if($('#groupbyV2').val() == '--') {
                    $('#groupbyV2').next().find('input').addClass('error');
                    return;
                }
                else {
                    //determin the type for easy access
                    if(!$('#MADataLayerEditor').data('layerType')) {
                        var levelData = $('#MADataLayerEditor').data('levelData') || [];
                        var currentLevel = $('#groupbyV2').val();
                        var type = '';
                        for(var l = 0; l < levelData.length; l++) {
                            var level = levelData[l];
                            if(level.level_id == currentLevel) {
                                $('#MADataLayerEditor').data('layerType',level.geo_type);
                            }
                        }
                    }
                
                    //get the topic data
                    if(!$('#MADataLayerEditor').data('topics')) {
                        MA.Popup.showLoading({display:true,popupId:'MADataLayerEditor'});
                        $.getJSON( MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&level_id=" + $('#groupbyV2').val(), function( data ) {
        
                			if (data.success && data.data.length > 0)
                			{
                			    //store the data for easy creation later
                			    $('#MADataLayerEditor').data('topics',data.data);
                			    
                			    var filterSelectHTML = '<select class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
        
                				filterSelectHTML += '<option value="" disabled selected>Please select a topic</option>';
                
                				$.each(data.data, function( index, value ) {
                                   filterSelectHTML += '<option data-type="'+value.filter_type+'" value="' + value.topic_id + '">'+ value.topic_name +'</option>';
                				});
                			    filterSelectHTML += '</select>';
                			    //update the legend topics
                			    //temp change to disable strings
        				        $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
        				        
        				        var levelData = $('#MADataLayerEditor').data('levelData') || [];
                                var currentLevel = $('#groupbyV2').val();
                                var geo_type = '';
                                for(var l = 0; l < levelData.length; l++) {
                                    var level = levelData[l];
                                    if(level.level_id == currentLevel) {
                                        geo_type = level.geo_type;
                                    }
                                }
                                if(geo_type == 'polygon') {
            				        $('#dl-legend-options .dl-legend-topic option').each(function(i,opt) {
            				            var $opt = $(opt);
            				            if($opt.attr('data-type') == 'string') {
            				                $opt.attr('disabled','disabled');
            				            }
            				        });
                                }
                			    
                			    //change the panel
                                $('.dl-panel').addClass('hidden');
                                $('.dl-panel[data-id="'+tabId+'"]').removeClass('hidden');
                                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                                $tab.addClass('active');
                                MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                			}
                			else {
                			    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                			    
                			    var filterSelectHTML = '<select class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
        
                				filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
                				filterSelectHTML += '</select>';
                				$('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                				
                				//change the panel
                                $('.dl-panel').addClass('hidden');
                                $('.dl-panel[data-id="'+tabId+'"]').removeClass('hidden');
                                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                                $tab.addClass('active');
                                MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                			}
                		});
                    }
                    else {
                        //change the panel
                        $('.dl-panel').addClass('hidden');
                        $('.dl-panel[data-id="'+tabId+'"]').removeClass('hidden');
                        $('#MADataLayerEditor .sidebar .item').removeClass('active');
                        $tab.addClass('active');
                    }
                    
                    if(!$('#MADataLayerEditor').data('popupData')) {
                        MAData.wizard.getPopupTopics();
                    }
                }
            }
            else {
                //change the panel
                $('.dl-panel').addClass('hidden');
                $('.dl-panel[data-id="'+tabId+'"]').removeClass('hidden');
                MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                $tab.addClass('active');
            }
            
            if(tabId == 'dl-tooltip') {
                //make sure we have the file info
                if(!$('#MADataLayerEditor').data('popupData')) {
                    MAData.wizard.getPopupTopics();
                }
            }
            
            //add row to filters if needed
            if(tabId == 'dl-filters') {
                //check if we have any
                var filterLength = $('#dl-filters-wrapper .dl-filter-row').length;
                if(filterLength === 0) {
                    //add filters
                    if(!$('#MADataLayerEditor').data('topics')) {
                       MAData.wizard.getFilterTopics(function (res) {
                           if(res.success) {
                               MAData.wizard.createFilterRow();
                               MAData.wizard.createFilterRow();
                               MAData.wizard.createFilterRow();
                           }
                       });
                   }
                   else {
                       MAData.wizard.getFilterTopics(function (res) {
                           if(res.success) {
                               MAData.wizard.createFilterRow();
                               MAData.wizard.createFilterRow();
                               MAData.wizard.createFilterRow();
                           }
                       });
                   }
                }
            }
        },
        
        getPopupTopics : function (callback) {
            callback = callback || function(){};
            if($('#groupbyV2').val() == '--') {
                callback({success:false, data: []});
                return;
            }
            MA.Popup.showLoading({display:true,popupId:'MADataLayerEditor'});
            if($('#MADataLayerEditor').data('popupData'))
            {
                callback({success:true,data:$('#MADataLayerEditor').data('popupData')});
                MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
            }
            else {
                $.getJSON( MAData.domain+"/info/index.php?action=get_data_for_popup&orgid=" + MAData.orgId + "&level_id=" + $('#groupbyV2').val(), function( res ) {
        
        			if (res.success && res.data.length > 0)
        			{
        			    $('#MADataLayerEditor').data('popupData',res.data);
        			    callback({success:true,data:res.data});
        			}
        			else {
        			    callback({success:false, data: []});
        			}
        			MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                });
            }
        },
        
        tempUpdateGroupByLegend : function() {
            //clear topics
            $('#MADataLayerEditor').removeData('topics');
            $('#dl-filters-wrapper .dl-row').remove();
            $('#dl-legend-options .dl-legend-step1, #dl-legend-options .dl-legend-step2,#dl-legend-options .rightPanel').addClass('hidden')
            
            //clear legend
            $('#dl-legend-info-wrapper .dl-row').remove();
            
            //make sure level data is present, may take a sec to load
            var levelInt = setInterval(function() {
                if($('#MADataLayerEditor').data('levelData')) {
                    clearInterval(levelInt);
                    var levelData = $('#MADataLayerEditor').data('levelData');
                    var currentLevel = $('#groupbyV2').val();
                    var geo_type = '';
                    for(var l = 0; l < levelData.length; l++) {
                        var level = levelData[l];
                        if(level.level_id == currentLevel) {
                            geo_type = level.geo_type;
                        }
                    }
                    if(geo_type == 'polygon') {
        		        $('#dl-legend-options .dl-legend-topic option').each(function(i,opt) {
        		            var $opt = $(opt);
        		            if($opt.attr('data-type') == 'string') {
        		                $opt.attr('disabled','disabled');
        		            }
        		        });
                    }
                    else {
                        $('#dl-legend-options .dl-legend-topic option').each(function(i,opt) {
        		            var $opt = $(opt);
        		            if($opt.attr('data-type') == 'string') {
        		                $opt.removeAttr('disabled');
        		            }
        		        });
                    }
                    
                    $('#MADataLayerEditor').data('layerType',geo_type);
                }
            },500);
        },
        
        createFilterRow : function (options) {
            var $row = $('#templates .dl-filter-row').clone();
            
            $row.on('click','.remove-row',function() {
               var $r = $(this).closest('.dl-filter-row');
               $r.remove();
               
               //if there are no rows just add one
               if($('#dl-filters-wrapper .dl-filter-row').length == 0) {
                   //if we do not have topics make one call to update
                   if(!$('#MADataLayerEditor').data('topics')) {
                       MAData.wizard.getFilterTopics(function (res) {
                           if(res.success) {
                               //loop over the filters and create rows
                               MAData.wizard.createFilterRow();
                           }
                       });
                   }
                   else {
                       MAData.wizard.createFilterRow();
                   }
               }
            });
            
            //handle autocomplete
            $row.on('keyup','.dl-filter-value-start',function() {
                var $input = $(this);
                var $wrap = $input.closest('.dl-filter-value-wrapper');
                
                //remove previous
                if($('.topic-autoComplete').length >0) {
                    $('.topic-autoComplete').remove();
                }
                //only autocomplete is string value
                if($row.find('.dl-filter-topic').val() != '--' && $row.find('.dl-filter-topic option:selected').attr('data-type') == 'string') {
                    $wrap.addClass('wait');
                    if (MAData.wizard.globalTimeout != null) {
                        clearTimeout(MAData.wizard.globalTimeout);
                    }
                    MAData.wizard.globalTimeout = setTimeout(function() {
                        MAData.wizard.globalTimeout = null; 
                        if($input.val() == '') {
                            $wrap.removeClass('wait');
                            return;
                        }
                        
                        //run search if no keyup for 1 second
                        $.ajax({
                            url: MAData.domain+"/info/index.php?action=get_autocomplete&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&topic_id=" + $row.find('.dl-filter-topic').val() + "&level_id=" + $('#groupbyV2').val() + "&search=" + $input.val(),
                            type: 'GET',
                            dataType: 'JSON',
                            data: {}
                        })
                        .success(function(res) {
                            $wrap.removeClass('wait');
                            //remove previous
                            if($('.topic-autoComplete').length >0) {
                                $('.topic-autoComplete').remove();
                            }
                            if(res.success) {
                                var data = res.data || [];
                                var listHTML = '';
                                for(var a = 0; a < data.length; a++) {
                                    var item = data[a];
                                    var li = '<li>'+item+'</li>';
                                    listHTML += li;
                                }
                                
                                if(data.length == 0) {
                                    return;
                                }
                                //create popup
                                var offset = $input.offset();
                                var offsetTop = (offset.top + 25) + 'px';
                                var offsetLeft = offset.left + 'px';
                                var $popupTemp = $('#templates .autocompleteWrapper').clone();
                                $popupTemp.find('.autocompleteList').html(listHTML);
                                var $bubble = $popupTemp
                                    .addClass('bubble top topic-autoComplete')
                                    .css({ position: 'absolute', top: offsetTop, left: offsetLeft, width: 200})
                                    .appendTo('body')
                                    .on('click', function (e) { e.stopPropagation(); })
                                ;
                                
                                $bubble.on('click','.autocompleteList li',function() {
                                    //hide list and set value
                                    var $item = $(this);
                                    $bubble.remove();
                                    $input.val($item.text());
                                });
                                
                                $bubble.on('click','.ac-button-close',function() {
                                    $bubble.remove();
                                })
                            }
                            else {
                                $wrap.removeClass('wait');
                            }
                        })
                        .error(function(res) {
                            console.log(res);
                            $wrap.removeClass('wait');
                        });
                    }, 500); 
                }
            });
            
            if($('#MADataLayerEditor').data('topics')) {
                var topicData = $('#MADataLayerEditor').data('topics');
                
                var filterSelectHTML = '<select class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
    
				filterSelectHTML += '<option value="--" disabled selected>Please select a topic</option>';

				$.each(topicData, function( index, value ) {
                   filterSelectHTML += '<option data-type="'+value.filter_type+'" value="' + value.topic_id + '">'+ value.topic_name +'</option>';
				});

				$row.find('.dl-filter-topic-wrap').html(filterSelectHTML);
				
				if($('#dl-legend-options .dl-legend-topic option').length === 0) {
				    $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
				}
				
				$('#dl-filters-wrapper').append($row);
                
            }
            else {
                $.getJSON( MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&level_id=" + $('#groupbyV2').val(), function( data ) {
    
        			if (data.success && data.data.length > 0)
        			{
        			    //store the data for easy creation later
        			    $('#MADataLayerEditor').data('topics',data.data);
        				var filterSelectHTML = '<select class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
        
        				filterSelectHTML += '<option value="--" disabled selected>Please select a topic</option>';
        
        				$.each(data.data, function( index, value ) {
                           filterSelectHTML += '<option data-type="'+value.filter_type+'" value="' + value.topic_id + '">'+ value.topic_name +'</option>';
        				});
        
        				$row.find('.dl-filter-topic-wrap').html(filterSelectHTML);
        			    
        				$('#dl-filters-wrapper').append($row);
        				
        				//update the legend topics
        				$('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
        			}
        			else if(data.success) {
        			    $('#MADataLayerEditor').data('topics',[]);
        			    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
        			    
        			    var filterSelectHTML = '<select class="dl-filter-topic">';

        				filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
        				filterSelectHTML += '</select>';
        				$('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
        			}
        			else {
        			    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
        			    
        			    var filterSelectHTML = '<select class="dl-filter-topic">';

        				filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
        				filterSelectHTML += '</select>';
        				$('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
        			}
        		});
            }
            
            $row.find('.dl-filter-topic').combobox();
			$row.find('.dl-filter-operator').combobox();
			
			if(options) {
			    $row.find('.dl-filter-topic').val(options.topic_id).next().find('input').val($row.find('.dl-filter-topic option:selected').text());
                $row.find('.dl-filter-topic').change();
                $row.find('.dl-filter-operator').val(options.operator).next().find('input').val($row.find('.dl-filter-operator option:selected').text());
                $row.find('.dl-filter-operator').change();
                if(options.operator == 'range') {
                    $row.find('.dl-filter-value-start').val(options.min);
                    $row.find('.dl-filter-value-end').val(options.max);
                }
                else {
                    $row.find('.dl-filter-value-start').val(options.values);
                }
			}
            
        },
        getFilterTopics : function (callback) {
            if($('#datasourceV2').val() == '--' || $('#groupbyV2').val() == '--') {
                callback({success:false});
                return;
            }
            callback = callback || function(){};
            $.getJSON( MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&level_id=" + $('#groupbyV2').val(), function( data ) {
    
    			if (data.success && data.data.length > 0)
    			{
    			    //store the data for easy creation later
    			    $('#MADataLayerEditor').data('topics',data.data);
    			    callback({success:true});
    			}
    			else
    			{
    				//Error! Read message property
    				//console.log(data.message);
    				callback({success:false});
    			}
    		});
        },
        
        updateLegend : function () {
            //clear all old
            $('#dl-legend-info-wrapper').empty();
            $('#dl-legend-options .dl-legend-auto').change();
            $('#dl-legend-options .rightPanel').addClass('hidden');
            //hide previous options
            $('#dl-legend-options .dl-legend-step1').removeClass('hidden');
            $('#dl-legend-options .dl-legend-step2').addClass('hidden');
            
            var dataType = $('#dl-legend-options .dl-legend-topic option:selected').attr('data-type');
            if (dataType == 'decimal') {
                //disable auto legend, not supported
                $('#dl-legend-legendSelect .dl-legend-auto option[data-type="decimal"]').removeAttr('disabled');
                $('#dl-legend-options .dl-legend-auto').val('auto').change();
            }
            else {
                $('#dl-legend-legendSelect .dl-legend-auto option[data-type="decimal"]').attr('disabled','disabled');
                $('#dl-legend-options .dl-legend-auto').val('custom').change();
            }
            
            if($('#MADataLayerEditor').attr('isLoading') != 'true') {
                if ($('#dl-legend-options .dl-legend-row').length == 0) {
                    MAData.wizard.createLegendRow();
                }
                
                if($('#MADataLayerEditor').data('layerType') && $('#MADataLayerEditor').data('layerType') == 'point') {
                    //create a row for other
                    MAData.wizard.createLegendRow({isOther:true, color:'#93c47d', pointType: 'Circle'});
                }
            }

            if($('#MADataLayerEditor').data('layerType') == 'polygon') {
                $('#dl-legend-opacity').removeClass('hidden');
            }
            var datasource = $('#datasourceV2 option:selected').val();
            if(datasource.indexOf('dmp') >=0) {
    		    $('#dl-legend-legendSelect .dl-legend-auto option[data-type="decimal"]').attr('disabled','disabled');
    		    $('#dl-legend-options .dl-legend-auto').val('custom').change();
    		}
        },

        showLegendOptions : function () {
            var legendType = $('#dl-legend-options .dl-legend-auto').val();
            $('#dl-legend-options .dl-legend-step2').addClass('hidden');
            $('#dl-createLegend-btn').removeClass('hidden');
            if($('#MADataLayerEditor').data('layerType') == 'polygon') {
                $('#dl-legend-opacity').removeClass('hidden');
            }
            switch(legendType) {
                case 'auto':
                    //just show the button
                    break;
                case 'quartiles':
                    //needs buckets
                    $('#dl-legend-buckets').removeClass('hidden');
                    break;
                case 'distribution':
                    //needs buckets max and min
                    $('#dl-legend-buckets').removeClass('hidden');
                    $('#dl-legend-minVal').removeClass('hidden');
                    $('#dl-legend-maxVal').removeClass('hidden');
                    break;
                case 'custom':
                    //empty the list
                default:
                    //auto
            }
        },

        removeError : function() {
             $('#MADataLayerEditor .notificationMsg').hide().removeClass('error').html('');
        },
        
        createLegend : function (type) {
            var type = $('#dl-legend-options .dl-legend-auto').val();
            var fileId = $('#datasourceV2').val();
            var topicId = $('#dl-legend-options .dl-legend-topic').removeClass('error').val();
            $('#dl-legend-options .dl-legend-buckets').removeClass('error');
            var levelId = $('#groupbyV2').val();
            $('#dl-legend-info-wrapper').empty();
            $('#dl-addLegendRow-btn').addClass('hidden');
            var urlString = ''
            var doAJAX = true;
            if(topicId == '--') {
                $('#dl-legend-options .dl-legend-topic').addClass('error');
                return;
            }
            if(type == 'auto') {
                urlString = MAData.domain+"/info/index.php?action=get_suggested_legend&orgid=" + MAData.orgId + "&file_id=" + fileId + "&topic_id=" + topicId + "&level_id=" + levelId;
            }
            else if (type == 'quartiles') {
                if($('#dl-legend-options .dl-legend-buckets').val() == '' || isNaN($('#dl-legend-options .dl-legend-buckets').val()) || $('#dl-legend-options .dl-legend-buckets').val() > 60) {
                    $('#dl-legend-options .dl-legend-buckets').addClass('error');
                    $('#MADataLayerEditor .notificationMsg').addClass('error').html('<div class="inline" style="width: 85%; padding:0 10px;">Number of buckets must be a number and below 60.</div><div style="float:right;"><button onclick="MAData.wizard.removeError();" class="MAbutton button-clear button-red remove-error ion-android-cancel" style="font-size: 14px;"></button></div>').show();
                    return;
                }
                var buckets = $('#dl-legend-options .dl-legend-buckets').val();
                if(buckets == '') {
                    return;
                }
                urlString = MAData.domain+"/info/index.php?action=get_quartiles&orgid=" + MAData.orgId + "&file_id=" + fileId + "&topic_id=" + topicId + "&level_id=" + levelId + "&buckets=" + buckets;
            }
            else if (type == 'distribution') {
                var min = $('#dl-legend-options .dl-legend-minVal').val();
                var max = $('#dl-legend-options .dl-legend-maxVal').val();
                var buckets = $('#dl-legend-options .dl-legend-buckets').val();
                
                if(min == '' || buckets == '' || max == '') {
                    $('#MADataLayerEditor .notificationMsg').addClass('error').html('<div class="inline" style="width: 85%; padding:0 10px;">The \'Number of buckets\', \'Minimum\', and \'Maximum\' values are required. Please update these fields before continuing</div><div style="float:right;"><button onclick="MAData.wizard.removeError();" class="MAbutton button-clear button-red remove-error ion-android-cancel" style="font-size: 14px;"></button></div>').show();
                    return;
                }
                if(buckets > 60) {

                    $('#MADataLayerEditor .notificationMsg').addClass('error').html('<div class="inline" style="width: 85%; padding:0 10px;">The \'Number of buckets\' field cannot be greater than 60.</div><div style="float:right;"><button onclick="MAData.wizard.removeError();" class="MAbutton button-clear button-red remove-error ion-android-cancel" style="font-size: 14px;"></button></div>').show();
                    return;
                }
                urlString = MAData.domain+"/info/index.php?action=get_even_distribution_buckets&orgid=" + MAData.orgId + "&min="+min+"&max="+max+"&buckets="+buckets;
            }
            else {
                doAJAX = false;
                $('#dl-legend-options .rightPanel').removeClass('hidden');
                $('#dl-addLegendRow-btn').removeClass('hidden');
                MAData.wizard.createLegendRow();
                if($('#MADataLayerEditor').data('layerType') && $('#MADataLayerEditor').data('layerType') == 'point') {
                    //create a row for other
                    MAData.wizard.createLegendRow({isOther:true, color:'#93c47d', pointType: 'Circle'});
                }
            }

            if(doAJAX) {
                MA.Popup.showLoading({display:true,popupId:'MADataLayerEditor'});
                $.ajax({
                    url: urlString,
                    type: 'POST',
                    dataType: 'JSON',
                    data: {
                        options : 'options'
                    }
                })
                .success(function(data) {
                    if (data.success && data.data.length > 0)
        			{
        			    //loop over the data and build rows
        			    for(var d = 0; d< data.data.length; d++) {
        			        var options = data.data[d];
        			        MAData.wizard.createLegendRow(options);
        			    }
        			    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                        $('#dl-legend-options .rightPanel').removeClass('hidden');
        			}
        			else
        			{
        				//Error! Read message property
        				//console.log(data.message);
                        $('#MADataLayerEditor .notificationMsg').addClass('error').html('<div class="inline" style="width: 85%; padding:0 10px;">'+data.message+'</div><div style="float:right;"><button onclick="MAData.wizard.removeError();" class="MAbutton button-clear button-red remove-error ion-android-cancel" style="font-size: 14px;"></button></div>').show();
        				MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
        			}
                })
                .error(function(res) {
                    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                    try{
                        var responseText = JSON.parse(res.responseText);
                        var msg = responseText.message;
                        var msgshort = msg.substr(0, 150) + '...';
                        $('#MADataLayerEditor .notificationMsg').show().addClass('error').text(msgshort);
                        $('#MADataLayerEditor .notificationMsg').addClass('error').html('<div class="inline" style="width: 85%; padding:0 10px;">'+msgshort+'</div><div style="float:right;"><button onclick="MAData.wizard.removeError();" class="MAbutton button-clear button-red remove-error ion-android-cancel" style="font-size: 14px;"></button></div>').show();
                    }
                    catch(e) {
                        $('#MADataLayerEditor .notificationMsg').addClass('error').html('<div class="inline" style="width: 85%; padding:0 10px;">An unknown error has occured.</div><div style="float:right;"><button onclick="MAData.wizard.removeError();" class="MAbutton button-clear button-red remove-error ion-android-cancel" style="font-size: 14px;"></button></div>').show();
                    }
                    
                });
            }
        },
        
        collapseInfo : function (button) {
            var $button = $(button);
            //update the button
            if($button.hasClass('ion-android-remove-circle')) {
                $button.removeClass('ion-android-remove-circle').addClass('ion-android-add-circle').text('Expand');
                
                //get the section
                $section = $button.closest('.header-main');
                
                //hide the more info section
                $section.find('.MAheader.header-collapse').addClass('hidden');
            }
            else {
                $button.removeClass('ion-android-add-circle').addClass('ion-android-remove-circle').text('Collapse');
                
                //get the section
                $section = $button.closest('.header-main');
                
                //hide the more info section
                $section.find('.MAheader.header-collapse').removeClass('hidden');
            }
        },
        
        createTooltipTab : function (options) {
            //check how many tabs we have for the temp title
            var newTabIndex = $('#dl-tooltip-tabs-wrap .dl-tab-row').length + 1;
            var tempTab = 'Tab '+newTabIndex+': New Tab';
            var $row = $('#templates .dl-tab-row').clone();
            $row.find('.tab-title').text(tempTab);
            
            $row.attr('tab-index', newTabIndex);
            
            //update the tab title on keyup
            $row.find('.tab-title-input').on('keyup',function () {
                var inputText = $(this).val();
                //get the tab index
                var tabIndex = $row.attr('tab-index');
                $row.find('.tab-title').text('Tab '+tabIndex+': ' + inputText);
            });
            
            $row.on('click','.remove-row',function() {
               var $r = $(this).closest('.dl-tab-row');
               $r.remove();
            });
            
            if(options) {
                //update the row with saved info
                $row.find('.tab-title-input').val(options.tab_label);
                
                //create row if needed
                var data = options.data || [];
                for(var d = 0; d < data.length; d++) {
                    var dRow = data[d];
                    MAData.wizard.createToolipRow({element:$row.find('.addTooltipRow'),type:'tab',data:dRow});
                }
                $row.find('.dl-tooltip-collapse').click();
            }
            
            $('#dl-tooltip-tabs-wrap .dl-tooltip-tabs-wrapper').append($row);
        },
        
        createToolipRow : function (options) {
            //build file and topic data
            MAData.wizard.getPopupTopics(function(res) {
                if(res.success) {
                    var fileData = res.data;
                    var $row = $('#templates .dl-tooltip-row').clone();
                    
                    //loop over options and create select
                    var fileSelectHTML = '<select style="max-width: 200px;" class="dl-tooltip-file">';
        
    				fileSelectHTML += '<option value="--" selected>-Select-</option>';
    
    				$.each(fileData, function( index, value ) {
                       fileSelectHTML += '<option value="' + value.file_id + '">'+ value.file_name +'</option>';
    				});
    
                    $row.find('.dl-tooltip-file-wrap').html(fileSelectHTML);
                    
                    $row.on('change','.dl-tooltip-file',function() {
                        var $select = $(this);
                        //get the topics
                        var topicData = $('#MADataLayerEditor').data('popupData') || [];
                        for(var td = 0; td < topicData.length; td++) {
                            var topic = topicData[td];
                            if(topic.file_id == $select.val()) {
                                var topicArr = topic.topics
                                //update the topic html
                                var topicSelectHTML = '<select style="max-width: 200px;" class="dl-tooltip-topic">';
        
                				topicSelectHTML += '<option value="--" selected>-Select-</option>';
                
                				$.each(topicArr, function( index, value ) {
                                   topicSelectHTML += '<option value="' + value.topic_id + '">'+ value.topic_name +'</option>';
                				});
                				
                				$row.find('.dl-tooltip-topic-wrap').html(topicSelectHTML);
                				$row.find('.dl-tooltip-topic').combobox();
                            }
                        }
                    });
                    
                    $row.on('click','.remove-row',function() {
                       var $r = $(this).closest('.dl-tooltip-row');
                       $r.remove();
                    });
                    
                    var $button = $(options.element);
                    if(options.type == 'tab') {
                        //add this row the element
                        var $selectedRow = $button.closest('.dl-tab-row').find('.dl-tooltip-rows');
                        $selectedRow.append($row);
                    }
                    else {
                        var $selectedRow = $button.closest('.dl-tooltip-header-wrap').find('.dl-tooltip-rows');
                        $selectedRow.append($row);
                    }
                    
                    //init combobox
                    $row.find('.dl-tooltip-file').combobox();
                    $row.find('.dl-tooltip-topic').combobox();
                    
                    if(options.data) {
                        $row.find('.dl-tooltip-file').val(options.data.file_id).next().find('input').val($row.find('.dl-tooltip-file option:selected').text());
                        $row.find('.dl-tooltip-file').change();
                        $row.find('.dl-tooltip-topic').val(options.data.topic_id).next().find('input').val($row.find('.dl-tooltip-topic option:selected').text());
                    }
                }
            });
        },
        
        createLegendRow : function(options) {
            //make sure we have a topic selected
            if($('#dl-legend-options .dl-legend-topic').val() == '') {
                $('#dl-legend-options .dl-legend-topic').addClass('error');
                setTimeout(function() {
                    $('#dl-legend-options .dl-legend-topic').removeClass('error')
                },1000);
                return;
            }
            options = $.extend({
        		min: "",
        		min_label : "",
        		max : "",
        		max_label : "",
        		color : "#3c78d8",
        		isOther : false,
        	}, options || {});
            var dataType = $('#dl-legend-options .dl-legend-topic option:selected').attr('data-type');
            
            if(dataType == '') {
                return;
            }
            
            if(options.isSaved) {
                //make some changes to the color options for row creation
                if(options.color) {
                    var colorArr = options.color.split(':');
                    if(colorArr.length == 2) {
                        options.pointType = colorArr[1];
                        options.color = '#'+colorArr[0];
                    }
                }
            }
            
            options.color = options.color.indexOf('#') == 0 ? options.color : '#' + options.color
            var colorHTML = MAData.wizard.updateLegendRowColor(options);
            var html = MAData.wizard.buildOperatorSelect(dataType,true);
            
            var $row = $('#templates .dl-legend-row').clone();
            $row.find('.dl-legend-color').html(colorHTML).attr('data-color',options.color).attr('data-icon',options.pointType || 'Marker');
            $row.find('.dl-legend-operator-wrap').html(html);
            
            if(dataType == 'decimal' && !options.isOther) {
                $row.find('.dl-filter-operator').val('range').change();
            }
            
            //update the values
            if(options.isSaved){
                $row.find('.dl-filter-operator').val(options.operator).change();
                if(options.operator == 'range') {
                    $row.find('.dl-filter-value-start').val(options.min);
                    $row.find('.dl-filter-value-end').val(options.max);
                }
                else {
                    $row.find('.dl-filter-value-start').val(options.values);
                }
            }
            else {
                $row.find('.dl-filter-value-start').val(options.min_label);
                $row.find('.dl-filter-value-end').val(options.max_label);
            }
            
            $row.on('click','.dl-legend-color', function (e) {
                e.stopPropagation();
                var $color = $(this);
                var levelData = $('#MADataLayerEditor').data('levelData');
                var currentLevel = $('#groupbyV2').val();
                var type = '';
                var showMarkers = false;
                for(var l = 0; l < levelData.length; l++) {
                    var level = levelData[l];
                    if(level.level_id == currentLevel) {
                        type = level.geo_type;
                    }
                }
                if(type == 'point') {
                    showMarkers = true;
                }
                
                if($('.colorPicker.bubble.top').length > 0) {
                    //remove
                    $('.colorPicker.bubble.top').remove();
                }
                
                MA.colors.openPicker({element:$color,showMarkers:showMarkers,icon:$color.attr('data-icon') || 'Marker', color: $color.attr('data-color') || '#2E43FF'},function(res){
                    var colorHTML = '';
                    if($('#MADataLayerEditor').data('layerType') == 'point') {
                        //update the icon
                        res = $.extend({
                    		pointType: "Marker",
                    		color : "#2E43FF",
                    		forLegend : true
                    	}, res || {});
                        colorHTML = MAData.wizard.updateLegendRowColor(res);
                    }
                    else {
                        res = $.extend({
                    		color : "#2E43FF"
                    	}, res || {});
                        colorHTML = MAData.wizard.updateLegendRowColor(res);
                    }
                    
                    $row.find('.dl-legend-color').attr({'data-icon':res.pointType,'data-color':res.color}).html(colorHTML);
                    
                });
            });
            
            //handle autocomplete
            $row.on('keyup','.dl-filter-value-start',function() {
                var $input = $(this);
                var $wrap = $input.closest('.dl-filter-value-wrapper');
                
                //remove previous
                if($('.topic-autoComplete').length >0) {
                    $('.topic-autoComplete').remove();
                }
                
                //only autocomplete is string value
                if($('#dl-legend-options .dl-legend-topic').val() != '--' && $('#dl-legend-options .dl-legend-topic option:selected').attr('data-type') == 'string') {
                    $wrap.addClass('wait');
                    var $list = $row.find('.autocompleteWrapper');
                    $list.find('.autocompleteList').empty();
                    $list.hide();
                    
                    if (MAData.wizard.globalTimeout != null) {
                        clearTimeout(MAData.wizard.globalTimeout);
                    }
                    MAData.wizard.globalTimeout = setTimeout(function() {
                        MAData.wizard.globalTimeout = null;  
                        
                        if($input.val() == '') {
                            $wrap.removeClass('wait');
                            return;
                        }
                        
                        //run search if no keyup for 1 second
                        $.ajax({
                            url: MAData.domain+"/info/index.php?action=get_autocomplete&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&topic_id=" + $('#dl-legend-options .dl-legend-topic').val() + "&level_id=" + $('#groupbyV2').val() + "&search=" + $input.val(),
                            type: 'GET',
                            dataType: 'JSON',
                            data: {}
                        })
                        .success(function(res) {
                            //remove previous
                            if($('.topic-autoComplete').length >0) {
                                $('.topic-autoComplete').remove();
                            }
                            $wrap.removeClass('wait');
                            if(res.success) {
                                var data = res.data || [];
                                var listHTML = '';
                                for(var a = 0; a < data.length; a++) {
                                    var item = data[a];
                                    var li = '<li>'+item+'</li>';
                                    listHTML += li;
                                }
                                
                                if(data.length == 0) {
                                    return;
                                }
                                //create popup
                                var offset = $input.offset();
                                var offsetTop = (offset.top + 25) + 'px';
                                var offsetLeft = offset.left + 'px';
                                var $popupTemp = $('#templates .autocompleteWrapper').clone();
                                $popupTemp.find('.autocompleteList').html(listHTML);
                                var $bubble = $popupTemp
                                    .addClass('bubble top topic-autoComplete')
                                    .css({ position: 'absolute', top: offsetTop, left: offsetLeft, width: 200})
                                    .appendTo('body')
                                    .on('click', function (e) { e.stopPropagation(); })
                                ;
                                
                                $bubble.on('click','.autocompleteList li',function() {
                                    //hide list and set value
                                    var $item = $(this);
                                    $bubble.remove();
                                    $input.val($item.text());
                                });
                                
                                $bubble.on('click','.ac-button-close',function() {
                                    $bubble.remove();
                                })
                            }
                            else {
                                $wrap.removeClass('wait');
                            }
                        })
                        .error(function(res) {
                            MA.log(res);
                            $wrap.removeClass('wait');
                        });
                    }, 500); 
                }
            });
            
            $row.on('click','.remove-row',function() {
               var $r = $(this).closest('.dl-legend-row');
               $r.remove();
            });
            
            if(options.isOther) {
                $row.addClass('OTHER').find('.dl-filter-operator').val('equals').attr('disabled','disabled').css('background-color','#e8e8e8');
                $row.find('.dl-filter-value-start').val('--Other--').attr('disabled','disabled').css('background-color','#e8e8e8');
                $row.find('.button-clear').remove();
                //$row.appendTo($('#dl-legend-info-wrapper'));
            }
            
            if($('#dl-legend-info-wrapper .OTHER').length > 0) {
                $row.insertBefore($('#dl-legend-info-wrapper .OTHER'));
            }
            else {
                $row.appendTo($('#dl-legend-info-wrapper'));
            }
            
        },
        
        updateLegendRowColor : function (options) {
            //get the layer type
            var levelData = $('#MADataLayerEditor').data('levelData');
            var currentLevel = $('#groupbyV2').val();
            var type = '';
            for(var l = 0; l < levelData.length; l++) {
                var level = levelData[l];
                if(level.level_id == currentLevel) {
                    type = level.geo_type;
                }
            }
            
            var colorHTML = '';
            if(type == '') {
                return colorHTML;
            }
            else if (type == 'polygon') {
                colorHTML = '<div class="dl-legend-colorBox" style="background:'+options.color+'; height: 20px;width: 20px;border-radius: 3px;"></div>';
            }
            else if (type == 'point') {
                var pointType = options.pointType || 'Marker';
                colorHTML = '<span class="dl-legend-colorBox">'+MA.Marker.createSVG({ color: options.color + ':' + pointType,forLegend:true })+'</span>';
            }
            
            return colorHTML;
        },
        
        updateValueField : function (select,forLegend) {
            var operator = $(select).val();
            var $row = $(select).closest('.dl-row');
            var rowvalStart = $row.find('.dl-filter-value-start').val();
            var rowvalEnd = $row.find('.dl-filter-value-start').val();
            var html = '';
            if(operator == 'range') {
                //show 2 input boxes
                $(select).find('.dl-filter-value-wrapper').empty();
                html = '<input class="dl-filter-value-start" style="width: 85px;" type="text"/><span> - </span><input style="width: 85px;" class="dl-filter-value-end" type="text"/>'
            }
            else {
                html = '<input class="dl-filter-value-start" type="text"/></div>';
            }
            
            //update the row
            $row.find('.dl-filter-value-wrapper').html(html);
            var widthFix = '135px';
            if(operator == 'range') {
                //fix css
                $row.find('.dl-filter-operator-wrap input').css('width','100px');
                $row.find('.dl-filter-topic-wrap input').css('width','100px');
                $row.find('.dl-filter-operator').css('width','100px');
                if(forLegend) {
                    widthFix = '95px';
                }
                else {
                    widthFix = '110px';
                }
            }
            else {
                $row.find('.dl-filter-operator-wrap input').css('width','175px');
                $row.find('.dl-filter-topic-wrap input').css('width','175px');
                $row.find('.dl-filter-operator').css('width','170px');
            }
            
            $row.find('.dl-filter-value-start').val(rowvalStart);
            $row.find('.dl-filter-value-end').val(rowvalEnd);
            
            var dataType;
            
            var paddingFix = false;
            if(forLegend) {
                dataType = $('#dl-legend-options .dl-legend-topic option:selected').attr('data-type');
                paddingFix = true;
            }
            else {
                dataType = $row.find('.dl-filter-topic option:selected').attr('data-type');
            }
            if(dataType == 'date') {
                $row.find('.dl-filter-value-start').css('width',widthFix).addClass('isDate').attr('disabled','disabled').datepicker({
                    showOn: "button",
                    buttonImage: MA.Images.calendar,
                    buttonImageOnly: true,
                    buttonText: "",
                    dateFormat: "yy-mm-dd"
                });
                $row.find('.dl-filter-value-end').css('width',widthFix).addClass('isDate').attr('disabled','disabled').datepicker({
                    showOn: "button",
                    buttonImage: MA.Images.calendar,
                    buttonImageOnly: true,
                    buttonText: "",
                    dateFormat: "yy-mm-dd"
                });
                if(paddingFix) {
                    $row.find('.dl-filter-value-wrapper input').css('padding-right','5px');
                }
                else {
                    $row.find('.dl-filter-value-wrapper input').css('padding-right','25px');
                }
            }
            else {
                $row.find('.dl-filter-value-start').removeAttr('disabled');
                $row.find('.dl-filter-value-end').removeAttr('disabled');
            }
        },
        
        buildOperatorSelect : function (type,forLegend) {
            forLegend = forLegend || false;
            //only show range if polygon
            var levelData = $('#MADataLayerEditor').data('levelData');
            var currentLevel = $('#groupbyV2').val();
            var geo_type = '';
            for(var l = 0; l < levelData.length; l++) {
                var level = levelData[l];
                if(level.level_id == currentLevel) {
                    geo_type = level.geo_type;
                }
            }
            
            var operatorSelectHTML = '<select class="dl-filter-operator" onchange="MAData.wizard.updateValueField(this,'+forLegend+');">';
            operatorSelectHTML += '<option value="--" selected>Please select an operator</option>';
            
            if(type == 'string') {
                operatorSelectHTML += '<option value="equals">equals</option>';
                operatorSelectHTML += '<option value="not equal to">not equal to</option>';
                operatorSelectHTML += '<option value="starts with">starts with</option>';
                operatorSelectHTML += '<option value="contains">contains</option>';
                operatorSelectHTML += '<option value="does not contain">does not contain</option>';
            }
            else if (type == 'decimal') {
                if(geo_type == 'polygon') {
                    operatorSelectHTML += '<option value="range">range</option>';
                }
                else {
                    operatorSelectHTML += '<option value="equals">equals</option><option value="not equal to">not equal to</option>';
                    operatorSelectHTML += '<option value="less than">less than</option><option value="greater than">greater than</option>';
                    operatorSelectHTML += '<option value="less or equal">less or equal</option>';
                    operatorSelectHTML += '<option value="greater or equal">greater or equal</option>';
                    operatorSelectHTML += '<option value="range">range</option>';
                }
            }
            else if (type == 'date') {
                operatorSelectHTML += '<option value="equals">equals</option><option value="not equal to">not equal to</option>';
                operatorSelectHTML += '<option value="less than">less than</option><option value="greater than">greater than</option>';
                operatorSelectHTML += '<option value="less or equal">less or equal</option>';
                operatorSelectHTML += '<option value="greater or equal">greater or equal</option>';
                operatorSelectHTML += '<option value="range">range</option>';
            }
            
            operatorSelectHTML += '</select>';
            
            return operatorSelectHTML;
            
        },
        
        updateFilter: function (selection) {
            var $topic = $(selection);
            var $option = $topic.find('option:selected');
            var dataType = $option.attr('data-type');
            //build operator options
            var html = MAData.wizard.buildOperatorSelect(dataType);
            
            //update the row
            var $row = $topic.closest('.dl-filter-row');
            
            $row.find('.dl-filter-operator-wrap').html(html);
            $row.find('.dl-filter-operator-wrap select').combobox();
            if(dataType == 'date') {
                $row.find('.dl-filter-value-start').val('');
            }
            
        },
        
        saveDataLayer : function (plotLayer) {
            //preform checks
            var $popup = $('#MADataLayerEditor');
            var isRefresh = $popup.data('isRefresh');
            var $refreshLayer;
            if(isRefresh) {
                $refreshLayer = $popup.data('plottedLayer');
                if($('#MADataLayerEditor').data('layerType') == 'polygon') {
                    $refreshLayer.removeClass('visibleOnly');
                    //hide visible area button
                    $('#visibleAreaRefeshMap').removeClass('visible');
                }
                else {
                    $refreshLayer.addClass('visibleOnly');
                }
            }
            //get the type
            var levelData = $('#MADataLayerEditor').data('levelData') || [];
            var currentLevel = $('#groupbyV2').val();
            var type = '';
            for(var l = 0; l < levelData.length; l++) {
                var level = levelData[l];
                if(level.level_id == currentLevel) {
                    type = level.geo_type;
                }
            }
            
            //
            var jsonData = {
                type : type == 'point' ? 'marker' : 'polygon',
                file_id : $('#datasourceV2').val(),
                level_id : $('#groupbyV2').val(),
                topic_id : $('#topicV2').val(),
                country_id : $('#countryV2').val(),
                opacity : parseInt($('.dl-legend-opacity').val(), 10)
            };
            
            //loop over the filters
            var filtersArr = $('#dl-filters-wrapper .dl-filter-row');
            var filtersJSON = [];
            for(var f = 0; f < filtersArr.length; f++){
                var $filter = $(filtersArr[f]);
                //ignore if blank or no topic selected
                if($filter.find('.dl-filter-value-start').val() != '' && $filter.find('.dl-filter-topic').val() != '--') {
                    var operator = $filter.find('.dl-filter-operator').val();
                    if(operator != '') {
                        var filterObj = {
                            topic_id : $filter.find('.dl-filter-topic').val(),
                            operator: operator
                        };
                        if(operator == 'range') {
                            filterObj['min'] = $filter.find('.dl-filter-value-start').val();
                            filterObj['max'] = $filter.find('.dl-filter-value-end').val();
                        }
                        else {
                            filterObj['values'] = $filter.find('.dl-filter-value-start').val();
                        }
                        filtersJSON.push(filterObj);
                    }
                }
            }
            //add the filters to the saveData
            jsonData['filters'] = filtersJSON;
            
            //build our legend
            var legendArr = $('#dl-legend-info-wrapper .dl-legend-row');
            var legendJSON = {
                title : $('.dl-legend-title').val(),
                subTitle : $('.dl-legend-subtitle').val(),
                rows : []
            };
            for(var l = 0; l < legendArr.length; l++) {
                var $legend = $(legendArr[l]);
                if($legend.find('.dl-filter-value-start').val() != '') {
                    var operator = $legend.find('.dl-filter-operator').val();
                    if(operator != '') {
                        var legObj = {
                            topic_id : $('#dl-legend-options .dl-legend-topic').val(),
                            operator : operator
                        }
                        
                        if(operator == 'range') {
                            legObj['min'] = $legend.find('.dl-filter-value-start').val();
                            legObj['max'] = $legend.find('.dl-filter-value-end').val();
                        }
                        else {
                            legObj['values'] = $legend.find('.dl-filter-value-start').val()
                        }
                        
                        if(type == 'point') {
                            legObj['color'] = $legend.find('.dl-legend-color').attr('data-color').replace('#','') + ':' + $legend.find('.dl-legend-color').attr('data-icon');
                        }
                        else {
                            legObj['color'] = $legend.find('.dl-legend-color').attr('data-color').replace('#','');
                        }
                        
                        legendJSON.rows.push(legObj);
                    }
                }
            }
            jsonData['legend'] = legendJSON;
            
            //get popup
            var popupJSON = {
                header : [],
                tabs : []
            };
            var $popupHeader = $('#dl-tooltip-header-info-wrapper');
            //loop over rows
            var headerRows = $popupHeader.find('.dl-tooltip-row');
            for(var h = 0; h < headerRows.length; h++) {
                var $head = $(headerRows[h]);
                var file_id = $head.find('.dl-tooltip-file').val();
                var topic_id = $head.find('.dl-tooltip-topic').val();
                if(topic_id != '' && file_id != '') {
                    var headObj = {
                        type: '',
                        file_id: file_id,
                        topic_id: topic_id
                    }
                    popupJSON.header.push(headObj);
                }
            }
            
            //get tabs
            var $popupTabs = $('#dl-tooltip-tabs-wrap');
            var tabRows = $popupTabs.find('.dl-tab-row');
            var tabsJSON = popupJSON.tabs;
            for(var t = 0; t < tabRows.length; t++) {
                var $tab = $(tabRows[t]);
                var date = new Date();
                var tabLabel = $tab.find('.tab-title-input').val();
                var uniqueId = t+date.getTime();
                var tabObj = {
                    tab_id : uniqueId,
                    tab_label: tabLabel,
                    data : []
                }
                
                //loop over the data rows
                var $dataRows = $tab.find('.dl-tooltip-row');
                for(var dr = 0; dr < $dataRows.length; dr++) {
                    var $row = $($dataRows[dr]);
                    var tabfile_id = $row.find('.dl-tooltip-file').val();
                    var tabtopic_id = $row.find('.dl-tooltip-topic').val();
                    if(tabfile_id != '' && tabtopic_id != '') {
                        var rowObj = {
                            file_id : tabfile_id,
                            topic_id : tabtopic_id
                        }
                        //add to the tab obj
                        tabObj.data.push(rowObj);
                    }
                }
                tabsJSON.push(tabObj);
            }
            jsonData['popup'] = popupJSON;
            
            //get the folder
            var folderId;
            var layerId;
            var userId;
            //check if this is a saved layer (editing) else get folder
            var isClone = $('#MADataLayerEditor').data('isClone') || false
            if($('#MADataLayerEditor').data('layer-id') && !isClone) {
                layerId = $('#MADataLayerEditor').data('layer-id');
            }
            else {
                if($('#MADataLayerEditor').data('folder-id') == 'PersonalRoot' || $('#MADataLayerEditor').data('folder-id') == 'RoleUserFolder') {
					if($('#MADataLayerEditor').data('folder-id') == 'RoleUserFolder') {
					    if (NewLayerNavigationEnabled()) {
					        //not supported right now
					        userId = MA.CurrentUser.Id;
					    }
					    else {
					        userId = $popup.data('folder-id-actual');
					    }
					    
					}
					else {
					    userId = MA.CurrentUser.Id;
					}
				}
				else if ($('#MADataLayerEditor').data('folder-id') == 'CorporateRoot') {
					//send nothing for corporate root
				}
				else {
					folderId = $('#MADataLayerEditor').data('folder-id');
				}
            }
            
            var saveData = {
                layerData: JSON.stringify({
                    sma__Description__c : $('#MADataLayerEditor .dl-desc').val(),
                    sma__Folder__c : folderId,
                    sma__Type__c : 'Data Layer',
                    sma__User__c : userId,
                    sma__Version__c : '1',
                    Name : $('#MADataLayerEditor .dl-label').val(),
                    Id : layerId
                }),
                jsonOptions : JSON.stringify(jsonData),
                isClone : $('#MADataLayerEditor').data('isClone') || false
            }
            
            //save
            $.ajax({
                url: MA.resources.Tree+"?securityToken="+securityToken+"&action=save_layerV2",
                type: 'POST',
                dataType: 'JSON',
                data: saveData
            })
            .success(function(res) {
                if(res.success) {
                    //refresh the folders
                    if (NewLayerNavigationEnabled())
                	{
                	    showSuccess($('#mapdiv'), 'Successfully saved this data layer.');
                	    MALayers.refreshFolder(function(refresh) {
                            if(plotLayer) {
                                if(isRefresh) {
                                    //refresh
                                    $refreshLayer.find('.basicinfo-name').text('Loading...');
                                    $refreshLayer.data('name',res.data.Name)
                                    MADemographicLayer.refreshDataLayer($refreshLayer);
                                }
                                else {
                    	            MADemographicLayer.StoreTempLayer(res.data.Id);
                                }
                                
                                MALayers.moveToTab('plotted');
                            }
                	    });
                	}
                    else
                    {
                        var folderId = $('#MADataLayerEditor').data('folder-id');
                        if($('#MADataLayerEditor').data('folder-id') == 'RoleUserFolder') {
                            folderId = $popup.data('folder-id-actual');
                        }
                        if (layerId)
                    	{
                    		//update
                    		var $node = $('#SQTree li[id="'+folderId+'"]');
                    		$("#SQTree").jstree('rename_node', '#' + layerId , res.data.Name);
                    		showSuccess($('#mapdiv'), 'Successfully updated this data layer.');
                    		
                    		//plot the layer
        				    if(plotLayer) {
        				        if(isRefresh) {
                                    //refresh
                                    MADemographicLayer.refreshDataLayer($refreshLayer);
                                }
                                else {
                    	            MADemographicLayer.StoreTempLayer(res.data.Id);
                                }
                                
                                if(!$('#tabs-nav-plotted').hasClass('tab-open')) {
            			            $('#tabs-nav-plotted').click();
            			        }
        				    }
                    	}
                    	else
                    	{
                    	    if( $('#SQTree #' + folderId + ' > ul ').length > 0 ) {
                    		    $("#SQTree").jstree("create","#" + folderId,"last",{attr : {id: res.data.Id, NodeType: 'DataLayer', rel: 'SavedDataLayer', title: res.data.Name}, data: res.data.Name},null,true);
                    	    }
        				    showSuccess($('#mapdiv'), 'Successfully saved this data layer.');
        				    
        				    //plot the layer
        				    if(plotLayer) {
        				        if(isRefresh) {
                                    //refresh
                                    MADemographicLayer.refreshDataLayer($refreshLayer);
                                }
                                else {
                    	            MADemographicLayer.StoreTempLayer(res.data.Id);
                                }
                                
                                if(!$('#tabs-nav-plotted').hasClass('tab-open')) {
            			            $('#tabs-nav-plotted').click();
            			        }
        				    }
                    	} 
                    }
                    
                    MAData.wizard.closePopup();
                    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                
                }
                else {
                    MA.log(res);
                    var msg = res.message || 'Unable to save: Unknown Error.'
                    $popup.find('.notificationMsg').addClass('error').text(msg).show();
                    setTimeout(function() {
                        $popup.find('.notificationMsg').removeClass('error').hide()
                    },5000);
                }
                
            })
            .error(function(res) {
                MA.log(res);
                MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
            });
        }
	},

	//Makes the call to the PHP in order to get the countries
	GetCountries: function() {
		//console.log('Acquiring the countries...');

		$.getJSON( MAData.domain + "/info/index.php?action=get_countries&orgId=" + MAData.orgId + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				var CountrySelectHTML = '<select id="country" onchange="MAData.GetFiles()">';

				CountrySelectHTML += '<option value="" disabled selected>Please select a country</option>';

				$.each(data.data, function( index, value ) {

					CountrySelectHTML += '<option value="' + value.country_id + '">'+ value.country_name +'</option>';

				});

				CountrySelectHTML += '</select>';
				$('#countryplaceholder').html(CountrySelectHTML);

			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},
	
	//Makes the call to the PHP in order to get the countries
	GetCountriesV2: function() {
		//console.log('Acquiring the countries...');

		$.getJSON( MAData.domain + "/info/index.php?action=get_countries&orgId=" + MAData.orgId + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				var CountrySelectHTML = '<select id="countryV2" onchange="MAData.GetFilesV2()">';

				CountrySelectHTML += '<option value="--" selected>Please select a country</option>';

				$.each(data.data, function( index, value ) {

					CountrySelectHTML += '<option value="' + value.country_id + '">'+ value.country_name +'</option>';

				});

				CountrySelectHTML += '</select>';
				$('#countryplaceholderV2').html(CountrySelectHTML);
                $('#countryV2').combobox();
                $('#countryV2').next().find('input').removeClass('error');
			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},


	//Makes the call to the PHP in order to get the data sources
	GetFiles: function() {
		//console.log('Acquiring the data sources...');

		var country = $('table.DemographicTable').find('#country option:selected').val();

		$.getJSON( MAData.domain + "/info/index.php?action=get_files&country_id=" + country + "&orgId=" + MAData.orgId + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				var DataSourceSelectHTML = '<select id="datasource" onchange="MAData.GetTopics()">';

				DataSourceSelectHTML += '<option value="--" disabled selected>Please select a datasource</option>';

				$.each(data.data, function( index, value ) {
					
					DataSourceSelectHTML += '<option value="' + value.file_id + '">'+ value.file_name +'</option>';

				});

				DataSourceSelectHTML += '</select>';
				$('#datasourceplaceholder').html(DataSourceSelectHTML);

			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},
	
	GetFilesV2: function() {
		//console.log('Acquiring the data sources...');

		var country = $('table.DemographicTable').find('#countryV2 option:selected').val();

		$.getJSON( MAData.domain + "/info/index.php?action=get_files&country_id=" + country + "&orgId=" + MAData.orgId + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				var DataSourceSelectHTML = '<select id="datasourceV2" onchange="MAData.GetTopicsV2()">';

				DataSourceSelectHTML += '<option value="--" disabled selected>Please select a datasource</option>';

				$.each(data.data, function( index, value ) {
					
					DataSourceSelectHTML += '<option value="' + value.file_id + '">'+ value.file_name +'</option>';

				});

				DataSourceSelectHTML += '</select>';
				$('#datasourceplaceholderV2').html(DataSourceSelectHTML);
				$('#countryV2').next().find('input').removeClass('error');
				
				//update the legend as well
				$('#dl-legend-options .dl-legend-file').html(DataSourceSelectHTML);
                $('#datasourceV2').combobox();
			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
		
		//clear old selections
		MAData.wizard.resetPopup(true);
		MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
	},
	
	GetTopicsV2: function() {
		//console.log('Acquiring the topics...');

		var datasource = $('#datasourceV2 option:selected').val();

		$.getJSON( MAData.domain + "/info/index.php?action=get_topics&file_id=" + datasource + "&orgId=" + MAData.orgId + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
			    $('#MADataLayerEditor').data('topicData',data.data);
				var TopicSelectHTML = '<select id="topicV2" onchange="MAData.GetLevelsV2()">';

				TopicSelectHTML += '<option value="--" disabled selected>Please select a topic</option>';

				$.each(data.data, function( index, value ) {
					
					TopicSelectHTML += '<option value="' + value.topic_id + '">'+ value.topic_name +'</option>';

				});

				TopicSelectHTML += '</select>';
				$('#topicplaceholderV2').html(TopicSelectHTML);
				$('#countryV2').next().find('input').removeClass('error');
				$('#datasourceV2').next().find('input').removeClass('error');
				
				//update the legend with the file selection and add topics to legend
				$('#dl-legend-options .dl-legend-file').val($('#datasourceV2').val()).attr('disabled','disabled');
                $('#topicV2').combobox();
			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},


	GetLevelsV2: function() {
		//console.log('Acquiring the levels...');

		var topic = $('table.DemographicTable').find('#topicV2 option:selected').val();

		$.getJSON( MAData.domain + "/info/index.php?action=get_topic_levels&topic_id=" + topic + "&orgId=" + MAData.orgId + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
			    $('#MADataLayerEditor').data('levelData',data.data);
			    MAData.groupByData = data.data;
			    
				var GroupBySelectHTML = '<select id="groupbyV2" onchange="MAData.wizard.tempUpdateGroupByLegend();">';
				
				GroupBySelectHTML += '<option value="--">Please select a level</option>';

				$.each(data.data, function( index, value ) {
					
					GroupBySelectHTML += '<option value="' + value.level_id + '">'+ value.level_name +'</option>';

				});

				GroupBySelectHTML += '</select>';
				$('#groupbyplaceholderV2').html(GroupBySelectHTML);
				$('#groupbyV2').combobox();
				$('#countryV2').next().find('input').removeClass('error');
				$('#datasourceV2').next().find('input').removeClass('error');
				$('#topicV2').next().find('input').removeClass('error');
                
			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},
	
	
	GetDataV2: function() {
        //get the country and topic
		var country = $('#countryV2 option:selected').val();
		var topic = $('#topicV2 option:selected').val();
		var topicname = $('#topicV2 option:selected').text();
		var datasource = $('#datasourceV2 option:selected').val();
		
		//get all of the grouping data
		var groupby = $('#groupbyV2 option:selected').val();

		//console.log('Building legend...');

		if (MAData.groupByData !== null && MAData.groupByData !== undefined)
		{
			MAData.ClearLayer();
			
    		var gbdIndex = null;
    		var gbdLen = MAData.groupByData.length;
    		for(var ii=0; ii<gbdLen; ii++) {
    		    if(MAData.groupByData[ii].level_id === groupby) {
    		        gbdIndex = ii;
    		    }
    		}

    		var geotype = MAData.groupByData[gbdIndex].geo_type;
    		
    		//are we using cache?
    		var usecache = true;
    		var debugtiles = false;
			
            //console.log(data);
			//remove previous data
			$('table.DemographicTable').removeData('legendInfo');
			$('table.DemographicTable').removeData('legendHead');
            $('table.DemographicTable').removeData('legendunit');
            
            if(geotype !== 'point') {
            
                var unit = MAData.groupByData[gbdIndex].unit;
        		var legend = JSON.parse(MAData.groupByData[gbdIndex].legend);
            
    			//store data for legend recreate
    			$('table.DemographicTable').data('legendInfo', legend);
    			$('table.DemographicTable').data('legendHead', topicname);
                $('table.DemographicTable').data('legendunit', unit === null ? '' : unit);
                
    			//create legend
    			MAData.CreateDemoLegend(legend);
    
    			MAData.CensusLayer = new google.maps.ImageMapType({
    				name: 'Census',
    				maxZoom: 18,
    				tileSize: new google.maps.Size(256, 256),
    				opacity: $('.fill-opacity-slider').slider('value')/100,
    				getTileUrl: function(coord, zoom) {
    					return [ MAData.domain + '/tile/index.php?x=', coord.x, '&y=', coord.y, '&z=', zoom, '&cache=', usecache,'&debug=', debugtiles, '&topic=', topic, '&groupby=', groupby, '&country=', country, '&legend=', encodeURIComponent(JSON.stringify(legend))].join('');
    				}
    
    			});
    
    			MA.map.overlayMapTypes.push(MAData.CensusLayer);
    
    			$('.demo-legend-button').show().val('Hide Legend');
    
    			//TURN ON CLICKS!
    			google.maps.event.addListener(MA.map, 'click', function(event) {
    				MAData.HandleClick(event, null, null);
    			});
            } 
            else {
                
                var NE = MA.map.getBounds().getNorthEast();
                var SE = MA.map.getBounds().getSouthWest();
                $.getJSON( MAData.domain + "/info/index.php?action=get_markers&level_id=" + groupby + "&orgId=" + MAData.orgId + "&file_id=" + datasource + "&nelat=" + NE.lat() + "&nelng=" + NE.lng() + "&swlat=" + SE.lat() + "&swlng=" + SE.lng() + "&limit=" + MAData.markerLimit + "&callback=?&apikey=" + MA.APIKey, function( data ) {

        			if (data.success)
        			{
        			    //Add markers to the map
        			    //console.log('daterr:', data);
        			    
        			    $.each(data.data.markers, function( index, value ) {
        			        
        			        var marker = new google.maps.Marker({
                                position: { 
                                    lat: value.marker.markerData.lat, 
                                    lng: value.marker.markerData.lng 
                                },
                                map: MA.map,
                                title: value.marker.label,
                                icon: MAData.domain + "/images/" + MAData.markerImage + ".png"
                            });
                            
                            google.maps.event.addListener(marker, 'click', function(event) {
                                MAData.HandleClick(event, value, marker);
                            });
                            
                            MAData.Markers.push(marker);
                            
        				});
        				
        			}
        			else
        			{
        				//Error! Read message property
        				//console.log(data.message);
        			}
        		});
        		
            }

		}
		else
		{
			//Error! Read message property
			//console.log(data.message);
			//$('#legendplaceholder').html('No Census Data Available');
		}

	},


	//Show or hide the legend
	ShowHideLegend: function() {
		if($('.demo-legend-button').val() == 'Hide Legend') {
			$('#mapcontainer').find('> .demo-legend').remove();
			$('.demo-legend-button').val('Show Legend');
		}
		else {
			MAData.CreateDemoLegend ($('.DemographicTable').data('legendInfo'));
			$('.demo-legend-button').val('Hide Legend');
		}
	},


	//Refresh the slider
	RefreshSlider: function() {
		$(this).closest('td').find('.percent').text($(this).slider( "value" )+'%');
		if(MAData.CensusLayer !== null && MAData.CensusLayer !== undefined) {
			MAData.CensusLayer.setOpacity($(this).slider( "value" )/100);
		}

		//update legend
		$.each($('.legend-table .demo-color'),function() {
			var opacity = $('.fill-opacity-slider').slider('value')/100;
			$(this).css('opacity', opacity);
		});
	},


	//Initialize the sliders
	InitializeSliders: function() {
		$('.DemographicTable .slider').slider({
			step: 5,
			range: "min",
			max: 100,
			min: 0,
			value: 50,
			slide: MAData.RefreshSlider(),
			change: MAData.RefreshSlider()
		});
	},


	//Removes the overlay
	RemoveOverlay: function (name) {
		$.each(MA.map.overlayMapTypes.getArray(), function (i, overlay) {
			if (overlay.name == name) {
				MA.map.overlayMapTypes.removeAt(i);
				return false;
			}
		});
	},


	//Creates the legend with the given legend data
	CreateDemoLegend: function(legend) {
		var $legend = $('.demo-legend').clone().draggable({ containment: "parent" });
		
		if(legend !== null && legend !== undefined && legend.length > 0) {
        
            var $unit ='<tr><td style="font-weight:bold;max-width:200px;text-shadow: 1px 1px 4px #BBBBBB;color: rgb(87, 87, 87);padding-bottom: 6px;font-size: 12px;" colspan="5"> '+$('.DemographicTable').data('legendunit')+' </td></tr>' ;			
            $legend.find('.legend-table').append($unit);
    
    		$.each(legend, function( index, value ) {
    			var rgb = hexToRgb(value.color);
    			var opacity = $('.fill-opacity-slider').slider('value')/100;
    
    			var $row = '<tr><td class="demo-color" style="width:20px; height: 20px; background: rgba('+rgb.r+', '+rgb.g+', '+rgb.b+' , 1); opacity:'+opacity+';"></td><td style="padding-left: 5px;">' 
    			+ value.min_label + '</td><td>-</td><td>' + value.max_label + '</td></tr>';
    			
    			$legend.find('.legend-table').append($row);
    		});
    
    		//append header
    		$legend.find('.legend-head').text($('.DemographicTable').data('legendHead'));
    
    		//show legend
    		$legend.appendTo('#mapcontainer');
    
    		//handle close button
    		$legend.on('click', '.demo-legend-close', function () {
    			$('#mapcontainer').find('> .demo-legend').remove();
    			$('.demo-legend-button').val('Show Legend');
    		});
    
    		//adjust heighth of now attached table
    		$('#mapcontainer > .demo-legend').css('height', $('#mapcontainer > .demo-legend .legend-table').height());
    		$('#mapcontainer > .demo-legend').css('width', $('#mapcontainer > .demo-legend .legend-table').width());
    		
		} else {
		    console.log('Legend does not yet exist for this query.');
		}
	},


	//Clears the census layer
	ClearLayer: function() {
		if (MAData.CensusLayer !== null && MAData.CensusLayer !== undefined)
		{
			//remove clicks
			google.maps.event.clearListeners(MA.map, 'click');

			//empty the census layer
			MAData.CensusLayer = null;

			//touch up the map
			MA.Map.InfoBubble.hide();
			MAData.RemoveOverlay('Census');

			$('#mapcontainer').find('> .demo-legend').remove();
			$('.demo-legend-button').hide();
		} else if(MAData.Markers.length > 0) {
		    var len = MAData.Markers.length;
		    
		    for(var ii=0; ii<len; ii++) {
		        MAData.Markers[ii].setMap(null);
		    }
		    
		    MAData.Markers = [];
		}
	}
}