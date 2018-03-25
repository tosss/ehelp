// check to see if no conflict mode is already set. if not, set it
var j$; if(!j$) { j$ = jQuery.noConflict(); } 

// top-level variables
var loadingurl; 
var CloneResultBox;
var CloneDisplayColumns = [];
var ClonedRecords = [];
var AllCloneRecordSettings = [];
var QueryStringCloneSettings = {};
var VFRemotingTimeout = 120000;

var temp; // temp variable for testing
var AllowOverridePreferredValues = false;
var SourceRecordUpdate = {};
var ReferenceFieldNameAndId = {};

// initialize when the document is ready for viewing
j$(document).ready(InitializePage);

/* Testing Statements
 * ------------------
 * // Select the first element of each of the select elements in the cloned table
 * j$("select.editable").each(function(i,v){v.selectedIndex = 1;}); j$("select.editable").change();
 * 
 * // Find all log statements
 * ^((?!//|/\*).)*[ ]+log\(.*
 */

function InitializePage()
{    
    Visualforce.remoting.timeout = VFRemotingTimeout;
    loadingurl = "url("+__InputBoxLoadingIcon+")";
    
    // hide the Find Source section if the sType and sId are provided 
    if(__sType && __sId) { j$("[id$='FindSource'] img").click(); }  
    
    var wait = MessageBox("Please wait", "<br/><div style='text-align:center;'><span style='font-size:16pt;width:100%;'>Loading...</span></div>");
    
    DSCB_CloneAnything.GetAllSObjectCloneSettingsList(function(result, event) { //log(result);
        AllCloneRecordSettings = result;
        
        QueryStringCloneSettings = GetCurrentCloneSettings(AllCloneRecordSettings, __sType, __sSubType);
        
        // select the first option in the Source Object Type field
        if(QueryStringCloneSettings != null) { j$("[id$='SelectType']").val(QueryStringCloneSettings.Id); }   
        else { j$("[id$='SelectType']").val(j$("[id$='SelectType'] option:first").val()); }
        
        // initialize the Select Project auto-complete 
        j$("#SelectSObject")
            .bind("keypress",BypassEnterKey)                  
            .autocomplete({
                source: AutocompleteSource,
                minLength: 2,
                delay: 750,
                select: SelectSObject,
                search: function() {
                    j$(this).css("background", loadingurl + " no-repeat right center #fff");
                },
                open: function() {
                    j$(this).css("background", "#fff");
                }
            })
            .bind("click", function() {
                if (j$(this).val() == "") {
                    j$(this).autocomplete("search", "");
                }
            });
        
        wait.dialog("close");
    });
    
    var FirstSourceField = j$("[id$='0:SourceRecordOutput']");
    var FirstSourceFieldContent = FirstSourceField.val() != "" ? FirstSourceField.val() : FirstSourceField.html();
    console.log(FirstSourceFieldContent);
    var sObjectRedirectFieldAndValue = "field=" + __SobjectCloneStettingsNameField + "&value="+FirstSourceFieldContent;
    console.log(sObjectRedirectFieldAndValue);
    var SourceRecordId = j$("[id$='HiddenSourceRecordId']").val();
    if(SourceRecordId) { sObjectRedirectFieldAndValue = "field=Id&value=" + SourceRecordId }
    console.log(SourceRecordId);
    
    FirstSourceField.replaceWith(
        function() {
            return j$("<a>")
                .html(FirstSourceFieldContent)
                .attr("target","_blank")
                .attr("href","/apex/sObjectRedirect?type=" + __sType + "&" + sObjectRedirectFieldAndValue); 
                //.attr("href","/apex/sObjectRedirect?type=" + __sType + "&field=Name&value="+FirstSourceFieldContent);
        }
    );
    
    j$(".datatable a").attr("target","_blank");
    
    
}

function GetCurrentCloneSettingsById(AllCloneRecordSettings, CloneSettingsId) {
    var CurrentCloneSettings = null;
    
    for(index in AllCloneRecordSettings) {
        var CloneSettings = AllCloneRecordSettings[index];
        if(CloneSettings.Id == CloneSettingsId) {
            CurrentCloneSettings = CloneSettings;
        }
    }
    
    return CurrentCloneSettings;
}

function GetCurrentCloneSettings(AllCloneRecordSettings, sType, sSubType) {
    var QueryStringCloneSettings = null; 
    
    for(index in AllCloneRecordSettings) {
        var CloneSettings = AllCloneRecordSettings[index];
        if(CloneSettings.sObject_API_Name__c == sType 
        && (sSubType == null || CloneSettings.SubType__c == sSubType)) {
            QueryStringCloneSettings = CloneSettings;
        }
    }
    
    return QueryStringCloneSettings;
}

function AutocompleteSource(request, response) { //log(request);
    var search = (request.term && request.term.length > 1 ? request.term : ""); //log(search); 
    
    try {
        var CloneSettingsId = j$("[id$='SelectType']").val();
        
        var CurrentCloneSettings 
            = GetCurrentCloneSettingsById(AllCloneRecordSettings, j$("[id$='SelectType']").val());
        
        //log(CurrentCloneSettings)
        
        // __sType and __sSubType are set here because search needs to know which parameters to use for search
        //   this affects the process wherever __sType and __sSubType are used in other functions
        __sType = CurrentCloneSettings.sObject_API_Name__c;
        __sSubType = CurrentCloneSettings.SubType__c;
        
        var SearchParameters = {sObjectType:__sType, sSubType:__sSubType, SearchTerm:search};   
        
        DSCB_CloneAnything.SearchSObjectsWithSubType(SearchParameters, function(result, event) { //log(result); //log(event);
            if(result) {
                var AllRecords = j$.map(result.sObjects, function(item){  
                    var AutocompleteLabel = "";
                    j$(result.Fields).each(function(i,v) { //log(result.Fields);   
                        var AutocompleteField = item;
                        
                        // if the value contains dot notation for referencing a child field 
                        // and the parent (first part of the dot notation) is not null 
                        if(v.indexOf(".") > 0 && item[v.split(".")[0]]) { 
                            j$(v.split(".")).each(function(x,n){ 
                                AutocompleteField = AutocompleteField[n] ? AutocompleteField[n] : AutocompleteField; }); }
                            else { 
                                AutocompleteField = item[v]; }
                           
                        AutocompleteLabel += (AutocompleteField ? 
                            (AutocompleteLabel != "" ? " - " + AutocompleteField : AutocompleteField) : ""); 
                    });
                    
                    var mapResults = {
                        label: ConvertSpecialCharacters(AutocompleteLabel),
                        sfid: item.Id,
                        aid: item[result.AccountField]
                    };
                    
                    //log(mapResults);
                    return mapResults;
                });
                
                if (event.type == "exception") {   
                    MessageBox("Error", "An error occurred while searching sObjects. "
                        + "There may be a number of causes such as the Salesforce session expiring. " 
                        + "It is recommended to refresh your browser by clicking the Refresh button below. \n\n"
                        + event.message, 
                        {"Refresh":function(){window.location=window.location;}});
                }
                else {
                    if (AllRecords.length > 0) {
                        response(AllRecords);
                    }
                    else {
                        j$("#SelectSObject").css("background", "transparent");
                    }
                }
            }
        });
    } 
    catch (error) {
        DisplayUnexpectedError(error);
    }

}

// invoked from the page when a new sObject Type is selected
function ToggleAutocompleteSearch()
{
    var ac = j$("#SelectSObject");
    
    if(ac.val().length > 0)
    {
        ac.autocomplete("search",ac.val());
        ac.focus();
    }
}

function CloneToSelected()
{
    // disable or remove the Override with preferred values button
    DisableButton();
    var CloneToIds = [];
    
    // selected items exists in the data table component included on the page
    j$(SelectedItems).each( function(i,v) { CloneToIds.push(v.Id); } );
    console.log(CloneToIds);
    var i = j$("#divid :input"); 
    
    //console.log(i); 
    
    var msg = j$("<div>")
        .addClass("processing-message")
        .append(j$("<div>").html("Cloning to the Selected Destination records. <br/>Please wait..."))
        .append(j$("<img>").attr("src",__ProcessingBarLoadingIcon));
    
    var wait = MessageBox("Cloning...", msg);
    
   
    
    if(CloneToIds != "") 
    { 
        SetToTrue(); // SivaP 1/21/2015 moved this from vf page to here to avoid a jvascript error. Though this method is Action function method, it's still
                     // working from here when called.
       
        //alert(AllowOverridePreferredValues);
        
        var FieldLists;
        var CloneParameters;
        var _DisplayAsOutputFields = j$("[id$='DisplayAsOutputFields']").val(); //alert('At Cloning process : ' + _DisplayAsOutputFields);
        if(AllowOverridePreferredValues == true)
        { 
            //alert('inside override '); 
            FieldLists = SourceRecordFieldsForEdit();
            
            SourceRecordUpdate = EditSourceRecord(FieldLists); console.log(SourceRecordUpdate); 
            
            CloneParameters = {sObjectType:__sType, sSubType:__sSubType, DestinationIdsList:CloneToIds, SourceIdString:__sId, SourceRecordUpdate:SourceRecordUpdate, DisplayAsOutPutFields2: _DisplayAsOutputFields};
        }
        else
        {
             CloneParameters = {sObjectType:__sType, sSubType:__sSubType, DestinationIdsList:CloneToIds, SourceIdString:__sId, DisplayAsOutPutFields2:_DisplayAsOutputFields};
        }
        
        console.log(CloneParameters);
        
        DSCB_CloneAnything.CloneToSelectedWithParameters(CloneParameters, function(returned, event) { 
            
            //console.log(returned);

            //temp = returned; 
            if(!returned) { //log(event);
                wait.html(j$("<div>").html('An unexpected error occurred. <br/><br/>ERROR: ' + event.message));
            }
            else if(returned && returned.Success != true) {
                wait.html(j$("<div>").html(returned.Message));
            }
            else {
                var ClonedRecordsContainer = j$("#ClonedRecordsContainer");
                ClonedRecordsContainer.css("display","block");
                
                var ClonedRecordsTable = j$("#ClonedRecordsTable", ClonedRecordsContainer); 
                
                // set column headers and initialize table
                if(j$("#ClonedRecordsContainer table thead tr th").length < 1)
                {                    
                    var ColumnDefinitions = AddClonedResultsTableColumns(ClonedRecordsTable, returned.Columns);
                    InitializeClonedResultsTable(ClonedRecordsTable, ColumnDefinitions);
                }
                
                var AllDestinationIds = [];
                
                // add any rows that were selected to the Cloned Records Table (and to the ClonedRecords array)
                j$(returned.Results).each(function(i, result) { //log(result);
                    /* Result contains
                     *   Boolean Success;
                     *   String Message;
                     *   Map<String, Clone_Display_Field_Settings__c> Columns;
                     *   List<DSCB_CloneAnything.ClonedDisplayRecord> Results; */
                    
                    // add to all destination ids for processing row removals later
                    AllDestinationIds.push(result.Destination);
                    
                    var ExistingClonedRecord = FindExistingClonedRecord(result.Destination); //log(ExistingClonedRecord);
                    
                    // do not add if already existing
                    if(!ExistingClonedRecord) 
                    {                       
                        var row = CreateRow(result.Destination, result.Record, result.Fields, CloneDisplayColumns);
                        //console.log(result.Record);
                        //console.log(result.Fields);
                        //console.log(row);
                        //var reg = /((^[0-9]+[a-z]+)|(^[a-z]+[0-9]+))+[0-9a-z]+$/i;
                        // add record to Cloned Records array and to the displayed datatable
                        ClonedRecords.push({"key": result.Destination, "record": result.Record});                       
                        j$("#ClonedRecordsTable").dataTable().fnAddData(row);
                    }
                });
                
                // remove any rows that were not selected from the Cloned Records Table (and from the ClonedRecords array)
                j$.each(ClonedRecords, function(i, record){
                    if(j$.inArray(record.key, AllDestinationIds) == -1) { 
                        RemoveClonedRecord(ClonedRecordsTable, record.key); }
                });
                
                wait.dialog("close");
                
                // scroll to the bottom of the page
                j$('html, body').animate({ scrollTop: j$("#ClonedRecordsContainer").offset().top }, 1000);
            }
        });
    }
    else {
        wait.dialog("close");
        MessageBox("Invalid Destination Record(s)","Please select at least one destination record.")
    }
}

function AddClonedResultsTableColumns(table, columns) 
{
    var cols = [];
    var ColumnDefinitions = [];
    
    j$.each(columns, function(i, v) { cols.push({ name: v.Name, obj: v }); });
    
    //console.log(cols);
    
    // returning 1 or -1 for IE8 & IE9 sort compatibility
    CloneDisplayColumns = j$(cols).sort( function(a,b) { return a.name > b.name ? 1 : -1; } );
    
    //log('--300--');
    //log(CloneDisplayColumns);
    
    var ClonedRecordsTableHeaderRow = j$("<tr>");
    
    j$.each(CloneDisplayColumns, function(i,col) { //log(i); //log(col);
        ClonedRecordsTableHeaderRow.append(
            j$("<th>")
                .html(col.obj.Field_Header_Text__c)
                .attr("id", col.obj.Field_API_Name__c));
        
        if(col.obj.Field_Editable__c == true || col.obj.Field_Display_Type__c == "Link") { 
            ColumnDefinitions.push({"sType": "html", "aTargets": [i]}); }
        else if(col.obj.Field_Display_Type__c == "Date") {
            ColumnDefinitions.push({"sType": "date", "aTargets": [i]}); }
        else { 
            ColumnDefinitions.push({"sType": "string", "aTargets": [i]}); }
    });
    
    //log('--317--');
    //log(CloneDisplayColumns);
    
    table.append(j$("<thead>").append(ClonedRecordsTableHeaderRow));
    
    return ColumnDefinitions;
}

function InitializeClonedResultsTable(ClonedRecordsTable, ColumnDefinitions) 
{
    // if there is no table body, add one
    var ClonedRecordsTableBody = j$("tbody", ClonedRecordsTable);
    if(ClonedRecordsTableBody.length < 1) { ClonedRecordsTable.append(j$("<tbody>")); }
    
    ClonedRecordsTable.addClass("display datatable");
    
    ClonedRecordsTable.dataTable({   
        "bJQueryUI": true,
        "bPaginate": false,
        //"iDisplayLength": 100, 
        //"sPaginationType": "full_numbers",
        "fnCreatedRow": function( nRow, aData, iDataIndex ) { 
            if(aData.length && aData[aData.length-1] && aData[aData.length-1].rowid) { // when a row is created 
                j$(nRow).attr("id", aData[aData.length-1].rowid); } // set the id to the first data element
        }, 
        "aoColumnDefs": ColumnDefinitions//,
        //"bRetrieve": true,
        //"bDestroy": true
    });
}

function CreateRow(key, record, fields, columns)
{
    //log(record); //log(columns);
    
    var row = [];
    
    // for each (sorted) column
    j$(columns).each(function(j, col) {
        var field = col.obj;
        /* Field is Clone_Display_Field_Settings__c in Salesforce:
         *   Field_API_Name__c                    Text(255)   *
         *   Field_Display_Type__c                Text(255)   *
         *   Field_Editable__c                    Checkbox    *
         *   Field_Header_Text__c                 Text(255)   *
         *   Field_Options_Query__c               Text(255)   *
         *   Field_Options_Query_Clone_Field__c   Text(255)   *
         *   Field_Options_Query_Match__c         Text(255)   *
         *   Field_Options_Query_Text__c          Text(255)   *
         *   Field_Options_Query_Value__c         Text(255)   *
         *   sObject_API_Name__c                  Text(255)   */
        
        var columndata = ParseNestedData(record, field.Field_API_Name__c);
        
        var cell = columndata ? columndata : ""; // default to displaying only text
        
        // if the field is editable
        if(field.Field_Editable__c) {
            var cell_id = key+":"+field.Field_API_Name__c;
            cell = j$("<input>").attr("id", cell_id).addClass("editable").val(columndata)
                .clone().wrap("<p>").parent().html();
            
            // if picklist, display picklist with options
            if(field.Field_Display_Type__c == "Picklist") { 
                var sel = j$("<select>")
                    .attr("id", cell_id)
                    .addClass("editable");
                
                var OptionsData = {};
                if(fields && fields[field.Field_API_Name__c]) { // if there are fields for this column/record
                    OptionsData = j$.map(fields[field.Field_API_Name__c].SelectOptions, function(name, id) { 
                        return ({"id": id, "name": name});
                    }); 
                }
                
                OptionsData = j$(OptionsData).sort(function(a, b) { return a.name > b.name ? 1 : -1; });
                
                // add a blank option
                sel.append(j$("<option>").attr("value", "").text("-- None --"));
                
                j$.each(OptionsData, function(indx, opt) {
                    var option = j$("<option>").attr("value", opt.id).text(opt.name);
                    if(record[field.Field_API_Name__c] == opt.id) { option.attr("selected","selected"); }
                    sel.append(option); //log(opt.id);
                });
                
                
                sel.val(columndata);
                //sel.val(j$("option:contains('Jimmy Oliver')", sel).val())
                
                cell = sel.clone().wrap("<p>").parent().html(); 
            }
            
            j$(document).on("change", ".editable", UpdateClonedRecordInArray);
        }
        
        if(field.Field_Display_Type__c == "Date") {
            
            if(columndata) {
                var CleanDate = new Date(columndata); //log(CleanDate);
                var CleanDateString = (CleanDate.getMonth()+1) + "/" + CleanDate.getDate() + "/" + CleanDate.getFullYear();
                
                if(CleanDate.getHours()) { 
                    var ampm = "AM";
                    var CleanHours = (CleanDate.getHours()+1);
                    var CleanMinutes = "" + CleanDate.getMinutes(); 
                    if(CleanMinutes.length < 2) { CleanMinutes = "0" + CleanMinutes; } 
                    if(CleanHours > 12) { CleanHours -= 12; ampm = "PM"; } 
                    CleanDateString += " " + CleanHours + ":" + CleanMinutes + " " + ampm; 
                }
                
                var add = j$("<span>").html(CleanDateString);
                cell = add.clone().wrap("<p>").parent().html();
            }
            
            //cell = new Date(columndata);
            //if(columndata){cell = new Date(columndata);} 
        }
        
        if(field.Field_Display_Type__c == "Link") { //log(field.Field_API_Name__c);
            if(columndata && columndata != "") { //log(columndata)
                var NestedIdData = null;
                var indexOfLastNested = field.Field_API_Name__c.lastIndexOf('\.');
                console.log(indexOfLastNested);
                if(indexOfLastNested > 0) {
                    var NestedIdFieldName = field.Field_API_Name__c.substring(0,indexOfLastNested) + ".Id"; 
                    console.log(NestedIdFieldName);
                    //log(field.Field_API_Name__c.substring(0,indexOfLastNested).indexOf("__r") > 0);
                    
                    if(NestedIdFieldName != null) {
                        NestedIdData = ParseNestedData(record, NestedIdFieldName); 
                    }
                    
                    //log('End Link Type');
                    //log(NestedIdData);
                }
                
                var anchor = j$("<a>");
                anchor.html(columndata);
                anchor.attr("target","_blank");
                
                if(NestedIdData != null) {
                    anchor.attr("href", "/" + NestedIdData);
                }
                else {
                    if(record && record.Id) {
                        anchor.attr("href", "/" + record.Id);
                    }
                }
                
                cell = anchor.clone().wrap("<p>").parent().html();
            }
        }
        
        row.push(cell);
    });
    
    row.push({"rowid": "clone_" + key});
    
    return row;
}

function UpdateClonedRecordInArray(changeEvent) 
{
    var fld = j$(this);
    fld.attr("disabled","disabled");
    fld.addClass("disabled");
    
    var row = j$(this).closest("tr");
    var rowid = row ? row.attr("id") : ""; 
    var key = rowid.split("_")[1]; 
    var fieldName = j$(this).attr("id").split("\:")[1]; 
    
    //log(key); log(fieldName);
    
    var ExistingClonedRecord = FindExistingClonedRecord(key); //log(ExistingClonedRecord);
    
    // if possible, update the field in the Cloned Record object
    if(ExistingClonedRecord && ExistingClonedRecord.record && fieldName) {
        if(j$(this).val()) { ExistingClonedRecord.record[fieldName] = fld.val(); } }
    else {
        // display the error
        MessageBox("Error Updating Cloned Record", 
            "An unexpected error occurred while updating the Cloned Record. Please contact support.", 
            null); 
        
        if(ExistingClonedRecord) { log("Found Record: "+ExistingClonedRecord); }
        if(ExistingClonedRecord.record) { log("Record: "+ExistingClonedRecord.record); }
        if(fieldName) { log("Field Name: "+fieldName); }
    }
    
    fld.removeAttr("disabled");
    fld.removeClass("disabled");
}

function RemoveClonedRecord(table, key) 
{
    var ClonedRecordsTable = table;
    var ExistingClonedRecord = FindExistingClonedRecord(key);
    
    var row = j$("#clone_"+key); 
    var rowNodePosition = ClonedRecordsTable.dataTable().fnGetPosition( row.get(0) );
    
    // if the record exists in both the array and as a row
    if(ExistingClonedRecord && row) { 
        ClonedRecordsTable.dataTable().fnDeleteRow(rowNodePosition); // remove the row from the table
        ClonedRecords = j$.grep(ClonedRecords, function(v) { return v.key != key; }); // remove it from the array
    }
}

function FindExistingClonedRecord(key) 
{
    var ExistingClonedRecord = j$.grep(ClonedRecords, function(v) { return v.key == key; });
    if(ExistingClonedRecord && ExistingClonedRecord.length > 0) { return ExistingClonedRecord[0]; }
    else { return null; }
}

function CallSaveClonesRemoteMethod(ClonedRecords, sId, sType, sSubType, wait, constant)
{
    //console.log(ClonedRecords);
    
    var OriginalClonedRecords = j$.extend(true, {}, ClonedRecords); // avoids duplicating the ClonedRecords
    var size = ClonedRecords.length;
    
    //log("ClonedRecords.length before pop :" + ClonedRecords.length);
    //wait.html(j$("<div>").html('Saving '+ size +'th'+' record of '+constant+' records....'));
    
    var ClonedRecordsTable = j$("#ClonedRecordsTable");
    
    if(size > 0)
    {
        var ClonedRecord = ClonedRecords.pop();
        //log("ClonedRecords.length After pop :" + ClonedRecords.length);
        
        var msg = j$("<div>")
            .append(j$("<p>").addClass("processing-message").html("Saving record " + (constant-(size-1)) + " of " + constant + " cloned records.<br>Please wait..."))
            .append(j$("<div>").attr("id",'waitprogressbar'));
        
        wait.html(msg);
        
        // hide overlay on dblclick
        j$(".ui-widget-overlay").dblclick( function() { j$(this).hide(); } );
        
        var progress = ((constant-size)/constant)*100;
        j$("#waitprogressbar").progressbar({value:progress});
        
        var ClonesToSave = {};
        ClonesToSave[ClonedRecord.key] = ClonedRecord.record;
        
        // add the sObjectType to the record (required for the Salesforce API)   
        ClonesToSave[ClonedRecord.key].sObjectType = sType;
        
        if(ClonesToSave[ClonedRecord.key] != null)
        {
            delete ClonesToSave[ClonedRecord.key]['What'];
        }
        //console.log(ClonesToSave);
        
        //var OverrideFields;
        //alert(AllowOverridePreferredValues);
        //if(AllowOverridePreferredValues == true){ alert('inside override ');OverrideFields = EditSourceRecord();}
       
        //console.log(ClonesToSave);
        //console.log(ReferenceFieldNameAndId); 
        
        var _DisplayAsOutputFields = j$("[id$='DisplayAsOutputFields']").val(); //alert('At Saving process : ' + _DisplayAsOutputFields);
        var SaveParameters = {sObjectType:sType, sSubType:sSubType, Clones:ClonesToSave, SourceIdString:sId, LookUpFieldMap:ReferenceFieldNameAndId, DisplayAsOutPutFields2: _DisplayAsOutputFields};//, OverrideFields:OverrideFields};
        
        //console.log(SaveParameters);
        
        DSCB_CloneAnything.SaveClonesWithParameters(SaveParameters, function(SaveResult, SaveEvent) { 
            //log('--SaveResult--');
            
            //log(SaveResult); 
            //log(SaveEvent);
            
            if(!SaveResult) {
                wait.html(j$("<div>").html('An unexpected error occurred. '));
                return;
            }
            
            if(SaveResult && !SaveResult.Success) {
                wait.html(j$("<div>").html(SaveResult.Message));
                return;
            }
            
            //log(SaveResult.Columns);
            if(SaveResult) {
                
                var cols = [];          
                
                j$.each(SaveResult.Columns, function(i, v) { cols.push({ name: v.Name, obj: v }); });                           
                
                CloneDisplayColumns = j$(cols).sort( function(a,b) { return a.name > b.name ? 1 : -1; } );                           
                
                //log(SaveResult.Results);
                j$.each(SaveResult.Results, function(i, sr) {
                    //log('ClonedRecords----'+ClonedRecords);
                    j$.each(OriginalClonedRecords, function(j, cr){   
                        if(sr.Destination == cr.key) {
                            var row = CreateRow(sr.Destination, sr.Record, sr.Fields, CloneDisplayColumns);
                           
                            // update the record in the Cloned Records array
                            cr.record = sr.Record; 
                            
                            // get the current row from the datatable (for updating)
                            var rowNodePosition 
                                = ClonedRecordsTable.dataTable().fnGetPosition( j$("#clone_"+sr.Destination).get(0) );
                            
                            // update the row in the displayed datatable
                            ClonedRecordsTable.dataTable().fnUpdate(row, rowNodePosition);
                            
                            // sort the datatable
                            ClonedRecordsTable.fnSort( [ [0,'asc'] ] );
                        }
                    });  
                });
            }
            
            //log("size before entering recursive method: "+size);
            
            if(size >= 0) {
                CallSaveClonesRemoteMethod(ClonedRecords, sId, sType, sSubType, wait, constant);
                if(size==1){wait.dialog("close");}
            }
        });
    }
}

function SaveClones()
{
    j$("[id$='SaveClonedRecords']").attr("disabled", "disabled").addClass("btnDisabled");
    
    var msg = j$("<div>")
        .addClass("processing-message")
        .append(j$("<div>").html("Saving the listed Cloned Records. <br/>Please wait..."))
        .append(j$("<img>").attr("src",__ProcessingBarLoadingIcon));
    
    var wait = MessageBox("Saving...", msg);
    var constant = ClonedRecords.length;
    
    //log("ClonedRecords:");
    //log(ClonedRecords);
    //console.log(ClonedRecords);
    CallSaveClonesRemoteMethod(ClonedRecords, __sId, __sType, __sSubType, wait, constant);
}

function ParseNestedData(sObject, field)
{
    var data = null;
    data = sObject[field] ? sObject[field] : ""; // default data to the field value
    
    // if nested data, parse nested data
    if (field.indexOf("\.") > 0) {
        var split = field.split("\."); 
        data = sObject[split[0]]; 
        
        if(data) {
            for(var i=1; i<split.length; i++) {
                if(data[split[i]]) { data = data[split[i]]; } 
            }
        }
    }
    
    return data;
}

function SelectSObject(e1, ui, followup)
{
    var CurrentCloneSettings 
        = GetCurrentCloneSettingsById(AllCloneRecordSettings, j$("[id$='SelectType']").val());
    
    var CurrentSubType = null;
    if(CurrentCloneSettings.SubType__c == null) { CurrentSubType = ""; }
    else { CurrentSubType = CurrentCloneSettings.SubType__c; }
    
    var orig = String(window.location.href).split("?")[0];
    window.location.href = orig 
        + "?sourcetype=" + CurrentCloneSettings.sObject_API_Name__c 
        + (ui.item.sfid ? "&sourceid=" + ui.item.sfid : "") 
        + (ui.item.aid ? "&aid=" + ui.item.aid : "")
        + ("&subtype=" + CurrentSubType);
}

function DisableCloneToSelectedButton()
{
    var CloneToSelected = j$("[id$='CloneToSelected']");
    var Cancel = j$("[id$='Cancel']");
    Cancel.attr("disabled", "disabled").addClass("btnDisabled");
    CloneToSelected.attr("disabled","disabled").addClass("btnDisabled");
}

function Cancel()
{
    var SearchString = window.location.search.substring(1);
    var VariableArray = SearchString.split('&');
    for(var i = 0; i < VariableArray.length; i++){
        var KeyValuePair = VariableArray[i].split('=');
        if(KeyValuePair[0] == 'sourceid')
        {                      
            window.location.assign('/' + KeyValuePair[1]);
        }
    } 
}

function DisableButton()
{
    var DisableButton = j$("[id$='SourceRecordEdit']");
    DisableButton.remove();    
}

// -- jQuery Utility Functions

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

function DisplayUnexpectedError(error)
{
    log(error);
    
    MessageBox("Error", "An unexpected error occurred. "
        + "There may be a number of causes such as the Salesforce session expiring. " 
        + "It is recommended to refresh your browser by clicking the Refresh button below. ", 
        {"Refresh":function(){window.location=window.location;}});
}

function EditSourceRecord(FieldLists)
{ 
    var REFERENCEfieldsList = FieldLists["REFERENCEfieldsList"];
    var AUTONUMBERfieldsList = FieldLists["AUTONUMBERfieldsList"];
    var FieldNames = FieldLists["FieldNames"];
    var DATEfieldsList = FieldLists["DATEfieldsList"];
    
    var SearchString = window.location.search.substring(1);
    var VariableArray = SearchString.split('&');
    
    for(var i = 0; i < VariableArray.length; i++){
        var KeyValuePair = VariableArray[i].split('=');
        if(KeyValuePair[0] == 'sourceid')
        {   
            SourceRecordUpdate['Id'] = KeyValuePair[1];
        }
    } 
    
    for (var i = 0; i < FieldNames.length; i++) 
    {               
        var FieldName = FieldNames[i];
        var FieldVal = j$("[id$='" + i + ":SourceRecordInput']").val(); 
        var ReferenceFieldFound = j$.inArray(FieldName, REFERENCEfieldsList) > -1;
        var AutoNumberFieldFound = j$.inArray(FieldName, AUTONUMBERfieldsList) > -1;
        var DATEfieldFound = j$.inArray(FieldName, DATEfieldsList) > -1;
        
         // alert(FieldName + "--- " +FieldVal);     
        if(ReferenceFieldFound && !AutoNumberFieldFound && !DATEfieldFound)
        {            
            var LookupId = j$("[id$='" + i + ":SourceRecordInput_lkid']").val();
            var LookupName = j$("[id$='" + i + ":SourceRecordInput']").val();
            SourceRecordUpdate[FieldName] = LookupName; 
            
            // this set of values wrapped in a object to use to pass to controller and replace the name with Id for ex: replace ownerId Name(siva Pragada)
            // with Id 005400000wBAAY
            var ReferenceFieldName = FieldVal;            
            
            var ReferenceFieldId = LookupId;
            
            ReferenceFieldNameAndId[FieldName] = ReferenceFieldId;
        }
        else if(!AutoNumberFieldFound && !DATEfieldFound)
        {          
            SourceRecordUpdate[FieldName] = FieldVal;
        }
        else if(DATEfieldFound)
        {
            // 10/15/2015 - current format of FieldVal
            
            var SplitDate = FieldVal.split('/');
            var newDate = new Date(); newDate.setFullYear(SplitDate[2], SplitDate[0], SplitDate[1]);
            
            // necessary for parsing the date to send to Salesforce
            var Months = ["January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"];
            var MonthString = Months[newDate.getMonth()];
            
            var ParsedDateFieldValue = null;
            if(SplitDate.length > 1) { ParsedDateFieldValue = Date.parse(MonthString + " " + SplitDate[1] + "," + " " + SplitDate[2]); }
            
            // set the field on the source record
            SourceRecordUpdate[FieldName] = ParsedDateFieldValue; 
            
            //console.log(ParsedDateFieldValue);
        }
        else
        {
            FieldVal = null; //had to set this to null or undefined else it's retaining the previous value in the loop
        }       
    }
    //console.log(SourceRecordUpdate);
    return SourceRecordUpdate;
}

function AllowOverride()
{
    AllowOverridePreferredValues = true;
}
function OverrideButtonClick()
{
    SetToFalse(); 
    DisableButton(); 
    AllowOverride();
}

// -- Utility Functions

function BypassEnterKey(e){
    e = e || event;
    var txtArea = /textarea/i.test((e.target || e.srcElement).tagName);
    return txtArea || (e.keyCode || e.which || e.charCode || 0) !== 13;
}

function ConvertSpecialCharacters(text)
{
    var t = document.createElement("div");
    t.innerHTML = text;
    var result = t.childNodes[0].nodeValue;
    t.removeChild(t.firstChild)
    return result;
}

function log(e) { if(console.log) { console.log(e); } };