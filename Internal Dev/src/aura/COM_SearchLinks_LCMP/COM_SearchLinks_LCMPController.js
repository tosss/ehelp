({
	doInit: function(component) {
    
        var action = component.get("c.searchLinks");
        console.log('component.get("v.searchText") ',component.get("v.searchTerm") );
        action.setParams({
            searchText: component.get("v.searchTerm")     
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()',response.getReturnValue());
                component.set("v.searchresults", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }})