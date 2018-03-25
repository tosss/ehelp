({
    getUpdatedList : function(component, event, helper) {
        var searchString = component.get("v.searchString");
        var searchIcon = component.find("searchIcon");
        var loadingIcon = component.find("loadingIcon");
        $A.util.addClass(searchIcon, 'hide');
        $A.util.removeClass(loadingIcon, 'hide');
        var objectName = component.get("v.objectAPIName");
        var fieldAPIName = component.get("v.searchFieldAPIName");
        helper.getNewList(component,event,objectName,fieldAPIName,searchString);
    },
    checkEnterKey : function(component,event,helper)
    {
        var searchString = component.get("v.searchString");
        if(event.getParams().keyCode == 13)
        {
            var searchIcon = component.find("searchIcon");
            var loadingIcon = component.find("loadingIcon");
            $A.util.addClass(searchIcon, 'hide');
            $A.util.removeClass(loadingIcon, 'hide');
            var objectName = component.get("v.objectAPIName");
            var fieldAPIName = component.get("v.searchFieldAPIName");
            var searchName = component.set("v.selectedName");
            helper.getNewList(component,event,objectName,fieldAPIName,searchString);
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
        
        component.set("v.resultList",[]);
	},
    updateValues : function(component, event, helper)
    {
        var objectName = component.get("v.objectAPIName");
		var fieldAPIName = component.get("v.searchFieldAPIName");
        var searchString = component.get("v.searchString");
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
                    if(actionResultList.length == 1)
                    {
                        component.set("v.selectedId",actionResultList[0]["Id"]);
                        component.set("v.selectedName",actionResultList[0][fieldAPIName]);          
                        component.set("v.selectedString",actionResultList[0][fieldAPIName]);    
                    }
                    else
                    {
                        component.set("v.selectedId",null);
                        component.set("v.selectedName",null);
                        component.set("v.searchString",null); 
                    }
                }
                $A.util.removeClass(searchIcon, 'hide');
                $A.util.addClass(loadingIcon, 'hide');
            });
            $A.enqueueAction(action);
        }
    }
})