/* **************************************************************************************** 
 ***** 03/28/2017 vijay.manimaran@cdk.com Created 
 *****
 ******************************************************************************************** */

({
    
    doInit: function(component, event, helper) {
        // the function that reads the url parameters
        var vars = [],
            hash;
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        console.log(hashes);
        component.showSpinnerMethod();
        for (var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
            var TEPolicy = component.find('TEPolicy');
            var TCPolicy = component.find('TCPolicy');
            var PCPolicy = component.find('PCPolicy');
            var MEPolicy = component.find('MEPolicy');
            var PCardEmail = component.find('PCardEmail');
            var completeFormincreaselimit = component.find('completeFormincreaselimit');
            var location = component.find('location');
            var buttonSection = component.find('buttonSection');
            var caseHistory = component.find('caseHistory');
            if (hash[1] === 'TravelExpenseCard') {
                component.set("v.src", "Travel & Expense Card");
                $A.util.addClass(PCPolicy, 'hide-form');
                $A.util.addClass(MEPolicy, 'hide-form');

            } else if (hash[1] === 'IncreaseLimit') {
                component.set("v.src", "Increase Limit on Travel or PCard");
                $A.util.removeClass(completeFormincreaselimit, 'hide-form');
                $A.util.addClass(location, 'hide-form');
                $A.util.removeClass(buttonSection, 'hide-form');
                
            } else if (hash[1] === 'PCard') {
                component.set("v.src", "PCard");
                $A.util.addClass(TEPolicy, 'hide-form');

            } else if (hash[1] === 'CaseHistory') {
                $A.util.addClass(location, 'hide-form');
                $A.util.removeClass(caseHistory, 'hide-form');
            } else if (hash[1] === 'PCardEmail') {
                helper.PCardEmail();
                $A.util.addClass(location, 'hide-form');
                $A.util.removeClass(PCardEmail, 'hide-form');
            } else {
                $A.util.addClass(location, 'hide-form');
                $A.util.removeClass(caseHistory, 'hide-form');
            }
        }
        helper.checkRegistration_Helper(component, hash[1]);
    },
    
    // selecting the location 
    pickLocation: function(component, event, helper) {
        var action = component.get("c.deletePolicies");
        var pickLocation = event.target.id;
        component.set("v.selectedLocation", pickLocation);
        component.showSpinnerMethod();
        
        if (pickLocation === 'US') {
            
            component.find('country').set('v.value', 'USA');
            
            helper.selectedButton_Helper(component, pickLocation);
        } else if (pickLocation === 'Canada') {
            helper.selectedButton_Helper(component, pickLocation);
        } else if (pickLocation === 'French') {
            helper.selectedButton_Helper(component, pickLocation);
        }
        document.getElementById("acknowledgmentsDiv").style.display = "block";
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.hideSpinnerMethod();
                
                document.getElementById('TEPolicy').removeAttribute("disabled");
                document.getElementById('TEPolicy').removeAttribute("style");
                document.getElementById('TCPolicy').removeAttribute("style");
                document.getElementById('TCPolicy').removeAttribute("disabled");
                document.getElementById('PCPolicy').removeAttribute("style");
                document.getElementById('PCPolicy').removeAttribute("disabled");
                document.getElementById("completeForm").style.display = "none";
            }
        });
        $A.enqueueAction(action);
    },
    
    policyAcknowledge: function(component, event, helper) {
        var policyName = event.getSource().getLocalId();
    },
    
    // show the acknowledgements 
    showModal: function(component, event, helper) {
        var clickedButton = event.target.id;
        component.set("v.clickedPolicy", clickedButton);
        var modalHeader;
        var enteredData = component.get("v.portalForm");
        var selectedLocation = component.get("v.selectedLocation");
        //  component.showSpinnerMethod();
        component.set("v.policyModal","true");
        if (clickedButton === 'TEPolicy') {
            component.hideSpinnerMethod();
            if (selectedLocation === 'US') {
                component.set("v.documentID", "0680b000002NgbvAAC");
            }
            if (selectedLocation === 'Canada') {
                component.set("v.documentID", "0680b000002NgbvAAC");
            }
            if (selectedLocation === 'French') {
                component.set("v.documentID", "0680b000002Ngc0AAC");
            }
            modalHeader = 'Travel and Expense Policy';
            modalBody = 'I certify that I have read, understand, and agree to abide by the terms and conditions of CDK’s T&E Policy. I understand that my failure to abide by CDK Global’s Travel and Expense Policy may result in disciplinary action up to and including termination.';
            helper.modalContent_Helper(component, modalHeader, modalBody);
        } else if (clickedButton === 'TCPolicy') {
            component.hideSpinnerMethod();
            if (selectedLocation === 'US') {
                console.log('uinsdie documentID');
                component.set("v.documentID", "06833000002HIjsAAG");
            }
            if (selectedLocation === 'Canada') {
                component.set("v.documentID", "0680b000002NgbHAAS");
            }
            if (selectedLocation === 'French') {
                component.set("v.documentID", "0680b000002NgbbAAC");
            }
            modalHeader = 'Terms and condition Policy';
            modalBody = 'By clicking ‘I Acknowledge’ you acknowledge that you have read and understand this Agreement, and you agree to the terms of this Agreement.';
            helper.modalContent_Helper(component, modalHeader, modalBody);
        } else if (clickedButton === 'PCPolicy') {
            component.hideSpinnerMethod();
            if (selectedLocation === 'US') {
                component.set("v.documentID", "0680b000002Ngb7AAC");
            }
            if (selectedLocation === 'Canada') {
                component.set("v.documentID", "0680b000002Ngb7AAC");
            }
            if (selectedLocation === 'French') {
                component.set("v.documentID", "0680b000002Ngb7AAC");
            }
            modalHeader = 'Pcard Policy';
            modalBody = 'I certify that I have read, understand, and agree to abide by the terms and conditions of CDK’s P-Card and SMMP Policy. I understand that my failure to abide by CDK’s P-Card and SMMP Policy may result in disciplinary action up to and including termination.';
            helper.modalContent_Helper(component, modalHeader, modalBody);
        }else if (clickedButton === 'MEPolicy') {
            component.hideSpinnerMethod();
            if (selectedLocation === 'US') {
                component.set("v.documentID", "0680b000002NgceAAC");
            }
            if (selectedLocation === 'Canada') {
                component.set("v.documentID", "0680b000002NgceAAC");
            }
            if (selectedLocation === 'French') {
                component.set("v.documentID", "0680b000002NgceAAC");
            }
            modalHeader = 'Meeting Event Policy';
            modalBody = 'I certify that I have read, understand, and agree to abide by the terms and conditions of CDK’s P-Card and SMMP Policy. I understand that my failure to abide by CDK’s P-Card and SMMP Policy may result in disciplinary action up to and including termination.';

            helper.modalContent_Helper(component, modalHeader, modalBody);
        }
        
        if (clickedButton === 'submit') {
            component.hideSpinnerMethod();
            var nameOnCard = component.find('nameOnCard').get("v.value");
            var mailingAddress = component.find('mailingAddress').get("v.value");
            var addressLine2 = component.find('addressLine2').get("v.value");
            var addressLine3 = component.find('addressLine3').get("v.value");
            var addressLine4 = component.find('addressLine4').get("v.value");
            var city = component.find('city').get("v.value");
            var state = component.find('state').get("v.value");
            var zipcode = component.find('zipcode').get("v.value");
            var phone = component.find('phone').get("v.value");
            var dateofBirth = component.find('dateofBirth').get("v.value");
            var country = component.find('country').get("v.value");
            helper.fieldValidation_Helper(component, clickedButton);
            component.set("v.portalForms", enteredData);
        }
    },
    
    policyAcknowledgement: function(component, event, helper) {
        var clickedPolicy = component.get("v.clickedPolicy");
        component.set("v.policyModal","true");
        console.log(component.get("v.policyModal"));
        helper.acknowledgment_Helper(component, event, helper, clickedPolicy);
    },
    
    insertPortalForm: function(component, event, helper) {
        helper.insertPortalForm_Helper(component);
    },
    
    openSingleFile: function(cmp, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: [component.get("v.currentContentDocumentId")]
        });
    },
    hideModal: function(component, event, helper) {
        
        document.getElementById("newModalId").style.display = "none";
    },
    
    
    sendEmail: function(component, event, helper) {
        var action = component.get("c.updatePortalForm");
        var clickedForm = event.target.getAttribute("data-recId");
        var buttonid = event.target.id;
        var disableButton = component.find(buttonid);
        console.log('am here in send email',clickedForm);
        action.setParams({
            "portalformID": clickedForm,
            "updateFlag":"sendEmail"
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
    },
    
    gotoHomePage: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://mycdk.force.com/intranet/s/"
        });
        urlEvent.fire();
    },
    
    showSpinner: function(component, event, helper) {
        var spinner = component.find('spinner');
        var policymodal = component.get("v.policyModal");
        console.log(policymodal);
        var spinnerModal = component.find('spinner_modal');
        var evt;
        if(policymodal == 'true'){
            evt = spinnerModal.get("e.toggle");
        } else{
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
        if(policymodal == 'true'){
            evt = spinnerModal.get("e.toggle");
        } else{
            evt = spinner.get("e.toggle");
        } 
        
        evt.setParams({
            isVisible: false
        });
        evt.fire();
    }
})