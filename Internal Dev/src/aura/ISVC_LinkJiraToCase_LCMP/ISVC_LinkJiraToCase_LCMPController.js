({
    doInit: function(component, event, helper) {
        var action = component.get("c.JiraProjects");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.cases", response.getReturnValue());
                helper.IssueTypeHelper(component, event, helper);
                helper.itTeamHelper(component, event, helper);
            } else {
                console.log("Failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    searchJira: function(component, event, helper) {
        console.log('**',component.find('selectedValue').get("v.value"));
        console.log('**',component.find('selectedValue_issueType').get("v.value"));
        console.log('**',component.find('selectedValue_itTeam').get("v.value"));
        
        var action = component.get("c.searchJiraIssues");
        action.setParams({jiraProjectKey :component.find('selectedValue').get("v.value"),
                          ISSUE_TYPE_BUG: component.find('selectedValue_issueType').get("v.value"),
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.cases", response.getReturnValue());
                console.log("am in success" + response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
    }
})