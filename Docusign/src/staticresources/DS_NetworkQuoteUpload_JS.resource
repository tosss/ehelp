// use jQuery in no conflict mode
var j$; if(!j$) { j$ = jQuery.noConflict(); }

var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters
var maxFileSize = 4350000;      //After Base64 Encoding, this is the max file size
var chunkSize = 990000;         //Maximum Javascript Remoting message size is 1,000,000 characters
var attachment;
var attachmentName;
var fileSize;
var positionIndex;
var doneUploading;
var filesCount;
var filesList = [];
var counter = 0;
var dialog;
var temp = [];
var noQuotesRequired = false;
var holeInFirewallUseCat = false;
var holeInFirewallNoCharge = false;
var aspBuyOutCat=false;
var fileDescriptionList = [];
var projectHighwayRouting;

// actions to perform on initialization (after page loads)
j$(document).ready(init);

// Method to avoid adding duplicate files.
function unique(mainList,tempList) 
{    
    if(mainList.length==0)
    {
        mainList.push.apply(mainList, temp); 
    }
    else
    {
        var diff = [];
        for(i=0;i<tempList.length;i++)
        {
            var counter=0;
            var tempFile = tempList[i];
            var tempFileName = tempFile.name;
            for(j=0;j<mainList.length;j++)
            {
                var mainFile = mainList[j];
                var mainFileName = mainFile.name;
                
                if(mainFileName==tempFileName)
                {
                    counter++;
                }
            }
            if(counter==0)
            {
                diff.push(tempList[i]);
            }
        }
        mainList.push.apply(mainList, diff);
        for(i=0;i<mainList.length;i++)
        {
            var sampleFile = mainList[i];
            var sampleFileName = sampleFile.name;
            var selector="textarea[id='"+sampleFileName+"']";
            var fileDescription = j$(selector).val();
            fileDescriptionList.push(fileDescription);
        }
    }
    return mainList;
}

// actions to perform on initialization (after page loads)
function init()
{
    temp = [];
    dialog = j$("<div>").html("Uploading file: 1<br/><br/>Please wait while files are uploading.").dialog({
        "autoOpen": false,
        "modal": true,
        "title": "Loading"
    });
    /* below code is commentedout for RQ-04766 Project Highway Change */
    /*j$("#projectHighwayRouting").change(function() {
        projectHighwayRouting = j$( "#projectHighwayRouting option:selected" ).text();        
    });*/
    
    j$("#NoQuotesRequired").change(function() {
        if(this.checked) 
        {
            noQuotesRequired=true;
        }
        else
        {
            noQuotesRequired = false;
        }
    });
    j$("#holeInFirewallUseCat").change(function() {
        if(this.checked) 
        {
            holeInFirewallUseCat=true;
        }
        else
        {
            holeInFirewallUseCat= false;
        }
    });
    j$("#holeInFirewallNoCharge").change(function() {
        if(this.checked)
        {
            holeInFirewallNoCharge=true;
        }
        else
        {
            holeInFirewallNoCharge=false;
        }
    });
    
    j$("#aspBuyOutCat").change(function() {
        if(this.checked) 
        {
            aspBuyOutCat=true;
        }
        else
        {
            aspBuyOutCat=false;
        }
    });
    
    j$("#upload").change(
        function() 
        {
            // clear File Descriptions
            fileDescriptionList = [];
            // filesList and filesCount are global to JS functions
            temp = j$("#upload").prop("files");
            filesList = unique(filesList,temp);    
            filesCount = filesList.length;
            // buildFileDescContainer(filesList);
            j$("[id$='fileDescriptionContainer']").empty();
            for(var i=0; i<filesList.length; i++)
            {
                var file = filesList[i];
                var fileName = file.name;
                var fileDescriptionContainer = j$("<div>").addClass("grey-container");
                var fileDescriptionInput = j$("<textarea>").attr("id",fileName).attr("cols","60").text(fileDescriptionList[i]);
                var fileDescriptionLabel = j$("<label>").addClass("pad-label").text(fileName).attr("for",fileName);
                var fileDescriptionAnchor = j$("<button onclick=\"removeFile('" + fileName + "')\">Remove</button>");//.attr("onclick",check(fileName)).text("Remove");
                fileDescriptionContainer.append(fileDescriptionInput, fileDescriptionLabel,fileDescriptionAnchor);
                j$("[id$='fileDescriptionContainer']").append(fileDescriptionContainer);
            }
        }
    );
}

//Removing file from the list
function removeFile(fileName)
{
    var result = confirm("Are you sure you want to remove this?");
    if(result)
    {
        var tempList = [];
        var fileDescriptionList = [];
        for(var i=0; i<filesList.length; i++)
        {
            var file = filesList[i];
            var newfileName = file.name;
            if(newfileName!=fileName)
            {
                var selector="textarea[id='"+newfileName+"']";
                var fileDescription = j$(selector).val();
                tempList.push(filesList[i]);
                fileDescriptionList.push(fileDescription);
            }
        }
        filesList = tempList;
        
        //Rebuilding file Description Container
        j$("[id$='fileDescriptionContainer']").empty();
        for(var i=0; i<filesList.length; i++)
        {
            var file = filesList[i];
            var fileName = file.name;
            var fileDescriptionContainer = j$("<div>").addClass("grey-container");
            var fileDescriptionInput = j$("<textarea>").attr("id",fileName).attr("cols","60").text(fileDescriptionList[i]);
            var fileDescriptionLabel = j$("<label>").addClass("pad-label").text(fileName).attr("for",fileName);
            var fileDescriptionAnchor = j$("<button onclick=\"removeFile('" + fileName + "')\">Remove</button>");//.attr("onclick",check(fileName)).text("Remove");
            fileDescriptionContainer.append(fileDescriptionInput, fileDescriptionLabel,fileDescriptionAnchor);
            j$("[id$='fileDescriptionContainer']").append(fileDescriptionContainer);
        }
    }
}



//Method to prepare a file to be attached to the Account bound to the page by the standardController
function saveFilesAndNotes() 
{
    //console.log(projectHighwayRouting);
    
    var fileDescription = j$("#fileDescription").val();
    var overAllNotes = j$("#notesTextArea").val();
    
    if(overAllNotes==null)
    {
        overAllNotes='';
    }
    
    var aspBuyOutPrice = j$("#aspBuyOutPrice").val();
    if(aspBuyOutPrice.length==0)
    {
        aspBuyOutPrice='';
    }
    
    // filesList and filesCount are global to JS functions
    filesCount = filesList.length;
    
    if(filesList.length != 0)
    {
        var file = filesList[counter];
        if(file.size <= maxFileSize) 
        {
            dialog.dialog("open");
            attachmentName = file.name;
            var selector="textarea[id='"+attachmentName+"']";
            var fileDescription = j$(selector).val();            
            var fileReader = new FileReader();
            
            fileReader.onloadend = function(e) 
            {
                //Base 64 encode the file before sending it
                attachment = window.btoa(this.result);
                positionIndex=0;
                fileSize = attachment.length;                
                doneUploading = false;
                
                if(fileSize < maxStringSize) 
                {                    
                    uploadAttachment(
                        null,
                        __sObjectId,
                        attachmentName,
                        fileDescription,
                        counter,
                        filesCount,
                        overAllNotes,
                        noQuotesRequired,
                        holeInFirewallUseCat,
                        holeInFirewallNoCharge,
                        aspBuyOutCat,
                        aspBuyOutPrice,
                        projectHighwayRouting
                    ); 
                } 
                else 
                {
                    alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
                }                
            }
            
            fileReader.onerror = function(e) 
            {
                alert("There was an error reading the file. Please try again.");
            }
            
            fileReader.onabort = function(e) {
                alert("There was an error reading the file. Please try again.");
            }
            
            //Read the body of the file
            fileReader.readAsBinaryString(file);  
        } 
        else 
        {
            alert("File must be under 4.3 MB in size. Your file is too large. Please try again.");
        }
    }
    else 
    {
        if(overAllNotes.length!=0)
        {
            dialog = j$("<div>").html("Notes Uploading... <br/><br/>Please wait..").dialog({
                "autoOpen": false,
                "modal": true,
                "title": "Loading"
            });
            
            dialog.dialog("open"); 
            DS_NetworkQuoteUpload_Extension.doUploadAttachment(
                __sObjectId, //String sobjId,
                null, //String attachmentBody, 
                null, //String attachmentName,
                null, //String attachmentId, 
                null, //String fileDescription, 
                null, //Integer counter, 
                null, //Integer fileCount, 
                overAllNotes, //String OverAllNotes, 
                noQuotesRequired, //Boolean noQuotesRequired,
                holeInFirewallUseCat, //Boolean holeInFirewallUseCat, 
                holeInFirewallNoCharge, //Boolean holeInFirewallNoCharge,
                aspBuyOutCat, //Boolean aspBuyOutCat, 
                aspBuyOutPrice, //String aspBuyOutPrice, 
                (!projectHighwayRouting?null:projectHighwayRouting), //String projectHighwayRouting, 
                true, //Boolean doneUploading - let this be true to insert Dc once else it will insert multiple times
                callbackNotes // callback causes recursion because this function is called
            );
        }
        else
        {
            var wait = j$("<div>").html("Please select at least one file to upload or Add Deal Change notes").dialog({
                "modal": true,
                "title": "Select a File",
                "buttons": {"Ok":function(){j$(this).dialog("close");}}
            }); 
        }
    }
    
}

function uploadAttachment(
    fileId,
    __sObjectId,
    attachmentName,
    fileDescription,
    counter,
    filesCount,
    overAllNotes,
    noQuotesRequired,
    holeInFirewallUseCat,
    holeInFirewallNoCharge,
    aspBuyOutCat,
    aspBuyOutPrice,
    projectHighwayRouting)
{
    var attachmentBody = "";
    if(fileSize <= positionIndex + chunkSize) 
    {                        
        attachmentBody = attachment.substring(positionIndex);                        
        doneUploading = true;
    } 
    else 
    {
        attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
    }
    
    //fileId = null;
    
    DS_NetworkQuoteUpload_Extension.doUploadAttachment(
        __sObjectId, //String sobjId,
        attachmentBody, //String attachmentBody, 
        attachmentName, //String attachmentName,
        fileId, //String attachmentId, 
        fileDescription, //String fileDescription, 
        counter, //Integer counter, 
        filesCount, //Integer fileCount, 
        overAllNotes, //String OverAllNotes, 
        noQuotesRequired, //Boolean noQuotesRequired,
        holeInFirewallUseCat, //Boolean holeInFirewallUseCat, 
        holeInFirewallNoCharge, //Boolean holeInFirewallNoCharge,
        aspBuyOutCat, //Boolean aspBuyOutCat, 
        aspBuyOutPrice, //String aspBuyOutPrice, 
        (!projectHighwayRouting?null:projectHighwayRouting), //String projectHighwayRouting, 
        doneUploading, //Boolean doneUploading - let this be true to insert Dc once else it will insert multiple times
        function(result, event) {          
            if(event.type === 'exception') {
                //console.log("exception");
                //console.log(event);
            } 
            else if(event.status) 
            {
                if(doneUploading != true) 
                {
                    positionIndex += chunkSize;
                    uploadAttachment(
                        result,
                        __sObjectId,
                        attachmentName,
                        fileDescription,
                        counter,
                        filesCount,
                        overAllNotes,
                        noQuotesRequired,
                        holeInFirewallUseCat,
                        holeInFirewallNoCharge,
                        aspBuyOutCat,
                        aspBuyOutPrice,
                        projectHighwayRouting
                    );
                } 
                else
                {
                    callback(result, event);
                }
            }
            else {
                //console.log(event.message);
            }
        },
        {buffer: true, escape: true, timeout: 120000} // callback causes recursion because this function is called
    );
}

function callbackNotes(result, event)
{
    dialog.html("Notes Uploaded.<br/><br/>Please wait..."); // update dialog
    window.location="/"+__sObjectId;
}            

function callback(result, event)
{
    filesCount = filesList.length;
    counter++;
    
    //console.log(event);
    
    if(event && event.status && event.type !== "exception") 
    {
        if(counter<filesCount)
        {
            window.setTimeout(saveFilesAndNotes, 1000); // 2014-11-11 MK - recursion.. need to update dialog
            dialog.html("Uploading file: " + (counter+1) + "<br/><br/>Please wait while files are uploading."); // update dialog
        }
        else
        {
            dialog.html("Upload finished.<br/><br/>Please wait..."); // update dialog
            window.location="/"+__sObjectId;
        }
    }
    else 
    {
        dialog.html(
            "An error occurred while uploading files. Please try again. <br/><br/>" + 
            "<div style='display:none; font: 8pt Courier New;' id='CurrentErrorMessage'>"+event.message+"</div>"
        ); // update dialog
        
        dialog.dialog("option", "buttons", [
            { text:"Detail", click: function(){ j$("#CurrentErrorMessage").css("display","");} },
            { text:"Ok", click: function(){window.location.href = window.location.href;} }
        ]);
    }
}

function cancel()
{
    window.location="/"+__sObjectId; 
}

function AddMoreFiles() { 
    
    j$('#wrapper').show();
    var AddMoreButton = j$("[id$='button1']");    
    AddMoreButton.css("display","none");
    return false; 
}

// Save files / Deal Change notes (IE Browser only)
function blockme(event)
{  
    (event.preventDefault) ? event.preventDefault() : event.returnValue = false;
    var filesSelected = false; 
    j$("input[type='file']").each(
        function(i,v){
            if(j$(v).val() != ""){
                filesSelected = true;
            }
        }
    ); 
    
    if(filesSelected)
    {
        var wait = j$("<div>").html("Please wait while files are uploading....").dialog({
            "modal": true,
            "title": "Loading"
        });
        
        UploadAndSave();
    }
    else
    {
        var notes = j$("TextArea[id='page1:AttForm:block1:j_id101:j_id102:DealChangeNotes']").val();
        if(notes.length!=0)
        {
            var wait = j$("<div>").html("Please wait while Notes is uploading....").dialog({
                "modal": true,
                "title": "Loading"
            });
            UploadAndSave();
        }
        else
        {
            var wait = j$("<div>").html("Please select at least one file to upload or Add Deal Change notes").dialog({
                "modal": true,
                "title": "Select a File",
                "buttons": {"Ok":function(){j$(this).dialog("close");}}
            }); 
        }
    }
    return false;
}

var base64 = {};
var PADCHAR = '=';
var ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function base64Getbyte64(s,i) {
    // This is oddly fast, except on Chrome/V8.
    //  Minimal or no improvement in performance by using a
    //   object with properties mapping chars to value (eg. 'A': 0)
    var idx = ALPHA.indexOf(s.charAt(i));
    if (idx === -1) {
        //console.log('Error!');
    }
    return idx;
}

function base64Encode(s) {
    
    if (arguments.length !== 1) {
        throw new SyntaxError("Not enough arguments");
    }
    
    var i, b10;
    var x = [];    
    // convert to string
    s = '' + s;   
    var imax = s.length - s.length % 3;
    
    if (s.length === 0) {
        return s;
    }
    
    for (i = 0; i < imax; i += 3) {
        b10 = (base64Getbyte64(s,i) << 16) | (base64Getbyte64(s,i+1) << 8) | base64Getbyte64(s,i+2);
        x.push(alpha.charAt(b10 >> 18));
        x.push(alpha.charAt((b10 >> 12) & 0x3F));
        x.push(alpha.charAt((b10 >> 6) & 0x3f));
        x.push(alpha.charAt(b10 & 0x3f));
    }    
    switch (s.length - imax) {
        case 1:
            b10 = base64Getbyte64(s,i) << 16;
            x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
                   padchar + padchar);
            break;
        case 2:
            b10 = (base64Getbyte64(s,i) << 16) | (base64Getbyte64(s,i+1) << 8);
            x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
                   alpha.charAt((b10 >> 6) & 0x3f) + padchar);
            break;
    }
    return x.join('');
}
