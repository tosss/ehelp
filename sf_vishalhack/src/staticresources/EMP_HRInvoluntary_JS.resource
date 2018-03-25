// use jQuery in noConflict mode because Salesforce uses another JavaScript library
var j$ = jQuery.noConflict();

// -- when DOM is ready, do init
j$(document).ready(init);

// -- global variables --
var BackgroundURL;

function init()
{
    // after the page has loaded, set the global variable from the page (apex-bound) variable
    BackgroundURL = "url('"+__BackgroundURL+"')"; 
    
    var SelectContactElement = j$("#SelectContact");
    SelectContactElement.blur(function(){stopProcessing();});
    
    // activate tooltips
    j$(".tooltip").tooltip();
    
    SelectContactElement.autocomplete({
        source: SearchContacts,
        select: function (event, ui) {
            j$("[id$='ContactId']").val(ui.item.salesforceid);
            j$("[id$='AssociateTitle']").html(ui.item.title);
            j$("[id$='AssociateManager']").html(ui.item.manager);
        },
        minLength: 0,
        search: function () { 
            startProcessing();
        },
        open: function () { stopProcessing(); }
    });
    
    SelectContactElement.blur(function(){
        if(SelectContactElement && SelectContactElement.val().trim() == "") {
            deselectContact();
        }
    });
}

function deselectContact()
{
    // blank out the selected ContactId, Title, and Manager elements
    j$("[id$='ContactId']").val("");
    j$("[id$='AssociateTitle']").html("");
    j$("[id$='AssociateManager']").html("");
}

function SearchContacts(request, response) 
{
    autocompleteSearchStopped();
    deselectContact();
    
    var search = (request.term && request.term.length > 1 && request.term.trim() != "" ? request.term : "");
    try
    {
        if(search != "") {
            autocompleteSearchStarted();
            
            EMP_HRInvoluntaryController.SearchContacts(search, function(result, event){
                
                var AllContacts = j$.map(result, function(item){
                    var VendorID = (item.Vendor_ID__c ? ' (' + ConvertSpecialCharacters(item.Vendor_ID__c) + ')' : '');
                    return ({
                        label: ConvertSpecialCharacters(item.Name) + VendorID,
                        salesforceid: item.Id,
                        title: item.HR_Title__c,
                        manager: item.HR_Manager__r ? item.HR_Manager__r.Name : ""
                    });
                });
                
                if (event.type == "exception") 
                {
                    alert(event.message);
                }
                else 
                {
                    if (AllContacts.length > 0) {
                        response(AllContacts);
                    }
                    else {
                        stopProcessing();
                        autocompleteSearchStopped();
                    }
                }
            });
        }
    }
    catch(error) { 
        DisplayUnexpectedError(); 
        autocompleteSearchStopped();
    }
}

function submitInvoluntaryTerm()
{
    startProcessing();
    
    // declare a new messagebox to be added to the page
    // to display the result
    var mb = j$("<div>"); 
    
    j$("#SelectContactMessage").html("");
    
    var SelectContact = j$("#SelectContact");  //log("Select Contact: "+SelectContact.val());
    var ContactId = j$("[id$='ContactId']"); //log("Contact ID: "+ContactId.val());
    var SelectedDate = j$("[id$='SelectedDate']"); //log("Selected Date: "+SelectedDate.val());
    var Hours = j$("[id$='Hours']"); //log("Hours: "+Hours.val());
    var Mins = j$("[id$='Mins']"); //log("Mins: "+Mins.val());
    var AMPM = j$("[id$='AMPM']"); //log("AMPM: "+AMPM.val());
    var AssociateTitle = j$("[id$='AssociateTitle']"); //log("Associate Title: "+AssociateTitle.val());
    var AssociateManager = j$("[id$='AssociateManager']"); //log("Associate Manager: "+AssociateManager.val());
    
    if(ContactId.val() != "" && SelectedDate.val() != "" && Hours.val() != "" && Mins.val() != "" && AMPM.val() != "")
    {
        EMP_HRInvoluntaryController.submitForm(
            ContactId.val(), SelectedDate.val(), Hours.val(), Mins.val(), AMPM.val(),
            function(event, response){
                var result = response.result; //log(result);
                
                if(!result) {
                    try {
                        displayResultMessage(
                            mb, false, "Error", 
                            result.message + "<input type='hidden' value='"+result.caseid+"'/>"
                        );
                    }
                    catch(e) {
                        DisplayUnexpectedError();
                    }
                    
                    stopProcessing();
                    return;
                }
                else {
                    
                    stopProcessing();
                    
                    displayResultMessage(
                        mb, result.success, "Involuntary Termination Submitted", 
                        result.message + "<input type='hidden' value='"+result.caseid+"'/>"
                    );
                    
                    SelectContact.val(""); 
                    ContactId.val(""); 
                    SelectedDate.val(""); 
                  //  Hours.val("12 "); 
                  //  Mins.val("00"); 
                  // AMPM.val("AM"); 
                    
                    AssociateTitle.html("");
                    AssociateManager.html("");
                }
            }
        );
    }
    else {
        displayResultMessage(
            mb, false, "Required fields missing...", 
            "Please select an Associate by typing a Name or Vendor ID and make a selection from the list that appears. " + 
            "Also, fill in the Associates Last Worked Date Time. "
        );
    }
}

function autocompleteSearchStarted() {
    j$("#SelectContact").css("background","transparent "+BackgroundURL+" no-repeat right");
    j$("#SelectContact").css("border","solid 1px #ccc");
}

function autocompleteSearchStopped() {
    j$("#SelectContact").css("background","");
    j$("#SelectContact").css("border","");
}

function startProcessing() {
    j$("[id$='Submit']").attr("disabled","disabled").addClass("btnDisabled").html("Please wait...");
    j$(this).css("background",BackgroundURL+" no-repeat right center #fff"); 
}

function stopProcessing() {
    j$("[id$='Submit']").removeAttr("disabled").removeClass("btnDisabled").html("Submit");
    j$("#SelectContact").css("background","#fff");
}

function displayResultMessage(mb, success, title, message) {
    var defaultMessage, defaultTitle;
    
    if(!success) {
        defaultMessage = "An error occurred..."; defaultTitle = "Error";
    }
    else {
        defaultMessage = "Sucessfully submitted... "; defaultTitle = "Success";
    }
    
    var msg = message && message.trim() != "" ? message : defaultMessage;
    var t = title && title.trim() != "" ? title : defaultTitle;
    
    MessageBox(mb, true, msg, t, {"Ok":function(){j$(this).dialog("close");}});
}


