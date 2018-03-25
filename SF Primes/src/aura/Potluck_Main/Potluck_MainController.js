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
                component.set("v.currentAttendee", null);
            }
        });
        $A.enqueueAction(action); 
    },
    goToHome : function(component, event, helper) {
        $A.createComponent(
            "c:Potluck_Home",
            {},
            function(newComponent){
                if (component.isValid()) 
                {
                    component.find("mainContent").set("v.body",[]);
                    var body = component.find("mainContent").get("v.body");
                    body.push(newComponent);
                }
            }
        );
        jQuery('.slds-tabs--default__item').removeClass('slds-active');
        jQuery(event.target).parents('li').addClass('slds-active');
    },
    getAboutMe : function(component, event, helper) {
        $A.createComponent(
            "c:PotLuck_AboutCurrentAttendee",
            {},
            function(newComponent){
                if (component.isValid()) 
                {
                    component.find("mainContent").set("v.body",[]);
                    newComponent.addHandler("registeredPotLuck", component, "c.doInit");
                    var body = component.find("mainContent").get("v.body");
                    body.push(newComponent);
                    
                }
            }
        );
        jQuery('.slds-tabs--default__item').removeClass('slds-active');
        jQuery(event.target).parents('li').addClass('slds-active');
    },
    makeDishSelection : function(component, event, helper) {
        var hasAccess = component.get("v.currentAttendee");
        if(hasAccess != null)
        {
            $A.createComponent(
                "c:PotLuck_DishSelection",
                {},
                function(newComponent){
                    if (component.isValid()) 
                    {
                        component.find("mainContent").set("v.body",[]);
                        var body = component.find("mainContent").get("v.body");
                        body.push(newComponent);
                    }
                }
            );
            jQuery('.slds-tabs--default__item').removeClass('slds-active');
            jQuery(event.target).parents('li').addClass('slds-active');
        }
        else
        {
            $A.createComponent(
                "c:PotLuck_AboutCurrentAttendee",
                {message:'Please give your details to select dish'},
                function(newComponent){
                    if (component.isValid()) 
                    {
                        component.find("mainContent").set("v.body",[]);
                        newComponent.addHandler("registeredPotLuck", component, "c.doInit");
                        var body = component.find("mainContent").get("v.body");
                        body.push(newComponent);
                    }
                }
            );
            jQuery('.slds-tabs--default__item').removeClass('slds-active');
            jQuery(event.target).parents('li').addClass('slds-active');
        }
    },
    getAllDishes : function(component, event, helper) {
        $A.createComponent(
            "c:Potluck_AllDishes",
            {},
            function(newComponent){
                if (component.isValid()) 
                {
                    component.find("mainContent").set("v.body",[]);
                    var body = component.find("mainContent").get("v.body");
                    body.push(newComponent);
                }
            }
        );
        jQuery('.slds-tabs--default__item').removeClass('slds-active');
        jQuery(event.target).parents('li').addClass('slds-active');
    },
    getDishSelections : function(component, event, helper) {
        $A.createComponent(
            "c:PotLuck_ListDetails",
            {},
            function(newComponent){
                if (component.isValid()) 
                {
                    component.find("mainContent").set("v.body",[]);
                    var body = component.find("mainContent").get("v.body");
                    body.push(newComponent);
                }
            }
        );
        jQuery('.slds-tabs--default__item').removeClass('slds-active');
        jQuery(event.target).parents('li').addClass('slds-active');
    },
    openChatter : function(component, event, helper) {
        var hasAccess = component.get("v.currentAttendee");
        if(hasAccess != null)
        {
            var hardware = component.get("v.hardware");
            if(hardware == "DESKTOP")
            {
                window.open('https://adpdealerservices--sfprimes.cs14.my.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9c00000001qGl','_blank');
            }
        }
        else
        {
            $A.createComponent(
                "c:PotLuck_AboutCurrentAttendee",
                {message:'Please give your details to use chatter'},
                function(newComponent){
                    if (component.isValid()) 
                    {
                        component.find("mainContent").set("v.body",[]);
                        newComponent.addHandler("registeredPotLuck", component, "c.doInit");
                        var body = component.find("mainContent").get("v.body");
                        body.push(newComponent);
                    }
                }
            );
            jQuery('.slds-tabs--default__item').removeClass('slds-active');
            jQuery(event.target).parents('li').addClass('slds-active');
        }
    },
    getContactDetails : function(component, event, helper) {
        $A.createComponent(
            "c:Potluck_ContactDetails",
            {},
            function(newComponent){
                if (component.isValid()) 
                {
                    component.find("mainContent").set("v.body",[]);
                    var body = component.find("mainContent").get("v.body");
                    body.push(newComponent);
                }
            }
        );
        jQuery('.slds-tabs--default__item').removeClass('slds-active');
        jQuery(event.target).parents('li').addClass('slds-active');
    },
    goToHelp : function(component, event, helper) {
        $A.createComponent(
            "c:Potluck_Help",
            {},
            function(newComponent){
                if (component.isValid()) 
                {
                    component.find("mainContent").set("v.body",[]);
                    var body = component.find("mainContent").get("v.body");
                    body.push(newComponent);
                }
            }
        );
        jQuery('.slds-tabs--default__item').removeClass('slds-active');
        jQuery(event.target).parents('li').addClass('slds-active');
    }
})