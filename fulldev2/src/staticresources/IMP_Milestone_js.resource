/*
Author: Rey Austral
Company: Cloud Sherpas
Description: all javascript function that is used in IMP.Milestone component
History
11/12/14    Rey Austral         Created
12/24/14	Rey Austral			Add field update and mass update function
*/

	$j = jQuery.noConflict();        

	function confirmAndDelete(){
		var tblActivity  = $j('.childTable');
    	var checkboxSelectedActivity = $j(tblActivity).find('td input:checkbox[id$="chkSelected"]:checked');

    	var tblMilestone = $j('.mainTable');
    	var checkboxSelectedMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');

		var tblTask = $j('.grandChildTable');
    	var checkboxSelectedTask = $j(tblMilestone).find('td input:checkbox[id$="chkTaskSelected"]:checked');
		
    	if ($j(checkboxSelectedMilestone).length == 0 && $j(checkboxSelectedActivity).length == 0 && $j(checkboxSelectedTask).length == 0) { 
			alert('No record selected for deletion. Please select any record in the table');
		} else {
			var message = confirm("Are you sure?");
			if(message){
				//call action function
				deleteMilestoneFunction();
			}
		}
	}



	function checkAndMarkChanged(control) {   
		//this function will determine if the record has been updated
		//find the check box location in the first column		
		var tdParent = $j(control).closest('td');
		//var tdParent = $j(control).parent();
		var trParent = $j(tdParent).parent();
		var chEdit = $j(trParent).find("input[id$='chkEdited']");	
		$j(tdParent).addClass("changedValue");
		chEdit.prop('checked', true);		
	}	

	function selectAllRecords(control, chkControl, type) {
		tickAllCheckboxColumn(control,chkControl);
		if (type == 'milestone') {
			disableActivityCheckbox();       
		} else if (type== 'activity') {
			disableMilestoneCheckbox(); 
		} else {
			disableTaskCheckbox();
		}
	}
	
	function checkAllPSR(control) {
		tickAllCheckboxColumn(control,'chkPSR');
		
		//get the table 
		var table = $j(control).closest('table');		
		var chEdit = $j(table).find('td input:checkbox[id$="chkEdited"][class="chkEditedActivity"]');
		//get the td for each checkbox
		var td = $j(table).find('td[id$="tdPSR"]');		
		$j(chEdit).prop('checked',true);
		$j(td).addClass("changedValue");		
	}

	function expandActivity() {   
		//get all parent of the class activityErrorClass
		var dvParent = $j('.toogle_control.expand').parent();   
		if (dvParent.length != 0)
		{	
			$j('input:checkbox[id$="chkExpand"]',dvParent).prop('checked',true);
		}

		var tbl = $j('.childTable,.grandChildTable');
	
		if (dvParent.length == (tbl.length -1 ))
		{
			$j(".btnExpand").hide();
			$j(".btnCollapse").show();
		}else {
			$j(".btnExpand").show();
			$j(".btnCollapse").hide();
		}
	}

 	function retainDisableCheckbox() {
    	var tblActivity  = $j('.childTable');
    	var checkboxSelectedActivity = $j(tblActivity).find('td input:checkbox[id$="chkSelected"]:checked');

    	var tblMilestone = $j('.mainTable');
    	var checkboxSelectedMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
		
		var tblTask = $j('.grandChildTable');
    	var checkboxSelectedTask = $j(tblTask).find('td input:checkbox[id$="chkTaskSelected"]:checked');

    	if ($j(checkboxSelectedActivity).length != 0) { 
    		//disable milestone and task checkbox
    		var checkboxMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"]');
    		var checkboxMilestoneAll =  $j('#chkMilestoneAll');
    		$j(checkboxMilestoneAll).attr("disabled","disabled");
    		$j(checkboxMilestone).attr("disabled","disabled"); 
			
			var checkboxTask = $j(tblTask).find('td input:checkbox[id$="chkMilestoneSelected"]');
    		var checkboxTaskAll =  $j('#chkTaskAll');
    		$j(checkboxTaskAll).attr("disabled","disabled");
    		$j(checkboxTask).attr("disabled","disabled");
    	} else 	if ($j(checkboxSelectedMilestone).length != 0) {
			//disable activity and task checkbox
        	var checkboxActivity = $j(tblActivity).find('td input:checkbox[id$="chkSelected"]'); 
			var checkboxActivityAll =  $j('#chkActivityAll',tblActivity);
			$j(checkboxActivityAll).attr("disabled","disabled"); 
    		$j(checkboxActivity).attr("disabled","disabled"); 
			
			var checkboxTask = $j(tblTask).find('td input:checkbox[id$="chkMilestoneSelected"]');
    		var checkboxTaskAll =  $j('#chkTaskAll');
    		$j(checkboxTaskAll).attr("disabled","disabled");
    		$j(checkboxTask).attr("disabled","disabled");
    	} else 	if ($j(checkboxSelectedTask).length != 0) {
			//disable milestone and activity checkbox
			var checkboxMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"]');
    		var checkboxMilestoneAll =  $j('#chkMilestoneAll');
    		$j(checkboxMilestoneAll).attr("disabled","disabled");
    		$j(checkboxMilestone).attr("disabled","disabled"); 
			
        	var checkboxActivity = $j(tblActivity).find('td input:checkbox[id$="chkSelected"]'); 
			var checkboxActivityAll =  $j('#chkActivityAll',tblActivity);
			$j(checkboxActivityAll).attr("disabled","disabled"); 
    		$j(checkboxActivity).attr("disabled","disabled"); 
    	} 
    }

	function updateRecord() {
		//this is used to know if the record that needs to mass update is a milestone or an activity
		if ($j('#chkMassMilestone').prop('checked')) {               
			massUpdateMilestone();
		} else if ($j('#chkMassActivity').prop('checked')) {
			massUpdateActivity();
		} else {
			massUpdateTask();
		}
	}
	
   function massUpdateMilestone()
	{
		var tblLast = $j('.mainTable:last');
		var hasChange = $j('td[class="changedValue"]',tblLast);
		//check first if there are changes in the mass update field
		if ($j(hasChange).length != 0) {
			//get all input in the dialog
			var sourceInput = $j('input:visible,select',tblLast); 
			//get all the table of the milestone
			var tbl = $j('.mainTable');
			//get all the check rows in the table
			var checkboxSelected = $j(tbl).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
			if ($j(checkboxSelected).length != 0) {
				//find the parent of the checkbox to get all the input field in that row
				$j(checkboxSelected).each(function () {
					var parentTd = $j(this).parent();                   
					//get the tr (row)
					var tr =  $j(parentTd).parent();                  
					//check the chkedited for the controller to process the row
					var chk = $j(tr).find('td input:checkbox[id$="chkEdited"]');                        
					$j(chk).prop('checked',true);
					//update all the field in the milestone
					
					updateMassFieldValue('sitesId','sitesId', tblLast, tr, 'changedValue');
					updateMassFieldValue('ddExternalId','externalId', tblLast, tr, 'changedValue');
					updateMassFieldValue('milestoneComment','txtMilestoneComment', tblLast, tr, 'changedValue');
				});
				showMassUpdateMessage('To complete the mass update, click Save button on the Milestone page.','success','dvMassMessage','lblMassMessage');				
			} else {
				showMassUpdateMessage('No Milestone record selected to mass update. Please select one or more milestones.','error','dvMassMessage','lblMassMessage');				
			}
		} else {
			showMassUpdateMessage('No field was selected to mass update, please select any field below.','error','dvMassMessage','lblMassMessage');			
		}
	}
	
	function massUpdateActivity()
	{            
		var tblLast = $j('.childTable:last');
		var hasChange = $j('td[class="changedValue"]',tblLast);
		//check first if there are changes in the mass update field
		if ($j(hasChange).length != 0) {
			//get all the source value
			var sourceInput = $j('input:visible,select',tblLast); 
			//get the target activity table
			var tbl = $j('.childTable');                
			//get the selected row by finding the 'chkSelected' checkbox
			var checkboxSelected = $j(tbl).find('td input:checkbox[id$="chkSelected"]:checked');
			//iterate the list of checkbox
			if ($j(checkboxSelected).length != 0) {
				//find the parent of the checkbox to get all the input field in that row
				$j(checkboxSelected).each(function () {
					//get the td of each checkbox
					//var parentTd = $j(this).parent();                   
					//get the tr (row)
					var tr =  $j(this).closest('tr');
					//check the chkedited for the controller to process the row
					var chk = $j(tr).find('td input:checkbox[id$="chkEdited"]');                        
					$j(chk).prop('checked',true);  
					//update all the field in the activity
					updateMassFieldValue('startDate','txtPlannedStartDate', tblLast, tr, 'changedValue');
					updateMassFieldValue('endDate','txtPlannedEndDate', tblLast, tr, 'changedValue');
					
					updateMassFieldLookUpValue('luCDKAssignee','luCDKAssignee', tblLast, tr, 'changedValue');					
					updateMassFieldLookUpValue('luClientAssignee','luClientAssignee', tblLast, tr, 'changedValue');
					updateMassFieldValue('actualStartDate','txtActualStartDate', tblLast, tr, 'changedValue');
					updateMassFieldValue('actualEndDate','txtActualEndDate', tblLast, tr, 'changedValue');
					updateMassFieldValue('ddDepartment','ddDepartment', tblLast, tr, 'changedValue');
					updateMassFieldValue('activityComment','txtActivityComments', tblLast, tr, 'changedValue');
					updateMassFieldValue('ddRole','ddRole', tblLast, tr, 'changedValue');
					updateMassFieldCheckValue('chkPSRTrue','chkPSRFalse','chkPSR', tblLast, tr, 'changedValue');
				}); 
				showMassUpdateMessage('To complete the mass update, click Save button on the Milestone page.','success','dvMassMessage','lblMassMessage');			
			} else {
				showMassUpdateMessage('No Activity record selected to mass update. Please select one or more activities.','error','dvMassMessage','lblMassMessage');				
			}
			
		} else {
			showMassUpdateMessage('No field was selected to mass update, please select any field below.','error','dvMassMessage','lblMassMessage');			
		}
	}
	
	function massUpdateTask()
	{            
		var tblLast = $j('.grandChildTable:last');
		var hasChange = $j('td[class="changedValue"]',tblLast);
		//check first if there are changes in the mass update field
		if ($j(hasChange).length != 0) {
			//get all the source value
			var sourceInput = $j('input:visible,select',tblLast); 
			//get the target activity table
			var tbl = $j('.grandChildTable');                
			//get the selected row by finding the 'chkSelected' checkbox
			var checkboxSelected = $j(tbl).find('td input:checkbox[id$="chkTaskSelected"]:checked');
			//iterate the list of checkbox
			if ($j(checkboxSelected).length != 0) {
				//find the parent of the checkbox to get all the input field in that row
				$j(checkboxSelected).each(function () {
					//get the td of each checkbox
					//var parentTd = $j(this).parent();                   
					//get the tr (row)
					var tr =  $j(this).closest('tr');
					//check the chkedited for the controller to process the row
					var chk = $j(tr).find('td input:checkbox[id$="chkEdited"]');                        
					$j(chk).prop('checked',true);  
					//update all the field in the activity
					updateMassFieldValue('taskStartDate','txtTaskPStartDate', tblLast, tr, 'changedValue');
					updateMassFieldValue('taskEndDate','txtTaskPEndDate', tblLast, tr, 'changedValue');
						
					updateMassFieldLookUpValue('luTaskCDKAssignee','luTaskCDKAssignee', tblLast, tr, 'changedValue');					
					updateMassFieldLookUpValue('luTaskClientAssignee','luTaskClientAssignee', tblLast, tr, 'changedValue');
					updateMassFieldValue('taskActualStartDate','txtTaskAStartDate', tblLast, tr, 'changedValue');
					updateMassFieldValue('taskActualEndDate','txtTaskAEndDate', tblLast, tr, 'changedValue');
					updateMassFieldValue('taskATimeSpent','txtATimeSpent', tblLast, tr, 'changedValue');
					
					updateMassFieldValue('taskComment','txtTaskComments', tblLast, tr, 'changedValue');
					updateMassFieldValue('ddTaskRole','ddTaskRole', tblLast, tr, 'changedValue');
					
					updateMassFieldValue('ddReasonMissed','plReasonMissed', tblLast, tr, 'changedValue');
					updateMassFieldValue('ddMigrationStatus','plStatusMigration', tblLast, tr, 'changedValue');
					updateMassFieldValue('ddNAReason','txtTaskReason', tblLast, tr, 'changedValue');
					
				
				}); 
				showMassUpdateMessage('To complete the mass update, click Save button on the Milestone page.','success','dvMassMessage','lblMassMessage');			
			} else {
				showMassUpdateMessage('No Task record selected to mass update. Please select one or more tasks.','error','dvMassMessage','lblMassMessage');				
			}
			
		} else {
			showMassUpdateMessage('No field was selected to mass update, please select any field below.','error','dvMassMessage','lblMassMessage');			
		}
	}
	
	function clearMassRecord() {
		//set the field in its default value
		var tblLast = $j('.childTable:last');
		clearMassFieldRecord('startDate',tblLast, 'input', 'changedValue');
		clearMassFieldRecord('endDate', tblLast, 'input', 'changedValue');
		
		clearMassFieldRecord('luCDKAssignee', tblLast, 'lookup', 'changedValue');
		clearMassFieldRecord('luClientAssignee', tblLast, 'lookup', 'changedValue');
		clearMassFieldRecord('actualStartDate', tblLast, 'input', 'changedValue');
		clearMassFieldRecord('actualEndDate', tblLast, 'input', 'changedValue');
		clearMassFieldRecord('ddDepartment',tblLast, 'select', 'changedValue');
		clearMassFieldRecord('activityComment', tblLast, 'input', 'changedValue');
		clearMassFieldRecord('ddRole', tblLast, 'select', 'changedValue');
		clearMassFieldRecord('chkPSRTrue', tblLast, 'radio', 'changedValue');
		clearMassFieldRecord('chkPSRFalse', tblLast, 'radio', 'changedValue');
		
		var tblMainLast = $j('.mainTable:last');
		clearMassFieldRecord('milestoneComment', tblMainLast, 'input', 'changedValue');
		clearMassFieldRecord('ddExternalId',tblMainLast, 'select', 'changedValue');
		clearMassFieldRecord('sitesId', tblMainLast, 'select', 'changedValue');
		
		
		var tblGrandChildLast = $j('.grandChildTable:last');
		clearMassFieldRecord('taskStartDate',tblGrandChildLast, 'input', 'changedValue');
		clearMassFieldRecord('taskEndDate', tblGrandChildLast, 'input', 'changedValue');
		
		clearMassFieldRecord('luTaskCDKAssignee', tblGrandChildLast, 'lookup', 'changedValue');
		clearMassFieldRecord('luTaskClientAssignee', tblGrandChildLast, 'lookup', 'changedValue');
		clearMassFieldRecord('taskActualStartDate', tblGrandChildLast, 'input', 'changedValue');
		clearMassFieldRecord('taskActualEndDate', tblGrandChildLast, 'input', 'changedValue');
		clearMassFieldRecord('taskATimeSpent', tblGrandChildLast, 'input', 'changedValue');
	
		clearMassFieldRecord('taskComment', tblGrandChildLast, 'input', 'changedValue');
		clearMassFieldRecord('ddTaskRole', tblGrandChildLast, 'select', 'changedValue');
		
		clearMassFieldRecord('ddMigrationStatus', tblGrandChildLast, 'select', 'changedValue');
		clearMassFieldRecord('ddReasonMissed', tblGrandChildLast, 'select', 'changedValue');
		clearMassFieldRecord('ddNAReason', tblGrandChildLast, 'select', 'changedValue');
		
	}
	
	
	function loadDatePicker() {
		//make the input textbox a jquery datepicker
		convertToJqueryDatePicker('startDate');
		convertToJqueryDatePicker('endDate');
		convertToJqueryDatePicker('actualStartDate');
		convertToJqueryDatePicker('actualEndDate');
		
		convertToJqueryDatePicker('taskStartDate');
		convertToJqueryDatePicker('taskEndDate');
		convertToJqueryDatePicker('taskActualStartDate');
		convertToJqueryDatePicker('taskActualEndDate');
	}	
	
	function displayMassUpdateSelected(control) {		
		//this is used to determine what field will be show in the mass update
		var selectedValue = $j(control).val();           
		if (selectedValue == 'Milestone') {
			$j('#massMilestone').show();
			$j('#massActivity').hide();
			$j('#massTask').hide();
		} 
		else if (selectedValue == 'Activity') {
			$j('#massActivity').show();
			$j('#massMilestone').hide();
			$j('#massTask').hide();
		} 
		else {
			$j('#massActivity').hide();
			$j('#massMilestone').hide();
			$j('#massTask').show();
		}
	}        

	
	function fieldUpdateExtension(td, controlId, mode, column, haveAccess) {
		//this are controls that cannot directly clone,
		if (mode == 'false' && haveAccess) {
			var inputfield = $j('[id$="' + controlId  + '"]',td);
			var div='',cons='';
			if (column == 'cdk') {
				cons = 'luFieldCDKAssignee';
				var div =  $j('#dvFieldCDKAssignee');
			} else if (column == 'client') {
				cons = 'luFieldClientAssignee';
				var div =  $j('#dvFieldClientAssignee');
			} else if (column == 'site') {
				cons = 'fieldSitesId';
				var div =  $j('#dvFieldSiteId');
			}
			var cloneField = $j('[id$="' + cons  + '"]',div);            	
			$j(div).removeClass('hide_component');
			
			var title = 'Edit ' + getColumnText(td);
			openFieldUpdateDialog('dvFieldUpdateExtension',cloneField, inputfield,'lookup',title);
		}
	}
	
	function fieldUpdateTaskExtension(td, controlId, mode, column, haveAccess) {
		//this are controls that cannot directly clone,
		if (mode == 'false' && haveAccess) {
			var inputfield = $j('[id$="' + controlId  + '"]',td);
			var div='',cons='';
			if (column == 'cdk') {
				cons = 'luFieldTaskCDKAssignee';
				var div =  $j('#dvFieldTaskCDKAssignee');
			} else if (column == 'client') {
				cons = 'luFieldTaskClientAssignee';
				var div =  $j('#dvFieldTaskClientAssignee');
			} 
			
			var cloneField = $j('[id$="' + cons  + '"]',div);            	
			$j(div).removeClass('hide_component');
			
			var title = 'Edit ' + getColumnText(td);
			openFieldUpdateDialog('dvFieldUpdateExtension',cloneField, inputfield,'lookup',title);
		}
	}

	
	function copyAndSaveValue(target, source, type) {
		//copy the source value back to the target value hidden inside the table
		//checked the chkEdited so that the controller will process the record
		var tr = $j(target).closest('tr'),
			chkEdited = $j(tr).find('td input:checkbox[id$="chkEdited"]');
		$j(chkEdited).prop('checked',true);
		
		fieldUpdateSource(target, source, type);
		//call the action function to save the record
		remoteSave();   
	}
	
	function hideDivLoopUp() {
		//hide all the div inside dvFieldUpdateExtension
		$j('#dvFieldCDKAssignee').addClass('hide_component');            
		$j('#dvFieldClientAssignee').addClass('hide_component');
		$j('#dvFieldSiteId').addClass('hide_component');
		
		$j('#dvFieldTaskCDKAssignee').addClass('hide_component');
		$j('#dvFieldTaskClientAssignee').addClass('hide_component');
	}
	
	function disableMilestoneCheckbox() {
    	var tblActivity  = $j('.childTable');
    	var checkboxSelectedActivity = $j(tblActivity).find('td input:checkbox[id$="chkSelected"]:checked');

    	var tblMilestone = $j('.mainTable, .grandChildTable');
    	var checkboxMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"], td input:checkbox[id$="chkTaskSelected"]');

    	var checkboxAll =  $j('#chkMilestoneAll, #chkTaskAll',tblMilestone);
    	if ($j(checkboxSelectedActivity).length == 0) {
    		$j(checkboxAll).removeAttr("disabled");
    		$j(checkboxMilestone).removeAttr("disabled");
    	} else {
    		$j(checkboxAll).attr("disabled","disabled");
    		$j(checkboxMilestone).attr("disabled","disabled"); 
    	}
    }

    function disableActivityCheckbox() {
    	var tblMilestone = $j('.mainTable');
    	var checkboxSelectedMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');

    	var tblActivity  = $j('.childTable, .grandChildTable');
    	var checkboxActivity = $j(tblActivity).find('td input:checkbox[id$="chkSelected"], td input:checkbox[id$="chkTaskSelected"]'); 
		var checkboxAll =  $j('#chkActivityAll, #chkTaskAll',tblActivity);
       	if ($j(checkboxSelectedMilestone).length == 0) {
       		$j(checkboxAll).removeAttr("disabled");
    		$j(checkboxActivity).removeAttr("disabled");
    	} else {
    		$j(checkboxAll).attr("disabled","disabled"); 
    		$j(checkboxActivity).attr("disabled","disabled"); 
    	}
    }
	
	function disableTaskCheckbox() {
    	var tblTask = $j('.grandChildTable');
    	var checkboxSelectedTask = $j(tblTask).find('td input:checkbox[id$="chkTaskSelected"]:checked');

    	var tblOthers  = $j('.childTable, .mainTable');
    	var checkboxActivity = $j(tblOthers).find('td input:checkbox[id$="chkSelected"], td input:checkbox[id$="chkMilestoneSelected"]'); 
		var checkboxAll =  $j('#chkActivityAll, #chkMilestoneAll',tblOthers);
		
       	if ($j(checkboxSelectedTask).length == 0) {
       		$j(checkboxAll).removeAttr("disabled");
    		$j(checkboxActivity).removeAttr("disabled");
    	} else {
    		$j(checkboxAll).attr("disabled","disabled"); 
    		$j(checkboxActivity).attr("disabled","disabled"); 
    	}
    }

	$j( document ).ready(function() {
		createHoverEventBindings(true);	
	});
	
	function createHoverEventBindings(execute){
		if (execute == true) {
			//this is used to add pencil in the table if the field can be field update
			createHoverEvent('grid-cell-editable','hoverEditableField');
		}	
	}	

	function showMassSection() {
		var tblMilestone = $j('.mainTable');
		var tblActivity = $j('.childTable');  
		var tblTask = $j('.grandChildTable');  
		var checkboxSelectedMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
		var checkboxSelectedActivity = $j(tblActivity).find('td input:checkbox[id$="chkSelected"]:checked');
		var checkboxSelectedTask = $j(tblTask).find('td input:checkbox[id$="chkTaskSelected"]:checked');
		
	    if ($j(checkboxSelectedActivity).length != 0) {
			 $j('#chkMassActivity').prop('checked',true);
		     $j('#massMilestone').hide();
			 $j('#massTask').hide();
		     $j('#massActivity').show();
	 	} else if ($j(checkboxSelectedTask).length != 0) {
			 $j('#chkMassTask').prop('checked',true);
		      $j('#massMilestone').hide();
		     $j('#massActivity').hide();
			 $j('#massTask').show();
	 	} else {
	 		 $j('#chkMassMilestone').prop('checked',true);
		     $j('#massMilestone').show();
		     $j('#massActivity').hide();
			 $j('#massTask').hide();
	 	}
	}

	 function showMassUpdate(control) { 
            //clear all data/error validation first before showing the dialog
            loadDatePicker();
            clearMassRecord();
            showMassSection();
            
            $j('#dvMassMessage').hide();
            //get the id of the form
            var id =$j(control).closest('form').attr('id'),
                ids = '#' + id.replace(/:/g,'\\:');
            //var id = '#{!$Component.formId}';
            //var ids = id.replace(/:/g,'\\:');
            $j('#dvMassUpdate').dialog({modal: false, zIndex: 9 , maxheight:460,width:680,resizable:false,minheight:200, position:'center', 
                                        create: function() {
                                            $j(this).parent().appendTo($j(ids));  
                                            $j(this).addClass("ui-corner-flat");
                                        },   
										beforeClose: function() {
											 clearMassRecord(); 
										},									
                                        open: function() {
											//remove the jquery css of the dialog box button
                                            $j('.ui-dialog-buttonset').children('button').
                                            removeClass("ui-button ui-widget ui-state-default ui-state-active ui-state-focus ui-corner-all").
                                            mouseover(function() { $j(this).removeClass('ui-state-hover'); }).
                                            mousedown(function() { $j(this).removeClass('ui-state-active'); }).
                                            focus(function() { $j(this).removeClass('ui-state-focus'); });
                                            $j(this).removeClass(".ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button");
                                        },
                                        buttons: [
                                            {
                                                text: "Apply to Selected Records",     
                                                "class":'btn',
                                                click: function() {
                                                    updateRecord();
                                                    // $j( '#dvMassUpdate' ).dialog( "close" );
                                                }
                                            },
                                            {
                                                text: "Refresh",
                                                click: function() {
                                                    clearMassRecord();  
                                                    $j('#dvMassMessage').hide();
                                                }
                                            },
                                            {
                                                text: "Cancel",
                                                click: function() {
                                                    $j( '#dvMassUpdate' ).dialog( "close" );
                                                }
                                            }
                                            
                                        ]});
        }
        
        function openFieldUpdateDialog(dialogId, cloneField, inputfield, type , titleText) {
            //get the form id
            var id =$j(inputfield).closest('form').attr('id'),
                ids = '#' + id.replace(/:/g,'\\:');
            //var id = '#{!$Component.formId}',
                
            
            $j('#' + dialogId).dialog(
                {                    
                    modal:true, 
                    title: titleText,
                    zIndex: 9,
                    maxWidth: 600,
                    minWidth: 300,
                    position: 'center', 
                    dialogClass: 'ui-corner-flat',
                    create: function() {
                        //by default jquery will move the div outside the form, 
                        //this will move the div inside the form
                        $j(this).parent().appendTo($j(ids)); 
                        $j('#' + dialogId).addClass("update_dialog");
                        
                    },
                    open: function() {
                        //remove the jquery css from the button
                        $j('.ui-dialog-buttonset').children('button').
                        removeClass("ui-button ui-widget ui-state-default ui-state-active ui-state-focus ui-corner-all").
                        mouseover(function() { $j(this).removeClass('ui-state-hover'); }).
                        mousedown(function() { $j(this).removeClass('ui-state-active'); }).
                        focus(function() { $j(this).removeClass('ui-state-focus'); });
                        $j(this).removeClass(".ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button");
                       
                    },
                    beforeClose: function() {
                        if (type != 'lookup') {
                            //remove all clone control that was append in the div
                            $j( this ).empty();
                        } else {
                            //hide all the div in dvFieldUpdateExtension
                            hideDivLoopUp();
                        }
                    },
                    buttons: [
                        {
                            id:"save-button",
                            text: "Save",     
                            "class":'btn',
                            click: function() {							
                                copyAndSaveValue(inputfield,cloneField,type);  
                                $j( this ).dialog('close');
                            }
                        },                                            
                        {
                            text: "Cancel",
                            "class":'btn',
                            click: function() {                                
                                $j( this ).dialog('close');
                            }
                        }
                        
                    ]
                });
            
        }

     function closeDialog() {
    	$j( '#dvMassUpdate' ).dialog( "close" );
    }
	
	function toggleAllWithMultipleTable(mode) {
		retainToggleAllTable('chkExpand',mode,'toggle_table');
		retainToggleAllTable('chkActivityExpand',mode,'toggle_subtable');
	}
	
	function openEdit(subjProjectId, maxRecord)
	{
		var tblMilestone = $j('.mainTable');
		var checkboxSelectedMilestone = $j(tblMilestone).find('td input:checkbox[id$="chkMilestoneSelected"]:checked');
		var milestoneIds = '';
		if ($j(checkboxSelectedMilestone).length == 0) {
			alert('No milestone record selected for edit. Please select maximum of ' + maxRecord + ' milestone record in the table');
		} else if ($j(checkboxSelectedMilestone).length > maxRecord) {
			alert('More than ' + maxRecord + ' records selected for edit. Please select maximum of ' + maxRecord + ' milestone record in the table');
		} else {
			$j(checkboxSelectedMilestone).each(function () {
				milestoneIds =  $j(this).val() + ',' + milestoneIds;
			});
			
			showWindowPop('/apex/IMP_MilestonesEdit','?id=' + subjProjectId + '&mid=' + milestoneIds,window.innerWidth,600);
		}
		
	}