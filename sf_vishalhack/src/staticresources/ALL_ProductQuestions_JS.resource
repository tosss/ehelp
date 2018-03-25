//2016-10-19- anirudh.singh@cdk.com- Created this for Questions Tab for Products.
var j$=jQuery.noConflict();

j$(document).ready(
    function()
    {
        processOnLoad();
    }
);

function processOnLoad()
{
    highlightSelectedSideBarTab();
    
    j$('#prodQuesSpinnerDiv').modal('hide');
    
    // 2016-10-24 matt.keefe@cdk.com - added sidebar position updating with scroll/resize, matches productQuestionsQuesAnsDiv top
    j$(window).scroll(windowScrollOrResize).resize(windowScrollOrResize);
}

// 2016-10-24 matt.keefe@cdk.com - added adjust function
function windowScrollOrResize()
{
    // adjust sidebar location
    var sidebarPosTop = j$(".productQuestionsComponent .productQuestionsQuesAnsDiv").offset().top;
    if(j$(window).scrollTop() > sidebarPosTop)
    {
        j$(".productQuestionsComponent .sideBar").css({top: 50});
    }
    else
    {
        j$(".productQuestionsComponent .sideBar").css({top: sidebarPosTop});
    }  
}

function addParameterToURL(element)
{
    var deptWorkflowName;
    if(j$(element).prop('value')==undefined)
    {
        deptWorkflowName=j$(element).prop('text');
    }
    else
    {
        deptWorkflowName=j$(element).prop('value');
    }
    
    var indexOfTabName=window.location.href.indexOf('&deptWorkflowName=');
    
    if(history.pushState)
    {
        var newurl;
        if(indexOfTabName==-1)
        {
            newurl=window.location.href+'&deptWorkflowName='+encodeURIComponent(deptWorkflowName);
            window.history.pushState({path:newurl}, '', newurl);
        }
        else
        {
            newurl=window.location.href.substring(0, indexOfTabName);
            newurl=newurl+'&deptWorkflowName='+encodeURIComponent(deptWorkflowName);
            window.history.pushState({path:newurl}, '', newurl);
        }
    }
    
    window.location.reload();
}

function highlightSelectedSideBarTab()
{
    var selectedDeptWorkflowValue=j$('#selectedDeptWorkflowValue').attr('value');
    
    j$('.sideBarButton').each(function()
	{
        if(j$(this).attr('value')==selectedDeptWorkflowValue)
        {
            j$(this).attr('style', 'background-color: #00C389; color: white;');
        }
        else
        {
            j$(this).attr('style', 'background-color: transparent; color: #337ab7;');
        }
    });
    
    j$('html,body').scrollTop(0);
}

function showProdQuesSpinnerDiv()
{
    j$('#prodQuesSpinnerDiv').modal('show');
}

function hideProdQuesSpinnerDiv()
{
    j$('#prodQuesSpinnerDiv').modal('hide');
}