({
	helperMethod : function() {
		
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