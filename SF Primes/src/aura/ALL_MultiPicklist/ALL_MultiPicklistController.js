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
	},
    /*reset : function(component, event, helper)
    {	console.log('called');
        helper.reset(component, event, helper);
    },
     aeHandlerController.js */

    resetEvent : function(component, event) {
        
        console.log('event fired');
        component.set('v.selectedOption','None Selected');
        component.set('v.selectedCount','None Selected');
        component.set('v.selectedOptions',[]);
        var element = component.getElement();
        jQuery(element).find(".icon").addClass('invisible');
    }
}
     
})