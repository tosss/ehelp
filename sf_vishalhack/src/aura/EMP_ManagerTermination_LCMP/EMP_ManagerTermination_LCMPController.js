/*******************************************************************************
** RQ-08648 02/22/2017 Created Vijay.Manimaran@cdk.com

********************************************************************************* */

({
    doInit: function(component) {
        var action = component.get("c.checkAccess");
        var accessCards = component.find('accessCards');
        var managerTerminationForm = component.find('managerTerminationForm');
        component.fetch_Helper();
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                if (response.returnValue === 'Success') {
                    $A.util.removeClass(managerTerminationForm, 'manager-form-hide');
                } else {
                    $A.util.removeClass(accessCards, 'manager-form-hide');
                    $A.util.addClass(managerTerminationForm, 'manager-form-hide');
                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    
// fetch's all the pending termination portal forms.
    fetch_Helper: function(component){
        var action = component.get("c.fetchPendingTermination");
        var saveContinue = component.find('saveContinue');
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.contactList", response.returnValue);
                $A.util.removeClass(saveContinue, 'manager-form-hide');
            }
        });
        $A.enqueueAction(action);
   },
 
 
    sectionPanel: function(component, event) {
        var selectedPanel = event.target.id;
        var myCareerContentPanel = component.find('myCareerPanel');
        var resignationcontentPanel = component.find('resignationPanel');
        var lastDayPanel = component.find('lastDayPanel');
        var myCareer_Collapse = component.find('myCareer_Collapse').get("v.iconName");
        var resignation_Collapse = component.find('resignation_Collapse').get("v.iconName");
        var lastDay_Collapse = component.find('lastDay_Collapse').get("v.iconName");
        if (selectedPanel === 'myCareerSection') {
            if (myCareer_Collapse === 'utility:chevronright') {
                component.set('v.ltng_icon_mycareer', 'utility:chevrondown');
                $A.util.removeClass(myCareerContentPanel, 'manager-form-hide');
            } else if (myCareer_Collapse === 'utility:chevrondown') {
                component.set('v.ltng_icon_mycareer', 'utility:chevronright');
                $A.util.addClass(myCareerContentPanel, 'manager-form-hide');
            }
        } else if (selectedPanel === 'resignationSection') {
            if (resignation_Collapse === 'utility:chevronright') {
                component.set('v.ltng_icon_resignation', 'utility:chevrondown');
                $A.util.removeClass(resignationcontentPanel, 'manager-form-hide');
            } else if (resignation_Collapse === 'utility:chevrondown') {
                component.set('v.ltng_icon_resignation', 'utility:chevronright');
                $A.util.addClass(resignationcontentPanel, 'manager-form-hide');
            }
        } else if (selectedPanel === 'lastDaySection') {
            if (lastDay_Collapse === 'utility:chevronright') {
                component.set('v.ltng_icon_lastday', 'utility:chevrondown');
                $A.util.removeClass(lastDayPanel, 'manager-form-hide');
            } else if (lastDay_Collapse === 'utility:chevrondown') {
                component.set('v.ltng_icon_lastday', 'utility:chevronright');
                $A.util.addClass(lastDayPanel, 'manager-form-hide');
            }
        }
    },

    onchange: function(component, event, helper) {
        helper.onchange_Helper(component, event, helper);
    },

      startTermination: function(component, event, helper) {
        var action = component.get("c.managerReport");
        var contactName = component.find('contactName').get("v.value");
        var workLocation = component.find('workLocation').get("v.value");

        if (contactName === '' || contactName === null || workLocation === '' || workLocation === null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error !",
                "message": "Please select the Employee and work location."
            });
            toastEvent.fire();
            return false;
        }
        action.setParams({
            assocaiteId: contactName
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                if (response.returnValue === "Success") {
                    helper.createManagerRecord_helper(component);
                } else {
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error !",
                        "message": "Please select the Employee who reports to you or your direct report(s)."
                    });
                    toastEvent.fire();
                    return false;
                }
            }
        });
        $A.enqueueAction(action);
    },

    hideModal: function() {
        document.getElementById("newModalId").style.display = "none";
    },

    getContactDetails: function(component, event, helper) {
        var action = component.get("c.fetchAssociateTerminated");
        var selectedAssociate = component.get("v.portalForms.Contact__c");
        action.setParams({
            portalForms: selectedAssociate
        });
        action.setCallback(this, function(response) {
            helper.update_FetchAssociateTermination(component, response);
        });
        $A.enqueueAction(action);
    },

    fetchSelectedAssocaite: function(component, event, helper) {
        var action = component.get("c.fetchAssociateTerminated");
        var manager_questions = component.find('managerquestions');
        var selectedAssociate = event.target.id;
        var selectAssociate = component.find('selectAssociate');
        $A.util.addClass(selectAssociate, 'manager-form-hide');
        $A.util.addClass(manager_questions, 'manager-form-hide');
        var myCareers_Ques = component.find('myCareer_Q1');
        var myCareer_HRBP = component.find('myCareer_Q2');
        var managerForm = component.find('managerForm');

        action.setParams({
            portalForms: selectedAssociate
        });
        action.setCallback(this, function(response) {
            var state = response.state;
            if (state === "SUCCESS") {
                component.set("v.portalFormsreturn", response.returnValue);
                component.set("v.portalForm", response.returnValue);
                component.set('v.ltng_icon_resignation', 'utility:chevrondown');
                component.set('v.ltng_icon_mycareer', 'utility:chevrondown');
                component.set('v.ltng_icon_lastday', 'utility:chevrondown');
                helper.onchange_Helper(component);
                $A.util.removeClass(managerForm, 'manager-form-hide');
                helper.update_FetchAssociateTermination(component, response);
                if (response.returnValue.Mgr_Term_Involuntary__c === true) {
                    $A.util.addClass(myCareers_Ques, 'manager-form-hide');
                    $A.util.addClass(myCareer_HRBP, 'manager-form-hide');
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateAssociateTermination: function(component, event, helper) {
        var pformsID = component.get("v.portalForm.Id");
        var action = component.get("c.insertAssociate");
        var manageranswers = component.get("v.portalForm");
        var completedFlag = component.get("v.formCompleted");
        var submitbutton = event.target.getAttribute("Id");
        action.setParams({
            pforms: manageranswers,
            pformsID: pformsID,
            completedFlag: completedFlag
        });
        console.log('completedFlag',completedFlag);
        
        action.setCallback(this, function(response) {
        console.log('res', response.state);
            helper.update_FetchAssociateTermination(component, response, completedFlag);
            if (submitbutton === 'Submit' && completedFlag === 'false') {
                document.getElementById("newModalId").style.display = "block";
                component.set("v.modalBody", "In order to continue, you must answer all questions.");
                component.set("v.modalHeader", "Error!");
            }
            if (completedFlag === 'true' && response.state === 'SUCCESS') {
                document.getElementById("newModalId").style.display = "block";
                component.set("v.modalBody", "Thank you for your submission, the termination checklist is complete.  All action items are being routed to the appropriate party for resolution. As a next step, an exit survey will be generated and sent to the employee's work email to collect their feedback on their experience while working for CDK.");
                component.set("v.modalHeader", "Success");
            }else if(completedFlag === 'true' && response.state !== 'SUCCESS'){
                document.getElementById("newModalId").style.display = "block";
                component.set("v.modalBody", "You have completed the termination checklist for this employee. If you believe this is an error, please reach out to your respective HR Business Partner.");
                component.set("v.modalHeader", "Error");
            }
        });
        $A.enqueueAction(action);
    },

    showSpinner: function(component) {
        component.set("v.toggleSpinner", true);
    },

    hideSpinner: function(component) {
        component.set("v.toggleSpinner", false);
    },

    gotoURL: function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://qa-mycdk.cs71.force.com/intranet/s/"
        });
        urlEvent.fire();
    }
})