/*----------------------------------------------------------------------
 * RQ-06791 BankofAmerica
 * vijay.manimaran@cdk.com - created this class  
 * 
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-09-19 Vijay.manimaran@cdk.com  Updated logic 
  ------------------------------------------------------------------------*/

if (!j$) {
    j$ = jQuery.noConflict();
}

var visiblecard;
var hidecard1;
var hidecard2;
var hidecard3;
var locationId;

function visiblecards(showcards) {
    /*if (showcards == 'false') {
        j$("#Newtravel").attr("class", "col-md-6 box box-md fade-in one content bkg-pattern");
        j$("#Pcardincblock").attr("class", "col-md-6 box box-md fade-in one content bkg-pattern");
        j$("#Pcardblock").attr("id", "#disable");
    }*/
}

j$(".progress-wrapper").hide();
function hidecards(visiblecard, hidecard1, hidecard2, hidecard3) {
    j$(visiblecard).attr("style", "background-image: url('/resource/1472611765000/CDK_Patterns/Patterns/Backgrounds/Tread1.png');");
    j$(hidecard1).attr("style", "background: #e6e2e2;opacity: 0.5");
    j$(hidecard2).attr("style", "background: #e6e2e2;opacity: 0.5");
    j$(hidecard3).attr("style", "");
	j$("#Pcardblockemail").hide();

    if (hidecard3 == "") {
        j$("#Mainform").hide();
    }
}

var fieldId;
function allowOnlyNumber(fieldId) {
    j$("fieldId").keypress(function(e) {
        //if the letter is not digit then display error and don't type anything
        if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
            //display error message
            j$("#errmsg").html("Digits Only").show().fadeOut("slow");
            return false;
        }
    });
    
}
var selectedmainId;
var travelPolicyAck;
var termsAck;
var Pcards;
var Smmps;
function ackpolicy() {

    j$(".progress-wrapper").show();
    var ackpolicyname = j$("[id$='AcknowledgementvalId']").val();
    EMP_BankofAmerica_Controller.Acknowledgment(ackpolicyname, function(result, event) 
	{
        if (event.status)
		 {
            if (result == 'success') 
			{
                j$("[id$='AckModal']").attr('style', 'display:none;');
                j$('#' + ackpolicyname).attr("disabled", "disabled");
                j$(".progress-wrapper").hide();
           

				if(selectedmainId == 'newTravelCard')
				{
				    travelPolicyAck = j$("#TravelPolicy").attr("disabled");
					termsAck = j$("#Termscondition").attr("disabled");
					if(travelPolicyAck == 'disabled' && termsAck == 'disabled')
					{
						j$("#completeForm").show();
					}
				}
				else if(selectedmainId == 'Pcard')
				{
				console.log('inside pcard ack');
					Pcards = j$("#Pcards").attr("disabled");		
					termsAck = j$("#Termscondition").attr("disabled");
					Smmps = j$("#Smmp").attr("disabled");
					if(Pcards == 'disabled' && termsAck == 'disabled' && Smmps == 'disabled')
					{
						j$("#completeForm").show();
					}

				}

               /* if (selectedmainId == 'newTravelCard' && travelPolicyAck == 'disabled' && termsAck == 'disabled') 
				{
                    j$("#completeForm").show();
                }
				*/
			}
            
        } 
		else 
		{
            j$(".progress-wrapper").hide();
        }
    });
}

function newdialogbox(temptext) {
    var newDiv = j$(document.createElement('div'));
    newDiv.html(temptext);
    newDiv.dialog({
        minwidth: 220,
        minheight: 230,
        modal: true,
        dialogClass: "no-close",
        buttons: [{
            text: "OK",
            click: function() {
                j$(this).dialog("close");
            }
        }]
    });
}
// on submit for manager approval 
function doUiCheck() {
    var errorcheck = false;
    console.log(cardsel);
    if (cardsel == 'newTravelCard' || cardsel == 'Pcard') {
        
        if (j$("[id$='state'] :selected").val() == '--None--' || j$("[id$='state'] :selected").val() == '' ) {
            newdialogbox('Required fields must be completed');
            errorcheck = true;
            return;
        }
        
        if ((j$("[id$='Nameoncard']").val() && j$("[id$='addressline1']").val() && j$("[id$='city']").val() && j$("[id$='zipcode']").val() && j$("[id$='birthDate']").val() && j$("[id$='Phone']").val()) == '') {
            newdialogbox('Required fields must be completed');
            errorcheck = true;
            return;
        }
    } else if (cardsel == 'PcardInc') {
        if ((j$("[id$='endDate']").val() || j$("[id$='beginningdate']").val() || j$("[id$='incJud']").val() || j$("[id$='dateInc']").val() || j$("[id$='currency']").val() || j$("[id$='cardType']").val()) == '') {
            newdialogbox('Required fields must be completed');
            errorcheck = true;
            return;
        }
        if(j$("[id$='beginmonthvalue'] :selected").val() == '' || j$("[id$='begindatevalue'] :selected").val() == '' || j$("[id$='beginyearvalue'] :selected").val() == '' || j$("[id$='endmonthvalue'] :selected").val() == '' || j$("[id$='enddatevalue'] :selected").val() == '' || j$("[id$='endyearvalue'] :selected").val() == ''){		
            newdialogbox('Required fields must be completed');
            errorcheck = true;
            return;
        }
    }
    
    
    
    if (errorcheck == true) {
        return;
    }
    
    j$(".progress-wrapper").show();
    var x = submitforApporval();
    j$("[id$='dialog']").dialog({
        minwidth: 220,
        minheight: 230,
        modal: true,
        dialogClass: "no-close",
        buttons: [{
            text: "OK",
            click: function() {
                window.location = "/Employees";
            }
        }]
    });
}

var cardsel;

// Enable Acknowledgment buttons
function activatePolicies() {
    j$(".progress-wrapper").hide();
    j$("[id$='TravelPolicy']").removeAttr("disabled");
    j$("[id$='Pcards']").removeAttr("disabled");
    j$("[id$='Smmp']").removeAttr("disabled");
    j$("[id$='Termscondition']").removeAttr("disabled");
}


function deletePolicies() {
    EMP_BankofAmerica_Controller.deletePolicies(function(result, event) {
        j$(".progress-wrapper").show();
        j$("#completeForm").hide();
        
        if (event.status) {
            if (result == 'success') {
                activatePolicies();
            } else {
                activatePolicies();
                j$(".progress-wrapper").hide();
                
            }
        }
    });
}

// same elements used for 3 cards 
function duplicateElements() {
    j$(".progress-wrapper").show();
    j$("[id$='managerApproval']").html("Submit");
    j$("#Mainform").show();
    j$("[id$='addressTooltip']").html("*CDK recommends using your home address to complete this form. This address is only used for the Bank of America card you are requesting. It will NOT update your CDK Address on file.<br /> Your new corporate card and corresponding PIN will be mailed to the address provided. Bank of America will validate to this address / zip code when purchases require zip code for validation, such as fuel purchases.");
    
    if (selectedmainId != 'PcardInc') {
        deletePolicies();
    } else {
        j$("#completeForm").show();
        j$(".progress-wrapper").hide();
    }
}

function init() {
    j$(".datepicker").datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange: "-125:-18", // last hundred years
    });
    
    j$("[id$='birthDate']").attr("readonly", "readonly");
    j$("#completeForm").hide();
    j$("#cardCheckDialog").hide();
    
    j$(document).keypress(function(e) {
        if (e.which == 13 && e.target.nodeName != "TEXTAREA")
            return false;
    });
    
    j$("[id$='Nameoncard']").bind('keypress', function(event) {
        var regex = new RegExp("^[a-zA-Z0-9., &-]+$");
        var key = String.fromCharCode(!event.charCode ? event.which : event.charCode);
        if (!regex.test(key)) {
            event.preventDefault();
            return false;
        }
    });
    
    
    
    j$("#locations").hide();
    j$("#Policies").hide();
    var selectedId;
    if (__showcards) {
        visiblecards(__showcards);
    }
    
    EMP_BankofAmerica_Controller.deletePolicies(function(result, event) {
        if (event.status) {
            if (result == 'success') {
            }
        }
    });
    j$("[id$='currency']").keyup(function(event) {
        
        // skip for arrow keys
        if (event.which >= 37 && event.which <= 40) return;
        
        // format number
        j$(this).val(function(index, value) {
            return value
            .replace(/\D/g, "")
            .replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        });
    });
    
    function dialogboxmessage() {
        j$("[id$='cardCheckDialog']").dialog({
            
            minwidth: 220,
            minheight: 230,
            modal: true,
            dialogClass: "no-close",
            buttons: [{
                text: "OK",
                click: function() {
                    window.location = "/Employees";
                }
            }]
        });
    }
    
    
    //Main three post cards code starts
    j$('#newTravelCard').click(function() {
        selectedmainId = j$(this).attr("id");
        j$("#locations").fadeIn("slow");
        hidecards("#Newtravel", "#Pcardblock", "#Pcardincblock", "");
        cardsel = selectedmainId;
        
        EMP_BankofAmerica_Controller.checkCardRequested(selectedmainId, function(result, event) {
            if (event.status) {
                if (result == 'failurevendor') {
                    j$("[id$='cardCheckDialog']").html("Sorry, VendorId missing cannot request the Card.");
                    dialogboxmessage();
                }
                if (result == 'failurecontractor') {
                    j$("[id$='cardCheckDialog']").html("Sorry, Contractors cannot request the Card.");
                    dialogboxmessage();
                }
                
                if (result == 'failure') {
                    j$("#locations").hide();
                    dialogboxmessage();
                } else {
                    j$(".progress-wrapper").hide();
                }
            }
        });
    });
    
    j$('#Pcard').click(function() {
        selectedmainId = j$(this).attr("id");
        hidecards("#Pcardblock", "#Newtravel", "#Pcardincblock", "");
        j$("#locations").fadeIn("slow");
        cardsel = selectedmainId;
		
          EMP_BankofAmerica_Controller.checkCardRequested(selectedmainId, function(result, event) {
            if (event.status) {
                if (result == 'failurevendor') {
                    j$("[id$='cardCheckDialog']").html("Sorry, VendorId missing cannot request the Card.");
                    dialogboxmessage();
                }
                if (result == 'failurecontractor') {
                    j$("[id$='cardCheckDialog']").html("Sorry, Contractors cannot request the Card.");
                    dialogboxmessage();
                }
                
                if (result == 'failure') {
                    j$("#locations").hide();
                    dialogboxmessage();
                } else {
                    j$(".progress-wrapper").hide();
                }
            }
        });
    });
    
    j$('#PcardInc').click(function() {
        hidecards("#Pcardincblock", "#Pcardblock", "#Newtravel", "");
        selectedmainId = j$(this).attr("id");
        j$("[id$='Mainform']").show();
        j$("[id$='registerForm']").hide();
        j$("[id$='inclimitform']").show();
        j$("[id$='Policies']").hide();
        j$("[id$='completeForm']").show();
        j$("[id$='locations']").hide();
        cardsel = selectedmainId;
		j$("[id$='hiddenvalue']").val(selectedmainId);

    });
    
    
    
    //Main three post cards code end
    
    // location code starts here
    j$("[id$='location']").click(
        
        function() {
            
            j$(".numericField").keypress(function(e) {
                //if the letter is not digit then display error and don't type anything
                if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
                    //display error message
                    j$("#errmsgs").html("Digits Only").show().fadeOut("slow");
                    return false;
                }
            });
            
            locationId = j$(this).attr("id");
            j$("#locations").show();
            j$("#inputformfields").show();
            j$("[id$='country']").prop("disabled", true);
            j$("[id$='manager']").prop("disabled", true);
            j$("[id$='hiddenvalue']").val(selectedmainId);
            j$(this).css("opacity", "50");
            
            if (locationId == 'uslocation') {
                //console.log('Am inside uslocation now');	
                hidecards("", "#frenchlocation", "#canadalocation", "#uslocation");
                j$("[id$='country']").val("USA");
                duplicateElements();
                //zip code validation 
                j$("[id$='zipcode']").keypress(function(e) {
                    //if the letter is not digit then display error and don't type anything
                    if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
                        //display error message
                        j$("#errmsg").html("Digits Only").show().fadeOut("slow");
                        return false;
                    }
                });
            }
            
            if (locationId == 'canadalocation') {
                hidecards("", "#frenchlocation", "#uslocation", "#canadalocation");
                j$("[id$='country']").val("Canada");
                duplicateElements();
            }
            
            if (locationId == 'frenchlocation') {
                j$(".progress-wrapper").show();
                duplicateElements();
                hidecards("", "#canadalocation", "#uslocation", "#frenchlocation");
                j$("[id$='country']").val("Canada");
                j$("[id$='managerApproval']").html("Approbation");
                j$("[id$='Nameoncard']").attr("title", "Le nom apparaissant sur la carte doit correspondre à votre ID fourni par le gouvernement.");
                j$("[id$='addressTooltip']").html("CDK recommande d’utiliser l’adresse de votre domicile sur ce formulaire.<br/>Cette adresse n’est utilisée que pour la carte Bank of America qui fait l’objet de votre demande. L’adresse inscrite dans votre dossier CDK demeurera inchangée.<br/>Une case postale n’est pas admissible. <br/>Votre nouvelle carte d’entreprise et le NIP correspondant vous seront mis à la poste à l’adresse fournie.<br/>La validation de la Bank of America s’effectuera à cette adresse/ce code postal, lorsqu’un achat requerra un code postal de validation, pour un achat d’essence par exemple.<br/>");
                j$("[id$='birthinfo']").attr("title", "*La date de naissance (DDN) du détenteur de la carte est requise pour permettre à la BofAML de pouvoir scanner correctement les données du client et de les comparer au contenu pertinent des sanctions économiques. Nous vous assurons que les renseignements sur le détenteur de la carte demeureront confidentiels conformément à la politique sur les renseignements confidentiels de la Bank of America Merrill Lynch (www.bankofamerica.com/privacy).");
                
            }
            console.log(cardsel);
            if (selectedmainId == 'PcardInc') {
                j$("#inclimitform").show();
            }
            
            if (selectedmainId == 'newTravelCard') {
                j$("[id$='Nameoncard']").val(j$("[id$='employeeName']").text());
                j$("#Policies").show();
                j$('#registerForm').show();
                j$("#TravelPolicy").show();
                j$("#Pcards").hide();
                j$("#Smmp").hide();
                j$("#inclimitform").hide();
            }
            
            if (selectedmainId == 'Pcard') {
                j$("[id$='Nameoncard']").val(j$("[id$='employeeName']").text());
                j$("#Policies").show();
                j$("#Pcards").show();
                j$("#Smmp").show();
                j$("#inclimitform").hide();
                j$("#TravelPolicy").hide();
                
            }
            
            if (selectedmainId == 'PcardInc') {
                j$("#Policies").hide();
                j$("[id$='completeForm']").show();
                j$("#inclimitform").show();
                j$('#registerForm').hide();
                //Last Validation 
                
                
            }
        });
    // location code ends here
    
    //Acknowledgement policy button code starts
    j$('#TravelPolicy').click(
        function() {
            selectedId = j$(this).attr("id");
            j$("[id$='PolicyType']").html(selectedId);
            j$("[id$='AcknowledgementvalId']").val(selectedId);
            
            if (locationId == 'uslocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002J8JdAAK");
                j$("[id$='Acknowledgetext']").html("I certify that I have read, understand, and agree to abide by the terms and conditions of CDK\’s T&amp;E Policy. I understand that my failure to abide by CDK Global\’s Travel and  Expense Policy may result in disciplinary action up to and including termination.");
            }
            
            if (locationId == 'canadalocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002J8JdAAK");
                j$("[id$='Acknowledgetext']").html("I certify that I have read, understand, and agree to abide by the terms and conditions of CDK\’s T&amp;E Policy. I understand that my failure to abide by CDK Global\’s Travel and  Expense Policy may result in disciplinary action up to and including termination.");
            }
            
            if (locationId == 'frenchlocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002J8JdAAK");
                j$("[id$='Acknowledgetext']").html("Je certifie que j\’ai lu et compris les modalités et conditions de la politique relative aux frais de représentation de CDK et je conviens de les respecter. Je comprends que le non-respect de la politique relative aux frais de représentation de CDK peut entraîner des mesures disciplinaires pouvant aller jusqu\’au licenciement.");
            }
        });
    
    j$('#Pcards').click(
        function() {
            selectedId = j$(this).attr("id");
            j$("[id$='PolicyType']").html(selectedId);
            j$("[id$='AcknowledgementvalId']").val(selectedId);
            
            if (locationId == 'uslocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002HOAYAA4");
                j$("[id$='Acknowledgetext']").html("I certify that I have read, understand, and agree to abide by the terms and conditions of CDK\’s P-Card and SMMP Policy. I understand that my failure to abide by CDK’s P-Card and SMMP Policy may result in disciplinary action up to and including termination.");
            }
            
            if (locationId == 'canadalocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002HOAYAA4");
                j$("[id$='Acknowledgetext']").html("I certify that I have read, understand, and agree to abide by the terms and conditions of CDK\’s P-Card and SMMP Policy. I understand that my failure to abide by CDK’s P-Card and SMMP Policy may result in disciplinary action up to and including termination.");
            }
            
            if (locationId == 'frenchlocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002HOAYAA4");
                j$("[id$='Acknowledgetext']").html("Je certifie que j\’ai lu et compris les modalités et conditions de la Politique relative à la carte d\’approvisionnement de CDK et Politique relative aux réunions de CDK  et je conviens de les respecter. Je comprends que le non-respect de la politique relative aux frais de représentation de CDK peut entraîner des mesures disciplinaires pouvant aller jusqu\’au licenciement.");
            }
        });
    
	 j$('#Smmp').click(
        function() {
            selectedId = j$(this).attr("id");
            j$("[id$='PolicyType']").html(selectedId);
            j$("[id$='AcknowledgementvalId']").val(selectedId);
            
            if (locationId == 'uslocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000001uwmMAAQ");
                j$("[id$='Acknowledgetext']").html("I certify that I have read, understand, and agree to abide by the terms and conditions of CDK\’s P-Card and SMMP Policy. I understand that my failure to abide by CDK’s P-Card and SMMP Policy may result in disciplinary action up to and including termination.");
            }
            
            if (locationId == 'canadalocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000001uwmMAAQ");
                j$("[id$='Acknowledgetext']").html("I certify that I have read, understand, and agree to abide by the terms and conditions of CDK\’s P-Card and SMMP Policy. I understand that my failure to abide by CDK’s P-Card and SMMP Policy may result in disciplinary action up to and including termination.");
            }
            
            if (locationId == 'frenchlocation') {
                j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000001uwmMAAQ");
                j$("[id$='Acknowledgetext']").html("Je certifie que j\’ai lu et compris les modalités et conditions de la Politique relative à la carte d\’approvisionnement de CDK et Politique relative aux réunions de CDK  et je conviens de les respecter. Je comprends que le non-respect de la politique relative aux frais de représentation de CDK peut entraîner des mesures disciplinaires pouvant aller jusqu\’au licenciement.");
            }
        });

    j$('#Termscondition').click(function() {
        selectedId = j$(this).attr("id");
        j$("[id$='PolicyType']").html(selectedId);
        j$("[id$='AcknowledgementvalId']").val(selectedId);
        
        if (locationId == 'uslocation') {
            j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002HIjsAAG");
            j$("[id$='Acknowledgetext']").html("By clicking ‘I Acknowledge’ you acknowledge that you have read and understand this Agreement, and you agree to the terms of this Agreement.");
        }
        if (locationId == 'canadalocation') {
            j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002HIiVAAW");
            j$("[id$='Acknowledgetext']").html("By clicking ‘I Acknowledge’ you acknowledge that you have read and understand this Agreement, and you agree to the terms of this Agreement.");
        }
        if (locationId == 'frenchlocation') {
            j$("#Documentviewer").attr("src", "Employees/apex/EMP_Content?DocumentId=06833000002HIiQAAW");
            j$("[id$='Acknowledgetext']").html("En cliquant ‘I Acknowledge’ vous convenez que vous avez lu et compris le présent accord, et que vous en acceptez les modalités.");
        }
    });
    
    //Acknowledgement policy button code ends
    function afterAck() {
        if (travelPolicyAck == 'disabled' && termsAck == 'disabled') {
            j$("#completeForm").show();
        }
    }
} 