({
	doInit : function(component, event, helper) {
        var action = component.get("c.getCurrentUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" ) 
            {
                component.set("v.currentUser", response.getReturnValue()); 
            }
        });                
        $A.enqueueAction(action);
	},
    saveDishSelection : function(component, event, helper)
    {
        var element = component.find("messageBox");
        $A.util.addClass(element,"hide");
        $A.util.removeClass(element,"show");
        element = component.find("notify");
        $A.util.removeClass(element,"info");
        $A.util.addClass(element,"error");
        if(component.get("v.currentDishSelection.Potluck_Dish__c") == undefined || component.get("v.currentDishSelection.Potluck_Dish__c") == null)
        {
            var element = component.find("messageBox");
            $A.util.removeClass(element,"hide");
            $A.util.addClass(element,"show");
            component.set("v.message","Dish Required");
        }
        else if(component.get("v.currentDishSelection.Quantity__c") == undefined || component.get("v.currentDishSelection.Quantity__c") == null)
        {
            var element = component.find("messageBox");
            $A.util.removeClass(element,"hide");
            $A.util.addClass(element,"show");
            component.set("v.message","Quantity Required");
        }
            else
            {
                var action = component.get("c.getRemainingQuantity");
                action.setParams({
                    pId : component.get("v.currentDishSelection.Potluck_Dish__c"),
                    reqQuantity : component.get("v.currentDishSelection.Quantity__c")
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS" && response.getReturnValue() >= 0) 
                    {
                        var actionCB = component.get("c.saveDishSelectionController");
                        component.set("v.currentDishSelection.sobjectType", "Potluck_Dish_Selection__c");
                        component.set("v.currentDishSelection.Potluck_Attendee__c", component.get("v.currentUser.Id"));
                        actionCB.setParams({
                            attendee : component.get("v.currentDishSelection")
                        });
                        actionCB.setCallback(this, function(response){
                            var state = response.getState();
                            if (component.isValid() && state === "SUCCESS" && response.getReturnValue() != null) 
                            {
                                component.set("v.currentDishSelection", {});
                                component.set("v.currentDishSelection.Potluck_Dish__c","");
                                component.set("v.selectedDishName","");
                                component.set("v.currentDishSelection.Quantity__c","");
                                component.set("v.currentDishSelection.Brought_By__c","");
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
                                component.set("v.currentDishSelection", {});
                                var element = component.find("messageBox");
                                $A.util.removeClass(element,"hide");
                                $A.util.addClass(element,"show");
                                component.set("v.message","Unexpected Error");
                                element = component.find("notify");
                                $A.util.removeClass(element,"info");
                                $A.util.addClass(element,"error");
                            }
                        });                
                        $A.enqueueAction(actionCB);
                    }
                    else if(response.getReturnValue() < 0)
                    {
                        var element = component.find("messageBox");
                        $A.util.removeClass(element,"hide");
                        $A.util.addClass(element,"show");
                        component.set("v.message","Choosing more than required Quantity");
                        element = component.find("notify");
                        $A.util.removeClass(element,"info");
                        $A.util.addClass(element,"error");
                    }
                });
                $A.enqueueAction(action);
            }
    }
})