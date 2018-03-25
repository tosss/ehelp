({
    doInit:function(component, event, helper){
        helper.doInit(component, event, helper);
    },
	showOptions : function(component, event, helper) {
		jQuery(event.target).parents("#fullComponent").find("#optionsList").toggle();
	},
    selectOption : function(component, event, helper) {
        helper.selectOption(component, event, helper);
	},
    hide : function(component, event, helper) {
		helper.hide(component, event);
	}
})