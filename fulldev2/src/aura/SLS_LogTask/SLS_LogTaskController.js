({
	setup : function(component, event, helper) {
		jQuery(".slds-grid ").show();
	},
    saveTaskControllerJS : function(component, event, helper)
    {
        var task = component.get("v.task");
        console.log(task);
        var action = component.get("c.saveTask");
        action.setParams({
            task:task
        });
        action.setCallback(this, function(actionResult) {
            var actionResultList = actionResult.getReturnValue();
            if(component.isValid())
            {
                 console.log(actionResult);
            }
                        
        });
        $A.enqueueAction(action);
    }
})