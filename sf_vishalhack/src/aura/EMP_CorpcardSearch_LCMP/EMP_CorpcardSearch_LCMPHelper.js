({
	helperMethod : function() {
		
	},
    
    requestApproval_Helper: function(component, clickedButton){
        console.log('am herer');
        var newModalId = component.find("newModalId");
        var portalforms = component.get("v.portalForms");
        var action = component.get("c.ApprovalReject");
        var responseMessage = component.find("responseMessage");
        var casedescription ;
        if(clickedButton === 'submitReject'){
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
                console.log(response.returnValue);
                if(response.returnValue == 'success')
                {
                    document.getElementById("newModalId").style.display = "block";
                    component.set("v.modalHeader", "THANK YOU!!!");
                    component.set("v.modalBody", "Thank you for Approving the credit card Application");
                }else{
                    
                }
            }
        });
        $A.enqueueAction(action);
    }
})