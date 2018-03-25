({
    getUpdatedList : function(component, event, helper) {
        var objectName = component.get("v.ObjectAPIName");
		var fieldAPIName = component.get("v.SearchFieldAPIName");
        var searchString = component.get("v.searchString");
        if((searchString != '') && (searchString != undefined))
        {
            helper.getNewList(component,objectName,fieldAPIName,searchString);
        }
	},
    selectedSobject : function(component, event, helper) {
        var cmpTarget = component.find('searchResult');
    	$A.util.addClass(cmpTarget, 'hide');
    	$A.util.removeClass(cmpTarget, 'show');
        var sourceElement = event.target;
        component.set("v.selectedId",sourceElement.getAttribute('id'));
        component.set("v.selectedName",sourceElement.getAttribute('name'));
        component.set("v.searchString",sourceElement.getAttribute('name'));
	},
    saveTaskC : function(component, event, helper)
    {
        var action = component.get("c.saveTask");
        var task = component.get("v.task");
        action.setParams({
            task:task
        });
        action.setCallback(this, function(actionResult) {
            var actionResultList = actionResult.getReturnValue();
            if(component.isValid())
            {
                 console.log(actionResult);
            }
                        
        });
        $A.enqueueAction(action);
    }
})