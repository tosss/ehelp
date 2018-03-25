({
	doInit : function(component, event, helper) {
        var action = component.get("c.getGroupsForCurrentUser");
        action.setParams({ CommunityNetworkId : component.get('v.CommunityNetworkId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseValue = response.getReturnValue();
                component.set("v.groupList",responseValue);
                
            }
        });
        $A.enqueueAction(action);
	}
})