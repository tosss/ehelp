     $j = jQuery.noConflict();
	 
	function highlightError(field,message) {
        //this function is used to style the invalid input field and add a message beside the field
        var hasError = j$(field).parent().find('div[class="errorMsg"]:visible');
       
        if (hasError.length == 0) {
            j$(field).addClass("error");
            j$(field).parent().append('<div class="errorMsg"><strong>Error: </strong>' + message + '</div>');
        }
    }
    
    function removeError(field) {        
        //remove the error class and message when the field is correct
         var hasError = j$(field).parent().find('div[class="errorMsg"]:visible');
       
        if (hasError.length != 0) {
            j$(field).removeClass("error");
            j$(hasError ).hide();
        }
    }