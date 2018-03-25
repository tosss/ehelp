//2017-04-05 lalitha.adduru@cdk.com - created this resource to toggle black flag statuses on the Top5 records -RQ-08902
var j$ = jQuery.noConflict();
var statusIndex;
var buttonLabel ='Hide Black Flags';
var blackFlagImageId = '';

j$(document).ready(function(){
    SLS_Top5List_Controller.getBlackFlagImageId(function(result, event){   
        blackFlagImageId = String(result).substr(0,15);
    });
});

// a new resource arrive.js is being used to wait for elements until they arrive to register events or operations on them
j$(document).arrive('.paginator', function(){
    console.log(j$('.selectorTarget').not('.selectCount'));
    j$('.selectorTarget').not('.selectCount').attr('disabled','disabled');
    j$('.selectorTarget').not('.selectCount').css('cursor','default');
    j$(j$('.selectorTarget').not('.selectCount').find('.selectArrow')).css('display','none');
    j$('.selectorTarget').not('.selectCount').css('pointer-events','none');
});

j$(document).arrive('.x-grid3-header',function(){      
    // find the column index in which Status field is stored
    var headerColumns = j$(j$(j$('.x-grid3-header')[0]).find('.x-grid3-hd-row')).find('td');
    for(var i=0; i<headerColumns.length ; i++)
    {
        if(j$(j$(headerColumns[i]).children()).attr('title') == 'Status')
        {
            statusIndex = i;
        }
    }
});


j$(document).on('click', '.x-grid3-hd.x-grid3-cell, .lastItem', function(a){ 
    if(buttonLabel == 'Show All Statuses')
    {  
        j$('.progress-wrapper').show();
        setTimeout(function(){
            var recordRows = j$(j$('.x-grid3-scroller')).find('tr'); 
            showOrHideBlackFlagRows(recordRows, 'hide');
            j$('.progress-wrapper').hide();
        }, 3000);
    }
});

function showOrHideBlackFlagButtonClicked(a)
{ 
    var recordRows = j$(j$('.x-grid3-scroller')).find('tr');
    var label = a.value;
    if(label == 'Hide Black Flags')
    {
        j$(a).attr('value','Show All Statuses');
        buttonLabel = 'Show All Statuses';
        showOrHideBlackFlagRows(recordRows, 'hide');
    }
    else
    {
        j$(a).attr('value','Hide Black Flags');
        buttonLabel = 'Hide Black Flags';
        showOrHideBlackFlagRows(recordRows, 'show');
    }
    
}

function showOrHideBlackFlagRows(recordRows, hideOrShow)
{
    for(var i=0; i<recordRows.length ; i++)
    {
        var source = j$(j$(j$(recordRows[i]).find('td:eq('+statusIndex+')')).find('img')).attr('src');
        var imageId = String(source).split('=')[1];
        if(imageId!= undefined && (imageId === blackFlagImageId))
        {
            if(hideOrShow === 'hide')
            {
                j$(j$(recordRows[i]).closest('.x-grid3-row')).attr('style', 'display: none');
            }
            else if(hideOrShow === 'show')
            {
                j$(j$(recordRows[i]).closest('.x-grid3-row')).attr('style', 'display: block');
            }
        }
    }
}