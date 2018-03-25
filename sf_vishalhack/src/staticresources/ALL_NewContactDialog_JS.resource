//2016-05-12- anirudh.singh@cdk.com, venkata.shrivol@cdk.com- Created this javascript for RQ-06986.
//2017-02-03- ragashalini.koka@cdk.com - Added MobilePhone field for RQ-08334
//This function created Dialog Box
function openDialog(subProjectId, insertSPCC, callWebService, inputCall) 
{
    try
    {
        var addNewContactDialog=jQuery("[id$='newContactSection']");
        if(inputCall == 'campaign')
        {
            jQuery("[id$='phoneBlock']").append("<div class='requiredBlock'></div>");
        }
        addNewContactDialog.dialog(
            {
                "minWidth": 750,
                "title": "Add a New Contact", 
                "modal": true,
                close:function(event, ui)
                {
                    jQuery(this).dialog("destroy");    
                },
                "buttons": [
                    {
                        "text": "Save",
                        click: function()
                        {
                            jQuery('#newSObjectRoles option').prop('selected', 'selected');
                            createContact(subProjectId, insertSPCC, callWebService, inputCall);
                            
                        }
                    },
                    {
                        "text":"Close",
                        click: function()
                        {
                            jQuery(this).dialog("destroy");
                        }
                    }
                ]
            });
        
        jQuery("#newSObjectRoleSelect").on("click", 
			function()
            {
                appendItemsToRight('#selectableSObjectRoles', '#newSObjectRoles');
            }
		);
        
        jQuery("#newSObjectRoleUnselect").on("click",
			function()
			{
				appendItemstoLeft('#newSObjectRoles', '#selectableSObjectRoles');
			}
		);
    }
    catch(error)
    {
        console.log(error.message);
    }
}

//This function is used to select the multi-select picklist values from the list of available values.
function appendItemsToRight(sourceId, destinationId)
{
    jQuery(sourceId+' option:selected').remove().appendTo(destinationId);
}

//This function is used to de-selects the selected values of the multi-select picklist.
function appendItemstoLeft(sourceId, destinationId)
{
    jQuery(sourceId+' option:selected').remove().appendTo(destinationId);
    sortSelectOptions(destinationId);
}

//This method is used to sort the picklist values.
function sortSelectOptions(selectListId)
{
    var sortOptions=jQuery(selectListId+' option');
    sortOptions.sort(function(a, b)
                     {
                         if (a.text > b.text) return 1;
                         else if (a.text < b.text) return -1;
                             else return 0;
                     });
    jQuery(selectListId+' option').remove();
    jQuery(selectListId).append(sortOptions);
}

//This function is used to validate user inputs and invoke the create Contact method of the apex class.
function createContact(subProjectId, insertSPCC, callWebService, inputCall)
{
    var addNewContactDialog=jQuery("#newContactSection");
    
    //Disable buttons.
    jQuery(":button", addNewContactDialog.parent()).attr("disabled", "disabled").addClass("ui-state-disabled");
    
    //Array of fields that are required.
    var requiredFields=new Array();
    
    //Select all selected roles.
    jQuery("#newSObjectRoles option").attr("selected", "selected");
    
    //First Name is required.
    var newContactFirstName=jQuery("#newContactFirstName");
    requiredFields.push(newContactFirstName);
    
    //Last Name is required.
    var newContactLastName=jQuery("#newContactLastName");
    requiredFields.push(newContactLastName);
    
    //Account is required. Since, a value is always selected there is no validation required.
    var newContactAccountSelect=jQuery("#newContactAccountSelect");
    //requiredFields.push(newContactAccountSelect);
    
    //Role is required.
    var newSObjectRoles=jQuery("#newSObjectRoles");
    requiredFields.push(newSObjectRoles);
    
    //Project Role is required. Since, a value is always selected there is no validation required.
    var projectRoleSelect=jQuery("#projectRoleSelect");
    //requiredFields.push(projectRoleSelect);
    
    //Phone is required for campaigns.
    var newContactPhone=jQuery("#newContactPhone");
    if(inputCall == 'campaign')
    {   
        requiredFields.push(newContactPhone);
    }
    
    //Email is not required.
    var newContactEmail=jQuery("#newContactEmail");
    
    var displayProjectRole=jQuery("#displayProjectRole");
    // var subProjectId=jQuery("#subProjectId");
   
    //2017-02-03 - ragashalini.koka@cdk.com - Added this for RQ-08334
    var newContactMobile=jQuery("#newContactMobile"); 
    
    //Clear out any previous error for the consecutive button clicks.
    jQuery("[id$=newContactErrorSummary]", "#newContactSection").html("");
    jQuery("[id$=_error]", "#newContactSection").remove();
    
    if(performValidations(requiredFields, newContactEmail)==true)
    {
        jQuery("#newContactErrorSummary", "#newContactSection").css("color", "");
        jQuery("#newContactErrorSummary", "#newContactSection").html("Adding a new Contact; please wait. ");
        
        try
        {
            if(callWebService == true)
            {
                
                var jsonResult = sforce.apex.execute(
                    "ALL_NewContactDialog_Controller","AddContactAndClientContact",
                    {
                        FirstName:newContactFirstName.val()
                        ,LastName:newContactLastName.val()
                        ,accountId:newContactAccountSelect.val()
                        ,contactRole:String(newSObjectRoles.val()).replace(/\,/g,"; ")
                        ,projectRole:String(projectRoleSelect.val()).replace(/\,/g,"; ")
                        ,Email:newContactEmail.val()
                        ,Phone:newContactPhone.val()
                        ,mobilePh:newContactMobile.val()
                        ,insertSPCC:insertSPCC
                        ,SubProjectId:subProjectId 
                        
                    }); 
                var result = JSON.parse(jsonResult);
                console.log(result);
                console.log(addNewContactDialog);
                handleResultCall(result, inputCall);
            }
            else
            {
                 
                ALL_NewContactDialog_Controller.createNewContact(
                    newContactFirstName.val(), 
                    newContactLastName.val(),
                    newContactAccountSelect.val(),
                    String(newSObjectRoles.val()).replace(/\,/g,"; "),
                    '',
                    newContactEmail.val(),
                    newContactPhone.val(),
                    newContactMobile.val(),
                    insertSPCC,
                    subProjectId,
                    inputCall,
                    function(result, event)
                    {
                        handleResultCall(result, inputCall);          
                    }
                );    
            }
            
        }
        catch(error)
        {
            console.log(error);
            jQuery("#newContactErrorSummary", "#newContactSection").html("Error. Please contact Administrator for Help!").css("color", "#CC0000"); 
            jQuery(":button",jQuery("#newContactSection").parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
        }
    }
}

//This function is used to validate User Inputs.
function performValidations(requiredFields, newContactEmail)
{
    var validationsPassed=true;
    var addNewContactDialog=jQuery("#newContactSection");
    var requiredFieldsWithError=new Array();
    
    jQuery(requiredFields).each(
        function(index, field)
        {
            console.log(field.val());
            if(!(field.val()!=null && field.val() != "" && field.val() != "-- None --")) 
            {
                field.addClass("error");
                requiredFieldsWithError.push(field); 
            } 
            else
            {
                field.removeClass("error");
            }
        }
    );
    
    //If the values of the required fields are not provided by the user. Then, proper error messages should be displayed.
    if(requiredFieldsWithError.length > 0)
    {
        console.log('I am here 1');
        //This will hold the field labels of the fields on which error is to be displayed.
        var requiredFieldLabels=new Array();
        
        jQuery(requiredFieldsWithError).each(
            function(index, field)
            {
                console.log('I am here 2');
                var requiredFieldLabel=jQuery("label[for$='"+jQuery(field).attr('id')+"']").html().trim();   
                requiredFieldLabels.push(requiredFieldLabel);
                field.after("<div id='"+field.attr("id")+"_error' class='errorMsg' style='display: inherit;'>"+requiredFieldLabel+" is Required.</div>");
            }
        );
        
        if(requiredFieldLabels.length > 1)
        {
            requiredFieldLabels[requiredFieldLabels.length - 1] = "and " + requiredFieldLabels[requiredFieldLabels.length - 1];
        }
        
        jQuery("#newContactErrorSummary","#newContactSection")
        .html(requiredFieldLabels.join(", ")+" "+(requiredFieldLabels.length > 1 ? "are" : "is a")+" required field(s). ")
        .css("color","#CC0000");
        
        //Enable buttons.
        jQuery(":button", addNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled");
        
        validationsPassed=false;
        return;
    }
    else 
    {
        if(newContactEmail && newContactEmail.val() && newContactEmail.val().length > 0 && !validEmail(newContactEmail.val()))
        {
            var errorLabel=jQuery("label[for$="+newContactEmail.attr('id')+"]").html().trim(); 
            newContactEmail.after("<div id='"+newContactEmail.attr("id")+"_error' class='errorMsg' >"+errorLabel+" is invalid.</div>").addClass("error");
            
            jQuery("#newContactErrorSummary", "#newContactSection").html("The e-mail address entered is invalid. ").css("color", "#CC0000");
            
            //Enable buttons.
            jQuery(":button", addNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled");
            
            validationsPassed=false;
            return;
        }
        else
        {
            newContactEmail.removeClass("error");
        }
    }
    
    return validationsPassed;
}

function handleResultCall(result, inputCall)
{
    if(result)
    {
        if(result.Success == true)
        {
            //Close the dialog.
            jQuery("#newContactSection").dialog("close");
            
            //Enable buttons.
            jQuery(":button", jQuery("#newContactSection").parent()).removeAttr("disabled").removeClass("ui-state-disabled");
            
            //Clear the message.
            jQuery("#newContactErrorSummary", "#newContactSection").html("");
            
            //Clear the inputs.
            jQuery("input", "#newContactSection").val("");
            
            //Clear any selections.
            jQuery("select > option", "#newContactSection").removeAttr("selected");
            
            //Remove all selected values.
            jQuery("#newSObjectRoles option").each(
                function(index,value)
                {
                    jQuery(value).removeAttr("selected").detach().appendTo("#selectableSObjectRoles");
                }
            );
            
            //Sort the selectable values.
            sortSelectOptions('#selectableSObjectRoles');
            setTheReturn(inputCall);
            //alert('Contact successfully created');
        }
        else
        {
            var decodedString = jQuery('<textarea />').html(result.Message).text();
            //console.log(decodedString);
            jQuery("#newContactErrorSummary","#newContactSection").html(decodedString);
            jQuery("#newContactErrorSummary","#newContactSection").css("color","#CC0000");
            jQuery(":button",jQuery("#newContactSection").parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
        }
    }      
}

function setTheReturn(inputCall)
{
    if(inputCall == 'campaign')
    {
        FindContacts(); // refresh the contacts list
        MessageBox(true,"Contact has been added.");
        setTimeout(function(){MessageBox(false,"Contact has been added.");},1000);
    }
    else if(inputCall == 'milestone')
    {
        alert('Sub-project Client Contact created');             
    }
    else
    {
         window.top.location.reload();    
    }      
}

function validEmail(email) 
{
    var re=/^([^\@]*)\@([^\.]*)\.(.*)$/;
    return re.test(email);
}

function formatPhoneNumber(value)
{
    number = value.value;
    var raw = (""+number).replace(/[^\+\x\d]*/g, "");
    var digits = (""+number).replace(/\D/g, ""); 
    if(!digits) { digits = ""; }
    
    var match = raw.match(/([\+\1\d]*)(\d{3})(\d{3})(\d{4})$/);
    
    if(match && digits && (digits.length >= 9 && digits.length < 12) ) {
        var matchprefix = ( (match[1] || match[1] != "") ? match[1]+" " : "" );
        
        if ( matchprefix == "" || /(\++1+ *)|(1+ *)/.test(matchprefix) ) {
            value.value = "(" + match[2] + ") " + match[3] + "-" + match[4]; 
        }
    }
    return true;
   
}