({
	/*doInit : function(component, event, helper) 
    {
		var pickListOptions = [
            { "class": "optionClass", label: "--None--", value: "None", selected: "true"},
            { "class": "optionClass", label: "Open", value: "Open"},
            { "class": "optionClass", label: "In Progress", value: "In Progress"},
            { "class": "optionClass", label: "On Hold", value: "On Hold"},
            { "class": "optionClass", label: "Completed", value: "Completed"}
        ];
        
        var pickListCmp = component.find("status");
        pickListCmp.set("v.options", pickListOptions);
	},*/
    
    createNotes : function(component, event, helper)
    { 
        //var name;
        //var userNameAction = component.get("c.getUserName");
        //userNameAction.setCallback(this, function(response){
            //name = response.getReturnValue();
            //component.set("v.userName", name);
        //});
        
        //$A.enqueueAction(userNameAction);
        var formValue = helper.validateForm(component);
       
       
        if(formValue)
        {
            
            var newLaunchNotes = component.get("v.newLaunchNotes");
            newLaunchNotes.Launch_Id__c = component.get("v.LaunchId");
            newLaunchNotes.Notes_Type__c = component.get("v.NotesType");
            var action = component.get("c.saveLaunchNotes");
           
            action.setParams({
                "newLaunchNotes" : newLaunchNotes
            });
            
            action.setCallback(this, function(response){
                var state = response.getState(); console.log(response.getState());
                
                if(component.isValid() && state === "SUCCESS")
                {
                    //var newLaunchNoteses = component.get("v.sObjects");
                    var savedRecords = response.getReturnValue();console.log(savedRecords);
                    //savedRecord["CreatedBy"]["Name"] = name; 
                    //newLaunchNoteses.unshift(savedRecord);
                    var x;
                    var setRecords = [];
                    var notesType = component.get("v.NotesType");
                    
                    for(x in savedRecords)
                    {
                        if(savedRecords[x].Notes_Type__c == notesType || notesType == null)
                        {  
                            setRecords.push(savedRecords[x]);                           
                        }   
                    }
                    component.set("v.sObjects", setRecords);
                    
                    var evt = component.getEvent("UpdateAllNotes");
                    evt.setParams({"LaunchNotes" : setRecords[0]});
                    evt.fire();
                    
                    //reset the form
                    helper.resetForm(component); 
                }
            });
            
            $A.enqueueAction(action);
        }
         
    }
})