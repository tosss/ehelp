//2016-08-30- anirudh.singh@cdk.com- Created this JS for ALL_ObjectDetails Visualforce Component.
var j$=jQuery.noConflict();
//2017-02-02- anirudh.singh@cdk.com- Added the below variable.
var scrollTimer=null;

//Processing on Ready event of the document.
j$(document).ready(
    function()
    {
        processOnLoad();
    }
);

//This method is invoked from the on Ready event of the document.
function processOnLoad()
{
    processHyperLinks();
    
    addDataTHToColumns();
    
    processToolTips();
    
    processReportLinks();
    
    processBuildingDependentLinks();
    
    processTimeZone();
    
    //2017-02-02- anirudh.singh@cdk.com- Added the below line.
    if(j$('.objectDetailsComponent').length==1)
    {
        freezeTableHeaders();
    }
}

//Processing Hyper Links.
function processHyperLinks()
{
    var linkElements=j$('.objectDetailsColumnData').find('a');
    
    linkElements.each(function()
	{
        var href=j$(this).prop('href');
        var innerText=j$(this).prop('innerText');
        
        var anchorElement=j$('<a></a>').prop('href', href).prop('innerText', innerText).prop('target', '_blank').addClass('underlinedLinks');
        j$(this).replaceWith(anchorElement);
    });
}

//Adding data-th attribute to columns, which is used to display the column Name in Tablet view.
function addDataTHToColumns()
{
    j$('table.objectDetailsTable').each(function()
	{
        var headerElement=j$(this).find('thead').find('th.objectDetailsTh');
        var headerNames=[];
        headerElement.each(function()
		{
            if(j$(this).prop('className').indexOf('itemNoColumn')==-1)
            {
                headerNames.push(j$(this).prop('textContent').trim());
            }
        });
        
        var bodyTrElements=j$(this).find('tbody').find('tr.objectDetailsRowData');
        bodyTrElements.each(function()
		{
            var tdElements=j$(this).find('td.objectDetailsColumnData');
            
            for(var i=0; i<tdElements.length; i++)
            {
                j$(tdElements[i]).each(function()
				{
                    j$(this).attr('data-th', headerNames[i]);
                });
                
                j$(tdElements[i]).children().each(function()
				{
                    if(!j$(this).is('script') && j$(this).prop('className').indexOf('noDisplay')==-1)
                    {
                        j$(this).addClass('tdChildContent');
                    }
                });
            }
        });
        
        j$('.deleteIconColumn').attr('data-th', 'To Delete, Click on Icon:');
    });
}

//Intializing bootstrap tooltips and styling them.
function processToolTips()
{
    j$('[data-toggle="tooltip"]').tooltip();
    
    j$('[data-toggle="tooltip"]').hover(function()
	{
        j$('.tooltip-inner').css('background-color', '#53565A');
        j$('.tooltip-inner').css('white-space', 'pre-wrap');
        j$('.tooltip-arrow').css('border-top-color', '#53565A');
    });
}

function processReportLinks()
{
    var objectDetailsElement=j$('.objectDetailsComponent');
    objectDetailsElement.each(function()
	{
        var reportLinkElement=j$(this).find('.reportLinks');
        if(reportLinkElement.length==1)
        {
            var reportRecLinkElements=reportLinkElement.find('a.reportRecLink');
            for(var i=0; i<reportRecLinkElements.length; i++)
			{
                if(i>0)
                {
                    j$('<b>,</b>').insertBefore(reportRecLinkElements[i]);
                }
            }
        }
    });
}

function processBuildingDependentLinks()
{
    var linkToBeUsedForBuildingElements=j$('.objectDetailsComponent').find('.linkToBeUsedForBuilding');
    
    //If more than two tables present have linkToBeUsedForBuilding.
    if(linkToBeUsedForBuildingElements.length>0)
    {
        linkToBeUsedForBuildingElements.each(function()
		{
            var defaultLinkValue=j$(this).prop('value');
            var rowElements=j$(this).closest('.createNewButtonOutsideHeader').find('.dropdown-menu').find('a');
            rowElements.each(function()
			{
                var buildingName=j$(this).closest('li').find('.buildingName').prop('value');
                var href=defaultLinkValue+buildingName;
                var rowElement=j$(this).prop('href', href).prop('target', '_blank');
            });
        });
    }
}

function processTimeZone()
{
    var objDetailsColDataElements=j$('.objectDetailsColumnData');
    
    objDetailsColDataElements.each(function()
	{
        var thisElement=j$(this);
        var colName=thisElement.data('th');
        if(colName=='Time Zone')
        {
            var tdChildContent=thisElement.find('.tdChildContent');
            
            if(tdChildContent.prop('innerText')==undefined || tdChildContent.prop('innerText').trim()=='' || tdChildContent.prop('innerText')==null
              || tdChildContent.prop('innerText')=='&nbsp;')
            {
                var oppLocSiteId=j$('.oppLocSiteId').val();
                var anchorElement='<a href="/'+oppLocSiteId+'/e?retURL=/apex/ALL_CloseSelfDonotReload&saveURL=/apex/ALL_CloseSelf"'
                +' target="_blank" class="underlinedLinks tdChildContent">Update</a>';
                
                tdChildContent.replaceWith(anchorElement);
            }
        }
    });
}

//Displaying Modal Content for Delete Confirmation.
function deleteConfirmationScreen(deleteIconElement)
{
    var objectDetailsComponentElement=j$(deleteIconElement).closest('.objectDetailsComponent');
    
    var objectLabel=objectDetailsComponentElement.find('.objectLabel').prop('value');
    var objectRecordType=objectDetailsComponentElement.find('.objectRecordType').prop('value');
    var objectAPIName=objectDetailsComponentElement.find('.objectAPIName').prop('value');
    
    var thisCompModalDialog=objectDetailsComponentElement.find('#modalDialog'+objectAPIName);
    
    //Title
    var titleToDisplay='<b>'+objectLabel;
    if(objectRecordType!=null && objectRecordType!='')
    {
        titleToDisplay+=' ('+objectRecordType+')</b>';
    }
    titleToDisplay+=' Delete Confirmation';
    thisCompModalDialog.find(".modal-title").html(titleToDisplay);
    
    //Body
    var objectIdToBeDeletedId=j$(deleteIconElement).closest('.objectDetailsRowData').find('.objectId').prop('value');
    
    var bodyElement='<input type="hidden" class="objectIdToBeDeletedId" value="'+objectIdToBeDeletedId+'"/>';
    bodyElement+='<p>Do you really want to delete this <b>'+objectLabel;
    if(objectRecordType!=null && objectRecordType!='')
    {
        bodyElement+=' ('+objectRecordType+')</b>';
    }
    bodyElement+='</b> record?</p>';
    thisCompModalDialog.find(".modal-body").html(bodyElement);
    
    //Footer
    var onclickAttribute="deleteObjectRecord(this);";
    var footerElement='<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>';
    footerElement+='<button type="button" class="btn btn-primary" onclick="'+onclickAttribute+'">Confirm Delete</button>';
    thisCompModalDialog.find(".modal-footer").html(footerElement);
}

//Performing validations on click of Confirm Delete Button of Modal and displaying error, success messages.
//And deleting the Object record.
function deleteObjectRecord(confirmButtonElement)
{
    var objectDetailsComponentElement=j$(confirmButtonElement).closest('.objectDetailsComponent');
    
    var objectIdToBeDeletedId=objectDetailsComponentElement.find('.objectIdToBeDeletedId').prop('value');
    var objectAPIName=objectDetailsComponentElement.find('.objectAPIName').prop('value');
    
    var messageDivElement=objectDetailsComponentElement.find('.messageDiv');
    messageDivElement.html('');
    messageDivElement.hide();
    
    var spinnerElement=objectDetailsComponentElement.find('.objDetSpinnerDiv');
    spinnerElement.modal('show');
    objectDetailsComponentElement.find('#modalDialog'+objectAPIName).modal('toggle');
    
    ALL_ObjectDetails_Controller.deleteObjectRecord(objectIdToBeDeletedId, objectAPIName, function(result, event)
	{
        if(event.status)
        {
            if(result=='')
            {
                var messageText='Record successfully deleted.';
                displayMessage('success', messageDivElement, messageText);
                spinnerElement.modal('hide');
                location.reload();
            }
            else
            {
                displayMessage('error', messageDivElement, 'Sorry, record could not be deleted, due to the some error. Please contact your System Administrator.');
                spinnerElement.modal('hide');
            }
        }
        else
        {
            displayMessage('error', messageDivElement, 'Sorry, record could not be deleted, due to the some error. Please contact your System Administrator.');
            spinnerElement.modal('hide');
        }
    });
}

//Processes error, info and success messages.
function displayMessage(scenario, messageDivElement, messageText)
{
    var alertMessage;
    if(scenario=='success')
    {
        alertMessage='<div class="alert alert-success" role="alert">'
        +'<strong>Success!</strong> ';
    }
    else if(scenario=='error')
    {
        alertMessage='<div class="alert alert-danger" role="alert">'
        +'<strong>Error!</strong> ';
    }
    
    alertMessage+=messageText;
    alertMessage+='</div>';
    
    messageDivElement.html(alertMessage);
    messageDivElement.show();
}

//2017-02-02- anirudh.singh@cdk.com- Added the below method.
function freezeTableHeaders()
{
    if(scrollTimer)
    {
        clearTimeout(scrollTimer);
    }
    scrollTimer=setTimeout(freezeHeaders, 500);
}

//2017-02-02- anirudh.singh@cdk.com- Added the below method.
function freezeHeaders()
{
    scrollTimer=null;
    var tableElement=j$('.objectDetailsComponent').find('.objectDetailsTable');
    
    if(tableElement.length>0)
    {
        var tableHeader=tableElement.find('thead');
        var tableHeaderTop=tableHeader.offset().top;
        
        j$(window).scroll(function()
        {
            var topSize=j$(window).scrollTop();
            var difference=tableHeaderTop-topSize;
            var tableHeight=(tableElement.height()+tableElement.offset().top)-40;
            
            if(difference<=0 && topSize<tableHeight)
            {
                var thWidths=[];
                var tableThs=tableHeader.find('th');
                tableThs.each(function()
                {
                    thWidths.push(j$(this).width());
                });
                
                var totalTopSize=50;
                tableHeader.css({
                    position: 'fixed',
                    top: totalTopSize
                });
                
                var rowTds=tableElement.find('tbody').find('tr:first').find('td');
                
                if(!j$(tableThs[0]).hasClass('widthSetForScroll'))
                {
                    for(var i=0; i<thWidths.length; i++)
                    {
                        j$(tableThs[i]).addClass('widthSetForScroll');
                        j$(rowTds[i]).addClass('widthSetForScroll');
                        j$(tableThs[i]).width(thWidths[i]);
                        j$(rowTds[i]).width(thWidths[i]);
                    }
                }
            }
            else
            {
                tableHeader.css({
                    position: 'static'
                });
            }
        });
    }
}