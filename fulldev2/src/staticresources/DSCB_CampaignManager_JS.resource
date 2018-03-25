// DataTables jQuery Plugin (by Allan Jardine) License: http://datatables.net/license_bsd

// use jQuery in noConflict mode because Salesforce uses another JavaScript library
var j$ = jQuery.noConflict();

// -- variables -- 
var ProfileIsInsideSales = false;
var CurrentUserInfo = null;
var SelectedCampaignSFID = null;
var SelectedCampaignAccountMembers = [];
var SelectedContacts = [];
var VFRemotingTimeout = 120000;
var Intervals = [];
var Timeouts = [];
var cid = null;
var campaignName = null;

var contactresult;

// -- initialize -- 
j$(document).ready(function(){init();});

// -- functions -- 
function getUrlParameters(parameter, staticURL, decode){
    var currLocation = (staticURL.length)? staticURL : window.location.search,
        parArr = currLocation.split("?")[1].split("&"),
        returnBool = true;
    
    for(var i = 0; i < parArr.length; i++){
        parr = parArr[i].split("=");
        if(parr[0] == parameter){
            return (decode) ? decodeURIComponent(parr[1]) : parr[1];
            returnBool = true;
        }
        else{
            returnBool = false;            
        }
    }
    
    if(!returnBool) return false;  
}
function init()
{
    Visualforce.remoting.timeout = VFRemotingTimeout;
    
    var BackgroundURL = "url("+__InputBoxLoadingIcon+")"; 
    
    // get permissions
    try
    {    
        var cid = getUrlParameters("id", "", true);
        
        if(cid) {
            DSCB_CampaignManagerController.GetCampaignName(cid, function(result, event){
                campaignName = result;
                j$("#SelectCampaign").val(campaignName);
                SelectedCampaignSFID = cid;
                GetAllAccountMemberStatuses(cid);    
                GetAllRegions(cid);    //20th Nov, 2014: Added by Anirudh
                GetAllKeyDOS(cid);     //21st Nov, 2014: Added by Anirudh
                GetAllKeyREP(cid);     //16th Dec, 2014: Added by Vishal Bandari
                GetAllTSM(cid);        //16th Dec, 2014: Added by Vishal Bandari
                FindCampaignAccountMembers(cid);  
            });
        }
        
        DSCB_CampaignManagerController.isInsideSales(function(result,event){
            if(result) { ProfileIsInsideSales = result; } 
        });
        
        DSCB_CampaignManagerController.GetCurrentUserInfo(function(result, event){
            if (result) { CurrentUserInfo = result; }
        });
    }
    catch(error) { DisplayUnexpectedError(); }
    
    // initialize the Select Campaign autocomplete
    var campaignList = j$("#SelectCampaign").autocomplete({
        source: function (request, response) {
            var search = (request.term && request.term.length > 1 ? request.term : "");
            try
            {
                DSCB_CampaignManagerController.SearchCampaigns(search, function(result, event){
                    
                    var AllCampaigns = j$.map(result, function(item){
                        return ({
                            label: ConvertSpecialCharacters(item.Name),
                            salesforceid: item.Id
                        });
                    });
                    
                    if (event.type == "exception") 
                    {
                        alert(event.message);
                    }
                    else 
                    {
                        if (AllCampaigns.length > 0) {
                            response(AllCampaigns);
                        }
                        else {
                            j$("#SelectCampaign").css("background","#fff");
                        }
                    }
                });
            }
            catch(error) { DisplayUnexpectedError(); }
        },
        minLength: 0,
        select: function (event, ui) {           
            SelectedCampaignSFID = ui.item.salesforceid;
            GetAllAccountMemberStatuses(ui.item.salesforceid);
            GetAllRegions(ui.item.salesforceid);    //20th Nov, 2014: Added by Anirudh
            GetAllKeyDOS(ui.item.salesforceid);    //21st Nov, 2014: Added by Anirudh
            GetAllKeyREP(ui.item.salesforceid);    //16th Dec, 2014: Added by Vishal Bandari
            GetAllTSM(ui.item.salesforceid);       //16th Dec, 2014: Added by Vishal Bandari
            FindCampaignAccountMembers(ui.item.salesforceid);                 
        },
        search: function () { 
            j$(this).css("background",BackgroundURL+" no-repeat right center #fff"); 
        },
        open: function () { j$(this).css("background","#fff"); }
    });
    
    // initialize the processing dialog
    j$("#messagebox").dialog({
        autoOpen: false,
        show: "fade",
        hide: "fade",
        title: "Please Wait...",
        resizable: false,
        minWidth: "150px",
        minHeight: "60px",
        open: function(event, ui) { j$("#overlay").css("display",""); },
        close: function(event, ui) { j$("#overlay").css("display","none"); }
    });
    
    // set the drop down arrow button
    j$("#ToggleSelectCampaign")
    .button({
        icons: {
            primary: "ui-icon-triangle-1-s"
        },
        text: false
    })
    .css( "display","" )
    .removeClass( "ui-corner-all" )
    .addClass( "ui-button-icon" )
    .click(function() { ToggleSelectCampaign(); });
    
    // Internet Explorer has trouble with padding, but Mozilla needs to be the exception..
    // test for Internet Explorer
    if(/trident/ig.test(navigator.userAgent)) { j$("#ToggleSelectCampaign").css("padding","12px 0px"); } 
    
    j$("#SelectCampaign").focus().select(); // focus on and select all text within the Select Campaign input on init
    j$("#SelectCampaign").on("click",function(){ j$(this).select(); }); // whenever Select Campaign is clicked, select all of its text
    j$("#SelectCampaign").on("dblclick",function(){ ToggleSelectCampaign(); }); // on double click, show all select options
    
    j$("#SelectAllAccountMemberStatuses").on("click",function(){ 
        if(j$("#SelectAllAccountMemberStatuses:checked").length > 0){ 
            j$("#AccountMemberStatus option").prop("selected", true); j$("#AccountMemberStatus").change(); }
    });
    
    j$("[id$=FindCampaignAccountMembers]").on("click",function(){
        FindCampaignAccountMembers(SelectedCampaignSFID);
    });
    
    j$("[id$=ClearCampaignAccountMemberFilters]").on("click",function(){
        ClearFilters();
    });
    
    j$("#AccountMemberStatus").on(
        "change mouseleave blur", function() {
            ToggleSelectAllAccountMemberStatuses();
        }
    );
    
    j$("#FindContacts").on("click",function(){
        FindContacts();
    });
    
    j$("[id$=NewContactPhone]").on("blur",function(){
        j$(this).val(formatPhoneNumber(j$(this).val()));
    });
    
    j$("#EmailContacts").on("click",function(){
        EmailSelectedContacts();
    });
    
    j$("#FindActivities").on("click",function(){
        FindActivities('open');
        FindActivities('all');
    });
    
    j$("#FindActivityHistory").on("click",function(){
        FindActivities('all');
    });
    
    j$("#NewContactRoleSelect").on("click",function(){
        j$(j$("#SelectableContactRoles").val()).each(function(index,value){
            j$("#SelectableContactRoles option[value='"+value+"']").removeAttr("selected").detach().appendTo("#NewContactRoles");
        });
    });
    
    j$("#NewContactRoleUnselect").on("click",function(){
        j$(j$("#NewContactRoles").val()).each(function(index,value){
            j$("#NewContactRoles option[value='"+value+"']").removeAttr("selected").detach().appendTo("#SelectableContactRoles");
        });
        
        // sort the selectable values
        var OptionsToSort = j$("#SelectableContactRoles option");
        
        OptionsToSort.sort(function(a,b) {
            if (a.text > b.text) { return 1; }
            else if (a.text < b.text) { return -1; }
                else { return 0; }
        });
        
        j$("#SelectableContactRoles option").remove();
        j$("#SelectableContactRoles").append( OptionsToSort );
    });
}

function ToggleSelectCampaign()
{
    scrollToTop();
    
    // close if already visible
    if ( j$("#SelectCampaign").autocomplete( "widget" ).is( ":visible" ) ) {
        j$("#SelectCampaign").autocomplete( "close" );
        return;
    }
    
    // work around a bug
    j$("#SelectCampaign").blur(); // j$(this).blur() - makes IE minimize itself.. LOL!
    
    // pass empty string as value to search for, displaying all results
    j$("#SelectCampaign").autocomplete("search","");
    j$("#SelectCampaign").focus(); 
}

function GetAllAccountMemberStatuses(SalesforceId)
{
    // clear all previous selectable values
    var AccountStatuses = new Array();
    var AccountUpdateStatuses = new Array();
    var AccountStatusesSelect = j$("#AccountMemberStatus");
    var AccountMemberStatusOptions = j$("option",AccountStatusesSelect); // get all current options
    
    var AllAccountMemberStatusSelect = j$("#SelectAccountMemberStatus");
    var AllAccountMemberStatusSelectOptions = j$("option",AllAccountMemberStatusSelect); // get all current options
    
    AccountStatusesSelect.html("");
    AccountStatusesSelect.children().remove();
    AllAccountMemberStatusSelect.html("");
    AllAccountMemberStatusSelect.children().remove();
    
    // run the GetAllAccountMemberStatuses on the server to retrieve all available 
    try
    {
        DSCB_CampaignManagerController.GetAllAccountMemberStatuses(
            SalesforceId, function(result, event) 
            {
                if(event.type === "exception") { 
                    stopTimers();
                    
                    MessageBox(
                        true, 
                        "An error occurred while loading Campaign Account Member Statuses. "
                        + "Please refresh the page and try again. <br/><br/>" + event.message,
                        "Error Loading Campaign", 
                        {"Refresh Page": function(){window.location=window.location;}}
                    );
                }
                
                if(result) 
                {
                    j$(result).each(function(index, item) { //console.log(item);
                        var it = decodeEntities(item);
                        AccountStatuses.push(j$("<option></option>").val(it).text(it));
                        AccountUpdateStatuses.push(j$("<option></option>").val(it).text(it));
                    });
                }
                
                // sort Account Statuses
                AccountStatuses.sort(function(a, b){
                    var LowerA = a.val().toLowerCase(), LowerB = b.val().toLowerCase();
                    return (LowerA < LowerB) ? -1 : (LowerA > LowerB) ? 1 : 0;
                });
                
                j$(AccountStatuses).each(function(index, item){
                    item.attr("selected","selected").appendTo(AccountStatusesSelect);
                });
                
                j$(AccountUpdateStatuses).each(function(index, item){
                    if(item.val() == "Not Contacted Yet") { item.attr("selected","selected"); }
                    item.appendTo(AllAccountMemberStatusSelect);
                });
            }
        );
    }
    catch(error) { DisplayUnexpectedError(); }
}

//20th Nov, 2014: Added by Anirudh.
function GetAllRegions(SalesforceId)
{
    // clear all previous selectable values
    var AllRegions = new Array();
    var RegionsSelect = j$("#RegionsSelected");
    var RegionOptions = j$("option",RegionsSelect); // get all current options
    
    RegionsSelect.html("");
    RegionsSelect.children().remove();
    
    // run the GetAllRegions on the server to retrieve all available 
    try
    {
        DSCB_CampaignManagerController.GetAllRegions(
            SalesforceId, function(result, event) 
            {
                if(event.type === "exception") { 
                    stopTimers();
                    
                    MessageBox(
                        true, 
                        "An error occurred while loading Regions. "
                        + "Please refresh the page and try again. <br/><br/>" + event.message,
                        "Error Loading Campaign", 
                        {"Refresh Page": function(){window.location=window.location;}}
                    );
                }
                
                if(result) 
                {
                    j$(result).each(function(index, item) { //console.log(item);
                        var it = decodeEntities(item);
                        AllRegions.push(j$("<option></option>").val(it).text(it));
                    });
                }
                
                // sort Regions
                AllRegions.sort(function(a, b){
                    var LowerA = a.val().toLowerCase(), LowerB = b.val().toLowerCase();
                    return (LowerA < LowerB) ? -1 : (LowerA > LowerB) ? 1 : 0;
                });
                
                j$(AllRegions).each(function(index, item){
                    item.attr("selected","selected").appendTo(RegionsSelect);
                });
            }
        );
    }
    catch(error) { DisplayUnexpectedError(); }
}

//21st Nov, 2014: Added by Anirudh.
function GetAllKeyDOS(SalesforceId)
{
    // clear all previous selectable values
    var AllKeyDOS = new Array();
    var KeyDOSSelect = j$("#KeyDOSSelected");
    var KeyDOSOptions = j$("option",KeyDOSSelect); // get all current options
    
    KeyDOSSelect.html("");
    KeyDOSSelect.children().remove();
    
    // run the GetAllKeyDOS on the server to retrieve all available 
    try
    {
        DSCB_CampaignManagerController.GetAllKeyDOS(
            SalesforceId, function(result, event) 
            {
                if(event.type === "exception") { 
                    stopTimers();
                    
                    MessageBox(
                        true, 
                        "An error occurred while loading all Key DOS values. "
                        + "Please refresh the page and try again. <br/><br/>" + event.message,
                        "Error Loading Campaign", 
                        {"Refresh Page": function(){window.location=window.location;}}
                    );
                }
                
                if(result) 
                {
                    j$(result).each(function(index, item) { //console.log(item);
                        var it = decodeEntities(item);
                        AllKeyDOS.push(j$("<option></option>").val(it).text(it));
                    });
                }
                
                // sort Key DOS
                AllKeyDOS.sort(function(a, b){
                    var LowerA = a.val().toLowerCase(), LowerB = b.val().toLowerCase();
                    return (LowerA < LowerB) ? -1 : (LowerA > LowerB) ? 1 : 0;
                });
                
                AllKeyDOS.unshift(j$("<option></option>").val("--None--").text("--None--"));    //Adds --None-- to the first poistion of the picklist
                
                j$(AllKeyDOS).each(function(index, item){
                    item.attr("selected","selected").appendTo(KeyDOSSelect);
                });
                
                j$("#KeyDOSSelected").val(j$("#KeyDOSSelected option:first").val());    //Focuses on the first element of the picklist
            }
        );
    }
    catch(error) { DisplayUnexpectedError(); }
}

//16th Dec, 2014: Added by Vishal Bandari.
function GetAllTSM(SalesforceId)
{
    // clear all previous selectable values
    var AllTSM = new Array();
    var TSMSelect = j$("#TSMSelected");
    var TSMOptions = j$("option",TSMSelect); // get all current options
    
    TSMSelect.html("");
    TSMSelect.children().remove();
    
    // run the GetAllTSM on the server to retrieve all available 
    try
    {
        DSCB_CampaignManagerController.GetAllTSM(
            SalesforceId, function(result, event) 
            {
                if(event.type === "exception") { 
                    stopTimers();
                    
                    MessageBox(
                        true, 
                        "An error occurred while loading all Key DOS values. "
                        + "Please refresh the page and try again. <br/><br/>" + event.message,
                        "Error Loading Campaign", 
                        {"Refresh Page": function(){window.location=window.location;}}
                    );
                }
                
                if(result) 
                {
                    j$(result).each(function(index, item) { 
                        var it = decodeEntities(item);
                        AllTSM.push(j$("<option></option>").val(it).text(it));
                    });
                }
                
                // sort TSM
                AllTSM.sort(function(a, b){
                    var LowerA = a.val().toLowerCase(), LowerB = b.val().toLowerCase();
                    return (LowerA < LowerB) ? -1 : (LowerA > LowerB) ? 1 : 0;
                });
                
                AllTSM.unshift(j$("<option></option>").val("--None--").text("--None--"));    //Adds --None-- to the first poistion of the picklist
                
                j$(AllTSM).each(function(index, item){
                    item.attr("selected","selected").appendTo(TSMSelect);
                });
                
                j$("#TSMSelected").val(j$("#TSMSelected option:first").val());    //Focuses on the first element of the picklist
            }
        );
    }
    catch(error) { DisplayUnexpectedError(); }
}

//16th Dec, 2014: Added by Vishal Bandari.
function GetAllKeyREP(SalesforceId)
{
    // clear all previous selectable values
    var AllKeyREP = new Array();
    var KeyREPSelect = j$("#KeyREPSelected");
    var KeyREPOptions = j$("option",KeyREPSelect); // get all current options
    
    KeyREPSelect.html("");
    KeyREPSelect.children().remove();
    
    // run the GetAllKeyREP on the server to retrieve all available 
    try
    {
        DSCB_CampaignManagerController.GetAllKeyREP(
            SalesforceId, function(result, event) 
            {
                if(event.type === "exception") { 
                    stopTimers();
                    
                    MessageBox(
                        true, 
                        "An error occurred while loading all Key DOS values. "
                        + "Please refresh the page and try again. <br/><br/>" + event.message,
                        "Error Loading Campaign", 
                        {"Refresh Page": function(){window.location=window.location;}}
                    );
                }
                
                if(result) 
                {
                    j$(result).each(function(index, item) { 
                        var it = decodeEntities(item);
                        AllKeyREP.push(j$("<option></option>").val(it).text(it));
                    });
                }
                
                // sort Key DOS
                AllKeyREP.sort(function(a, b){
                    var LowerA = a.val().toLowerCase(), LowerB = b.val().toLowerCase();
                    return (LowerA < LowerB) ? -1 : (LowerA > LowerB) ? 1 : 0;
                });
                
                AllKeyREP.unshift(j$("<option></option>").val("--None--").text("--None--"));    //Adds --None-- to the first poistion of the picklist
                
                j$(AllKeyREP).each(function(index, item){
                    item.attr("selected","selected").appendTo(KeyREPSelect);
                });
                
                j$("#KeyREPSelected").val(j$("#KeyREPSelected option:first").val());    //Focuses on the first element of the picklist
            }
        );
    }
    catch(error) { DisplayUnexpectedError(); }
}


function FindCampaignAccountMembers(SalesforceId)
{
    var messagecontainer = j$("<div>");
    var processingmessage = j$("<div>").html("Loading Campaign.");
    
    var pb = j$("<div>").attr("id","progressbar").progressbar(); 
    var timeout = Math.round(VFRemotingTimeout/100);
    
    messagecontainer.append(processingmessage, pb);
    MessageBox(true, messagecontainer);
    
    var progressInterval = setInterval(function() { 
        var val = pb.progressbar("value") || 0;
        pb.progressbar("value", val + 1); 
        if(val >= 100) { stopTimers(); }
    }, timeout);
    
    Intervals.push(progressInterval);
    
    var AccountState = j$("#AccountState").val();
    var KeyDOSSelected= j$("#KeyDOSSelected").val();    //21st Nov, 2014: Added by Anirudh
    var KeyREPSelected= j$("#KeyREPSelected").val(); 
    var TSMSelected= j$("#TSMSelected").val(); 
    var AccountStartsWith = j$("#AccountStartsWith").val();
    var AccountMemberStatus = j$("#AccountMemberStatus").val();
    var RegionsSelected= j$("#RegionsSelected").val();    //20th Nov, 2014: Added by Anirudh
    
    ClearCampaignAccountMembersTable();
    ClearContactsTable();
    ClearActivitiesTable();
    
    // run the SelectCampaign method on the server
    try
    {
        DSCB_CampaignManagerController.FindCampaignAccountMembers(
            SalesforceId, 
            AccountState, KeyDOSSelected,KeyREPSelected, TSMSelected, AccountStartsWith, AccountMemberStatus, RegionsSelected, function(result, event) 
            {
                if(event.type === "exception") { 
                    stopTimers();
                    
                    var errormessage = "An error occurred while loading Campaign Account Members. "
                    + "Please refresh the page and try again. <br/><br/>" + event.message;
                    
                    MessageBox(
                        true, 
                        errormessage,
                        "Error Loading Campaign", 
                        {"Refresh Page": function(){window.location=window.location;}}
                    );
                }
                
                if (result) {
                    
                    j$("[id$=FindCampaignAccountMembers]").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
                    j$("#UpdateSelectedCampaignAccountMembersContainer").css("display", "");
                    j$("#CampaignAccountMembersContainer").css("display", "");
                    
                    var rows = [];
                    
                    //MessageBox(true,result.length+" Campaign Account Members found. Loading; please wait.");
                    
                    // put together all rows 
                    j$(result).each(function(index, item) {
                        
                        // set any blank values to an empty string
                        if(!item.AccountName) { item.AccountName=""; }
                        if(!item.GroupName) { item.GroupName=""; } 
                        if(!item.CampaignAccountMemberStatus) { item.CampaignAccountMemberStatus=""; }
                        if(!item.SiteType) { item.SiteType=""; }
                        if(!item.City) { item.City=""; }
                        if(!item.State) { item.State=""; }
                        if(!item.Region) { item.Region=""; }    //12th Nov, 2014: Added by Anirudh.
                        if(!item.KeyDOS) { item.KeyDOS=""; }    //12th Nov, 2014: Added by Anirudh.
                        if(!item.KeyRep) { item.KeyRep=""; }
                        if(!item.DesignatedDSM) { item.DesignatedDSM=""; }
                        if(!item.VendorSystem) { item.VendorSystem=""; }
                        if(!item.BoxOnsite) { item.BoxOnsite=""; }
                        if(!item.Age) { item.Age=""; }
                        if(!item.SoldDMSVendorSystem) { item.SoldDMSVendorSystem=""; }
                        if(!item.SoldDMSInstallDate) { item.SoldDMSInstallDate=""; }
                        if(!item.DoNotSolicit) { item.DoNotSolicit=""; }
                        
                        rows.push([
                            "<input type='checkbox' id='"+item.CampaignAccountMemberId+"_checkbox' title='"+item.AccountName.replace("'","")+"' />", // checkbox
                            "<a href='/"+item.CampaignAccountId+"' target='_blank'>"+item.AccountName+"</a>", // Account Name
                            item.GroupName, // Group Name    
                            item.CampaignAccountMemberStatus, // Status
                            item.SiteType, // Site Type
                            item.City, // Account City
                            item.State, // Account State
                            item.Region,    //12th Nov, 2014: Added by Anirudh.
                            "<a href='/"+item.KeyDOS_Id+"' target='_blank'>"+item.KeyDOS+"</a>",   //12th Nov, 2014: Added by Anirudh.
                            "<a href='/"+item.KeyREP_Id+"' target='_blank'>"+item.KeyRep+"</a>",   // Account Key Rep    //20th Nov, 2014: Added by Anirudh.
                            "<a href='/"+item.DSM_Id+"' target='_blank'>"+item.DesignatedDSM+"</a>",   // Account Key Rep    //20th Nov, 2014: Added by Anirudh.
                            item.VendorSystem, // Vendor System
                            (item.BoxOnsite ? "<span class='ui-icon ui-icon-check' style='margin:auto;'>True</span>" : ""), // check or blank
                            item.Age, // Age
                            item.SoldDMSVendorSystem, // DMS Vendor System
                            DateToString(item.SoldDMSInstallDate), // Install Date
                            (item.DoNotSolicit ? "<span class='ui-icon ui-icon-check' style='margin:auto;'>True</span>" : "") // check or blank
                        ]);
                    });
                    
                    var CampaignAccountMembersTable = null;
                    var CurrentCampaignAccountMembersTable = j$("#CampaignAccountMembersTable.init"); 
                    
                    if(CurrentCampaignAccountMembersTable.length > 0)
                    {
                        var dt = CurrentCampaignAccountMembersTable.dataTable();
                        dt.fnClearTable();
                        dt.fnAddData(rows);
                        
                        CampaignAccountMembersTable = j$("#CampaignAccountMembersTable").dataTable();
                    }
                    else
                    {
                        CampaignAccountMembersTable = j$("#CampaignAccountMembersTable").addClass("init").dataTable({
                            "aaData":rows,
                            "bDestroy": true, // allow this datatable to be destroyed
                            "bJQueryUI": true, // use the jQuery UI theme
                            "sPaginationType": "full_numbers", // show full numbers for paging
                            "iDisplayLength": 10,
                            "aaSorting": [[1,'asc']],
                            "sDom": "<'H'lr<'#CAMTableHeaderMessage'>f>t<'F'ip>", // set the positioning of the table elements
                            "fnPreDrawCallback": function() {
                                //MessageBox(true, "Loading.");
                            },
                            "fnDrawCallback": function() {
                                
                                j$("tbody tr [id$=checkbox]",CampaignAccountMembersTable).off("click");
                                j$("tbody tr [id$=checkbox]",CampaignAccountMembersTable).on("click",function(){
                                    
                                    var aData = CampaignAccountMembersTable.fnGetData(this.parentNode.parentNode);
                                    
                                    var SelectedCAMId = j$(aData[0]).attr("id"); 
                                    
                                    var SalesforceIdNumber = String(SelectedCAMId).split("_")[0];
                                    var SalesforceAccountName = j$(aData[1]).html();
                                    
                                    if(this.checked) {
                                        SelectCampaignAccountMember(SelectedCAMId, SalesforceIdNumber, SalesforceAccountName); }
                                    else {
                                        UnSelectCampaignAccountMember(SalesforceIdNumber); }
                                    
                                    //Added by Vishal Bandari on 14/1/2015 : changes the status of CheckAll based on checkbox.
                                    j$("#CheckAll", CampaignAccountMembersTable).prop("checked",true);
                                    j$("[id$=checkbox]", CampaignAccountMembersTable.fnGetFilteredNodes()).each(function(){
                                        if(!j$(this).prop("checked"))
                                        {
                                            j$("#CheckAll", CampaignAccountMembersTable).prop("checked",false);
                                        }
                                    });
                                });
                                
                                stopTimers();
                                try { pb.progressbar("value", 100); } 
                                catch(progressBarError) { /* if(console) { console.log(progressBarError); } */ }
                                
                                setTimeout( function() { MessageBox(false); }, 500 );
                            },
                            "aoColumns":[ 
                                { "sTitle": "<input type='checkbox' id='CheckAll' title='Select All' ></input>", "bSortable": false } // checkbox
                                ,{ "sTitle": "Account Name", "sType": "html", "sWidth": "22%" } // Account Name
                                ,{ "sTitle": "Group", "sType": "html", "sWidth": "5%" } // Group Name
                                ,{ "sTitle": "Account Member Status", "sType": "string", "sWidth": "10%" } // Campaign Account Member Status
                                ,{ "sTitle": "Site Type", "sType": "string", "sWidth": "5%" } // Account Site Type
                                ,{ "sTitle": "City", "sType": "string", "sWidth": "10%" } // Account City
                                ,{ "sTitle": "State", "sType": "string", "sWidth": "2%" } // Account State
                                ,{ "sTitle": "Region", "sType": "string", "sWidth": "5%" } // Region      //12th Nov, 2014: Added by Anirudh.
                                ,{ "sTitle": "Key DOS", "sType": "html", "sWidth": "5%" } // Key DOS    //12th Nov, 2014: Added by Anirudh.
                                ,{ "sTitle": "Key Rep", "sType": "string", "sWidth": "2%" } // Account Key Rep
                                ,{ "sTitle": "DSM", "sType": "string", "sWidth": "2%" } // Account Key Rep
                                ,{ "sTitle": "Vendor System", "sType": "string", "sWidth": "18%" } // Vendor System
                                ,{ "sTitle": "Box Onsite", "sType": "html", "sWidth": "2%" } // Box Onsite
                                ,{ "sTitle": "Age", "sType": "numeric", "sWidth": "2%" } // Age
                                ,{ "sTitle": "Sold DMS Vendor System", "sType": "string", "sWidth": "10%" } // SoldDMSVendorSystem
                                ,{ "sTitle": "Sold DMS Install Date", "sType": "date", "sWidth": "10%" } // SoldDMSInstallDate
                                ,{ "sTitle": "Do Not Solicit", "sType": "html", "sWidth": "5%" } // DoNotSolicit
                            ]
                        });
                    }
                    
                    j$("#CAMTableHeaderMessage").css("float","left").html("2000 Campaign Account Members displayed at a time");
                    
                    // force the search to only be performed if the enter button is pressed
                    j$(".dataTables_filter input","#CampaignAccountMembersContainer")
                    .off("keypress keyup")
                    .on("keypress keyup",function(e){ 
                        if (e.keyCode != 13) { return; }
                        else { e.preventDefault(); CampaignAccountMembersTable.fnFilter(j$(this).val()); return false; }
                    });
                    
                    // set the check all table header checkbox
                    j$("#CheckAll", CampaignAccountMembersTable).off("click");
                    j$("#CheckAll", CampaignAccountMembersTable).on("click",function(){
                        
                        var CheckAll = j$("#CheckAll").prop("checked");
                        var AllCheckboxes = j$("[id$=checkbox]", CampaignAccountMembersTable.fnGetFilteredNodes());
                        
                        if(CheckAll == true) 
                        {
                            AllCheckboxes.prop("checked", j$("#CheckAll").prop("checked"));
                            
                            // remove all previous selections
                            j$("#SelectedCampaignAccountMembers").children().each(function(){j$(this).remove();});
                            SelectedCampaignAccountMembers = [];
                            
                            // select all filtered results
                            AllCheckboxes.each(function(){ 
                                var current = j$(this); 
                                var currentid = current.attr("id"); 
                                var currentsfid = String(currentid).split("_")[0];
                                var currenttitle = current.attr("title");
                                SelectCampaignAccountMember(currentid,currentsfid,currenttitle);
                            }); 
                            
                            j$("#FindActivities").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
                            j$("#FindActivityHistory").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
                            j$("#FindContacts").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
                            
                            if(j$("#EmailTemplates option").length > 0) { 
                                j$("#EmailContacts").removeAttr("disabled").removeClass("btnDisabled").addClass("btn"); }
                        }
                        else 
                        { 
                            AllCheckboxes.prop("checked",false); 
                            j$("#SelectedCampaignAccountMembers").children().each(function(){j$(this).remove();}); 
                            SelectedCampaignAccountMembers = []; 
                            j$("#SelectedCampaignAccountMembersLabel").css("display","");
                            
                            if(SelectedCampaignAccountMembers.length < 1)
                            {
                                j$("#FindActivities").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                                j$("#FindActivityHistory").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                                j$("#FindContacts").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                                j$("#EmailContacts").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                            }
                            
                            ClearActivitiesTable(); // clear both Open Activities and Activity History tables
                            ClearContactsTable(); // clear the contacts table
                        }
                    });
                    
                    var TableData = CampaignAccountMembersTable.fnGetData();
                    
                    j$("#UpdateCampaignAccountMemberStatus").off("click");
                    j$("#UpdateCampaignAccountMemberStatus").on("click",function(){UpdateCampaignAccountMemberStatus();});
                    
                    ToggleContactsContainer(true);
                    ToggleActivitiesContainer(true);
                    
                } // end result if
            }); // end remote action call
    } // end try
    catch(error) { DisplayUnexpectedError(); }
    
    j$("#ContactCheckAll").prop("checked",false);
    j$("#SendEmailToContactsContainer").css("display","none");
    j$("#ContactsTableContainer").css("display","none");
}

function ToggleSelectAllAccountMemberStatuses()
{
    if (j$("#AccountMemberStatus option").length != j$("#AccountMemberStatus").val().length) {
        j$("#SelectAllAccountMemberStatuses").removeAttr("checked");
    }
    else {
        j$("#SelectAllAccountMemberStatuses").attr("checked", "checked");
    }
}

function SelectCampaignAccountMember(objectid, sfid, name)
{
    j$("#SelectedCampaignAccountMembersLabel").css("display","none");
    
    ClearActivitiesTable(); // clear both Open Activities and Activity History tables
    ClearContactsTable(); // clear the contacts table
    
    var SelectedCampaignAccountMember = j$("<span></span>");
    SelectedCampaignAccountMember.attr("id",sfid+"_selected");
    SelectedCampaignAccountMember.html(name);
    SelectedCampaignAccountMember.css("margin","2px");
    
    SelectedCampaignAccountMember.button({
        icons:{secondary:"ui-icon-close"}
    });
    
    j$("#SelectedCampaignAccountMembers").append(SelectedCampaignAccountMember);
    
    SelectedCampaignAccountMember.on("click",function(){
        var sfid_click = String(j$(this).attr("id")).split("_")[0];
        UnSelectCampaignAccountMember(sfid_click);
    });
    
    var SelectedCampaignAccountMemberData = {
        objectid: objectid,
        sfid: sfid,
        name: escape(name)
    };
    
    SelectedCampaignAccountMembers.push(SelectedCampaignAccountMemberData);
    
    j$("#FindActivities").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
    j$("#FindActivityHistory").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
    j$("#FindContacts").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
    
    if(j$("#EmailTemplates option").length > 0) { 
        j$("#EmailContacts").removeAttr("disabled").removeClass("btnDisabled").addClass("btn"); }
}

function UnSelectCampaignAccountMember(sfid)
{
    // remove from selected array
    if (sfid) {
        SelectedCampaignAccountMembers = j$.grep(SelectedCampaignAccountMembers, function(value){
            if (value.sfid) {
                return value.sfid != sfid;
            }
        });
        
        if(SelectedCampaignAccountMembers.length < 1) { j$("#SelectedCampaignAccountMembersLabel").css("display",""); }
        
        ClearActivitiesTable(); // clear both Open Activities and Activity History tables
        ClearContactsTable(); // clear the contacts table
    }
    
    // retrieve the datatable
    var CampaignAccountMembersTable = j$("#CampaignAccountMembersTable").dataTable({"bRetrieve": true});
    
    var tData = CampaignAccountMembersTable.fnGetNodes(); // get all table rows
    j$("[id^="+sfid+"]", tData).prop("checked",false).removeAttr("checked"); // remove check from table
    
    j$("#"+sfid+"_selected").remove(); // remove from selected list
    
    if(SelectedCampaignAccountMembers.length < 1)
    {
        j$("#FindActivities").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
        j$("#FindActivityHistory").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
        j$("#FindContacts").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
        j$("#EmailContacts").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
    }
}

function UpdateCampaignAccountMemberStatus()
{
    if(j$("#SelectedCampaignAccountMembers").children().length > 0 && SelectedCampaignAccountMembers.length > 0)
    {
        var IdsToUpdate = new Array();
        j$(SelectedCampaignAccountMembers).each(function(index,item){IdsToUpdate.push(item.sfid);});
        
        try
        {
            DSCB_CampaignManagerController.UpdateAccountMemberStatus(IdsToUpdate, j$("#SelectAccountMemberStatus").val(), function(result, event) {
                //console.log('update account member status: '+event);
                if(result && result.Success)
                {
                    FindCampaignAccountMembers(SelectedCampaignSFID);
                    j$("#SelectedCampaignAccountMembers").children().each(function(){j$(this).remove();});
                    SelectedCampaignAccountMembers = [];
                    j$("#FindActivities").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                    j$("#FindActivityHistory").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                    j$("#FindContacts").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                    j$("#EmailContacts").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
                }
                else if(result && !result.Success)
                {
                    MessageBox(true,result.Message,"Error");
                }
            });
        }
        catch(error) { DisplayUnexpectedError(); }
    }
    else
    {
        MessageBox(true,"Please select a Campaign Account Member to update the Status.","Please Select...",{"Ok":function(){j$(this).dialog("close");}});
    }
}

function FindContacts()
{
    MessageBox(true,"Finding Contacts.");
    
    if(j$("#SelectedCampaignAccountMembers").children().length > 0 && SelectedCampaignAccountMembers.length > 0)
    {
        // put together a list of Selected Campaign Account Members Ids
        var CampaignAccountMemberIds = new Array();
        j$(SelectedCampaignAccountMembers).each(function(index,item){CampaignAccountMemberIds.push(item.sfid);});
        
        // put together a list of Selected Contact Roles
        var ContactRoles = new Array();
        if (j$("#ContactRoles").val()) {
            j$("#ContactRoles option:selected").each(function(index,item){
                if (j$(item).val() != '--None--' && j$(item).val() != '--All--') {
                    ContactRoles.push(j$(item).val());
                }
            });
        }
        
        // delete the table and re-initialize it
        ClearContactsTable();
        
        try
        {
            DSCB_CampaignManagerController.FindContacts(CampaignAccountMemberIds, ContactRoles, function(result, event) {
                
                contactresult = result;
                
                if(event.status && result)
                {
                    j$("#SendEmailToContactsContainer").css("display","");
                    
                    if(j$("#EmailTemplates option").length < 1) { 
                        j$("#EmailContacts").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled"); }
                    
                    j$("#ContactsTableContainer").css("display","");
                    
                    var rows = [];
                    var SelectedCampaignName = j$("#SelectCampaign").val();
                    
                    // put together all rows 
                    j$(result).each(function(index, item) {
                        
                        //Select Id, Name, Email, Phone, Role__c, Account.Name, AccountId 
                        // set any blank values to an empty string
                        if(!item.Id) { item.Id=""; } 
                        if(!item.Name) { item.Name=""; }
                        if(!item.Email) { item.Email=""; }
                        if(!item.Phone) { item.Phone=""; } else { item.Phone = formatPhoneNumber(item.Phone); }
                        if(!item.Role__c) { item.Role__c=""; }
                        if(!item.Account.Name) { item.Account.Name=""; }
                        if(!item.Account.Dealer_Group_Name2__c){ item.Account.Dealer_Group_Name2__c=""; }
                        if(!item.AccountId) { item.AccountId=""; }
                        if(!item.Do_Not_Solicit__c) { item.Do_Not_Solicit__c=false; }
                        
                        var ADPOpportunityOwnerQS = null; // ADP Opportunity Owner QueryString
                        
                        if(CurrentUserInfo && CurrentUserInfo.Id && CurrentUserInfo.FirstName && CurrentUserInfo.LastName)
                        {
                            ADPOpportunityOwnerQS = "";
                            ADPOpportunityOwnerQS += "&CF00N40000001mu1G" + "_lkid=" + encodeURIComponent(CurrentUserInfo.Id); // ADP Opportunity Owner ID
                            ADPOpportunityOwnerQS += "&CF00N40000001mu1G=" + CurrentUserInfo.FirstName + " " + CurrentUserInfo.LastName; // ADP Opportunity Owner Name 
                        }
                        
                        rows.push(["<input type='checkbox' id='"+item.Id+"_ContactCheckbox' title='"+item.Name.replace("'","")+"' />",
                                   "<a href='/"+item.Id+"' target='_blank'>"+item.Name+"</a>",
                                   "<a href='/"+item.AccountId+"' target='_blank'>"+item.Account.Name+"</a>",
                                   item.Email,
                                   ((ProfileIsInsideSales && this.innerHTML != null && this.innerHTML != "")? 
                                    "<div style='float:left;' >"+item.Phone+"</div>" :
                                    "<a style='float:left;' href='' onclick=\"dial(event, this.innerHTML, '"+item.Id+"', '"+SelectedCampaignSFID+"'); return false;\">"+item.Phone+"</a>"),
                                   item.Role__c,
                                   (item.Do_Not_Solicit__c ? "<span class='ui-icon ui-icon-check' style='margin:auto;'>True</span>" : ""), // check or blank
                                   (ProfileIsInsideSales ? "" :
                                    "<a href='/006/e?opp4=" + encodeURIComponent(item.Account.Name) + "&opp4_lkid=" + item.AccountId + ADPOpportunityOwnerQS 
                                    + "&opp17=" + encodeURIComponent(SelectedCampaignName) + "&opp17_lkid=" + SelectedCampaignSFID
                                    + "&opp3=" + encodeURIComponent(SelectedCampaignName) 
                                    + "&retURL=" + "/apex/CloseMe' "
                                    + " target='_blank' id='"+item.Id+"_CreateOpportunity'>Create Opportunity<br/></a>") + 
                                   "<a href='/apex/activityOpportunity?accountId="+item.AccountId+"&contactId="+item.Id+"&campaignId="+SelectedCampaignSFID+"&retURL=/apex/CloseMe' "
                                   + " target='_blank' id='"+item.Id+"_ContactLogActivity'>Log Activity/Opportunity</a>"]);
                    });
                    
                    var ContactsTable = null;
                    var CurrentContactsTable = j$("#ContactsTable.init"); 
                    
                    if(CurrentContactsTable.length > 0)
                    {
                        var dt = CurrentContactsTable.dataTable();
                        dt.fnClearTable();
                        dt.fnAddData(rows);
                        
                        ContactsTable = j$("#ContactsTable").dataTable();
                    }
                    else
                    {
                        ContactsTable = j$("#ContactsTable").addClass("init").dataTable({
                            "aaData": rows,
                            "bDestroy": true, // allow this datatable to be destroyed
                            "bJQueryUI": true, // use the jQuery UI theme
                            "bFilter": false, // do not allow filtering
                            "iDisplayLength": 10,
                            "sPaginationType": "full_numbers", // show full numbers for paging
                            "aaSorting": [[2,'asc'], [1,'asc']], // automatically sort by the 2nd column ascending and then the 1st column ascending
                            "sDom": "<'H'lr<'#ContactsTableHeaderMessage'><'#AddNewContactButtonContainer'>>t<'F'ip>", // set the positioning of the table elements
                            "fnDrawCallback": function() { 
                                
                                j$("tbody tr [id$=ContactCheckbox]",ContactsTable).off("click");
                                j$("tbody tr [id$=ContactCheckbox]",ContactsTable).on("click",function(){
                                    
                                    var aData = ContactsTable.fnGetData(this.parentNode.parentNode);
                                    
                                    var SelectedContactId = j$(aData[0]).attr("id"); 
                                    
                                    var SalesforceIdNumber = String(SelectedContactId).split("_")[0];
                                    var SalesforceContactName = j$(aData[0]).attr("title");
                                    
                                    if(this.checked)
                                    {
                                        SelectContact(SelectedContactId, SalesforceIdNumber, SalesforceContactName, aData[3]);
                                    }
                                    else
                                    {
                                        UnSelectContact(SalesforceIdNumber);
                                    }
                                    
                                    //Added by Vishal Bandari on 14/1/2015 : changes the status of ContactCheckAll based on ContactCheckbox.
                                    j$("#ContactCheckAll", ContactsTable).prop("checked",true);
                                    j$("[id$=ContactCheckbox]", ContactsTable.fnGetFilteredNodes()).each(function(){
                                        if(!j$(this).prop("checked"))
                                        {
                                            j$("#ContactCheckAll", ContactsTable).prop("checked",false);
                                        }
                                    });
                                });
                            },
                            "aoColumns":[ 
                                { "sTitle": "<input type='checkbox' id='ContactCheckAll' title='Select All' ></input>", 
                                 "bSortable": false, "sWidth": "20px", "sType": "html" } // checkbox
                                ,{ "sTitle": "Contact Name", "sType": "html" } // Contact Name
                                ,{ "sTitle": "Account", "sType": "html" } // Account Name
                                ,{ "sTitle": "Email", "sType": "string" } // Email
                                ,{ "sTitle": "Phone", "sType": "string" } // Phone
                                ,{ "sTitle": "Role(s)", "sType": "string" } // Role
                                ,{ "sTitle": "Do Not Solicit", "sType": "html" } // Do Not Solicit
                                ,{ "sTitle": "Action(s)", "sType": "html", "sWidth":"140px" } // Action Link Buttons
                            ]
                        });
                    }
                    
                    // change links to buttons
                    //j$("[id$=CreateOpportunity]",ContactsTable.fnGetNodes()).css("font-size","0.8em").css("float","left").button({icons:{primary:"ui-icon-plus"},text:false});
                    //j$("[id$=ContactLogActivity]",ContactsTable.fnGetNodes()).css("font-size","0.8em").button({icons:{primary:"ui-icon-pencil"},text:false});
                    
                    var HeaderMessage = j$("#ContactsTableHeaderMessage").css("float","left").html("500 Contacts displayed at a time");
                    
                    var AddNewContactButtonContainer = j$("#AddNewContactButtonContainer")
                    .html("<input type='button' value='Add a New Contact'></input>")
                    .css("text-align","right");
                    
                    var AddNewContactButton = j$("input",AddNewContactButtonContainer).button();
                    
                    AddNewContactButton.off("click");
                    AddNewContactButton.on("click",function(){
                        
                        var AddNewContactDialog = j$("#NewContactSection");
                        AddNewContactDialog.css("display","");
                        AddNewContactDialog.dialog(
                            {
                                "minWidth": 760, 
                                "minHeight": 130, 
                                "title": "Add a New Contact",
                                "modal": true,
                                "buttons":[
                                    {
                                        text: "Save",
                                        click: function() { CreateNewContact(); }
                                    },
                                    {
                                        text: "Close",
                                        click: function() { j$(this).dialog("close"); }
                                    }
                                ]
                            });
                        
                    });
                    
                    var NewContactAccountSelect = j$("[id$=NewContactAccountSelect]").html("");
                    j$(SelectedCampaignAccountMembers).each(function(index, item){
                        var NewContactAccountOption = j$("<option></option>").val(item.sfid).text(unescape(item.name)).appendTo(j$("[id$=NewContactAccountSelect]"));
                    });
                    
                    j$("#ContactCheckAll", ContactsTable).off("click");
                    j$("#ContactCheckAll", ContactsTable).on("click",function(){
                        
                        var ContactsTableNodes = ContactsTable.fnGetNodes();
                        
                        var CheckAll = j$("#ContactCheckAll").prop("checked");
                        var AllCheckboxes = j$("[id$=ContactCheckbox]", ContactsTableNodes);
                        
                        if(CheckAll == true) 
                        {
                            AllCheckboxes.attr("checked", j$("#ContactCheckAll").prop("checked"));
                            
                            // remove all previous selections
                            j$("#SelectedContacts").children().each(function(){j$(this).remove();});
                            SelectedContacts = [];
                            
                            // select all filtered results
                            j$(ContactsTableNodes).each(function(index,value){ 
                                var currentid = value.children[0].children[0].id; 
                                var currentsfid = String(currentid).split("_")[0];
                                var currenttitle = value.children[0].children[0].title;
                                var currentemail = value.children[3].innerHTML;
                                SelectContact(currentid,currentsfid,currenttitle,currentemail);
                            }); 
                        }
                        else 
                        {
                            AllCheckboxes.removeAttr("checked"); 
                            SelectedContacts = []; 
                            j$("#SelectedContacts").children().each(function(){j$(this).remove();}); 
                            j$("#SelectedContactsLabel").css("display","");
                        }
                        
                        // add all selected nodes to notification area
                    });
                    
                    scrollToBottom();
                    
                    MessageBox(false,"Contacts found.");
                    
                } // end if result
                else
                {
                    j$("#ContactCheckAll").prop("checked",false);
                    
                    // delete the table and re-initialize it
                    ClearContactsTable();
                    
                    j$("#ContactsTableContainer").css("display","none");
                    j$("#NewContactSection").css("display","none");
                    j$("#SendEmailToContactsContainer").css("display","none");
                    
                    var ContactsError = "No Contacts found. ";
                    if(event.message != null) { ContactsError += "Error: " + event.message; }
                    
                    MessageBox(true,ContactsError);
                }
                
            });
        }
        catch(error) { DisplayUnexpectedError(); }
    }
    else // no Campaign Account Members selected
    {
        j$("#ContactCheckAll").prop("checked",false);
        
        // delete the table and re-initialize it
        ClearContactsTable();
        
        j$("#NewContactSection").css("display","none");
        j$("#SendEmailToContactsContainer").css("display","none");
        j$("#ContactsTableContainer").css("display","none");
        
        MessageBox(
            true,
            "Please select a Campaign Account Member before finding Contacts.",
            "Please Select...",
            {"Ok":function(){j$(this).dialog("close");}}
        );
    }
}

function SelectContact(objectid, sfid, name, email)
{
    //console.log('select contact called');
    
    j$("#SelectedContactsLabel").css("display","none");
    
    var SelectedContact = j$("<span></span>");
    SelectedContact
    .attr("id",sfid+"_selected")
    .attr("title",email)
    .html(name)
    .css("margin","2px");
    
    SelectedContact.button({
        icons:{secondary:"ui-icon-close"}
    });
    
    j$("#SelectedContacts").append(SelectedContact);
    
    SelectedContact.on("click",function(){
        var sfid_click = String(j$(this).attr("id")).split("_")[0];
        UnSelectContact(sfid_click);
    });
    
    var SelectedContactData = {
        objectid: objectid,
        sfid: sfid,
        name: name,
        email: email
    };
    
    SelectedContacts.push(SelectedContactData);
}

function UnSelectContact(sfid)
{
    if (sfid) {
        SelectedContacts = j$.grep(SelectedContacts, function(value){
            if (value.sfid) {
                return value.sfid != sfid;
            }
        });
        
        if(SelectedContacts.length < 1) { j$("#SelectedContactsLabel").css("display",""); }
    }
    
    var ContactsTable = j$("#ContactsTable").dataTable({"bRetrieve": true});
    
    var tData = ContactsTable.fnGetNodes();
    j$("[id^="+sfid+"]", tData).removeAttr("checked");
    
    j$("#"+sfid+"_selected").remove();
}

function CreateNewContact()
{
    var AddNewContactDialog = j$("#NewContactSection");
    j$(":button",AddNewContactDialog.parent()).attr("disabled","disabled").addClass("ui-state-disabled"); // disable buttons
    
    var RequiredFields = [];
    var RequiredFieldsInError = [];
    
    // select all selected roles
    j$("#NewContactRoles option").attr("selected","selected");
    
    var NewContactFirstName = j$("#NewContactFirstName"); RequiredFields.push(NewContactFirstName);
    var NewContactLastName = j$("#NewContactLastName"); RequiredFields.push(NewContactLastName);
    var NewContactAccountSelect = j$("#NewContactAccountSelect"); RequiredFields.push(NewContactAccountSelect);
    var NewContactRoles = j$("#NewContactRoles"); RequiredFields.push(NewContactRoles);
    var NewContactPhone = j$("#NewContactPhone"); RequiredFields.push(NewContactPhone);
    
    var NewContactEmail = j$("#NewContactEmail");
    
    // clear out any previous error
    j$("#NewContactErrorSummary","#NewContactSection").html("");
    j$("[id$=_error]","#NewContactSection").remove();
    
    // check required fields
    j$(RequiredFields).each(
        function(index,field)
        {
            if(!(field.val() && field.val() != "" && field.val() != "--None--")) { field.addClass("error"); RequiredFieldsInError.push(field); } 
            else { field.removeClass("error"); }
        }
    );
    
    if(RequiredFieldsInError.length > 0)
    {
        var RequiredFieldLabels = [];
        
        j$(RequiredFieldsInError).each(function(index,field){
            var RequiredFieldLabel = j$("label[for$="+j$(field).attr('id')+"]").html().trim(); RequiredFieldLabels.push(RequiredFieldLabel);
            field.after("<div id='"+field.attr("id")+"_error' class='errorMsg' >"+RequiredFieldLabel+" is Required.</div>");
        });
        
        if (RequiredFieldLabels.length > 1) {
            RequiredFieldLabels[RequiredFieldLabels.length - 1] = "and " + RequiredFieldLabels[RequiredFieldLabels.length - 1];
        }
        
        j$("#NewContactErrorSummary","#NewContactSection")
        .html(RequiredFieldLabels.join(", ")+" "+(RequiredFieldLabels.length > 1 ? "are" : "is a")+" required field(s). ")
        .css("color","#CC0000");
        
        j$(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
        
        return;
    }
    else
    {
        if(NewContactEmail && NewContactEmail.val() && NewContactEmail.val().length > 0 && !ValidEmail(NewContactEmail.val()))
        {
            var ErrorLabel = j$("label[for$="+NewContactEmail.attr('id')+"]").html().trim(); 
            NewContactEmail.after("<div id='"+NewContactEmail.attr("id")+"_error' class='errorMsg' >"+ErrorLabel+" is invalid.</div>").addClass("error");
            
            j$("#NewContactErrorSummary","#NewContactSection").html("The e-mail address entered is invalid. ").css("color","#CC0000");
            j$(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
            
            return;
        } else { NewContactEmail.removeClass("error"); }
        
        j$("#NewContactErrorSummary","#NewContactSection").css("color","");
        j$("#NewContactErrorSummary","#NewContactSection").html("Adding a new Contact; please wait. ");
        
        try
        {
            DSCB_CampaignManagerController.AddContact(
                NewContactFirstName.val(),NewContactLastName.val()
                ,NewContactAccountSelect.val()
                ,String(NewContactRoles.val()).replace(/\,/g,"; ")
                ,NewContactEmail.val()
                ,NewContactPhone.val()
                ,function(result, event){
                    if(result)
                    {
                        if(result.Success)
                        {
                            AddNewContactDialog.dialog("close"); // close the dialog
                            
                            j$(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
                            j$("#NewContactErrorSummary","#NewContactSection").html(""); // clear the message
                            
                            j$("input","#NewContactSection").val(""); // clear the inputs 
                            j$("select > option","#NewContactSection").removeAttr("selected"); // clear any selections
                            
                            // remove all selected values
                            j$("#NewContactRoles option").each(function(index,value){
                                j$(value).removeAttr("selected").detach().appendTo("#SelectableContactRoles");
                            });
                            
                            // sort the selectable values
                            var OptionsToSort = j$("#SelectableContactRoles option");
                            
                            OptionsToSort.sort(function(a,b) {
                                if (a.text > b.text) { return 1; }
                                else if (a.text < b.text) { return -1; }
                                    else { return 0; }
                            });
                            
                            j$("#SelectableContactRoles option").remove();
                            j$("#SelectableContactRoles").append( OptionsToSort );
                            
                            FindContacts(); // refresh the contacts list
                            
                            MessageBox(true,"Contact has been added.");
                            setTimeout(function(){MessageBox(false,"Contact has been added.");},1000);
                        }
                        else
                        {
                            j$("#NewContactErrorSummary","#NewContactSection").html(result.Message);
                            j$("#NewContactErrorSummary","#NewContactSection").css("color","#CC0000");
                            j$(":button",AddNewContactDialog.parent()).removeAttr("disabled").removeClass("ui-state-disabled"); // un-disable buttons
                        }
                    }
                }
            );
        }
        catch(error) { DisplayUnexpectedError(); }
    }
}

function EmailSelectedContacts()
{
    if(SelectedContacts.length == 1) 
    { 
        if (SelectedContacts[0].email && SelectedContacts[0].email.length > 1) {
            window.open("/_ui/core/email/author/EmailAuthor?p2_lkid=" + SelectedContacts[0].sfid + "&rtype=003&template_id=" + j$("#EmailTemplates").val() + "&retURL=/apex/CloseMe");
        }
        else {
            MessageBox(true
                       ,"The Contact you have selected does not have a valid e-mail address."
                       ,"Invalid E-mail Address"
                       ,{"Ok":function(){j$(this).dialog("close");}}
                      );
        } 
    }
    else if(SelectedContacts.length > 1)
    {
        var AllContactsHaveEmails = true;
        
        j$(SelectedContacts).each(function(index,item){if(!item.email || item.email.length < 2){ AllContactsHaveEmails = false; }});
        
        if(AllContactsHaveEmails)
        {
            MessageBox(
                true,"Are you sure you would like to send e-mails using the selected template ("+
                j$("#EmailTemplates option[value='"+j$("#EmailTemplates").val()+"']").text()+") to "+SelectedContacts.length+" Contacts?","Are You Sure?",
                {
                    "Ok":function()
                    {
                        var SelectedTemplateId = j$("#EmailTemplates").val();
                        
                        if(SelectedTemplateId && SelectedTemplateId.length > 1)
                        {
                            var ContactIds = new Array();
                            j$(SelectedContacts).each(function(index,item){ContactIds.push(item.sfid);});
                            
                            try
                            {
                                DSCB_CampaignManagerController.SendEmails(SelectedTemplateId, ContactIds, function(result, event){
                                    if(result && result.Success) { 
                                        MessageBox(true,SelectedContacts.length+" E-mails sent.","E-mails sent",{
                                            "Close": function(){ j$(this).dialog("close"); } 
                                        }); }
                                    else { MessageBox(true,result.Message,"Error",{"Ok":function(){j$(this).dialog("close");}}); }
                                });
                            }
                            catch(error) { DisplayUnexpectedError(); }
                        }
                        else
                        {
                            MessageBox(true
                                       ,"The E-mail Template selected is invalid."
                                       ,"Invalid Template"
                                       ,{"Ok":function(){j$(this).dialog("close");}}
                                      );
                        }
                    },
                    "Cancel":function()
                    {
                        j$(this).dialog("close");
                    }
                }
            );
        }
        else
        {
            MessageBox(
                true
                ,"One of the Contact(s) you have selected does not have a valid e-mail address. Please select only Contact(s) that have valid e-mail addresses."
                ,"Invalid E-mail Address"
                ,{"Ok":function(){j$(this).dialog("close");}}
            );
        }    
    }
        else 
        {
            MessageBox(
                true
                ,"Please select one or more Contacts to E-mail. "
                ,"E-mail Contacts"
                ,{"Ok":function(){j$(this).dialog("close");}}
            ); 
            setTimeout(function(){MessageBox(false);},10000); 
        }
}

function FindActivities(RequestType)
{
    MessageBox(true,"Finding Activities.");
    
    var ObjectTypePrefix = ""; 
    var ObjectType = "";
    
    if(RequestType && RequestType.toLowerCase() == "open") { ObjectTypePrefix = "OpenActivities"; ObjectType = "Open Activities"; }
    else if(RequestType && RequestType.toLowerCase() == "all") { ObjectTypePrefix = "ActivityHistory"; ObjectType = "Activity History"; } 
    
    try
    {
        if(j$("#SelectedCampaignAccountMembers").children().length > 0 && SelectedCampaignAccountMembers.length > 0)
        {
            ClearActivitiesTable(ObjectTypePrefix);
            
            j$("#"+ObjectTypePrefix+"TableContainer").css("display","");
            
            // put together a list of Selected Campaign Account Members Ids
            var CampaignAccountMemberIds = new Array();
            j$(SelectedCampaignAccountMembers).each(function(index,item){CampaignAccountMemberIds.push(item.sfid);});
            
            //console.log(CampaignAccountMemberIds);
            //console.log(calltype);
            
            var MyActivities = j$("#MyActivitiesCheckbox").attr("checked"); 
            if(!MyActivities) { MyActivities = false; }
            
            var ActivitiesSinceCampaign = j$("#ActivitiesSinceCampaignCheckbox").attr("checked"); 
            if(!ActivitiesSinceCampaign) { ActivitiesSinceCampaign = false; }
            
            try
            {
                DSCB_CampaignManagerController.FindActivities(
                    CampaignAccountMemberIds, RequestType, 
                    (MyActivities && RequestType.toLowerCase() == 'all'), 
                    (ActivitiesSinceCampaign && RequestType.toLowerCase() == 'all'), 
                    function(result, event)
                    {
                        if(result)
                        {
                            //console.log(result);
                            
                            j$("#"+ObjectTypePrefix+"Activities").css("display","");
                            
                            var rows = [];
                            var SelectedCampaignName = j$("#SelectCampaign").val();
                            
                            if(result.Objects)
                            {
                                //if (j$.browser.mozilla) { console.log(result.Objects); }
                                // put together all rows 
                                j$(result.Objects).each(function(index, item) {
                                    
                                    //console.log(item);
                                    
                                    // set any blank values to an empty string
                                    if(!item.Id) { item.Id=""; }
                                    if(!item.AccountId) { item.AccountId=""; }
                                    if(!item.Account) { item.Account={Id:"",Name:""}; }
                                    if(!item.Subject) { item.Subject=""; }
                                    if(!item.WhoId) { item.WhoId=""; }
                                    if(!item.Who) { item.Who={Name:""}; }
                                    if(!item.ActivityDate) { item.ActivityDate=""; }
                                    if(!item.Type) { item.Type=""; }
                                    if(!item.Status) { item.Status=""; }
                                    if(!item.Priority) { item.Priority=""; }
                                    if(!item.Owner) { item.Owner={Name:"",Id:""}; }
                                    if(!item.WhatId) { item.WhatId=""; }
                                    if(!item.What) { item.What={Name:"",Id:""}; }
                                    
                                    rows.push([
                                        "<a class='actionLink' href='/"+item.Id+"/e?retURL=/apex/CloseMe' target='_blank'>Edit</a>&nbsp;|&nbsp;"
                                        + "<a class='actionLink' href='/"+item.Id+"/e?close=1&retURL=/apex/CloseMe' target='_blank'>Cls</a>", // Action
                                        "<a class='actionLink' href='/"+item.Id+"?retURL=/apex/CloseMe' target='_blank'>"+item.Subject+"</a>", // Subject
                                        "<a href='/"+item.WhoId+"' target='_blank'>"+item.Who.Name+"</a>", // Related To (Who)
                                        "<a href='/"+item.WhatId+"' target='_blank'>"+item.What.Name+"</a>", // Related To (What)
                                        "<a href='/"+item.AccountId+"' target='_blank'>"+item.Account.Name+"</a>", // Account
                                        (String(item.Id).indexOf("00T")==0 ? "<span class='ui-icon ui-icon-check' style='margin:auto;'>True</span>" : ""), // Task
                                        item.Type, // Type
                                        DateToString(item.ActivityDate), // Due Date
                                        item.Status, // Status
                                        item.Priority, // Priority
                                        "<a href='/"+item.Owner.Id+"' target='_blank'>"+item.Owner.Name+"</a>" // Assigned To
                                    ]);
                                });
                                
                                var ActivitiesTable = null;
                                var CurrentActivitiesTable = j$("#"+ObjectTypePrefix+"Table.init"); 
                                
                                if(CurrentActivitiesTable.length > 0)
                                {
                                    var dt = CurrentActivitiesTable.dataTable();
                                    dt.fnClearTable();
                                    dt.fnAddData(rows);
                                    
                                    ActivitiesTable = j$("#"+ObjectTypePrefix+"Table").dataTable();
                                }
                                else
                                {
                                    ActivitiesTable = j$("#"+ObjectTypePrefix+"Table").addClass("init").dataTable({
                                        "aaData":rows,
                                        "bDestroy":true, // allow this datatable to be destroyed
                                        "bJQueryUI": true, // use the jQuery UI theme
                                        "bFilter": false, // do not allow filtering
                                        //"bPaginate": false, 
                                        "iDisplayLength": 10,
                                        "sPaginationType": "full_numbers", // show full numbers for paging
                                        "aaSorting": [[7,'desc']], // automatically sort by the 1st column ascending
                                        "sDom": "<'H'<'#"+ObjectTypePrefix+"TableHeaderMessage'>r>t<'F'ip>", // set the positioning of the table elements
                                        "aoColumns":[ 
                                            { "sTitle": "Action", "bSortable": false, "sWidth": "50px", "sType": "html" } // Actions
                                            ,{ "sTitle": "Subject", "sType": "html" } // Subject
                                            ,{ "sTitle": "Contact/Lead", "sType": "html" } // Related To - Contact or Lead
                                            ,{ "sTitle": "Opportunity/Account/Campaign", "sType": "html" } // Related To - Opportunity, Account, or Campaign
                                            ,{ "sTitle": "Account", "sType": "html" } // Account
                                            ,{ "sTitle": "Task", "sType": "html" } // Task
                                            ,{ "sTitle": "Type", "sType": "string" } // Type
                                            ,{ "sTitle": "Due Date", "sType": "date" } // Due Date
                                            ,{ "sTitle": "Status", "sType": "string" } // Status
                                            ,{ "sTitle": "Priority", "sType": "string" } // Priority
                                            ,{ "sTitle": "Assigned To", "sType": "html", "sWidth":"140px" } // Assigned To
                                        ]
                                    });
                                }
                                
                                j$("#"+ObjectTypePrefix+"TableHeaderMessage").css("text-align","center").html("500 Activities displayed at a time");
                                
                                j$("#"+ObjectTypePrefix+"Label").css("display","");
                                
                                scrollToBottom();
                            }
                        }
                        
                        MessageBox(false);
                    });
            }
            catch(error) { DisplayUnexpectedError(); }
        }
        else
        {
            MessageBox(true,"Please select a Campaign Account Member before finding Activities.","Please Select...",{"Ok":function(){j$(this).dialog("close");}});
        }
    }
    catch(exception) {
        MessageBox(true,"An unexpected error occurred while finding Activities for the selected Account. Error: "+exception); }
}

// -- clear previous data functions --

function ClearFilters()
{
    j$("#AccountState").val(j$("#AccountState option:first").val());
    j$("#AccountStartsWith").val("");
    j$("#AccountMemberStatus option").prop("selected", true);
    j$("#SelectAllAccountMemberStatuses").prop("checked", true);
    j$("#RegionsSelected option").prop("selected", true);                   //20th Nov, 2014: Added by Anirudh
    j$("#KeyDOSSelected").val(j$("#KeyDOSSelected option:first").val());    //21st Nov, 2014: Added by Anirudh
    j$("#KeyREPSelected").val(j$("#KeyREPSelected option:first").val());    //16th Dec, 2014: Added by Vishal Bandari
    j$("#TSMSelected").val(j$("#TSMSelected option:first").val());          //16th Dec, 2014: Added by Vishal Bandari
}

function ClearCampaignAccountMembersTable()
{
    // 13 columns
    // delete the table and re-initialize it
    //j$("#CampaignAccountMembersTable")
    //    .html("")
    //    .append(
    //          "<thead>"
    //            + "<tr>" + Array(13+1).join("<th></th>") + "</tr>" // header row (column plus one for join)
    //        + "</thead>"
    //        + "<tbody>"
    //            + "<tr>" + Array(13+1).join("<td></td>") + "</tr>" // body row (column plus one for join)
    //        + "</tbody>")
    //    .css("width","100%");
    
    SelectedCampaignAccountMembers = [];
    j$("#SelectedCampaignAccountMembers").children().each(function(){j$(this).remove();});
    j$("#SelectedCampaignAccountMembersLabel").css("display","");
    j$("#UpdateSelectedCampaignAccountMembersContainer").css("display","none"); // Update Selected
    
    j$("#ContactsContainer").css("display","none");
    j$("#ActivitiesContainer").css("display","none");
    j$("#OpenActivitiesLabel").css("display","none");
    j$("#ActivityHistoryLabel").css("display","none");
}

function ClearContactsTable()
{
    // 7 columns
    // delete the table and re-initialize it
    //j$("#ContactsTable")
    //    .html("")
    //    .append(
    //          "<thead>"
    //            + "<tr>" + Array(7+1).join("<th></th>") + "</tr>" // header row (column plus one for join)
    //        + "</thead>"
    //        + "<tbody>"
    //            + "<tr>" + Array(7+1).join("<td></td>") + "</tr>" // body row (column plus one for join)
    //        + "</tbody>")
    //    .css("width","100%");
    
    SelectedContacts = []; 
    j$("#ContactCheckAll").prop("checked",false);
    j$("#SelectedContacts").children().each(function(){j$(this).remove();}); 
    j$("#SelectedContactsLabel").css("display","");
    
    j$("#ContactsTableContainer").css("display","none");
    j$("#SendEmailToContactsContainer").css("display","none");
}

function ClearActivitiesTable(ObjectTypePrefix)
{
    if(!ObjectTypePrefix)
    {
        ClearActivitiesTable("OpenActivities"); // mmm, recursion
        ClearActivitiesTable("ActivityHistory");
    }
    else
    {
        // delete the table and re-initialize it
        //j$("#"+ObjectTypePrefix+"Table")
        //    .html("")
        //    .append(
        //          "<thead>"
        //            + "<tr>" + Array(11+1).join("<th></th>") + "</tr>" // header row (column plus one for join)
        //        + "</thead>"
        //        + "<tbody>"
        //            + "<tr>" + Array(11+1).join("<td></td>") + "</tr>" // body row (column plus one for join)
        //        + "</tbody>")
        //    .css("width","100%");
        
        //var OldActivitiesTable = j$("#"+ObjectTypePrefix+"Table").dataTable({
        //    "bRetrieve": true, "bJQueryUI": true, "sDom": "<'H'<'#"+ObjectTypePrefix+"TableHeaderMessage'>r>t<'F'ip>" });
        //OldActivitiesTable.fnClearTable();
        
        j$("#"+ObjectTypePrefix+"TableHeaderMessage").css("text-align","center").html("First 500 Activities Displayed");
        
        j$("#"+ObjectTypePrefix+"Label").css("display","none");
        j$("#"+ObjectTypePrefix+"TableContainer").css("display","none");
    }
}

// -- display toggle functions --

function ToggleContactsContainer(show)
{
    if(show) { j$("#ContactsContainer").css("display",""); }
    else { j$("#ContactsContainer").css("display","none"); }
}

function ToggleActivitiesContainer(show)
{
    if(show) { j$("#ActivitiesContainer").css("display",""); }
    else { j$("#ActivitiesContainer").css("display","none"); }
}


// -- processing dialogs --

function MessageBox(show, message, title, buttons) 
{ 
    var p = j$("#messagebox"); 
    if (show) { if (!p.dialog("isOpen")) { p.dialog("open"); } } else { if(p) { p.empty(); } if (p.dialog("isOpen")) { p.dialog("close"); } }
    if (title) { p.dialog("option","title",title) } else { p.dialog("option","title","Please Wait...") }
    if (message) { if(message && message.jquery) { p.empty().append(message); } else { p.html(message); } } else { p.html("Processing..."); }
    if (buttons) { p.dialog("option","buttons",buttons); } else { p.dialog("option","buttons",{}); }
    
    return p;
}

// -- utility functions -- 

// InsideSales.com dialer
function dial(event, pn, whoid, whatid)
{
    if(event) { event.preventDefault(); }
    
    if(ISTools && ISTools.Record) 
    { 
        scrollToTop(); 
        ISTools.Record.dialNumber({phone_number:pn, who_id:whoid, what_id:whatid}); 
    }
}

function scrollToTop() {
    j$("html, body").animate({ scrollTop: 0 }, "slow");
}

function scrollToBottom() {
    j$("html, body").animate({ scrollTop: j$(document).height() }, "slow");
}

function stopTimers() {
    for(var i in Timeouts) { clearTimeout(Timeouts[i]); }
    for(var i in Intervals) { clearInterval(Intervals[i]);  }
}

// http://stackoverflow.com/questions/8358084/regular-expression-to-reformat-a-phone-number-in-javascript
function formatPhoneNumber(number)
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
    MessageBox(true, "An unexpected error occurred. "
               + "There may be a number of causes such as the Salesforce session expiring. " 
               + "It is recommended to refresh your browser by clicking the Refresh button below. ", "Error", 
               {"Refresh":function(){window.location=window.location;}});
}

function ValidEmail(email) 
{
    var re = /^([^\@]*)\@([^\.]*)\.(.*)$/;
    return re.test(email);
}  

function decodeEntities(s)
{
    var str, temp = document.createElement('p');
    temp.innerHTML = s;
    str = temp.textContent || temp.innerText;
    temp = null;
    return str;
}

// -- custom datatable plugin functions --

// custom datatable function to get filtered nodes
j$.fn.dataTableExt.oApi.fnGetFilteredNodes = function ( oSettings )
{
    var anRows = [];
    for ( var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++ )
    {
        var nRow = oSettings.aoData[ oSettings.aiDisplay[i] ].nTr;
        anRows.push( nRow );
    }
    return anRows;
};

/*
// when a table is redrawn, use the values from the filtering inputs
j$.fn.dataTableExt.afnFiltering.push(
    function( oSettings, aData, iDataIndex ) 
    {
        // only clear if the filtering is changed on the Campaign Account Members Table
        if(oSettings && oSettings.sTableId && oSettings.sTableId == "CampaignAccountMembersTable") 
        {
            //console.log(oSettings);
            
            SelectedCampaignAccountMembers = [];
            j$("#SelectedCampaignAccountMembers").children().each(function(){j$(this).remove();});
            j$("#SelectedCampaignAccountMembersLabel").css("display","");
            
            var ReturnValue = false;
            
            var StateFilter = false;
            var StartsWithFilter = false;
            var StatusFilter = false;
            
            var AccountState = j$("#AccountState").val();
            var AccountStartsWith = j$("#AccountStartsWith").val();
            var AccountMemberStatus = j$(j$("#AccountMemberStatus").val());
            
            var TableAccountName = aData[1]; 
            var TableAccountMemberStatus = aData[2];
            var TableState = aData[4];
            
            if ((!AccountState || AccountState == "" || AccountState == "--None--")
            &&  (!AccountStartsWith || AccountStartsWith == "")
            &&  (j$("#AccountMemberStatus option").length == j$(j$("#AccountMemberStatus")).val().length)) { return true; }
            
            if ((!AccountState || AccountState == "" || AccountState == "--None--") || AccountState && TableState == AccountState) { StateFilter = true; }
            if ((!AccountStartsWith || AccountStartsWith == "") || 
                AccountStartsWith && j$(TableAccountName).html().toLowerCase().match("^"+AccountStartsWith.toLowerCase())) { StartsWithFilter = true; }
            
            if (j$("#AccountMemberStatus option").length != j$(j$("#AccountMemberStatus")).val().length) { 
                AccountMemberStatus.each( function(index,value) { if(TableAccountMemberStatus == value){ StatusFilter = true; } } ); }
            else { StatusFilter = true; }
            
            if(StateFilter && StartsWithFilter && StatusFilter) { ReturnValue = true; }
            
            return ReturnValue;
        }
    }
);
*/