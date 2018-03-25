({
    doInit: function(component, event, helper) {
        // the function that reads the url parameters
        var action = component.get("c.pendingRequest");
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.hideSpinnerMethod();
                component.set("v.pendingRequest", response.returnValue)
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function(component, event, helper) {
        var spinner = component.find('spinner');
        var policymodal = component.get("v.policyModal");
        console.log(policymodal);
        var spinnerModal = component.find('spinner_modal');
        var evt;
        if (policymodal == 'true') {
            evt = spinnerModal.get("e.toggle");
        } else {
            evt = spinner.get("e.toggle");
        }
        evt.setParams({
            isVisible: true
        });
        evt.fire();
    },

    hideSpinner: function(component, event, helper) {
        var spinner = component.find('spinner');
        var spinnerModal = component.find('spinner_modal');
        var policymodal = component.get("v.policyModal");
        var evt;
        if (policymodal == 'true') {
            evt = spinnerModal.get("e.toggle");
        } else {
            evt = spinner.get("e.toggle");
        }

        evt.setParams({
            isVisible: false
        });
        evt.fire();
    },
    
    sendEmail: function(component, event, helper) {
        var action = component.get("c.updatePortalForm");
        var clickedForm = event.target.getAttribute("data-recId");
        var buttonid = event.target.id;
        var disableButton = component.find(buttonid);
        action.setParams({
            "portalformID": clickedForm,
            "updateFlag": "sendEmail"
        });
        component.showSpinnerMethod();

        action.setCallback(this, function(response) {
            var state = response.state;
            if (response.returnValue === 'success') {
                component.hideSpinnerMethod();

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success !",
                    "message": "You have successfully send email to managers as a reminder for approving your request.",
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})