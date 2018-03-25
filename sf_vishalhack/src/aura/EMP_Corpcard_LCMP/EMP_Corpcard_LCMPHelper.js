({
    selectedButton_Helper: function(component, pickLocation) {
        var canadaButton = component.find('Canada');
        var frenchButton = component.find('French');
        var usButton = component.find('US');
        component.set("v.selectedLocation", pickLocation);
        
        if (pickLocation === 'US') {
            this.selectedButtoncolor_Helper(component, usButton, usButton, frenchButton, canadaButton);
        }
        if (pickLocation === 'Canada') {
            this.selectedButtoncolor_Helper(component, canadaButton, canadaButton, usButton, frenchButton);
        }
        if (pickLocation === 'French') {
            this.selectedButtoncolor_Helper(component, frenchButton, frenchButton, usButton, canadaButton);
        }
    },
    
    showPolicyButtons_Helper: function(addTEPolicy, addTCPolicy, addPcard, removeTEPolicy, removeTCPolicy, removePcard) {
        $A.util.removeClass(removeTCPolicy, 'hide-form');
        $A.util.removeClass(removeTEPolicy, 'hide-form');
        $A.util.removeClass(removeTCPolicy, 'hide-form');
        $A.util.addClass(addTEPolicy, 'hide-form');
        $A.util.addClass(addTCPolicy, 'hide-form');
        $A.util.addClass(addPcard, 'hide-form');
    },
    
    checkRegistration_Helper: function(component, pageType) {
        var action = component.get("c.checkCardRequested");
        var fullForm = component.find('fullForm');
        var validationMessage = component.find('validationMessage');
        action.setParams({
            "pageType": pageType
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                this.pendingRequest_Helper(component);
                component.hideSpinnerMethod();
                if (response.returnValue === 'failurevendor') {
                    component.set("v.validationMessage", "Sorry you do not have access. As your VendorID is Null, if you are a new employee. please wait for 3 days.");
                    $A.util.removeClass(validationMessage, 'hide-form');
                } else if (response.returnValue === 'failurecontractor') {
                    component.set("v.validationMessage", "Sorry you do not have access. As your are a contractor");
                    $A.util.removeClass(validationMessage, 'hide-form');
                } else if (response.returnValue === 'failureTECard' && pageType === 'TravelExpenseCard') {
                    component.set("v.validationMessage", "You have already requested the TE card");
                    $A.util.removeClass(validationMessage, 'hide-form');
                } else if (response.returnValue === 'failurePCard' && pageType === 'PCard') {
                    component.set("v.validationMessage", "You have already requested the Pcard");
                    $A.util.removeClass(validationMessage, 'hide-form');
                } else if (response.returnValue === 'success') {
                    $A.util.removeClass(fullForm, 'hide-form');
                }else if (response.returnValue === 'failurePCardAccess' && pageType === 'PCard') {
                    component.set("v.validationMessage", "You do not have Access to request the card");
                    $A.util.removeClass(validationMessage, 'hide-form');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    pendingRequest_Helper: function(component) {
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
    
    PCardEmail: function() {
        var email_title = "Request for Meeting %26 Event Pcard ";
        var email_body="Please start by filling out the information below to explain your intended use of and spend on a CDK Pcard%2E "+ "If the spend is allowable%2C you will be directed to complete the actual%2C full registration process which requires Manager"+ "Approval%2E   %0D%0A %0D%0A "+
            "%5F%5F%5F My role at CDK requires me to purchase the following Meeting and Event related expenses%2E%0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Airline Reservations%0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Group Hotel Accommodations%0D%0A"+ 
            "%20%20%20%20%20%20%20%5F%5F%5F Group Food %26 Beverage%2C Catering%0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Group Ground Transportation%0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Other Meeting %26 Event Related Expenses%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F%5F %0D%0A "+
            "%5F%5F%5F My role at CDK requires me to purchase Goods and Services such as  %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Promotional Items %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Office Supplies%2E %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Advertising %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Social Media %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Misc Computer Equipment %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Marketing related expenses %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Gift Cards %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Management Services provided by a 3rd party%0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Computer Software %0D%0A "+
            "%20%20%20%20%20%20%20%5F%5F%5F Other%3A%5F%5F %0D%0A "+          
            "My Individual estimated spend on such purchases would be%3A %5F%5F%5F per Month or  %5F%5F%5F%5F%5F%5F  Annually%2E %0D%0A%0D%0AProvide the name of the Business Department you report to   "+
            "My Manager %5F%5F%5F%5F%5F%5F Managers title is %3A%5F%5F %0D%0A %0D%0A "+
            "CDK Procurement will review your request and advise within two days or sooner";
        ;
        window.location.href = "mailto:Pcard_requests@cdk.com&subject=" + email_title + "&body=" + email_body;
    },
    
    selectedButtoncolor_Helper: function(component, successClass, neutralClass_1, neutralClass_2, neutralClass_3) {
        $A.util.removeClass(neutralClass_1, 'slds-button--neutral');
        $A.util.removeClass(neutralClass_2, 'slds-button--success');
        $A.util.removeClass(neutralClass_3, 'slds-button--success');
        $A.util.addClass(successClass, 'slds-button--success');
        $A.util.addClass(neutralClass_2, 'slds-button--neutral');
        $A.util.addClass(neutralClass_3, 'slds-button--neutral');
    },
    
    modalContent_Helper: function(component, modalHeader, modalBody) {
        component.hideSpinnerMethod();
        document.getElementById("newModalId").style.display = "block";
        component.set("v.modalHeader", modalHeader);
        component.set("v.modalBody", modalBody);
        
        
    },
    
    fieldValidation_Helper: function(component, selectedLocation) {
        var nameOnCard = component.find('nameOnCard').get("v.value");
        var mailingAddress = component.find('mailingAddress').get("v.value");
        var city = component.find('city').get("v.value");
        var state = component.find('state').get("v.value");
        var zipcodeinput = component.find('zipcode');
        var phoneinput = component.find('phone');
        var zipcode = component.find('zipcode').get("v.value");
        var phone = component.find('phone').get("v.value");
        var dateofBirth = component.find('dateofBirth').get("v.value");
        var country = component.find('country').get("v.value");
        var beginDate = component.find('beginDate').get("v.value");
        var endDate = component.find('endDate').get("v.value");
        var justification = component.find('justification').get("v.value");
        var cardType = component.find('cardType').get("v.value");
        var amount = component.find('amount').get("v.value");
        var selectedCard = component.get("v.src");
        var toastEvent = $A.get("e.force:showToast");
        var TEPreview = component.find('TEPreview');
        var ILPreview = component.find('ILPreview');
        
        if (selectedCard === 'Increase Limit on Travel or PCard') {
            component.showSpinnerMethod();
            
            if (beginDate === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Beginning Date is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (endDate === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "End Date is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (justification === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Justification is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (cardType === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Card Type is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (amount === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Amount is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            }
            component.set("v.portalForms", enteredData);
            if (beginDate != undefined && endDate != undefined && amount != undefined && cardType != undefined && justification != undefined) {
                component.set("v.fieldValidation", "success");
                modalHeader = 'Validate the Information entered Here ';
                modalBody = '';
            }
        }
        if (selectedCard !== 'Increase Limit on Travel or PCard') {
            if (nameOnCard === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Name on Card is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (mailingAddress === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Mailing Address is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (city === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "City is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (state === undefined || state === '' || state === null) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "State is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (zipcode === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Zipcode is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (phone === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Phone is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (dateofBirth === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Date od Birth is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            } else if (country === undefined) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Country is Required",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            }
            if (nameOnCard.length > 21) {
                toastEvent.setParams({
                    "title": "Error !",
                    "message": "Name on the card must not exceed 21",
                    "type": "error"
                });
                toastEvent.fire();
                return false;
            }
            var zipcodeinput = component.find('zipcode');
            var phoneinput = component.find('phone');
            var zipcode = component.find('zipcode').get("v.value");
            var phone = component.find('phone').get("v.value");
            var enteredData = component.get("v.portalForm");
            
            if (country != undefined && dateofBirth != undefined && phone != undefined && zipcode != undefined && state != undefined && city != undefined && mailingAddress != undefined &&
                nameOnCard != undefined) {
                component.hideSpinnerMethod();
                component.set("v.portalForms", enteredData);
                component.set("v.fieldValidation", "success");
                modalHeader = 'Validate the Information entered Here ';
                modalBody = '';
            }
        }
        this.modalContent_Helper(component, modalHeader, modalBody);
    },
    
    insertPortalForm_Helper: function(component) {    
        component.showSpinnerMethod();
        
        console.log('insertPortalForminsertPortalForm');
        var action = component.get("c.submitforApporval");
        var portalForms = component.get("v.portalForm");
        var modalcontent = component.find('modalcontent');
        var selectedCard = component.get("v.src");
        action.setParams({
            "portalForms": portalForms,
            "selectedCard": selectedCard
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.hideSpinnerMethod();
                
                if (response.returnValue === 'success') {
                    $A.util.removeClass(modalcontent, 'modal-content');
                    component.set("v.fieldValidation", "failure");
                    var modalBody = '';
                    var modalHeader = 'THANK YOU!!!';
                    this.modalContent_Helper(component, modalHeader, modalBody);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    acknowledgment_Helper: function(component, event, helper, acknowledgeVal) {
        component.showSpinnerMethod();
        var action = component.get("c.Acknowledgment");
        var disablButton = component.find(acknowledgeVal);
        action.setParams({
            "Acknowledgementval": acknowledgeVal
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                if (response.returnValue === 'success') {
                    component.hideSpinnerMethod();
                    document.getElementById("newModalId").style.display = "none";
                    document.getElementById(acknowledgeVal).setAttribute("disabled", "true");
                    document.getElementById(acknowledgeVal).setAttribute("style", "Background:grey");
                    this.acknowledgementCompleted_Helper(component);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    acknowledgementCompleted_Helper: function(component) {
        var buttonSection = component.find('buttonSection');
        var selectedLocation = component.get("v.selectedLocation");
        var USack = document.getElementById("TEPolicy").getAttribute("disabled");
        var TEack = document.getElementById("TEPolicy").getAttribute("disabled");
        var TCack = document.getElementById("TCPolicy").getAttribute("disabled");
        var PCack = document.getElementById("PCPolicy").getAttribute("disabled");
        var MEack = document.getElementById("MEPolicy").getAttribute("disabled");

        var selectedCard = component.get("v.src");
        component.hideSpinnerMethod();
        if (selectedCard === 'Travel & Expense Card') {
            if (TEack === 'true' && TCack === 'true') {
                document.getElementById("completeForm").setAttribute("style", "display:block");
                $A.util.removeClass(buttonSection, 'hide-form');
                
            }
        } else if (selectedCard === 'PCard') {
            if (PCack === 'true' && TCack === 'true' && MEack === 'true') {
                document.getElementById("completeForm").setAttribute("style", "display:block");
                $A.util.removeClass(buttonSection, 'hide-form');
            }
        }
        
    },
    
    
    
    
})