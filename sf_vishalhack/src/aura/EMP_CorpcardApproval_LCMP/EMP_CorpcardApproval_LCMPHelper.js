({
	helperMethod : function() {
		
	},
    
    requestApproval_Helper: function(component, clickedButton){

        var portalforms = component.get("v.portalForms");
        var action = component.get("c.ApprovalReject"); console.log('am herer');
        var responseMessage = component.find("responseMessage"); console.log('am herer');
        var casedescription ; console.log('am herer');
        var approvalPanel = component.find('approvalPanel'); console.log('am herer');
        var rejectionPanel = component.find('rejectionPanel');
        if(clickedButton === 'submitReject'){ console.log('am herer');
            casedescription = component.find('rejectionReason').get("v.value");
        }
        action.setParams({
            "decision": clickedButton, 
            "casedescription":casedescription,
            "portalForms": portalforms
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                if(response.returnValue == 'success')
                {
                    document.getElementById("newModalId").style.display = "block";
                    component.set("v.modalHeader", "THANK YOU!!!");
                    component.set("v.modalBody", "Thank you for Approving the credit card Application");
                    $A.util.removeClass(approvalPanel,"hide-form");
                    $A.util.addClass(rejectionPanel,"hide-form");
                }
            }
        });
        $A.enqueueAction(action);
    }
})