({
	doInit : function(component, event, helper) {
		var action = component.get("c.getCurrentAttendee");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()!=null ) 
            {
                component.set("v.currentAttendee", response.getReturnValue()); 
            }
            else
            {
                component.set("v.currentAttendee", {});
                var element = component.find("messageBox");
                $A.util.removeClass(element,"hide");
                $A.util.addClass(element,"show");
                component.set("v.message","Please give your details to perform other operations.");
                element = component.find("notify");
                $A.util.removeClass(element,"error");
                $A.util.addClass(element,"info");
            }
        });                
        $A.enqueueAction(action);
        action = component.get("c.getCurrentUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) 
            {
                component.set("v.currentUser", response.getReturnValue()); 
            }
        });                
        $A.enqueueAction(action);
        action = component.get("c.getCurrentAttendeePotuLuckDishes");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue() != null) 
            {
                component.set("v.dishesList", response.getReturnValue()); 
            }
        });                
        $A.enqueueAction(action);
	},
    saveAttendee : function(component, event, helper)
    {
        var element = component.find("messageBox");
        $A.util.addClass(element,"hide");
        $A.util.removeClass(element,"show");
        element = component.find("notify");
        $A.util.removeClass(element,"info");
        $A.util.addClass(element,"error");
        var action = component.get("c.saveCurrentAttendee");
        component.set("v.currentAttendee.sobjectType", "Potluck_Attendee__c");
        component.set("v.currentAttendee.Name__c", component.get("v.currentUser.Id"));
        action.setParams({
            attendee : component.get("v.currentAttendee")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue() != null) 
            {
                var registeredAttendee = component.getEvent("registeredPotLuck");
                registeredAttendee.fire();
                component.set("v.currentAttendee", response.getReturnValue()); 
                var element = component.find("messageBox");
                $A.util.removeClass(element,"hide");
                $A.util.addClass(element,"show");
                component.set("v.message","Saved Successfully");
                element = component.find("notify");
                $A.util.removeClass(element,"error");
                $A.util.addClass(element,"info");
            }
            else
            {
                component.set("v.currentAttendee.Name__c", null);
                var element = component.find("messageBox");
                $A.util.removeClass(element,"hide");
                $A.util.addClass(element,"show");
                component.set("v.message","Unexpected Error");
                element = component.find("notify");
                $A.util.removeClass(element,"info");
                $A.util.addClass(element,"error");
            }
        });                
        $A.enqueueAction(action);
    }
})