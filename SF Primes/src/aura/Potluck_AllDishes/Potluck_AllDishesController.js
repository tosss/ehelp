({
	doInit : function(component, event, helper) {
		var action = component.get("c.getALLDishes");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) 
            {
                component.set("v.dishesList", response.getReturnValue()); 
            }
        });                
        $A.enqueueAction(action);
	}
})