({
	provide : function(component, event, helper) {
        var jsonString = component.get("v.inputJson");
        console.log('json String:' +jsonString);
        var jsonData = [];
        if(jsonString !=null){
            try{
               jsonData = JSON.parse(jsonString);
            }catch(err){
                console.log('Error');
                // Do Nothing
            }
        }
		helper.fireDataChangeEvent(component, jsonData); 
    }
})