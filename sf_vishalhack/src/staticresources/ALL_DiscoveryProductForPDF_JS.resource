//2016-11-21- anirudh.singh@cdk.com- Created this JS for ALL_DiscoveryProductForPDF Visualforce Component.
var j$=jQuery.noConflict();

//Processing on Ready event of the document.
j$(document).ready(
    function()
    {
        j$('.pdfProductAtSiteComponent').each(function()
        {
            processProductAtSiteBodyForPDF(j$(this));
        });
    }
);

function processProductAtSiteBodyForPDF(productComponent)
{
    var inputRowElements=productComponent.find('.pdfTable').find('.bodyRow').find('input');
    
    inputRowElements.each(function()
	{
        var thisElement=j$(this);
        
        var productId=thisElement.data('productid');
        var prodName=thisElement.data('prodname');
        var dept=thisElement.data('dept');
        var otherDept=thisElement.data('otherdept');
        var workflow=thisElement.data('workflow');
        var otherWorkflow=thisElement.data('otherworkflow');
        var current=thisElement.data('current');
        var proposed=thisElement.data('proposed');
        var sold=thisElement.data('sold');
        var notes=thisElement.data('notes');
        
        var tdContent='<td class="tableData selectField">';
        if(productId!=null && productId!=undefined && productId!='')
        {
            tdContent+='<span><i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        else
        {
            tdContent+='<span><i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        tdContent+='</td>'
        +'<td class="tableData prodNameField">';
        
        if(prodName!=null && prodName!=undefined && prodName!='')
        {
            tdContent+=prodName;
        }
        tdContent+='</td>'
        +'<td class="tableData deptField">';
        
        if(dept!=null && dept!=undefined && dept!='')
        {
            tdContent+=dept;
        }
        else
        {
            tdContent+=otherDept;
        }
        tdContent+='</td>'
        +'<td class="tableData workflowField">';
        
        if(workflow!=null && workflow!=undefined && workflow!='')
        {
            tdContent+=workflow;
        }
        else
        {
            tdContent+=otherDept;
        }
        tdContent+='</td>'
        +'<td class="tableData currentCheckboxField">';
        
        if(current==true)
        {
            tdContent+='<span><i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        else
        {
            tdContent+='<span><i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        tdContent+='</td>'
        +'<td class="tableData proposedCheckboxField">';
        
        if(proposed==true)
        {
            tdContent+='<span><i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        else
        {
            tdContent+='<span><i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        tdContent+='</td>'
        +'<td class="tableData soldCheckboxField">';
        
        if(sold==true)
        {
            tdContent+='<span><i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        else
        {
            tdContent+='<span><i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i></span>';
        }
        tdContent+='</td>'
        +'<td class="tableData notesField">';
        
        if(notes==null || notes==undefined) 
        {
            notes='';
        }
        tdContent+='<span class="form-control pdfTextAreaField" value="'+notes+'"></span>'
        +'</td>';
        
        thisElement.closest('tr').append(tdContent);
        thisElement.remove();
    });
}