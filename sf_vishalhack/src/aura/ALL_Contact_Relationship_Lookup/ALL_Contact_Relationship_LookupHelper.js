({
    getNewList : function(component,event,objectName,fieldAPIName,searchString) 
    {
        var searchIcon = component.find("searchIcon");
        var loadingIcon = component.find("loadingIcon");
        $A.util.addClass(searchIcon, 'hide');
        $A.util.removeClass(loadingIcon, 'hide');
        var action = component.get("c.getContactRelationshipSearchList");
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
                if(actionResultList.length == 1)
                {
                    component.set("v.accountId",actionResultList[0]['Account__c']);
                    component.set("v.contactId",actionResultList[0]['Contact__c']);
                    component.set("v.selectedName",actionResultList[0]['Contact__r']['Name']+' - '+actionResultList[0]['Account_r']['Name']);          
                    component.set("v.selectedString",actionResultList[0]['Contact__r']['Name']+' - '+actionResultList[0]['Account_r']['Name']);    
                }
                else if(actionResultList.length > 0)
                {
                    component.set("v.resultList", actionResult.getReturnValue());
                    jQuery(cmpTarget.elements[0]).css("display","block");
                    cmpTarget = component.find("option");
                    $A.util.removeClass(cmpTarget, 'error');
                    
                }
                else
                {
                    component.set("v.resultList", [{Id:null,Contact__r:{Name : "No Results Found"},Account__r : {Name : null}}]);
                    jQuery(cmpTarget.elements[0]).css("display","block");
                    cmpTarget = component.find("option");
                    $A.util.addClass(cmpTarget, "error");
                }
            }
            else if(state != "SUCCESS")
            {
                if(component.get("hardware") !="DESKTOP")
                {
                    console.log(actionResult);
                }
            } 
            $A.util.removeClass(searchIcon, 'hide');
            $A.util.addClass(loadingIcon, 'hide');
        });
        $A.enqueueAction(action);
    },
    
    selectedSobjectHelper : function(component,event)
    {
        var cmpTarget = component.find('searchResult');
        jQuery(cmpTarget.elements[0]).css("display","none");
        var sourceElement = event.target;
        var name = sourceElement.getAttribute('name');
        if(name!= "No Results Found")
        {
            component.set("v.accountId",sourceElement.getAttribute('id').substr(0,18));
            component.set("v.contactId",sourceElement.getAttribute('id').substr(19,36));
            component.set("v.selectedName",sourceElement.getAttribute('name'));
            component.set("v.searchString",sourceElement.getAttribute('name')); 
        }
        else
        {
            component.set("v.accountId",null);
            component.set("v.contactId",null);
            component.set("v.selectedName",null);
            component.set("v.searchString",null); 
        }
        
        component.set("v.resultList",[]);
    },
    
    enterKeyPressedHelper : function(component,event,helper)
    {
        var searchString = component.get("v.searchString");
        if((searchString != '') && (searchString != undefined))
        {
            if(event.getParams().keyCode == 13)
            {
                var objectName = component.get("v.objectAPIName");
                var fieldAPIName = component.get("v.searchFieldAPIName");
                var searchName = component.set("v.selectedName");
                helper.getNewList(component,event,objectName,fieldAPIName,searchString);
            }
        }
    },
    
    updateValuesHelper : function(component,event)
    {
        var searchIcon = component.find("searchIcon");
        var loadingIcon = component.find("loadingIcon");
        $A.util.addClass(searchIcon, 'hide');
        $A.util.removeClass(loadingIcon, 'hide');
        var objectName = component.get("v.objectAPIName");
        var fieldAPIName = component.get("v.searchFieldAPIName");
        var searchString = component.get("v.searchString");
        if(searchString != '' && searchString != null && searchString != undefined)
        {
            var cmpTarget = component.find('searchResult');
            jQuery(cmpTarget.elements[0]).css("display","none"); 
            var action = component.get("c.getContactRelationshipSearchList");
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
                        component.set("v.accountId",actionResultList[0]['Account__c']);
                        component.set("v.contactId",actionResultList[0]['Contact__c']);
                        component.set("v.selectedName",actionResultList[0].Contact__r.Name+' - '+actionResultList[0].Account__r.Name);          
                        component.set("v.searchString",actionResultList[0].Contact__r.Name+' - '+actionResultList[0].Account__r.Name);    
                    }
                    else
                    {
                        component.set("v.accountId",null);
                        component.set("v.contactId",null);
                        component.set("v.selectedName",null);
                        component.set("v.searchString",null); 
                    }
                }
                $A.util.removeClass(searchIcon, 'hide');
                $A.util.addClass(loadingIcon, 'hide');
            });
            $A.enqueueAction(action);
        }
    },
    
    getUpdatedListHelper : function(component,event,helper)
    {
        var searchString = component.get("v.searchString");
        if((searchString != '') && (searchString != undefined))
        {
            var objectName = component.get("v.objectAPIName");
            var fieldAPIName = component.get("v.searchFieldAPIName");
            helper.getNewList(component,event,objectName,fieldAPIName,searchString);
        }
    }
    
})