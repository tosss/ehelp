({
	doInit : function(cmp, event, helper) 
    {
		var launchId = cmp.get("v.LaunchId");
        
        var action = cmp.get("c.getAllLaunchNotes");        
        action.setParams({ launchId : launchId });
               
        action.setCallback(this, function(response){
            var state = response.getState();
            var allNotes = response.getReturnValue();
            //console.log(allNotes);
            //allNotes.reverse();
            var designNotes = [];
            var orderManagerNotes = [];
            //console.log(allNotes);
            if(allNotes)
            {
                cmp.set("v.LaunchNotes", allNotes);
                var x;
                for(x in allNotes)
                { 
                    var record = allNotes[x];
                    
                    if(record.Notes_Type__c == 'Designer')
                    {
                        designNotes.push(record);
                    }  
                    
                    if(record.Notes_Type__c == 'IC/IS')
                    {
                        orderManagerNotes.push(record);
                    }
                }
            }
            
            cmp.set("v.DesignNotes", designNotes);
            cmp.set("v.OrderManagerNotes", orderManagerNotes);
            cmp.set("v.LaunchNotes", allNotes);
            
            var spinner = cmp.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            
            
            if(state === "ERROR")
            {
                var errors = response.getError();
                
                if(errors)
                {
                    if(errors[0] && errors[0].message)
                    {
                        console.log("Error message: " + errors[0].message);
                    }
                    else
                    {
                        console.log("Unknown error");
                    }
                }
            }
        });
        
        $A.enqueueAction(action);
	},
    
    updateALL : function(cmp, event, helper)
    {
        var updateLaunchNotes = event.getParam("LaunchNotes");
        var allNotes = cmp.get("v.LaunchNotes");
        allNotes.unshift(updateLaunchNotes);
        cmp.set("v.LaunchNotes", allNotes);
        
    }
})