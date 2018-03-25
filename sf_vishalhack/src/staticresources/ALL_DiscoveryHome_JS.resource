//2016-08-25- anirudh.singh@cdk.com- Created this JS for ALL_DiscoveryHome Visualforce Page.
//2017-02-23 -venkata.shrivol@cdk.com -added signer tags and span tags at line 469 and 478
//									
var j$=jQuery.noConflict();
var summarySectsPresent=[];
var summarySectsNotPresent=[];
var globalTimer=0;

j$(document).ready(
    function()
    {
        j$('#discHomeSpinnerDiv').modal('show');
        highlightSelectedTab();
        
        addDataTHToColumnsOfHomePageTable();
        document.getElementsByTagName("html")[0].style.visibility="visible";
        
        var indexOfTabName=window.location.href.indexOf('&tabName=')+9;
        var urlLength=window.location.href.length;
        var tabName=window.location.href.substring(indexOfTabName, urlLength);
        
        if(decodeURIComponent(tabName)=='Print Version')
        {
            removeAllLinks();
            
            addTopHeaderTableToSections();
        }
        
        backToTopButton();
        
        fixedTopHeader();
        
        responsiveTabs();
        j$('#discHomeSpinnerDiv').modal('hide');
    }
);

j$(window).resize(function()
{
    clearTimeout(globalTimer);
    globalTimer=setTimeout(responsiveTabs, 500);
});

function addDataTHToColumnsOfHomePageTable()
{
    j$('table.homePageTable').each(function()
	{
        var headerElement=j$(this).find('thead').find('th.homePageTh');
        var headerNames=[];
        
        headerElement.each(function()
		{
            headerNames.push(j$(this).prop('textContent').trim());
        });
        
        var bodyTrElements=j$(this).find('tbody').find('tr.homepageTr');
        
        bodyTrElements.each(function()
		{
            var tdElements=j$(this).find('td.dataColumn');
            
            for(var i=0; i<tdElements.length; i++)
            {
                j$(tdElements[i]).each(function()
				{
                    j$(this).attr('data-th', headerNames[i]);
                });
                
                j$(tdElements[i]).children().each(function()
				{
                    if(j$(this).prop('className').indexOf('underlinedLinks')==-1)
                    {
                        j$(this).addClass('tdChildHomeTableContent');
                    }
                });
            }
        });
    });
}

function addTabNameParameterToURL(element)
{
    var tabName;
    if(j$(element).prop('value')==undefined)
    {
        tabName=j$(element).prop('text');
    }
    else
    {
        tabName=j$(element).prop('value');
    }
    
    var indexOfTabName=window.location.href.indexOf('&tabName=');
    
    if(history.pushState)
    {
        var newurl;
        if(indexOfTabName==-1)
        {
            newurl=window.location.href+'&tabName='+encodeURIComponent(tabName);
            window.history.pushState({path:newurl}, '', newurl);
        }
        else
        {
            newurl=window.location.href.substring(0, indexOfTabName);
            newurl=newurl+'&tabName='+encodeURIComponent(tabName);
            window.history.pushState({path:newurl}, '', newurl);
        }
    }
    
    window.location.reload();
}

function highlightSelectedTab()
{
    var selectedTabName=j$('#selectedTabValue').attr('value');
    
    j$('.tabButtonStyle').each(function()
	{
        if(j$(this).attr('value')==selectedTabName)
        {
            //j$(this).attr('style', 'background-color: #00A9CE; color: white; text-decoration: underline;');
            j$(this).addClass('selectedTab');
        }
        else
        {
            //j$(this).attr('style', 'background-color: transparent; color: #337ab7; text-decoration: none;');
            j$(this).removeClass('selectedTab');
        }
    });
}

function removeAllLinks()
{
    j$('.homepageDetailsTable a').each(function()
    {
        var innerText=j$(this).prop('innerText');
        var spanElement=j$('<span></span>').text(innerText);
        j$(this).replaceWith(spanElement);
    });
}

function addTopHeaderTableToSections()
{
    var homepageDetailsTable=j$('.homepageDetailsTable').clone();
    homepageDetailsTable.find('tr:first').remove();
    
    j$('.headerH3:not(:first)').each(function()
	{
        var homepageDetailsTableClone=homepageDetailsTable.clone().css('margin-bottom', 0)
        .css('border-bottom','1px solid #ccc').addClass('sectionTables');
        j$(this).after(homepageDetailsTableClone);
    });
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

function fixedTopHeader()
{
	j$(window).scroll(function()
	{
		if(j$(this).scrollTop()>100)
        {
			j$('.homeDetailsHeader').css('position', 'fixed');
		}
        else
        {
			j$('.homeDetailsHeader').css('position', '');
		}
	});
}

function responsiveTabs()
{
    var homePageTabUl=j$('.homePagetabUl');
    var homePageTabUlWidth=homePageTabUl.prop('offsetWidth');
    createPlusIconElement(homePageTabUl);
    
    var plusElement=j$('.plusIconLi');
    var plusElementWidth=plusElement.prop('offsetWidth');
    plusElement.hide();
    
    var homePageTabLiList=j$('.homePagetabUl').find('li:not(.plusIconLi)');
    homePageTabLiList.each(function()
    {
        j$(this).show();
    });
    
    var combinedWidth=20+plusElementWidth;
    var remainingListItems='';
    var totalWidthExceeded=false;
    
    var homePageTabLiList=j$('.homePagetabUl').find('li:not(.plusIconLi)');
    if(homePageTabLiList.length>0)
    {
        homePageTabLiList.each(function()
        {
            var thisElement=j$(this);
            var currentLiWidth=thisElement.prop('offsetWidth');
            var newCombinedWidth=combinedWidth+currentLiWidth;
            
            if(newCombinedWidth<homePageTabUlWidth && !totalWidthExceeded)
            {
                combinedWidth=newCombinedWidth;
                thisElement.show();
            }
            else
            {
                remainingListItems+=thisElement.clone().prop('innerHTML');
                totalWidthExceeded=true;
                thisElement.hide();
            }
        });
    }
    
    if(remainingListItems!='')
    {
        plusElement.find('.additionalTabsDropdown').append(remainingListItems);
        plusElement.show();
        
        var plusIconInputElements=plusElement.find('.additionalTabsDropdown').find('input');
        plusIconInputElements.each(function()
        {
            if(j$(this).hasClass('selectedTab'))
            {
                j$(this).removeClass();
                j$(this).addClass('selectedTab').addClass('tabDropdownLiElement');
            }
            else
            {
                j$(this).removeClass();
                j$(this).addClass('tabDropdownLiElement');
            }
        });
    }
}

function createPlusIconElement(homePageTabUl)
{
    if(j$('.plusIconLi').length>0)
    {
        j$('.plusIconLi').remove();
    }
    
    var plusElement='<li class="homePageTabs plusIconLi">'
    +'<button class="btn btn-default dropdown-toggle additionalTabs" type="button" data-toggle="dropdown">'
    +'<i class="fa fa-caret-down plusIcon" aria-hidden="true"></i>'
    +'</button>'
    +'<ul class="dropdown-menu additionalTabsDropdown">'
    +'</ul>'
    +'</li>';
    homePageTabUl.append(plusElement);
}

function printPage()
{
    j$('.homeDetailsHeader').css('position', '');
    
    var modalDialongElement=j$('#modalDialogSectionSelect');
    modalDialongElement.find('.modal-title').html('<b>Select Sections to Print</b>');
    modalDialongElement.find('.modal-body').html(generateSectionSelectBody());
    modalDialongElement.find('.modal-footer').html(generateSectionSelectFooter());
}

function generateSectionSelectBody()
{
    var sectionHeaderElements=j$('.headerH3');
    
    var tableElement='<button type="button" class="btn btn-primary summaryButton" onclick="summarySelection(this);">'
    +'<i aria-hidden="true" class="fa fa-square summaryReportIcon"></i>Summary</button>'
    +'<table class="table table-bordered table-striped table-condensed selectSectionsTable">'
    +'<thead>'
    +'<tr>'
    +'<th class="selectAllSections" title="Select All"><input type="checkbox" onclick="selectAllSections(this);" checked="checked"></th>'
    +'<th class="sectionName">Section Name</th>'
    +'</tr>'
    +'</thead>'
    +'<tbody>';
    
    sectionHeaderElements.each(function()
	{
        var sectionName=j$(this).prop('innerText');
        
        tableElement+='<tr>'
        +'<td class="selectSection">'
        +'<input type="checkbox" onclick="selectSection(this);" checked="checked">'
        +'</td>'
        +'<td class="sectionName">'+sectionName+'</td>'
        tableElement+='</tr>';
    });
    tableElement+=addNotPresentSectsForSummary(sectionHeaderElements)
    +'</tbody>'
    +'</table>';
    
    return tableElement;
}

function addNotPresentSectsForSummary(sectionHeaderElements)
{
    var summarySectsList=fetchSummarySectsList();
    var sectsNamesList=[];
    
    sectionHeaderElements.each(function()
	{
        var sectionName=j$(this).prop('innerText');
        sectsNamesList.push(sectionName);
        
        if(j$.inArray(sectionName, summarySectsList)>-1 && j$.inArray(sectionName, summarySectsPresent)==-1)
        {
            summarySectsPresent.push(sectionName);
        }
    });
    
    var accPresent='no';
    //For Product Questions.
    var productQuesHeaderElements=j$('.productQuestionsComponent').find('.headerH3');
    productQuesHeaderElements.each(function()
	{
        var headerName=j$(this).prop('innerText');
        var lastIndexOfDash=headerName.lastIndexOf('-');
        var productName=headerName.substring(lastIndexOfDash, headerName.length);
        if(productName.toLowerCase().indexOf('accounting')>-1)
        {
            summarySectsPresent.push(headerName);
            accPresent='yes';
            return false;
        }
    });
    
    var rowsForSectsNotPresent='';
    j$.each(summarySectsList, function(index, value)
	{
        if(j$.inArray(value, summarySectsPresent)==-1 && j$.inArray(value, sectsNamesList)==-1 && j$.inArray(value, summarySectsNotPresent)==-1)
        {
            summarySectsNotPresent.push(value);
            rowsForSectsNotPresent+='<tr>'
            +'<td class="selectSection">'
            +'<input type="checkbox" onclick="selectSection(this);" checked="checked">'
            +'</td>'
            +'<td class="sectionName">'+value+'</td>'
            +'</tr>';
        }
    });
    
    if(accPresent=='no')
    {
        if(j$.inArray('Accounting', summarySectsNotPresent)==-1)
        {
            summarySectsNotPresent.push('Accounting');
        }
        
        rowsForSectsNotPresent+='<tr>'
        +'<td class="selectSection">'
        +'<input type="checkbox" onclick="selectSection(this);" checked="checked">'
        +'</td>'
        +'<td class="sectionName">Accounting</td>'
        +'</tr>';
    }
    
    addSectionsForNotPresentSects();
    
    return rowsForSectsNotPresent;
}

function fetchSummarySectsList()
{
    var summarySectsList=[];
    summarySectsList.push('Dealership Overview');
    summarySectsList.push('Opportunity Location- Building');
    summarySectsList.push('Hours of Operation');
    summarySectsList.push('Headcount Details');
    summarySectsList.push('Inventory Levels');
    summarySectsList.push('Building Map');
    summarySectsList.push('Hardware Details');
    summarySectsList.push('Network Details');
    summarySectsList.push('Network Device Images');
    summarySectsList.push('Products');
    summarySectsList.push('Dealer Acknowledgement');
    
    return summarySectsList;
}

function addSectionsForNotPresentSects()
{
    var spanElement=j$('.pdfPageBreak > span');
    
    j$.each(summarySectsNotPresent, function(index, sectionName)
	{
        spanElement.append(generateNotPresentSections(sectionName));
        summarySectsPresent.push(sectionName);
    });
}

function generateNotPresentSections(sectionName)
{
    var sectionPresent='no';
    var emptySection='';
    j$('.headerH3').each(function()
	{
        var headerName=j$(this).prop('innerText');
        
        if(headerName==sectionName)
        {
            sectionPresent='yes';
        }
    });
    
    if(sectionPresent=='no')
    {
        var homepageDetailsTable=j$('.homepageDetailsTable').first().clone();
        homepageDetailsTable=homepageDetailsTable.css('margin-bottom', 0)
        .css('border-bottom','1px solid #ccc').addClass('sectionTables');
        homepageDetailsTable=homepageDetailsTable.prop('outerHTML');
        
        emptySection='<span class="summaryEmptySections">'
        +'<div>'
        +'<h3 class="headerH3">'+sectionName+'</h3>'
        +homepageDetailsTable;
        if(sectionName=='Dealer Acknowledgement')
        {
            emptySection+=generateAcknowledgementSection();
        }
        emptySection+='</div>'
        +'</span>';
    }
    
    return emptySection;
}

function generateAcknowledgementSection()
{
    var acknowledgementContent='<div class="dealerAck">'
    +'<p>Prospective Client named below represents that to the best of its knowledge the information detailed in pages '
    +'_ through _ herein accurately reflects the operations of Prospective Client, including the number and location '
    +'of buildings, servers, PCs, printers, network routers, users and application software plus any contemplated future '
    +'changes to those factors (e.g,, any future buildings or dealership operations) that Prospective Client desires '
    +'to be managed by its replacement dealer management system.</p>'
    +'<br/>'
    +'<p>Prospective Client understands that this information will be relied upon by CDK Global, LLC ("CDK") in the '
    +'preparation of a proposal to Prospective Client and in the preparation of schedules to its eventual definitive '
    +'agreement with CDK, and that any inaccuracy may result in additional cost to Prospective Client for the implementation '
    +'of its CDK dealer management system. </p>'
    +'<br/>'
    +'<br/>'
    +'<label class="ackLabel">Prospective Client:</label>'
    +'<span class="ackInputLine"></span>'
    +'<br/>'
    +'<br/>'
    +'<br/>'
    +'<br/>'
    +'<label class="ackLabel">Authorized Signature:</label>'
    //+'<span class="ackInputLine"></span>'
    +'<span class="ackInputLine">'
    +'<span class="docuSignTags">\\\s1\\\</span><span class="docuSignTags">\\\s2\\\</span>'
    +'</span>'
    +'<br/>'
    +'<label class="ackLabel">Print Name:</label>'
    +'<span class="ackInputLine"></span>'
    +'<br/>'
    +'<label class="ackLabel">Title:</label>'
    +'<span class="ackInputLine"></span>'
    +'<br/>'
    +'<label class="ackLabel">Date:</label>'
    //+'<span class="ackInputLine"></span>'
    +'<span class="ackInputLine">'
    +'<span class="docuSignTags">\\\d1\\\</span><span class="docuSignTags">\\\d2\\\</span>'
    +'</span>'
    +'</div>';
    
    return acknowledgementContent;
}

function generateSectionSelectFooter()
{
    var footerElement='<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>';
    footerElement+='<button type="button" class="btn btn-primary printButton" onclick="confirmPrint();">Print</button>';
    return footerElement;
}

function selectAllSections(element)
{
    var selectAllCheckboxValue=j$(element).prop('checked');
    var tdCheckboxes=j$('#modalDialogSectionSelect').find('.selectSectionsTable').find('.selectSection');
    
    tdCheckboxes.each(function()
	{
        var inputElement=j$(this).find('input');
        var printButton=j$('.printButton');
        if(selectAllCheckboxValue)
        {
            inputElement.prop('checked', 'checked');
            printButton.prop('disabled', false);
            
            var summaryButton=j$('.summaryButton');
            if(summaryButton.hasClass('whiteColor'))
            {
                summaryButton.removeClass('whiteColor');
                summaryButton.find('i').replaceWith('<i class="fa fa-square summaryReportIcon" aria-hidden="true"></i>');
                
                summaryButton.prop('innerHTML', summaryButton.find('i').prop('outerHTML')+'Summary');
            }
        }
        else
        {
            inputElement.removeAttr('checked');
            printButton.prop('disabled', true);
        }
    });
}

function selectSection(element)
{
    var currentCheckboxValue=j$(element).prop('checked');
    var tdCheckboxes=j$('#modalDialogSectionSelect').find('.selectSectionsTable').find('.selectSection');
    var noOfCheckedRows=0;
    var totalNoOfRows=0;
    var printButton=j$('.printButton');
    
    tdCheckboxes.each(function()
	{
        totalNoOfRows++;
        var checkboxValue=j$(this).find('input').prop('checked');
        if(checkboxValue)
        {
            noOfCheckedRows++;
        }
    });
    
    if(noOfCheckedRows==totalNoOfRows)
    {
        j$('.selectSectionsTable').find('.selectAllSections').find('input').prop('checked', 'checked');
    }
    else
    {
        j$('.selectSectionsTable').find('.selectAllSections').find('input').removeAttr('checked');
    }
    
    if(noOfCheckedRows==0)
    {
        printButton.prop('disabled', true);
    }
    else
    {
        printButton.prop('disabled', false);
    }
    
    if(noOfCheckedRows==totalNoOfRows || noOfCheckedRows==0)
    {
        var summaryButton=j$('.summaryButton');
        if(summaryButton.hasClass('whiteColor'))
        {
            summaryButton.removeClass('whiteColor');
            summaryButton.find('i').replaceWith('<i class="fa fa-square summaryReportIcon" aria-hidden="true"></i>');
            
            summaryButton.prop('innerHTML', summaryButton.find('i').prop('outerHTML')+'Summary');
        }
    }
}

function summarySelection(element)
{
    var summaryButton=j$(element);
    
    if(!summaryButton.hasClass('whiteColor'))
    {
        summaryButton.addClass('whiteColor');
        summaryButton.find('i').replaceWith('<i class="fa fa-check-square summaryReportIcon whiteColor" aria-hidden="true"></i>');
        
        summaryButton.prop('innerHTML', summaryButton.find('i').prop('outerHTML')+'<b>Summary</b>');
        
        var selectAllCheckbox=j$('.selectSectionsTable').find('thead').find('.selectAllSections').find('input');
        selectAllCheckbox.removeAttr('checked');
        
        var rowElements=j$('.selectSectionsTable').find('tbody').find('tr');
        var noOfCheckedRows=0;
        rowElements.each(function()
        {
            var thisElement=j$(this);
            var secName=thisElement.find('.sectionName').prop('innerText');
            
            if(j$.inArray(secName, summarySectsPresent)>-1)
            {
                thisElement.find('.selectSection').find('input').prop('checked', 'checked');
                noOfCheckedRows++;
            }
            else
            {
                thisElement.find('.selectSection').find('input').removeAttr('checked');
            }
        });
        
        var printButton=j$('.printButton');
        if(noOfCheckedRows==0)
        {
            printButton.prop('disabled', true);
        }
        else
        {
            printButton.prop('disabled', false);
        }
    }
    else
    {
        summaryButton.removeClass('whiteColor');
        summaryButton.find('i').replaceWith('<i class="fa fa-square summaryReportIcon" aria-hidden="true"></i>');
        
        summaryButton.prop('innerHTML', summaryButton.find('i').prop('outerHTML')+'Summary');
        
        var selectAllSectionsEl=j$('.selectAllSections').find('input');
        selectAllSectionsEl.prop('checked', 'checked');
        selectAllSections(selectAllSectionsEl);
    }
}

function confirmPrint()
{
    j$('#modalDialogSectionSelect').modal('toggle');
    var selectAllCheckboxValue=j$('.selectSectionsTable').find('.selectAllSections').prop('checked');
    
    if(selectAllCheckboxValue)
    {
        window.print();
    }
    else
    {
        var tdCheckboxes=j$('.selectSectionsTable').find('.selectSection');
        var selectedSectionList=[];
        
        tdCheckboxes.each(function()
        {
            var thisElement=j$(this);
            var checkboxValue=thisElement.find('input').prop('checked');
            if(checkboxValue)
            {
                var sectionName=thisElement.closest('tr').find('.sectionName').prop('innerText');
                selectedSectionList.push(sectionName);
            }
        });
        
        var sectionHeaderElements=j$('.headerH3');
        var noOfSectionsToDisplay=0;
        sectionHeaderElements.each(function()
		{
            var sectionName=j$(this).prop('innerText');
            var parentSpan=j$(this).closest('div').closest('span');
            
            if(j$.inArray(sectionName, selectedSectionList)>-1)
            {
                parentSpan.removeClass('sectionDivs');
                parentSpan.addClass('sectionToDisplay');
                noOfSectionsToDisplay++;
                
                if(noOfSectionsToDisplay==1)
                {
                    parentSpan.addClass('firstSection');
                }
                else
                {
                    parentSpan.removeClass('firstSection');
                }
            }
            else
            {
                parentSpan.addClass('sectionDivs');
                parentSpan.removeClass('sectionToDisplay');
                parentSpan.removeClass('firstSection');
            }
        });
        
        window.print();
    }
}

function navigateToDiscoveryHome()
{
    var indexOfTabName=window.location.href.indexOf('&tabName=');
    var newUrl=window.location.href.substring(0, indexOfTabName);
    window.history.pushState({path:newUrl}, '', newUrl);
    window.location.reload();
}

function homeQuesTypeBtn(homeQuesTypeBtn)
{
    var homeQuesTypeBtnEl=j$(homeQuesTypeBtn);
    var thisHomeComp=homeQuesTypeBtnEl.closest('.discoveryHomePage');
    var quesTypeSelected=homeQuesTypeBtnEl.prop('innerText').trim();
    
    var liElements=thisHomeComp.find('.quesTypeBtn').find('ul').find('li');
    liElements.each(function()
	{
        var thisLiEl=j$(this);
        if(thisLiEl.find('.quesTypeLiBtn').prop('value')==quesTypeSelected)
        {
            thisLiEl.hide();
        }
        else
        {
            thisLiEl.show();
        }
    });
}

function homeQuesTypeFilter()
{
    var selectedQuesTypeVal=j$('.selectedQuesTypeVal').val();
    var homeQuesTypeBtnEl=j$('.quesTypeBtn').find('button');
    
    if(selectedQuesTypeVal!=undefined && selectedQuesTypeVal!=null && selectedQuesTypeVal!=='')
    {
        homeQuesTypeBtnEl.prop('innerHTML', selectedQuesTypeVal+' <span class="caret"></span>');
    }
    else
    {
        homeQuesTypeBtnEl.prop('innerHTML', 'All <span class="caret"></span>');
    }
    homeQuesTypeBtn(homeQuesTypeBtnEl);
    addDataTHToColumnsOfHomePageTable();
}

function showDiscHomeSpinner()
{
    j$('#discHomeSpinnerDiv').modal('show');
}

function hideDiscHomeSpinner()
{
    j$('#discHomeSpinnerDiv').modal('hide');
}