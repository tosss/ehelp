// use jQuery in noConflict mode because Salesforce uses another JavaScript library
var j$ = jQuery.noConflict();

// -- variables --
var resources;
var loadingurl;
var alltasks;
var selectedtasks;
var projectid;

var ProjectTasksTable;

// -- initialize -- 
j$(document).ready(init);

function init() { //log("Page initialized");
	
	alltasks = {};
	selectedtasks = [];
	resources = [];
	
	projectid = null;
	loadingurl = "url("+__InputBoxLoadingIcon+")"; 
	loadingurlsmall = "url("+__InputBoxLoadingIconSmall+")"; 
	
	// set the drop down arrow button
	j$("#ToggleAllProjects")
		.css( "display","" )
		.click(function() { ToggleAllProjects(); });
	
	// initialize the Select Project autocomplete
	j$("#SelectProject")
		.autocomplete({
			source: function(request, response){
				var search = (request.term && request.term.length > 1 ? request.term : ""); //log(search);
				
				try {
					LG_ResourceAssignment.SearchProjects(search, function(result, event){
						
						//log(result);
						var AllProjects = j$.map(result, function(item){
							return ({
								label: ConvertSpecialCharacters(item.Name),
								salesforceid: item.Id
							});
						});
						
						if (event.type == "exception") {
							MessageBox("Error", "An error occurred while searching Projects. "
								+ "There may be a number of causes such as the Salesforce session expiring. " 
								+ "It is recommended to refresh your browser by clicking the Refresh button below. \n\n"
								+ event.message, 
								{"Refresh":function(){window.location=window.location;}});
						}
						else {
							if (AllProjects.length > 0) {
								//log(AllProjects);
								response(AllProjects);
							}
							else {
								j$("#SelectProject").css("background", "transparent");
							}
						}
					});
				} 
				catch (error) {
					DisplayUnexpectedError();
				}
			},
			minLength: 0,
			select: SelectProject,
			search: function(){
				j$(this).css("background", loadingurl + " no-repeat right center #fff");
				projectid = null;
			},
			open: function(){
				j$(this).css("background", "#fff");
			}
		})
		.bind("click", function() {
			if (j$(this).val() == "") {
				j$(this).autocomplete("search", "");
			}
		});
	
	// sync up checkboxes
	j$(".load-assigned-tasks").bind("click", function(event){
		if (j$(this).attr("checked")) {
			j$(".load-assigned-tasks").attr("checked","checked");
		}
		else {
			j$(".load-assigned-tasks").removeAttr("checked");
		}
	});
	
	j$(".refresh-tasks").bind("click", function(event) {
		event.preventDefault();
		var ui = {}; ui.item = {}; ui.item.salesforceid = projectid;
		SelectProject(null, ui); // and remove all selected task labels
	});
	
	LG_ResourceAssignment.GetResources(function(result, event){
		//log(result);
		if (event.type == "exception") {
			MessageBox("Error", "An error occurred while retrieving the Resource list. "
				+ "There may be a number of causes such as the Salesforce session expiring. " 
				+ "It is recommended to refresh your browser by clicking the Refresh button below. \n\n"
				+ event.message, 
				{"Refresh":function(){window.location=window.location;}});
		}
		else {
			if(result.length > 0) {
				j$(result).each(function(index, item){
					resources.push({"Id":item.Id,"label":item.Name});
				});
				
				j$("#ResourceToAssign")
					.autocomplete({
						source: resources,
						minLength: 0,
						search: function(event, ui) { //log(ui);
							if(ui.item == null) { j$("#ResourceToAssignId").val(""); }
						},
						select: function(event, ui) {
							//log(ui.item);
							var idfield = j$("#ResourceToAssignId");
							if (ui.item.Id) {
								idfield.val(ui.item.Id);
							}
							else {
								idfield.val("");
							}
						}
					})
					.bind("click", function() {
						if (j$(this).val() == "") {
							j$(this).autocomplete("search", "");
						}
					});
			}
		}
	});
}

function ToggleAllProjects()
{
    j$("html, body").animate({ scrollTop: 0 }, "slow");
    
    // close if already visible
    if ( j$("#SelectProject").autocomplete( "widget" ).is( ":visible" ) ) {
        j$("#SelectProject").autocomplete( "close" );
        return;
    }

    // work around a bug
    j$("#SelectProject").blur(); // j$(this).blur() - makes IE minimize itself.. LOL!
    
    // pass empty string as value to search for, displaying all results
    j$("#SelectProject").autocomplete("search","");
    j$("#SelectProject").focus(); 
}

function SelectProject(e1, ui, followup)
{
	selectedtasks = [];
	RemoveAllSelectedTaskLabels();
	
	var loadalltasks = j$(".load-assigned-tasks:checked").length > 0;
	
	LG_ResourceAssignment.GetProjectTasks(ui.item.salesforceid, loadalltasks, function(resulttask, e2){
		
		if (e2.type == "exception") {
			MessageBox("Error", "An error occurred while searching Projects. "
				+ "There may be a number of causes such as the Salesforce session expiring. " 
				+ "It is recommended to refresh your browser by clicking the Refresh button below. \n\n"
				+ e2.message, 
				{"Refresh":function(){window.location=window.location;}});
		}
		else { 
			projectid = ui.item.salesforceid;
			
			//log(result);
			j$(".nt-container").css("display","none");
			j$(".dt-container").css("display","none");
			
			var rows = [];
			
			if (resulttask && resulttask.length > 0) {
				
				j$(resulttask).each(function(index, t){ 
					//log(t);
					
					alltasks[t.Id] = t;
					var row = [];
					
					if (t.Id) 
					{ 
						// checkbox
						row.push("<input type='checkbox' id='" + t.Id + "_checkbox' title='"
							+ ((t.mpm3__Resource__r && t.mpm3__Resource__r.Name) ? t.mpm3__Resource__r.Name : "") + "'></input>"); 
						
						// task name
						row.push("<a target='_blank' href='/" + t.Id + "' >" + t.Name + "</a>"); 
						
						// milestone name
						row.push("<a target='_blank' href='/" + t.mpm3__Project_Milestone__c + "' >" + t.mpm3__Project_Milestone__r.Name + "</a>");
						
						// resource fields
						var id = "<input id='"+t.Id+"_id' type='hidden' value='"+(t.mpm3__Resource__c?t.mpm3__Resource__c:"")+"' />";
						var name = "<input id='"+t.Id+"_name' class='dt-input' type='text' "
							+"value='" + ((t.mpm3__Resource__r && t.mpm3__Resource__r.Name) ? t.mpm3__Resource__r.Name : "") + "'/>";
						row.push(id+name);
						
						// start date
						row.push(DateToString(t.mpm3__Start_Date__c));
						
						// due date
						row.push(DateToString(t.mpm3__Due_Date__c));
						
						rows.push(row);
					} 
					else { row.push(""); }
					
					// show datatable
					j$(".nt-container").css("display","none");
					j$(".dt-container").css("display","");
				});
			}
			else {
				j$(".nt-container").css("display","");
				j$(".dt-container").css("display","none");
			}
			
			//log(rows);
			
			ProjectTasksTable = null;
			ProjectTasksTable = j$("#ProjectTasksTable").dataTable({
				"aaData": rows,
				"bJQueryUI": true, // use the jQuery UI theme
				"bDestroy": true, // allow the table to be reset
				"bAutoWidth": false,
				"iDisplayLength": 100,
				"sPaginationType": "full_numbers", // show full numbers for paging
				"aaSorting": [[4,'asc']],
				"fnDrawCallback": function() {
					
					j$("#ProjectTasksTable input[type=text]:not(.autocomplete)")
						.addClass("autocomplete")
						.autocomplete({
							source: resources,
							minLength: 0,
							search: function(event, ui) { //log(ui);
								j$("#" + j$(this).attr("id").replace("name", "id")).val("");
							},
							select: function(e3, ui) {
								//log(ui.item);
								
								// this gets mixed up, so use sender variable instead
								var sender = j$(this); sender.attr("disabled","disabled");
								var idfield = j$("#" + sender.attr("id").replace("name", "id"));
								
								if (ui.item.Id) { idfield.val(ui.item.Id); }
								else { idfield.val(""); }
								
								sender.css("background", loadingurlsmall + " no-repeat right center #fff");
								sender.css("font-style", "italic");
								
								var obj = [];
								obj.push({"Id":sender.attr("id").replace("_name", ""),"mpm3__Resource__c":ui.item.Id});
								
								LG_ResourceAssignment.AssignResources(obj, function(result, event) { //log(result);
									if (result && result.success) { //log("success");
										sender.removeAttr("disabled");
										sender.css("background", "#fff");
										sender.css("font-style", "normal");
									}
									else {
										sender
											.css("background", "#fff")
											.css("border-color","red")
											.attr("title",result.message);
									}
								});
							}
						})
						.bind("blur", function(){
							var sender = j$(this); 
							var idfield = j$("#" + j$(this).attr("id").replace("name", "id"));
							
							if(sender.val() != "" && idfield.val() == "")
							{
								sender.attr("disabled","disabled");
								sender.css("background", loadingurlsmall + " no-repeat right center #fff");
								sender.css("font-style", "italic");
								
								var obj = [];
								obj.push({"TaskId":sender.attr("id").replace("_name", ""), "ResourceName": sender.val()});
								
								LG_ResourceAssignment.AssignResourcesByName(obj, function(result, event) { //log(result);
									if (result && result.success) { //log("success");
										
										//var sender = j$("#"+obj.TaskId+"_name");
										sender.removeAttr("disabled");
										sender.css("background", "#fff");
										sender.css("font-style", "normal");
										
										if(result.objects) { //log(result.objects);
											j$(result.objects).each(function(index, resultobj){ //log(obj);
												var returnedresource = j$.grep(resources,function(v){return v.Id === resultobj.mpm3__Resource__c});
												var resourcename = (returnedresource && returnedresource.length > 0 ? returnedresource[0].label : "");
												j$("#"+resultobj.Id+"_name").val(resourcename);
												j$("#"+resultobj.Id+"_id").val(resultobj.mpm3__Resource__c);
											});
										}
									}
									else {
										sender
											.css("background", "#fff")
											.css("border-color","red")
											.attr("title",result.message);
									}
								});
							}
						})
						.bind("click", function() {
							if (j$(this).val() == "") {
								j$(this).autocomplete("search", "");
							}
						});
					
					j$("#ProjectTasksTable input[type=checkbox]:not(.bound)").addClass("bound").bind("click", function(){
						var aData = ProjectTasksTable.fnGetData(this.parentNode.parentNode);
						var TaskCheckbox = j$(aData[0]); //log(TaskCheckbox);
						var TaskName = j$(aData[1]); //log(TaskCheckbox);
						var SalesforceTaskId = null;
						var SalesforceTaskName = null;
						var task = {};
						
						try { 
							SalesforceTaskId = String(TaskCheckbox.attr("id")).split("_")[0]; 
							SalesforceTaskName = TaskName.html(); 
						} 
						catch(exc) { log("ERROR: "+exc); }
						
						if(SalesforceTaskId != null) {
							task["Id"] = SalesforceTaskId; 
							task["Name"] = SalesforceTaskName;
							
							if(this.checked) {
								SelectTask(task); //log("selecting "+task["Id"]);
							}
							else {
								UnSelectTask(task); //log("unselecting "+task["Id"]);
							}
						}
					});
				},
				"aoColumns": [
					{"sTitle":"<input type='checkbox' id='selectall' title='Select All'></input>", 
						"sType":"html", "bSortable": false, "sWidth":"12px"},
					{"sTitle":"Name", "sType":"html"},
					{"sTitle":"Milestone", "sType":"html"},
					{"sTitle":"Resource", "sType":"html"},
					{"sTitle":"Start Date", "sType":"date"},
					{"sTitle":"Due Date", "sType":"date"}
				]
			});
			
			j$("#selectall").parent().css("padding","0").parent().css("width","12px");
			
			var SelectAll = j$("#selectall", ProjectTasksTable);
			
			SelectAll.unbind("click");
			SelectAll.bind("click",function() {
				var AllCheckboxes = j$("input:checkbox", ProjectTasksTable.fnGetFilteredNodes());
				
				// clear out previous selections
				j$("#SelectedTasks").children().each(function(){j$(this).remove();});
				selectedtasks = [];
				
				if(SelectAll.attr("checked"))
				{
					AllCheckboxes.attr("checked", "checked");
					
					// select all filtered results
					AllCheckboxes.each(function(){ 
						var current = j$(this); 
						var task = {};
						
						task["Id"] = String(current.attr("id")).split("_")[0];
						task["Name"] = alltasks[task["Id"]].Name;
						
						SelectTask(task);
					}); 
				}
				else
				{
					AllCheckboxes.removeAttr("checked");
					j$("#SelectedTasksLabel").css("display","");
				}
			});
			
			// assign resources
			j$("#AssignResources").unbind("click");
			j$("#AssignResources").bind("click", function(event){
				event.preventDefault();
				AssignResourcesClick("Assigning '"+j$("#ResourceToAssign").val()+"' to all selected Tasks.");
			}); // end bind AssignResources
			
			// unassign resources
			j$("#UnassignAllResources").unbind("click");
			j$("#UnassignAllResources").bind("click", function(event){
				event.preventDefault();
				
				j$("#ResourceToAssign").val("");
				j$("#ResourceToAssignId").val("");
				
				var AllCheckboxes = j$("input:checkbox", ProjectTasksTable.fnGetFilteredNodes());
				
				// clear out previous selections
				j$("#SelectedTasks").children().each(function(){j$(this).remove();});
				selectedtasks = [];
				
				AllCheckboxes.attr("checked", "checked");
				
				// select all filtered results
				AllCheckboxes.each(function(){ 
					var current = j$(this); 
					var task = {};
					
					task["Id"] = String(current.attr("id")).split("_")[0];
					task["Name"] = alltasks[task["Id"]].Name;
					
					SelectTask(task);
				}); 
				
				AssignResourcesClick("Un-assigning Resources from all listed Tasks.");
			});
			
			if (followup) {
				followup.close(followup.messagebox);
			}
		} // else, no exception
	});
}

function AssignResourcesClick(armessage)
{
	if (selectedtasks.length > 0 && j$("#SelectedTasks").children().length > 0) {
		
		// this method is inefficient, as it needs to loop through the table multiple times
		// to set the inputs to the selected value
		//var AllInputs = j$("input:not(:checkbox)", ProjectTasksTable.fnGetFilteredNodes());
		
		var ts = [];
		var tabletasks = [];
			
		
		if (j$("#ResourceToAssignId").val() == "" && j$("#ResourceToAssign").val().length > 0) {
			j$(selectedtasks).each(function(index, item){
				ts.push({
					"TaskId": item["Id"],
					"ResourceName": j$("#ResourceToAssign").val()
				});
			});
			
			var mb1 = MessageBox(
				"Assigning Resources...",
				armessage
			);
			
			LG_ResourceAssignment.AssignResourcesByName(ts, function(result, event) { 
				// remove all selected tasks
				
				if (result && result.success) {
					var ui = {};
					ui.item = {};
					ui.item.salesforceid = projectid;
					
					SelectProject(null, ui,{"messagebox":mb1,"close":function(mb1){mb1.dialog("close");}}); // and remove all selected task labels
				}
				else
				{
					mb1.dialog("close");
					RemoveAllSelectedTaskLabels();
					
					var mb2 = MessageBox(
						"Error",
						result.message, 
						{"Ok": function(){j$(this).dialog("close");}}
					);
				}
				
				/* inefficient
				j$(tabletasks).each(function(index, v) { 
					v.removeAttr("disabled");
					if (!result.success) { v.css("border-color","red"); }
				});
				*/
			});
		}
		else {
			j$(selectedtasks).each(function(index, item){
				ts.push({
					"Id": item["Id"],
					"mpm3__Resource__c": j$("#ResourceToAssignId").val()
				});
				
				/* inefficient
				j$(ts).each(function(index, item){
					var match = j$.grep(AllInputs, function(v) {
						return j$(v).attr("id") == item["Id"] + "_name";
					});
					
					//log(match);
					
					var jv = j$(match); 
					jv.attr("disabled","disabled").val(j$("#ResourceToAssign").val());
					
					tabletasks.push(jv);
				});
				*/
			});
			
			var mb1 = MessageBox(
				"Assigning Resources...",
				armessage
			);
			
			LG_ResourceAssignment.AssignResources(ts, function(result, event) { 
				
				if (result && result.success) {
					var ui = {};
					ui.item = {};
					ui.item.salesforceid = projectid;
					
					SelectProject(null, ui,{"messagebox":mb1,"close":function(mb1){mb1.dialog("close");}}); // and remove all selected task labels
				}
				else
				{
					// remove all selected tasks
					RemoveAllSelectedTaskLabels();
					
					var mb2 = MessageBox(
						"Error",
						result.message, 
						{"Ok": function(){j$(this).dialog("close");}}
					);
				}
				
				/* inefficient
				j$(tabletasks).each(function(index, v) { 
					v.removeAttr("disabled");
					if (!result.success) { v.css("border-color","red"); }
				});
				*/
			});
		}
	}
	else
	{
		MessageBox(
			"Select One or More Tasks",
			"Please select one or more Tasks to Assign Resources.",
			{"Ok": function(){j$(this).dialog("close");}}
		);
	}
}

function MessageBox(t, m, b) 
{ 
	var mb = j$("<div>"); 
	if (m) { mb.html(m); } else { mb.html("Processing..."); }
	
	mb.dialog({
		modal: true,
		autoOpen: false,
		title: (t?t:"Please Wait..."),
		buttons: (b?b:{})
	});
	
	mb.dialog("open");
	
	return mb;
}

function SelectTask(task)
{
	//log(task);
	
	j$("#SelectedTasksLabel").css("display","none");
	
	var SelectedTask = j$("<span></span>");
	SelectedTask.attr("id",task["Id"]+"_selected");
	SelectedTask.html(task["Name"]);
	SelectedTask.css("margin","2px");
	
	SelectedTask.button({
		icons:{secondary:"ui-icon-close"}
	});
	
	j$("#SelectedTasks").append(SelectedTask);
	
	SelectedTask.bind("click", {t:task}, function(e){
		if (e.data.t) { UnSelectTask(e.data.t); } //log(e.data.t);
	});
	
	var SelectedTaskData = {
		"Id": task["Id"],
		"Name": escape(task["Name"])
	};
	
	selectedtasks.push(SelectedTaskData);
}

function UnSelectTask(task)
{
	// remove from selected array
	if (task && task["Id"]) {
		selectedtasks = j$.grep(selectedtasks, function(value) {
			if (value.Id) {
				return value.Id != task["Id"];
			}
		});
		
		if(selectedtasks.length < 1) { j$("#SelectedTasksLabel").css("display",""); }
	
		// retrieve the datatable
		var taskstable = j$("#ProjectTasksTable").dataTable({"bRetrieve": true});
		
		var tdata = taskstable.fnGetNodes(); // get all table rows
		j$("[id^="+task["Id"]+"]", tdata).removeAttr("checked"); // remove check from table
	
		// need to use task id because will not always have sender pointer
		j$("#"+task["Id"]+"_selected").remove(); // remove from selected list
	}
}

function RemoveAllSelectedTaskLabels()
{
	j$("#SelectedTasks").children().each( function(index, item) { 
		j$(item).remove(); 
	}); 
	
	j$("#SelectedTasksLabel").css("display","");
}

// -- custom datatable plugin functions --

// custom datatable function to get filtered nodes
j$.fn.dataTableExt.oApi.fnGetFilteredNodes = function (oSettings)
{
	var anRows = [];
	for (var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++)
	{
		var nRow = oSettings.aoData[oSettings.aiDisplay[i]].nTr;
		anRows.push(nRow);
	}
	return anRows;
};

// -- Utility Functions

function FormatPhoneNumber(number)
{
	var digits = (""+number).replace(/\D/g, "");
	var match = digits.match(/1?(\d{3})(\d{3})(\d{4})$/);
	return (!match) ? digits : "(" + match[1] + ") " + match[2] + "-" + match[3];
}

function DateToString(InitialDate)
{
	var ResultCreatedDate = new Date(InitialDate);
	var ResultCreatedDateString = "";
	
	// convert for time-zone
	ResultCreatedDate = new Date(ResultCreatedDate.setUTCHours(ResultCreatedDate.getTimezoneOffset()/60));
	
	if (InitialDate && InitialDate != "") 
	{
		ResultCreatedDateString += ResultCreatedDate.getMonth() + 1 + "/";
		ResultCreatedDateString += ResultCreatedDate.getDate() + "/";
		ResultCreatedDateString += ResultCreatedDate.getFullYear() + " ";
	}
	
	return ResultCreatedDateString;
}

function ConvertSpecialCharacters(text)
{
	var temp = document.createElement("div");
	temp.innerHTML = text;
	var result = temp.childNodes[0].nodeValue;
	temp.removeChild(temp.firstChild)
	return result;
}

function DisplayUnexpectedError()
{
	MessageBox("Error", "An unexpected error occurred. "
		+ "There may be a number of causes such as the Salesforce session expiring. " 
		+ "It is recommended to refresh your browser by clicking the Refresh button below. ", 
		{"Refresh":function(){window.location=window.location;}});
};

function ValidEmail(email) 
{
    var re = /^([^\@]*)\@([^\.]*)\.(.*)$/;
    return re.test(email);
}

function log(l) 
{
    if (j$.browser.mozilla) { console.log(l); } //else { alert(l); }
}