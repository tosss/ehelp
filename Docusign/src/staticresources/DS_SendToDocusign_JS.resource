// on and between 6/11/2015 - 6/11/2015 siva.Pragada@cdk.com added autocomplete search for user and also contact picklist and related changes

//450 and 451 , 77 and 88 siva.pragada@cdk.com

var j$; if(!j$) { j$ = jQuery.noConflict(); }

// old IE fix
if (!window.console) { console = { log: function(message) { } } }

var test;
var ccEmailList = [];
var loadingurl;

//2015-04-02 MK - may need to keep these, but maybe consolidate into override signers
//idea being: { "OverrideSigner1": {FirstName:"", LastName:"", Email:""} }
var overrideSigner1Object = {FirstName:"", LastName:"", Email:""}; 
var overrideSigner2Object = {FirstName:"", LastName:"", Email:""}; 

// 2015-04-02 MK - Remove global variables, these should be passed as arguments/parameters instead
var Is_Client_1_Sign_In_Person = false; // use j$("[id$='SignInPerson1']").is(":checked") instead
var isSigner1Checked = false; // j$("[id$='SignInPerson1']").is(":checked")
var isSigner2Checked = false; // j$("[id$='SignInPerson2']").is(":checked")

j$(document).ready(init);

function init() 
{ 
    loadingurl = "url("+__InputBoxLoadingIcon+")";
    var wait = j$("<div>").html("Please wait...").dialog({
        "modal": true,
        "title": "Loading"
    });
    
    var SendToDocusignButton = j$("[id$='SendToDocusign']");
    
    if(__Region == "Division")
    {
        j$("#PageMessages").html("Account's region is Division");
        DisableElement(SendToDocusignButton); 
        DisableElement(j$("input, select, textarea", "[id$='form1']"));
        wait.dialog("close");
        return;        
    }
    
    j$("#SearchYourUser")
    .bind("keypress",BypassEnterKey)                  
    .autocomplete({
        source: AutocompleteSource,
        minLength: 2,
        delay: 750,
        select: SelectYourUser,
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
    
    // validate
    DS_SendToDocusign_Extension.Validate(
        __CurrentPageId, 
        function(Message, event)
        {
            if (event.type == 'exception' || Message != null) {
                j$("#PageMessages").html(Message);
                //alert(Message);
                // declare all variables for disabling all the fields in the page                
                //DisableElement(SendToDocusignButton);           
                DisableElement(j$("input, select, textarea", "[id$='form1']")); //.attr("disabled","disabled");
                
                wait.dialog("close"); 
                return; 
            }
            showHidePanel(this);   
            wait.dialog("close");
        }
    );
    var ccData = {};
    if(__CurrentAccountHasCorpAuthSigner)
    {
        var dealStateAccountId = j$("[id$='AlternateDocuSignAccount1']").val();
        
        DS_SendToDocusign_Extension.getAllRequiredCcsIntoJavascript(
            __OppAccountId, dealStateAccountId,
            
            function(result, event)
            {  
                j$(result).each(
                    function(i,v) 
                    {
                        var ccData = {}; 
                        ccData.Email = v.Email;
                        ccData.FirstName = v.FirstName;
                        ccData.LastName = v.LastName;
                        addEmail(ccData);                        
                    }
                )
            }
        );
    } 
}

//sanjay.ghanathey@cdk.com 13-Feb-2015 Override Signer
function overrideSigner(element)
{   
    var id = j$(element).attr('id');
    var SelectedUserId;
    var Signer_Email; 
    var signerId = 0;
    
    if(id.indexOf('OverrideSigner1')> 0)
    {
        SelectedUserId = j$("[id$='OverrideSigner1_lkid']");
        Signer_Email = j$("[id$='Signer_1_Email']");
        signerId= 1;
    }
    else if(id.indexOf('OverrideSigner2')>0)
    {
        SelectedUserId = j$("[id$='OverrideSigner2_lkid']");
        Signer_Email = j$("[id$='Signer_2_Email']");
        signerId= 2;
    }
    
    DS_SendToDocusign_Extension.SelectUser(SelectedUserId.val(), function(result, event) {            
        if(result) {   
            if(isSigner2Checked && signerId==2)
            {
                overrideSigner2Object = result;
                Signer_Email.val(overrideSigner2Object.Email);
            }
            else if(isSigner1Checked && signerId==1)
            {
                overrideSigner1Object = result;
                Signer_Email.val(overrideSigner1Object.Email);
            }
        }            
    });   
}

function clearOverrideSigner(element)
{    
    //alert('inside clear signer');
    var id = j$(element).attr('id'); //alert(id);
    var SelectedUserId;
    var SelectedUserName;
    var Signer_Email;
    var classElement;
    var isValidId = false;
    if(id == 'clearOverrideSigner1')
    {
        //alert('clearing signer 1');        
        SelectedUserId = j$("[id$='OverrideSigner1_lkid']");
        SelectedUserName = j$("[id$='OverrideSigner1_lkold']");
        Signer_Email = j$("[id$='Signer_1_Email']");
        classElement = j$(".OverrideSigner1");
        renderSigner(j$("[id$='SelectedListSigner1']"));
        isValidId = true;                        
    }
    else if(id == 'clearOverrideSigner2')
    {
        //alert('clearing signer 2');
        SelectedUserId = j$("[id$='OverrideSigner2_lkid']");
        SelectedUserName = j$("[id$='OverrideSigner2_lkold']");
        Signer_Email = j$("[id$='Signer_2_Email']");
        classElement = j$(".OverrideSigner2");        
        renderSigner(j$("[id$='SelectedListSigner2']"));
        isValidId = true;
    }
    
    if(isValidId)
    {
        SelectedUserId.val('000000000000000');
        Signer_Email.val('');
        SelectedUserName.val('null');
        classElement.val('');
        return false;
    }    
}

//sanjay.ghanathey@cdk.com 02-Feb-2015 Add Email Ids to CC additional contacts
function addEmail(value)
{
    j$('#SearchYourUser').val("");
    j$("[id$='contactsId']").val(""); 

    
    var wait = j$("<div>").html("Please wait...").dialog({
        "modal": true,
        "title": "Adding Email"
    });
    
    var CarbonCopyEmail = j$("[id$='ccEmailId']").val();
    var CarbonCopyFirstName = j$("[id$='ccFirstName']").val();
    var CarbonCopyLastName = j$("[id$='ccLastName']").val();
    
    if(value)
    {
        var CarbonCopyEmail = value.Email;
        var CarbonCopyFirstName = value.FirstName;
        var CarbonCopyLastName = value.LastName;
    }
    
    var ccData = {};
    ccData.Email = CarbonCopyEmail;
    ccData.FirstName = CarbonCopyFirstName;
    ccData.LastName = CarbonCopyLastName;
    
    j$("#PageMessages2").empty();
    j$("#PageMessages").empty();
    
    var validateErrorMessage = "The CC Email address supplied is invalid.";
    var validEmail = ValidateEmail(ccData.Email, validateErrorMessage);
    
    if(validEmail)
    {
        var found = false;
        for(var i = 0; i < ccEmailList.length; i++) {
            if (ccEmailList[i] == CarbonCopyEmail) {
                found = true;                    
                break;
            }
        }
        
        if(!found)
        {
            ccEmailList.push(ccData);
            
            j$("[id$='ccEmailIdList']").empty();
            
            for(var i=0; i<ccEmailList.length; i++)
            {            
                var container = j$("<p>").addClass("text-spacing").attr("style","margin-bottom:4px;margin-left:0px;");
                var emailAddress = j$("<label>").addClass("text-background").text(ccEmailList[i].Email).attr("for",ccEmailList[i].Email);
                var removeEmailAddress = j$("<img>").attr("src","/img/func_icons/remove12_on.gif").attr("onclick","removeEmail('" + ccEmailList[i].Email + "')");  
                j$(container).append(emailAddress,removeEmailAddress);
                j$("[id$='ccEmailIdList']").append(container);
                
                // clear values
                j$("[id$='ccEmailId']").val("");
                j$("[id$='ccFirstName']").val(""); 
                j$("[id$='ccLastName']").val(""); 
            }   
        }
    }
    else
    {
        j$("#PageMessages").html(validateErrorMessage);
    }
    
    wait.dialog("close");
}

//sanjay.ghanathey@cdk.com 02-Feb-2015 Remove Email Ids from CC additional contacts
function removeEmail(ccEmail)
{        
    var tempList = [];
    j$("[id$='ccEmailIdList']").empty();
    
    for(var i=0; i<ccEmailList.length; i++)
    {
        var newEmailId = ccEmailList[i].Email;        
        if(newEmailId!=ccEmail)
        {
            tempList.push(ccEmailList[i]);
        }
    }
    
    ccEmailList = tempList;
    for(var i=0; i<ccEmailList.length; i++)
    {
        var container = j$("<p>").addClass("text-spacing").attr("style","margin-bottom:4px;margin-left:0px;");        
        var emailAddress = j$("<label>").addClass("text-background").text(ccEmailList[i].Email).attr("for",ccEmailList[i].Email);
        var removeEmailAddress = j$("<img>").attr("src","/img/func_icons/remove12_on.gif").attr("onclick","removeEmail('" + ccEmailList[i].Email + "')");        
        j$(container).append(emailAddress,removeEmailAddress);
        j$("[id$='ccEmailIdList']").append(container);
    }
    
    //clearing the value of lookup for input
    j$("[id$='ccEmailId']").val(""); 
    j$("[id$='ccFirstName']").val(""); 
    j$("[id$='ccLastName']").val(""); 
}

//sanjay.ghanathey@cdk.com 07-Jan-2015 To fetch Signers when account is changed
function renderSigner(element)
{
    
    var selectedlistsigner1 = j$("[id$=SelectedListSigner1]");
    var selectedlistsigner2 = j$("[id$=SelectedListSigner2]");
    var SendToDocusignButton = j$("[id$='SendToDocusign']");
    
    if(j$(element).attr('Id').indexOf('SelectedListSigner1')>0)
    { 
        if(selectedlistsigner2 && !selectedlistsigner2.prop('disabled') && selectedlistsigner2.val() && selectedlistsigner2.val().length>0)
        { 
            EnableElement(SendToDocusignButton);
        }
        else if(selectedlistsigner2.prop('disabled'))
        {
            EnableElement(SendToDocusignButton);
        }        
        
        SelectContact(j$(element).val(),'Signer_1_Email','EmailBodyText'); 
    }
    if(j$(element).attr('Id').indexOf('SelectedListSigner2')>0)
    { 
        if(selectedlistsigner1 && !selectedlistsigner1.prop('disabled') && selectedlistsigner1.val() && selectedlistsigner1.val().length>0)
        {          
            EnableElement(SendToDocusignButton);
        }
        
        SelectContact(j$(element).val(),'Signer_2_Email','EmailBodyText'); 
    }    
}

//sanjay.ghanathey@cdk.com 06-Apr-2015 - Toggle Overrider Signers.In addition,
//it also clears the override signers data if unchecked.
function signInPerson(element)
{       
    var elementId = j$(element).attr('id');
    var SignInPerson = j$(element);
    var Signer_Email;
    var SignInPersonHidden; 
    var OverrideSigner;
    var ClearOverrideSigner;
    
    if(elementId.indexOf('SignInPerson1')>0)
    {
        Signer_Email = j$("[id$='Signer_1_Email']");
        SignInPersonHidden = j$("[id$='SignInPersonHidden1']"); 
        OverrideSigner = j$(".OverrideSigner1");
        ClearOverrideSigner = j$("[id$='clearOverrideSigner1']");
        if(SignInPerson.is(":checked"))
        {
            isSigner1Checked = true;
        }
        else
        {
            var tempElement = j$("[id$='clearOverrideSigner1']");
            if(isSigner1Checked)
            {
                isSigner1Checked = false; //alert('clearing signer');
                clearOverrideSigner(tempElement);         
            }
        }
    }
    else if(elementId.indexOf('SignInPerson2')>0)
    {
        Signer_Email = j$("[id$='Signer_2_Email']");
        SignInPersonHidden = j$("[id$='SignInPersonHidden2']"); 
        OverrideSigner = j$(".OverrideSigner2");
        ClearOverrideSigner = j$("[id$='clearOverrideSigner2']");
        if(SignInPerson.is(":checked"))
        {
            isSigner2Checked = true;
        }
        else
        {
            var tempElement = j$("[id$='clearOverrideSigner2']");            
            if(isSigner2Checked)
            {
                isSigner2Checked = false;
                clearOverrideSigner(tempElement);         
            }
        }
    }  
    
    if(SignInPerson.is(":checked"))
    {      
        SignInPersonHidden.val(true);        
        Signer_Email.prop('disabled', true);  
        Signer_Email.val(__UserInfoEmail);
        Is_Client_2_Sign_In_Person = true; 
        OverrideSigner.show();
        ClearOverrideSigner.show();
        isSigner2Checked = true;
    }
    else
    {
        SignInPersonHidden.val(true);        
        
        if(!SignInPerson.prop('disabled'))
        {
            Signer_Email.prop('disabled', false); 
        }
        Is_Client_2_Sign_In_Person = false; 
        OverrideSigner.hide();
        ClearOverrideSigner.hide();        
    }
}

function showHidePanel(ref){
    if (j$('.buy-sell-check').is(":checked") ||
        __deal_type_Text_value == 'Ownership Change' || 
        __deal_type_Text_value == 'Ownership Change Upgrade')
    {
        j$('.AlternateDocuSignAccountPanel').show();
        return true;
    }
    else{
        j$('.AlternateDocuSignAccountPanel').hide();
        return false;
    }
}

function ValidateEmail(email, message)
{
    var filter = /^([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+.)+([a-zA-Z0-9]{2,4})+$/;
    
    if (!filter.test(email)) { 
        if(message) { j$("#PageMessages").html(message);}
        return false; 
    }
    else { 
        return true; 
    }
}

function SelectContact(SelectedContactId, EmailFieldId, EmailBodyFieldId)
{
    var EmailField = j$("[id$='"+EmailFieldId+"']");
    var SendToDocusignButton = j$("[id$='SendToDocusign']");
    
    DisableElement(EmailField); //.attr("disabled","disabled");
    //SendToDocusignButton.attr("disabled","disabled").addClass("btnDisabled");
    
    if(SelectedContactId != null && SelectedContactId != "")
    {
        DS_SendToDocusign_Extension.SelectContact(SelectedContactId, function(result, event) {
            
            if(result) { 
                EmailField.removeAttr("disabled").val(result.SelectedContact.Email);
                //SendToDocusignButton.removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
                /*var tempElement = j$("[id$='SignInPerson1']");             
                signInPerson(tempElement);
                tempElement = j$("[id$='SignInPerson2']");   
                signInPerson(tempElement);*/
            }
            
        });
    }
    else
    {
        EmailField.removeAttr("disabled").val("");
        //SendToDocusignButton.removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
        /*var tempElement = j$("[id$='SignInPerson1']");             
        signInPerson(tempElement);
        tempElement = j$("[id$='SignInPerson2']");   
        signInPerson(tempElement);*/
    }      
}

function SendPageFieldsToDocusign(event)
{
    (event.preventDefault) ? event.preventDefault() : event.returnValue = false;
    
    // validate and add any CC email that has not been added
    var ccEmail = j$("[id$='ccEmailId']");
    var SharedSystemSellerEmail = j$("[id$='Signer_8_Email']").val();
    var SharedSystemSeller2Email = j$("[id$='Signer_8_2_Email']").val();
    var Signer_1_Email_Element = j$("[id$=Signer_1_Email]");
    var Signer_2_Email_Element = j$("[id$=Signer_2_Email]");
    var SharedSystemSellerTitle = j$("[id$='Signer_8_Title']").val();
    var SharedSystemSeller2Title = j$("[id$='Signer_8_2_Title']").val();
    var SharedSystemSellerFirstName = j$("[id$='Signer_8_FirstName']").val(); 
    var SharedSystemSellerLastName = j$("[id$='Signer_8_LastName']").val(); 
    var SharedSystemSeller2FirstName = j$("[id$='Signer_8_2_FirstName']").val(); 
    var SharedSystemSeller2LastName = j$("[id$='Signer_8_2_LastName']").val(); 
    
    
    var Signer1Email = ValidateEmail(Signer_1_Email_Element.val(), 'The Signer 1 Email address supplied is invalid.');
    var Signer2Email;
    
    if(__TwoSignerRequired == "true")
    {
        Signer2Email = ValidateEmail(Signer_2_Email_Element.val(), 'The Signer 2 Email address supplied is invalid.');
    }
    
    if(!Signer1Email){ /*DisableElement(j$("[id$='SendToDocusign']"));*/ return false;} 
    
    if(!Signer2Email && __TwoSignerRequired != "false"){ /*DisableElement(j$("[id$='SendToDocusign']"));*/ return false;}
    
    if(__SharedSystemAddendum == "true")
    {
        var sellerEmail = ValidateEmail(SharedSystemSellerEmail, null);
        if(SharedSystemSellerEmail != "")
        {
            if(!sellerEmail)
            {
                 j$("#PageMessages").html("Shared System Seller email is not correct"); return false;
            } 
        }
        var seller2Email = ValidateEmail(SharedSystemSeller2Email, null);
        if(SharedSystemSeller2Email != "")
        {
            if(!seller2Email)
            {
                 j$("#PageMessages").html("Shared system seller2 email is not correct"); return false;
            } 
        }
        
        var sharedSystemSellerAllFilled = (
            SharedSystemSellerTitle != "" && 
            SharedSystemSellerFirstName != "" && 
            SharedSystemSellerLastName != "" && 
            sellerEmail == true);
        
        var sharedSystemSeller2AllFilled = (
            SharedSystemSeller2Title != "" && 
            SharedSystemSeller2FirstName != "" && 
            SharedSystemSeller2LastName != "" && 
            seller2Email == true);
        
        if(sharedSystemSellerAllFilled == false && sharedSystemSeller2AllFilled == false)
        {
            j$("#PageMessages").html("At least one Shared System Seller email and details are needed"); return false;
        }
        if(sharedSystemSellerAllFilled == false)
        {
            if(!SharedSystemSeller2FirstName || !SharedSystemSeller2LastName || !SharedSystemSeller2Title || !SharedSystemSeller2Email)
            {
                j$("#PageMessages").html("Shared System Seller 2 email and details are needed"); return false; 
            } 
        }
        if(sharedSystemSeller2AllFilled == false)
        {
            if(!SharedSystemSellerFirstName || !SharedSystemSellerLastName || !SharedSystemSellerTitle || !SharedSystemSellerEmail)
            {
                j$("#PageMessages").html("Shared System Seller email and details are needed"); return false; 
            } 
        }
    }
    
    if(ccEmail && ccEmail.val() && ccEmail.val().length > 0) 
    { 
        var validEmail = ValidateEmail(ccEmail.val(), 'The CC Email address supplied is invalid.');        
        if(validEmail) { addEmail(); }
        else { ToggleForm(true); return; }
    }
    
    // disabled all form elements
    //ToggleForm();
    
    try
    {
        var SelectedListSigner1 = j$("[id$=SelectedListSigner1]").val();
        var SelectedListSigner2 = j$("[id$=SelectedListSigner2]").val();       
        var SignInPerson1 = j$("[id$=SignInPerson1]").is(':checked');
        var Signer_1_Email = Signer_1_Email_Element.val();
        var Signer_2_Email = Signer_2_Email_Element.val();
        var Signer1EmailUpdate = j$("[id$=Signer1EmailUpdate]").is(':checked');
        var SignInPerson2 = j$("[id$=SignInPerson2]").is(':checked');
        var Signer2EmailUpdate = j$("[id$=Signer2EmailUpdate]").is(':checked');
        var OpportunityId = __OpportunityId;
        var EmailBody = j$("[id$=EmailBodyText]").val();
        var Subject = j$("[id$=EmailSubjectText]").val();
        var OverrideSignerId1 = j$("[id$='OverrideSigner1_lkid']").val();
        var OverrideSignerId2 = j$("[id$='OverrideSigner2_lkid']").val();
        
        // for RQ-04760 SivaP 6/25/2015        
        var SharedSystemSellerEmail = j$("[id$='Signer_8_Email']").val();
        
        
        // for RQ-05637 SivaP 2015-10-29
        var SharedSystemSeller2Email = j$("[id$='Signer_8_2_Email']").val();
        
        
        SendToDocusign(
            SelectedListSigner1, SelectedListSigner2, SignInPerson1, Signer_1_Email, 
            Signer_2_Email, Signer1EmailUpdate, SignInPerson2, Signer2EmailUpdate, OpportunityId, 
            EmailBody, Subject, OverrideSignerId1, OverrideSignerId2, SharedSystemSellerFirstName, 
            SharedSystemSellerLastName, SharedSystemSellerEmail, SharedSystemSellerTitle, 
            SharedSystemSeller2FirstName, SharedSystemSeller2LastName, SharedSystemSeller2Email, 
            SharedSystemSeller2Title            
        );  
    }
    catch(ex) { alert(ex.message); }
}

function SendToDocusign(
    SelectedListSigner1, SelectedListSigner2, SignInPerson1, Signer_1_Email, 
    Signer_2_Email, Signer1EmailUpdate, SignInPerson2, Signer2EmailUpdate, 
    OpportunityId, EmailBody, Subject, OverrideSignerId1, OverrideSignerId2,
    SharedSystemSellerFirstName, SharedSystemSellerLastName, SharedSystemSellerEmail, SharedSystemSellerTitle,
    SharedSystemSeller2FirstName, SharedSystemSeller2LastName, SharedSystemSeller2Email, SharedSystemSeller2Title) 
{    
    var FieldPack = {
        selectedListSigner1:SelectedListSigner1, 
        selectedListSigner2:SelectedListSigner2, 
        SignInPerson1:SignInPerson1, 
        Signer_1_Email:Signer_1_Email, 
        Signer_2_Email:Signer_2_Email, 
        Signer1EmailUpdate:Signer1EmailUpdate, 
        SignInPerson2:SignInPerson2, 
        Signer2EmailUpdate:Signer2EmailUpdate, 
        HiddenId:OpportunityId, 
        EmailBody:EmailBody, 
        Subject:Subject,
        OverrideSignerId1:OverrideSignerId1,
        OverrideSignerId2:OverrideSignerId2,
        SharedSystemSellerTitle:SharedSystemSellerTitle,
        SharedSystemSellerFirstName:SharedSystemSellerFirstName,
        SharedSystemSellerLastName:SharedSystemSellerLastName,
        SharedSystemSeller2Title:SharedSystemSeller2Title,
        SharedSystemSeller2FirstName:SharedSystemSeller2FirstName,
        SharedSystemSeller2LastName:SharedSystemSeller2LastName
    }; // 006e0000006AarQ
    
    
    DS_SendToDocusign_Extension.UpdateDocusignFields(
        FieldPack, 
        function(results, event)
        {
            try
            {
                if (event.type == 'exception' || 
                    results.ApexMessages || 
                    results.ApexMessages != null)// || FieldsNotFilledInForSigner1) 
                {
                    j$("#PageMessages").html(results.ApexMessages); 
                    //console.log(event);
                    //alert(results.ApexMessages);
                    return; 
                }
                
                ToggleForm();
                
                var CCRM = "";
                var CCTM = "";
                
                // send data to docusign, use window.location to redirect to Docusign URL
                var CRL = "";
                var firstnameTemp = "";
                var lastnameTemp = "";
                
                //Check if the Signer1 is overridden
                if (results.SignInPerson1 && 
                    overrideSigner1Object.Email!='' && // 2015-04-02 MK - fix spacing, pad 4 spaces
                    overrideSigner1Object.FirstName!='' && 
                    overrideSigner1Object.LastName!='')
                {
                    CCTM += "Signer1~Sign in person;";
                    
                    overrideSigner1Object.LastName = overrideSigner1Object.LastName.replace(/,|'/g,"");
                    overrideSigner1Object.FirstName = overrideSigner1Object.FirstName.replace(/,|'/g,"");
                    
                    Signer1LastName = results.SignerContact1.LastName.replace(/,|'/g,"");
                    Signer1FirstName = results.SignerContact1.FirstName.replace(/,|'/g,"");
                    
                    CRL += ""
                    + "Email~" + overrideSigner1Object.Email + ";"                    
                    + "LastName~" + overrideSigner1Object.LastName + ";"
                    + "FirstName~" + overrideSigner1Object.FirstName + ";"
                    + "SignInPersonName~" + Signer1FirstName + ' ' + Signer1LastName + ';'
                    + "RoutingOrder~1;"
                    + "Role~Signer1";
                    CCRM += "Signer1~Signer1;";   
                }
                else if (
                    results.SignInPerson1 && 
                    results.ADPOpportunityOwnerFirstName != null && // 2015-04-02 MK - fix spacing, pad 4 spaces
                    results.ADPOpportunityOwnerLastName != null && 
                    results.ADPOpportunityOwnerEmail != null)
                {
                    // if sign in person is checked for signer 1 OR signer 2, send the Sign in Person flag for Signer1
                    CCTM += "Signer1~Sign in person;";
                    
                    results.ADPOpportunityOwnerLastName = results.ADPOpportunityOwnerLastName.replace(/,|'/g,"");
                    results.ADPOpportunityOwnerFirstName = results.ADPOpportunityOwnerFirstName.replace(/,|'/g,"");
                    results.SignerContact1.LastName = results.SignerContact1.LastName.replace(/,|'/g,"");
                    results.SignerContact1.FirstName = results.SignerContact1.FirstName.replace(/,|'/g,"");
                    
                    CRL += ""
                    + "Email~" + results.ADPOpportunityOwnerEmail + ";"                    
                    + "LastName~" + results.ADPOpportunityOwnerLastName + ";"
                    + "FirstName~" + results.ADPOpportunityOwnerFirstName + ";"
                    + "SignInPersonName~" + results.SignerContact1.FirstName + ' ' + results.SignerContact1.LastName + ';'
                    + "RoutingOrder~1;"
                    + "Role~Signer1";
                    
                    CCRM += "Signer1~Signer1;"; 
                }
                    else
                    {
                        Signer1LastName = results.SignerContact1.LastName.replace(/,|'/g,"");
                        Signer1FirstName = results.SignerContact1.FirstName.replace(/,|'/g,"");
                        
                        CRL += ""
                        + "Email~" + Signer_1_Email + ";"
                        + "LastName~" + Signer1LastName + ";"
                        + "FirstName~" + Signer1FirstName + ";"
                        + "RoutingOrder~1;"
                        + "Role~Signer1";
                        
                        CCRM += "Signer1~Signer1;";
                    }
                
                //Check if the Signer2 is overridden
                if(results.SignInPerson2 && 
                   overrideSigner2Object.Email!='' && // 2015-04-02 MK - pad 4 spaces
                   overrideSigner2Object.FirstName!='' && 
                   overrideSigner2Object.LastName!='')
                {
                    CCTM += "Signer2~Sign in person;";
                    
                    overrideSigner2Object.LastName = overrideSigner2Object.LastName.replace(/,|'/g,"");
                    overrideSigner2Object.FirstName = overrideSigner2Object.FirstName.replace(/,|'/g,"");
                    
                    Signer2LastName = results.SignerContact2.LastName.replace(/,|'/g,"");
                    Signer2FirstName = results.SignerContact2.FirstName.replace(/,|'/g,"");
                    
                    CRL += ","
                    + "Email~" + overrideSigner2Object.Email + ";"                    
                    + "LastName~" + overrideSigner2Object.LastName + ";"
                    + "FirstName~" + overrideSigner2Object.FirstName + ";"
                    + "SignInPersonName~" + Signer2FirstName + ' ' + Signer2LastName + ';'
                    + "RoutingOrder~2;"
                    + "Role~Signer2";
                    
                    CCRM += "Signer2~Signer2;";   
                }
                else if (results.SignInPerson2 && __UserInfoEmail != "")
                {
                    // if sign in person is checked for signer 1 AND signer 2, send the Sign in Person flag for Signer1 and Signer2
                    CCTM += "Signer2~Sign in person;";
                    
                    lastnameTemp = results.SignerContact2.LastName;
                    lastnameTemp = lastnameTemp.replace(/,/g,"");
                    lastnameTemp = lastnameTemp.replace(/'/g,"");
                    
                    firstnameTemp = results.SignerContact2.FirstName;
                    firstnameTemp = firstnameTemp.replace(/,/g,"");
                    firstnameTemp = firstnameTemp.replace(/'/g,"");
                    
                    CRL += ","
                    + "Email~" + __UserInfoEmail + ";"
                    + "LastName~" + lastnameTemp + ";"
                    + "FirstName~" + firstnameTemp + ";"
                    + "SignInPersonName~" + firstnameTemp + ' ' + lastnameTemp + ';'
                    + "RoutingOrder~2;"
                    + "Role~Signer2";
                    
                    CCRM += "Signer2~Signer2;"; // not needed for sign in person?
                }
                    else
                    {
                        if (results.SignerContact2 && typeof results.SignerContact2 != "undefined" && results.SignerContact2 != null) 
                        {
                            if (Signer_2_Email != null && Signer_2_Email != "" && 
                                results.SignerContact2.hasOwnProperty("LastName") && 
                                results.SignerContact2.hasOwnProperty("FirstName"))
                            {
                                lastnameTemp = results.SignerContact2.LastName;
                                lastnameTemp = lastnameTemp.replace(/,/g,"");
                                lastnameTemp = lastnameTemp.replace(/'/g,"");
                                
                                firstnameTemp = results.SignerContact2.FirstName;
                                firstnameTemp = firstnameTemp.replace(/,/g,"");
                                firstnameTemp = firstnameTemp.replace(/'/g,"");
                                
                                CRL += ","
                                + "Email~" + Signer_2_Email + ";"
                                + "LastName~" + lastnameTemp + ";"
                                + "FirstName~" + firstnameTemp + ";"
                                + "RoutingOrder~2;"
                                + "Role~Signer2";
                                
                                CCRM += "Signer2~Signer2;";
                            }
                        }
                    }
                
                if(results.SignerContact3 && typeof results.SignerContact3 != "undefined" && results.SignerContact3 != null)
                {
                    CRL += ","
                    + "Email~" + results.SignerContact3.Email__c + ";"
                    + "LastName~" + results.SignerContact3.Last_Name__c + ";"
                    + "FirstName~" + results.SignerContact3.First_Name__c + ";"
                    + "RoutingOrder~" + results.SignerContact3.Routing_Order__c + ";"
                    + "Role~"+results.SignerContact3.Signer_Role__c;
                    
                    CCRM += results.SignerContact3.Signer_Role__c+"~"+results.SignerContact3.Signer_Role__c+";";
                }
                
                if(results.SignerContact4 && typeof results.SignerContact4 != "undefined" && results.SignerContact4)
                {
                    CRL += ","
                    + "Email~" + results.SignerContact4.Email__c + ";"
                    + "LastName~" + results.SignerContact4.Last_Name__c + ";"
                    + "FirstName~" + results.SignerContact4.First_Name__c + ";"
                    + "RoutingOrder~" + results.SignerContact4.Routing_Order__c + ";"
                    + "Role~"+results.SignerContact4.Signer_Role__c;
                    
                    // Salesforce Role~DocuSign Role; Signer4~Signer4
                    CCRM += results.SignerContact4.Signer_Role__c+"~"+results.SignerContact4.Signer_Role__c+";";
                }
                
                if(results.SignerContact7 && typeof results.SignerContact7 != "undefined" && results.SignerContact7 != null)
                {
                    CRL += ","
                    + "Email~" + results.SignerContact7.Email__c + ";"
                    + "LastName~" + results.SignerContact7.Last_Name__c + ";"
                    + "FirstName~" + results.SignerContact7.First_Name__c + ";"
                    + "RoutingOrder~" + results.SignerContact7.Routing_Order__c + ";"
                    + "Role~"+results.SignerContact7.Signer_Role__c;
                    
                    CCRM += results.SignerContact7.Signer_Role__c+"~"+results.SignerContact7.Signer_Role__c+";";
                }
                
                if(results.SignerContact5 && typeof results.SignerContact5 != "undefined" && results.SignerContact5)
                {
                    CRL += ","
                    + "Email~" + results.SignerContact5.Email__c + ";"
                    + "LastName~" + results.SignerContact5.Last_Name__c + ";"
                    + "FirstName~" + results.SignerContact5.First_Name__c + ";"
                    + "RoutingOrder~" + results.SignerContact5.Routing_Order__c + ";"
                    + "Role~"+results.SignerContact5.Signer_Role__c;
                    
                    CCRM += results.SignerContact5.Signer_Role__c+"~"+results.SignerContact5.Signer_Role__c+";";
                }
                
                if(results.SignerContact6 && typeof results.SignerContact6 != "undefined" && results.SignerContact6 && results.CreditCheck == true)
                {
                    CRL += ","
                    + "Email~" + results.SignerContact6.Email__c + ";"
                    + "LastName~" + results.SignerContact6.Last_Name__c + ";"
                    + "FirstName~" + results.SignerContact6.First_Name__c + ";"
                    + "RoutingOrder~" + results.SignerContact6.Routing_Order__c + ";"
                    + "Role~"+results.SignerContact6.Signer_Role__c;
                    
                    CCRM += results.SignerContact6.Signer_Role__c+"~"+results.SignerContact6.Signer_Role__c+";";
                }
                
                // Signer8 functionality
                if(SharedSystemSellerFirstName && SharedSystemSellerLastName && SharedSystemSellerEmail)
                {
                    SharedSystemSellerFirstName = SharedSystemSellerFirstName.replace(/,/g,"");
                    SharedSystemSellerFirstName = SharedSystemSellerFirstName.replace(/'/g,"");
                    
                    SharedSystemSellerLastName = SharedSystemSellerLastName.replace(/,/g,"");
                    SharedSystemSellerLastName = SharedSystemSellerLastName.replace(/'/g,"");
                    
                    SharedSystemSellerEmail = SharedSystemSellerEmail.replace(/,/g,"");
                    SharedSystemSellerEmail = SharedSystemSellerEmail.replace(/'/g,"");
                    
                    CRL += ","
                    + "Email~" + SharedSystemSellerEmail + ";"
                    + "LastName~" + SharedSystemSellerLastName + ";"
                    + "FirstName~" + SharedSystemSellerFirstName + ";" 
                    + "RoutingOrder~" + results.SignerContact8.Routing_Order__c + ";"
                    + "Role~"+results.SignerContact8.Signer_Role__c;
                    
                    CCRM += results.SignerContact8.Signer_Role__c+"~"+results.SignerContact8.Signer_Role__c+";";
                }
                
                // Signer8_2 functionality added 2015-10-29 siva.pragada@cdk.com for RQ-05637 SivaP 2015-10-29
                if(SharedSystemSeller2FirstName && SharedSystemSeller2LastName && SharedSystemSeller2Email)
                {
                    SharedSystemSeller2FirstName = SharedSystemSeller2FirstName.replace(/,/g,"");
                    SharedSystemSeller2FirstName = SharedSystemSeller2FirstName.replace(/'/g,"");
                    
                    SharedSystemSeller2LastName = SharedSystemSeller2LastName.replace(/,/g,"");
                    SharedSystemSeller2LastName = SharedSystemSeller2LastName.replace(/'/g,"");
                    
                    SharedSystemSeller2Email = SharedSystemSeller2Email.replace(/,/g,"");
                    SharedSystemSeller2Email = SharedSystemSeller2Email.replace(/'/g,"");
                    
                    CRL += ","
                    + "Email~" + SharedSystemSeller2Email + ";"
                    + "LastName~" + SharedSystemSeller2LastName + ";"
                    + "FirstName~" + SharedSystemSeller2FirstName + ";" 
                    + "RoutingOrder~" + results.SignerContact8_2.Routing_Order__c + ";"
                    + "Role~"+results.SignerContact8_2.Signer_Role__c;
                    
                    CCRM += results.SignerContact8_2.Signer_Role__c+"~"+results.SignerContact8_2.Signer_Role__c+";";
                }
                
                //sanjay.ghanathey@cdk.com 02-Feb-2015 Add Email Ids to CC additional contacts
                for(var i=0; i<ccEmailList.length; i++)
                { 
                    if(ccEmailList[i].Email!=null && ccEmailList[i].Email!='')
                    {                                                       
                        ccEmailList[i].LastName = ccEmailList[i].LastName.replace(/,/g,"");
                        ccEmailList[i].LastName = ccEmailList[i].LastName.replace(/'/g,"");                        
                        ccEmailList[i].FirstName = ccEmailList[i].FirstName.replace(/,/g,"");
                        ccEmailList[i].FirstName = ccEmailList[i].FirstName.replace(/'/g,"");
                        
                        var ccCount = (i+1);
                        
                        CRL += ","
                        + "Email~" + ccEmailList[i].Email + ";"
                        + "LastName~" + ccEmailList[i].LastName  + ";"
                        + "FirstName~" + ccEmailList[i].FirstName  + ";"
                        + "RoutingOrder~1;"                    
                        + "Role~CC" + ccCount;
                        CCRM += "CC" + ccCount +"~CC" + ccCount +";";
                        CCTM += "CC" + ccCount +"~Carbon Copy;";                 
                    }                    
                }
                
                //2015-11-2 siva.pragada@cdk.com added for RQ-05538 DocuSign - need to send completed envelope to CCs and additional contacts
                for(var i=0; i<ccEmailList.length; i++)
                { 
                    if(ccEmailList[i].Email!=null && ccEmailList[i].Email!='')
                    {                                                       
                        ccEmailList[i].LastName = ccEmailList[i].LastName.replace(/,/g,"");
                        ccEmailList[i].LastName = ccEmailList[i].LastName.replace(/'/g,"");                        
                        ccEmailList[i].FirstName = ccEmailList[i].FirstName.replace(/,/g,"");
                        ccEmailList[i].FirstName = ccEmailList[i].FirstName.replace(/'/g,"");
                        
                        var ccCount = (i+1);
                        
                        CRL += ","
                        + "Email~" + ccEmailList[i].Email + ";"
                        + "LastName~" + ccEmailList[i].LastName  + ";"
                        + "FirstName~" + ccEmailList[i].FirstName  + ";"
                        + "RoutingOrder~30;"                    
                        + "Role~CC" + ccCount;
                        CCRM += "CC" + ccCount +"~CC" + ccCount +";";
                        CCTM += "CC" + ccCount +"~Carbon Copy;";                 
                    }                    
                } 
                
                //console.log(CCTM); console.log(CCRM);
                
                var redirect = "" 
                + "/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID=" + (results.DealStateId != null ? encodeURIComponent(results.DealStateId).substr(0,15) : "")
                + "&CRL=" + encodeURIComponent(CRL)
                + "&OCO=Send" // comment out to prevent sending immediately, for debug
                + "&LA=1"
                + "&CEM=" + encodeURIComponent(results.EmailBody)
                + "&CES=" + encodeURIComponent(results.Subject)
                + "&STB=0"
                // Remind Via Email, Remind In N Days, Repeat Remind In N Days, Expire-Void Envelope, Expire-Void Envelope In N Days, Warn Expire Void In N Days. 
                + "&RES=1,2,5,1,180,3"
                + (CCTM ? "&CCTM=" + encodeURIComponent(CCTM) : "")
                + "&CCRM=" + encodeURIComponent(CCRM);
                
                /********************** For DEBUG purposes **********************/
                var redirectUnEncoded = "" 
                + "/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID=" + (results.DealStateId != null ? results.DealStateId.substr(0,15) : "")
                + "&CRL=" + CRL
                + "&OCO=Send" // comment out to prevent sending immediately, for debug
                + "&LA=1"
                + "&CEM=" + results.EmailBody
                + "&CES=" + results.Subject
                + "&STB=0"
                + "&RES=1,2,5,1,180,3"
                + (CCTM ? "&CCTM=" + CCTM : "")
                + "&CCRM=" + CCRM;
                redirectUnEncoded = redirectUnEncoded.replace(/(\r\n|\n|\r)/gm,"");
                console.log(redirectUnEncoded);
                //sanjay.ghanathey@cdk.com 03-Dec-2014 To Update return URL in DealState
                DS_SendToDocusign_Extension.UpdateDocusignReturnURL(
                    __CurrentPageId,
                    redirectUnEncoded,
                    Is_Client_1_Sign_In_Person, // (j$("[id$='SignInPerson1']").is(":checked") ? true : false),
                    function(message, event) { /*can be used for debugging*/ }
                );
                /********************** End DEBUG purposes **********************/
                
                //console.log(redirect);
                window.location.href = redirect;
            }
            catch(ex) { alert(ex.message); log(ex.stack);}
            
            return false;
        }, 
        {escape: true} 
    );
}

function ToggleForm(enable)
{
    var __SelectedListSigner1 = j$("[id$=SelectedListSigner1]").val();   
    
    if(__SelectedListSigner1 != ""){
        var SendToDocusignButton = j$("[id$='SendToDocusign']");
        
        if(!enable) {
            DisableElement(SendToDocusignButton);
            DisableElement(j$("input, select, textarea", "[id$='form1']")); //.attr("disabled","disabled");
        }
        else {          
            EnableElement(SendToDocusignButton);
            DisableElement(j$("input, select, textarea", "[id$='form1']")); //.removeAttr("disabled","disabled");
        }
    }
}

function BypassEnterKey(e)
{
    e = e || event;
    var txtArea = /textarea/i.test((e.target || e.srcElement).tagName);
    return txtArea || (e.keyCode || e.which || e.charCode || 0) !== 13;
}

function AutocompleteSource(request, response) { //log(request);
   
    var search = (request.term && request.term.length > 1 ? request.term : ""); //log(search); 
    
    try {
        DS_SendToDocusign_Extension.searchForUsers(search, function(result, event) { //log(result); //log(event);
            if(result) {
                var AllRecords = j$.map(result, function(item){  
                    var AutocompleteLabel = "";
                    var Fields = ["Name"];
                    j$(Fields).each(function(i,v) { //log(result.Fields);   
                        var AutocompleteField = item;
                       
                        AutocompleteField = item[v]; 
                        
                        AutocompleteLabel += (AutocompleteField ? (AutocompleteLabel != "" ? " - " + AutocompleteField : AutocompleteField) : ""); 
                    });
                    
                    var mapResults = {
                        label: ConvertSpecialCharacters(AutocompleteLabel),
                        sfid: item.Id,
                        Email: item.Email,
                        FirstName: item.FirstName,
                        LastName: item.LastName
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
                        j$("#SearchYourUser").css("background", "transparent");
                    }
                }
            }
        });
    } 
    catch (error) {
        DisplayUnexpectedError(error);
    }

}

function SelectYourUser(e1, ui)
{    
    //log(ui);
    j$("[id$='ccEmailId']").val(ui.item.Email);
    j$("[id$='ccFirstName']").val(ui.item.FirstName);
    j$("[id$='ccLastName']").val(ui.item.LastName);
   
}

function DisableElement(jElement)
{
    jElement.attr("disabled","disabled");
    if(isButton(jElement)) { jElement.addClass('btnDisabled'); }
}

function EnableElement(jElement)
{  
    jElement.removeAttr("disabled");
    if(isButton(jElement)) { jElement.removeClass('btnDisabled').addClass('btn'); }
}

function isButton(jElement)
{
    if(
        (jElement.is("input") && (jElement.attr("type") == "button" || jElement.attr("type") == "submit")) || 
        jElement.is("button")
    ) {
        return true;
    }
    else {
        return false;
    }
}

function DisplayUnexpectedError(error)
{
    //log(error);
    
    MessageBox("Error", "An unexpected error occurred. "
        + "There may be a number of causes such as the Salesforce session expiring. " 
        + "It is recommended to refresh your browser by clicking the Refresh button below. ", 
        {"Refresh":function(){window.location=window.location;}});
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

function ConvertSpecialCharacters(text)
{
    var t = document.createElement("div");
    t.innerHTML = text;
    var result = t.childNodes[0].nodeValue;
    t.removeChild(t.firstChild)
    return result;
}

function getTheContact(ContactId)
{
    DS_SendToDocusign_Extension.getTheContact(ContactId, function(result, event) {
       
        //log(result);
        
        if(result)
        {
            j$("[id$='ccEmailId']").val(result.Email);
            j$("[id$='ccFirstName']").val(result.FirstName);
            j$("[id$='ccLastName']").val(result.LastName);
        }
    });
}

function log(obj)
{
   // console.log(obj);
}



