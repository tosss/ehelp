({
    doInit : function(component, event,helper) {
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
            action.setCallback(this, function(actionResult) {
                var actionResultValue= actionResult.getReturnValue();
                var state = actionResult.getState();
                if(component.isValid() && state == "SUCCESS")
                {
                    component.set("v.selectedName",actionResultValue);
                    component.set("v.searchString",actionResultValue);  
                    component.set("v.valueUpdated",true);
                }
                 console.log(actionResultValue);
            });
            $A.enqueueAction(action);
        }
    },
    getUpdatedList : function(component, event, helper) {
        var searchString = component.get("v.searchString");
        if((searchString != '') && (searchString != undefined))
        {
            var searchIcon = component.find("searchIcon");
            var loadingIcon = component.find("loadingIcon");
            $A.util.addClass(searchIcon, 'hide');
            $A.util.removeClass(loadingIcon, 'hide');
            var objectName = component.get("v.objectAPIName");
            var fieldAPIName = component.get("v.searchFieldAPIName");
            component.set("v.valueUpdated",false);
            helper.getNewList(component,event,objectName,fieldAPIName,searchString);
        }
    },
    checkEnterKey : function(component,event,helper)
    {
        var searchString = component.get("v.searchString");
        component.set("v.valueUpdated",false);
        if((searchString != '') && (searchString != undefined))
        {
            if(event.getParams().keyCode == 13)
            {
                var searchIcon = component.find("searchIcon");
                var loadingIcon = component.find("loadingIcon");
                $A.util.addClass(searchIcon, 'hide');
                $A.util.removeClass(loadingIcon, 'hide');
                helper.updateValuesHelper(component, event, helper);
            }
        }
    },
    selectedSobject : function(component, event, helper) {
        var cmpTarget = component.find('searchResult');
        jQuery(cmpTarget.elements[0]).css("display","none");
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
            component.set("v.valueUpdated",false);
        
        component.set("v.resultList",[]);
    },
    emptyValues : function(component, event, helper) {
        var currentvalue = component.get("v.selectedName");
        var searchString = component.get("v.searchString");
        var resultList = component.get("v.resultList");
        if(currentvalue != searchString && resultList.length == 0)
        { 
            var searchIcon = component.find("searchIcon");
            var loadingIcon = component.find("loadingIcon");
            $A.util.addClass(searchIcon, 'hide');
            $A.util.removeClass(loadingIcon, 'hide');
            var objectName = component.get("v.objectAPIName");
            var fieldAPIName = component.get("v.searchFieldAPIName");
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
                        component.set("v.selectedId",null);
                        component.set("v.selectedName",null);
                        component.set("v.searchString",null); 
                    }
                }
                $A.util.removeClass(searchIcon, 'hide');
                $A.util.addClass(loadingIcon, 'hide');
                component.set("v.valueUpdated",false);
                component.set("v.resultList",[]);
            });
            $A.enqueueAction(action);
        }
        
    }
})