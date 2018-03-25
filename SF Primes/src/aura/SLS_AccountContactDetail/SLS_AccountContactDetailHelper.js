({
	showErrorMessage: function(component,message,severity)
    {
        message = message==null || message==null ?"Unexpected Error!!!!":message;
        severity = severity==null ||severity==undefined ? "Error!!!!":severity;
        if(component.get("v.hardware")=="DESKTOP")
        {
            jQuery("#message").html(message);
            jQuery("#messageBox").fadeIn(1000, function(){
                jQuery(this).fadeOut(10000);
            });
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": severity,
                "message": message,
                "duration":10000
            });
            toastEvent.fire();
        }
    }
})