({
    doInit : function(component, event, helper) {
        var selectedId = component.get("v.selectedId");
        console.log(selectedId);
        if(selectedId && selectedId != null && (selectedId.length ==15 || selectedId.length == 18))
        {
            var objectName = component.get("v.objectAPIName");
            var fieldAPIName = component.get("v.searchFieldAPIName");
            var action = component.get("c.getName");
            action.setParams({
                ObjectName :  objectName,
                NameField : fieldAPIName,
                selectedId : selectedId
            });
            console.log(selectedId,objectName,fieldAPIName);
            action.setCallback(this, function(actionResult) {
                var actionResultValue= actionResult.getReturnValue();
                var state = actionResult.getState();
                if(component.isValid() && state == "SUCCESS")
                {
                    component.set("v.selectedName",actionResultValue);
                    component.set("v.searchString",actionResultValue);  
                    component.set("v.valueUpdated",true);
                }
            });
            $A.enqueueAction(action);
        }
    },
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
            component.set("v.valueUpdated",true);
        });
        $A.enqueueAction(action);
	},
    
    updateValuesHelper : function(component,event,helper)
    {
        var objectName = component.get("v.objectAPIName");
        var fieldAPIName = component.get("v.searchFieldAPIName");
        var searchString = component.get("v.searchString");
        var results = component.get("v.resultList");
        if(searchString != '' && searchString != null && searchString != undefined)
        {
            var cmpTarget = component.find('searchResult');
            jQuery(cmpTarget.elements[0]).css("display","none"); 
            var searchIcon = component.find("searchIcon");
            var loadingIcon = component.find("loadingIcon");
            $A.util.addClass(searchIcon, 'hide');
            $A.util.removeClass(loadingIcon, 'hide');
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
                    if(actionResultList.length == 1 )
                    {
                        component.set("v.selectedId",actionResultList[0]["Id"]);
                        component.set("v.selectedName",actionResultList[0][fieldAPIName]);          
                        component.set("v.selectedString",actionResultList[0][fieldAPIName]);  
                        cmpTarget = component.find("option");
                        $A.util.removeClass(cmpTarget, 'error');    
                    }
                    else if(actionResultList.length > 1)
                    {
                        component.set("v.resultList", actionResult.getReturnValue());
                        jQuery(cmpTarget.elements[0]).css("display","block");
                        cmpTarget = component.find("option");
                        $A.util.removeClass(cmpTarget, 'error');  
                    }
                }
                $A.util.removeClass(searchIcon, 'hide');
                $A.util.addClass(loadingIcon, 'hide');
                component.set("v.valueUpdated",false);
            });
            $A.enqueueAction(action);
        }
        else
        {
            var cmpTarget = component.find('searchResult');
            jQuery(cmpTarget.elements[0]).css("display","none");
        }
    }

})