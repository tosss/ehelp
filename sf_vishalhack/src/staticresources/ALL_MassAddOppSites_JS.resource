//2017-04-25- anirudh.singh@cdk.com- Created this JS for RQ-09132 Merge Add Opportunity Sites Pages & Functionality.
//2017-05-23- anirudh.singh@cdk.com- Modified createSiteRecords function to close Mass Add page on Save and redirect to Opp Page for RQ-09335.
var j$=jQuery.noConflict();

//Processing on Ready event of the document.
j$(document).ready(
    function()
    {
        processOnLoad();
    }
);

//This method is invoked from the on Ready event of the document.
function processOnLoad()
{
    processHyperLinks();
    
    processExistingAccountSites();
    
    //2017-04-20- anirudh.singh@cdk.com- Added the below line for RQ-09077.
    disableCheckboxesForNoPartyIdAccs();
    
    enableDisableHeaderCheckboxAndSaveButton();
    
    fetchManuallyAddedSites();
    
    backToTopButton();
    
    j$('.loadingSpinnerDiv').hide();
}

//Processing Hyper Links.
function processHyperLinks()
{
    var linkElements=j$('.massCreateOpportunitySitesPage').find('a[class!="scrollToTop"]');
    linkElements.each(function()
	{
        var href=j$(this).prop('href');
        var innerText=j$(this).prop('innerText');
        
        var anchorElement=j$('<a></a>'). prop('href', href).prop('innerText', innerText).prop('target', '_blank');
        j$(this).replaceWith(anchorElement);
    });
}

//Processing Existing Account Sites for adding the Titles used in bootstrap tooltips.
function processExistingAccountSites()
{
    var accIdsWithExistingSites=j$('.accountIdsWithExistingSites').prop('value').replace('{', '').replace('}', '').split(',');
    accIdsWithExistingSites=accIdsWithExistingSites.map(function(value)
	{
        var rowValue=value.trim();
        var indexOfEqualsTo=rowValue.indexOf('=');
        var accountId=rowValue.substring(0, indexOfEqualsTo);
        return accountId;
    });
    
    j$('.bodyRow').each(function()
	{
        var bodyRowAccountId=j$(this).find('.accountId').prop('value');
        if(accIdsWithExistingSites.indexOf(bodyRowAccountId)>-1)
        {
            j$(this).find('.tableCheckbox').prop('title', 'Site already existing.');
            j$(this).find('.bodyRowCheckbox').prop('disabled', 'true');
            j$(this).find('.homeIcon').show();
        }
        else
        {
            j$(this).find('.homeIconColumn').prop('title', '');
            j$(this).find('.homeIcon').hide();
        }
    });
}

//Enabling or Disabling Header Checkbox And Save Button.
function enableDisableHeaderCheckboxAndSaveButton()
{
    var noOfActiveBodyRowCheckboxes=0;
    j$('.bodyRowCheckbox').each(function()
	{
        if(j$(this).prop('disabled')==false)
        {
            noOfActiveBodyRowCheckboxes++;
        }
    });
    
    if(noOfActiveBodyRowCheckboxes==0)
    {
        j$('.headerRowCheckbox').hide();
        j$('.headerRowCheckbox').prop('checked', '');
        j$('.headerRowCheckboxIcon').show();
        
        j$('.saveButton').each(function()
		{
            j$(this).prop('disabled', 'true');
        });
    }
    else
    {
        j$('.headerRowCheckbox').show();
        j$('.headerRowCheckbox').prop('checked', '');
        j$('.headerRowCheckboxIcon').hide();
        
        j$('.saveButton').each(function()
		{
            j$(this).prop('disabled', '');
        });
    }
}

//Fetching Manually Added Sites.
function fetchManuallyAddedSites()
{
    var accIdsManuallyAdded=fetchManuallyAddedAccIds();
    
    if(accIdsManuallyAdded.length>0)
    {
        var accColumnsToBeFetched='';
        var colNameLabelMap=[];
        j$('.colNameLabelTh').each(function()
        {
            var colName=j$(this).find('.colName').prop('value');
            var colLabel=j$(this).prop('outerText');
            accColumnsToBeFetched+=(accColumnsToBeFetched=='') ? colName : (', '+colName);
            
            var colNameLabel={};
            colNameLabel['columnName']=colName;
            colNameLabel['columnLabel']=colLabel;
            colNameLabelMap.push(colNameLabel);
        });
        
        fetchManuallyAddedSitesFunction(JSON.stringify(accIdsManuallyAdded), accColumnsToBeFetched, JSON.stringify(colNameLabelMap));
    }
}

//Fetching Manually Added Sites Account Ids.
function fetchManuallyAddedAccIds()
{
    var accHierarchyAccountIds=[];
    j$('.accountId').each(function()
	{
        var bodyRowAccountId=j$(this).prop('value');
        accHierarchyAccountIds.push(bodyRowAccountId);
    });
    
    var accIdsWithExistingSites=j$('.accountIdsWithExistingSites').prop('value').replace('{', '').replace('}', '').split(',');
    accIdsWithExistingSites=accIdsWithExistingSites.map(function(value)
	{
        var rowValue=value.trim();
        var indexOfEqualsTo=rowValue.indexOf('=');
        var accountId=rowValue.substring(0, indexOfEqualsTo);
        return accountId;
    });
    
    var accIdsManuallyAdded=[];
    accIdsWithExistingSites.map(function(accIdWithSite)
	{
        if(accHierarchyAccountIds.indexOf(accIdWithSite)==-1)
        {
            accIdsManuallyAdded.push(accIdWithSite);
        }
    });
    
    return accIdsManuallyAdded;
}

//2017-04-20- anirudh.singh@cdk.com- Added the below method for disabling checkboxes for Accounts having no Party Id.
function disableCheckboxesForNoPartyIdAccs()
{
    j$('.accountId').each(function()
	{
        var thisAccRow=j$(this);
        if(thisAccRow.data('accpartyid')=='' || thisAccRow.data('accpartyid')==undefined || thisAccRow.data('accpartyid')==null)
        {
            var tableCheckboxEl=thisAccRow.closest('.bodyRow').find('.tableCheckbox');
            tableCheckboxEl.find('input').prop('disabled', 'true');
            if(tableCheckboxEl.prop('title')=='' || tableCheckboxEl.prop('title')==undefined || tableCheckboxEl.prop('title')=='')
            {
                tableCheckboxEl.prop('title', 'Site is not synchronized with Oracle.');
            }
        }
    });
}

//This is getting invoked from actionFunction.
function processingForManuallyAddedSites()
{
    processHyperLinks();
}

//Checking unchecking row checkboxes when Header checkbox is checked unchecked.
function headerRowCheckboxSelect(checkboxElement)
{
    if(j$(checkboxElement).prop('checked')==true)
    {
        j$('.bodyRowCheckbox').each(function()
		{
            if(j$(this).prop('disabled')==false)
            {
                j$(this).prop('checked', 'true');
            }
        });
    }
    else
    {
        j$('.bodyRowCheckbox').each(function()
		{
            if(j$(this).prop('checked')==true)
            {
                j$(this).prop('checked', '');
            }
        });
    }
}

//Checking unchecking header checkboxe when body row checkbox is checked unchecked.
function bodyRowCheckboxSelect()
{
    var noOfBodyRowCheckboxesChecked=0;
    var totalNoOfActiveBodyRowCheckboxes=0;
    
    j$('.bodyRowCheckbox').each(function()
	{
        if(j$(this).prop('checked')==true)
        {
            noOfBodyRowCheckboxesChecked++;
        }
        
        if(j$(this).prop('disabled')==false)
        {
            totalNoOfActiveBodyRowCheckboxes++;
        }
    });
    
    if(noOfBodyRowCheckboxesChecked==totalNoOfActiveBodyRowCheckboxes)
    {
        j$('.headerRowCheckbox').prop('checked', 'true');
    }
    else
    {
        j$('.headerRowCheckbox').prop('checked', '');
    }
}

//Performing validations on click of Save Button and displaying error, info, success messages.
//And creating Site records.
function createSiteRecords()
{
    var selectedAccountIds=[];
    
    var noOfSelectedBodyRowCheckboxes=0;
    var noOfActiveBodyRowCheckboxes=0;
    j$('.bodyRowCheckbox').each(function()
	{
        if(j$(this).prop('checked')==true)
        {
            var accountId=j$(this).closest('.bodyRow').find('.accountId').prop('value');
            selectedAccountIds.push(accountId);
            noOfSelectedBodyRowCheckboxes++;
        }
        
        if(j$(this).prop('disabled')==false)
        {
            noOfActiveBodyRowCheckboxes++;
        }
    });
    
    var messageDivElement=j$('.messageDiv');
    
    if(noOfSelectedBodyRowCheckboxes==0 && noOfActiveBodyRowCheckboxes>=1)
    {
        displayMessage('info', messageDivElement, 'Please select <b>atleast one</b> row to add Site(s) and then click <b>Save</b>.');
    }
    else
    {
        messageDivElement.html('');
        messageDivElement.hide();
        j$('.loadingSpinnerDiv').show();
        
        var opportunityId=j$('.opportunityRecord').prop('value');
        ALL_MassCreateOppSites_Extension.createOpportunitySites(selectedAccountIds, opportunityId, function(result, event)
		{
            var accountNames='';
            if(event.status)
            {
                if(Object.keys(result).length==0)
                {
                    var noOfRecordsSuccessful=0;
                    
                    j$('.bodyRow').each(function()
					{
                        var bodyRowAccountId=j$(this).find('.accountId').prop('value');
                        if(selectedAccountIds.indexOf(bodyRowAccountId)>-1)
                        {
                            
                            var accName='<b>'+j$(this).find('.accountName').find('a').prop('innerText')+'</b> ';
                            accountNames+=(accountNames=='') ? accName : ', '+accName;
                            noOfRecordsSuccessful++;
                        }
                    });
                    
                    enableDisableHeaderCheckboxAndSaveButton();
                    
                    displayMessage('success', messageDivElement, 'Site record(s) successfully created for '+noOfRecordsSuccessful+' account(s): '+accountNames);
                    //2017-05-23- anirudh.singh@cdk.com- Commented the below line and added line to invoke redirectBackToOppPage.
                    //location.reload();
                    redirectBackToOppPage();
                    j$('.loadingSpinnerDiv').hide();
                }
                else
                {
                    var noOfRecordsUnSuccessful=0;
                    
                    j$('.bodyRow').each(function()
					{
                        var bodyRow=j$(this);
                        j$.each(result, function(key, value)
						{
                            var bodyRowAccountId=bodyRow.find('.accountId').prop('value');
                            if(key==bodyRowAccountId)
                            {
                                var errorIconDivElement=bodyRow.find('.errorIconDiv');
                                var errorIconElement='<i class="fa fa-exclamation-triangle errorIcon" aria-hidden="true" title="'+value+'"></i>';
                                errorIconDivElement.replaceWith(errorIconElement);
                                
                                var accName='<b>'+j$(this).find('.accountName').find('a').prop('innerText')+'</b> ';
                                accountNames+=(accountNames=='') ? accName : ', '+accName;
                                noOfRecordsUnSuccessful++;
                            }
                        });
                    });
                    
                    displayMessage('error', messageDivElement, 'Site record(s) could not be created for '+noOfRecordsUnSuccessful+' account(s): '+accountNames+'. Please contact your System Administrator.');
                    
                    j$('.loadingSpinnerDiv').hide();
                }
            }
			else 
            {
                displayMessage('error', messageDivElement, 'Sorry, Site record(s) could not be created for account(s): '+accountNames+'. Please contact your System Administrator.');
                j$('.loadingSpinnerDiv').hide();
            }
        });
    }
}

//Processes error, info and success messages.
function displayMessage(scenario, messageDivElement, messageText)
{
    var alertMessage;
    if(scenario=='success')
    {
        alertMessage='<div class="slds-notify slds-theme--success alertMessage" role="alert">'
        +'<strong>Success!</strong> ';
    }
    else if(scenario=='info')
    {
        alertMessage='<div class="slds-notify alertMessage" role="alert">'
        +'<strong>Note!</strong> ';
    }
    else if(scenario=='error')
    {
        alertMessage='<div class="slds-notify slds-theme--error alertMessage" role="alert">'
        +'<strong>Error!</strong> ';
    }
    
    alertMessage+=messageText;
    alertMessage+='</div>';
    
    messageDivElement.html(alertMessage);
    messageDivElement.show();
}

//This is invoked from Cancel button to redirect back to the opportunity page.
function redirectBackToOppPage()
{
    var opportunityId=j$('.opportunityRecord').prop('value');
    window.location.replace('/' + opportunityId);
}

//Displaying Modal Content for Add Site.
function addSiteScreen()
{
    var addSiteModalDialog=j$('#addSiteModalDialog');
    
    var messageDivElement=j$('.messageDiv');
    messageDivElement.html('');
    messageDivElement.hide();
    
    var newSiteAccountDivElement=j$('.newSiteAccountDiv');
    
    var newSiteAccLookupAnchorElement=newSiteAccountDivElement.find('.lookupInput').find('a');
    var lookupIcon='<i class="fa fa-search lookupIconFont slds-form-element__addon" aria-hidden="true"></i>';
    newSiteAccLookupAnchorElement.html(lookupIcon);
    
    var bodyElement=j$('.siteLookup').prop('innerHTML');
    addSiteModalDialog.find(".modalBody").html(bodyElement);
    
    addSiteModalDialog.removeClass('noDisplay');
}

//Performing validations on click of Add Site Button of Modal and displaying error, success messages.
//And adding the Site record.
function addSiteRecord()
{
    var newSiteAccountDivElement=j$('.newSiteAccountDiv');
    var selectedAccountId=[];
    var accId=newSiteAccountDivElement.find("input[id$='lkid']").prop('value');
    selectedAccountId.push(accId);
    
    //If Site already exists for the selected Account.
    var siteAlreadyExists=false;
    var existingSiteRow;
    
    if(accId!=null && accId!='')
    {
        j$('.manuallyAddedSitesTable').find('.accountId').each(function()
        {
            var bodyRowAccountId=j$(this).prop('value');
            if(bodyRowAccountId.indexOf(accId)>-1)
            {
                existingSiteRow=j$(this).closest('.bodyRow');
                siteAlreadyExists=true;
                return false;
            }
        });
    }
    
    var messageDivElement=j$('.messageDiv');
    messageDivElement.html('');
    messageDivElement.hide();
    j$('.loadingSpinnerDiv').show();
    j$('#addSiteModalDialog').addClass('noDisplay');
    
    if(siteAlreadyExists==false)
    {
        var opportunityId=j$('.opportunityRecord').prop('value');
        
        var accNameValue=newSiteAccountDivElement.find("input[id$='lkold']").prop('value');
        var accountName='<b>'+accNameValue+'</b>';
        
        if(accNameValue!='null' && accNameValue!='')
        {
            ALL_MassCreateOppSites_Extension.createOpportunitySites(selectedAccountId, opportunityId, function(result, event)
            {
                if(event.status)
                {
                    if(Object.keys(result).length==0)
                    {
                        displayMessage('success', messageDivElement, 'Site record successfully added for '+accountName+' account...');
                        location.reload();
                        j$('.loadingSpinnerDiv').hide();
                    }
                    else
                    {
                        displayMessage('error', messageDivElement, 'Sorry, Site for '+accountName+' could not be added, due to the some error. Please contact your System Administrator.');
                        j$('.loadingSpinnerDiv').hide();
                    }
                }
                else 
                {
                    displayMessage('error', messageDivElement, 'Sorry, Site for '+accountName+' could not be added, due to the some error. Please contact your System Administrator.');
                    j$('.loadingSpinnerDiv').hide();
                }
            });
        }
        else
        {
            displayMessage('info', messageDivElement, 'Please select a Site using Lookup icon or auto-complete results and then click <b>Add Site</b> button.');
            j$('.loadingSpinnerDiv').hide();
        }
    }
    else
    {
        existingSiteRow.addClass('highlightRow');
        setTimeout(function()
		{
            existingSiteRow.removeClass('highlightRow');
        }, 2000);
        
        displayMessage('info', messageDivElement, 'A Site already exists for the selected Account. Duplicate Sites cannot be added.');
        j$('.loadingSpinnerDiv').hide();
    }
}

function navigateToDiscoveryHome(homeIconElement)
{
    var homeIconElementAccountId=j$(homeIconElement).closest('tr').find('.accountId').prop('value');
    
    var oppLocationId;
    var accIdsWithExistingSites=j$('.accountIdsWithExistingSites').prop('value').replace('{', '').replace('}', '').split(',');
    accIdsWithExistingSites.map(function(value)
	{
        var rowValue=value.trim();
        var indexOfEqualsTo=rowValue.indexOf('=');
        var accountId=rowValue.substring(0, indexOfEqualsTo);
        if(accountId==homeIconElementAccountId)
        {
            var lengthOfRowValue=rowValue.length;
            oppLocationId=rowValue.substring((indexOfEqualsTo+1), lengthOfRowValue);
        }
    });
    
    window.open('/apex/ALL_DiscoveryHome?oppLocId='+oppLocationId);
}

function closeAddSiteModal()
{
    j$('#addSiteModalDialog').addClass('noDisplay');
}

function backToTopButton()
{
    //Check to see if the window is top if not then display button
	j$(window).scroll(function()
	{
		if(j$(this).scrollTop()>500)
        {
			j$('.scrollToTop').fadeIn();
		}
        else
        {
			j$('.scrollToTop').fadeOut();
		}
	});
	
	//Click event to scroll to top.
	j$('.scrollToTop').click(function()
	{
		j$('html, body').animate({scrollTop : 0}, 800);
		return false;
	});
}