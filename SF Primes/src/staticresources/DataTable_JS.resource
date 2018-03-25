var j$; if(j$==null) { j$ = jQuery.noConflict(); }
j$(document).ready(function(){init();});

var SelectedItems = [];

function init() 
{
    j$("#SelectedItems").children().each(function(){j$(this).remove();});
    SelectedItems = [];
    
	var SelectAll = j$("[id$='SelectAll']");
	
	if(__checkboxes && __checkboxes == "true") { j$("#SelectedItemsContainer").css("display","block"); }
	
	var DataTable = null;
	DataTable = j$("[id$='DataTable']").dataTable({
		"bDestroy": true, // allow this datatable to be destroyed 
		"bJQueryUI": true, // use the jQuery UI theme 
		"sPaginationType": "full_numbers", // show full numbers for paging 
		"iDisplayLength": 25,
		"bRetrieve": true,
		"bAutoWidth": false,
		"aoColumnDefs": [{ "sType":"html", "bSortable":false, "bVisible": __checkboxes == "true", "aTargets":[0] }],
		//"sDom": "<'H'<'#ButtonContainer'>rf>t<'F'ip>", // set the positioning of the table elements
		"fnDrawCallback": function() {
			// format the parent of the parent of the Select All checkbox and the container of that element 
			SelectAll.parent().parent().css("padding-right","0").parent().css("width","12px");
			
			j$("[id$='DataTable'] input[type=checkbox].check:not(.bound)").addClass("bound").bind("click", function(){
				var ItemCheckbox = j$(this); 
				var SalesforceId = String(ItemCheckbox.parent().children("[id$='id']").val());
				var SalesforceName = String(ItemCheckbox.parent().children("[id$='name']").val());
				var item = {};
				
				if(SalesforceId != null) {
					item["Id"] = SalesforceId; 
					item["Name"] = SalesforceName != null ? SalesforceName : SalesforceId;
					
					if(this.checked) {
						SelectItem(item);
					}
					else {
						UnSelectItem(item); 
					}
				}
			});
			
			SelectAll.unbind("click");
			SelectAll.bind("click",function() {
				var AllCheckboxes = j$("input:checkbox", DataTable.fnGetFilteredNodes());
				
				// clear out previous selections
				j$("#SelectedItems").children().each(function(){j$(this).remove();});
				SelectedItems = [];
				
				if(SelectAll.attr("checked"))
				{
					AllCheckboxes.attr("checked", "checked");
					
					// select all filtered results
					AllCheckboxes.each(function(){ 
						var current = j$(this); 
						var item = {};
						
						item["Id"] = String(current.parent().children("[id$='id']").val());
						item["Name"] = String(current.parent().children("[id$='name']").val());
						
						SelectItem(item);
					}); 
				}
				else
				{
					AllCheckboxes.removeAttr("checked");
					j$("#SelectedItemsLabel").css("display","");
					
					// all previous selections have been cleared out already 
				}
			});
		}
	});
}

function SelectItem(item)
{
	//log(item);
	
	j$("#SelectedItemsLabel").css("display","none");
	
	var SelectedItem = j$("<span></span>");
	SelectedItem.attr("id",item["Id"]+"_selected");
	SelectedItem.html(item["Name"]);
	SelectedItem.css("margin","2px");
	
	SelectedItem.button({
		icons:{secondary:"ui-icon-close"}
	});
	
	j$("#SelectedItems").append(SelectedItem);
	
	SelectedItem.bind("click", {i:item}, function(e){
		if (e.data.i) { UnSelectItem(e.data.i); } //console.log(e.data.i);
	});
	
	var SelectedItemData = {
		"Id": item["Id"],
		"Name": escape(item["Name"])
	};
	
	SelectedItems.push(SelectedItemData);
}

function UnSelectItem(item)
{
	// remove from selected array 
	if (item && item["Id"]) {
		SelectedItems = j$.grep(SelectedItems, function(value) {
			if (value.Id) {
				return value.Id != item["Id"];
			}
		});
		
		if(SelectedItems.length < 1) { j$("#SelectedItemsLabel").css("display",""); }
		
		// retrieve the datatable 
		var DataTable = j$("[id$='DataTable']").dataTable({"bRetrieve": true});
		
		var idata = DataTable.fnGetNodes(); // get all table rows 
		j$("[id$="+item["Id"]+"_data"+"]", idata).children("input[type=checkbox]").removeAttr("checked"); // remove check from table 
	
		// need to use item id because will not always have sender pointer 
		j$("#"+item["Id"]+"_selected").remove(); // remove from selected list 
	}
}

function invAction()
{
	var SelectedIds = [];
	var SelectedIdsStr = "";
	j$(SelectedItems).each(function(index,item){SelectedIdsStr+=(index!=0?",":"")+item.Id; SelectedIds.push(item.Id);});
	
	//console.log(SelectedIds);
	
	j$("#ProcessingMessage").css("display","");
	
	Visualforce.remoting.Manager.invokeAction(__buttonaction,SelectedIds,
		function(result,event) {
			j$("#ProcessingMessage").css("display","none");
			__oncomplete();
		}
	);
}

function log(m) { if(console.log) { console.log(m); } }

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