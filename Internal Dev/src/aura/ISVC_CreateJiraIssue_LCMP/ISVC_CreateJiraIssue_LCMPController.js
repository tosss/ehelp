({
    doInit : function(component, event, helper) {
        var action = component.get("c.JiraProjects");
        var Subject = component.get("v.caseSubject");
        var Description = component.get("v.caseDescription");
        console.log('Subject',Subject);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.cases", response.getReturnValue());
                component.find('Subject').set('v.value', Subject);
                component.find('Description').set('v.value', Description);
                helper.IssueTypeHelper(component,event,helper);
                helper.itTeamHelper(component,event,helper);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    submitJira : function(component, event, helper) {
        console.log('am here inn');
        var selectedValue= component.find('selectedValue').get("v.value");
        var Subject= component.find('Subject').get("v.value");
        var Description = component.find('Description').get("v.value");
        var toastEvent = $A.get("e.force:showToast");
        var successMsg = component.find('successMsg');
        var headingID = component.find('prompt-heading-id');
        
        if(selectedValue =='' ||selectedValue === undefined){
            component.set('v.msgHeader','Error');
            component.set('v.msgBody','Jira Project is Required');
            $A.util.addClass(headingID, 'slds-theme_error');
            $A.util.removeClass(headingID, 'slds-theme_success');
            $A.util.removeClass(successMsg, 'hide-form');
            return false;
        }
        if(Subject =='' ||Subject ===undefined){
            component.set('v.msgHeader','Error');
            component.set('v.msgBody','Subject is Required');
            $A.util.addClass(headingID, 'slds-theme_error');
            $A.util.removeClass(headingID, 'slds-theme_success');
            $A.util.removeClass(successMsg, 'hide-form');
            return false;
        }
        if(Description =='' ||Description ===undefined){
            component.set('v.msgHeader','Error');
            component.set('v.msgBody','Description is Required');
            $A.util.addClass(headingID, 'slds-theme_error');
            $A.util.removeClass(headingID, 'slds-theme_success');
            $A.util.removeClass(successMsg, 'hide-form');
            return false;
        }
        helper.submitJiraHelper(component,event,helper);
    },
    showSpinner: function(component) {
        component.set("v.toggleSpinner", true);
    },
    
    hideSpinner: function(component) {
        component.set("v.toggleSpinner", false);
    },
    hideModal : function(component,event, helper){
        var successMsg = component.find('successMsg');
        $A.util.addClass(successMsg, 'hide-form');
    }
    
})