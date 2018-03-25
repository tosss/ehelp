//Author: Anirudh Singh
//Description: This jQuery is used for displaying Parent and Child Records for any generic Parent Child Relationship. 
//It includes functionalities such as Save on View Mode, Editing the records and Saving them, Mass Delete and Mass Update.

var j$=jQuery.noConflict();
var selectedList;

//This method is executed after the DOM is ready.
j$(document).ready(
    function()
    {
        j$(".pbButton").siblings(".pbTitle").css("display", "none");
        j$(".pbButton").addClass("centerButtonsTop");
        j$(".pbButton").css({"position": "static", "top": "0px"});
        
        j$(window).scroll(function(e)
        {
            j$el=j$(".pbButton"); 
            if(j$(this).scrollTop()>100 && j$el.css("position")!="fixed")
            { 
                j$(".pbButton").css({"position": "fixed", "top": "0px"}); 
            }
            if(j$(this).scrollTop()<100 && j$el.css("position")=="fixed")
            {
                j$(".pbButton").css({"position": "static", "top": "0px"}); 
            } 
        });
        
        //1st June, 2015- Anirudh Singh
        //This is added for fixing the lookup auto-complete functionality.
        j$(document).delegate("input:text", "keyup", function()
        {
            if(j$(this).closest("span").attr("class")=="lookupInput")
            {
                if(j$(this).closest("div[class$='custPopup']").css("display")=="block")
                {
                    j$(".autoCompleteBoxScrolling").each(function()
                    {
                        j$(this).addClass("positionFixed");
                    });
                }
                else
                {
                    j$(".autoCompleteBoxScrolling").each(function()
                    {
                        j$(this).removeClass("positionFixed");
                    });
                }
            }
        });
        
        //4th June, 2015
        //This is added for fixing the the Date select position.
        j$(document).delegate("input:text", "click", function()
        {
            if(j$(this).closest("span").attr("class")=="dateInput dateOnlyInput")
            {
                if(j$(this).closest("div[class$='custPopup']").css("display")=="block")
                {
                    j$(".datePicker").addClass("positionFixed");
                }
                else
                {
                    j$(".datePicker").removeClass("positionFixed");
                }
            }
        });
        
        //1st June, 2015- Anirudh Singh
        //This is added for fixing the lookup issue when typing a text directly into text-box and updating.
        j$(document).delegate("input:text", "change", function()
        {
            if(j$(this).closest("span").attr("class")=="lookupInput")
            {
                if(j$(this).closest("div[class$='custPopup']").css("display")=="block")
                {
                    if(j$(this).parents('.updatedValueParent').attr('title')!=undefined)
                    {
                        var parentElement=j$(this).parent().siblings("[Id$='lkid']");
                        if(parentElement.val()==null || parentElement.val()=='')
                        {
                            ALL_ParentChildRecords_Controller.fetchUserId(j$(this).val(), j$("[Id$='parentAPIName']").val(), j$(this).parents('.updatedValueParent').attr('title'), function(result, event)
                            {
                                if(result!=null)
                                {
                                    parentElement.val(result);
                                }
                            });
                        }
                    }
                    else if(j$(this).parents('.updatedValueChild').attr('title')!=undefined)
                    {
                        var childElement=j$(this).parent().siblings("[Id$='lkid']");
                        if(childElement.val()==null || childElement.val()=='')
                        {
                            ALL_ParentChildRecords_Controller.fetchUserId(j$(this).val(), j$("[Id$='childAPIName']").val(), j$(this).parents('.updatedValueChild').attr('title'), function(result, event)
                            {
                                if(result!=null)
                                {
                                    childElement.val(result);
                                }
                            });
                        }
                    }
                }
            }
        });
        
        //5-20-2015 PH TIME Rey Austral Comment out
        //init();
        
        // 2015-05-19 matt.keefe@cdk.com tried adding an event listener to the form to run init when loaded
        //j$("[id$='formId']").onload(init);
    }
);

function init()
{
    var href=window.location.href;
    
    //if(href.indexOf('reloaded=true')>0 || (j$(displayMode).val().toLowerCase()=='edit' && !(href.indexOf('modeAdded=true')>0)))
    //if(href.indexOf('reloaded=true')>0 || (j$("#displayMode").val().toLowerCase()=='edit')) //28th May, 2015- Anirudh Singh- Commented this code
    if(j$("#displayMode").val().toLowerCase()=="edit")
    {
        editAll();
        //console.log('edit');
    }
    else
    {
        viewModeInit();
        //console.log('view');
    }
}

//This function is used to initialize the values on the page.
function viewModeInit()
{
    var childTable=j$("[Id$='childTable']").DataTable
    ({
        "bDestroy": true,
        "sPaginationType": "full_numbers",
        "bRetrieve": true,
        "bAutoWidth": false
        //25th May, 2015- Anirudh Singh
        //Commented auto-sorting as default sorting should happen by the provided columns in the childFieldSortOrderAPINames property.
        //"aaSorting" : [[1, 'asc']]
    });
    
    j$("[Id$='child_td_checkboxes']").removeClass("sorting_asc");
    
    j$("[Id$='childTable_length']").hide();
    if(j$("[Id$='enableChildSearch']").val().toLowerCase()=="false")
    {
        j$("[Id$='childTable_filter']").hide();
    }
    
    createEventBindings();
    disable(j$("[Id$='Collapse']"));
    
    j$("[Id*='child_td_checkboxes']").hide();
    j$("[Id*='create_New_Child_Record']").hide();
    
    j$(document).delegate(".paginate_button, .sorting, .sorting_desc, .sorting_asc", "click", function()
    {
        j$("[Id*='child_td_checkboxes']").hide();
        createEventBindings();
    });
    
    if(j$("[Id$='displayEditButton']").val().toLowerCase()=="false")
    {
        j$("[Id$='EditRecords']").hide();
    }
}

//This function is used for adding the pencil image on hovering over parent or child fields in view mode.
function createEventBindings()
{
    var fieldAccessible=false;
    var fieldUpdateable=false;
    j$("[Id$='parentInOutFields']").each(function()
    {
        fieldAccessible=j$(this).find("[Id$='fieldAccessibleParent']").val();
        fieldUpdateable=j$(this).find("[Id$='fieldUpdateableParent']").val();
        
        if(fieldAccessible=="true" && fieldUpdateable=="true")
        {
            j$(this).hover
            (
                function()
                {
                    j$(this).addClass("hoverEditableField");
                },
                function()
                {
                    j$(this).removeClass("hoverEditableField");
                }
            );
        }
    });
    
    j$("[Id$='childInOutFields']").each(function()
    {
        fieldAccessible=j$(this).find("[Id$='fieldAccessibleChild']").val();
        fieldUpdateable=j$(this).find("[Id$='fieldUpdateableChild']").val();
        
        if(fieldAccessible=="true" && fieldUpdateable=="true")
        {
            j$(this).hover
            (
                function()
                {
                    j$(this).addClass("hoverEditableField");
                },
                function()
                {
                    j$(this).removeClass("hoverEditableField");
                }
            );
        }
    });
}

//This function is used to expand the child records on the page.
function expandAll()
{
    disable(j$("[Id$='Expand']"));
    enable(j$("[Id$='Collapse']"));
    
    j$(".child_td_content").show();
    j$(".btnExpand").hide();
    j$(".btnCollapse").show();
    
    var divParent=j$(".child_td_content").parent();
    var h3=j$(divParent).find("h3");
    j$(h3).addClass("expand");
}

//This function is used to collapse the child records on the page.
function collapseAll()
{
    disable(j$("[Id$='Collapse']"));
    enable(j$("[Id$='Expand']"));
    
    j$(".child_td_content").hide();
    j$(".btnExpand").show();
    j$(".btnCollapse").hide();
    
    var divParent=j$(".child_td_content").parent();
    var h3=j$(divParent).find("h3");
    j$(h3).removeClass("expand");
}

//This function is used to disable the Expand All or Collapse All buttons.
//It is invoked from expandAll and collapseAll methods.
function disable(element)
{
    j$(element).attr("disabled", "disabled");
    j$(element).css("border-color", "#c4c4c4");
    j$(element).css("color", "#909090");
}

//This function is used to enable the Expand All or Collapse All buttons.
//It is invoked from expandAll and collapseAll methods.
function enable(element)
{
    j$(element).removeAttr("disabled");
    j$(element).css("border-color", "");
    j$(element).css("color", "");
}

//This method is invoked from the link above the Child Table with a + icon to expand the table or - icon to collapse it.
function collapseExpandSelected(control)
{
    var element=j$(control).siblings("[Id$='childDataTableStart']");
    
    if(j$(element).css("display")=="none")
    {
        j$(element).show();
        j$(control).addClass("expand");
    }
    else
    {
        j$(element).hide();
        j$(control).removeClass("expand");
    }
    
    var noOfChildTables=0;
    var noOfChildTablesDisplayed=0;
    
    j$("[Id$='childDataTableStart']").each(function()
    {
        noOfChildTables++;
        if(j$(this).css("display")=="block")
        {
            noOfChildTablesDisplayed++;
        }
    });
    
    if(noOfChildTables==noOfChildTablesDisplayed)
    {
        enable(j$("[Id$='Collapse']"));
        disable(j$("[Id$='Expand']"));
    }
    else if(noOfChildTablesDisplayed==0)
    {
        disable(j$("[Id$='Collapse']"));
        enable(j$("[Id$='Expand']"));
    }
    else if(noOfChildTables>noOfChildTablesDisplayed)
    {
        enable(j$("[Id$='Collapse']"));
        enable(j$("[Id$='Expand']"));
    }
}

//This function is used for editing the records.
//It changes the view mode of the page to edit mode and display the input fields for both parent and child records.
function editAll()
{
    j$(".child_td_content").show();
    j$(".btnExpand").hide();
    j$(".btnCollapse").show();
    
    j$("[Id$='CancelButton']").css("display", "");
    j$("[Id$='EditRecords']").css("display", "none");
    
    if(j$("[Id$='displayQuickSaveButton']").val().toLowerCase()=="false")
    {
        j$("[Id$='SaveButton']").hide();
    }
    else
    {
        j$("[Id$='SaveButton']").css("display", "");
    }
    
    if(j$("[Id$='displaySaveButton']").val().toLowerCase()=="false")
    {
        j$("[Id$='SaveCloseButton']").hide();
    }
    else
    {
        j$("[Id$='SaveCloseButton']").css("display", "");
    }
    
    if(j$("[Id$='displayDeleteButton']").val().toLowerCase()=="false")
    {
        j$("[Id$='DeleteButton']").hide();
    }
    else
    {
        j$("[Id$='DeleteButton']").css("display", "");
    }
    
    if(j$("[Id$='displayMassUpdateButton']").val().toLowerCase()=="false")
    {
        j$("[Id$='MassUpdateRecButton']").hide();
    }
    else
    {
        j$("[Id$='MassUpdateRecButton']").css("display", "");
    }
    
    if(j$("[Id$='displayCreateNewChildButton']").val().toLowerCase()=="false")
    {
        j$("[Id$='create_New_Child_Record']").hide();
    }
    else
    {
        j$("[Id$='create_New_Child_Record']").show();
    }
    
    //2015-05-14 IST Date Anirudh Singh
    if(j$("[Id$='displayCreateNewParentButton']").val().toLowerCase()=="false")
    {
        j$("[Id$='createNewParent']").hide();
    }
    else
    {
        j$("[Id$='createNewParent']").show();
    }
    
    j$(".pbButton").siblings(".pbTitle").css("display", "none");
    j$(".pbButton").addClass("centerButtonsTop");
    j$(".pbButton").css({"position": "static", "top": "0px"});
    
    j$(window).scroll(
        function(e)
        { 
            j$el=j$(".pbButton"); 
            if(j$(this).scrollTop()>100 && j$el.css("position")!="fixed")
            { 
                j$(".pbButton").css({"position": "fixed", "top": "0px"}); 
            }
            if(j$(this).scrollTop()<100 && j$el.css("position")=="fixed")
            {
                j$(".pbButton").css({"position": "static", "top": "0px"}); 
            } 
        }
    );
    
    var divParent=j$(".child_td_content").parent();
    var h3=j$(divParent).find("h3");
    j$(h3).addClass("expand");
    
    var childTable=j$("[Id$='childTable']").DataTable
    ({
        "bDestroy": true,
        "sPaginationType": "full_numbers",
        "bRetrieve": true,
        "bAutoWidth": false,
        "aoColumnDefs": [{ "bSortable":false, "aTargets":[0] }]
        //25th May, 2015- Anirudh Singh
        //Commented auto-sorting as default sorting should happen by the provided columns in the childFieldSortOrderAPINames property.
        //"aaSorting" : [[1, 'asc']]
    });
    
    j$("[Id$='child_td_checkboxes']").removeClass("sorting_asc");
    
    j$("[Id$='childTable_length']").hide();
    
    if(j$("[Id$='enableChildSearch']").val().toLowerCase()=="false")
    {
        j$("[Id$='childTable_filter']").hide();
    }
    
    j$("[Id$='child_td_checkboxes']").show();
    
    j$("[Id*='parent_td_input_field']").find("select[title='Search scope']").each(function()
    {
        if(j$(this).next().prop("tagName")!="BR")
        {
            j$("<br/><br/>").insertAfter(this);
        }
    });
    
    //Display Parent Header Checkboxes when in Edit Mode.
    var parentHRCheckbox=j$("[Id$='parentHeaderCheckbox']");
    parentHRCheckbox.each(function()
    {
        j$(this).removeClass("showCheckboxParentHeader");
        j$(this).addClass("parent_header_th");
    });
    
    //Display Parent Row Checkboxes when in Edit Mode.
    var parentTRCheckbox=j$("[Id$='parentRowCheckbox']");
    parentTRCheckbox.each(function()
    {
        j$(this).removeClass("showCheckboxForParentData");
        j$(this).addClass("parent_data_td");
    });
    
    //Display Parent Input Fields when in Edit Mode.
    var parentInputFields=j$("[Id*='parent_td_input_field']");
    parentInputFields.each(function()
    {
        j$(this).removeClass("showFieldsInEditMode");
    });
    
    //Do not display Parent Records Link when in Edit Mode.
    var hideParentRecLinks=j$("[Id$='nameLinkParentRec']");
    hideParentRecLinks.each(function()
    {
        j$(this).addClass("showFieldsInEditMode");
    });
    
    //Do not display Parent Output Fields when in Edit Mode.
    var hideParentOutputFields=j$("[Id$='fieldDataParentRec']");
    hideParentOutputFields.each(function()
    {
        j$(this).addClass("showFieldsInEditMode");
    });
    
    //Display Child Input Fields when in Edit Mode.      
    var childInputFieldControl=j$("[Id$='child_td_input_field']");
    childInputFieldControl.each(function()
    {
        j$(this).removeClass("showChildFieldsInEditMode");
    });
    
    //Do not display Child Record Links in Edit Mode.
    var hideChildRecLinks=j$("[Id$='child_td_input_field']").siblings("[Id$='nameLinkChildRec']");
    hideChildRecLinks.each(function()
    {
        j$(this).addClass("showFieldsInEditMode");
    });
    
    //Do not display Child Record Output Fields in Edit Mode.
    var hideChildOutputFields=j$("[Id$='child_td_input_field']").siblings("[Id$='fieldDataChildRec']");
    hideChildOutputFields.each(function()
    {
        j$(this).addClass("showFieldsInEditMode");
    });
    
    j$("[Id$='parentInOutFields']").prop("ondblclick", "");
    j$("[Id$='childInOutFields']").prop("ondblclick", "");
    
    enable(j$("[Id$='Collapse']"));
    disable(j$("[Id$='Expand']"));
    
    j$(document).delegate(".paginate_button, .sorting, .sorting_desc, .sorting_asc", "click", function(event)
    {
        removeEventBindings();
        
        j$("[Id$='childTable_length']").hide();
        
        j$("[Id$='child_td_checkboxes']").show();
        j$("[Id$='child_td_checkboxesRow']").show();
        
        //Display Child Input Fields when in Edit Mode.      
        var childInputFieldControl=j$("[Id$='child_td_input_field']");
        childInputFieldControl.each(function()
        {
            j$(this).removeClass("showChildFieldsInEditMode");
        });
        
        //Do not display Child Record Links in Edit Mode.
        var hideChildRecLinks=j$("[Id$='child_td_input_field']").siblings("[Id$='nameLinkChildRec']");
        hideChildRecLinks.each(function()
        {
            j$(this).addClass("showFieldsInEditMode");
        });
        
        //Do not display Child Record Output Fields in Edit Mode.
        var hideChildOutputFields=j$("[Id$='child_td_input_field']").siblings("[Id$='fieldDataChildRec']");
        hideChildOutputFields.each(function()
        {
            j$(this).addClass("showFieldsInEditMode");
        });
        
        j$("[Id$='childInOutFields']").prop("ondblclick", "");
    });
}

//This function is used for removing the pencil image on hovering over parent or child fields in edit mode.
function removeEventBindings()
{
    j$("[Id$='parentInOutFields']").hover
    (
        function()
        {
            j$(this).removeClass("hoverEditableField");
        }
    );
    
    j$("[Id$='childInOutFields']").hover
    (
        function()
        {
            j$(this).removeClass("hoverEditableField");
        }
    );
}

//This is invoked from the parent row checkbox. It disables or enables Child checkboxes.
function disableChildCheckboxes()
{
    var noOfParentChecked=j$("[Id$='chkParentSelected']:checked").length;
    
    if(noOfParentChecked>0)
    {
        j$("[Id$='selectAllChilds']").prop("disabled", true);
        j$("[Id$='selectAllChilds']").attr("checked", false);
        j$("[Id$='child_AllCheckbox_Selected']").prop("disabled", true);
        j$("[Id$='child_AllCheckbox_Selected']").attr("checked", false);
    }
    else
    {
        j$("[Id$='selectAllChilds']").prop("disabled", false);
        j$("[Id$='child_AllCheckbox_Selected']").prop("disabled", false);
    }
}

//This method is invoked from the child table header checkbox.
//It is used to select all the child row checkboxes.
function selectAllRecords(control)
{
    var checkBoxValue=j$(control).prop("checked");
    var table=j$(control).closest("table");
    var checkboxSelected=j$(table).find("td input:checkbox[Id$='child_AllCheckbox_Selected']");
    
    if (checkboxSelected.length!=0)
    {
        j$(checkboxSelected).prop("checked", checkBoxValue);
    }
    
    noOfTotalCheckboxesChecked=j$("[Id$='selectAllChilds']:checked").length + j$("[Id$='child_AllCheckbox_Selected']:checked").length;
    
    if(noOfTotalCheckboxesChecked>0)
    {
        j$("[Id$='chkParentSelected']").prop("disabled", true);
        j$("[Id$='chkParentSelected']").attr("checked", false);
    }
    else if(noOfTotalCheckboxesChecked==0)
    {
        j$("[Id$='chkParentSelected']").prop("disabled", false);
    }
}

//This method is used for clearing the checked checkboxes in the child table, based on the conditions.
function clearSelectAllChildCheckbox(control)
{
    var checkBoxValue=j$(control).prop("checked");
    var table=j$(control).closest("table");
    var checkboxSelected=j$(table).find("th input:checkbox[Id$='selectAllChilds']");
    var noOfCheckboxes=j$(table).find("td input:checkbox[Id$='child_AllCheckbox_Selected']").length;
    var noOfCheckboxesChecked=j$(table).find("td input:checkbox[Id$='child_AllCheckbox_Selected']:checked").length;
    
    if(checkBoxValue==false && (j$(checkboxSelected).prop("checked")==true))
    {
        j$(checkboxSelected).prop("checked", false);
    }
    else if(checkBoxValue==true && noOfCheckboxes==noOfCheckboxesChecked)
    {
        j$(checkboxSelected).prop("checked", true);
    }
    
    noOfTotalCheckboxesChecked=j$("[Id$='selectAllChilds']:checked").length + j$("[Id$='child_AllCheckbox_Selected']:checked").length;
    if(noOfTotalCheckboxesChecked>0)
    {
        j$("[Id$='chkParentSelected']").prop("disabled", true);
        j$("[Id$='chkParentSelected']").attr("checked", false);
    }
    else if(noOfTotalCheckboxesChecked==0)
    {
        j$("[Id$='chkParentSelected']").prop("disabled", false);
    }
}

//This method is invoked from the Delete Button.
//It displays appropriate error or confirmation messages, depending upon certain conditions.
function confirmAndDelete()
{
    var noOfParentChecked=j$("[Id$='chkParentSelected']:checked").length;
    var noOfChildChecked=j$("[Id$='child_AllCheckbox_Selected']:checked").length;
    
    if(noOfParentChecked==0 && noOfChildChecked==0)
    {
        j$("<div>").html("No record(s) selected for deletion. Please select any record(s) in the table.").dialog
        ({
            "modal": true,
            "title": "Error Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons": 
            {
                "Ok": function()
                {
                    j$(this).dialog("close");
                }
            }
        }); 
    }
    else if(noOfParentChecked>0)
    {
        var objName=j$("[Id$='parentName']").val();
        var response=j$("<div>").html("Are you sure to delete the selected "+noOfParentChecked+" "+objName+" record(s)?").dialog
        ({
            "modal": true,
            "title": "Confirmation Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons": 
            {
                "Ok": function()
                {
                    if(response)
                    {
                        deleteRecords(noOfParentChecked, noOfChildChecked);
                    }
                    j$(this).dialog("close");
                },
                "Cancel": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
    else if(noOfChildChecked>0)
    {
        var objName=j$("[Id$='childName']").val();
        var response=j$("<div>").html("Are you sure to delete the selected "+noOfChildChecked+" "+objName+" record(s)?").dialog
        ({
            "modal": true,
            "title": "Confirmation Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons": 
            {
                "Ok": function()
                {
                    if(response)
                    {
                        deleteRecords(noOfParentChecked, noOfChildChecked);
                    }
                    j$(this).dialog("close");
                },
                "Cancel": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
}

//This method is used for deleting the selected Parent or Child records.
function deleteRecords(noOfParentChecked, noOfChildChecked)
{
    var recIdList=new Array();
    
    if(noOfParentChecked>0)
    {
        j$("[Id$='chkParentSelected']:checked").each(function()
        {
            recIdList.push(j$(this).siblings("[Id$='parentRecId']").val());
        });
        
        ALL_ParentChildRecords_Controller.deleteRecords(recIdList, function(result, event)
        {
            errorMessagesDelete(JSON.stringify(result), "parentRec");
        });
    }
    else if(noOfChildChecked>0)
    {
        j$("[Id$='child_AllCheckbox_Selected']:checked").each(function()
        {
            recIdList.push(j$(this).siblings("[Id$='childRecId']").val());
        });
        
        ALL_ParentChildRecords_Controller.deleteRecords(recIdList, function(result, event)
        {
            errorMessagesDelete(JSON.stringify(result), "childRec");
        });
    }
}

//This function is used to check the checkbox for the rows which have been changed for the Parent Records.
function selectParentRowForSave(control)
{
    var checkbox=j$(control).closest("[Id$='parentRecRow']").find("[Id$='chkParentSelected']");
    
    if(j$(checkbox).prop("checked")==false)
    {
        j$(checkbox).prop("checked", true);
    }
    
    disable(j$("[Id$='MassUpdateRecButton']"));
    disable(j$("[Id$='DeleteButton']"));
    j$("[Id$='ClearAllChanges']").css("display", "");
    j$("[Id$='saveMessage']").css("display", "block");
    
    if(j$(control).closest("[Id$='parentRecRow']").find("[Id$='parentRecId']").val()!="" 
       && j$(control).closest("[Id$='parentRecRow']").find("[Id$='parentRecId']").val()!=null)
    {
        disable(j$("[Id$='createNewChild']"));
    }
}

//This function is used to check the checkbox for the rows which have been changed for the Child Records.
function selectChildRowForSave(control)
{
    var checkbox=j$(control).closest("[Id$='childInOutFields']").siblings("[Id$='child_td_checkboxesRow']").find("[Id$='child_AllCheckbox_Selected']");
    
    if(j$(checkbox).prop("checked")==false)
    {
        j$(checkbox).prop("checked", true);
    }
    
    disable(j$("[Id$='MassUpdateRecButton']"));
    disable(j$("[Id$='DeleteButton']"));
    j$("[Id$='ClearAllChanges']").css("display", "");
    j$("[Id$='saveMessage']").css("display", "block");
    
    if(j$(control).closest("[Id$='childInOutFields']").siblings("[Id$='child_td_checkboxesRow']").find("[Id$='childRecId']").val()!="" 
       && j$(control).closest("[Id$='childInOutFields']").siblings("[Id$='child_td_checkboxesRow']").find("[Id$='childRecId']").val()!=null)
    {
        disable(j$("[Id$='createNewChild']"));
    }
}

//This function is used to bring the table to the initial stage,
//if the user wants to revert all the changes made on Parent and Child records on the table.
function clearAllChanges()
{
    if(j$("[Id$='showChildRecForNewParentMessage']").val().toLowerCase()=="true")
    {
        j$("<div>").html("Please create a Child record for the new Parent.").dialog
        ({
            "modal": true,
            "title": "Information Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons":
            {
                "Ok": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
    else
    {
        var confirm=j$("<div>").html("Do you want to revert all the changes made on the record(s) below?").dialog
        ({
            "modal": true,
            "title": "Confirmation Message",
            width: "auto",
            create: function( event, ui )
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons":
            {
                "Ok": function()
                {
                    if(confirm)
                    {
                        refreshMyPanel();
                    }
                    j$(this).dialog("close");
                },
                "Cancel": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
}

//This function is used for Creating New Child functionality.
function createNewChild()
{
    editAll();
    disable(j$("[Id$='MassUpdateRecButton']"));
    disable(j$("[Id$='DeleteButton']"));
    j$("[Id$='ClearAllChanges']").css("display", "");
    j$("[Id$='newRecordsMsg']").css("display", "block");
}

//2015-05-14 IST Date Anirudh Singh
//This function is used for Creating New Parent functionality.
function createNewParent()
{
    editAll();
    disable(j$("[Id$='MassUpdateRecButton']"));
    disable(j$("[Id$='DeleteButton']"));
    j$("[Id$='ClearAllChanges']").css("display", "");
    disable(j$("[Id$='createNewChild']"));
    disable(j$("[Id$='createNewParent']"));
}

//This function is used to check if there are records to save.
//If there are no records for saving a info message is displayed.
function checkValidSave(control)
{   
    if((j$("[Id$='chkParentSelected']:checked").length==0) && (j$("[Id$='child_AllCheckbox_Selected']:checked").length==0))
    {
        j$("<div>").html("Sorry, there is nothing to save.").dialog
        ({
            "modal": true,
            "title": "Information Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons":
            {
                "Ok": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
    else
    {
        if(j$(control).attr('id')=='SaveButton')
        {
            saveFunction();
        }
        else if(j$(control).attr('id')=='SaveCloseButton')
        {
            saveAndCloseFunction();
        }
    }
}

//This method is used for Save functionality.
function save()
{
    if(j$(".messageCell").prop("tagName")!=="TD")
    {
        editAll();
    }
    else
    {
        editAll();
        disable(j$("[Id$='MassUpdateRecButton']"));
        disable(j$("[Id$='DeleteButton']"));
        j$("[Id$='ClearAllChanges']").css("display", "");
        disable(j$("[Id$='createNewParent']"));
    }
    
    var displayChildMsg=false;
    
    j$("[Id$='child_AllCheckbox_Selected']:checked").each(function()
    {
        if(j$(this).siblings("[Id$='childRecId']").val()=="" || j$(this).siblings("[Id$='childRecId']").val()==null)
        {
            displayChildMsg=true;
            return false;
        }
    });
    
    if(displayChildMsg=="false")
    {
        j$("[Id$='newRecordsMsg']").css("display", "none");
    }
}

//This function is used for Save and Close functionality.
function saveAndClose()
{
    var href=window.location.href;
    
    if(j$(".messageCell").prop("tagName")!="TD" && 
       (j$("[Id$='redirectURLLocation']").val()==null || j$("[Id$='redirectURLLocation']").val()==""))
    {
        // 2015-05-19 matt.keefe@cdk.com need to remove window.open to preserve selections
        // consider using actionfunctions to rerender
        //window.open(href,'_self'); 
        
        //21st May, 2015- Anirudh Singh
        saveAndCloseMethod();
    }
    else if(j$(".messageCell").prop("tagName")!="TD" && 
            j$("[Id$='redirectURLLocation']").val()!=null && j$("[Id$='redirectURLLocation']").val()!="")
    {
        if(j$("[Id$='redirectURLLocation']").val().toLowerCase().indexOf("http://")>-1 || 
           j$("[Id$='redirectURLLocation']").val().toLowerCase().indexOf("https://")>-1)
        {
            window.open(j$("[Id$='redirectURLLocation']").val(), "_self");
        }
        else
        {
            var tempUrl="http://"+j$("[Id$='redirectURLLocation']").val();
            window.open(tempUrl, "_self");
        }
    }
    else
    {
        editAll();
        disable(j$("[Id$='MassUpdateRecButton']"));
        disable(j$("[Id$='DeleteButton']"));
        j$("[Id$='ClearAllChanges']").css("display", "");
        disable(j$("[Id$='createNewParent']"));
    }
}

//This function is used for updating the parent fields in view mode.
function fieldUpdate(control)
{
    var fieldAccessible=false;
    var fieldUpdateable=false;
    
    if(j$(control).find("[Id$='objectType']").val()=="Parent")
    {
        fieldAccessible=j$(control).find("[Id$='fieldAccessibleParent']").val();
        fieldUpdateable=j$(control).find("[Id$='fieldUpdateableParent']").val();
    }
    else if(j$(control).find("[Id$='objectType']").val()=="Child")
    {
        fieldAccessible=j$(control).find("[Id$='fieldAccessibleChild']").val();
        fieldUpdateable=j$(control).find("[Id$='fieldUpdateableChild']").val();
    }
    
    //If the field is accessible then only do further processing, else not.
    if(fieldAccessible=="true" && fieldUpdateable=="true")
    {
        var fieldName=null;
        var recordId=null;
        
        if(j$(control).find("[Id*='parent_td_input_field']").prop("tagName")!=undefined)
        {
            fieldName=j$(control).find("[Id*='parent_td_input_field']").next().prop("title");
            recordId=j$(control).closest("[Id$='parentRecRow']").find("[Id$='parentRecId']").val();
        }
        else
        {
            fieldName=j$(control).find("[Id*='child_td_input_field']").next().prop("title");
            recordId=j$(control).siblings("[Id$='child_td_checkboxesRow']").find("[Id$='childRecId']").val();
        }
        
        if(fieldName!=null && recordId!=null)
        {
            fieldUpdatePanel(fieldName, recordId);
        }
    }
    else
    {
        j$("<div>").html("Sorry, you can not edit this field.").dialog
        ({
            "modal": true,
            "title": "Error Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons":
            {
                "Ok": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
}

//This function is used to display the updated field value in view mode.
//This function is invoked from Save button on Field Update Panel in View Mode.
function viewMode()
{
    var childTable=j$("[Id$='childTable']").DataTable
    ({
        "bDestroy": true,
        "sPaginationType": "full_numbers",
        "bRetrieve": true,
        "bAutoWidth": false
        //25th May, 2015- Anirudh Singh
        //Commented auto-sorting as default sorting should happen by the provided columns in the childFieldSortOrderAPINames property.
        //"aaSorting" : [[1, 'asc']]
    });
    
    j$("[Id$='child_td_checkboxes']").removeClass("sorting_asc");
    
    j$("[Id$='childTable_length']").hide();
    if(j$("[Id$='enableChildSearch']").val().toLowerCase()=="false")
    {
        j$("[Id$='childTable_filter']").hide();
    }
    
    createEventBindings();
    expandAll();
    
    j$("[Id*='child_td_checkboxes']").hide();
    j$("[Id*='create_New_Child_Record']").hide();
    
    j$(".pbButton").siblings(".pbTitle").css("display", "none");
    j$(".pbButton").addClass("centerButtonsTop");
    j$(".pbButton").css({"position": "static", "top": "0px"});
    
    j$(window).scroll(function(e)
    { 
        j$el=j$(".pbButton"); 
        if(j$(this).scrollTop()>100 && j$el.css("position")!="fixed")
        { 
            j$(".pbButton").css({"position": "fixed", "top": "0px"}); 
        }
        if(j$(this).scrollTop()<100 && j$el.css("position")=="fixed")
        {
            j$(".pbButton").css({"position": "static", "top": "0px"}); 
        } 
    });
    
    j$(document).delegate(".paginate_button, .sorting, .sorting_desc, .sorting_asc", "click", function(event)
    {
        j$("[Id*='child_td_checkboxes']").hide();
        createEventBindings();
    });
}

//This method is used for Mass Updating the Parent or Child records.
//This method is invoked from button with Id=MassUpdateRecButton.
function massUpdateRecords()
{
    var noOfParentChecked=j$("[Id$='chkParentSelected']:checked").length;
    var noOfChildChecked=j$("[Id$='child_AllCheckbox_Selected']:checked").length;
    
    if(noOfParentChecked>0)
    {
        selectionParentPanel();
    }
    else if(noOfChildChecked>0)
    {
        selectionChildPanel();
    }
    else
    {
        j$("<div>").html("No record selected for Mass Update. Please select records in the table.").dialog
        ({
            "modal": true,
            "title": "Error Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons":
            {
                "Ok": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
}

//This function is invoked on complete event of the actionFunction named selectionParentPanel.
function showParentSelectionPanel()
{
    j$("[Id$='parentFieldSelectionPanel']").css("display", "block");
}

//This method is invoked from the Continue button in parentFieldSelectionPanel outputPanel.
function setValuesParent()
{
    if(j$("[id$='selectedParentField']:checked").length>0)
    {
        selectedList=new Array();
        
        j$("[id$='selectedParentField']:checked").each(function()
        {
            var Label=j$(this).siblings("[Id$='selectedParentFieldLabel']").val(); 
            selectedList.push(Label);
        });
        j$("[Id$='selectionErrorMessageParent']").css("display", "none");
        
        displayParentMUPanel();
    }
    else
    {
        j$("[Id$='selectionErrorMessageParent']").css("display", "block");
    }
}

//This method is invoked from setValuesParent function.
function displayParentMUPanel()
{
    j$("[Id$='parentFieldSelectionPanel']").css("display", "none");
    
    j$("[Id$='parentMassUpdatePanel']").find("table").find("label").each(function()
    {
        var labValue=j$(this).html();
        if(!contains(labValue))
        {
            j$(this).parent().parent().hide();
        }
    });
    
    j$("[Id$='parentMassUpdatePanel']").css("display", "block");
}

//This method is invoked from the Cancel button in parentFieldSelectionPanel outputPanel.
function closeParentFSPanel()
{
    j$("[Id$='parentFieldSelectionPanel']").css("display", "none");
    j$("[Id$='parentMassUpdatePanel']").css("display", "none");
}

//This method is invoked from the Previous button in parentMassUpdatePanel outputPanel.
function renderSelectionPanelParent()
{
    j$("[Id$='selectedParentField']").attr("checked", false);
    selectionParentPanel();
}

//This method is invoked from the Update button in parentMassUpdatePanel outputPanel.
function updateValuesParent()
{
    var updatedValues=new Array();
    var APINamesList=new Array();
    
    j$("[Id$='pInputField']").each(function()
    {
        if(j$(this).closest("tr").css("display")!="none")
        {
            if(j$(this).parent().attr("class")=="lookupInput")
            {
                updatedValues.push(j$(this).parent().siblings("[Id$='_lkid']").val());
            }
            else if(j$(this).attr("type")=="checkbox")
            {
                updatedValues.push(j$(this).prop("checked"));
            }
            else
            {
                updatedValues.push(j$(this).val());
            }
            APINamesList.push(j$(this).parents(".updatedValueParent").attr("title"));
        }
    });
    
    j$("[Id$='pMUPanel']").find("[Id$='pInputField_selected']").each(function()
    {
        if(j$(this).closest("tr").css("display")!="none")
        {
            var value='';
            
            j$(this).find("option").each(function()
            {
                value+=j$(this).html()+'; ';
            });
            
            updatedValues.push(value);
            
            APINamesList.push(j$(this).parents(".updatedValueParent").attr("title"));
        }
    });
    
    var ObjectName=j$("[Id$='parentAPIName']").val();
    
    var IdList=new Array();
    
    j$("[Id$='chkParentSelected']:checked").each(function()
    {
        IdList.push(j$(this).next().val());
    });
    
    ALL_ParentChildRecords_Controller.MassUpdate(ObjectName, IdList, APINamesList, updatedValues, function(result, event)
    {
        //2nd June, 2015- Anirudh Singh
        if(result!=null)
        {
            errorMessagesMassUpdate(JSON.stringify(result), "parentRec");
        }
    });
    
    j$("[Id$='parentConfirmationPanel']").hide();
}

//This method is invoked from the Cancel button in parentMassUpdatePanel outputPanel.
function closeParentMUPanel()
{
    j$("[Id$='parentMassUpdatePanel']").css("display", "none");
}

//This function is invoked on complete event of the actionFunction named selectionChildPanel.
function showChildSelectionPanel()
{
    j$("[Id$='childFieldSelectionPanel']").css("display", "block");
}

//This method is invoked from the Continue button in childFieldSelectionPanel outputPanel.
function setValuesChild()
{
    if(j$("[Id$='selectedChildField']:checked").length>0)
    {
        selectedList=new Array();
        
        j$("[Id$='selectedChildField']:checked").each(function()
        {
            var Label=j$(this).siblings("[Id$='selectedChildFieldLabel']").val(); 
            selectedList.push(Label);
        });
        
        j$("[Id$='selectionErrorMessageChild']").css("display", "none");
        
        displayChildMUPanel();
    }
    else
    {
        j$("[Id$='selectionErrorMessageChild']").css("display", "block");
    }
}

//This method is invoked from setValuesChild function.
function displayChildMUPanel()
{
    j$("[Id$='childFieldSelectionPanel']").css("display", "none");
    
    j$("[Id$='childMassUpdatePanel']").find("table").find("label").each(function()
    {
        var labValue=j$(this).html();
        
        if(!contains(labValue))
        {
            j$(this).parent().parent().hide();
        }
    });
    
    j$("[Id$='childMassUpdatePanel']").css("display", "block");
}

//This method is invoked from the Cancel button in childFieldSelectionPanel outputPanel.
function closeChildFSPanel()
{
    j$("[Id$='childFieldSelectionPanel']").css("display", "none");
    j$("[Id$='childMassUpdatePanel']").css("display", "none");
}

//This method is invoked from the Previous button in childMassUpdatePanel outputPanel.
function renderSelectionPanelChild()
{
    j$("[Id$='selectedChildField']").attr("checked", false);
    selectionChildPanel();
}

//This method is invoked from the Update button in childMassUpdatePanel outputPanel.
function updateValuesChild()
{
    var updatedValues=new Array();
    var APINamesList=new Array();
    
    j$("[Id$='cInputField']").each(function()
    {
        if(j$(this).closest("tr").css("display")!="none")
        {
            if(j$(this).parent().attr("class")=="lookupInput")
            {
                updatedValues.push(j$(this).parent().siblings("[Id$='_lkid']").val());
            }
            else if(j$(this).attr("type")=="checkbox")
            {
                updatedValues.push(j$(this).prop("checked"));
            }
            else
            {
                updatedValues.push(j$(this).val()); 
            }
            APINamesList.push(j$(this).parents(".updatedValueChild").attr("title"));
        }
    });
    
    j$("[Id$='cMUPanel']").find("[Id$='cInputField_selected']").each(function()
    {
        if(j$(this).closest("tr").css("display")!="none")
        {
            var value='';
            
            j$(this).find("option").each(function()
            {
                value+=j$(this).html()+'; ';
            });
            
            updatedValues.push(value);
            
            APINamesList.push(j$(this).parents(".updatedValueChild").attr("title"));
        }
    });
    
    var ObjectName=j$("[Id$='childAPIName']").val();
    
    var IdList=new Array();
    
    j$("[Id$='child_AllCheckbox_Selected']:checked").each(function()
    {
        IdList.push(j$(this).next().val());
    });
    
    ALL_ParentChildRecords_Controller.MassUpdate(ObjectName, IdList, APINamesList, updatedValues, function(result, event)
    {
        //2nd June, 2015- Anirudh Singh
        if(result!=null)
        {
            errorMessagesMassUpdate(JSON.stringify(result), "childRec");
        }
    }
	);
    j$("[Id$='childConfirmationPanel']").hide();
}

//This method is invoked from the Cancel button in childMassUpdatePanel outputPanel.
function closeChildMUPanel()
{
    j$("[Id$='childMassUpdatePanel']").css("display", "none");
}

//This method is used for comparing the selected Fields by the User and all the fields present.
function contains(labValue)
{
    for(var i=0; i<selectedList.length; i++)
    {
        if(selectedList[i]==labValue)
        {
            return true;
        }
    }
    return false;
}

//This method is used for reloading the page on Mass Update Parent or Child records.
function ReloadMassUpdate()
{
    // 2015-05-19 matt.keefe@cdk.com need to remove window.open to preserve selections
    // consider using actionfunctions to rerender
    //window.open(href,'_self');
    
    //The If and Else blocks are added for proper error handling for Mass Update Scenario.
    if(j$(".messageCell").prop("tagName")!=="TD")
    {
        //28th May, 2015- Anirudh Singh- Invoking actionFunction massUpdateMethod
        massUpdateMethod();
	}
    else
    {
        editAll();
        disable(j$("[Id$='SaveButton']"));
        disable(j$("[Id$='SaveCloseButton']"));
        disable(j$("[Id$='DeleteButton']"));
        disable(j$("[Id$='createNewParent']"));
        j$("[Id$='ClearAllChanges']").css("display", "");
    }
}

//This method is used for reloading the page on Mass Update Parent or Child records.
function Cancel()
{
    if(j$("[Id$='showChildRecForNewParentMessage']").val().toLowerCase()=="true")
    {
        j$("<div>").html("Please create a Child record for the new Parent.").dialog
        ({
            "modal": true,
            "title": "Information Message",
            width: "auto",
            create: function(event, ui)
            {
                // Set maxWidth
                j$(this).css("maxWidth", "600px");
            },
            "buttons":
            {
                "Ok": function()
                {
                    j$(this).dialog("close");
                }
            }
        });
    }
    else
    {
        var href=window.location.href;
        
        if(j$("[Id$='redirectURLLocation']").val()!=null && j$("[Id$='redirectURLLocation']").val()!="")
        {
            if (j$("[Id$='redirectURLLocation']").val().toLowerCase().indexOf("http://")>-1 || 
                j$("[Id$='redirectURLLocation']").val().toLowerCase().indexOf("https://")>-1)
            {
                window.open(j$("[Id$='redirectURLLocation']").val(), "_self");
            }
            else
            {
                var tempUrl="http://"+j$("[Id$='redirectURLLocation']").val();
                window.open(tempUrl, "_self");
            }
        }
        else
        {
            // 2015-05-19 matt.keefe@cdk.com need to remove window.open to preserve selections
            // consider using actionfunctions to rerender and call init method again
            //21st May, 2015- Anirudh Singh- Invoking actionFunction cancelMethod
            cancelMethod();
        }
    }
}

//22nd May, 2015- Anirudh Singh
function createNewParentFunction()
{
    if(j$("[Id$='fetchGrandparentRelationshipField']").val()!=null && j$("[Id$='fetchGrandparentRelationshipField']").val()!="")
    {
        createNewParentWGrandparent();
    }
    else
    {
        createNewParentWOGrandparent();
    }
}

//22nd May, 2015- Anirudh Singh
function closeGrandparentPanelFunction()
{
    if(j$("[Id$='selectedGrandparent']").val()!=null)
    {
        j$("[Id$='selectionErrorMessageChild']").css("display", "none");
        closeGrandparentPanel();
    }
    else
    {
        j$("[Id$='selectionErrorMessageChild']").css("display", "block");
    }
}

function parentConfirmationPanel()
{
    j$("[Id$='parentMassUpdatePanel']").css("display", "none");
    j$("[Id$='parentConfirmationPanel']").css("display", "block");
}

function renderParentMassUpdatePanel()
{
    j$("[Id$='parentConfirmationPanel']").css("display", "none");
    j$("[Id$='parentMassUpdatePanel']").css("display", "block");
}

function closeParentConfirmationPanel()
{
    j$("[Id$='parentConfirmationPanel']").css("display", "none");
}

function childConfirmationPanel()
{
    j$("[Id$='childMassUpdatePanel']").css("display", "none");
    j$("[Id$='childConfirmationPanel']").css("display", "block");
}

function renderChildMassUpdatePanel()
{
    j$("[Id$='childConfirmationPanel']").css("display", "none");
    j$("[Id$='childMassUpdatePanel']").css("display", "block");
}

function closeChildConfirmationPanel()
{
    j$("[Id$='childConfirmationPanel']").css("display", "none");
}

function cancelGrandparent()
{
    enable(j$("[Id$='MassUpdateRecButton']"));
    enable(j$("[Id$='DeleteButton']"));
    enable(j$("[Id$='createNewChild']"));
    enable(j$("[Id$='createNewParent']"));
    j$("[Id$='ClearAllChanges']").css("display", "none");
}