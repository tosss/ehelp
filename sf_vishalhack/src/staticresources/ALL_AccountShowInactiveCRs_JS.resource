//2016-07-28 - lalitha.adduru@cdk.com - created this resoure for a new button to hide or show inactive CRs - RQ-07242
//2016-08-01 - lalitha.adduru@cdk.com - added some more functionality
//2016-08-05 - lalitha.adduru@cdk.com - added functionality for 'Show More' link
//2016-08-09 - lalitha.adduru@cdk.com - added code to prevent event propagation

var j$ = jQuery.noConflict();
var count = 0;
var recordTable;
var recordList;
var statusIndex;
var showMoreLink;
var recordListSize;
var showMoreIsClicked=0;
j$(document).ready(function()
{
    	recordTable = j$('[name=new_shared_contact]').closest('.listRelatedObject').contents().contents()[1];
    	if(recordTable != undefined && recordTable != null)
        {
            var headerRow = j$(recordTable).find('.list').find('tr.headerRow');
            var headerRowColumns = j$(recordTable).find('.list').find('tr.headerRow').find('th');
            j$.each( headerRowColumns, function( index, value ) 
            {
                if(j$(value).text() == 'Status')
                {
                    statusIndex = j$(value).index();
                }
            });
            statusIndex = statusIndex-1;
            onPageLoad('Show Active & Inactive');
            showMoreLink = j$(recordTable).find('.pShowMore').find('a')[0]; 
            if(showMoreLink != undefined && showMoreLink != null)
            {
                 //console.log('show more link ' +showMoreLink);
                j$(showMoreLink).addClass('showMoreClass');}
        }
});

j$(document).on('mouseover', 'div', function(e) {
    if(j$(e.target).attr('class') == 'listTitle')
    {
    	//console.log(j$(e.target).html());
     	onPageLoad('Show Active & Inactive');
    }
});


function onPageLoad(label)
{
	// display only active CRs when page is loaded
    recordTable = j$('[name=new_shared_contact]').closest('.listRelatedObject').contents().contents()[1];
    recordList = j$(recordTable).find('.list').find('tr.dataRow');
    //console.log('on page load --> '+recordList.length);
    //console.log(j$(recordTable).find('.list tr.dataRow'));
    recordListSize = recordList.length;
    if(recordList.length != 0)
    {
    	// insert a new button beside New Shared Contact button
    	count = 0;
    	var td =j$('[name=new_shared_contact]').closest('td');
    	td.css("width","20");
        //console.log('toggle button  --> '+j$('[name=new_shared_contact]').closest('tr').find('input[name=Show_Inactive_Active_Toggle]').length);
        //console.log(j$('[name=new_shared_contact]').closest('tr').find('input[name=Show_Inactive_Active_Toggle]').prop('value'));
        if(j$('[name=new_shared_contact]').closest('tr').find('input[name=Show_Inactive_Active_Toggle]').length == 0)
        {
            //console.log('button not present');
            j$('<td><input value="'+label+'" class="btn" style="padding-top:2px;padding-bottom:2px" name="Show_Inactive_Active_Toggle" type="button"></input></td>').insertAfter(td);
        	//console.log('button inserted');
        }
        else if(j$('[name=new_shared_contact]').closest('tr').find('input[name=Show_Inactive_Active_Toggle]').prop('value') != label)
        {
            j$('[name=new_shared_contact]').closest('tr').find('input[name=Show_Inactive_Active_Toggle]').prop('value',label);
        }
    	j$.each(recordList, function(index, row)
    	{
        	var statusColumn = j$(row).find('td:eq('+statusIndex+')');
        	var status = j$(statusColumn).text();
        	//console.log(status);
        	if(status == 'Inactive')
        	{
            	j$(row).hide();
                count = count+1;
        	}
        	// add no row header when there are no records(active) to display
        	if( count == recordList.length)
        	{
           		var pallette = j$('[name=new_shared_contact]').closest('.listRelatedObject').contents()[0];
            	j$(recordTable).hide();  
            	j$(pallette).append('<div class="pbBody"><table name = Empty_Table  class="list" border="0" cellspacing="0" cellpadding="0"><tbody><tr class="headerRow"><th scope="col" style="border-left-width:0" class="noRowsHeader">No records to display</th></tr></tbody></table></div>');
        	}
    	});
    	showMoreLink = j$(recordTable).find('.pShowMore').find('a')[0]; 
        if(showMoreLink != undefined && showMoreLink != null)
        {
            //console.log(showMoreLink);
            j$(showMoreLink).addClass('showMoreClass');
        }
    }        
}

j$(document).on('click', '[name=Show_Inactive_Active_Toggle]', function(event)
{
    		event.stopPropagation();
    		recordTable = j$('[name=new_shared_contact]').closest('.listRelatedObject').contents().contents()[1];
            recordList = j$(recordTable).find('.list').find('tr.dataRow');
            //console.log('in button click');
            //console.log('count '+count);
            //console.log('record list length '+recordList.length);
        	if(count==recordList.length)
        	{
            	j$(recordTable).show();
            	j$('[name=Empty_Table]').hide();
        	}
        	if(j$(this).val() == 'Show Active & Inactive')
        	{
            	j$(this).val('Show Active Only');
            	j$.each(recordList, function(index, row)
                {
        			var statusColumn = j$(row).find('td:eq('+statusIndex+')');
        			var status = j$(statusColumn).text();
        			if(status == 'Inactive')
        			{
            			j$(row).show();
            		}});
        	}
        	else
        	{
            	count = 0;
            	j$(this).val('Show Active & Inactive');
				j$.each(recordList, function(index, row)
    			{
        			var statusColumn = j$(row).find('td:eq('+statusIndex+')');
        			var status = j$(statusColumn).text();
        			if(status == 'Inactive')
        			{
            			j$(row).hide();
                		count++;               
        			}
            	});
            	if(count == recordList.length)
        		{
            		var pallette = j$('[name=new_shared_contact]').closest('.listRelatedObject').contents()[0];
            		j$(recordTable).hide();  
            		j$(pallette).append('<div class="pbBody"><table name = Empty_Table  class="list" border="0" cellspacing="0" cellpadding="0"><tbody><tr class="headerRow"><th scope="col" style="border-left-width:0" class="noRowsHeader">No records to display</th></tr></tbody></table></div>');      
        		}
        	}        
        });

j$(document).on('click', '.showMoreClass', function(event)
{
    				showMoreIsClicked = 1;
                    var tempListSize = recordListSize;
                    //event.stopPropagation();
                    //console.log('link is clicked');
    				j$('.progress-wrapper').show();
                    var temp =setInterval(function(){
                        recordTable = j$('[name=new_shared_contact]').closest('.listRelatedObject').contents().contents()[1];
                        recordList = j$(recordTable).find('.list').find('tr.dataRow');
                        //console.log('record length '+recordList.length);
                        if(recordList.length > recordListSize)
                        {
                            onPageLoad('Show Active & Inactive');
                            clearInterval(temp);
                            j$('.progress-wrapper').hide();
                            //console.log('finished');
                        }
                    }, 500);
});
  