
jQuery('head').append('<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/redmond/jquery-ui.css" type="text/css" />'); 

if(jQuery)
{
   jQuery.noConflict(); 
}
function appendItemsToRight(source, dest)
{
    jQuery(source+' option:selected').remove().appendTo(dest);
}

function appendItemstoLeft(source, dest)
{
    jQuery(source+' option:selected').remove().appendTo(dest);
    
    var sortOptions = jQuery(dest+' option');
    sortOptions.sort(function(a,b){
        if (a.text > b.text) return 1;
        else if (a.text < b.text) return -1;
            else return 0;
    });
    jQuery(dest+' option').remove();
    jQuery(dest).append( sortOptions );
}

function ValidEmail(email) 
{
    var re = /^([^\@]*)\@([^\.]*)\.(.*)$/;
    return re.test(email);
} 

//CC - Client Contact of SubProject
function createContactAndCC(subProjectId, reload)
{
    var AddNewContactDialog = jQuery("#NewContactSection");
    jQuery(":button",AddNewContactDialog.parent()).attr("disabled","disabled").addClass("ui-state-disabled"); // disable buttons
    var RequiredFields = [];
    var RequiredFieldsInError = [];
    
    // select all selected roles
    jQuery("#NewContactRoles option").attr("selected","selected");
    jQuery("#newProjectRolesOfContact option").attr("selected","selected");
    
    var NewContactFirstName = jQuery("#NewContactFirstName"); RequiredFields.push(NewContactFirstName);
    var NewContactLastName = jQuery("#NewContactLastName"); RequiredFields.push(NewContactLastName);
    var NewContactAccountSelect = jQuery("[id$=NewContactAccountSelect]"); RequiredFields.push(NewContactAccountSelect);
    var NewContactRoles = jQuery("#NewContactRoles"); RequiredFields.push(NewContactRoles);
    var newProjectRolesOfContact = jQuery("#newProjectRolesOfContact"); RequiredFields.push(newProjectRolesOfContact);
    var NewContactPhone = jQuery("#NewContactPhone"); 
    var NewContactEmail = jQuery("#NewContactEmail");
    
    // clear out any previous error for the consecutive button clicks
    jQuery("[id$=NewContactErrorSummary]","#NewContactSection").html("");
    jQuery("[id$=_error]","#NewContactSection").remove();
    
    jQuery(RequiredFields).each(
        function(index,field)
        {
            if(!(field.val() && field.val() != "" && field.val() != "-- None --")) 
            { 	
                field.addClass("error"); 
                RequiredFieldsInError.push(field); 
            } 
            else { field.removeClass("error"); }
        }
    );
    
    if(RequiredFieldsInError.length > 0)
    {
        var RequiredFieldLabels = [];
        
        jQuery(RequiredFieldsInError).each(
            function(index,field)
            { 
                
                var RequiredFieldLabel = jQuery("label[for$='"+jQuery(field).attr('id')+"']").html().trim();
                RequiredFieldLabels.push(RequiredFieldLabel);
                field.after("<div id='"+field.attr("id")+"_error' class='errorMsg' style='display: inherit;'>"+RequiredFieldLabel+" is Required.</div>");
                
            });
        
        if (RequiredFieldLabels.length > 1) {
            RequiredFieldLabels[RequiredFieldLabels.length - 1] = "and " + RequiredFieldLabels[RequiredFieldLabels.length - 1];
        }
        
        jQuery("#NewContactErrorSummary","#NewContactSection")
        .html(RequiredFieldLabels.join(", ")+" "+(RequiredFieldLabels.length > 1 ? "are" : "is a")+" required field(s). ")
        .css("color","#CC0000");
        
        jQuery(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
        return;
    }
    else 
    {
        if(NewContactEmail && NewContactEmail.val() && NewContactEmail.val().length > 0 && !ValidEmail(NewContactEmail.val()))
        {
            var ErrorLabel = jQuery("label[for$="+NewContactEmail.attr('id')+"]").html().trim(); 
            NewContactEmail.after("<div id='"+NewContactEmail.attr("id")+"_error' class='errorMsg' >"+ErrorLabel+" is invalid.</div>").addClass("error");
            
            jQuery("#NewContactErrorSummary","#NewContactSection").html("The e-mail address entered is invalid. ").css("color","#CC0000");
            jQuery(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
            
            return;
        } else { NewContactEmail.removeClass("error"); }
        
        jQuery("#NewContactErrorSummary","#NewContactSection").css("color","");
        jQuery("#NewContactErrorSummary","#NewContactSection").html("Adding a new Contact and ClientContact; please wait. ");
        
        try
        {
            var jsonResult = sforce.apex.execute(
                "IMP_AddNewContact_Controller","AddContactAndClientContact",
                {
                    FirstName:NewContactFirstName.val()
                    ,LastName:NewContactLastName.val()
                    ,accountId:NewContactAccountSelect.val()
                    ,contactRole:String(NewContactRoles.val()).replace(/\,/g,"; ")
                    ,projectRole:String(newProjectRolesOfContact.val()).replace(/\,/g,"; ")
                    ,Email:NewContactEmail.val()
                    ,Phone:NewContactPhone.val()
                    ,SubProjectId:subProjectId 
                    
                });
            var result = JSON.parse(jsonResult);
            
            if(result)
            {
                if(result.Success)
                {
                    AddNewContactDialog.dialog("close"); // close the dialog
                    
                    jQuery(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
                    jQuery("#NewContactErrorSummary","#NewContactSection").html(""); // clear the message
                    
                    jQuery("input","#NewContactSection").val(""); // clear the inputs 
                    jQuery("select > option","#NewContactSection").removeAttr("selected"); // clear any selections
                    
                    // remove all selected values
                    jQuery("#NewContactRoles option").each(function(index,value){
                        jQuery(value).removeAttr("selected").detach().appendTo("#SelectableContactRoles");
                    });
                    
                    // sort the selectable values
                    var OptionsToSort = jQuery("#SelectableContactRoles option");
                    
                    OptionsToSort.sort(function(a,b) {
                        if (a.text > b.text) { return 1; }
                        else if (a.text < b.text) { return -1; }
                            else { return 0; }
                    });
                    
                    jQuery("#SelectableContactRoles option").remove();
                    jQuery("#SelectableContactRoles").append( OptionsToSort );
                    
                    //MessageBox(true,"Contact has been added.");
                    //setTimeout(function(){MessageBox(false,"Contact has been added.");},1000);
                    if(reload)
                    {
                        window.top.location.reload();
                    }
                    else
                    {
                        alert('Sub-project Client Contact created');
                    }
                    
                }
                else
                {
                    jQuery("#NewContactErrorSummary","#NewContactSection").html(result.Message);
                    jQuery("#NewContactErrorSummary","#NewContactSection").css("color","#CC0000");
                    jQuery(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
                }
            }
        }
        catch(error) {
            console.log(error.message);
            jQuery("#NewContactErrorSummary","#NewContactSection").html("Error. Please contact Administrator for Help!").css("color","#CC0000"); 
        }
        
    }
    
}

function callDialog(subProjectId, reload)
{
	try
    {
        var addNewContactDialog = jQuery("[id$='NewContactSection']");
        
		addNewContactDialog.dialog(
		{
			"minWidth": 750,
			"title": "Add a New Contact", 
			"modal": true,
			"buttons": [
				{
					"text": "Save",
					click: function() { createContactAndCC(subProjectId, reload); }
				},
				{
					"text":"Close",
					click: function(){ 
						jQuery(this).dialog("destroy");
					}
				}
			]
		});
		//parent().appendTo(jQuery("j_id0\\:newContactForm"));
		
		jQuery("#NewContactRoleSelect").on("click",function(){
			appendItemsToRight('#SelectableContactRoles', '#NewContactRoles');
		});
        
		jQuery("#NewContactRoleUnselect").on("click",function(){
			appendItemstoLeft('#NewContactRoles', '#SelectableContactRoles');
		});
        
		jQuery("#NewProjectRoleSelect").on("click",function(){
			appendItemsToRight('#SelectableProjectRoles', '#newProjectRolesOfContact');
		});
        
		jQuery("#NewProjectRoleUnselect").on("click",function(){
			appendItemstoLeft('#newProjectRolesOfContact', '#SelectableProjectRoles');
		});
		
		jQuery(".ui-dialog-titlebar-close").remove();
		addNewContactDialog.dialog('open');
        //console.log(addNewContactDialog);
		//parent().appendTo(jQuery("j_id0\\:newContactForm"));
	}
	catch(error){
		console.log(error.message);
	}
}
