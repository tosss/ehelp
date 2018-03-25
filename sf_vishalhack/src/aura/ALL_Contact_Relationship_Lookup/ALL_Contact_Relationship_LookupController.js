({
    getUpdatedList : function(component, event, helper) 
    {
        helper.getUpdatedListHelper(component, event, helper);
	},
    
    enterKeyPressed : function(component,event,helper)
    {
        helper.enterKeyPressedHelper(component,event,helper);
    },
    
    selectedSobject : function(component, event, helper) 
    {
        helper.selectedSobjectHelper(component, event);
	},
    
    updateValues : function(component, event, helper)
    {
        helper.updateValuesHelper(component, event);
    }
})