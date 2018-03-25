/************************************************
 * 
 * 
 * 
 * 
 * 
 * 
 *  This File is Deprecated 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 *************************************************/

var MAData = {
    CensusLayer: null,
    Markers: [],

    domain: "https://product-api-prod.cloudbilt.com/demographicsv7",
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
        MAData.getDataLayerSource();
        
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
            $.ajax({
                url: MAData.domain + '/info/index.php?action=get_point_info&sandbox=' + MAData.sandbox + '&topic_id=' + topic + '&file_id=' + datasource + '&level_id=' + groupby + '&orgid=' + MAData.orgId + '&lat=' + lat + '&lng=' + lng + '&callback=?&apikey=' + MA.APIKey,
                type: 'GET',
                dataType: 'JSON',
                data: {}
            }).success(function(data) {
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
            }).error(function(err) {
                callback({success:false});
            });
            /*$.getJSON( MAData.domain + '/info/index.php?action=get_point_info&sandbox=' + MAData.sandbox + '&topic_id=' + topic + '&file_id=' + datasource + '&level_id=' + groupby + '&orgid=' + MAData.orgId + '&lat=' + lat + '&lng=' + lng + '&callback=?&apikey=' + MA.APIKey, function( data ) {
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
            });*/
            
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
    
    createRecordFromDataLayer: {
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
                
                if(layerType.indexOf('dmp') >= 0) 
                {
                    layerType = 'dmp-v1';
                }
                else if(layerType.indexOf('dbusa') >= 0)
                {
                    layerType = 'dbusa-v1';
                }
                else if(layerType.indexOf('navport') >= 0)
                {
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
            
            try {
                //if not lightning, clear out the map
                if(typeof Map === 'function' && (typeof sforce === 'object' && !sforce.one)) {
                    Map = undefined;
                }
            }
            catch(e) {}
            
            //launch the popup
            var popup = MA.Popup.showMAPopup({
                template: $('#templates .CreateRecordDataLayerPopup2').clone(),
                popupId : 'createDataLayerRecordV2',
                width : 600,
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
                url: MA.resources.Tooltip+"?securityToken="+MASystem.MergeFields.Security_Token+"&action=getClick2CreateDataLayerSettings&core.apexpages.devmode.url=0",
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
            
                
            // $("#createDataLayerRecordV2 .createrecordDataLayer-fieldset").html('Loading...').load(MA.resources.Click2Create, "sobject=" + $('#createDataLayerRecordV2 .createrecordDataLayer2-object').val() + '&fieldset=' + fieldSetName + '&recordtypeid=' + (recordTypeId || '') + '&platform=desktop', function () {
                
            //     if(!$('#createDataLayerRecordV2').data('isMassAction')){
            //         //build json data to send
            //         var jsonData = {
            //             uIds : [],
            //             tableNames : [],
            //             sfdcData : [],
            //             topicData : [],
            //             dataType : $('#createDataLayerRecordV2').data('dataType')
            //         }
            //         var markers = $popup.data('dataLayers') || [];
            //         var mI = markers.length;
            //         while(mI--) {
            //             var marker = markers[mI];
            //             jsonData.uIds.push(marker.data.marker.uid);
            //             jsonData.tableNames.push(marker.data.marker.table);
            //         }
                
            //         if(objc2cSettings.fields) {
            //             var fields = objc2cSettings.fields;
            //             //loop over the saved data layer fields and try to update
            //             for(var key in fields) {
            //                 var field = fields[key];
            //                 if(field != '') {
            //                     var phpFix = key.replace('dmp_','');
            //                     jsonData.topicData.push({topic_id:phpFix,field:field});
            //                 }
            //             }
            //         }
                
            //         //get data
            //         MAData.createRecordFromDataLayer.getC2CDataFromServer(jsonData,function(res) {
            //             if(res.success) {
            //                 //console.log(res.data);
            //                 var markerData = res.data[0];
            //                 for(var sfdcId in markerData) {
            //                     var fieldValue = markerData[sfdcId];
            //                     //try and find a matching field
            //                     try {
            //                         var $input = $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="'+sfdcId+'"]');
            //                         var $row = $input.closest('tr');
            //                         $row.addClass('autoPopDataLayer');
                                    
            //                         //fill in the rows
            //                         if($input.length > 0) {
            //                             if(!$('#createDataLayerRecordV2').data('isMassAction')){
            //                                 $input.find('.get-input').val(fieldValue);
            //                             }
            //                         }
            //                         else {
            //                             //append to bottom hidden
            //                             var rowTemp = '<tr style="display:none;"><td class="field::'+sfdcId+' fieldInput" data-field="'+sfdcId+'" data-type="string"><input class="get-input '+sfdcId+'" value="'+fieldValue+'"/></td></tr>';
            //                             $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldSetTable').append(rowTemp);
            //                         }
            //                     }
            //                     catch(e) {
                                    
            //                     }
            //                 }
            //             }
                        
            //             //update the lat lng fields
            //             if(!$('#createDataLayerRecordV2').data('isMassAction')){
            //                 try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__Geolocation_Longitude__s"]').find('.get-input').val(markerInfo.markerData.lng); } catch (err) {}
            //                 try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__Geolocation_Latitude__s"]').find('.get-input').val(markerInfo.markerData.lat); } catch (err) {}
            //                 try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__MALongitude__c"]').find('.get-input').val(markerInfo.markerData.lng); } catch (err) {}
            //                 try { $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="sma__MALatitude__c"]').find('.get-input').val(markerInfo.markerData.lat); } catch (err) {}
            //             }
                        
            //             $('#createDataLayerRecordV2 .MA2-loading-mask').remove('hidden');
            //         });
            //     }
            //     else {
            //         if(objc2cSettings.fields) {
            //             var fData = objc2cSettings.fields;
            //             //loop over the saved data layer fields and try to update
            //             for(var id in fData) {
            //                 var fieldData = fData[id];
                            
            //                 var $input = $('#createDataLayerRecordV2 .createrecordDataLayer-fieldset .fieldInput[data-field="'+fieldData+'"]');
            //                 var $row = $input.closest('tr');
            //                 $row.addClass('autoPopDataLayer');
            //             }
            //         }
            //     }
                
            // });
            
            
            $("#createDataLayerRecordV2 .createrecordDataLayer-fieldset").html('Loading...');
            
            console.log('MA.resources.Click2Create:',MA.resources.Click2Create);
            
            $.ajax({
                url: MA.resources.Click2Create,
                type: 'GET',
                dataType: 'HTML',
                data: {
                    sobject : $('#createDataLayerRecordV2 .createrecordDataLayer2-object').val(),
                    fieldset : fieldSetName,
                    recordtypeid :  (recordTypeId || ''),
                    platform : (MA.IsMobile ? 'tablet' : 'desktop')
                }
            })
            .complete(function (res) {
                //console.log(res);
                
                $("#createDataLayerRecordV2 .createrecordDataLayer-fieldset").html(res.responseText);
                
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
                            if(field != '') {
                                var phpFix = key.replace('dmp_','');
                                jsonData.topicData.push({topic_id:phpFix,field:field});
                            }
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
            })
            .error(function (err) {
                MA.log(err);
                //callback(res);
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
                            url: MA.resources.Tooltip+"?securityToken="+MASystem.MergeFields.Security_Token+"&action=createDataLayerRecordV2&core.apexpages.devmode.url=0",
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

                        //console.log('as:',ajaxData);

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
                                MAData.createC2CDLIcon(popupData, record.id);
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
    
    createC2CDLIcon: function (popupData, recordId) {
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
                content: MAMarkerBuilder.createSVG({ type: 'Marker', color: '#FF8800:Favorite' })
            });
        }
        else {
            marker = new google.maps.Marker({
                map: MA.map,
                position: dataLayerInfo.getPosition(),
                icon: {
                    url: 'data:image/svg+xml;base64,'+CryptoJS.enc.Base64.stringify(CryptoJS.enc.Utf8.parse(MAMarkerBuilder.createSVG({ type: 'Marker', color: '#FF8800:Favorite' }))),
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
            if (typeof sforce != 'undefined' && sforce.one) {
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
    
    deleteDataLayer: function (layerId) {
        $.ajax({
           url: MA.resources.Tree+"?securityToken="+MASystem.MergeFields.Security_Token+"&action=delete_layer",
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
           MA.log(res);
        });
    },
    
    wizard: {
        
        firstOpen: true,
        
        resetPopup: function (keepHeader) {
            keepHeader = keepHeader || false;
            MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
            //if changing the data source, do not reset the name and first select box
            if(!keepHeader) {
                //reset name tab
                $('#MADataLayerEditor .dl-label').val('');
                $('#MADataLayerEditor .dl-desc').val('');
                $("#dl-source-select").val('').change();
                $('#MADataLayerEditor .next-DataSource').removeClass('MA2active');
            }
            $('#dl-level').removeClass('MA2active');
            $("#dl-source-select").next().find('input').removeClass('error');
            $("#dl-level-select").val('').change();
            $('#dl-style').removeClass('MA2active');
            $('#dl-style .dl-cards .dl-card').removeClass('selected').addClass('hidden');
            $('#MADataLayerEditor .next-Tooltip').removeClass('MA2active');
            $('#dl-level-select').next().find('input').removeClass('error');

            //reset the tooltip tab
            $tooltip = $('#MADataLayerEditor .tooltipWrap');
            $tooltip.find('.hearers-wrap .dl-row').remove();
            $tooltip.find('.tabs-wrap .dl-tab').remove();
            $tooltip.find('.details-wrap .dl-row').remove();
            $tooltip.find('#dl-details-wrapper .dl-headerBtn').attr('disabled','disabled');

            //reset the style tab
            $('#dl-addFilters').removeClass('MA2active');
            $('#dl-filter-wrapper .dl-row').remove();
            $("#dl-legendSelect").val('').change();
            $('#legendDistButtons .dl-legitem').removeClass('hidden active');
            $('#dl-setupLegend').removeClass('MA2active');
            $('#dl-Done').removeClass('MA2active');
            $('#dl-legend-wrap').addClass('hidden');
            $('#dl-legend-info-wrapper').empty();
            $('#dl-legend-wrap .dl-legend-title').val('');
            $('#dl-addLegendRow-btn').addClass('hidden');
            $('#dl-legend-wrap .dl-legend-subtitle').val('');
            $('#legendImagePlaceholder').removeClass('hidden');
            $('#dl-useFilters .styleDLbtn').removeClass('button-blue');

            //finish up
            $('#MADataLayerEditor').removeData('topics');
            $('#MADataLayerEditor').removeData('popupData');
            $('#MADataLayerEditor').removeData('levelData');
            $('#MADataLayerEditor').removeData('filterTopicsDone');
            $('#MADataLayerEditor').removeData('useLegend');

            //go to the first tab
            if(!keepHeader) {
                $('#MADataLayerEditor #dl-details').click();
                $('#MADataLayerEditor').removeData();
                $('#MADataLayerEditor .dl-header-help').removeClass('hidden');
                $('#MADataLayerEditor .dl-details-help').removeClass('hidden');
            }
            
            //add a sample tab
            $('#add-dl-tab').click();
            $('#dl-tooltip-setup .dl-tab.active .tab-name').val('Info');

        },
        
        launchPopup: function (options) {
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
                //console.log(options,isClone);
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
                //$popup.find('.dl-combobox').combobox();
                //create keyup listener
                $popup.on('keyup','.dl-label',function() {
                    var $input = $(this);
                    if($input.val() != '') {
                        $popup.find('.next-DataSource').addClass('MA2active');
                    }
                    else {
                        $popup.find('.next-DataSource').removeClass('MA2active');
                    }
                });
                $popup.on('click','#cancelLegCreate',function() {
                    $('#legendDistButtons').addClass('MA2active');
                    $('#dl-legend-options').removeClass('MA2active');
                    $('#dl-legend-options .dl-legend-minVal').val('').removeClass('error');
                    $('#dl-legend-options .dl-legend-maxVal').val('').removeClass('error');
                    $('#dl-legend-options .dl-legend-buckets').val('').removeClass('error');
                    $('#legendDistButtons .dl-legitem').removeClass('hidden active');
                    $('#legendImagePlaceholder').removeClass('hidden');
                    $('#dl-legend-wrap').addClass('hidden');
                    $('#dl-legend-info-wrapper').empty();
                    $('#dl-Done').removeClass('MA2active');
                });
                MAData.wizard.firstOpen = false;
            }
            
        },
        
        getLayerInfo: function (options) {
            var id = options.id;
            options = $.extend({
                isClone : false,
            }, options || {});
            var isClone = options.isClone;
            $('#getLayerLoading').show();
            //get the data
            $.ajax({
               url: MA.resources.Tree+"?securityToken="+MASystem.MergeFields.Security_Token+"&action=get_layer",
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
                   var name = isClone == true ? data.Name + ' (clone)' : data.Name;
                   $popup.find('.dl-label').val(name);
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

                    //set up the data source and level
                    async.series([
                        function(callback){
                            //update the select list with the correct value then change
                            $('#dl-source-select').val(options.file_id).change();
                            MAData.getDataLayerLevelOfDetail(function(res) {
                                if(res.success) {
                                    $('#dl-level-select').val(options.level_id).change();
                                    callback(null, 1);
                                }
                                else{
                                    callback(res,1);
                                }
                            });
                        },
                        function(callback){
                            //update the level select box
                            MAData.getDataLayerStyle(function(res) {
                                if(res.success) {
                                    if(options.type === 'polygon') {
                                        $('#cardShape').addClass('selected').change();
                                        $('#legendImagePlaceholder .legImgWrapper[data-type="polygon"]').removeClass('hidden');
                                        $('#legendImagePlaceholder .legImgWrapper[data-type="polygon"] .legendImg.legendStatic').removeClass('hidden');
                                    } else {
                                        $('#cardMarker').addClass('selected').change();
                                        $('#legendImagePlaceholder .legImgWrapper[data-type="point"]').removeClass('hidden');
                                        $('#legendImagePlaceholder .legImgWrapper[data-type="point"] .legendImg.legendStatic').removeClass('hidden');
                                    }
                                    callback(null, 1);
                                }
                                else{
                                    callback(res,1);
                                }
                            });
                        },
                        function(callback) {
                            //setup the tooltips and filters
                            MAData.wizard.getPopupTopics(function(res) {
                                if(res.success) {
                                    //setup vars for access
                                    var filters = options.filters || [];
                                    var popup = options.popup || {};
                                    var header = popup.header || [];
                                    var tabs = popup.tabs || [];
                                    var legendRows = options.legend.rows || [];

                                    //if filter or legend is > 0 show options
                                    if(filters.length > 0 || legendRows.length > 0 && options.topic_id != '--') {
                                        MAData.wizard.styleSetup(true);
                                    }
                                    //console.log(legendRows);
                                    //udpate filters
                                    if(filters.length > 0 || legendRows.length > 0 && options.topic_id != '--') {
                                        //get the topics
                                        MAData.wizard.getFilterTopics(function (res) {
                                            if(res.success) {
                                                //update the select box with correct value
                                                $('#dl-legendSelect').val(options.topic_id).change();

                                                MAData.wizard.setupLegend($('#dl-legendSelect'));
                                                //loop over the filters and create rows
                                                for(var f = 0; f < filters.length; f++) {
                                                    var filter = filters[f];
                                                    //create rows 
                                                    MAData.wizard.createFilterRow(filter);
                                                }

                                                //just set the information divid to manual on recall
                                                $('#legendDistButtons .dl-legitem.manual').addClass('active');

                                                //if type == marker, hide certain divid info
                                                if(options.type == 'marker') {
                                                    $('#legendDistButtons .dl-legitem[data-type="decimal"]').addClass('hidden');
                                                }

                                                //show the legend, hide sample images
                                                var isFakeStyling = false;
                                                $('#legendImagePlaceholder').addClass('hidden');
                                                $('#dl-legend-wrap').removeClass('hidden');
                                                $('#dl-addLegendRow-btn').removeClass('hidden');
                                                //empty the legend rows just to be sure
                                                $('#dl-legend-info-wrapper').empty();
                                                for(var l = 0; l < legendRows.length; l++) {
                                                    var row = legendRows[l];
                                                    
                                                    //update the topic select
                                                    row.isSaved = true;
                                                    if(row.values && row.values == '--Other--') {
                                                        row.isOther = true;
                                                    }
                                                    MAData.wizard.createLegendRow(row);
                                                    
                                                    if(row.topic_id == '--other--') {
                                                        isFakeStyling = true;
                                                    }
                                                }

                                                //update the title and subtitle
                                                $('#dl-legend-wrap .dl-legend-title').val(options.legend.title);
                                                $('#dl-legend-wrap .dl-legend-subtitle').val(options.legend.subTitle);
                                                
                                                if(isFakeStyling) {
                                                    //no styling was used
                                                    $('#legendImagePlaceholder').removeClass('hidden');
                                                    $('#dl-legend-wrap').addClass('hidden');
                                                    MAData.wizard.styleSetup(false);
                                                }
                                            }
                                        });
                                    }
                                    else {
                                        //no styling was used
                                        $('#legendImagePlaceholder').removeClass('hidden');
                                        $('#dl-legend-wrap').addClass('hidden');
                                        MAData.wizard.styleSetup(false);
                                    }

                                    //do tooltips
                                    //empty any previous
                                    $('#dl-tooltip-setup .tabs-wrap .dl-tab').remove();
                                    $('#dl-tooltip-setup .details-wrap .dl-row').remove();
                                    $('#dl-tooltip-setup .hearers-wrap .dl-row').remove();

                                    //loop over tabs and create
                                    for(var t = 0; t < tabs.length; t++) {
                                        var tab = tabs[t];
                                        MAData.wizard.createTooltipTab(tab);
                                    }
                                    //create tooltip headers
                                    for(var h = 0; h < header.length; h++) {
                                        var hRow = header[h];
                                        //create the row
                                        MAData.wizard.createToolipRow({element:$('#dl-tooltip-header-addRow'),type:'header',data:hRow}); 
                                    }

                                   //let async know this process is done;
                                   callback();
                                }
                                else {
                                    callback('error','test');
                                }
                            });
                        }
                    ], function (err, result) {
                        //done getting the data so hide loading and finish up
                        $('#getLayerLoading').hide();

                        //let's not show the steps since this has already been made
                        $('#MADataLayerEditor .next-Tooltip').removeClass('MA2active');
                        $('#dl-Done').removeClass('MA2active');

                        $('#dl-rightPanel .dl-panel').animate({ scrollTop: 0}, 100);
                    });
               }
           })
           .error(function(res) {
               MA.log(res);
               $('#getLayerLoading').hide();
           });
        },
        
        closePopup: function () {
            ClosePopupWindow();
            MAData.wizard.resetPopup();
        },
        
        globalTimeout: null,
        
        changeTab: function (tab) {
            $tab = $(tab);
            var tabId = $tab.attr('id');
            $('#MADataLayerEditor .DemographicTable .ui-combobox input').removeClass('error');
            
            $('#MADataLayerEditor .dl-label').removeClass('error');
            

            if(tabId == 'dl-details') {
                $('.dl-panel').removeClass('MA2active');
                $('.dl-panel[data-id="'+tabId+'"]').addClass('MA2active');
                MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                $tab.addClass('active');
                return;
            }

            if($('#MADataLayerEditor .dl-label').val() == '') {
                $('#MADataLayerEditor .dl-label').addClass('error');
                return;
            }

            if(tabId == 'dl-dataSource'){
                //update selected
                $('.dl-panel').removeClass('MA2active');
                $('.dl-panel[data-id="'+tabId+'"]').addClass('MA2active');
                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                $tab.addClass('active');
                return;
            }

            //name is good, check for source
            if($('#dl-source-select').val() == '--') {
                $('#dl-source-select').next().find('input').addClass('error');
                return;
            }
            else if($('#dl-level-select').val() == '--') {
                $('#dl-level-select').next().find('input').addClass('error');
                return;
            }

            //get filter topics info since source is good
            MAData.wizard.getFilterTopics();

            if(tabId == 'dl-tooltip'){
                $('.dl-panel').removeClass('MA2active');
                $('.dl-panel[data-id="'+tabId+'"]').addClass('MA2active');
                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                $tab.addClass('active');
            }
            else if(tabId == 'dl-filters'){
                $('.dl-panel').removeClass('MA2active');
                $('.dl-panel[data-id="'+tabId+'"]').addClass('MA2active');
                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                $tab.addClass('active');
            }
            else if(tabId == 'dl-filtersFix'){
                $('.dl-panel').removeClass('MA2active');
                $('.dl-panel[data-id="'+tabId+'"]').addClass('MA2active');
                $('#MADataLayerEditor .sidebar .item').removeClass('active');
                $tab.addClass('active');
            }
            
        },
        
        styleSetup: function (useStyle) {
            var geo_type = $('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id');
            $('#legendImagePlaceholder .legendImg').addClass('hidden');
            $('#legendImagePlaceholder .legendSampleBtn').removeClass('active');
            $('#dl-useFilters .styleDLbtn').removeClass('button-blue');

            if(useStyle) {
                //show the information select options
                $('#dl-addFilters').addClass('MA2active');
                $('#legendImagePlaceholder .legImgWrapper[data-type="'+geo_type+'"]').addClass('hidden');
                $('#legendImagePlaceholder .legImgWrapper[data-type="'+geo_type+'"] .legendImg.legendColor').removeClass('hidden');
                $('#legendImagePlaceholder .legendSampleBtn.legendColor').addClass('active');
                $('#dl-Done').removeClass('MA2active');
                $('#MADataLayerEditor').data('useLegend',true);
                $('#dl-useFilters .colorLegend').addClass('button-blue');

                //some checks to see if things have already been filled out
                if($("#dl-legendSelect").val() != '--' && $("#dl-legendSelect").val() != null) {
                    //show legend setup
                    $('#dl-setupLegend').addClass('MA2active');
                }
                if($('#legendDistButtons .dl-legitem.active').length > 0) {
                    $('#dl-legend-wrap').removeClass('hidden');
                    $('#legendImagePlaceholder').addClass('hidden');
                    $('#dl-Done').addClass('MA2active');
                }
            }
            else {
                $('#dl-addFilters, #dl-setupLegend').removeClass('MA2active');
                $('#legendImagePlaceholder .legImgWrapper[data-type="'+geo_type+'"]').removeClass('hidden');
                $('#legendImagePlaceholder .legImgWrapper[data-type="'+geo_type+'"] .legendImg.legendStatic').removeClass('hidden');
                $('#legendImagePlaceholder .legendSampleBtn.legendStatic').addClass('active');
                $('#dl-useFilters .staticLegend').addClass('button-blue');

                $('#dl-Done').addClass('MA2active');

                //hide the legend info and show sample image
                $('#dl-legend-wrap').addClass('hidden');
                $('#legendImagePlaceholder').removeClass('hidden');
                $('#MADataLayerEditor').data('useLegend',false);



                //scroll down
                var $panel = $('#dl-rightPanel .dl-panel[data-id="dl-filters"]');
                var height = $panel[0].scrollHeight;
                $panel.animate({ scrollTop: height }, 1000);
            }
        },
        
        setupLegend: function () {
            var sourcesWithoutAutoLegend = ['x_dmp_data', 'x_usa_2016_dmp_sample', 'x_usa_dbusa', 'x_usa_dbusa_sample', 'x_eu_2016_nuts'];
            
            var $select = $('#dl-legendSelect');
            $('#dl-Done').removeClass('MA2active');
            $('#dl-legend-options').removeClass('MA2active');
            if($select.val() == '--' || $select.val() == null) {
                //hide the legend creation options
                $('#dl-setupLegend').removeClass('MA2active');
                $('#dl-legend-wrap').addClass('hidden');
                $('#legendImagePlaceholder').removeClass('hidden');
                $('#dl-legend-info-wrapper').empty();
            }
            else {
                //show the legend creation options
                $('#dl-setupLegend').addClass('MA2active');

                //update options
                var dataType = $('#dl-legendSelect option:selected').attr('data-type');
                $('#legendDistButtons .dl-legitem').removeClass('active');
                if (dataType == 'decimal') {
                    //disable auto legend, not supported
                    $('#legendDistButtons .dl-legitem[data-type="decimal"]').removeClass('hidden');
                    
                    //if property or biz data just set to manual
                    //var dataName = $('#dl-source-select option:selected').attr('data-name');
                    
                    var dataSource = $('#dl-source-select option:selected').val();
                    if( jQuery.inArray(dataSource, sourcesWithoutAutoLegend) > -1 ) {
                        $('#legendDistButtons .dl-legitem[data-type="decimal"]').addClass('hidden');
                        //set manual
                        $('#legendDistButtons .dl-legitem.manual').removeClass('hidden').addClass('active');
                        //create legend
                        MAData.wizard.createLegend('manual');
                    }
                }
                else {
                    $('#legendDistButtons .dl-legitem[data-type="decimal"]').addClass('hidden');
                    //set manual
                    $('#legendDistButtons .dl-legitem.manual').removeClass('hidden').addClass('active');
                    //create legend
                    MAData.wizard.createLegend('manual');
                }
            }
        },
        
        getPopupTopics: function (callback) {
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
                $.ajax({
                    url: MAData.domain+"/info/index.php?action=get_data_for_popup&orgid=" + MAData.orgId + "&level_id=" + $('#dl-level-select').val(),
                    type: 'GET',
                    dataType: 'JSON',
                    data: {}
                }).success(function(res) {
                    if (res.success && res.data.length > 0)
                    {
                        $('#MADataLayerEditor').data('popupData',res.data);
                        callback({success:true,data:res.data});
                    }
                    else {
                        callback({success:false, data: []});
                    }
                    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                }).error(function(err) {
                    //callback({success:false});
                });
                
                
                /*$.getJSON( MAData.domain+"/info/index.php?action=get_data_for_popup&orgid=" + MAData.orgId + "&level_id=" + $('#dl-level-select').val(), function( res ) {
        
                    if (res.success && res.data.length > 0)
                    {
                        $('#MADataLayerEditor').data('popupData',res.data);
                        callback({success:true,data:res.data});
                    }
                    else {
                        callback({success:false, data: []});
                    }
                    MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                });*/
            }
        },
        
        updateSampleImage: function (button,imgParam) {
            //update button
            $('#legendImagePlaceholder .legendSampleBtn').removeClass('active');
            var $button = $(button);
            $button.addClass('active');
            //show proper image
            var geo_type = $('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id');
            $('#legendImagePlaceholder .legendImg').addClass('hidden');
            $('#legendImagePlaceholder .legImgWrapper[data-type="'+geo_type+'"] .legendImg.'+imgParam+'').removeClass('hidden');
        },
        
        createFilterRow: function (options) {
            var $row = $('#templates .dl-filter-row').clone();
            
            $row.on('click','.remove-row',function() {
               var $r = $(this).closest('.dl-filter-row');
               $r.remove();
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
                /*if($row.find('.dl-filter-topic').val() != '--' && $row.find('.dl-filter-topic option:selected').attr('data-type') == 'string') {
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
                            MA.log(res);
                            $wrap.removeClass('wait');
                        });
                    }, 500); 
                }*/
                
                MAData.wizard.validateInput(this);
            });

            if($('#MADataLayerEditor').data('topics')) {
                var topicData = $('#MADataLayerEditor').data('topics');
                
                var filterSelectHTML = '<select style="width:100%;" class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
    
                filterSelectHTML += '<option value="--" disabled selected>Please select a topic</option>';

                $.each(topicData, function( index, value ) {
                   filterSelectHTML += '<option data-type="'+value.filter_type+'" value="' + value.topic_id + '">'+ value.topic_name +'</option>';
                });

                $row.find('.dl-filter-topic-wrap').html(filterSelectHTML);
                
                if($('#dl-legend-options .dl-legend-topic option').length === 0) {
                    $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                }
                
                if(options) {
                    $row.find('.dl-filter-topic').val(options.topic_id).trigger('change');
                    $row.find('.dl-filter-operator').val(options.operator).trigger('change');
                    if(options.operator == 'range') {
                        $row.find('.dl-filter-value-start').val(options.min);
                        $row.find('.dl-filter-value-end').val(options.max);
                    }
                    else {
                        var ajaxInt = setInterval(function() {
                            if($row.find('.dl-filter-value-start').length != 0) {
                                //check if this is a string or array
                                if(typeof options.values == 'string') {
                                    options.values = [options.values];
                                }
                                
                                //check if each option is in the select options otherwise add it
                                var $selectOptions = $row.find('.dl-filter-value-start option') || [];
                                for(var o = 0, length = options.values.length; o < length; o++) {
                                    var recallValue = options.values[o];
                                    var foundMatch = false;
                                    for(var s = 0, len = $selectOptions.length; s < len; s++) {
                                        var selectOption = $selectOptions[s];
                                        var selectValue = selectOption.getAttribute('value');
                                        if(recallValue === selectValue) {
                                            foundMatch = true;
                                            break;
                                        }
                                    };
                                    if(!foundMatch) {
                                        //append options
                                        $row.find('.dl-filter-value-start').prepend($('<option>', {
                                            value: recallValue,
                                            text: recallValue
                                        }));
                                    }
                                }
                                
                                $row.find('.dl-filter-value-start').val(options.values).trigger('change');
                                clearInterval(ajaxInt);
                            }
                        },500);
                    }
                }
                
                $('#dl-filters-wrapper').append($row);
                $row.find('.dl-filter-topic').select2();
                $row.find('.dl-filter-operator').select2();
                $('#dlFilters').append($row);
                 
            }
            else {
                $.ajax({
                    url: MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&level_id=" + $('#groupbyV2').val(),
                    type: 'GET',
                    dataType: 'JSON',
                    data: {}
                }).success(function(data) {
                    if (data.success && data.data.length > 0)
                    {
                        //store the data for easy creation later
                        $('#MADataLayerEditor').data('topics',data.data);
                        var filterSelectHTML = '<select style="width:100%;" class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
        
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
                        
                        var filterSelectHTML = '<select style="width:100%;" class="dl-filter-topic">';

                        filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
                        filterSelectHTML += '</select>';
                        $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                    }
                    else {
                        MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                        
                        var filterSelectHTML = '<select style="width:100%;" class="dl-filter-topic">';

                        filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
                        filterSelectHTML += '</select>';
                        $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                    }
                    
                    if(options) {
                        $row.find('.dl-filter-topic').val(options.topic_id).trigger('change');
                        $row.find('.dl-filter-operator').val(options.operator).trigger('change');
                        if(options.operator == 'range') {
                            $row.find('.dl-filter-value-start').val(options.min);
                            $row.find('.dl-filter-value-end').val(options.max);
                        }
                        else {
                            var ajaxInt = setInterval(function() {
                                
                                if($row.find('.dl-filter-value-start').length != 0) {
                                    $row.find('.dl-filter-value-start').val(options.values).trigger('change');
                                    clearInterval(ajaxInt);
                                }
                            },500);
                        }
                    }
                    
                    $row.find('.dl-filter-topic').select2();
                    $row.find('.dl-filter-operator').select2();
                    $('#dlFilters').append($row);
                }).error(function(err) {
                    //callback({success:false});
                });
                
                /*$.getJSON( MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&level_id=" + $('#groupbyV2').val(), function( data ) {
    
                    if (data.success && data.data.length > 0)
                    {
                        //store the data for easy creation later
                        $('#MADataLayerEditor').data('topics',data.data);
                        var filterSelectHTML = '<select style="width:100%;" class="dl-filter-topic" onchange="MAData.wizard.updateFilter(this)">';
        
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
                        
                        var filterSelectHTML = '<select style="width:100%;" class="dl-filter-topic">';

                        filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
                        filterSelectHTML += '</select>';
                        $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                    }
                    else {
                        MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
                        
                        var filterSelectHTML = '<select style="width:100%;" class="dl-filter-topic">';

                        filterSelectHTML += '<option value="" disabled selected>No topics found</option>';
                        filterSelectHTML += '</select>';
                        $('#dl-legend-options .dl-legend-topic').html(filterSelectHTML);
                    }
                    
                    if(options) {
                        $row.find('.dl-filter-topic').val(options.topic_id).trigger('change');
                        $row.find('.dl-filter-operator').val(options.operator).trigger('change');
                        if(options.operator == 'range') {
                            $row.find('.dl-filter-value-start').val(options.min);
                            $row.find('.dl-filter-value-end').val(options.max);
                        }
                        else {
                            var ajaxInt = setInterval(function() {
                                
                                if($row.find('.dl-filter-value-start').length != 0) {
                                    $row.find('.dl-filter-value-start').val(options.values).trigger('change');
                                    clearInterval(ajaxInt);
                                }
                            },500);
                        }
                    }
                    
                    $row.find('.dl-filter-topic').select2();
                    $row.find('.dl-filter-operator').select2();
                    $('#dlFilters').append($row);
                });*/
            }

            $('#dlFilters').append($row)
            
        },
        
        getFilterTopics: function (callback) {
            callback = callback || function(){};
            if($('#MADataLayerEditor').data('filterTopicsDone') == 'Done') {
                callback({success:true});
                return;
            }
            else {
                $.ajax({
                    url: MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#dl-source-select').val() + "&level_id=" + $('#dl-level-select').val(),
                    type: 'GET',
                    dataType: 'JSON',
                    data: {}
                }).success(function(data) {
                    if (data.success && data.data.length > 0)
                    {
                        var selectOptions = data.data;        
                        var filterSelectHTML = '<select id="dl-legendSelect" onchange="MAData.wizard.setupLegend(this)">';

                        filterSelectHTML += '<option value="--" disabled selected>Please select a topic</option>';

                        $.each(selectOptions, function( index, value ) {
                           filterSelectHTML += '<option data-type="'+value.filter_type+'" value="' + value.topic_id + '">'+ value.topic_name +'</option>';
                        });

                        $('#dl-legendSelect-wrap').html(filterSelectHTML);
                        $('#dl-legendSelect').select2();
                        $('#MADataLayerEditor').data('filterTopicsDone','Done');
                        $('#MADataLayerEditor').data('topics',selectOptions);
                        callback({success:true});
                    }
                    else
                    {
                        //Error! Read message property
                        //console.log(data.message);
                        callback({success:false});
                    }
                }).error(function(err) {
                    callback({success:false});
                });
                
               /* $.getJSON( MAData.domain+"/info/index.php?action=get_filterable_topics&orgid=" + MAData.orgId + "&file_id=" + $('#dl-source-select').val() + "&level_id=" + $('#dl-level-select').val(), function( data ) {
                    if (data.success && data.data.length > 0)
                    {
                        var selectOptions = data.data;        
                        var filterSelectHTML = '<select id="dl-legendSelect" onchange="MAData.wizard.setupLegend(this)">';

                        filterSelectHTML += '<option value="--" disabled selected>Please select a topic</option>';

                        $.each(selectOptions, function( index, value ) {
                           filterSelectHTML += '<option data-type="'+value.filter_type+'" value="' + value.topic_id + '">'+ value.topic_name +'</option>';
                        });

                        $('#dl-legendSelect-wrap').html(filterSelectHTML);
                        $('#dl-legendSelect').select2();
                        $('#MADataLayerEditor').data('filterTopicsDone','Done');
                        $('#MADataLayerEditor').data('topics',selectOptions);
                        callback({success:true});
                    }
                    else
                    {
                        //Error! Read message property
                        //console.log(data.message);
                        callback({success:false});
                    }
                });*/
            }
        },
        
        removeError: function(type) {
             $('#MADataLayerEditor .notificationMsg').hide().removeClass('error').html('');
        },
        
        createLegendCheck: function (showOptions,type) {
            var $button = $('#legendDistButtons .dl-legitem.'+type+'');
            if($button.hasClass('active')) {
                return;
            }
            $('#legendDistButtons .dl-legitem').removeClass('active')
            $button.addClass('active');
            $('#dl-Done').removeClass('MA2active');
            $('#legendImagePlaceholder').removeClass('hidden');
            $('#dl-legend-wrap').addClass('hidden');
            $('#dl-legend-info-wrapper').empty();
            if(showOptions) {
                $('#dl-legend-options').addClass('MA2active');
                $('#legendDistButtons .dl-legitem').addClass('hidden');
                if(type == 'quantiles') {
                    $('#dl-legend-minVal').addClass('hidden');
                    $('#dl-legend-maxVal').addClass('hidden');
                    $('#dl-legend-buckets .fieldLabel').css('padding-top','0px');
                }
                else {
                    $('#dl-legend-minVal').removeClass('hidden');
                    $('#dl-legend-maxVal').removeClass('hidden');
                    $('#dl-legend-buckets').removeClass('hidden');
                    $('#dl-legend-buckets .fieldLabel').css('padding-top','10px');
                }
                $button.removeClass('hidden');
            }
            else {
                $('#dl-legend-options').removeClass('MA2active');
                MAData.wizard.createLegend(type);
            }
        },
        
        createLegend: function (type) {
            //show the finshed logo
            $('#dl-Done').addClass('MA2active');

            var fileId = $('#dl-source-select').val();
            var topicId = $('#dl-legendSelect').val();
            var levelId = $('#dl-level-select').val();
            $('#dl-legend-info-wrapper').empty();
            $('#dl-addLegendRow-btn').addClass('hidden');
            $('#dl-legend-options .dl-legend-buckets').removeClass('error');
            var urlString = ''
            var doAJAX = true;
            if(topicId == '--') {
                $('#dl-legend-options .dl-legend-topic').addClass('error');
                return;
            }
            if(type == 'getType') {
                type = $('#legendDistButtons .dl-legitem.active').attr('data-id');
            }
            if(type == 'auto') {
                urlString = MAData.domain+"/info/index.php?action=get_suggested_legend&orgid=" + MAData.orgId + "&file_id=" + fileId + "&topic_id=" + topicId + "&level_id=" + levelId;
            }
            else if (type == 'quantiles') {
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
                var min = $('#dl-legend-options .dl-legend-minVal').val().replace(/,/g,'');
                var max = $('#dl-legend-options .dl-legend-maxVal').val().replace(/,/g,'');
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
                if($('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id') == 'point') {
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

            //show the legend wrapper
            $('#legendImagePlaceholder').addClass('hidden');
            $('#dl-legend-wrap').removeClass('hidden');

            //update the legend title with the selected options
            $('#dl-legend-grid .dl-legend-title').val($('#dl-legendSelect option:selected').text() || '');
        },
        
        createTooltipTab: function (options) {
            var tabLimit = 6;
            
            var tabLength = $('#dl-tooltip-setup .dl-tab').length;
            if(tabLength >= tabLimit) {
                var msg = 'Only '+tabLimit+' tabs are allowed per data layer.';
                $('#MADataLayerEditor').find('.notificationMsg').addClass('error').text(msg).show();
                setTimeout(function() {
                    $('#MADataLayerEditor').find('.notificationMsg').removeClass('error').hide()
                },5000);
                return;
            }
            //limit tabs
            var tabLength = $('#MADataLayerEditor .tabs-wrap .dl-tab').length;
            if(tabLength >= tabLimit) {
                var msg = 'A max of '+tabLimit+' tabs may be assigned per data layer.';
                $('#MADataLayerEditor').find('.notificationMsg').addClass('error').text(msg).show();
                setTimeout(function() {
                    $('#MADataLayerEditor').find('.notificationMsg').removeClass('error').hide()
                },5000);
                return;
            }
            //check how many tabs we have for the temp title
            var uid = new Date();
            uid = uid.getTime() + MA.componentIndex++;
            var newTabIndex = $('#dl-rightPanel .tabs-wrap .dl-tab').length + 1;
            var $row = $('#templates .dl-tab.template').clone().removeClass('template');
            $row.find('.tab-name').val('New Tab');
            
            $row.attr({'tab-index': newTabIndex, 'uid' : uid});

            if(options) {
                //update the row with saved info
                $row.find('.tab-name').val(options.tab_label);
                
                //create row if needed
                var data = options.data || [];
                for(var d = 0; d < data.length; d++) {
                    var dRow = data[d];
                    dRow.uid = uid;
                    MAData.wizard.createToolipRow({type:'tab',data:dRow,uid:uid});
                }
                $row.find('.dl-tooltip-collapse').click();
            }
            
            $row.appendTo($('#dl-rightPanel .tabs-wrap'));

            //set the new tab as active
            $('#dl-rightPanel .tabs-wrap .dl-tab').removeClass('active');
            $row.addClass('active');
            $('#dl-rightPanel .details-wrap .dl-row').hide();
            $('#dl-rightPanel .details-wrap .dl-row[data-tabid="'+uid+'"]').show();
            $('#dl-details-wrapper .dl-headerBtn').removeAttr('disabled');
            
        },
        
        removeTooltipTab: function (element) {
            var $element = $(element);
            var $tab = $element.closest('.dl-tab');

            //remove rows that are related to this tab
            var uid = $tab.attr('uid');
            $('#dl-rightPanel .details-wrap .dl-row[data-tabid="'+uid+'"]').remove();
            var wasActive = $tab.hasClass('active');
            $tab.remove();

            var $tabs = $('#dl-rightPanel .tabs-wrap .dl-tab');
            var tabLength = $tabs.length;
            if(tabLength >= 1) {
                if(wasActive) {
                    var $newTab = $tabs.first();
                    $newTab.addClass('active');
                    var uid = $newTab.attr('uid');
                    $('#dl-rightPanel .details-wrap .dl-row[data-tabid="'+uid+'"]').show();
                }
            }
            else {
                $('#dl-details-wrapper .dl-headerBtn').attr('disabled','true');
            }
        },
        
        handleTooltipClick: function (element) {
            $('#dl-rightPanel .tabs-wrap .dl-tab').removeClass('active');
            //can be the tab or the inpu
            var $input = $(element);
            var $tab = $input.closest('.dl-tab');
            $tab.addClass('active');
            var uid = $tab.attr('uid');

            //show hide the proper rows
            $('#dl-rightPanel .details-wrap .dl-row').hide();
            $('#dl-rightPanel .details-wrap .dl-row[data-tabid="'+uid+'"]').show();
        },
        
        createToolipRow: function (options) {
            var headerLimit = 3;
            var tooltipLimit = 10;
            
            //limit rows
            if(options.type == 'tab') {
                //get the tab id
                var uid = options.uid || $('#dl-rightPanel .tabs-wrap .dl-tab.active').attr('uid');
                //count the rows for the tab
                var tabLength = $('#dl-details-wrapper .dl-tooltip-row[data-tabid="'+uid+'"]').length;
                $('#MADataLayerEditor .dl-details-help').addClass('hidden');
                if(tabLength >= tooltipLimit) {
                    var msg = 'Only '+tooltipLimit+' tooltips can be used per tab. Please select a different tab to add more details.';
                    $('#MADataLayerEditor').find('.notificationMsg').addClass('error').text(msg).show();
                    setTimeout(function() {
                        $('#MADataLayerEditor').find('.notificationMsg').removeClass('error').hide()
                    },5000);
                    return;
                }
            }
            if(options.type == 'header') {
                //count the rows for the header
                var headerLength = $('#dl-tooltip-setup .hearers-wrap .dl-tooltip-row').length;
                $('#MADataLayerEditor .dl-header-help').addClass('hidden');
                if(headerLength >= headerLimit) {
                    var msg = 'A max of '+headerLimit+' headers are allowed.  Please create a tab to add more details.';
                    $('#MADataLayerEditor').find('.notificationMsg').addClass('error').text(msg).show();
                    setTimeout(function() {
                        $('#MADataLayerEditor').find('.notificationMsg').removeClass('error').hide()
                    },5000);
                    return;
                }
            }
            //build file and topic data
            MAData.wizard.getPopupTopics(function(res) {
                if(res.success) {
                    var fileData = res.data;
                    var $row = $('#templates .dl-tooltip-row').clone();
                    
                    //get the selected tab uid
                    var uid = $('#dl-rightPanel .tabs-wrap .dl-tab.active').attr('uid');
                    $row.attr('data-tabId', uid);

                    //loop over options and create select
                    var fileSelectHTML = '<select style="width: 100%;" class="dl-tooltip-file">';
        
                    fileSelectHTML += '<option disabled="disabled" value="--" selected>--Select--</option>';
    
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
                                var topicSelectHTML = '<select style="width: 100%;" class="dl-tooltip-topic">';
        
                                topicSelectHTML += '<option disabled="disabled" value="--" selected>--Select--</option>';
                
                                $.each(topicArr, function( index, value ) {
                                   topicSelectHTML += '<option value="' + value.topic_id + '">'+ value.topic_name +'</option>';
                                });
                                
                                $row.find('.dl-tooltip-topic-wrap').html(topicSelectHTML);
                                $row.find('.dl-tooltip-topic').select2();
                            }
                        }
                    });
                    
                    $row.on('click','.remove-row',function() {
                       var $r = $(this).closest('.dl-tooltip-row');
                       $r.remove();
                    });
                    
                    if(options.type == 'tab') {
                        //add this row the element
                        $('#MADataLayerEditor .details-wrap').append($row);
                    }
                    else {
                        $('#MADataLayerEditor .hearers-wrap').append($row);
                    }

                    //set the data source to the data source selected earlier
                    $row.find('.dl-tooltip-file').val($('#dl-source-select').val()).change();
                    
                    //init combobox
                    $row.find('.dl-tooltip-file').select2();
                    $row.find('.dl-tooltip-topic').select2();
                    
                    if(options.data) {
                        $row.find('.dl-tooltip-file').val(options.data.file_id).change();
                        $row.find('.dl-tooltip-file').change();
                        $row.find('.dl-tooltip-topic').val(options.data.topic_id).change();
                        $row.attr('data-tabid',options.data.uid);
                    }
                }
            });
        },
        
        createLegendRow: function(options) {
            //make sure we have a topic selected
            options = $.extend({
                min: "",
                min_label : "",
                max : "",
                max_label : "",
                color : "#3c78d8",
                isOther : false,
            }, options || {});
            var dataType = $('#dl-legendSelect option:selected').attr('data-type');
            
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
                var type = $('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id')
                var showMarkers = false;

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
                            url: MAData.domain+"/info/index.php?action=get_autocomplete&v=2&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&topic_id=" + $('#dl-legend-options .dl-legend-topic').val() + "&level_id=" + $('#groupbyV2').val() + "&search=" + $input.val(),
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
                                    var li = '<li value="'+item.value+'">'+item.label+'</li>';
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

            //init combobox
            $row.find('.dl-filter-operator').select2();
            
            // REMOVED TO FIX MAY16MAPRT-197 & MAY16MAPRT-201
            // if(!options.isSaved) {
            //     $row.find('.dl-filter-operator').change();
            // }
            
            if(options.isOther) {
                $row.addClass('OTHER').find('.dl-filter-operator').val('equals').attr('disabled','disabled').css('background-color','#e8e8e8').next().find('input').val($row.find('.dl-filter-operator option:selected').text());
                $row.find('.dl-filter-value-start').val('--Other--').attr('disabled','disabled').css('background-color','#e8e8e8');
                $row.find('.remove-row').remove();
                $row.find('.ui-combobox a').remove();
                $row.find('.ui-combobox input').css('cssText','background-color: rgb(232, 232, 232) !important').attr('disabled','true');
            }

            if($('#dl-legend-info-wrapper .OTHER').length > 0) {
                $row.insertBefore($('#dl-legend-info-wrapper .OTHER'));
            }
            else {
                $row.appendTo($('#dl-legend-info-wrapper'));
            }
            
        },
        
        updateLegendRowColor: function (options) {
            //get the layer type
            var levelData = $('#MADataLayerEditor').data('levelData');
            var currentLevel = $('#groupbyV2').val();
            var type = $('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id')
            
            var colorHTML = '';
            if(type == '') {
                return colorHTML;
            }
            else if (type == 'polygon') {
                colorHTML = '<div class="dl-legend-colorBox" style="background:'+options.color+'; height: 20px;width: 20px;border-radius: 3px;"></div>';
            }
            else if (type == 'point') {
                var pointType = options.pointType || 'Marker';
                colorHTML = '<span class="dl-legend-colorBox">'+MAMarkerBuilder.createSVG({ color: options.color + ':' + pointType,forLegend:true })+'</span>';
            }
            
            return colorHTML;
        },
        
        updateValueField: function (select,forLegend) {
            var operator = $(select).val();
            var $row = $(select).closest('.dl-row');
            var rowvalStart = $row.find('.dl-filter-value-start').val();
            var rowvalEnd = $row.find('.dl-filter-value-start').val();
            var html = '';
            
            var dataType;
            var paddingFix = false;
            
            var isDMP = ($row.find('.dl-filter-topic').val() || '').indexOf('dmp') === 0;
            
            
            
            
            
            if(forLegend) {
                dataType = $('#dl-legendSelect option:selected').attr('data-type');
                paddingFix = true;
            }
            else {
                dataType = $row.find('.dl-filter-topic option:selected').attr('data-type');
            }
            
            
            
            
            if(operator == 'range') {
                //show 2 input boxes
                $(select).find('.dl-filter-value-wrapper').empty();
                html = '<input class="dl-filter-value-start" style="width: calc(50% - 25px);" type="text" onkeyup="MAData.wizard.validateInput(this,'+forLegend+');"/><span> - </span><input style="width: calc(50% - 25px);" class="dl-filter-value-end" onkeyup="MAData.wizard.validateInput(this,'+forLegend+');" type="text"/>'
            }
            else if (dataType != 'date'){
                var isNotDMPAndIsDecimal = (!isDMP && dataType == 'decimal');
                var isDMPAndIsPartialString = (isDMP && (operator === 'starts with' || operator === 'contains' || operator === 'does not contain'));
                
                if( isNotDMPAndIsDecimal || isDMPAndIsPartialString ) {//|| (isDMP && dataType == 'string') ) {
                    html = '<input class="dl-filter-value-start" style="width: calc(100% - 20px);" type="text"/></div>';
                }
                else if(!forLegend) {
                    
                    $.ajax({
                        url: MAData.domain+"/info/index.php?action=get_autocomplete&v=2&orgid=" + MAData.orgId + "&file_id=" + $('#datasourceV2').val() + "&topic_id=" + $row.find('.dl-filter-topic').val() + "&level_id=" + $('#groupbyV2').val() + "&search=",
                        type: 'GET',
                        dataType: 'JSON',
                        data: {}
                    }).done(function(res) {
                        if(res.success) {
                            var data = res.data || [];
                            if(data.length > 0) {
                                html = '<select multiple="multiple" style="width: 100%;" class="rowSelect dl-filter-value-start">';
                                for(var i = 0, length = data.length; i < length; i++) {
                                    var option = data[i];
                                    if(option != '') {
                                        html += '<option value="'+option.value+'">'+option.label+'</option>';
                                    }
                                }
                                html += '</select>';
                                
                                //update the row
                                $row.find('.dl-filter-value-wrapper').html(html);
                                $row.find('.rowSelect').select2({
                                    placeholder: "Select a value...",
                                    closeOnSelect: false,
                                    tags : true
                                });
                                $row.find('.dl-filter-value-start').val(rowvalStart);
                                $row.find('.dl-filter-value-end').val(rowvalEnd);
                            }
                            else {
                                html = '<input class="dl-filter-value-start" style="width: calc(100% - 20px);" type="text"/></div>';
                                $row.find('.dl-filter-value-wrapper').html(html);
                                $row.find('.dl-filter-value-start').val(rowvalStart);
                                $row.find('.dl-filter-value-end').val(rowvalEnd);
                            }
                        }
                        else {
                            html = '<input class="dl-filter-value-start" style="width: calc(100% - 20px);" type="text"/></div>';
                            $row.find('.dl-filter-value-wrapper').html(html);
                            $row.find('.dl-filter-value-start').val(rowvalStart);
                            $row.find('.dl-filter-value-end').val(rowvalEnd);
                        }
                    }).error(function(err) {
                        html = '<input class="dl-filter-value-start" style="width: calc(100% - 20px);" type="text"/></div>';
                        $row.find('.dl-filter-value-wrapper').html(html);
                        $row.find('.dl-filter-value-start').val(rowvalStart);
                        $row.find('.dl-filter-value-end').val(rowvalEnd);
                    });
                }
                else {
                    html = '<input class="dl-filter-value-start" style="width: calc(100% - 20px);" type="text"/></div>';
                }
                        
            }
            else {
                html = '<input class="dl-filter-value-start" style="width: calc(100% - 20px);" type="text" onkeyup="MAData.wizard.validateInput(this,'+forLegend+');"/></div>';
            }
            
            //update the row
            $row.find('.dl-filter-value-wrapper').html(html);
            
            $row.find('.dl-filter-value-start').val(rowvalStart);
            $row.find('.dl-filter-value-end').val(rowvalEnd);
            
            if(dataType == 'date') {
                if(operator == 'range') {
                    $row.find('.dl-filter-value-start').css('width','calc(50% - 50px)').addClass('isDate').attr('placeholder','yyyy-mm-dd').datepicker({
                        showOn: "button",
                        buttonImage: MA.Images.calendar,
                        buttonImageOnly: true,
                        buttonText: "",
                        dateFormat: "yy-mm-dd",
                        onClose: function( selectedDate ) {
                            $row.find('.dl-filter-value-end').datepicker( "option", "minDate", selectedDate );
                            MAData.wizard.validateInput($row.find('.dl-filter-value-start'),forLegend);
                        }
                    });
                    $row.find('.dl-filter-value-end').css('width','calc(50% - 50px)').addClass('isDate').attr('placeholder','yyyy-mm-dd').datepicker({
                        showOn: "button",
                        buttonImage: MA.Images.calendar,
                        buttonImageOnly: true,
                        buttonText: "",
                        dateFormat: "yy-mm-dd",
                        onClose: function( selectedDate ) {
                            $row.find('.dl-filter-value-start').datepicker( "option", "maxDate", selectedDate );
                            MAData.wizard.validateInput($row.find('.dl-filter-value-end'),forLegend);
                        }
                    });
                }
                else {
                    $row.find('.dl-filter-value-start').css('width','calc(100% - 50px)').addClass('isDate').attr('placeholder','yyyy-mm-dd').datepicker({
                        showOn: "button",
                        buttonImage: MA.Images.calendar,
                        buttonImageOnly: true,
                        buttonText: "",
                        dateFormat: "yy-mm-dd",
                        onClose: function( selectedDate ) {
                            MAData.wizard.validateInput($row.find('.dl-filter-value-start'),forLegend);
                        }
                    });
                }
            }
            else {
                $row.find('.dl-filter-value-start').removeAttr('disabled');
                $row.find('.dl-filter-value-end').removeAttr('disabled');
            }
        },
        
        buildOperatorSelect: function (type,forLegend) {
            forLegend = forLegend || false;
            //only show range if polygon
            var currentLevel = $('#dl-level-select').val();
            var geo_type = $('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id');
            
            var operatorSelectHTML = '<select style="width:100%;" class="dl-filter-operator" onchange="MAData.wizard.updateValueField(this,'+forLegend+');">';
            //operatorSelectHTML += '<option value="--" selected>Please select an operator</option>';
            
            if(type == 'string') {
                operatorSelectHTML += '<option value="equals">equals</option>';
                operatorSelectHTML += '<option value="not equal to">not equal to</option>';
                operatorSelectHTML += '<option value="starts with">starts with</option>';
                operatorSelectHTML += '<option value="contains">contains</option>';
                operatorSelectHTML += '<option value="does not contain">does not contain</option>';
            }
            else if (type == 'decimal') {
                //REMOVED POLYGON RANGE ONLY FOR ISSUE MAY16MAPRT-84 - https://mapanything.atlassian.net/browse/MAY16MAPRT-84
                
                // if(geo_type == 'polygon') {
                //     operatorSelectHTML += '<option value="range">range</option>';
                // }
                // else {
                    operatorSelectHTML += '<option value="equals">equals</option><option value="not equal to">not equal to</option>';
                    operatorSelectHTML += '<option value="less than">less than</option><option value="greater than">greater than</option>';
                    operatorSelectHTML += '<option value="less or equal">less or equal</option>';
                    operatorSelectHTML += '<option value="greater or equal">greater or equal</option>';
                    operatorSelectHTML += '<option value="range">range</option>';
                // }
            }
            else if (type == 'date') {
                operatorSelectHTML += '<option value="equals">equals</option><option value="not equal to">not equal to</option>';
                operatorSelectHTML += '<option value="less than">less than</option><option value="greater than">greater than</option>';
                operatorSelectHTML += '<option value="less or equal">less or equal</option>';
                operatorSelectHTML += '<option value="greater or equal">greater or equal</option>';
                operatorSelectHTML += '<option value="range">range</option>';
            }
            else if (type == 'boolean') {
                operatorSelectHTML += '<option value="equals">equals</option>';
            }
            
            operatorSelectHTML += '</select>';
            
            return operatorSelectHTML;
            
        },
        
        updateFilter: function (selection) {
            var $topic = $(selection);
            var $option = $topic.find('option:selected');
            var dataType = $option.attr('data-type');

            //get the level details


            //build operator options
            var html = MAData.wizard.buildOperatorSelect(dataType);
            
            //update the row
            var $row = $topic.closest('.dl-filter-row');
            
            $row.find('.dl-filter-operator-wrap').html(html);
            $row.find('.dl-filter-operator-wrap select').select2({
                    placeholder : 'Please select a topic'
                }).change();
            if(dataType == 'date') {
                $row.find('.dl-filter-value-start').val('');
            } else if(dataType == 'boolean') {
                var selectHTML = '<select class="dl-filter-value-start" style="width:100%;"><option value="true">True</option><option value="false">False</option></select>';
                $row.find('.dl-filter-value-wrapper').html(selectHTML);
                $row.find('.dl-filter-value-wrapper select').select2({
                    placeholder : 'Please select a topic'
                }).change();
            }
            
        },
        
        saveDataLayer: function (plotLayer) {
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
            var currentLevel = $('#dl-level-select').val();
            var $sourceSelect = $('#dl-source-select');
            var type = $('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id');
            
            //start building json data
            var jsonData = {
                type : type == 'point' ? 'marker' : 'polygon',
                file_id : $sourceSelect.val(),
                level_id : currentLevel,
                topic_id : $('#dl-legendSelect').val(),
                country_id : '--',
                opacity : 50
            };
            
            
            var filtersArr = $('#dlFilters .dl-filter-row');
            var filtersJSON = [];
            for(var f = 0; f < filtersArr.length; f++){
                var $filter = $(filtersArr[f]);
                //ignore if blank or no topic selected
                if($filter.find('.dl-filter-value-start').val() != '' && $filter.find('.dl-filter-topic').val()) {
                    var operator = $filter.find('.dl-filter-operator').val();
                    if(operator != '') {
                        var errors = 0;
                        var filterObj = {
                            topic_id : $filter.find('.dl-filter-topic').val(),
                            operator: operator
                        };
                        if(operator == 'range') {
                            errors += jQuery.inArray('error', $filter.find('.dl-filter-value-start')[0].classList) > -1 ? 1 : 0;
                            errors += jQuery.inArray('error', $filter.find('.dl-filter-value-end')[0].classList) > -1 ? 1 : 0;
                            
                            filterObj['min'] = $filter.find('.dl-filter-value-start').val();
                            filterObj['max'] = $filter.find('.dl-filter-value-end').val();
                        }
                        else {
                            errors += jQuery.inArray('error', $filter.find('.dl-filter-value-start')[0].classList) > -1 ? 1 : 0;
                            //convert strings to array
                            var value = $filter.find('.dl-filter-value-start').val();
                            if(typeof $filter.find('.dl-filter-value-start').val() == 'string') {
                                value = [$filter.find('.dl-filter-value-start').val()];
                            }
                            
                            if(!value) {
                                //this is empty, skip
                                errors++;
                            }
                            filterObj['values'] = value;
                        }
                        
                        if(errors === 0) {
                            filtersJSON.push(filterObj);
                        }
                    }
                }
            }
            
            //add the filters to the saveData
            jsonData['filters'] = filtersJSON;
            
            //loop over the filters
            if($('#MADataLayerEditor').data('useLegend')) {
                
                //build our legend
                var legendArr = $('#dl-legend-info-wrapper .dl-legend-row');
                var legendJSON = {
                    title : $('#dl-legend-grid .dl-legend-title').val(),
                    subTitle : $('#dl-legend-grid .dl-legend-subtitle').val(),
                    rows : []
                };
                for(var l = 0; l < legendArr.length; l++) {
                    var $legend = $(legendArr[l]);
                    if($legend.find('.dl-filter-value-start').val() != '') {
                        var operator = $legend.find('.dl-filter-operator').val();
                        if(operator != '') {
                            var legObj = {
                                topic_id : $('#dl-legendSelect').val(),
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
            }
            else {
                //setup the legend differently depending on type selection
                var legendRow = {};
                if(type == 'polygon') {
                    legendRow = {
                        color: '3c78d8',
                        max : '0',
                        min : '0',
                        operator : 'range',
                        topic_id : '--other--'
                    };
                }
                else if(type == 'point') {
                    legendRow = {
                        color : '93c47d:Circle',
                        operator : 'equals',
                        topic_id : '--other--',
                        values : '--Other--'
                    }
                }
                jsonData['legend'] = {
                    title: $('#dl-source-select option:selected').attr('data-name'),
                    subtitle: '--',
                    rows : [legendRow]
                };
            }
            
            //get popup
            var popupJSON = {
                header : [],
                tabs : []
            };
            var $tooltipSetup = $('#dl-tooltip-setup');
            //loop over rows
            var headerRows = $tooltipSetup.find('.hearers-wrap .dl-tooltip-row');
            for(var h = 0; h < headerRows.length; h++) {
                var $head = $(headerRows[h]);
                var file_id = $head.find('.dl-tooltip-file').val();
                var topic_id = $head.find('.dl-tooltip-topic').val();
                if(topic_id != '--' && file_id != '--') {
                    var headObj = {
                        type: '',
                        file_id: file_id,
                        topic_id: topic_id
                    }
                    popupJSON.header.push(headObj);
                }
            }
            
            //get tabs
            var tabRows = $tooltipSetup.find('.tabs-wrap .dl-tab');
            var tabsJSON = popupJSON.tabs;
            for(var t = 0; t < tabRows.length; t++) {
                var $tab = $(tabRows[t]);
                var tabLabel = $tab.find('.tab-name').val();
                tabUID = $tab.attr('uid');
                var tabObj = {
                    tab_id : tabUID,
                    tab_label: tabLabel,
                    data : []
                }
                
                //loop over the data rows that match that tab uid
                var $dataRows = $tooltipSetup.find('.details-wrap .dl-tooltip-row[data-tabid="'+tabUID+'"]');
                for(var dr = 0; dr < $dataRows.length; dr++) {
                    var $row = $($dataRows[dr]);
                    var tabfile_id = $row.find('.dl-tooltip-file').val();
                    var tabtopic_id = $row.find('.dl-tooltip-topic').val();
                    if(tabfile_id != '--' && tabtopic_id != '--') {
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
                    //Something has to happen if we're in a subfolder here
                    
                    folderId = $('#MADataLayerEditor').data('folder-id');
                    var breadcrumbText = '';
                    //We've got to figure this thing out now
                    
                    if (NewLayerNavigationEnabled()) {
                        $.each($('div#folder-breadcrumb > a'), function(i,v) { 
                            breadcrumbText += $(v).text(); 
                        });
                        
                        //Check if this string contains 'Personal'
                        if(breadcrumbText.indexOf('Personal') === 4) {
                            userId = MA.CurrentUser.Id;
                        }
                    } else {
                        
                    }
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
            };
            
            //save
            $.ajax({
                url: MA.resources.Tree+"?securityToken="+MASystem.MergeFields.Security_Token+"&action=save_layerV2",
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
        },
        
        validateInput: function (element,isLegend) {
            var $element = $(element);
            var $row = $element.closest('.dl-filter-row');
            
            if(isLegend) {
                dataType = $('#dl-legendSelect option:selected').attr('data-type');
            }
            else {
                dataType = $row.find('.dl-filter-topic option:selected').attr('data-type');
            }
            
            var dtArr = {
                'string'    :/(\w+)/ig,
                'date'      :/\b\d+[-/.]\d+[-/.]\d+\b/g,
                'decimal'   :/[^\d\t\r\n]+/g,
                'boolean'   :/(true|false)/ig
            };
            
            var trimmedValue = '';
            var newClass = 'valid';
            
            switch(dataType) {
                case 'decimal':
                    if($element.val().search(/\./g) > -1) {
                        
                        var values = $element.val().trim().replace(/,/g,'').split('.');
                        var garbage = values[1].length > 0 ? values[1] : '';
                        
                        trimmedValue = values[0];
                        newClass = (trimmedValue.search( dtArr[dataType] ) < 0 && garbage.search( dtArr[dataType] ) < 0) ? 'valid' : 'error';
                        
                    } else {
                        
                        trimmedValue = $element.val().trim().replace(/,/g,'');
                        newClass = (trimmedValue.search( dtArr[dataType] ) < 0) ? 'valid' : 'error';
                        
                    }
                    break;
                    
                case 'string':
                    
                    trimmedValue = $element.val().trim();
                    newClass = trimmedValue.search( dtArr[dataType] ) > -1 ? 'valid' : 'error';
                    break;
                    
                case 'date':
                    trimmedValue = $element.val().trim();
                    newClass = (trimmedValue.search( dtArr[dataType] ) > -1 && trimmedValue.length <= 10) ? 'valid' : 'error';
                    break;
                    
                case 'boolean':
                    trimmedValue = $element.val().trim().toLowerCase();
                    newClass = (trimmedValue == 'true' || trimmedValue == 'false') ? 'valid' : 'error';
                    break;
                    
                default:
                    trimmedValue = $element.val();
                    newClass = 'error';
                    break;
            }
            
            $element.removeClass('valid').removeClass('error').addClass(newClass);
        }
        
    },

    getDataLayerSource: function(callback) {
        callback = callback || function() {};
        MA.Popup.showLoading({display:true,popupId:'MADataLayerEditor'});
        $('#dl-level').removeClass('MA2active');
        $('#dl-style').removeClass('MA2active');
        $('.next-Tooltip').removeClass('MA2active');
        $.ajax({
            url: MAData.domain + "/info/index.php?action=get_files_and_country",
            type: 'GET',
            dataType: 'JSON',
            data: {
                orgId : MAData.orgId,
                apikey: MA.APIKey
            }
        }).success(function(data) {
            MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
            if (data.success && data.data.length > 0)
            {

                var sourceHTML = '<select style="width: 300px;" id="dl-source-select" class="dl-combobox" onchange="MAData.getDataLayerLevelOfDetail()">';

                sourceHTML += '<option value="--" selected>-- Select --</option>';

                $.each(data.data, function( index, value ) {

                    sourceHTML += '<option data-name="'+value.file_name+'" value="' + value.file_id + '">'+ value.label +'</option>';

                });

                sourceHTML += '</select>';
                $('#dl-source-wrapper').html(sourceHTML);
                $('#dl-source-select').select2();
                $('#dl-source-select').next().find('input').removeClass('error');
                callback({success:true});
            }
            else
            {
                //Error! Read message property
                //console.log(data.message);
                callback({success:false});
            }
        }).error(function(err) {
            callback({success:false});
        });
    },

    getDataLayerLevelOfDetail: function(callback) {
        //reset the popup
        MAData.wizard.resetPopup(true);
        callback = callback || function() {};
        var fileId = $('#dl-source-select').val();
        $('#dl-style').removeClass('MA2active');
        $('#dl-level').removeClass('MA2active');
        $('.next-Tooltip').removeClass('MA2active');
        if(fileId == '--') {
            return;
        }
        MA.Popup.showLoading({display:true,popupId:'MADataLayerEditor'});
        $('#dl-level').addClass('MA2active');
        $.ajax({
            url: MAData.domain + "/info/index.php?action=get_levels",
            type: 'GET',
            dataType: 'JSON',
            data: {
                orgId : MAData.orgId,
                apikey: MA.APIKey,
                file_id : fileId
            }
        }).success(function(data) {
            if (data.success && data.data.length > 0)
            {
                var options = data.data;
                $('#MADataLayerEditor').data('levelData',options);
                var lodHTML = '<select style="width:300px;" id="dl-level-select" class="dl-combobox" onchange="MAData.getDataLayerStyle();">';

                if(options.length > 1) {
                    lodHTML += '<option value="--" selected>-- Select --</option>';
                }

                $.each(options, function( index, value ) {

                    lodHTML += '<option data-name="'+value.level_name+'" value="' + value.level_id + '">'+ value.label +'</option>';

                });

                lodHTML += '</select>';
                $('#dl-level-wrapper').html(lodHTML);
                $('#dl-level-select').select2();
                $('#dl-level-select').next().find('input').removeClass('error');

                //if only 1 options get the style automatically
                if(options.length == 1) {
                    //disable the select box
                    $('#dl-level-select').prop("disabled", true);

                    MAData.getDataLayerStyle();
                }
                else {

                }
                callback({success:true});
            }
            else
            {
                //Error! Read message 
                //console.log(data.message);
                callback({success:false});
            }
            MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
        }).error(function(err) {
            callback({success:false});
        });
    },

    getDataLayerStyle: function(callback) {
        callback = callback || function() {};
        var fileId = $('#dl-source-select').val();
        var levelId = $('#dl-level-select').val();
        $('#dl-style .dl-card').addClass('hidden').removeClass('selected');
        $('#dl-style').removeClass('MA2active');
        $('.next-Tooltip').removeClass('MA2active');
        if(levelId == '--') {
            return;
        }
        MA.Popup.showLoading({display:true,popupId:'MADataLayerEditor'});
        
        $.ajax({
            url: MAData.domain + "/info/index.php?action=get_styles",
            type: 'GET',
            dataType: 'JSON',
            data: {
                orgId : MAData.orgId,
                apikey: MA.APIKey,
                file_id : fileId,
                level_id : levelId
            }
        }).success(function(data) {
            if (data.success && data.data.length > 0)
            {
                var options = data.data || [];

                //show the needed cards
                for(var i = 0; i < options.length;i++) {
                    var option = options[i];
                    var styleId = option.style_id;
                    //show the card
                    $('#dl-style .dl-card[data-id="'+styleId+'"]').removeClass('hidden');

                    if(options.length == 1) {
                        //set this as active
                        $('#dl-style .dl-card[data-id="'+styleId+'"]').addClass('selected').click();
                    }
                }
                $('#dl-style').addClass('MA2active');
                callback({success:true});
            }
            else {
                callback({success:false});
            }
            MA.Popup.showLoading({display:false,popupId:'MADataLayerEditor'});
        }).error(function(err) {
            callback({success:false});
        });
        
    },

    selectDataLayerStyle: function (element) {
        var $el = $(element);
        //remove checkmarks
        $('#dl-style .dl-card').removeClass('selected');
        $el.addClass('selected');
        $('.next-Tooltip').addClass('MA2active');

        //determine what sample images to display
        var geo_type = $('#MADataLayerEditor .dl-cards .dl-card.selected').attr('data-id');
        $('#legendImagePlaceholder .legImgWrapper[data-type="'+geo_type+'"]').removeClass('hidden');

        //scroll down
        var $panel = $('#dl-rightPanel .dl-panel[data-id="dl-dataSource"]');
        var height = $panel[0].scrollHeight;
        $panel.animate({ scrollTop: height }, 1000);

        //update sample images
        $('#legendImagePlaceholder .legImgWrapper .legendImg').addClass('hidden');
        $('#legendImagePlaceholder .legImgWrapper[data-type="'+geo_type+'"] .legendImg').first().removeClass('hidden');
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
            MA.log('Legend does not yet exist for this query.');
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