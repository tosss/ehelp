({
    getUpdatedList : function(component, event, helper) {
        var objectName = component.get("v.objectAPIName");
		var fieldAPIName = component.get("v.searchFieldAPIName");
        var searchString = component.get("v.searchString");
        if((searchString != '') && (searchString != undefined))
        {
            helper.getNewList(component,event,objectName,fieldAPIName,searchString);
        }
	},
    checkEnterKey : function(component,event,helper)
    {
        var searchString = component.get("v.searchString");
        if((searchString != '') && (searchString != undefined))
        {
            if(event.getParams().keyCode == 13)
            {
                var objectName = component.get("v.objectAPIName");
                var fieldAPIName = component.get("v.searchFieldAPIName");
                var searchName = component.set("v.selectedName");
                helper.getNewList(component,event,helper,objectName,fieldAPIName,searchString);
            }
        }
    },
    selectedSobject : function(component, event, helper) {
        var cmpTarget = component.find('searchResult');
    	$A.util.addClass(cmpTarget, 'hide');
    	$A.util.removeClass(cmpTarget, 'show');
        var sourceElement = event.target;
        var name = sourceElement.getAttribute('name');
        if(name!= "No Results Found")
        {
            component.set("v.selectedId",sourceElement.getAttribute('id'));
            component.set("v.selectedName",sourceElement.getAttribute('name'));
            component.set("v.searchString",sourceElement.getAttribute('name')); 
        }
        else
        {
            component.set("v.selectedId",null);
            component.set("v.selectedName",null);
            component.set("v.searchString",null); 
        }
        
        component.set("v.resultList",[]);
	},
    updateValues : function(component, event, helper)
    {
        component.set("v.selectedName",null);
        component.set("v.selectedId",null);
    }
})