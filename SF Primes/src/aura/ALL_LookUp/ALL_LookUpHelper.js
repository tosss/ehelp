({
    getNewList : function(component,event,objectName,fieldAPIName,searchString) {
        var searchIcon = component.find("searchIcon");
        var loadingIcon = component.find("loadingIcon");
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
                    jQuery(cmpTarget.elements[0]).css("display","block");
                    cmpTarget = component.find("option");
                    $A.util.removeClass(cmpTarget, 'error');
                    
                }
                else
                {
                    component.set("v.resultList", [{Id:null,Name:"No Results Found"}]);
                    jQuery(cmpTarget.elements[0]).css("display","block");
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
            $A.util.removeClass(searchIcon, 'hide');
            $A.util.addClass(loadingIcon, 'hide');
        });
        $A.enqueueAction(action);
	}

})