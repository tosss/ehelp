var j$; if(j$==null) { j$ = jQuery.noConflict(); }
j$(document).ready(function(){ init();});

function UpdateDatatableSizes(dt) 
{
    j$(dt).css( "width", j$(dt).parent().width() );
    if(dt) { dt.fnAdjustColumnSizing(); }
}

function init()
{
    InitializeDataTables(false);
    EnableButton("#SaveNewStrategy", "Save New Strategy");
    SetDatePickers();
    
    j$("#tabs").tabs({
        //activate: function( event, ui ) {  
        //	UpdateDatatableSizes(j$("#OpenStrategyDataTable")); 
        //	UpdateDatatableSizes(j$("#StrategyHistoryDataTable"));
        //}
    });
    
    if (j$.browser.msie) { j$("textarea").resizable(); }
    
    if(__RecordTypeName.indexOf("PowerSEO") >= 0) { 
        j$(".dataTables_open_scroll").css("height","720px"); 
        j$(".dataTables_history_scroll").css("height","840px"); 
    }
    
    j$(document).scroll(onScroll);     
}


function onScroll(e) {
   
    var header = j$("#StrategyHistoryDataTableHeaders");       
    
    if(window.scrollY >= 190)
    {   
        
        j$("#StrategyHistoryDataTableHeaders1").show();
        header.addClass('sticky');
        j$("#StrategyHistoryDataTableHeaders").show();
       
    }
    else
    {
        header.removeClass('sticky');
        j$("#StrategyHistoryDataTableHeaders1").hide();
       
    }
    
}


function reinit()
{
    InitializeDataTables(true);
    EnableButton("#SaveNewStrategy", "Save New Strategy");
    SetDatePickers();
}

function InitializeDataTables(reset)
{
    var types = j$("th span", "[id$='OpenStrategyDataTableContainer']");
    
    var input_columns = [], output_columns = [];
    for(var i=0; i<types.length; i++) {
        var input_type = types[i].innerHTML != "" ? types[i].innerHTML : "input"; // default to input
        var output_type = input_type.indexOf("date") >= 0 ? "us_date" : "html"; // default to html
        input_columns.push({"sType":input_type}); 
        output_columns.push({"sType":output_type}); 
    } 
    
    //console.log(output_columns);
    
    var OpenStrategyDataTable = null;
    OpenStrategyDataTable = j$("#OpenStrategyDataTable").dataTable({
        //"bJQueryUI": true, 
        "bDestroy": reset,
        //"sScrollY": "260px",
        //"bScrollCollapse": true,
        "bLengthChange": false,
        "bFilter": false,
        "bPaginate": false,
        "sDom": "t",
        "aoColumns": input_columns,
        "aaSorting": [[ 1, "asc" ]],
        "oLanguage": {
            "sZeroRecords": "There are not any open items."
        }
    });
    
    var StrategyHistoryDataTable = null;
    StrategyHistoryDataTable = j$("#StrategyHistoryDataTable").dataTable({
        //"bJQueryUI": true, 
        "bDestroy": reset, 
        //"sScrollY": "300px",
        //"bScrollCollapse": true, 
        "bLengthChange": false, 
        "bFilter": false, 
        "bPaginate": false, 
        "sDom": "t",
        "aoColumns": output_columns,
        "aaSorting": [[ 1, "desc" ]],
        "oLanguage": {
            "sZeroRecords": "There are not any closed items."
        }
    });
    
    /*
    setTimeout(function() { 
        UpdateDatatableSizes(OpenStrategyDataTable); 
        UpdateDatatableSizes(StrategyHistoryDataTable);
    }, 1000);
    
    j$(window).resize(function() {
        clearTimeout(window.refresh_size);
        window.refresh_size = setTimeout(function() { 
            UpdateDatatableSizes(OpenStrategyDataTable); 
            UpdateDatatableSizes(StrategyHistoryDataTable);
        }, 100);
        //update_size(); // this is not done immediately because it causes lag when resizing the browser
    });
	*/
}

function SetDatePickers()
{
    j$(".type-date").datepicker( { "dateFormat": "m/d/yy" } );
    j$(".type-datetime").datepicker( { 
        "dateFormat": "m/d/yy", 
        "onSelect": function(dateText, inst) { 
            var time = new Date(); var hours = time.getHours(); var minutes = time.getMinutes();
            
            if (time.getHours() > 12) { hours = time.getHours() - 12; } 
            else if (time.getHours() == 0 ) { hours = "12"; } 
            else { hours = time.getHours(); }
            
            this.value = this.value + " " 
                + hours + ":" + minutes + " " + ((time.getHours() > 12) ? "PM" : "AM");
            
            j$(this).change();
        }
    });
}

function ToggleStrategyInputs(enable)
{
    var FormElements = j$("input, textarea, select", "[id$='DataTableContainer']");
    
    if(enable) { FormElements.removeAttr("disabled").css("disabled",""); }
    else { FormElements.attr("disabled","disabled").css("disabled","disabled"); }
}

function DisableRowStrategyInputs(sender)
{
    var FormElements = j$("input, textarea, select", j$(sender).closest("tr"));
    
    if(enable) { FormElements.removeAttr("disabled").css("disabled",""); }
    else { FormElements.attr("disabled","disabled").css("disabled","disabled"); }
}

var UpdatingField = [];

function DisableButton(sender, text) {
	j$(sender)
        .off("click")
        .html(text)
        .val(text)
        .attr("disabled","disabled")
        .removeAttr("onclick")
        .removeClass("btn")
        .addClass("btnDisabled")
        .css("cursor","default"); 
}

function EnableButton(sender, text) {
	j$(sender)
        .on("click", function(event) {
            event.preventDefault();
            DisableButton(this, 'Saving...'); 
            AddNewStrategy();
        })
        .html(text)
        .val(text)
        .removeAttr("disabled")
        .addClass("btn")
        .removeClass("btnDisabled")
        .css("cursor","pointer"); 
}

function DisableInput($sender) {
    $sender.attr("disabled", "disabled").addClass("disabled"); 
}

function MarkAsUpdating($sender) {
	$sender.removeClass("error").removeClass("updated").addClass("updating");
}

function EnableInput($sender) {
    $sender.removeClass("disabled").removeAttr("disabled"); 
}

function MarkAsUpdated($sender) {
	$sender.removeClass("updating").addClass("updated");
}

function MarkAsError($sender) {
	$sender.addClass("error");
}

function UpdateSObjectField($sender, sObjectId, FieldApiName, FieldValue)
{
    MarkAsUpdating($sender);
    
    var sObject = {};
    var FieldsToNull = [];
    sObject.Id = sObjectId;
    
    if(FieldValue == null || FieldValue == "" || FieldValue == undefined) {
    	FieldsToNull.push(FieldApiName);
    }
    else {
        if($sender.hasClass("type-date") || $sender.hasClass("type-datetime")) {
            FieldValue = Date.parse(FieldValue); }
        
        sObject[FieldApiName] = FieldValue;
    }
    
    CB_AccountPlan.SaveStrategy(sObject, FieldsToNull, function(result, event){ 
        if(result && result.toLowerCase().indexOf("success") === 0) { 
            MarkAsUpdated($sender); } 
        else 
        { 
            MarkAsError($sender); 
            j$("[id$='Errors']").html(result); 
            
            /*
            CB_AccountPlan.RefreshStrategy(sObjectId, FieldApiName, function(result, event) {
                if(result && result[FieldApiName]) { 
                    if($sender.hasClass("type-date") || $sender.hasClass("type-datetime")) {
                        var RefreshedDate = new Date(result[FieldApiName]);
                        var m = RefreshedDate.getMonth() + 1, 
                            d = RefreshedDate.getDate(), 
                            y = RefreshedDate.getFullYear();
                        var RefreshedDateString = m + "/" + d + "/" + y;
                        $sender.val(RefreshedDateString);
                    }
                    else { $sender.val(result[FieldApiName]); }
                }
            });
            */
        }
        
        EnableInput($sender);
    });
}