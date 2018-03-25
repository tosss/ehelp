({
	myAction : function(component, event, helper) {
		
	},
        showSpinner: function(component) {
        component.set("v.toggleSpinner", true);
    },
    
    hideSpinner: function(component) {
        component.set("v.toggleSpinner", false);
    }
})