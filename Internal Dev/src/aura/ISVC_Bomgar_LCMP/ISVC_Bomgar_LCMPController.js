({
	doInit : function(component, event, helper) {
        var action = component.get("c.sendRequest");
        var headingID = component.find('prompt-heading-id');
console.log('component.get("v.caseId")',component.get("v.caseId"));
        action.setParams({
            caseId: component.get("v.caseId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() === null || response.getReturnValue() === '' || response.getReturnValue() === undefined){
                    component.set("v.header","Error");
                    component.set("v.content","CTA is Unavailable please go online and then generate the key ");
                    $A.util.addClass(headingID, 'slds-theme_error');
                    $A.util.removeClass(headingID, 'slds-theme_success');
                }else{
                    component.set("v.header","Success");
                    component.set("v.content",response.getReturnValue());
                    $A.util.removeClass(headingID, 'slds-theme_error');
                    $A.util.addClass(headingID, 'slds-theme_success');
                }
                
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    refresh : function(component, event, helper) {
     window.location.reload( true );

    }
 })