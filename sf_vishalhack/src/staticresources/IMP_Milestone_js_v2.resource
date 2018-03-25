	    $j = jQuery.noConflict();
    function expandViewPage() {
        $j('.child_header_tr, .child_content_tr,.grandChild_header_tr,.grandChild_content_tr,.excess_column').show();
        $j('.btnExpand').hide();
        $j('.btnCollapse').show();
        $j('input:checkbox[id$=chkExpand]').prop('checked',true);	
        
        $j('.toggle_cell').closest('tr').addClass('expands');
    }
    
    function collapseViewPage() {
        $j('.child_header_tr, .child_content_tr,.grandChild_header_tr,.grandChild_content_tr,.excess_column').hide();
        $j('.btnExpand').show();
        $j('.btnCollapse').hide();
        $j('input:checkbox[id$=chkExpand]').prop('checked',false);	
        $j('.toggle_cell').closest('tr').removeClass('expands');
    }
    
    function milestoneToggle(control, tr_id, type) {
        //toggleRow to hide/show the tr
        var event = toggleRow(control,tr_id);
        //this will hide/show the excess column when expanding or collapsing
        if (type == 'Activity') {
            if (event == 'expand') {
                $j('.excess_column.activity').show();
            } else {
                //only hide the excess columns when the "- button" is click in the last expanded record
                
                if($j('tr.parent_content_tr.dataRow.expands').length == 0) {
                    $j('.excess_column.activity,.excess_column.task').hide();   
                } else if ($j('tr.child_content_tr.dataRow.expands').length == 0) {
                    $j('.excess_column.task').hide();
                }               
            }
            
        } else {
            if (event == 'expand') {
                $j('.excess_column.activity,.excess_column.task').show();
            } else {       
                //only hide the excess columns when the "- button" is click in the last expanded record              
               
                if($j('tr.child_content_tr.dataRow.expands').length == 0) {
                     $j('.excess_column.task').hide();
                }
            }
        }
        
    }
    
    function toggleRow(control,tr_id) {
        var event = 'expand';
        //get the table
        var currentTr = $j(control).closest('tr');
        var parentTable = $j(control).closest('table');   
        //find all child record 
        //hidden input is place in the child record to store the id of the parent id       
        var tr = $j(parentTable).find('input[type=hidden][id=hdnToShow][value=' + tr_id + ']').closest('tr');
        //check the visibility of the tr 
        if ($j(tr).css('display') == 'none') {
            //add class to change the +/- button
            $j(currentTr).addClass('expands');
            $j(tr).show();
            //this will update the wrapper class to be used in retaining the expanded records when a rerender is trigger
            $j('input:checkbox[id$=chkExpand]',currentTr).prop('checked',true);	           
        } else {
            $j(currentTr).removeClass('expands');
            $j(tr).hide();
            //check if the target record to be hide has children attach to it
            var childId = $j(tr).find('input[type=hidden][id=hdnActId]');            
            $j(childId).each(function () {               
                var str = $j(parentTable).find('input[type=hidden][value=' + $j(this).val() + ']').closest('tr');
                $j(str).removeClass('expands');
                $j(str).hide();                
                $j('input:checkbox[id$=chkExpand]',str).prop('checked',false);
            }); 
             //this will update the wrapper class to be used in removing the expanded records when a rerender is trigger
            $j('input:checkbox[id$=chkExpand]',currentTr).prop('checked',false);	
            event= 'hide';
        }
        return event;
    }
    
    function retainExcessColumnAfterPostBack() {
        //expand all the records that has been expanded before delete or adding a record
    	$j('.expands').css('display','table-cell');        
        //this will fix the not showing of excess columns when new milestone is created and table have expanded records
        if ($j('.excess_column.task.expands').length > 0 ) {
             $j('.excess_column.activity,.excess_column.task').show();
        } else if ($j('.excess_column.activity.expands').length > 0 ) {
             $j('.excess_column.activity').show();
        }
    }
    
    function confirmAndDelete2() {
        var tblMain = $j('.mainTable');
        var checkboxSelectedActivity = $j(tblMain).find('td input:checkbox[id$="chkSelected"]:checked');
        
        var checkboxSelectedMilestone = $j(tblMain).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
       
        var checkboxSelectedTask = $j(tblMain).find('td input:checkbox[id$="chkTaskSelected"]:checked');
        
        if ($j(checkboxSelectedMilestone).length == 0 && $j(checkboxSelectedActivity).length == 0 && $j(checkboxSelectedTask).length == 0) {
            alert('No record selected for deletion. Please select any record in the table');
        } else {
            var message = confirm("Are you sure?");
            if (message) {
                //call action function
                deleteMilestoneFunction();
            }
        }
    }
	function updatePSRDisplayOfRecs(includeTasks, toDisplay) 
	{
        var checkThis = $j("[id$='allRecords']").is('clicked');
        console.log(checkThis);
        var tblMain = $j('.mainTable');
        var checkboxSelectedActivity = $j(tblMain).find('td input:checkbox[id$="chkSelected"]:checked');
        
        var checkboxSelectedMilestone = $j(tblMain).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
       
        var checkboxSelectedTask = $j(tblMain).find('td input:checkbox[id$="chkTaskSelected"]:checked');
        
        if ($j(checkboxSelectedMilestone).length == 0 && ($j(checkboxSelectedActivity).length > 0 || $j(checkboxSelectedTask).length > 0)) 
        {
            alert('You have selected an Activity or Task and this action is only supported if you check a Milestone or if no items are checked.  Please uncheck any Activities and Tasks.  If you want to enable/disable PSR display on selected Activities or Tasks, this can be accomplished through the Milestone Edit Page.');
        }
        else if($j(checkboxSelectedMilestone).length == 0 && $j(checkboxSelectedActivity).length == 0 && $j(checkboxSelectedTask).length == 0)
        {
            showPSRDialogue('noMilestoneDialogue',includeTasks,toDisplay);
        }
        else if($j(checkboxSelectedMilestone).length > 0)
        {
            showPSRDialogue('milestoneCheckedDialogue',includeTasks,toDisplay);
        }
    }
	function showPSRDialogue(dialogParam,includeTasks,toDisplay) 
	{
        var dialogID = '#'+dialogParam;
        $j( dialogID ).dialog({
            resizable: false,
            height:"auto",
            width:600,
            modal: true,
            buttons: {
                "Ok": function() 
                {                       
                    
                    if(dialogParam == 'milestoneCheckedDialogue')
                    {
                       updateDisplayPSR(false, includeTasks, toDisplay);
                        $j( this ).dialog( "close" );
                    }
                    else
                    {
                        updateDisplayPSR(true, includeTasks, toDisplay);
                        $j( this ).dialog( "close" );
                    }
                    
                },
                Cancel: function() {
                    $j( this ).dialog( "close" );
                }
            }
        });
        
    }
    
    function disableTaskCheckbox2() {
        var tblMain = $j('.mainTable');
        var checkboxToDisable = $j(tblMain).find('td input:checkbox[id$="chkSelected"], td input:checkbox[id$="chkMilestoneSelected"]');        
        var checkboxSelectedTask = $j(tblMain).find('td input:checkbox[id$="chkTaskSelected"]:checked');
        
        if ($j(checkboxSelectedTask).length == 0) {
            //$j(checkboxAll).removeAttr("disabled");
            $j(checkboxToDisable).removeAttr("disabled");
        } else {
            //$j(checkboxAll).attr("disabled", "disabled");
            $j(checkboxToDisable).attr("disabled", "disabled");
        }
    }
    
    function disableMilestoneCheckbox2() {
        var tblMain = $j('.mainTable');
        var checkboxToDisable = $j(tblMain).find('td input:checkbox[id$="chkTaskSelected"], td input:checkbox[id$="chkMilestoneSelected"]');        
        var checkboxSelectedTask = $j(tblMain).find('td input:checkbox[id$="chkSelected"]:checked');
        
        if ($j(checkboxSelectedTask).length == 0) {
            //$j(checkboxAll).removeAttr("disabled");
            $j(checkboxToDisable).removeAttr("disabled");
        } else {
            //$j(checkboxAll).attr("disabled", "disabled");
            $j(checkboxToDisable).attr("disabled", "disabled");
        }
    }
    
    function disableActivityCheckbox2() {
        var tblMain = $j('.mainTable');
        var checkboxToDisable = $j(tblMain).find('td input:checkbox[id$="chkTaskSelected"], td input:checkbox[id$="chkSelected"]');        
        var checkboxSelectedTask = $j(tblMain).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
        
        if ($j(checkboxSelectedTask).length == 0) {
            //$j(checkboxAll).removeAttr("disabled");
            $j(checkboxToDisable).removeAttr("disabled");
        } else {
            //$j(checkboxAll).attr("disabled", "disabled");
            $j(checkboxToDisable).attr("disabled", "disabled");
        }
    }

	function retainDisableCheckbox2() {
		var tblMain = $j('.mainTable');
		
		var checkboxActivity = $j(tblMain).find('td input:checkbox[id$="chkSelected"]:checked');
		var checkboxMilestone = $j(tblMain).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
		var checkboxTask = $j(tblMain).find('td input:checkbox[id$="chkTaskSelected"]:checked');
		if ($j(checkboxActivity).length != 0) {
			$j(tblMain).find('td input:checkbox[id$="chkTaskSelected"], td input:checkbox[id$="chkMilestoneSelected"]').attr("disabled", "disabled");
		} else if ($j(checkboxMilestone).length != 0) {
			$j(tblMain).find('td input:checkbox[id$="chkTaskSelected"], td input:checkbox[id$="chkSelected"]').attr("disabled", "disabled");
		} else if ($j(checkboxTask).length != 0) {
			$j(tblMain).find('td input:checkbox[id$="chkSelected"], td input:checkbox[id$="chkMilestoneSelected"]').attr("disabled", "disabled");
		}
        
        var expand = $j(tblMain).find('td input:checkbox[id$="chkExpand"]:checked');
        $j(expand).closest('tr').addClass('expands');
	}

    
	
	/*
	 * function showUpdatePSR(toDisplay) {   
        if (toDisplay==true)
        {
            $j( "#dialogShowallPSR" ).dialog({
                resizable: false,
                height:"auto",
                width:600,
                modal: true,
                buttons: {
                    "Ok": function() {                       
                        $j( this ).dialog( "close" );
                        updateDisplayPSR(toDisplay);
                    },
                    Cancel: function() {
                        $j( this ).dialog( "close" );
                    }
                }
            });
        } else {
            $j( "#dialogHideAllPSR" ).dialog({
                resizable: false,
                height:"auto",
                width:600,
                modal: true,
                buttons: {
                    "Ok": function() {                        
                        $j( this ).dialog( "close" );
                        updateDisplayPSR(toDisplay);
                    },
                    Cancel: function() {
                        $j( this ).dialog( "close" );
                    }
                }
            });
        }      
    }
    */