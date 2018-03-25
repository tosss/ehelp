/* Original Author: Vishal Bandari
 * Last Modified By: 2015-06-25 matt.keefe@cdk.com - updated formatting, removed duplicate functions, updated some functions for usability
 * 
 */

// -- Browser Functions -- //

var isIE = !!navigator.userAgent.match(/trident/ig);

// -- Logging Functions -- //

var loggingOff = false;

function log(e) {
    if(console && console.log && !isIE && !loggingOff)
    {
        console.log(e); 
    }
};

// -- Validation Functions -- //

function ValidEmail(email) {
    var re = /^([^\@]*)\@([^\.]*)\.(.*)$/;
    return re.test(email);
} 

// http://stackoverflow.com/a/8358141/549141
function formatPhoneNumber(number){
    var digits = (""+number).replace(/\D/g, "");
    var match = digits.match(/1?(\d{3})(\d{3})(\d{4})$/);
    return (!match) ? digits : "(" + match[1] + ") " + match[2] + "-" + match[3];
}

// -- Conversion Functions -- //

function DateToString(InitialDate){
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

// -- Timer Functions -- //

function stopTimers() {
    for(var i in Timeouts) { clearTimeout(Timeouts[i]); }
    for(var i in Intervals) { clearInterval(Intervals[i]);  }
}

// -- Conversion Functions -- //

function DateToString(InitialDate){
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

// -- Redirecting Functions -- //

function redirectToObject(ObjectId,location) {
    window.open('/'+ObjectId,location);
}

function redirectToUrl(url,location){
    window.open('/'+url,location);
}

// -- URL Query String Parameter Functions -- //

// http://stackoverflow.com/a/901144/549141
function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function updateQueryStringParameter(uri, key, value){
    var re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i");
    separator = uri.indexOf('?') !== -1 ? "&" : "?";
    
    var newuri = "";
    
    if (uri.match(re)) {
        if(value) { newuri = uri.replace(re, '$1' + key + "=" + value + '$2'); } else { newuri = uri.replace(re,""); } }
	else {
		if(value) { newuri = uri + separator + key + "=" + value; } else { newuri = uri; } }
    
    return newuri;
}

// -- HTML Conversion Functions -- //

function ConvertSpecialCharacters(text){
    var temp = document.createElement("div");
    temp.innerHTML = text;
    var result = temp.childNodes[0].nodeValue;
    temp.removeChild(temp.firstChild)
    return result;
}

// -- Browser Check Functions -- //

function isIE() {
    return !!navigator.userAgent.match(/trident/ig);
}

// -- Action Functions -- //

function dial(event, pn, whoid, whatid){
    if(event) { event.preventDefault(); }
    
    if(ISTools && ISTools.Record){ 
        scrollToTop(); 
        ISTools.Record.dialNumber({phone_number:pn, who_id:whoid, what_id:whatid}); 
    }
}

function stopTimers() {
    for(var i in Timeouts) { clearTimeout(Timeouts[i]); }
    for(var i in Intervals) { clearInterval(Intervals[i]);  }
}

// -- Encode and Decoding Functions -- //

function decodeEntities(s){
    var str, temp = document.createElement('p');
    temp.innerHTML = s;
    str = temp.textContent || temp.innerText;
    temp = null;
    return str;
}


/* == jQuery Utility functions and jQuery dependent functions == */

var j$ = jQuery.noConflict();

// -- Popup Functions -- //

// usage: 
// var mb = j$("<div>"); MessageBox(mb, true, "Test", "Message", {"Cancel":function(){j$(this).dialog("close");}});
function MessageBox(element, show, message, title, buttons) { 
    var p = j$(element); 
    
    if (p) { p.dialog({modal: true, autoOpen: false, minWidth: 300}); }
    if (show) { if (!p.dialog("isOpen")) { p.dialog("open"); } } else { if(p) { p.empty(); } if (p.dialog("isOpen")) { p.dialog("close"); } }
    if (title) { p.dialog("option","title",title) } else { p.dialog("option","title","Please Wait...") }
    if (message) { if(message && message.jquery) { p.empty().append(message); } else { p.html(message); } } else { p.html("Processing..."); }
    if (buttons) { p.dialog("option","buttons",buttons); } else { p.dialog("option","buttons",{}); }
    
    return p;
}

function DisplayUnexpectedError(){
    var mb = j$("<div>"); 
    MessageBox(
        mb,
        true, 
        "An unexpected error occurred. "
        + "There may be a number of causes such as the Salesforce session expiring. " 
        + "It is recommended to refresh your browser by clicking the Refresh button below. ", 
        "Error", 
        {
            "Refresh":function(){
                window.location=window.location;
            }
        }
    );
}


// -- Animation Functions -- //

function scrollToTop() {
    j$("html, body").animate({ scrollTop: 0 }, "slow");
}

function scrollToBottom() {
    j$("html, body").animate({ scrollTop: j$(document).height() }, "slow");
}

