({
    submitJiraHelper : function(component,event,helper) {
        console.log('**',component.find('selectedValue').get("v.value"));
        console.log('**',component.find('selectedValue_issueType').get("v.value"));
        console.log('**',component.find('selectedValue_itTeam').get("v.value"));

        console.log('**',component.find('Subject').get("v.value"));
        console.log('**',component.get("v.caseId"));
        var action = component.get("c.createJiraIssue");
        var successMsg = component.find('successMsg');
        var headingID = component.find('prompt-heading-id');
        action.setParams({jiraProjectKey :component.find('selectedValue').get("v.value"),
                          Subject:component.find('Subject').get("v.value"),
                          Description:component.find('Description').get("v.value"),
                          ISSUE_TYPE_BUG: component.find('selectedValue_issueType').get("v.value"),
                          caseId: component.get("v.caseId")
                          //customfield_11500:component.find('selectedValue_itTeam').get("v.value") 
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.cases", response.getReturnValue());
                console.log("am in success" + state);
                
                component.set('v.msgHeader','Success');
                component.set('v.msgBody','You have successfully created');
                $A.util.addClass(headingID, 'slds-theme_success');
                $A.util.removeClass(headingID, 'slds-theme_error');
                
                $A.util.removeClass(successMsg, 'hide-form');
            } else {
                console.log("Failed with state: " + state);
                $A.util.addClass(successMsg, 'hide-form');
                
            }
        });
        
        $A.enqueueAction(action);
    },
    IssueTypeHelper: function(component,event,helper){
        this.picklistValue(component,'Jira_Issue__c','Issue_Type__c');	
    },
    itTeamHelper: function(component,event,helper){
        this.picklistValue(component,'Jira_Issue__c','IT_Team__c');	
    }, 
    picklistValue: function(component,sObject,fieldName){
        console.log(fieldName);
        var action = component.get("c.FieldPikclistValues");
        action.setParams({ObjectApi_name :sObject,
                          picklistField:fieldName
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(fieldName === 'Issue_Type__c'){
                    component.set("v.issueType", response.getReturnValue());
                }
                if(fieldName === 'IT_Team__c'){
                    component.set("v.iTTeam", response.getReturnValue());
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})