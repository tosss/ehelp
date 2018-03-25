({
    ToggleCollapseHandler : function(component, event) {  
        
        var existingText = component.get("v.collapseStyle");
        var container = component.find("containerCollapsable");
        var sampletest = component.get("v.collapseText");
        var container1 = component.find("collapseText");
        
        if(existingText.includes("fa-li fa fa-chevron-circle-down"))
        {        
            $A.util.removeClass(container1, 'expandCollapse fa-li fa fa-chevron-circle-down'); 
            $A.util.addClass(container1,'expandCollapse fa-li fa fa-chevron-circle-right');
            $A.util.addClass(container, 'hide');
        }
        else
        {
            $A.util.removeClass(container, 'hide'); 
            $A.util.removeClass(container1, 'expandCollapse fa-li fa fa-chevron-circle-right'); 
            $A.util.addClass(container1,'expandCollapse fa-li fa fa-chevron-circle-down');
        }  
    }
    
})