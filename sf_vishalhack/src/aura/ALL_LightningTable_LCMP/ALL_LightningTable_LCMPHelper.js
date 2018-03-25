({
	validateForm : function(component)
    {
        var validForm = true;
        
        var date = component.find("date");
        var dateValue = date.get("v.value");
        
        if($A.util.isEmpty(dateValue))
        {
            validForm = false;
            date.set("v.errors", [{message:"Date can't be empty!"}]);
        }
        
        var notes = component.find("notes");
        var notesValue = notes.get("v.value");
        
        if($A.util.isEmpty(notesValue))
        {
            validForm = false;
            notes.set("v.errors", [{message:"Notes can't be empty!"}]);
        }
        
        /*var status = component.find("status");
        var statusValue = status.get("v.value");
        
        if($A.util.isEmpty(statusValue) || statusValue == "None")
        {
            validForm = false;
            status.set("v.errors", [{message:"Status can't be empty!"}]);
        }*/
        
        return validForm;
    },
    
    resetForm : function(component)
    {
        component.find("date").set("v.value", null);
        component.find("notes").set("v.value", null);
        /*var status = component.find("status"); status.set("v.value", null);*/
    }
})