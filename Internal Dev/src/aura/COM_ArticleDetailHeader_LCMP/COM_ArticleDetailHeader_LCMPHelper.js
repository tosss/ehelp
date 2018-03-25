({
    articleEditAccess: function(component, event, helper) {
        var action = component.get("c.articleEditAccess");        
        action.setCallback(this, function(response) {
            var state = response.state;            
            if (state === "SUCCESS") {
                component.set("v.articleEditAccess", response.returnValue);
            }
        });
        $A.enqueueAction(action);
    }
})