({
    getNewList : function(component,event,helper,objectName,fieldAPIName,searchString) {
		helper.showSpinner(component, event, helper);
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
                    helper.hideSpinner(component, event, helper);
                }
                else
                {
                    component.set("v.resultList", [{Id:null,Name:"No Results Found"}]);
                    $A.util.removeClass(cmpTarget, 'hide');
                    $A.util.addClass(cmpTarget, 'show');
                    cmpTarget = component.find("option");
                    $A.util.addClass(cmpTarget, "error");
                    helper.hideSpinner(component, event, helper);
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
                    helper.hideSpinner(component, event, helper);
                }
            }           
        });
        $A.enqueueAction(action);
	},
    showSpinner: function(component, event, helper)
    {
        var spinner=component.find("spinnerLookup");
        console.log('---->'+spinner);
        $A.util.removeClass(spinner, "noDisplayLookupSpinner");
    },
    hideSpinner: function(component, event, helper)
    {
        var spinner=component.find("spinnerLookup");
        $A.util.addClass(spinner, "noDisplayLookupSpinner");
    }

})