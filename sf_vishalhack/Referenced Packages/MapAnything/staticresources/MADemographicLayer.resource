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


// var orgId = MASystem.MergeFields.Organization_Id;
        
// var MADemographicLayer = {
//     getMarkers: true,
    
//     domain: "https://product-api-prod.cloudbilt.com/demographicsv7",
//     //domain: "http://localhost/API2XX/demographicsv6",
//     mDomain: "https://product-api-prod.cloudbilt.com/marker",
    
//     defaultMarker: '3083d3:Marker',
    
//     markerLimit: 5000,
    
//     dmpMarkerLimit: 15000,
    
//     queryTimeout: 15000,
    
//     runningQueries: [],
    
//     t: null,
    
    
//     //Stores the temporary layer
//     StoreTempLayer: function(id,oldOptions,callback) {
//         callback = callback || function(){};
        
//         oldOptions = $.extend({
//             refresh : false,
//             isMobile : false
//         }, oldOptions || {});
        
//         var element = '';
//         var name = '';
//         var action = '';
        
//         if(NewLayerNavigationEnabled()) {
//             element = $('div#'+id);
//             name = element.find('.ftu-text.inline').first().text();
//             action = element.find('.ftu-unit-left').attr('action');
//         } else {
//             element = $('li#'+id);
//             name = element.attr('title');
//         }

//         var uid = new Date();
//         uid = uid.getTime();
        
//         var options = {
//             id: id,
//             key: '',
//             uid: uid,
//             name: 'Loading...',
//             opacity: 0.5,
//             plotMarkers: action == 'plot-data-layer-marker',
//             legend: null,
//             plottedLayer: null,
//             refresh : oldOptions.refresh || false,
//             isMobile : oldOptions.isMobile || false
//         };
                    
// 	    //build the div now
// 	    options.plottedLayer = oldOptions.plottedLayer || MADemographicLayer.BuildPlottedLayerDiv(options,oldOptions);
// 	    options.plottedLayer.find('.queryIcon').hide();
//         options.plottedLayer.find('.queryLoader').show();
	    
// 	    //Check due to old folder junk
// 	    if(NewLayerNavigationEnabled()) {
//             MALayers.moveToTab('plotted');
// 	    } else {
// 	        if(!$('#tabs-nav-plotted').hasClass('tab-open')) {
// 	            $('#tabs-nav-plotted').click();
// 	        }
// 	    }
        
//         //has not been keyed already this session
//         // if( !element.hasClass('keyed') && element.attr('key') === undefined ) {
        
//             //Store the temp data in amazon postgres using a POST
//             jQuery.ajax({ 
                
//                 url: '/apex/MATreeAJAXResources?action=get_layer_data&id=' + id, 
//                 type: 'GET', 
//                 dataType: 'JSON' 
                
//             }).done( function(res) {
//                 console.log(res);
//                 var d = new Date();
//                 var theKey = orgId + d.getTime();
                
//                 var results = JSON.parse(res.options.sma__Options__c);
//                 options.legend = results.legend;
//                 options.opacity = results.hasOwnProperty('opacity') ? results.opacity/100 : 50;
                
//                 options.name = res.options.Name || name;
                
//                 //BEGIN OLD FOLDERS FIX
//                 options.plotMarkers = results.type.indexOf('marker') > -1;
//                 options.plottedLayer.attr('plot-type', results.type);
//                 //END OLD FOLDERS FIX
                
                
//                 options.datatype = results.file_id;
                
                
                
//                 if(res.success) {
    			    
//                     //var options = res.options;
                    
//                     $.ajax({
//                         url: MADemographicLayer.domain + "/tempstor/index.php?action=store_data&key=" + theKey,
//                         type: 'POST',
//                         dataType: 'JSON',
//                         data: {
//                             jsonData : res.options.sma__Options__c
//                         }
//                     }).done( function(res2) {
                        
                        
//                         if(res2.success) {
//                             var key = res2.key;
                            
//                             element.addClass('keyed');
//                             element.attr('key', key);
                            
//                             options.key = key;
                            
//                             //also try to plot it
//                             MADemographicLayer.PlotLayer(options, function() {
//                                 options.plottedLayer.find('.queryIcon').show();
//                                 options.plottedLayer.find('.queryLoader').hide();
//                                 callback({success:true});
//                             });
//                         }
                        
//                     }).error( function(err2) {
//                         MA.log(err2.message);
//                     });
//                 }
                
//             }).error( function(err) {
//                 MA.log(err.message);
//             });
            
//         // } else {
//         //     options.key = element.attr('key');
//         //     options.legend = element.data();
//         //     MADemographicLayer.PlotLayer(options);
//         // }
//     },
    
    
//     //Calls remove layer from the dom
//     RemoveLayerFromDom: function(obj, refresh, callback) {
//         callback = callback || function(){};
//         var el = $(obj).closest('.PlottedRowUnit');
        
//         var options = {
//             id: el.attr('id'),
//             key: el.attr('key'),
//             uid: el.attr('uid'),
//             plotMarkers: el.attr('plot-type') === 'marker',
//             refresh : refresh || false
//         };

//         MADemographicLayer.RemoveLayer(options,function(res) {
//             callback({success:true});
//         });
//     },
    
    
//     //Removes the layer from the map and removes the plotted layer div
//     RemoveLayer: function(options, callback) {
//         callback = callback || function(){};
//         MA.Map.InfoBubble.hide();
//         //Get the current element.
//         var element = $('#PlottedQueriesTable').find('.PlottedRowUnit[uid="'+options.uid+'"]');
//         //Get the key for the next polygon layer.
//         var nextKey = null;
//         var ii = 0;
//         if($('.PlottedRowUnit.DataLayer[plot-type="polygon"]').length > 1) {
//             var len = $('.PlottedRowUnit.DataLayer[plot-type="polygon"]').length;
            
//             while(nextKey === null && ii < len) {
//                 var newKey = $('.PlottedRowUnit.DataLayer[plot-type="polygon"]')[ii].getAttribute('key');
                
//                 if(newKey !== options.key) {
//                     nextKey = newKey;
//                 }
                
//                 ii++;
//             }
//         }
        
//         element.addClass('unloading');
        
//         //Clears the layer
//         if (options.plotMarkers || options.isDMP) {
//             //clear the marker layer
//             var list = element.data().markers || [];
//             for(var jj = list.length-1; jj >= 0; jj--) {
                
//                 MA.Map.spiderfier.removeMarker(list[jj]);
//                 list[jj].setMap(null);
                
//             }
//             list = [];
            
//             //clear any parcel boundaries
//             var boundaries = element.data('parcelBoundaries');
//             $.each(boundaries || [],function(i,layer) {
//                 layer.find('.btn-remove').click();
//             });
                
//         } else {
            
//             //remove clicks
//             google.maps.event.clearListeners(MA.map, 'click');
            
//             //null out the layer
//             element.data().censusLayer = null;
            
//             //hide any info bubbles
//             MA.Map.InfoBubble.hide();
            
//             //actually remove the overlay
//             var overlays = MA.map.overlayMapTypes.getArray();
//     		for(var kk=overlays.length-1; kk >= 0; kk--) {
    		    
//     			if (overlays[ii].name == options.key) {
//     				MA.map.overlayMapTypes.removeAt(kk);
//     				//return false;
//     			}
    			
//     		}
            
//         }
        
//         //remove the plottedrowunit
//         if(!options.refresh) {
//             element.slideUp(400, function() {
//                 this.remove();
                
//                 if($('#PlottedQueriesTable').children().length === 0) {
//                     $('div.plotted-watermark').slideDown();
//                 }
                
//                 //if no visible area queries hide refreh button
//                 if($('#PlottedQueriesTable .visibleOnly').length === 0) {
//                     $('#visibleAreaRefeshMap').addClass('ready').removeClass('visible');
//                 }
                
//             });
//         }
        
    		
//     	MADemographicLayer.ToggleLayerClick(nextKey);
        
        
        
//         callback({success:true});
//     },
    
//     rerenderDataLayer : function ($plottedLayer,callback) {
//         callback = callback || function(){};
//         //collect data about the records that need to be processed and rendered
// 		var markerRendererBatchSize = 100;
// 		var markerRendererTimeout = 50;
// 		var markerProcessingBatchSize = MA.Map.hitTestShapeMgr.hasShapes() 
// 			? $.browser.webkit
// 				? 500
// 				: 20 
// 			: 1000;
// 		var markerProcessingTimeout = 1;
// 		var markersToRender = [];
// 		var orderedPolylineRecords = [];
// 		var recordsToProcess = [];
// 		$.each($plottedLayer.data('markers') || [], function (index, marker) {
// 			recordsToProcess.push(marker);
// 		});
		
// 		//get legend Data
// 		var legend = $plottedLayer.data('legend') || {title:'Legend',subTitle:'',row:[]};
// 		//build temp obj for totals
// 		var tempLegend = {};
// 		for(var r = 0; r <legend.rows.length; r++) {
// 		    var row = legend.rows[r];
// 		    row.rowId = row.values == '--Other--' ? '--other--' : 'row-'+r;
// 		    row.total = 0;
// 		    row.visible = 0;
// 		    tempLegend[row.rowId] = {
// 		        total : 0,
// 		        visible : 0
// 		    }
// 		}
		
// 		setTimeout(function doBatch() {
				
// 			if (recordsToProcess.length > 0)
// 			{
// 				//status update
// 				$plottedLayer.find('.status').text('Processing...' + recordsToProcess.length + ' remaining');
				
// 				var recordsProcessed = 0;
// 				while (recordsProcessed < markerProcessingBatchSize && recordsToProcess.length > 0)
// 				{
// 					recordsProcessed++;
					
// 					var record = recordsToProcess.shift();
// 					if (record.position) {
// 					    //update legend totals
// 					    var legendRow = record.data.marker.rowid.toLowerCase();
// 					    var mlegend = tempLegend[legendRow];
// 					    if(mlegend !== undefined) {
// 					        mlegend.total++;
//     					    record.isVisible = false;
//         					if (MA.Map.hitTestShapeMgr.hasShapes())
//         					{
//         						//loop through all prox objects to see if this marker falls inside or outside
//         						var isInsideProxObject = MA.Map.hitTestShapeMgr.containsLatLng(record.getPosition());
        						
//         						//determine if we should continue based on whether or not prox visibility has been inverted or this query has prox enabled
//         						if (!isInsideProxObject)
//         						{
//         							//we should not plot this marker so continue to the next one
//         							continue;
//         						}
//         					}
    
//         					//if we made it this far, then we should render this marker (still check proximity options to ensure markers aren't hidden)
//         					record.isVisible = true;
//         					mlegend.visible++;
//         					record.setMap(MA.map);
//         					markersToRender.push(record);
// 					    }
//     				}
//     			}
	    		
//     			//set a timeout to process the next batch
// 				setTimeout(doBatch, markerProcessingTimeout);
// 			}
// 			else
// 			{
// 			    $plottedLayer.find('.status').text('Data Points: ' + markersToRender.length);
// 			    //update the acutal legend obj
// 			    for(var rl = 0; rl < legend.rows.length; rl++) {
// 			        var lrow = legend.rows[rl];
// 			        var tLegInfo = tempLegend[lrow.rowId];
// 			        lrow.total = tLegInfo.total;
// 			        lrow.visible = tLegInfo.visible;
			        
// 			        if(tLegInfo.total > 0) {
			        
//     			        //update the legend rows
//     			        var $row = $plottedLayer.find('.legend-row[uid="'+lrow.rowId+'"]');
//     			        $row.find('.visiblemarkers').text(tLegInfo.visible);
//     			        $row.find('.totalmarkers').text(tLegInfo.total);
    			        
//     			        //Put this in for MAY16MAPRT-136: https://mapanything.atlassian.net/browse/MAY16MAPRT-136
//     			        //But this is not how we do it on the other layers.
//     			        //$row.find('.totalmarkers').text(markersToRender.length);
    			        
// 			        } else {
			            
// 			            var $row = $plottedLayer.find('.legend-row[uid="'+lrow.rowId+'"]');
// 			            $row.addClass('empty').hide();
			            
// 			        }
			        
// 			    }
			    
// 			    //show the show all drop down
// 			    $plottedLayer.find('.legend-moreless-checkbox').hide();
// 			    $plottedLayer.find('.legend-moreless-wrapper').show();
// 			    $plottedLayer.find('.legend-showhide').hide();
			    
// 				callback({done:true});
				
// 			}
// 		}, markerProcessingTimeout);
//     },
    
//     //Plots the layer on the map and adds the plotted layer div
//     PlotLayer: function(options,callback) {
        
//         callback = callback || function(){};
//         var theKey = options.key;
//         options.plottedLayer.attr('key', theKey);
//         var isDMP = options.datatype === 'x_dmp_data';
//         //options.plottedLayer.data('refreshOptions',options);
//         var $plottedLayer = options.plottedLayer;
//         $plottedLayer.find('.header .ftu-icon-icon').attr('type','dataLayer');
//         $plottedLayer.attr('data-type',options.datatype);
//         $plottedLayer.find('.header .ftu-icon-icon').removeClass('error');
//         $plottedLayer.find('.queryIcon').hide();
//         $plottedLayer.find('.queryLoader').show();
        
        
//         //BEGIN MA ANALYTICS
//         jQuery.ajax({
//             url: '/apex/MATreeAJAXResources?action=store_layer_analytics&track=true&subtype=Data Layer&id=' + options.id,
//             type: 'GET',
//             dataType: 'JSON',
//         }).done ( function (res) {
//             if(NewLayerNavigationEnabled()) {
//                 MALayers.loadRecent();
//             }
//         }).error ( function(err) {
//             MA.log(err);
//         });
//         //END MA ANALYTICS
        
        
//         if(isDMP) {
            
            
//             //this is where we do the dmp stuff
//             var NE = MA.map.getBounds().getNorthEast();
//             var SW = MA.map.getBounds().getSouthWest();
            
//             var CE = MA.map.getCenter();
//             var zoom = MA.map.getZoom();
            
//             var url = MADemographicLayer.domain + "/info/index.php?action=get_dmp_markers_by_key&orgid=" + orgId + "&key=" + theKey
//                      + "&nelat=" + NE.lat() + "&nelng=" + NE.lng() + "&swlat=" + SW.lat() + "&swlng=" + SW.lng() 
//                      + "&celat=" + CE.lat() + "&celng=" + CE.lng() + "&zoom=" + zoom + "&limit=" + MADemographicLayer.dmpMarkerLimit
//                      + "&callback=?&apikey=" + MA.APIKey;
//             //GET MARKERS!
//             jQuery.ajax({
//                 url: url,
//                 type: 'GET',
//                 dataType: 'JSONP',
//                 timeout: MADemographicLayer.queryTimeout,
//             }).done ( function (data) {
//                 var markerList = [];
                
                
//                 if(data.data === null || data.data === undefined || data.data === []) {
//                     MADemographicLayer.HandleError($plottedLayer, 'Please adjust your zoom level and position.');
//                 }
                
                
//     			if (data.success) {
    			    
//     			    //Add markers to the map
//     			    $.each(data.data.markers, function( index, value ) {
    			        
//     			        var color = MADemographicLayer.defaultMarker;
//     			        var icon = null;
    			        
//     			        if(value.marker.hasOwnProperty('icon')) {
    			            
//     			            if(value.marker.icon !== null) {
//         			            icon = MADemographicLayer.domain + "/images/" + value.marker.icon;
//     			            } else {
//     			                icon = MADemographicLayer.mDomain + "/marker.php?marker=" + color;
//     			            }
    			            
//     			        } else {
    			            
//     			            if( value.marker.hasOwnProperty('color') ) {
//     			                if(value.marker.color !== '' && value.marker.color !== null && value.marker.color !== undefined) {
//     			                    color = value.marker.color;
//     			                }
//     			            }
    			        
//                             icon = MADemographicLayer.mDomain + "/marker.php?marker=" + color;
    			            
//     			        }
    			        
//                         var marker = new google.maps.Marker({
//                             position: { 
//                                 lat: value.marker.markerData.lat, 
//                                 lng: value.marker.markerData.lng 
//                             },
//                             layerUID : options.plottedLayer.attr('uid'),
//                             data : value,
//                             isVisible : false,
//                             title: value.marker.label,
//                             icon: icon,
//                             zIndex : 10
//                         });
                        
                        
                        
                        
//     			        if(marker !== null) {
                        
//                             google.maps.event.addListener(marker, 'click', function(event) {
//                                 var clickOptions = {
//                                     isMobile : options.isMobile,
//                                     layerName : options.name
//                                 }
//                                 MADemographicLayer.HandleDMPClick(event, marker, theKey, clickOptions);
//                             });
                                    
//                             MA.Map.spiderfier.addMarker(marker);
                            
//                             markerList.push(marker);
                            
//     			        }
                        
//     				}); 
    				
//     				var newData = {
//         			    name: options.name,
//         			    id: options.id,
//         			    key: options.key,
//         			    markers: markerList,
//         			    censusLayer: null,
//         			    legend: data.data.legend
//         			};
        			
//         			MADemographicLayer.FillPlottedLayerDiv(options.plottedLayer, newData);
        			
//         			//render markers
//         			var renderModes = MADemographicLayer.getRenderModes($plottedLayer);
//         			MADemographicLayer.rerenderDataLayer(options.plottedLayer, {renderModes : ['Cluster']}, function(res) {
//         			    callback({success:true,msg:'finished rendering'});
//         			    //update legend with totals
        			    
//         			});
    				
//     			} 
    			
//     			else {
//     				//Error! Read message property
//     				MADemographicLayer.HandleError($plottedLayer, data.message);
//     			}
//             }).error ( function(err) {
//                 //timeout handles 404s
//                 MADemographicLayer.HandleError($plottedLayer, err.message);
//             });
            
            
//         } else {
            
            
//             //Are they markers or shapes?
//             if (options.plotMarkers) {
                
//                 var NE = MA.map.getBounds().getNorthEast();
//                 var SW = MA.map.getBounds().getSouthWest();
//                 var url = MADemographicLayer.domain + "/info/index.php?action=get_markers_by_key&key=" + theKey + "&orgid=" + orgId
//                          + "&nelat=" + NE.lat() + "&nelng=" + NE.lng() + "&swlat=" + SW.lat() + "&swlng=" + SW.lng() + "&limit=" + MADemographicLayer.markerLimit
//                          + "&callback=?&apikey=" + MA.APIKey;
//                 //GET MARKERS!
//                 jQuery.ajax({
//                     url: url,
//                     type: 'GET',
//                     dataType: 'JSONP',
//                     timeout: MADemographicLayer.queryTimeout,
//                 }).done ( function (data) {
//                     var markerList = [];
//         			if (data.success) {
//         			    //Add markers to the map
//         			    $.each(data.data.markers, function( index, value ) {
        			        
//         			        var color = MADemographicLayer.defaultMarker;
//         			        var icon = null;
        			        
//         			        if(value.marker.hasOwnProperty('icon')) {
        			            
//         			            if(value.marker.icon !== null) {
//             			            icon = MADemographicLayer.domain + "/images/" + value.marker.icon;
//         			            } else {
//         			                icon = MADemographicLayer.mDomain + "/marker.php?marker=" + color;
//         			            }
        			            
//         			        } else {
        			            
//         			            if( value.marker.hasOwnProperty('color') ) {
//         			                if(value.marker.color !== '' && value.marker.color !== null && value.marker.color !== undefined) {
//         			                    color = value.marker.color;
//         			                }
//         			            }
        			        
//                                 icon = MADemographicLayer.mDomain + "/marker.php?marker=" + color;
        			            
//         			        }
        			        
        			        
        			        
//                             var marker = new google.maps.Marker({
//                                 position: { 
//                                     lat: value.marker.markerData.lat, 
//                                     lng: value.marker.markerData.lng 
//                                 },
//                                 data : value,
//                                 layerUID : options.plottedLayer.attr('uid'),
//                                 isVisible : false,
//                                 title: value.marker.label,
//                                 icon: icon
//                             });
                            
                            
                            
                            
//         			        if(marker !== null) {
                            
//                                 google.maps.event.addListener(marker, 'click', function(event) {
//                                     var clickOptions = {
//                                         isMobile : options.isMobile,
//                                         layerName : options.name
//                                     }
//                                     MADemographicLayer.HandleClick(event, value.marker, marker, theKey, clickOptions);
//                                 });
                                    
//                                 MA.Map.spiderfier.addMarker(marker);
                                
//                                 markerList.push(marker);
                                
//         			        }
                            
//         				}); 
        				
//         				var newData = {
//             			    name: options.name,
//             			    id: options.id,
//             			    key: options.key,
//             			    markers: markerList,
//             			    censusLayer: null,
//             			    legend: data.data.legend
//             			};
            			
//             			MADemographicLayer.FillPlottedLayerDiv(options.plottedLayer, newData);
            			
//             			//render markers
//             			var renderModes = MADemographicLayer.getRenderModes($plottedLayer);
//             			MADemographicLayer.rerenderDataLayer(options.plottedLayer, {renderModes : ['Cluster']}, function(res) {
//             			    callback({success:true,msg:'finished rendering'});
//             			    //update legend with totals
            			    
//             			});
        				
//         			} else {
//         				//Error! Read message property
//         				MADemographicLayer.HandleError($plottedLayer, data.message);
//         			}
//                 }).error ( function(err) {
//                     //timeout handles 404s
//                     MADemographicLayer.HandleError($plottedLayer, err.message);
//                 });
                
//     		} else {
//                 //are we using cache?
//                 var usecache = false;
//                 var debugtiles = false;
    		    
//     		    //GET TILES!
//                 var CensusLayer = new google.maps.ImageMapType({
                    
//                 	name: theKey,
//                 	maxZoom: 18,
//                 	tileSize: new google.maps.Size(256, 256),
//                 	opacity: options.opacity,
//                 	getTileUrl: function(coord, zoom) {
//                 		return [ MADemographicLayer.domain, '/tile/index.php?x=', coord.x, '&y=', coord.y, '&z=', zoom, '&cache=', usecache, '&debug=', debugtiles, '&key=', theKey ].join('');
//                 	}
                
//                 });
                
//                 MA.map.overlayMapTypes.push(CensusLayer);
                
//                 //do a get legend by key call, don't forget to build the php for it as well
                
//     			var newData = {
//         		    name: options.name,
//     			    id: options.id,
//     			    key: options.key,
//     			    markers: null,
//                     censusLayer: CensusLayer,
//     			    legend: options.legend
//     			};
    			
//     			MADemographicLayer.FillPlottedLayerDiv(options.plottedLayer, newData);
                
//                 $plottedLayer.find('.visiblemarkers').hide();
//                 $plottedLayer.find('.of').hide();
//                 $plottedLayer.find('.totalmarkers').hide();
//                 callback({success:true,msg:'finished rendering'});
//                 //$('.demo-legend-button').show().val('Hide Legend');
                
//                 //TURN ON CLICKS!
//                 // google.maps.event.addListener(MA.map, 'click', function(event) {
//                 // 	MADemographicLayer.HandleClick(event, null, null, theKey);
//                 // });
//                 MADemographicLayer.ToggleLayerClick(theKey);
//             }
            
            
//         }
        
//         if(!options.refresh) {
//                 $plottedLayer.find('button.btn-remove').attr('onclick', 'MADemographicLayer.RemoveLayerFromDom(this);');
                
//                 $plottedLayer.on('click','.plotted-visibile-icon',function() {
//                     var $button = $(this);
//                     $plottedLayer = $button.closest('.DataLayer');
                    
//                     if($button.find('.MAIcon').hasClass('glyphicon-eye-open')) {
//                         //hide
//                         $button.find('.MAIcon').addClass('glyphicon-eye-close').removeClass('glyphicon-eye-open');
//                         if($plottedLayer.data('markers')) {
//                             var markers = $plottedLayer.data('markers') || [];
//                             var markerIndex = markers.length;
//                             while(markerIndex--) {
//                                 var marker = markers[markerIndex];
//                                 marker.setMap(null);
//                             }
//                             $plottedLayer.find('.markers').removeClass('on');
//                         }
//                         //hide shape
//                         if($plottedLayer.data('censusLayer')) {
//                             var layer = $plottedLayer.data('censusLayer');
//                             $plottedLayer.data('toggleOpac',layer.getOpacity());
//                             layer.setOpacity(0);

//                             //remove click events if selected
//                             if($plottedLayer.find('.inline.status').find('span').hasClass('ion-toggle-filled')) {
//                                 //remove click
//                                 google.maps.event.clearListeners(MA.map, 'click');
//                                 //Hide all clickability icons
//                                 $plottedLayer.find('.inline.status').find('span').removeClass('ion-toggle-filled').addClass('ion-toggle');
//                             }

//                             //select next if possible
//                             if($('.DataLayer').length > 1) {
//                                 //click the first data layer that is visible
//                                 var dataLayers = $('.DataLayer .plotted-visibile-icon .glyphicon-eye-open').closest('.DataLayer');
//                                 dataLayers.eq(0).find('.inline.status span').click();
//                             }
//                         }
                        
//                     }
                    
//                     else {
//                         //show
//                         $button.find('.MAIcon').addClass('glyphicon-eye-open').removeClass('glyphicon-eye-close');
//                         if($plottedLayer.data('markers')) {
//                             var renderModes = MADemographicLayer.getRenderModes($plottedLayer);
//                             MADemographicLayer.rerenderDataLayer($plottedLayer, {renderModes : renderModes},function(res) {
                			   
//                 			});
                            
//                             $plottedLayer.find('.markers').addClass('on');
//                         }
//                         //show shape
//                         if($plottedLayer.data('censusLayer')) {
//                             var layer = $plottedLayer.data('censusLayer');
//                             layer.setOpacity($plottedLayer.data('toggleOpac') || 0.5);
//                             //enable click if only row plotted
//                             if($('.DataLayer').length == 1) {
//                                 var key = $plottedLayer.attr('key');
//                                 MADemographicLayer.ToggleLayerClick(key);
//                             }
//                         }
//                     }
                    
//                 });
                
//                 //handle hover menu
//                 $plottedLayer.on('mouseenter','.drop-menu-wrapper',function(event) {
//                     var $button = $(this);
//                     var menuItemPos = $button.position();
//                     //get position to show menu
//                     var topPos = menuItemPos.top + 25; //+25px for button size
                    
//                     if($plottedLayer.hasClass('loading')) {
//                         return;
//                     }
                    
//                     if($button.is('.query-options')) {
//                         $plottedLayer.find('.query-menu-options').css('top',topPos);
//                         $plottedLayer.find('.plotted-menu-icon, .query-menu-options').addClass('active');
//                     }

//                     var $menu = $button.find('.drop-down-menu');
//                     var menuOff = $menu.offset();
//                     var menuHeight = $menu.height();
//                     //check the menu height and offset
//                     var totalMenu = menuOff.top + menuHeight;

//                     //get the map dimensions
//                     var $container = $('#mapcontainer');
//                     var containerOff = $container.offset();
//                     var containerHeight = $container.height();
//                     var containerTotal = containerOff.top + containerHeight;

//                     //appears offscreen
//                     if(totalMenu >= containerTotal) {
//                         //place the menu on the bottom of the container
//                         topPos = menuItemPos.top - menuHeight;
//                         $menu.css('top',topPos);
//                     }
//                 });
//                 $plottedLayer.on('mouseleave','.drop-menu-wrapper',function(event) {
//                     $('.drop-down-menu, .btn-lg').removeClass('active');
//                 });
                
//                 //handle actions
//                 $plottedLayer.on('click','.edit-query',function() {
//                     MAData.wizard.launchPopup({ layerId: options.id, plottedLayer : $plottedLayer });
//                 });
//                 $plottedLayer.on('click','.refresh-query',function() {
//                     MADemographicLayer.refreshDataLayer($plottedLayer);
//                 });
//                 $plottedLayer.on('click','.fit-query',function() {
//                     ZoomToFit({ dataLayers: [$plottedLayer] });
//                 });
                
//                 $plottedLayer.find('.markers').addClass('on');
//             }
        
//     },
    
    
//     //Handles errors on datalayers
//     HandleError: function($plottedLayer, message) {
//         $plottedLayer.removeClass('loading');
//         $plottedLayer.find('.queryLoader').hide();
//         //$plottedLayer.find('.basicinfo-name').text('Error');
//         $plottedLayer.find('.loadMask').hide();
//         $plottedLayer.find('.loading-icon').hide();
//         $plottedLayer.find('.status').text('Too many properties to plot.');
//         $plottedLayer.find('.info').text(message || 'Please zoom in and refresh this layer.');
//         //$plottedLayer.find('.header .ftu-icon-icon').addClass('error');
//         $plottedLayer.find('.queryIcon').show();
//     },
    
    
// 	//Handles clicks on the map
// 	HandleClick: function(e, markerData, marker, key,options) {
//         options = $.extend({
//             isMobile : false
//         }, options || {});
        
// 		//create a new info bubble and show loading
// 		var $tooltipContent = $('#tooltip-demographic-template').clone().attr('id', 'tooltip-content').addClass('demographics').show();
//         $tooltipContent.find('.layerName').text(options.layerName);
// 		$tooltipContent.find('.tooltip-loader').show();
		
//         //lat and lng of the click event
// 		var lat = e.latLng.lat();
// 		var lng = e.latLng.lng();
    		
// 		if(markerData === null || markerData === undefined) {
//     		$.getJSON( MADemographicLayer.domain + '/info/index.php?action=get_point_info_by_key&key=' + key + '&orgid=' + orgId + '&lat=' + lat + '&lng=' + lng + '&callback=?&apikey=' + MA.APIKey, function( data ) {
    			
    
//     			if (data.success && data.data.header.levels !== undefined)
//     			{
    			    
//         		    MA.demographicsInfoBubble = MA.Map.InfoBubble.show({
//             			position: e.latLng,
//             			minWidth: 200,
//             			content: $tooltipContent.get(0)
//             		});
    
    			    
//                     MADemographicLayer.BuildHeader(data.data.header, $tooltipContent);
//                     MADemographicLayer.BuildTabs(data.data.tabs, $tooltipContent);
                    
//                     //init tabs
//                     if(options.isMobile) {
//                         $tooltipContent.find('.tabs').navbar().find('a').each(function () {
//                             $(this).click(function () {
//                                 $tooltipContent.find('.navbar a').removeClass('ui-btn-active').filter(this).addClass('ui-btn-active');
//                                 $tooltipContent.find('.pane').css({ height: '0', padding: '0' });
//                                 $tooltipContent.find($(this).attr('data-pane')).css({ height: 'auto', padding: '10px' });
//                                 MA.Map.InfoBubble.adjust();
//                             });
//                         });
//                         $tooltipContent.find('.navbar a').first().click()
//                     }
//                     else {
//         				$tooltipContent.find('.tabs').tabs({
//         					activate: function( event, ui ) {
//         						setTimeout(function () {
//         							try { MA.demographicsInfoBubble.padding_changed(); MA.demographicsInfoBubble.panToView(); } catch (err) {}
//         						}, 500);
//         					}
//         				});
//                     }
    
//     				//hide loading and adjust pan
//     				$tooltipContent.find('.tooltip-loader').hide();
//     				MA.demographicsInfoBubble.padding_changed();
//     				MA.demographicsInfoBubble.panToView();
//     			}
//     			else
//     			{
//     				MA.Map.InfoBubble.hide();
//     			}
//     		});
    		
// 		} else {
		    
//             MA.demographicsInfoBubble = MA.Map.InfoBubble.show({
//     			position: e.latLng,
//     			minWidth: 500,
//     			content: $tooltipContent.get(0),
//     			anchor: marker,
//     			markerData: markerData
//     		});
			    
//             MADemographicLayer.BuildHeader(markerData.header, $tooltipContent);
            
            
//             MADemographicLayer.BuildTabs(markerData.tabs, $tooltipContent);
            
//             if(marker) {
//                 var tabs = $tooltipContent.find('#madata-tabs');
//                 var tabURL = options.isMobile == false ? "#tab-buttonActions" : "#" ;
//                 tabs.find('ul').append('<li><a data-pane="#tab-buttonActions" href="'+tabURL+'">Actions</a></li>');
//                 var $dataHTML = $('<div id="tab-buttonActions" class="layout-tooltip pane"></div>');
                
//                 var dlLayout = userSettings.ButtonSetSettings.dataLayerLayout || JSON.parse('[{"Label":"Actions","Columns":[[{"Label":"Add to Trip","Type":"Standard Action"},{"Label":"Remove Marker","Type":"Standard Action"}],[{"Label":"Set Proximity Center","Type":"Standard Action"},{"Label":"Street View","Type":"Standard Action"}],[{"Label":"Create Record","Type":"Standard Action"},{"Label":"Plot Parcel","Type":"Standard Action"}]]}]');
                
//                 $dataHTML.html(MAActionFramework.buildLayoutFromContents(dlLayout, {
// 						markerType: 'DataLayer'
// 					})
// 				);
				
// 				$dataHTML.find('.actionbutton[data-action="Plot Parcel"]').remove();
				
				
// 				//handle clicking an action button
//                 $dataHTML.find('.actionbutton').click(function (e) {
//                 	var $button = $(this);
//                 	var frameworkAction = $button.attr('data-type') == 'Custom Action'
//     					? MAActionFramework.customActions[$button.attr('data-action')] || null
//     					: MAActionFramework.standardActions[$button.attr('data-action')] || null;
                	
//                 	if (frameworkAction) {
//           				switch (frameworkAction.Action)
//           				{
//           					case 'Iframe':
           					
//           						/*//get a component index from the action framework to make this tab unique and build the iframe url 
//           						var componentIndex = MAActionFramework.componentIndex++;
//           						var iframeURL = frameworkAction.ActionValue 
//           							+ (frameworkAction.ActionValue.indexOf('?') == -1 ? '?noparams' : '')
//           							+ '&Button=' + encodeURIComponent(frameworkAction.Label)
//           							+ '&RecordId=' + record.record.Id;
           						
//           						//build the new tab and the corresponding pane
//           						var $newTab = $("<li id='CustomTab-"+componentIndex+"'><a href='#pane-customaction-"+componentIndex+"'>"+frameworkAction.Label+"</a> <span class='ui-icon ui-icon-close'>Remove Tab</span></li>");
//           						var $newPane = $("<div id='pane-customaction-"+componentIndex+"'><iframe src='"+iframeURL+"' style='width: 100%; height: 100%;'></iframe></div>");
           						
//           						//append the tab and pane to the tooltip tabs and refresh
//           						$('#tooltip-content').find('.ui-tabs-nav').append($newTab).closest('.tabs').append($newPane).tabs('refresh').find('#CustomTab-'+componentIndex+' a').click();
           						
//           						//handle clicking the close button for this new tab
//           						$newTab.css({'width': 'auto', 'padding-right': '5px'}).find('.ui-icon-close').css({'cursor': 'pointer', 'position': 'absolute', 'right': '0'}).click(function () {
//           							if ($newTab.is('.ui-tabs-active')) {
//           								$('#tooltip-content').find('.ui-tabs-nav > li:first-child a').click();
//           							}
           							
//           							$newTab.remove();
//           							$newPane.remove();
//           						});*/
//           						break;
           						
//           					case 'NewWindow':
//           					  /*var options = {
//                                 recString : ''
//                               };
//                               if(frameworkAction.ActionValue.indexOf('{records}') >= 0) {
//                                 options.records = true;
//                               }
            
//                               var newURL = frameworkAction.ActionValue 
//                                   + (frameworkAction.ActionValue.indexOf('?') == -1 ? '?noparams' : '')
//                                   + '&Button=' + encodeURIComponent(frameworkAction.Label)
//                                   + '&RecordId=' + record.record.Id;
//                               if(frameworkAction.Options.method == 'GET') {
//                                 if(frameworkAction.Options.addRecords) {
//                      						 newURL += '&'+frameworkAction.Options.paramName+'=' + record.record.Id;
//                                 }
//                                 window.open(newURL);
//                                 break;
//                               }
//                               else {
            
//                                 var postData = {};
            
//                                 if(frameworkAction.Options.addRecords) {
//                                   postData[frameworkAction.Options.paramName] = record.record.Id;
//                                 }
            
//                                 openNewWindow('POST', newURL, postData, '_blank');
//                                 break;
//                               }*/break;
           						
//           					case 'Javascript':
//                                 var layerObj = {};
//                                 layerObj[marker.layerUID || 'dlClick'] = [marker];
//                                 frameworkAction.ActionValue.call(this, {
//                                     button: $button,
//                                     dataLayers: layerObj,
//                                     mode : MA.IsMobile == true ? 'Mobile' : 'Desktop'
//                                 });
//     		            	break;
                	
//                 			default:
//                 			break;
//           				}
//                 	}
    
//                 	//stop the click from getting to the map
//                     e.stopPropagation();
//                 });
                
//                 tabs.append($dataHTML);
//             }
            
//             //MADemographicLayer.test = $tooltipContent.closest('div');
            
//             //init tabs
//             if(options.isMobile) {
//                 $tooltipContent.find('.tabs').navbar().find('a').each(function () {
//                     $(this).click(function () {
//                         $tooltipContent.find('.navbar a').removeClass('ui-btn-active').filter(this).addClass('ui-btn-active');
//                         $tooltipContent.find('.pane').css({ height: '0', padding: '0' });
//                         $tooltipContent.find($(this).attr('data-pane')).css({ height: 'auto', padding: '10px' });
//                         MA.Map.InfoBubble.adjust();
//                     });
//                 });
//                 $tooltipContent.find('.navbar a').first().click()
//             }
//             else {
//     			$tooltipContent.find('.tabs').tabs({
//     				activate: function( event, ui ) {
//     					setTimeout(function () {
//     						try {
//     						    var $bubble = $(MA.demographicsInfoBubble.content);
//     						    var height = $bubble.height();
//     						    var oldHeight = parseFloat($bubble.attr('data-height')) || 0;
//     						    $bubble.attr('data-height',height);
//     						    MA.demographicsInfoBubble.padding_changed(); 
    						    
//     						    if(oldHeight < height) {
//     						        MA.demographicsInfoBubble.panToView();
//     						    }
    						    
//     						} catch (err) {}
//     					}, 200);
//     				}
//     			});
//             }

// 			//hide loading and adjust pan
// 			$tooltipContent.find('.tooltip-loader').hide();
// 			MA.demographicsInfoBubble.padding_changed();
// 			MA.demographicsInfoBubble.panToView();
// 		}
// 	},

//     removeDataLayerMarker : function (options) {
        
//         options = $.extend({
//             markers : [],
//         }, options || {});

//         if(!options.layer) {
//             return;
//         }

//         //loop over markers and remove those that match
//         var dlMarkers = options.layer.data('markers') || [];
//         var mIndex = dlMarkers.length;
//         var searchIndex = options.markers.length;
//         var legendInfo = {
//             layer : options.layer,
//             rows : {}
//         };
//         while(mIndex--) {
//             var marker = dlMarkers[mIndex];
//             var markerUID = marker.data.marker.uid;
//             if($.inArray( markerUID, options.markers )>=0){
//                 //update legend
//                 var legendId = marker.data.marker.rowid;
//                 if(legendInfo.rows[legendId]) {
//                     if(marker.isVisible) {
//                         legendInfo.rows[legendId].visibleTotal++;
//                     }
//                     legendInfo.rows[legendId].total++;
//                 }
//                 else {
//                     legendInfo.rows[legendId] = {
//                         total : 0,
//                         visibleTotal : 0
//                     };
//                     if(marker.isVisible) {
//                         legendInfo.rows[legendId].visibleTotal++;
//                     }
//                     legendInfo.rows[legendId].total++;
//                 }

//                 marker.setMap(null);
//                 marker.isVisible = false;
//                 //delete record
//                 dlMarkers.splice(mIndex, 1);
//                 searchIndex--;
//             }

//             if(searchIndex == 0) {
//                 //exit loop
//                 MADemographicLayer.updateDataLayerInfo(legendInfo);
//                 break;
//             }
//         }
//     },

//     updateDataLayerInfo: function (options) {
//         var $plottedLayer = options.layer;
//         var legendData = $plottedLayer.data('legend');
//         legendData = legendData.rows || [];
//         //loop over rows for dl and update
//         for(legendId in options.rows) {
//             var rowInfo = options.rows[legendId];
//             var $legendRow = $plottedLayer.find('.legend-row[uid="'+legendId+'"]');
//             var visible = parseFloat($legendRow.find('.visiblemarkers').text());
//             var total = parseFloat($legendRow.find('.totalmarkers').text());
//             $legendRow.find('.visiblemarkers').text(visible-rowInfo.visibleTotal);
//             $legendRow.find('.totalmarkers').text(total-rowInfo.total);
//             $plottedLayer.find('.plottinginfo-wrapper .status').text(MASystem.Labels.MA_Data_Points +': ' + (total - rowInfo.total));
//         }
//     },
	
// 	//Handles DMP clicks on the map
// 	HandleDMPClick: function(e, marker, key, options) {
//         options = $.extend({
//             isMobile : false
//         }, options || {});

// 	    MADemographicLayer.testMarker = marker;
        
// 		//create a new info bubble and show loading
// 		var $tooltipContent = $('#tooltip-demographic-template').clone().attr('id', 'tooltip-content').addClass('demographics').show();
// 		$tooltipContent.find('.layerName').text(options.layerName);
// 		MADemographicLayer.t = $tooltipContent;
		
// 		MA.demographicsInfoBubble = MA.Map.InfoBubble.show({
// 			position: marker.getPosition(),
// 			minWidth: 200,
// 			content: $tooltipContent.get(0),
// 			anchor: marker
// 		});

// 		$tooltipContent.find('.tooltip-loader').show();
		
//         //lat and lng of the click event
// 		var lat = marker.data.marker.markerData.lat;
// 		var lng = marker.data.marker.markerData.lng;
    		

// 		$.getJSON( MADemographicLayer.domain + '/info/index.php?action=get_dmp_point_info_by_key&key=' + key + '&orgid=' + orgId + '&lat=' + lat + '&lng=' + lng + '&table=' + marker.data.marker.table + '&property_id=' + marker.data.marker.uid + '&callback=?&apikey=' + MA.APIKey, function( data ) {

// 			if (data.success && data.data.header.levels !== undefined)
// 			{
            
//                 MADemographicLayer.BuildHeader(data.data.header, $tooltipContent, options);
//                 MADemographicLayer.BuildTabs(data.data.tabs, $tooltipContent, options);
                
                
//                 var tabs = $tooltipContent.find('#madata-tabs');
//                 var tabURL = options.isMobile == false ? "#tab-buttonActions" : "#" ;
//                 tabs.find('ul').append('<li><a data-pane="#tab-buttonActions" href="'+tabURL+'">Actions</a></li>');
//                 var $dataHTML = $('<div id="tab-buttonActions" class="layout-tooltip pane"></div>');
                
//                 var dlLayout = userSettings.ButtonSetSettings.dataLayerLayout || JSON.parse('[{"Label":"Actions","Columns":[[{"Label":"Add to Trip","Type":"Standard Action"},{"Label":"Remove Marker","Type":"Standard Action"}],[{"Label":"Set Proximity Center","Type":"Standard Action"},{"Label":"Street View","Type":"Standard Action"}],[{"Label":"Create Record","Type":"Standard Action"},{"Label":"Plot Parcel","Type":"Standard Action"}]]}]');
                
//                 $dataHTML.html(MAActionFramework.buildLayoutFromContents(dlLayout, {
// 						markerType: 'DataLayer'
// 					})
// 				);
				
				
// 				//handle clicking an action button
//                 $dataHTML.find('.actionbutton').click(function (e) {
//                 	var $button = $(this);
//                 	var frameworkAction = $button.attr('data-type') == 'Custom Action'
//     					? MAActionFramework.customActions[$button.attr('data-action')] || null
//     					: MAActionFramework.standardActions[$button.attr('data-action')] || null;
                	
//                 	if (frameworkAction) {
//           				switch (frameworkAction.Action)
//           				{
//           					case 'Iframe':
           					
//           						/*//get a component index from the action framework to make this tab unique and build the iframe url 
//           						var componentIndex = MAActionFramework.componentIndex++;
//           						var iframeURL = frameworkAction.ActionValue 
//           							+ (frameworkAction.ActionValue.indexOf('?') == -1 ? '?noparams' : '')
//           							+ '&Button=' + encodeURIComponent(frameworkAction.Label)
//           							+ '&RecordId=' + record.record.Id;
           						
//           						//build the new tab and the corresponding pane
//           						var $newTab = $("<li id='CustomTab-"+componentIndex+"'><a href='#pane-customaction-"+componentIndex+"'>"+frameworkAction.Label+"</a> <span class='ui-icon ui-icon-close'>Remove Tab</span></li>");
//           						var $newPane = $("<div id='pane-customaction-"+componentIndex+"'><iframe src='"+iframeURL+"' style='width: 100%; height: 100%;'></iframe></div>");
           						
//           						//append the tab and pane to the tooltip tabs and refresh
//           						$('#tooltip-content').find('.ui-tabs-nav').append($newTab).closest('.tabs').append($newPane).tabs('refresh').find('#CustomTab-'+componentIndex+' a').click();
           						
//           						//handle clicking the close button for this new tab
//           						$newTab.css({'width': 'auto', 'padding-right': '5px'}).find('.ui-icon-close').css({'cursor': 'pointer', 'position': 'absolute', 'right': '0'}).click(function () {
//           							if ($newTab.is('.ui-tabs-active')) {
//           								$('#tooltip-content').find('.ui-tabs-nav > li:first-child a').click();
//           							}
           							
//           							$newTab.remove();
//           							$newPane.remove();
//           						});*/
//           						break;
           						
//           					case 'NewWindow':
//           					  var options = {
//                                 recString : ''
//                               };
//                               if(frameworkAction.ActionValue.indexOf('{records}') >= 0) {
//                                 options.records = true;
//                               }
            
//                               var newURL = frameworkAction.ActionValue 
//                                   + (frameworkAction.ActionValue.indexOf('?') == -1 ? '?noparams' : '')
//                                   + '&Button=' + encodeURIComponent(frameworkAction.Label)
//                                   + '&RecordId=' + record.record.Id;
//                               if(frameworkAction.Options.method == 'GET') {
//                                 if(frameworkAction.Options.addRecords) {
//                      						 newURL += '&'+frameworkAction.Options.paramName+'=' + record.record.Id;
//                                 }
//                                 window.open(newURL);
//                                 break;
//                               }
//                               else {
            
//                                 var postData = {};
            
//                                 if(frameworkAction.Options.addRecords) {
//                                   postData[frameworkAction.Options.paramName] = record.record.Id;
//                                 }
            
//                                 openNewWindow('POST', newURL, postData, '_blank');
//                                 break;
//                               }
           						
//           					case 'Javascript':
//                                 var layerObj = {};
//                                 layerObj[marker.layerUID || 'dlClick'] = [marker];
//                                 frameworkAction.ActionValue.call(this, {
//                                     button: $button,
//                                     dataLayers: layerObj,
//                                     mode : MA.IsMobile == true ? 'Mobile' : 'Desktop'
//                                 });
//     		            	break;
                	
//                 			default:
//                 			break;
//           				}
//                 	}
    
//                 	//stop the click from getting to the map
//                     e.stopPropagation();
//                 });
                
//                 tabs.append($dataHTML);
                
//                 //init tabs
//                 if(options.isMobile) {
//                     $tooltipContent.find('.tabs').navbar().find('a').each(function () {
//                         $(this).click(function () {
//                             $tooltipContent.find('.navbar a').removeClass('ui-btn-active').filter(this).addClass('ui-btn-active');
//                             $tooltipContent.find('.pane').css({ height: '0', padding: '0' });
//                             $tooltipContent.find($(this).attr('data-pane')).css({ height: 'auto', padding: '10px' });
//                             MA.Map.InfoBubble.adjust();
//                         });
//                     });
//                     $tooltipContent.find('.navbar a').first().click()
//                 }
//                 else {
//                     $tooltipContent.find('.tabs').tabs({
//                         activate: function( event, ui ) {
//                             MA.demographicsInfoBubble.padding_changed();
//                             setTimeout(function () {
//                                 try { MA.demographicsInfoBubble.padding_changed(); MA.demographicsInfoBubble.panToView(); } catch (err) {}
//                             }, 100);
//                         }
//                     });
//                 }
				
				
// 				//disable the parcel button if there's no parcel data
// 				if(marker.data.marker.parcel === '') {
// 				    $('#tab-buttonActions .actionbutton[data-action="Plot Parcel"]').off('click');
// 				    $('#tab-buttonActions .actionbutton[data-action="Plot Parcel"]').addClass('disabled-button');
// 				}
				

// 				//hide loading and adjust pan
// 				$tooltipContent.find('.tooltip-loader').hide();
// 				MA.demographicsInfoBubble.padding_changed();
// 				MA.demographicsInfoBubble.panToView();
// 			}
// 			else
// 			{
// 				MA.Map.InfoBubble.hide();
// 			}
// 		});
    		

// 	},
	
	
// 	//Builds and appends the HTML for the info bubble header
// 	BuildHeader: function(headerData, $element) {
// 	    var newHTML = '';
	    
// 	    //add in the single topic-specific header
// 	    newHTML += '<tr><td style="font-weight:bold; font-size: 12px; ">' + headerData.label + ':</td><td style="font-size: 12px;">' + headerData.value + '</td></tr>';
	    
// 	    //handle all of the levels: state, county, etc.
// 	    var len = headerData.levels.length;
// 	    for(var ii=0; ii<len; ii++) {
// 	        newHTML += '<tr><td style="font-weight:bold; font-size: 12px; ">' + headerData.levels[ii].label + ':</td><td style="font-size: 12px;">' + headerData.levels[ii].value + '</td></tr>';
// 	    }
	    
// 	    $element.find( '.tooltip-table' ).append( newHTML );
// 	},
	
	
// 	//Builds and appends the tab data to the proper tabs
// 	BuildTabs: function(tabData, $element,options) {
//         options = $.extend({
//             isMobile : false
//         }, options || {});

//         var isMobile = options.isMobile;
// 	    var tabs = $element.find('#madata-tabs');
	    
// 	    //handle all of the tabs.
// 	    var len = tabData.length;
//         for(var ii=0; ii<len; ii++) {
//             if(tabData[ii].values.length > 0) {
//                 var hrefURL = isMobile == false ? "#tab-" + tabData[ii].id : "#" ;
//                 var dataPaneInfo = isMobile == false ? '' : tabData[ii].id;
//     	        tabs.find('ul').append('<li><a data-pane="#tab-' + tabData[ii].id+'" href="' + hrefURL + '">' + tabData[ii].name + '</a></li>');
//     	        var dataHTML = '<div class="pane" id="tab-' + tabData[ii].id + '"><table id="'+ tabData[ii].id + '-table">';
    	        
//     	        var valCount = tabData[ii].values.length;
//     	        for(var jj=0; jj<valCount; jj++) {
//     	            dataHTML += '<tr><td style="font-weight:bold; font-size: 12px; padding-right:10px">' + tabData[ii].values[jj].label + ':</td><td style="float:left; font-size: 12px;">' + tabData[ii].values[jj].formatted_value + '</td></tr>';
//     	        }
    	        
//     	        dataHTML += '</table></div>';
    	        
//     	        tabs.append(dataHTML);
//             }
// 	    }
// 	},
	
	
// 	//Builds and appends the HTML for the info bubble header
// 	BuildMobileHeader: function(headerData, $element) {
// 	    var newHTML = [];
	    
// 	    //add in the single topic-specific header
// 	    newHTML.push(headerData.label + ': ' + headerData.value);
	    
// 	    //handle all of the levels: state, county, etc.
// 	    var len = headerData.levels.length;
// 	    for(var ii=0; ii<len; ii++) {
// 	        newHTML.push(headerData.levels[ii].label + ': ' + headerData.levels[ii].value);
// 	    }
	    
// 	    $element.find( '.name' ).html( newHTML.join(' <br /> ') );
// 	},
	
	
// 	//Builds and appends the tab data to the proper tabs
// 	BuildMobileTabs: function(tabData, $element) {
// 	    var tabs = $element.find( '.navbar' );
	    
// 	    //handle all of the tabs.
// 	    var len = tabData.length;
//         for(var ii=0; ii<len; ii++) {
//             if(tabData[ii].values.length > 0) {
//     	        tabs.find('ul').append('<li><a href="#tab-' + tabData[ii].id + '">' + tabData[ii].name + '</a></li>');
//     	        var dataHTML = '<div id="tab-' + tabData[ii].id + '"><table id="'+ tabData[ii].id + '-table">';
    	        
//     	        var valCount = tabData[ii].values.length;
//     	        for(var jj=0; jj<valCount; jj++) {
//     	            dataHTML += '<tr><td style="font-weight:bold; font-size: 12px; padding-right:10px">' + tabData[ii].values[jj].label + ':</td><td style="float:left; font-size: 12px;">' + tabData[ii].values[jj].formatted_value + '</td></tr>';
//     	        }
    	        
//     	        dataHTML += '</table></div>';
    	        
//     	        $element.append(dataHTML);
//             }
// 	    }
// 	},
	
	
// 	//Builds the actions tab
// 	BuildActionsTab: function(actionData, $element) {
// 	    var tabs = $element.find('#madata-tabs');
	    
// 	    //handle all of the tabs.
// 	    var len = actionData.length;
//         tabs.find('ul').append('<li><a href="#tab-buttonActions">Actions</a></li>');
//         var $dataHTML = $('<div id="tab-buttonActions" class="layout-tooltip"></div>');
        
//         $dataHTML.html(MAActionFramework.buildLayoutFromContents(userSettings.ButtonSetSettings.dataLayerLayout, {
// 				markerType: 'DataLayer'
// 			})
// 		);
		
// 		//handle clicking an action button
//         $dataHTML.find('.actionbutton').click(function (e) {
//         	var $button = $(this);
//         	var frameworkAction = $button.attr('data-type') == 'Custom Action'
// 				? MAActionFramework.customActions[$button.attr('data-action')] || null
// 				: MAActionFramework.standardActions[$button.attr('data-action')] || null;
        	
//         	if (frameworkAction) {
//   				switch (frameworkAction.Action)
//   				{
//   					case 'Iframe':
   					
//   						//get a component index from the action framework to make this tab unique and build the iframe url 
//   						var componentIndex = MAActionFramework.componentIndex++;
//   						var iframeURL = frameworkAction.ActionValue 
//   							+ (frameworkAction.ActionValue.indexOf('?') == -1 ? '?noparams' : '')
//   							+ '&Button=' + encodeURIComponent(frameworkAction.Label)
//   							+ '&RecordId=' + record.record.Id;
   						
//   						//build the new tab and the corresponding pane
//   						var $newTab = $("<li id='CustomTab-"+componentIndex+"'><a href='#pane-customaction-"+componentIndex+"'>"+frameworkAction.Label+"</a> <span class='ui-icon ui-icon-close'>Remove Tab</span></li>");
//   						var $newPane = $("<div id='pane-customaction-"+componentIndex+"'><iframe src='"+iframeURL+"' style='width: 100%; height: 100%;'></iframe></div>");
   						
//   						//append the tab and pane to the tooltip tabs and refresh
//   						$('#tooltip-content').find('.ui-tabs-nav').append($newTab).closest('.tabs').append($newPane).tabs('refresh').find('#CustomTab-'+componentIndex+' a').click();
   						
//   						//handle clicking the close button for this new tab
//   						$newTab.css({'width': 'auto', 'padding-right': '5px'}).find('.ui-icon-close').css({'cursor': 'pointer', 'position': 'absolute', 'right': '0'}).click(function () {
//   							if ($newTab.is('.ui-tabs-active')) {
//   								$('#tooltip-content').find('.ui-tabs-nav > li:first-child a').click();
//   							}
   							
//   							$newTab.remove();
//   							$newPane.remove();
//   						});
//   						break;
   						
//   					case 'NewWindow':
//   					  var options = {
//                         recString : ''
//                       };
//                       if(frameworkAction.ActionValue.indexOf('{records}') >= 0) {
//                         options.records = true;
//                       }
    
//                       var newURL = frameworkAction.ActionValue 
//                           + (frameworkAction.ActionValue.indexOf('?') == -1 ? '?noparams' : '')
//                           + '&Button=' + encodeURIComponent(frameworkAction.Label)
//                           + '&RecordId=' + record.record.Id;
//                       if(frameworkAction.Options.method == 'GET') {
//                         if(frameworkAction.Options.addRecords) {
//              						 newURL += '&'+frameworkAction.Options.paramName+'=' + record.record.Id;
//                         }
//                         window.open(newURL);
//                         break;
//                       }
//                       else {
    
//                         var postData = {};
    
//                         if(frameworkAction.Options.addRecords) {
//                           postData[frameworkAction.Options.paramName] = record.record.Id;
//                         }
    
//                         openNewWindow('POST', newURL, postData, '_blank');
//                         break;
//                       }
   						
//   					case 'Javascript':
//   						frameworkAction.ActionValue.call(this, {
//   							button: $button,
// 		            		dataLayers: [MA.demographicsInfoBubble.markerData.marker]
// 		            	});
// 	            	break;
        	
//         			default:
//         			break;
//   				}
//         	}

//         	//stop the click from getting to the map
//             e.stopPropagation();
//         });
		
//         tabs.append($dataHTML);
// 	},
	
	
// 	//Builds the initial plotted layer div in the plotted tab
// 	BuildPlottedLayerDiv: function(options,hoverInfo) {
//         //hide any info bubbles
//         MA.Map.InfoBubble.hide();
//         //hide that watermark
//         $('div.plotted-watermark').hide();
        
// 	    var $plottedLayer = $('#templates').find('.PlottedRowUnit-DataLayer').clone().addClass('DataLayer loading PlottedRowUnit').removeClass('PlottedRowUnit-DataLayer');
// 	    $.extend($plottedLayer.data(), hoverInfo);
// 	    $plottedLayer.attr('data-id', options.id);
// 	    $plottedLayer.attr('key', options.key);
// 	    $plottedLayer.attr('uid', options.uid);
// 	    $plottedLayer.attr('plot-type', options.plotMarkers ? 'marker' : 'polygon');
	    
// 	    if(options.plotMarkers) {
// 	        $plottedLayer.addClass('visibleOnly');
// 	    }
	    
	    
// 	    $plottedLayer.find('.basicinfo-name').html(options.name);
// 	    $plottedLayer.find('.basicinfo-baseobjectname').html('Data Layer');
	    
//         $plottedLayer.find('.loadMask').show();
//         $plottedLayer.find('.loading-icon').show();
        
//         $('#PlottedQueriesTable').prepend($plottedLayer);

//         if(options.isMobile) {
//             $plottedLayer.find('.renderButtons').remove();
//             PlottedQueries_Show()
//         }

//         return $plottedLayer;
// 	},
	
// 	refreshDataLayer:function($plottedLayer,dlOptions,callback) {
//         dlOptions = $.extend({
//             isMobile : false
//         }, dlOptions || {});

// 	    callback = callback || function(){}
// 	    //unrender the data layer
// 	    $plottedLayer.addClass('loading');
// 	    $plottedLayer.find('.queryIcon').hide();
//         $plottedLayer.find('.loading-icon').show();
// 	    MADemographicLayer.RemoveLayerFromDom($plottedLayer,true,function() {
// 	        //refresh the query
// 	        $plottedLayer.removeClass('unloading');
// 	        var options = $plottedLayer.data();
// 	        var oldOptions = {
// 	            refresh: true,
// 	            plottedLayer : $plottedLayer,
//                 isMobile : dlOptions.isMobile
// 	        }

// 	        MADemographicLayer.StoreTempLayer(options.id,oldOptions,function() {
// 	             callback({success:true});
// 	        });
	       
// 	    });
// 	},
	
// 	//Fills the plotted layer div with the necessary data
// 	FillPlottedLayerDiv: function(layer, data) {
// 	    var $plottedLayer = layer.removeClass('loading');
// 	    $plottedLayer.find('.glyphicon-eye-close').addClass('glyphicon-eye-open').removeClass('glyphicon-eye-close');
	    
// 	    $plottedLayer.find('.basicinfo-name').html(data.name);
// 	    $plottedLayer.data(data);
	    
// 	    if(data.markers !== null) {
	        
//     	    var markerCount = data.markers.length;
//     	    $plottedLayer.find('.plottinginfo-wrapper .inline.status').html('Data Points: ' + markerCount);
//     	    $plottedLayer.find('.plottinginfo-wrapper .info').html(markerCount + ' markers created, ' + markerCount + ' visible.');
    	    
// 	    } else if(data.censusLayer !== null) {
// 	        //Hide the zoom to fit
// 	        $plottedLayer.find('.drop-menu-item.item-selectable.fit-query').hide();
	        
// 	        //do census layer stuff
// 	        var stat = $plottedLayer.find('.plottinginfo-wrapper .inline.status');
// 	        stat.html('Data Type: Polygon <span class="MAIcon ion-toggle" onclick="MADemographicLayer.ToggleLayerClickFromDOM(this);" style="color: black; font-size: 16px; float: right;"></span>');
// 	        stat[0].style.width = "95.5%";
	        
// 	    }
	    
	    
	    
// 	    if(data.legend.hasOwnProperty('rows')) {
	        
// 	        var info = '';
	        
// 	        if(data.legend.title !== '') {
// 	            info += data.legend.title;
	            
// 	            if(data.legend.subTitle !== '') {
// 	                info += ': ' + data.legend.subTitle;
// 	            }
// 	        }
	        
// 	        $plottedLayer.find('.plottinginfo-wrapper .info').html(info);
	        
// 	        if(data.legend.rows.length > 0) {
// 	            //do legend stuff here
//                 var tableHTML = MADemographicLayer.BuildLegend(data.legend.rows);
	            
// 	            $plottedLayer.find('table.legend').html(tableHTML).show();
// 	            $plottedLayer.find('div.legend-showhide').show();
// 	        } else {
//                 //do legend stuff here
//                 var otherRow = {
//                     color: MADemographicLayer.defaultMarker,
//                     operator: 'equals',
//                     topic_id: '--fake--',
//                     values: '--Other--'
//                 }
                
//                 var fakeLegend = [ otherRow ];
                
//                 var tableHTML = MADemographicLayer.BuildLegend(fakeLegend);
                
//                 $plottedLayer.find('table.legend').html(tableHTML).show();
//                 $plottedLayer.find('div.legend-showhide').show();
//     	    }
// 	    } 
	    
//         $plottedLayer.find('.loadMask').hide();
//         $plottedLayer.find('.loading-icon').hide();
// 	},
	
	
// 	//Creates the legend with the given legend data
// 	BuildLegend: function(legendData) {
	    
// 	    var isPolygon = false;
	    
// 	    var rowHTML = '';
	    
// 		for(var ii=0, len=legendData.length; ii<len; ii++) {
		    
// 		    var rowid = legendData[ii].values === '--Other--' ? '--other--' : 'row-'+ii;
		    
// 		    rowHTML += '<tr class="legend-row" uid="'+rowid+'" ::ONCLICK::>';
		    
// 		    rowHTML += '<td class="legend-visibility-toggle legend-checkbox-wrapper">::CHECKBOX::</td>';
		    
// 		    rowHTML += '<td class="legend-text">'+MADemographicLayer.BuildLegendRowText(legendData[ii])+'</td>';
// 		    rowHTML += '<td class="visiblemarkers">0</td>';
// 		    rowHTML += '<td class="of">of</td>';
// 		    rowHTML += '<td class="totalmarkers">0</td>';
		    
		    
// 		    //is this an icon or a marker?
// 		    if(legendData[ii].hasOwnProperty('icon')) {
		        
// 		        rowHTML += '<td class="legend-color" data-color="#'+color+'"><img src="' + MADemographicLayer.mDomain + "/images/" + legendData[ii].icon + '" height="16px"></td>';
		        
// 		    } else {
		        
// 		        //we know it has a color now, is it a marker or polygon?
//     		    if(legendData[ii].color.indexOf(':') > -1) {
//     		        color = legendData[ii].color.split(':')[0];
//     		        rowHTML += '<td class="legend-color" data-color="#'+color+'"><img src="' + MADemographicLayer.mDomain + "/marker.php?marker=" + legendData[ii].color + '" height="16px"></td>';
//     		    } else {
//     		        isPolygon = true;
//     		        rowHTML += '<td class="legend-color" data-color="#'+legendData[ii].color+'"><span class="MAIcon ion-stop" style="color: #'+legendData[ii].color+'; font-size: 16px;"></span></td>';
//     		    }
    		    
// 		    }
		    
// 		    rowHTML += '</tr>';
// 		}
		
// 		if(isPolygon) {
// 		    rowHTML = rowHTML.replace(/::ONCLICK::/g, '').replace(/::CHECKBOX::/g, '<span class="MAIcon dataLayerCheckbox ion-checkmark-round"></span>');
// 		} else {
// 		    rowHTML = rowHTML.replace(/::ONCLICK::/g, 'onclick="MADemographicLayer.ToggleMarkerRow(this);"').replace(/::CHECKBOX::/g, '<span class="MAIcon dataLayerCheckbox ion-checkmark-round"></span>');
// 		}
		
// 		return rowHTML;
// 	},
	
	
// 	//Builds the rows for the legend depending on the operator
// 	BuildLegendRowText: function(row) {
// 	    var op = (row.operator || 'equals').toLowerCase();
	    
// 	    if(row.topic_id === '--fake--') {
// 	        row.values = 'All';
// 	    }
	    
// 	    switch(op) {
// 	        case 'equals':
// 	            return row.values;
	            
//             case 'not equal to':
//                 return 'Not ' + row.values;
                
//             case 'starts with':
//                 return 'Starts with ' + row.values;
                
//             case 'contains':
//                 return 'Contains ' + row.values;
                
//             case 'does not contain':
//                 return 'Does not contain ' + row.values;
                
//             case 'ends with':
//                 return 'Ends with ' + row.values;
                
//             case 'less than':
//                 return 'Less than ' + row.values;
                
//             case 'less than equal to':
//                 return 'Less than or equal to ' + row.values;
                
//             case 'greater than':
//                 return 'Greater than ' + row.values;
                
//             case 'greater than equal to':
//                 return 'Greater than or equal to ' + row.values;
                
// 	        case 'range':
// 	            return row.min + ' to ' + row.max;
	            
//             default:
// 	            return '';
// 	    }
// 	},
	
	
// 	//Toggles the marker row hidden or shown
// 	ToggleMarkerRow: function(element) {
// 	    var $plottedLayer = $(element).closest('.PlottedRowUnit.DataLayer');
// 	    var markers = $plottedLayer.data('markers') || [];
// 	    var checkbox = $(element).find('.legend-visibility-toggle').find('span');
// 	    var rowid = $(element).attr('uid');
	    
// 	    var isShown = checkbox.hasClass('ion-checkmark-round');
	    
// 	    if(isShown) {
// 	        checkbox.removeClass('ion-checkmark-round');
// 	    } else {
// 	        checkbox.addClass('ion-checkmark-round');
// 	    }
// 	    var total = 0;
// 	    for(var ii=0, len=markers.length; ii<len; ii++) {
// 	        var newMap = isShown ? null : MA.map;
// 	        var isVisible = isShown ? false : true;
	        
	        
// 	        if(markers[ii].data.marker.rowid == rowid && markers[ii].isVisible) {
// 	            total++;
// 	            markers[ii].setMap(newMap);
// 	            //markers[ii].isVisible = isVisible;
// 	        }
// 	    }
// 	    $(element).find('.visiblemarkers').text(!isShown ? total : 0);
// 	},
	
	
// 	//Toggles the click events on polygons from the DOM
// 	ToggleLayerClickFromDOM: function(obj) {
// 	    var key = obj.closest('.PlottedRowUnit.DataLayer').getAttribute('key');
// 	    MADemographicLayer.ToggleLayerClick(key);
// 	},
	
	
// 	//Toggles the click events on polygons
// 	ToggleLayerClick: function(key) {
// 	    if(key !== null) {
//     	    //Remove all click events
//     	    google.maps.event.clearListeners(MA.map, 'click');
//     	    //Hide all clickability icons
//             $('.PlottedRowUnit.DataLayer').find('.inline.status').find('span').removeClass('ion-toggle-filled').addClass('ion-toggle');
    	    
//             //Turn on click for that single layer.
//             google.maps.event.addListener(MA.map, 'click', function(event) {
//             	MADemographicLayer.HandleClick(event, null, null, key, {layerName : $('.PlottedRowUnit.DataLayer[key="'+key+'"]').find('.basicinfo-name').text()});
//             });
//             //Show clickability icon for that layer
//             $('.PlottedRowUnit.DataLayer[key="'+key+'"]').find('.inline.status').find('span').removeClass('ion-toggle').addClass('ion-toggle-filled');
// 	    }
// 	}
    
// };