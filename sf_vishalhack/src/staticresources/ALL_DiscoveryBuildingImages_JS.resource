//2016-12-12- anirudh.singh@cdk.com- Modified the below JS to combine all the JS code present on the component, 
//this JS file and ALL_AccountGoogleMapsAPI_JS.
//2016-12-12- anirudh.singh@cdk.com- Added code for default checking the checkboxes.
//as all the images were getting displayed by default.
var j$=jQuery.noConflict();

var map;
var mapCenter;
var mapLatLngBounds;
var selectedOverlay;
var overlayDataList=[];
var newOverlayDataList=[];
var lineColorSelected;
var drawingManager;
var mapScenario;
var buildingImgRotations=[];

j$(document).ready(function()
{
    j$('#buildImgSpinnerDiv').modal('show');
    j$('.buildingImagesComponent').each(function()
	{
        processTabName(j$(this));
        
        processImageHeader(j$(this));
    });
    
    addEventsToRotateIcons();
    
    //j$('.loadingSpinnerDiv').hide();
    j$('.overlaysDataContentDiv').hide();
});

j$(window).load(function()
{
    applyDeviceImageRotations();
    
    if(j$('.inputParameters').data('scenario')!='pdf')
    {
        generateFilters();
    }
});

function generateFilters()
{
    j$('.buildingButtons').each(function()
	{
        j$(this).find('input').prop('checked', 'checked');
    });
    
    var deviceImageUl=j$('.deviceImageUl').isotope({
        itemSelector: '.deviceImageLi',
        filter: '*',
        layoutMode: 'fitRows'
    });
    
    //Filter items when filter link is clicked.
    var checkboxElements=j$('#deviceImageFilters').find('input');
    checkboxElements.change(function()
	{
        var checkedElementsValue=[];
        
        checkboxElements.each(function(i, elem)
		{
            if(elem.checked)
            {
                checkedElementsValue.push(j$(this).closest('label').data('filter'));
            }
        });
        
        var filterValue=checkedElementsValue.length>0 ? checkedElementsValue.join(', ') : '.hideAll';
        
        deviceImageUl.isotope({
            filter: filterValue
        });
        return false;
    });
}

function processTabName(thisComponent)
{
    var tabName=thisComponent.find('.inputParameters').data('tabname');
    
    if(tabName!='Network Details')
    {
        j$('.addAttachmentLinkForBuilding').remove();
    }
}

function processImageHeader(thisComponent)
{
    var headerElement=thisComponent.find('.buildingImgHeader');
    var inputElement=headerElement.find('input');
    var tabName=inputElement.data('tabname');
    var labelToDisplay=inputElement.data('labeltodisplay');
    var displayHeader=inputElement.data('displayheader');
    
    headerElement.empty();
    if(displayHeader)
    {
        if(labelToDisplay!=undefined && labelToDisplay!=null && labelToDisplay!='')
        {
            headerElement.prop('innerText', labelToDisplay);
        }
        else
        {
            headerElement.prop('innerText', tabName);
        }
    }
}

function initMap()
{
    if(document.getElementById('map')!=null)
    {
        j$('#buildImgSpinnerDiv').modal('show');
        
        var mapDivElement=j$('.mapDiv');
        
        var messageDivElement=mapDivElement.closest('.buildingImagesComponent').find('.messageDiv');
        messageDivElement.html('');
        messageDivElement.hide();
        
        var inputParametersElement=j$('.inputParameters');
        var oppLocationId=inputParametersElement.data('opplocationid');
        mapScenario=inputParametersElement.data('scenario'); 
        
        ALL_DiscoveryBuildingImages_Controller.fetchMap(oppLocationId, function(result, event)
        {
            if(event.status)
            {
                var mapObject;
                var mapZoom=19;
                
                if(result!=null)
                {
                    mapObject=JSON.parse(result);
                    
                    if(mapObject.mapZoom)
                    {
                        mapZoom=mapObject.mapZoom;
                    }
                }
                
                thisComponent=mapDivElement.closest('.buildingImagesComponent');
                var myOptions=
                    {
                        zoom: mapZoom,
                        mapTypeId: google.maps.MapTypeId.HYBRID,
                        mapTypeControl: true
                    }
                
                var accMarker;
                var geocoder=new google.maps.Geocoder();
                var addressGenerated=generateAddress(thisComponent);
                
                var address=addressGenerated.BillingStreet+', '+addressGenerated.BillingCity+', '+addressGenerated.BillingPostalCode;
                
                var accInfoWindow=new google.maps.InfoWindow({content: '<div class="infoContent accountInfo"><b>'+addressGenerated.AccountName+'</b></div>'});
                
                geocoder.geocode({address : address}, function(results, status)
				{
                    if(status==google.maps.GeocoderStatus.OK && results.length)
                    {
                        if(status!=google.maps.GeocoderStatus.ZERO_RESULTS)
                        {
                            map=new google.maps.Map(document.getElementById('map'), myOptions);
                            
                            mapCenter=results[0].geometry.location;
                            map.setCenter(mapCenter);
                            
                            accMarker=new google.maps.Marker({
                                position: mapCenter,
                                map: map,
                                title: addressGenerated.AccountName
                            });
                            
                            addListeners(accMarker, accInfoWindow);
                            
                            if(result!=null)
                            {
                                generateMapOverlays(mapObject.overlayList);
                                
                                if(mapScenario!='pdf')
                                {
                                    lineColorSelected=mapObject.lineColor;
                                    changeLineButtonColor(mapObject.lineColor);
                                }
                            }
                            
                            if(mapScenario!='pdf')
                            {
                                if(lineColorSelected==null || lineColorSelected=='' || lineColorSelected==undefined)
                                {
                                    lineColorSelected='#000000';
                                    changeLineButtonColor(lineColorSelected);
                                }
                                initDrawingManager();
                                
                                map.addListener('click', function()
                                {
                                    //Close previous opened Info Windows.
                                    j$('.infoContent').each(function()
                                    {
                                        closeInfoWindow(j$(this).find('.closeWindow'));
                                    });
                                    
                                    if(j$('.accountInfo').length!=0)
                                    {
                                        j$('.accountInfo').parent().parent().parent().parent().hide();
                                    }
                                });
                            }
                            
                            j$('#buildImgSpinnerDiv').modal('hide');
                        }
                    }
                    else
                    {
                        mapDivElement.css({
                            'height' : '15px'
                        });
                        
                        mapDivElement.html("<h4>Oops!"+ addressGenerated.AccountName + "'s address could not be found, please make sure the address is correct.</h4>");
                        resizeIframe();
                        mapDivElement.find('.buttonGroup').hide();
                        j$('#buildImgSpinnerDiv').modal('hide');
                    }
                });
            }
            else
            {
                mapDivElement.css({
                    'height' : '15px'
                });
                
                displayMessage('error', messageDivElement, 'Sorry, Some error occured while fetching Map values. Please contact your System Administrator.');
                resizeIframe();
                mapDivElement.find('.buttonGroup').hide();
                j$('#buildImgSpinnerDiv').modal('hide');
            }
        }, 
        {escape: false});
    }
}

function generateAddress(thisComponent)
{
    var myObject=new Object();
    var inputParameters=thisComponent.find('.inputParameters');
    myObject.BillingStreet=inputParameters.data('billingstreet');
    myObject.BillingCity=inputParameters.data('billingcity');
    myObject.BillingPostalCode=inputParameters.data('billingpostalcode');
    myObject.AccountName=inputParameters.data('accountname');
    
    return myObject;
}

function addListeners(marker, infoWindow)
{
    if(mapScenario!='pdf')
    {
        google.maps.event.addListener(marker, 'click', function()
        {
            //Close previous opened Info Windows.
            j$('.infoContent').each(function()
            {
                j$(this).parent().parent().parent().parent().hide();
            });
            
            infoWindow.open(map, marker);
        });
    }
    else
    {
        infoWindow.open(map, marker);
    }
    
    google.maps.event.addListener(infoWindow, 'domready', function()
	{
        var iwElement=j$('.accountInfo').closest('.gm-style-iw');
        iwElement.addClass('iwElement');
        iwElement.next().hide();
        
        //Info Window Styling.
        iwElementPrevSibling=iwElement.prev();
        
        iwElementPrevSibling.children(':nth-child(2)').hide();
        iwElementPrevSibling.children(':nth-child(4)').hide();
        
        var iwElementThirdDiv=iwElementPrevSibling.children(':nth-child(3)');
        iwElementThirdDiv.addClass('iwElementThirdDiv');
        iwElementThirdDiv.find('div').css('z-index', '1');
        j$(iwElementThirdDiv.find('> div > div').get(0)).css('border-left', '2px solid #FF0000');
        j$(iwElementThirdDiv.find('> div > div').get(1)).css('border-right', '2px solid #FF0000');
        j$('.accountInfo').css('border', '2px solid #FF0000');
        
        if(mapScenario!='pdf')
        {
            j$(iwElementThirdDiv.find('> div > div').get(0)).css('border-left', '2px solid rgb(0, 169, 206)');
            j$(iwElementThirdDiv.find('> div > div').get(1)).css('border-right', '2px solid rgb(0, 169, 206)');
            j$('.accountInfo').css('border', '2px solid rgb(0, 169, 206)');
        }
    });
    
    google.maps.event.addListener(marker, 'dblclick', function()
	{
        map.setCenter(mapCenter);
    });
    
    google.maps.event.addListener(map, 'zoom_changed', function()
	{
        map.setCenter(mapCenter);
    });
    
    google.maps.event.addDomListener(window, 'resize', function()
	{
        var center=map.getCenter();
        google.maps.event.trigger(map, 'resize');
        map.setCenter(center);
    });
}

function initDrawingManager()
{
    drawingManager=new google.maps.drawing.DrawingManager({
        drawingMode: null,
        drawingControl: true,
        drawingControlOptions: {
            position: google.maps.ControlPosition.TOP_CENTER,
            drawingModes: ['marker', 'polyline', 'rectangle', 'circle', 'polygon']
        },
        polylineOptions:
        {
            strokeColor: lineColorSelected
        },
        rectangleOptions:
        {
            strokeColor: lineColorSelected
        },
        circleOptions:
        {
            strokeColor: lineColorSelected
        },
        polygonOptions:
        {
            strokeColor: lineColorSelected
        }
    });
    drawingManager.setMap(map);
    
    bindCompleteEvents(drawingManager);
}

function bindCompleteEvents(drawingManager)
{
    google.maps.event.addListener(drawingManager, 'overlaycomplete', function(event)
	{
        var overlayType=event.type;
        var overlay=event.overlay;
        
        var infoWindowPosition=fetchInfoWindowPosition(overlayType, overlay);
        var overlayNumber=generateUniqueString();
        
        createInfoWindow(overlayNumber, overlay, infoWindowPosition, '', overlayType);
        
        createDeleteWindow(overlayNumber, overlayType, overlay, infoWindowPosition);
        
        //Setting drawing mode to Null after each drawing.
        if(drawingManager.getDrawingMode())
        {
            drawingManager.setDrawingMode(null);
        }
        
        populateNewOverlayDataList(overlayType, overlay, overlayNumber);
    });
}

function createInfoWindow(overlayNumber, overlay, infoWindowPosition, content, overlayType)
{
    var infoWindow=new google.maps.InfoWindow({
        content: generateInfoWindowContent(overlayNumber, content, overlayType)
    });
    
    overlay.addListener('click', function()
	{
        //Close previous opened Info Windows.
        j$('.infoContent').each(function()
		{
            j$(this).parent().parent().parent().parent().hide();
            closeInfoWindow(j$(this).find('.closeWindow'));
        });
        infoWindow.open(map, overlay);
    });
    infoWindow.setPosition(infoWindowPosition);
    
    google.maps.event.addListener(infoWindow, 'domready', function()
	{
        selectedOverlay=overlay;
        
        var iwElement=j$('.infoContent').closest('.gm-style-iw');
        iwElement.addClass('iwElement');
        iwElement.next().hide();
        
        iwElement.find('.details').show();
        iwElement.find('.info').hide();
        
        //Info Window Styling.
        iwElementPrevSibling=iwElement.prev();
        
        iwElementPrevSibling.children(':nth-child(2)').hide();
        iwElementPrevSibling.children(':nth-child(4)').hide();
        
        var iwElementThirdDiv=iwElementPrevSibling.children(':nth-child(3)');
        iwElementThirdDiv.find('div').css('z-index', '1');
        iwElementThirdDiv.each(function()
		{
            var thisElement=j$(this);
            j$(thisElement.find('> div > div').get(0)).css('border-left', '2px solid rgb(0, 169, 206)');
            j$(thisElement.find('> div > div').get(1)).css('border-right', '2px solid rgb(0, 169, 206)');
        });
    });
}

function generateInfoWindowContent(overlayNumber, content, overlayType)
{
    var header='<div class="infoWindowHeader">'
    +'<h4><b>Details</b></h4>'
    +'</div>';
    
    var body='<div class="infoWindowBody">'
    +'<input type="hidden" class="overlayData" data-number="'+overlayNumber+'" data-overlaytype="'+overlayType+'"/>';
    body+=(content!=undefined && content!=null && content!='') ? 
        '<div class="infoText">'+content+'<i class="fa fa-pencil pencilIcon" aria-hidden="true" onclick="editContent(j$(this));"></i></div>'
    : '<textarea class="form-control textAreaField" placeHolder="Enter some details..."></textarea>';
    body+='</div>';
    
    var footer='<div class="infoWindowFooter">'
    +'<button type="button" class="btn btn-default deleteInfoBtn" onclick="deleteOverlayConfirmation(j$(this));">Delete</button>'
    +'<button type="button" class="btn btn-default closeWindow" onclick="closeInfoWindow(j$(this));">Close</button>'
    +'</div>';
    
    var infoElement='<div class="infoContent details">'+header+body+footer+'</div>'
    +generateDeleteWindowContent(overlayNumber, overlayType, 'info');
    
    return infoElement;
}

function editContent(pencilIconElement)
{
    var infoTextElement=pencilIconElement.closest('.infoText');
    var inputTextAreaElement='<textarea class="form-control textAreaField" placeHolder="Enter some details...">'+infoTextElement.prop('innerText')+'</textarea>';
    infoTextElement.replaceWith(inputTextAreaElement);
}

function deleteOverlayConfirmation(deleteBtnElement)
{
    var iwElement=deleteBtnElement.closest('.gm-style-iw');
    iwElement.find('.details').hide();
    iwElement.find('.info').show();
}

function createDeleteWindow(overlayNumber, overlayType, overlay, infoWindowPosition)
{
    //Delete Window
    var deleteWindow=new google.maps.InfoWindow({
        content: generateDeleteWindowContent(overlayNumber, overlayType, 'delete')
    });
    
    overlay.addListener('rightclick', function()
	{
        selectedOverlay=overlay;
        
        //Close previous opened Info Windows.
        j$('.infoContent').each(function()
		{
            j$(this).parent().parent().parent().parent().hide();
            closeInfoWindow(j$(this).find('.closeWindow'));
        });
        deleteWindow.open(map, overlay);
    });
    deleteWindow.setPosition(infoWindowPosition);
    
    google.maps.event.addListener(deleteWindow, 'domready', function()
	{
        var iwElement=j$('.infoContent').closest('.gm-style-iw');
        iwElement.addClass('iwElement');
        iwElement.next().hide();
        
        //Info Window Styling.
        iwElementPrevSibling=iwElement.prev();
        
        iwElementPrevSibling.children(':nth-child(2)').hide();
        iwElementPrevSibling.children(':nth-child(4)').hide();
        
        var iwElementThirdDiv=iwElementPrevSibling.children(':nth-child(3)');
        iwElementThirdDiv.find('div').css('z-index', '1');
        iwElementThirdDiv.each(function()
		{
            var thisElement=j$(this);
            j$(thisElement.find('> div > div').get(0)).css('border-left', '2px solid rgb(0, 169, 206)');
            j$(thisElement.find('> div > div').get(1)).css('border-right', '2px solid rgb(0, 169, 206)');
        });
    });
}

function generateDeleteWindowContent(overlayNumber, overlayType, windowScenario)
{
    var header='<div class="deleteWindowHeader">'
    +'<h4><b>Delete Confirmation</b></h4>'
    +'</div>';
    
    var body='<div class="deleteWindowBody">'
    +'<input type="hidden" class="overlayData" data-number="'+overlayNumber+'"/>'
    +'<div class="deleteText">Do you want to delete this '+overlayType+'?</div>'
    +'</div>';
    
    var footer='<div class="infoWindowFooter">'
    +'<button type="button" class="btn btn-default closeWindow" onclick="closeInfoWindow(j$(this));">Close</button>'
    +'<button type="button" class="btn btn-primary deleteButton" onclick="deleteOverlay(j$(this));">Confirm Delete</button>'
    +'</div>';
    
    var deleteElement='<div class="infoContent '+windowScenario+'">'+header+body+footer+'</div>';
    
    return deleteElement;
}

function fetchInfoWindowPosition(overlayType, overlay)
{
    var infoWindowPosition;
    if(overlayType=='marker')
    {
        infoWindowPosition=overlay.getPosition();
    }
    else if(overlayType=='polyline')
    {
        infoWindowPosition=overlay.getPath().getAt(0);
    }
	else if(overlayType=='rectangle')
    {
        infoWindowPosition=overlay.getBounds().getNorthEast();
    }
	else if(overlayType=='circle')
    {
        infoWindowPosition=overlay.getCenter();
    }
	else if(overlayType=='polygon')
    {
        infoWindowPosition=overlay.getPath().getAt(0);
    }
    return infoWindowPosition;
}

function populateNewOverlayDataList(overlayType, overlay, overlayNumber)
{
    var overlayDataObject=new Object();
    overlayDataObject.number=overlayNumber;
    overlayDataObject.overlayType=overlayType;
    overlayDataObject.overlay=overlay;
    overlayDataObject.lineColor=lineColorSelected;
    newOverlayDataList.push(overlayDataObject);
}

function generateUniqueString()
{
    return fetchUniqueString()+fetchUniqueString()+'-'+fetchUniqueString()+'-'+fetchUniqueString()+'-'+
        fetchUniqueString()+'-'+fetchUniqueString()+fetchUniqueString()+fetchUniqueString();
}

function fetchUniqueString()
{
    return Math.floor((1+Math.random())*0x10000)
    .toString(16)
    .substring(1);
}

function generateMapOverlays(overlayList)
{
    if(overlayList!=null && overlayList!='' && overlayList!=undefined && overlayList.length>0)
    {
        var index=0;
        var indexContentList=[];
        
        j$.each(overlayList, function(index, ref)
		{
            var overlayType=ref.overlayType;
            var overlay;
            
            var overlayDataObject=new Object();
            overlayDataObject.number=ref.number;
            overlayDataObject.overlayType=overlayType;
            overlayDataObject.content=ref.content;
            overlayDataObject.lineColor=ref.lineColor;
            
            if(overlayType=='marker')
            {
                var markerRef=new google.maps.Marker({
                    map: map,
                    position: ref.position
                });
                overlay=markerRef;
            }
            else if(overlayType=='polyline')
            {
                var polylineRef=new google.maps.Polyline({
                    map: map,
                    path: ref.path,
                    strokeColor: ref.lineColor
                });
                overlay=polylineRef;
            }
            else if(overlayType=='rectangle')
            {
                var rectangleRef=new google.maps.Rectangle({
                    map: map,
                    bounds: ref.bounds,
                    strokeColor: ref.lineColor
                });
                overlay=rectangleRef;
            }
            else if(overlayType=='circle')
            {
                var circleRef=new google.maps.Circle({
                    map: map,
                    center: ref.center,
                    radius: ref.radius,
                    strokeColor: ref.lineColor
                });
                overlay=circleRef;
            }
            else if(overlayType=='polygon')
            {
                var polygonRef=new google.maps.Polygon({
                    map: map,
                    paths: ref.path,
                    strokeColor: ref.lineColor
                });
                overlay=polygonRef;
            }
            
            var infoWindowPosition=fetchInfoWindowPosition(overlayType, overlay);
            var overlayNumber=ref.number;
            
            if(mapScenario!='pdf')
            {
                createInfoWindow(overlayNumber, overlay, infoWindowPosition, ref.content, overlayType);
                
                createDeleteWindow(overlayNumber, overlayType, overlay, infoWindowPosition);
            }
            else
            {
                index++;
                
                var indexContentObject=new Object();
                indexContentObject.indexNo=index;
                indexContentObject.content=ref.content;
                indexContentList.push(indexContentObject);
                
                createInfoWindowForPDFVersion(index, overlay, infoWindowPosition);
            }
            
            overlayDataObject.overlay=overlay;
            overlayDataList.push(overlayDataObject);
        });
        
        if(mapScenario=='pdf' && indexContentList.length>0)
        {
            displayIndexContent(indexContentList);
        }
    }
}

function createInfoWindowForPDFVersion(index, overlay, infoWindowPosition)
{
    var infoWindow=new google.maps.InfoWindow({
        content: '<div class="indexNo">'+index+'</div>'
    });
    
    infoWindow.open(map, overlay);
    infoWindow.setPosition(infoWindowPosition);
    
    google.maps.event.addListener(infoWindow, 'domready', function()
	{
        var iwElement=j$('.indexNo').closest('.gm-style-iw');
        iwElement.addClass('iwElement');
        iwElement.next().hide();
        
        //Info Window Styling.
        iwElementPrevSibling=iwElement.prev();
        
        iwElementPrevSibling.children(':nth-child(2)').hide();
        iwElementPrevSibling.children(':nth-child(4)').hide();
        
        var iwElementThirdDiv=iwElementPrevSibling.children(':nth-child(3)');
        iwElementThirdDiv.find('div').css('z-index', '1');
        iwElementThirdDiv.addClass('iwElementThirdDiv');
        
        iwElementThirdDiv.each(function()
		{
            var thisElement=j$(this);
            j$(thisElement.find('> div > div').get(0)).css('border-left', '2px solid #FF0000');
            j$(thisElement.find('> div > div').get(1)).css('border-right', '2px solid #FF0000');
        });
    });
}

function displayIndexContent(indexContentList)
{
    var mapDivElement=j$('.mapDiv');
    var mapIndexContentTable='<div class="mapIndexContent">'
    +'<table class="table-bordered table-hover">'
    +'<thead>'
    +'<tr>'
    +'<th class="indexNoTh">Index No.</th>'
    +'<th class="contentTh">Details</th>'
    +'</tr>'
    +'</thead>'
    +'<tbody>';
    j$.each(indexContentList, function(index, ref)
	{
        mapIndexContentTable+='<tr>'
        +'<td class="indexNoTd">'+ref.indexNo+'</td>'
        +'<td class="contentTd">'+ref.content+'</td>'
        +'</tr>';
    });
    mapIndexContentTable+='</tbody>'
    +'</table>'
    +'</div>';
    
    mapDivElement.append(mapIndexContentTable);
}

function deleteOverlay(deleteButtonElement)
{
    var selectedOverlayNumber=deleteButtonElement.closest('.infoContent').find('.overlayData').data('number');
    
    var overlayDataListLengthBefore=overlayDataList.length;
    overlayDataList=j$.grep(overlayDataList, function(ref)
	{
        if(ref.number!=selectedOverlayNumber)
        {
            return ref;
        }
    });
    var overlayDataListLengthAfter=overlayDataList.length;
    
    if(selectedOverlay)
    {
        selectedOverlay.setMap(null);
    }
    
    if(overlayDataListLengthBefore==overlayDataListLengthAfter)
    {
        newOverlayDataList=j$.grep(newOverlayDataList, function(ref)
        {
            if(ref.number!=selectedOverlayNumber)
            {
                return ref;
            }
        });
    }
    else
    {
        saveMapChanges();
    }
}

function closeInfoWindow(closeButtonElement)
{
    var infoContentElement=closeButtonElement.closest('.infoContent');
    infoContentElement.parent().parent().parent().parent().hide();
    var infoTextElement=infoContentElement.find('.infoText');
    var textAreaElement=infoContentElement.find('.textAreaField');
    
    if(infoTextElement.length==0 && textAreaElement.length>0 
       && textAreaElement.val()!=null && textAreaElement.val()!='' && textAreaElement.val()!=undefined)
    {
        var infoTextElement='<div class="infoText">'+textAreaElement.val()
        +'<i class="fa fa-pencil pencilIcon" aria-hidden="true" onclick="editContent(j$(this));"></i></div>';
        
        textAreaElement.replaceWith(infoTextElement);
    }
}

function resizeIframe()
{
    var me=window.name;
    if(me)
    {
        var iframes=parent.document.getElementsByName(me);
        if(iframes && iframes.length==1)
        {
            height=document.body.offsetHeight;
            iframes[0].style.height=height+"px";
        }
    }
}

function saveMapChanges()
{
    j$('#buildImgSpinnerDiv').modal('show');
    
    var messageDivElement=j$('.mapDiv').closest('.buildingImagesComponent').find('.messageDiv');
    messageDivElement.html('');
    messageDivElement.hide();
    
    var oppLocationId=j$('.inputParameters').data('opplocationid');
    
    var mapObject=new Object();
    mapObject.mapZoom=map.getZoom();
    mapObject.overlayList=fetchOverlayDetails();
    mapObject.lineColor=lineColorSelected;
    
    ALL_DiscoveryBuildingImages_Controller.saveMap(oppLocationId, JSON.stringify(mapObject), function(result, event)
	{
        if(event.status)
        {
            if(result=='')
            {
                var messageText='Map changes successfully saved.';
                displayMessage('success', messageDivElement, messageText);
                location.reload();
                j$('#buildImgSpinnerDiv').modal('hide');
            }
            else if(result=='Save not valid. No changes found.')
            {
                displayMessage('info', messageDivElement, result);
                j$('#buildImgSpinnerDiv').modal('hide');
            }
            else
            {
                displayMessage('error', messageDivElement, 'Sorry, the Map changes could not be saved, due to the some error. Please contact your System Administrator.');
                j$('#buildImgSpinnerDiv').modal('hide');
            }
        }
        else
        {
            displayMessage('error', messageDivElement, 'Sorry, the Map changes could not be saved, due to the some error. Please contact your System Administrator.');
            j$('#buildImgSpinnerDiv').modal('hide');
        }
    });
}

function fetchOverlayDetails()
{
    var overlayDataToSaveList=[];
    j$.merge(overlayDataList, newOverlayDataList);
    
    j$.each(overlayDataList, function(index, ref)
	{
        var overlayType=ref.overlayType;
        var overlayNumber=ref.number;
        
        var overlayDataToSaveObject=new Object();
        overlayDataToSaveObject.overlayType=overlayType;
        overlayDataToSaveObject.number=overlayNumber;
        overlayDataToSaveObject.lineColor=ref.lineColor;
        
        if(overlayType=='marker')
        {
            overlayDataToSaveObject.position=ref.overlay.position;
        }
        else if(overlayType=='polyline')
        {
            overlayDataToSaveObject.path=ref.overlay.getPath().getArray();
        }
        else if(overlayType=='rectangle')
        {
            overlayDataToSaveObject.bounds=ref.overlay.getBounds();
        }
        else if(overlayType=='circle')
        {
            overlayDataToSaveObject.center=ref.overlay.getCenter();
            overlayDataToSaveObject.radius=ref.overlay.getRadius();
        }
        else if(overlayType=='polygon')
        {
            overlayDataToSaveObject.path=ref.overlay.getPath().getArray();
        }
        
        var infoContentElements=j$('.details');
        var match=0;
        if(infoContentElements.length>0)
        {
            //Fetch Content.
            infoContentElements.each(function()
            {
                var thisElement=j$(this);
                var contentNo=thisElement.find('.overlayData').data('number');
                
                if(overlayNumber==contentNo)
                {
                    overlayDataToSaveObject.content=(thisElement.find('.textAreaField').length>0) ? thisElement.find('.textAreaField').val() 
                    : thisElement.find('.infoText').prop('innerText');
                    
                    match=1;
                }
            });
        }
        
        if(match==0)
        {
            overlayDataToSaveObject.content=(ref.content!=null && ref.content!=undefined) ? ref.content : '';
        }
        
        overlayDataToSaveList.push(overlayDataToSaveObject);
    });
    
    return overlayDataToSaveList;
}

function displayMessage(errorScenario, messageDivElement, messageText)
{
    var alertMessage;
    if(errorScenario=='success')
    {
        alertMessage='<div class="alert alert-success" role="alert">'
        +'<strong>Success!</strong> ';
    }
    else if(errorScenario=='error')
    {
        alertMessage='<div class="alert alert-danger" role="alert">'
        +'<strong>Error!</strong> ';
    }
    else if(errorScenario=='info')
    {
        alertMessage='<div class="alert alert-info" role="alert">'
        +'<strong>Info!</strong> ';
    }
    
    alertMessage+=messageText;
    alertMessage+='</div>';
    
    messageDivElement.html(alertMessage);
    messageDivElement.show();
}

function clearMap(clearBtnElement)
{
    var thisComponent=clearBtnElement.closest('.buildingImagesComponent');
    var thisCompModal=thisComponent.find('.modalDialogMap');
    
    if(overlayDataList.length==0 && newOverlayDataList.length==0)
    {
        thisCompModal.find('.modal-title').html('<b>Clear Map Info</b>');
        thisCompModal.find('.modal-body').html('<p>Nothing to clear! There are no shapes present on the Map, other than the Site Marker.<p>');
        
        var footerElement='<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>';
        thisCompModal.find('.modal-footer').html(footerElement);
    }
    else
    {
        thisCompModal.find('.modal-title').html('<b>Clear Map Confirmation</b>');
        thisCompModal.find('.modal-body').html('<p>Do you really want to clear all the shapes from the Map?<p>');
        
        var footerElement='<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>';
        footerElement+='<button type="button" class="btn btn-primary" onclick="deleteAllOverlays(j$(this));">Confirm Clear Map</button>';
        thisCompModal.find('.modal-footer').html(footerElement);
    }
}

function deleteAllOverlays(deleteAllBtnElement)
{
    j$('#buildImgSpinnerDiv').modal('show');
    
    deleteAllBtnElement.closest('.buildingImagesComponent').find('#modalDialogMap').modal('toggle');
    var overlayDataListlengthBefore=overlayDataList.length;
    for(var i=0; i<overlayDataList.length; i++)
    {
        overlayDataList[i].overlay.setMap(null);
    }
    
    for(var i=0; i<newOverlayDataList.length; i++)
    {
        newOverlayDataList[i].overlay.setMap(null);
    }
    
    overlayDataList=[];
    newOverlayDataList=[];
    
    if(overlayDataListlengthBefore!=0)
    {
        saveMapChanges();
    }
    j$('#buildImgSpinnerDiv').modal('hide');
}

function changeLineColor(lineColorElement)
{
    lineColorSelected=lineColorElement.find('.liColorSpan').data('color');
    changeLineButtonColor(lineColorSelected);
    drawingManager.setMap(null);
    initDrawingManager();
}

function changeLineButtonColor(lineColorSelected)
{
    var lineColorButton=j$('.lineColorBtn').find('button');
    
    if(lineColorSelected=='#FF0000' || lineColorSelected=='#0000FF' || lineColorSelected=='#FFA500')
    {
        lineColorButton.css('color', '#FFFFFF').css('background-color', lineColorSelected);
    }
    else if(lineColorSelected=='#00FF00' || lineColorSelected=='#FFFF00')
    {
        lineColorButton.css('color', '#000000').css('background-color', lineColorSelected);
    }
    else
    {
        lineColorButton.css('color', '#FFFFFF').css('background-color', lineColorSelected);
    }
}

function addEventsToRotateIcons()
{
    j$('.rotateLeft').on('click', function()
	{
        rotateImage(j$(this), 'left');
    });
    
    j$('.rotateRight').on('click', function()
	{
        rotateImage(j$(this), 'right');
    });
}

function applyDeviceImageRotations()
{
    var oppLocationId=j$('.inputParameters').data('opplocationid');
    j$('#buildImgSpinnerDiv').modal('show');
    
    ALL_DiscoveryBuildingImages_Controller.fetchImgRotations(oppLocationId, function(result, event)
	{
        if(event.status)
        {
            var buildingImgRotatnsList=[];
            if(result!=null)
            {
                buildingImgRotatnsList=result;
                for(var i=0; i<buildingImgRotatnsList.length; i++)
				{
                    var buildingImgRotation=populateBuildingImgRotations(buildingImgRotatnsList[i]);
                    var fetchedBuildingName=buildingImgRotatnsList[i].oppBuildingName;
                    
                    j$('.deviceImageLi').each(function()
					{
                        var deviceImageLi=j$(this);
                        var imgDetails=deviceImageLi.find('.imgDetails');
                        var oppBuildingName=imgDetails.data('oppbuildingname');
                        
                        if(oppBuildingName==fetchedBuildingName && buildingImgRotation.imgRotations!='')
                        {
                            var imageId=imgDetails.data('imageid');
                            
                            for(var j=0; j<buildingImgRotation.imgRotations.length; j++)
                            {
                                var fetchedImageId=buildingImgRotation.imgRotations[j].imgId;
                                if(imageId==fetchedImageId)
                                {
                                    var fetchedImageRotation=buildingImgRotation.imgRotations[j].rotation;
                                    deviceImageLi.find('.currentRotation').prop('value', fetchedImageRotation);
                                    deviceImageLi.find('.existingRotation').prop('value', fetchedImageRotation);
                                    
                                    var imgElement=deviceImageLi.find('img');
                                    imgElement.css({'transform': 'rotate('+fetchedImageRotation+'deg)'});
                                   	
                                    var imgPositionTop=imgElement.position().top;
                                    var imgPositionLeft=imgElement.position().left;
                                    
                                    var imgTop=Math.abs(imgPositionTop)+5;
                                    var imgLeft=-(imgPositionLeft)+5;
                                    
                                    if(fetchedImageRotation==0 || fetchedImageRotation==180 || fetchedImageRotation==-180)
                                    {
                                        imgElement.css({'margin': 0});
                                    }
                                    else
                                    {
                                        if(imgPositionTop>0)
                                        {
                                            imgElement.css({'margin-left': imgLeft, 'margin-right': imgLeft});
                                        }
                                        else
                                        {
                                            imgElement.css({'margin-top': imgTop, 'margin-left': imgLeft, 'margin-right': imgLeft, 'margin-bottom': imgTop});
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                        
                        if(j$('.inputParameters').data('scenario')!='pdf')
                        {
                            generateFilters();
                        }
                        j$('#buildImgSpinnerDiv').modal('hide');
                    });
                }
            }
            j$('#buildImgSpinnerDiv').modal('hide');
        }
    }, 
	{escape: false});
}

function populateBuildingImgRotations(buildingImgRotatns)
{
    var buildingImgRotation=new Object();
    buildingImgRotation['oppBuildingId']=buildingImgRotatns.oppBuildingId;
    buildingImgRotation['imgRotations']=[];
    
    if(buildingImgRotatns.imgRotations!=undefined && buildingImgRotatns.imgRotations!=null)
    {
        buildingImgRotation['imgRotations']=JSON.parse(buildingImgRotatns.imgRotations);
    }
    
    buildingImgRotations.push(buildingImgRotation);
    return buildingImgRotation;
}

function rotateImage(iconElement, iconScenario)
{
    var deviceImageLi=iconElement.closest('.deviceImageLi');
    var currentRotation=deviceImageLi.find('.currentRotation');
    var imgElement=deviceImageLi.find('img');
    var rotationDeg=currentRotation.val();
    
    if(iconScenario=='left')
    {
        rotationDeg=parseInt(rotationDeg)-90;
        rotationDeg=(rotationDeg==-360) ? 0 : rotationDeg;
    }
    else
    {
        rotationDeg=parseInt(rotationDeg)+90;
        rotationDeg=(rotationDeg==360) ? 0 : rotationDeg;
    }
    
    imgElement.css({'transform': 'rotate('+rotationDeg+'deg)'});
    currentRotation.prop('value', rotationDeg);
    
    var imgPositionTop=imgElement.position().top;
    var imgPositionLeft=imgElement.position().left;
    
    var imgTop=Math.abs(imgPositionTop)+5;
    var imgLeft=-(imgPositionLeft)+5;
    
    if(rotationDeg==0 || rotationDeg==180 || rotationDeg==-180)
    {
        imgElement.css({'margin': 0});
    }
    else
    {
        if(imgPositionTop>0)
        {
            imgElement.css({'margin-left': imgLeft, 'margin-right': imgLeft});
        }
        else
        {
            imgElement.css({'margin-top': imgTop, 'margin-left': imgLeft, 'margin-right': imgLeft, 'margin-bottom': imgTop});
        }
    }
    
    generateFilters();
}

function saveDeviceImgChanges(element)
{
    var thisDeviceImg=j$(element);
    var deviceImageLi=thisDeviceImg.closest('.deviceImageLi');
    var imgDetails=deviceImageLi.find('.imgDetails');
    var existingDesc=imgDetails.data('existingdesc');
    var currentDesc=deviceImageLi.find('.deviceImageDesc').val();
    var existingRotation=deviceImageLi.find('.existingRotation').val();
    var currentRotation=deviceImageLi.find('.currentRotation').val();
    
    var messageDivElement=thisDeviceImg.closest('.buildingImagesComponent').find('.deviceImgMessageDiv');
    messageDivElement.hide();
    j$('#buildImgSpinnerDiv').modal('show');
    
    if(existingDesc!=currentDesc || existingRotation!=currentRotation)
    {
        var imgId=imgDetails.data('imageid');
        var oppBuildingId=imgDetails.data('oppbuildingid');
        
        var oppBuildingObj=new Object();
        oppBuildingObj['oppBuildingId']=oppBuildingId;
        oppBuildingObj['imgRotations']=fetchImgRotations(oppBuildingId, imgId, currentRotation);
        var oppBuildingObjJson=JSON.stringify(oppBuildingObj);
        
        ALL_DiscoveryBuildingImages_Controller.saveImgChanges(imgId, currentDesc, oppBuildingObjJson, function(result, event)
        {
            if(event.result=='Success')
            {
                displayMessage('success', messageDivElement, 'Image Changes saved successfully!!');
                j$('#buildImgSpinnerDiv').modal('hide');
            }
            else
            {
                displayMessage('error', messageDivElement, 'Some error occured while saving Device Image Changes. Please contact your System Administrator...');
                j$('#buildImgSpinnerDiv').modal('hide');
            }
        });
    }
    else
    {
        displayMessage('info', messageDivElement, 'No Changes Found. Nothing to Save!!');
        j$('#buildImgSpinnerDiv').modal('hide');
    }
}

function fetchImgRotations(oppBuildingId, imgId, currentRotation)
{
    var imgIdAndRotationList=[];
    
    if(buildingImgRotations.length>0)
    {
        for(var i=0; i<buildingImgRotations.length; i++)
        {
            var thisOppBuildingId=buildingImgRotations[i]['oppBuildingId'];
            var thisBuildingImgRotations=buildingImgRotations[i]['imgRotations'];
            
            if(thisOppBuildingId==oppBuildingId && thisBuildingImgRotations.length==0)
            {
                var imgIdAndRotation=new Object();
                imgIdAndRotation['imgId']=imgId;
                imgIdAndRotation['rotation']=currentRotation;
                
                thisBuildingImgRotations.push(imgIdAndRotation);
                imgIdAndRotationList=thisBuildingImgRotations;
                break;
            }
            else if(thisOppBuildingId==oppBuildingId && thisBuildingImgRotations.length>0)
            {
                var imgIdPresent=false;
                for(var j=0; j<thisBuildingImgRotations.length; j++)
                {
                    if(imgId==thisBuildingImgRotations[j]['imgId'])
                    {
                        thisBuildingImgRotations[j]['rotation']=currentRotation;
                        imgIdPresent=true;
                        break;
                    }
                }
                
                if(!imgIdPresent)
                {
                    var imgIdAndRotation=new Object();
                    imgIdAndRotation['imgId']=imgId;
                    imgIdAndRotation['rotation']=currentRotation;
                    
                    thisBuildingImgRotations.push(imgIdAndRotation);
                }
                imgIdAndRotationList=thisBuildingImgRotations;
                break;
            }
        }
    }
    
    return JSON.stringify(imgIdAndRotationList);
}