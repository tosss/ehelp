//2016-11-21- anirudh.singh@cdk.com- Created this JS for ALL_ObjectDetailsForPDF Visualforce Component.
var j$=jQuery.noConflict();

//Processing on Ready event of the document.
j$(document).ready(
    function()
    {
        j$('.objectDetailsComponent').each(function()
		{
            processObjDetailsHeaderForPDF(j$(this));
            
            removeHyperLinksObjDetailsPDF(j$(this));
            
            processObjDetailsBodyForPDF(j$(this));
        });
        
        addDataTHToColumns();
    }
);

function processObjDetailsHeaderForPDF(objectDetailsComponent)
{
    var headerElement=objectDetailsComponent.find('.objectDetailsHeader');
    var headerVal=headerElement.find('input').val();
    
    headerElement.prop('innerText', headerVal);
}

function removeHyperLinksObjDetailsPDF(objectDetailsComponent)
{
    var anchorElements=objectDetailsComponent.find('.objectDetailsTable').find('a');
    anchorElements.each(function()
    {
        var innerText=j$(this).prop('innerText');
        var spanElement=j$('<span></span>').text(innerText);
        j$(this).replaceWith(spanElement);
    });
}

function processObjDetailsBodyForPDF(objectDetailsComponent)
{
    var objectDetailsContent=objectDetailsComponent.find('.objectDetailsContent');
    var objectDetailsContentInput=objectDetailsContent.find('input');
    var columnNamesList=objectDetailsContentInput.data('columnnameslist').replace('[', '').replace(']', '').split(',');
    var noOfRowsToDisplay=objectDetailsContentInput.data('noofrowstodisplay');
    
    var tableElement=objectDetailsComponent.find('.objectDetailsTable');
    var tableLastRow=tableElement.find('tr:last');
    var firstTd=tableLastRow.find('td:first');
    
    var startNo=0;
    var endNo=10;
    if(firstTd.prop('innerText')!=undefined)
    {
        var lastRowIndexNo=parseInt(firstTd.prop('innerText'))
        startNo=startNo+lastRowIndexNo;
        endNo=endNo+lastRowIndexNo;
    }
    
    var rowElement='';
    for(var i=startNo; i<endNo; i++)
    {
        rowElement+='<tr class="objectDetailsRowData">'
        +'<td class="alignCenter itemNoColumn">'+(i+1)+'</td>';
        
        j$.each(columnNamesList, function(index, value)
        {
            rowElement+='<td class="objectDetailsColumnData"></td>';
        });
        rowElement+='</tr>';
    }
    
    if(firstTd.prop('innerText')!=undefined)
    {
        tableLastRow.after(rowElement);
    }
    else
    {
        tableElement.append(rowElement);
    }
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
    });
}