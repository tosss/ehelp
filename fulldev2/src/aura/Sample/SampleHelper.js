({
    getNewList : function(component,objectName,fieldAPIName,searchString) {
		var action = component.get("c.getSearchList");
        action.setParams({
            ObjectName :  objectName,
            NameField : fieldAPIName,
            searchString : searchString
        });
        action.setCallback(this, function(actionResult) {
            var actionResultList = actionResult.getReturnValue();
            if(component.isValid())
            {
                var cmpTarget = component.find('searchResult');
                if(actionResultList.length > 0)
                {
                    component.set("v.resultList", actionResult.getReturnValue());
                    $A.util.removeClass(cmpTarget, 'hide');
                    $A.util.addClass(cmpTarget, 'show');
                }
                else
                {
                    $A.util.addClass(cmpTarget, 'hide');
                    $A.util.removeClass(cmpTarget, 'show');
                }
            }
                        
        });
        $A.enqueueAction(action);
	}

})