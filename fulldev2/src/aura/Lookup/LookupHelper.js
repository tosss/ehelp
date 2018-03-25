({
    getNewList : function(component,event,objectName,fieldAPIName,searchString) {
		var action = component.get("c.getSearchList");
        action.setParams({
            ObjectName :  objectName,
            NameField : fieldAPIName,
            searchString : searchString
        });
        action.setCallback(this, function(actionResult) {
            var actionResultList = actionResult.getReturnValue();
            var state = actionResult.getState();
            if(component.isValid() && state == "SUCCESS")
            {
                var cmpTarget = component.find('searchResult');
                if(actionResultList.length > 0)
                {
                    component.set("v.resultList", actionResult.getReturnValue());
                    $A.util.removeClass(cmpTarget, 'hide');
                    $A.util.addClass(cmpTarget, 'show');
                    cmpTarget = component.find("option");
                    $A.util.removeClass(cmpTarget, 'error');
                    
                }
                else
                {
                    component.set("v.resultList", [{Id:null,Name:"No Results Found"}]);
                    $A.util.removeClass(cmpTarget, 'hide');
                    $A.util.addClass(cmpTarget, 'show');
                    cmpTarget = component.find("option");
                    $A.util.addClass(cmpTarget, "error");
                }
            }
            else if(state != "SUCCESS")
            {
                if(component.get("hardware") !="DESKTOP")
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Failed!",
                        "message": "Unexpected Error"
                    });
                    toastEvent.fire();
                }
            }           
        });
        $A.enqueueAction(action);
	}

})