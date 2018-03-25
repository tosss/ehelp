//2016-08-22- anirudh.singh@cdk.com- Created this JS for ALL_QuestionAnswer Visualforce Component.
//2017-05-05- anirudh.singh@cdk.com- Modified this JS for RQ-09205 Discovery - Add a Comments question for each tab.
var j$=jQuery.noConflict();

//Processing on Ready event of the document.
j$(document).ready(
    function()
    {
        j$('#qaSpinnerDiv').modal('show');
        j$('.questionAnswerComponent').each(function()
        {
            processQuesAnsHeadersForNonPDF(j$(this));
            
            processQuesAnsBodyForNonPDF(j$(this));
        });
        
        processDataTypes();
        
        initializeDateTimePicker();
        
        addEventToQuickSaveButton();
        
        addEventToParentQues();
        
        addValidationEventToAnsFields();
        
        showHideChildQues();
        
        j$('#qaSpinnerDiv').modal('hide');
    }
);

function processQuesAnsHeadersForNonPDF(questionAnswerComponent)
{
    var categoryHeaderElement=questionAnswerComponent.find('.categoryHeader');
    var categoryHeaderInputElement=categoryHeaderElement.find('input');
    
    var categoryNameForRecsVal=categoryHeaderInputElement.data('categorynameforrecs');
    var productNameVal=categoryHeaderInputElement.data('productname');
    var subCategoryNameForRecsVal=categoryHeaderInputElement.data('subcategorynameforrecs');
    var displayHeader=categoryHeaderInputElement.data('displayheader');
    
    categoryHeaderElement.empty();
    if(subCategoryNameForRecsVal!=undefined && subCategoryNameForRecsVal!=null && subCategoryNameForRecsVal!='')
    {
        categoryHeaderElement.prop('innerText', subCategoryNameForRecsVal);
    }
    else if(productNameVal!=undefined && productNameVal!=null && productNameVal!='')
    {
        categoryHeaderElement.prop('innerText', productNameVal);
    }
	else if(displayHeader)
    {
        categoryHeaderElement.prop('innerText', categoryNameForRecsVal);
    }
}

function processQuesAnsBodyForNonPDF(questionAnswerComponent)
{
    processQuesNoForNonPDF(questionAnswerComponent);
    
    processQuesTextForNonPDF(questionAnswerComponent);
}

function processQuesNoForNonPDF(questionAnswerComponent)
{
    var quesNoElements=questionAnswerComponent.find('.quesNo');
    
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var inputElement=thisElement.find('input');
        var parentQuestionNumber=inputElement.data('parentquestionnumber');
        var questionType=inputElement.data('questiontype');
        var rowElement=thisElement.closest('tr');
        
        if(parentQuestionNumber!='' && parentQuestionNumber!=null && parentQuestionNumber!=undefined)
        {
            var spanElement='<span ';
            if(questionType=='Pre-Sale')
            {
                spanElement+='class="pre"';
            }
            else if(questionType=='Post-Sale')
            {
                spanElement+='class="post"';
            }
            else if(questionType=='Talk Track')
            {
                spanElement+='class="talkTrack"';
            }
            else
            {
                spanElement+='class="virtual"';
            }
            
            spanElement+='>'+parentQuestionNumber+'.</span>';
            
            thisElement.append(spanElement);
            rowElement.addClass('hrLine');
        }
        else
        {
            rowElement.find('.quesText').addClass('hrLine');
            rowElement.find('.quesText').addClass('childQuestPadding');
            rowElement.find('.ansColumn').addClass('hrLine');
            rowElement.find('.notApplicableColumn').addClass('hrLine');
        }
    });
}

function processQuesTextForNonPDF(questionAnswerComponent)
{
    var questTextElements=questionAnswerComponent.find('.quesText');
    
    questTextElements.each(function()
	{
        var thisElement=j$(this);
        var inputElement=thisElement.find('input');
        var questionType=inputElement.data('questiontype');
        var questionText=inputElement.data('questiontext');
        var note=inputElement.data('note');
        
        var spanElement='<span ';
        if(questionType=='Pre-Sale')
        {
            spanElement+='class="pre"';
        }
        else if(questionType=='Post-Sale')
        {
            spanElement+='class="post"';
        }
        else if(questionType=='Talk Track')
        {
            spanElement+='class="talkTrack"';
        }
        else
        {
            spanElement+='class="virtual"';
        }
        
        spanElement+='>'+questionText+'</span>';
        
        if(questionType=='Virtual')
        {
            spanElement+=' <i class="fa fa-laptop virtualIcon" aria-hidden="true" title="Virtual"></i>';
        }
        
        if(note!=undefined && note!=null && note!='')
        {
            spanElement+='<br/>'
            +'<span><b>Note: </b>'+note+'</span>';
        }
        
        inputElement.remove();
        thisElement.append(spanElement);
    });
}

//This method is used to process Multiselect and Number fields values on page load.
function processDataTypes()
{
    j$(".multiselectField").each(function()
	{
        //Show the selected values on page load.
        var multiselectFieldValue=j$(this).attr('fieldValue');
        
        if(multiselectFieldValue!=undefined)
        {
            var multiselectFieldSplitedValues=multiselectFieldValue.split(";");
            var optionElements=j$(this).find("option");
            
            for(var i=0; i<multiselectFieldSplitedValues.length; i++)
            {
                for(var j=0; j<optionElements.length; j++)
                {
                    if(multiselectFieldSplitedValues[i].trim()==optionElements[j].value)
                    {
                        j$(optionElements[j]).prop('selected', true);
                    }
                }
            }
        }
    });
    
    j$(".numberField").each(function()
	{
        var numberFieldValue=j$(this).attr('value');
        if(numberFieldValue!=undefined)
        {
            numberFieldValue=numberFieldValue.replace(/,/g , '');
            j$(this).prop('value', numberFieldValue);
        }
    });
}

function initializeDateTimePicker()
{
    j$(".datepicker").datetimepicker({
        format: 'MM/DD/YYYY'
    });
    
    j$('.datetimepicker').datetimepicker();
}

function addValidationEventToAnsFields()
{
    var ansElements=j$('.ansColumn');
    ansElements.each(function()
	{
        var thisElement=j$(this);
        var quesNoInput=thisElement.closest('.quesTR').find('.quesNo').find('input');
        var dataType=quesNoInput.data('datatype');
        
        if(dataType=='Email' || dataType=='URL' || dataType=='Phone')
        {
            var functionName='validateAns(this, "'+dataType+'");';
            thisElement.find('input').attr('onblur', functionName);
        }
    });
    
    j$('input[type="number"]').keydown(function(event)
	{
        //Allow: backspace, delete, tab, escape, enter and .
        if(j$.inArray(event.keyCode, [46, 8, 9, 27, 13, 110, 190])!==-1 ||
           //Allow: Ctrl+A
           (event.keyCode==65 && event.ctrlKey===true) ||
           //Allow: Ctrl+C
           (event.keyCode==67 && event.ctrlKey===true) ||
           //Allow: Ctrl+X
           (event.keyCode==88 && event.ctrlKey===true) ||
           //Allow: home, end, left, right
           (event.keyCode>=35 && event.keyCode<=39))
        {
            //let it happen, don't do anything
            return;
        }
        //Ensure that it is a number and stop the keypress
        if((event.shiftKey || (event.keyCode<48 || event.keyCode>57)) && (event.keyCode<96 || event.keyCode>105))
        {
            event.preventDefault();
        }
    });
}

function validateAns(ansElement, dataType)
{
    var ansElement=j$(ansElement);
    var thisComponent=ansElement.closest('.questionAnswerComponent');
    var formValid=thisComponent.find('[Id$="questionAnswerForm"]')[0].checkValidity();
    var fieldErrorElement=ansElement.closest('.ansColumn').find('.fieldError');
    var newFieldValue=fetchFieldValue(dataType, ansElement);
    
    if((formValid && dataType!='Phone')
       || (dataType=='Phone' && performFieldValidation(fieldErrorElement, dataType, ansElement, newFieldValue)))
    {
        fieldErrorElement.remove();
    }
    else
    {
        if(dataType!='Phone')
        {
            performFieldValidation(fieldErrorElement, dataType, ansElement, newFieldValue);
        }
    }
}

function addEventToQuickSaveButton()
{
    var quickSaveButtons=j$('.quickSaveButton');
    
    quickSaveButtons.each(function()
	{
        var thisElement=j$(this);
        thisElement.attr('onclick', 'enableDisableQuickSave(this);');
    });
}

function enableDisableQuickSave(element)
{
    var clickedQSElement=j$(element);
    var quickSaveButtonEl=j$('.quickSaveButton');
    var quickSaveEnableOrDisable='';
    
    if(!clickedQSElement.hasClass('whiteColor'))
    {
        quickSaveButtonEl.each(function()
		{
            var thisButton=j$(this);
            thisButton.addClass('whiteColor');
            thisButton.find('i').replaceWith('<i class="fa fa-check-square quickSaveIcon whiteColor" aria-hidden="true"></i>');
            
            thisButton.prop('innerHTML', thisButton.find('i').prop('outerHTML')+'<b>QuickSave Enabled</b>'
                            +'<i class="fa fa-spinner fa-spin quickSaveSpinner hideQuickSaveSpinner"></i>');
        });
        
        quickSaveEnableOrDisable='enable';
    }
    else
    {
        quickSaveButtonEl.each(function()
		{
            var thisButton=j$(this);
            thisButton.removeClass('whiteColor');
            thisButton.find('i').replaceWith('<i class="fa fa-square-o quickSaveIcon" aria-hidden="true"></i>');
            
            thisButton.prop('innerHTML', thisButton.find('i').prop('outerHTML')+'Enable QuickSave');
        });
        
        quickSaveEnableOrDisable='disable';
    }
    
    addRemoveEventToAnsFields(quickSaveEnableOrDisable);
}

function addEventToParentQues()
{
    var quesNoElements=j$('.quesNo');
    var parentNames=[];
    
    //Collecting all the Parent names from the Child Questions.
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var inputElement=thisElement.find('input');
        var parentName=inputElement.data('parentname');
        var rowElement=thisElement.closest('tr');
        
        if(parentName!='' && parentName!=null && parentName!=undefined && j$.inArray(parentName, parentNames)==-1)
        {
            parentNames.push(parentName);
        }
    });
    
    //Adding onclick event on Parent Questions.
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var rowElement=thisElement.closest('tr');
        var inputElement=thisElement.find('input');
        var questionName=inputElement.data('questionname');
        var quesDatatype=inputElement.data('datatype');
        
        if(j$.inArray(questionName, parentNames)>-1)
        {
            if((quesDatatype=='Picklist' || quesDatatype=='MultiSelect Picklist'))
            {
                rowElement.find('.ansColumn').attr('onchange', 'rerenderChildQues(this);');
            }
            rowElement.find('.notApplicableColumn').attr('onclick', 'naFieldChangeWithChildren(this);');
            
            if(rowElement.find('.notApplicableField').prop('checked'))
            {
                var quesNameList=[];
                quesNameList.push(questionName);
                onLoadCheckChildrenNa(quesNameList);
                
                var ansElement=rowElement.find('.ansColumn');
                ansElement.find('input').prop('disabled', true);
                ansElement.find('textarea').attr('disabled', true);
                ansElement.find('select').prop('disabled', true);
                ansElement.find('.multiselectClearButton').prop('disabled', true);
            }
        }
        else
        {
            rowElement.find('.notApplicableColumn').attr('onclick', 'naFieldChangeNoChildren(this);');
            naFieldChangeNoChildren(rowElement.find('.notApplicableColumn'));
        }
    });
}

function addRemoveEventToAnsFields(quickSaveEnableOrDisable)
{
    var ansElements=j$('.ansColumn');
    var naElements=j$('.notApplicableField');
    
    if(quickSaveEnableOrDisable=='enable')
    {
        ansElements.each(function()
        {
            var thisElement=j$(this);
            //2017-05-05- anirudh.singh@cdk.com- Added [type!="hidden"] to the input selection below.
            thisElement.find('input[type!="hidden"]').attr('onfocus', 'createHiddenInput(this, ".ansColumn");');
            thisElement.find('textarea').attr('onfocus', 'createHiddenInput(this, ".ansColumn");');
            thisElement.find('select').attr('onfocus', 'createHiddenInput(this, ".ansColumn");');
            
            //2017-05-05- anirudh.singh@cdk.com- Added [type!="hidden"] to the input selection below.
            thisElement.find('input[type!="hidden"]').attr('onblur', 'quickSaveAnsRecord(this, "input", ".ansColumn");');
            thisElement.find('textarea').attr('onblur', 'quickSaveAnsRecord(this, "textarea", ".ansColumn");');
            thisElement.find('select').attr('onblur', 'quickSaveAnsRecord(this, "select", ".ansColumn");');
        });
        
        naElements.each(function()
        {
            var thisElement=j$(this);
            thisElement.attr('onfocus', 'createHiddenInput(this, ".notApplicableColumn");');
            thisElement.attr('onblur', 'quickSaveAnsRecord(this, "input", ".notApplicableColumn");');
        });
    }
    else
    {
        ansElements.each(function()
        {
            var thisElement=j$(this);
            //2017-05-05- anirudh.singh@cdk.com- Added [type!="hidden"] to the input selection below.
            thisElement.find('input[type!="hidden"]').attr('onfocus', '');
            thisElement.find('textarea').attr('onfocus', '');
            thisElement.find('select').attr('onfocus', '');
            
            //2017-05-05- anirudh.singh@cdk.com- Added [type!="hidden"] to the input selection below.
            thisElement.find('input[type!="hidden"]').attr('onblur', '');
            thisElement.find('textarea').attr('onblur', '');
            thisElement.find('select').attr('onblur', '');
        });
        
        naElements.each(function()
        {
            var thisElement=j$(this);
            thisElement.attr('onfocus', '');
            thisElement.attr('onblur', '');
        });
    }
}

function createHiddenInput(element, scenarioName)
{
    var ansElement=j$(element);
    var dataType=(scenarioName=='.ansColumn') ? ansElement.closest('.quesTR').find('.quesNo').find('input').data('datatype') : 'Checkbox';
    
    //2017-05-05- anirudh.singh@cdk.com- Added the below IF Block to handle Other Question Types.
    if(dataType==undefined && ansElement.closest('.quesTR').find('.otherComments').length==1)
    {
        dataType='Long Text Area';
    }
    
    var existingFieldValue=fetchFieldValue(dataType, ansElement);
    
    var ansCol=ansElement.closest(scenarioName);
    var hiddenInput=ansCol.find('.existingFieldValue');
    if(hiddenInput.length>0)
    {
        hiddenInput.prop('value', existingFieldValue);
    }
    else
    {
        hiddenInput='<input type="hidden" class="existingFieldValue" value="'+existingFieldValue+'"/>';
        ansCol.append(hiddenInput);
    }
}

function quickSaveAnsRecord(element, tagType, scenarioName)
{
    var ansElement=j$(element);
    var quesNoInput=ansElement.closest('.quesTR').find('.quesNo').find('input');
    var dataType=quesNoInput.data('datatype');
    
    //2017-05-05- anirudh.singh@cdk.com- Added the below IF Block to handle Other Question Types.
    if(dataType==undefined && ansElement.closest('.quesTR').find('.otherComments').length==1)
    {
        dataType='Long Text Area';
    }
    
    var fieldErrorElement=ansElement.closest('.ansColumn').find('.fieldError');
    var newFieldValue=fetchFieldValue(dataType, ansElement);
    
    var thisComponent=ansElement.closest('.questionAnswerComponent');
    var formValid=thisComponent.find('[Id$="questionAnswerForm"]')[0].checkValidity();
    
    if((tagType=='input' && formValid && dataType!='Phone')
       || (tagType=='input' && dataType=='Phone' && performFieldValidation(fieldErrorElement, dataType, ansElement, newFieldValue)) 
       || tagType!='input'
       || tagType=='textarea')
    {
        fieldErrorElement.remove();
        
        var ansCol=ansElement.closest(scenarioName);
        var existingFieldValue=ansCol.find('.existingFieldValue').val();
        
        if(existingFieldValue!=newFieldValue)
        {
            var ansObject=new Object();
            
            ansObject['answerId']=quesNoInput.data('answerid');
            ansObject['dataType']=dataType;
            ansObject['fieldValue']=(scenarioName=='.ansColumn') ? newFieldValue : ansElement.prop('checked').toString();
            ansObject['siteWorkBookId']=j$('.siteWorkBookId').val();
            ansObject['quesId']=quesNoInput.data('quesid');
            
            //2017-05-05- anirudh.singh@cdk.com- Added the below IF Block to handle Other Question Types.
            if(ansElement.closest('.quesTR').find('.otherComments').length==1)
            {
                ansObject['answerId']=ansElement.closest('.quesTR').find('.otherComments').data('answerid');
                ansObject['quesId']=ansElement.closest('.quesTR').find('.otherComments').data('quesid');
            }
            
            invokeQuickSave(ansElement, scenarioName, ansObject);
        }
    }
    else
    {
        if(dataType!='Phone')
        {
            performFieldValidation(fieldErrorElement, dataType, ansElement, newFieldValue);
        }
    }
}

function fetchFieldValue(dataType, ansElement)
{
    var fieldValue='';
    if(dataType=='Checkbox')
    {
        fieldValue=ansElement.prop('checked').toString();
    }
    else if(dataType=='Currency' || dataType=='Date' || dataType=='DateTime' || dataType=='Email' || dataType=='Number'
            || dataType=='Phone' || dataType=='Text' || dataType=='URL')
    {
        fieldValue=ansElement.prop('value');
    }
	else if(dataType=='Long Text Area')
    {
        fieldValue=ansElement.val();
    }
	else if(dataType=='MultiSelect Picklist' || dataType=='Picklist')
    {
        var optionElements=ansElement.find('option');
        optionElements.each(function()
		{
            var thisElement=j$(this);
            var optVal=thisElement.val();
            
            if(thisElement.prop('selected')==true && optVal!=undefined && optVal!=null)
            {
                fieldValue+=(fieldValue=='') ? optVal : '; '+optVal;
            }
        });
    }
    
    if(fieldValue==undefined && fieldValue==null)
    {
        fieldValue='';
    }
    
    return fieldValue;
}

function invokeQuickSave(ansElement, scenarioName, ansObject)
{
    var nextTrElements=ansElement.closest('.quesTR').nextAll();
    var totalNoOfElements=0;
    var noOfElementsProcessed=0;
    var ansObjectJSON=JSON.stringify(ansObject);
    
    var clearedAns=[];
    var naAnsList=[];
    naAnsList.push(ansObjectJSON);
    
    if(nextTrElements.length>0)
    {
        nextTrElements.each(function()
        {
            var thisElement=j$(this);
            var quesNoInput=thisElement.find('.quesNo').find('input');
            var parentName=quesNoInput.data('parentname');
            
            if(parentName!=undefined && parentName!=null && parentName!='')
            {
                var answerId=quesNoInput.data('answerid');
                var dataType=quesNoInput.data('datatype');
                
                if(scenarioName=='.ansColumn' && thisElement.css('display')=='none')
                {
                    totalNoOfElements++;
                    var ansColElement=thisElement.find('.ansColumn');
                    
                    noOfElementsProcessed=clearAnswerValues(dataType, ansColElement, noOfElementsProcessed);
                    clearedAns.push(answerId);
                }
                else
                {
                    var naObject=new Object();
                    naObject['answerId']=answerId;
                    naObject['dataType']=dataType;
                    naObject['fieldValue']=thisElement.find('.notApplicableField').prop('checked').toString();
                    naObject['siteWorkBookId']=j$('.siteWorkBookId').val();
                    naObject['quesId']=quesNoInput.data('quesid');
                    naAnsList.push(JSON.stringify(naObject));
                }
            }
            else
            {
                return false;
            }
        });
    }
    
    if(scenarioName=='.ansColumn' && totalNoOfElements==noOfElementsProcessed)
    {
        if(ansObject.dataType=='Checkbox' && ansObject.fieldValue=='false')
        {
            ansObjectJSON=null;
            clearedAns.push(ansObject.answerId);
        }
        else if(ansObject.dataType!='Checkbox' && (ansObject.fieldValue==null || ansObject.fieldValue==undefined || ansObject.fieldValue==''))
        {
            ansObjectJSON=null;
            clearedAns.push(ansObject.answerId);
        }
        
        showQuickSaveSpinner();
        ALL_QuestionAnswer_Controller.quickSaveAnswers(ansObjectJSON, clearedAns, function(result, event)
		{
            if(result!='Network Connected')
            {
                hideQuickSaveSpinner();
                j$('#discQuesAnsErrorDiv').modal('show');
            }
            else
            {
                hideQuickSaveSpinner();
                j$('#discQuesAnsErrorDiv').modal('hide');
            }
        });
    }
    else
    {
        if(naAnsList.length>0)
        {
            showQuickSaveSpinner();
            ALL_QuestionAnswer_Controller.quickSaveNAAnswers(naAnsList, function(result, event)
            {
                if(result!='Network Connected')
                {
                    hideQuickSaveSpinner();
                    j$('#discQuesAnsErrorDiv').modal('show');
                }
                else
                {
                    hideQuickSaveSpinner();
                    j$('#discQuesAnsErrorDiv').modal('hide');
                }
            });
        }
    }
}

function showQuickSaveSpinner()
{
    var quickSaveSpinnerEls=j$('.quickSaveSpinner');
    if(quickSaveSpinnerEls.length>0)
    {
        quickSaveSpinnerEls.each(function()
        {
            j$(this).removeClass('hideQuickSaveSpinner');
            j$(this).addClass('showQuickSaveSpinner');
        });
    }
    
    var qaSaveButtonEls=j$('.qaSaveButton');
    if(qaSaveButtonEls.length>0)
    {
        qaSaveButtonEls.each(function()
        {
            j$(this).prop('disabled', 'disabled');
        });
    }
    
    //Disable Enable Tabs.
    var homePageTabsEls=j$('.tabButtonStyle');
    if(homePageTabsEls.length>0)
    {
        homePageTabsEls.each(function()
        {
            j$(this).prop('disabled', 'disabled');
        });
    }
    
    var tabDropdownLiEls=j$('.tabDropdownLiElement');
    if(tabDropdownLiEls.length>0)
    {
        tabDropdownLiEls.each(function()
        {
            j$(this).prop('disabled', 'disabled');
        });
    }
    
    j$('.generatePdf').prop('disabled', 'disabled');
}

function hideQuickSaveSpinner()
{
    var quickSaveSpinnerEls=j$('.quickSaveSpinner');
    if(quickSaveSpinnerEls.length>0)
    {
        quickSaveSpinnerEls.each(function()
        {
            j$(this).removeClass('showQuickSaveSpinner');
            j$(this).addClass('hideQuickSaveSpinner');
        });
    }
    
    var qaSaveButtonEls=j$('.qaSaveButton');
    if(qaSaveButtonEls.length>0)
    {
        qaSaveButtonEls.each(function()
        {
            j$(this).prop('disabled', '');
        });
    }
    
    //Disable Enable Tabs.
    var homePageTabsEls=j$('.tabButtonStyle');
    if(homePageTabsEls.length>0)
    {
        homePageTabsEls.each(function()
        {
            j$(this).prop('disabled', '');
        });
    }
    
    var tabDropdownLiEls=j$('.tabDropdownLiElement');
    if(tabDropdownLiEls.length>0)
    {
        tabDropdownLiEls.each(function()
        {
            j$(this).prop('disabled', '');
        });
    }
    
    j$('.generatePdf').prop('disabled', '');
}

function performFieldValidation(fieldErrorElement, dataType, ansElement, newFieldValue)
{
    var fieldsValid=true;
    
    var messageText='';
    if(dataType=='Email' && newFieldValue!=null && newFieldValue!=undefined && newFieldValue!='')
    {
        var atTheRateOfPosition=newFieldValue.indexOf("@");
        var dotPosition=newFieldValue.lastIndexOf(".");
        
        if(atTheRateOfPosition<1 || dotPosition<atTheRateOfPosition+2 || dotPosition+2>=newFieldValue.length)
        {
            messageText='Email value invalid. Please enter a valid email (e.g. abc@email.com)';
            fieldsValid=false;
        }
    }
    else if(dataType=='URL' && newFieldValue!=null && newFieldValue!=undefined && newFieldValue!='')
    {
        var urlRegex=new RegExp("^((http|https)://)??(www[.])??([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?$");
        
        if(!urlRegex.test(newFieldValue))
        {
            messageText='Invalid URL. Please enter a valid URL.';
            fieldsValid=false;
        }
    }
    else if(dataType=='Phone' && newFieldValue!=null && newFieldValue!=undefined && newFieldValue!='')
    {
        //Supports: (123) 456 7899, (123).456.7899, (123)-456-7899, 123-456-7899, 123 456 7899, 1234567899
        var phoneRegex=/\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/;
        
        if(!phoneRegex.test(newFieldValue))
        {
            messageText='Invalid Phone Number. Please enter a valid Phone Number.';
            fieldsValid=false;
        }
    }
    
    if(messageText!='')
    {
        var fieldError='<div class="alert alert-danger fieldError" role="alert">'
        +'<strong>Error!</strong> '+messageText+'</div>';
        
        if(fieldErrorElement.length==0)
        {
            ansElement.after(fieldError);
        }
        else
        {
            fieldErrorElement.replaceWith(fieldError);
        }
    }
    
    if(fieldsValid)
    {
        fieldErrorElement.remove();
    }
    
    return fieldsValid;
}

function onLoadCheckChildrenNa(quesNameList)
{
    var quesNoElements=j$('.quesNo');
    var newQuesNameList=[];
    
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var rowElement=thisElement.closest('tr');
        
        var inputElement=thisElement.find('input');
        var parentName=inputElement.data('parentname');
        
        if(parentName!='' && parentName!=null && parentName!=undefined && j$.inArray(parentName, quesNameList)>-1)
        {
            newQuesNameList.push(inputElement.data('questionname'));
            
            var naFieldElement=rowElement.find('.notApplicableField');
            naFieldElement.prop('checked', 'checked');
            naFieldElement.prop('disabled', true);
            
            var ansElement=rowElement.find('.ansColumn');
            ansElement.find('input').prop('disabled', true);
            ansElement.find('textarea').attr('disabled', true);
            ansElement.find('select').prop('disabled', true);
            ansElement.find('.multiselectClearButton').prop('disabled', true);
        }
    });
    
    if(newQuesNameList.length>0)
    {
        onLoadCheckChildrenNa(newQuesNameList);
    }
}

function showHideChildQues()
{
    var quesNoElements=j$('.quesNo');
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var rowElement=thisElement.closest('tr');
        
        var inputElement=thisElement.find('input');
        var parentName=inputElement.data('parentname');
        var parentDatatype=inputElement.data('parentdatatype');
        
        if(parentName!='' && parentName!=null && parentName!=undefined 
           && (parentDatatype=='Picklist' || parentDatatype=='MultiSelect Picklist'))
        {
            var parentAnsForRendering=inputElement.data('parentansforrendering');
            var existingParentAnsValue=fetchParentAnsValue(parentName);
            
            if(!compareParentAnsAndChildAns(existingParentAnsValue, parentAnsForRendering))
            {
                rowElement.hide();
                var quesName=inputElement.data('questionname');
                
                var quesNameList=[];
                quesNameList.push(quesName);
                hideAllChildren(quesNameList);
            }
        }
    });
}

function rerenderChildQues(element)
{
    var thisElement=j$(element);
    var parentRow=thisElement.closest('.quesTR');
    var quesName=parentRow.find('.quesNo').find('input').data('questionname');
    
    var parentAnsValue=fetchParentAnsValue(quesName);
    
    var quesNoElements=j$('.quesNo');
    quesNoElements.each(function()
	{
        var childRow=j$(this).closest('.quesTR');
        var childInputElement=j$(this).find('input')
        var parentQuesName=childInputElement.data('parentname');
        var parentAnsForRendering=childInputElement.data('parentansforrendering');
        
        if(quesName==parentQuesName)
        {
            var chilQuesName=childInputElement.data('questionname');
            
            var quesNameList=[];
            quesNameList.push(chilQuesName);
            
            if(compareParentAnsAndChildAns(parentAnsValue, parentAnsForRendering))
            {
                childRow.show();
                showChildren(quesNameList);
            }
            else
            {
                childRow.hide();
                hideAllChildren(quesNameList);
            }
        }
    });
}

function fetchParentAnsValue(parentName)
{
    var selectedOptions=[];
    
    var quesNoElements=j$('.quesNo');
    quesNoElements.each(function()
	{
        var questionName=j$(this).find('input').data('questionname');
        var answerInputElement=j$(this).closest('tr').find('.ansColumn');
        var parentDataType=j$(this).find('input').data('datatype');
        
        if(questionName==parentName && (parentDataType=='Picklist' || parentDataType=='MultiSelect Picklist'))
        {
            var parentOptElements=answerInputElement.find('select').find('option');
            
            parentOptElements.each(function()
            {
                var thisElement=j$(this);
                var thisElementVal=thisElement.val();
                
                if(thisElement.prop('selected') && thisElementVal!=undefined && thisElementVal!=null && thisElementVal!='')
                {
                    selectedOptions.push(thisElementVal);
                }
            });
        }
    });
    
    return selectedOptions;
}

function compareParentAnsAndChildAns(currentParentAnsValue, parentAnsForRendering)
 {
    var renderChild=false;
    
    if(parentAnsForRendering!=undefined && parentAnsForRendering!=null && parentAnsForRendering!='')
    {
        var tempArray;
        if(parentAnsForRendering.indexOf(',')>-1)
        {
            tempArray=parentAnsForRendering.split(',');
            j$.each(tempArray, function(index, value)
            {
                if(j$.inArray(value.trim(), currentParentAnsValue)>-1)
                {
                    renderChild=true;
                }
            });
        }
        else if(parentAnsForRendering.indexOf(';')>-1)
        {
            tempArray=parentAnsForRendering.split(';');
            j$.each(tempArray, function(index, value)
            {
                if(j$.inArray(value.trim(), currentParentAnsValue)>-1)
                {
                    renderChild=true;
                }
            });
        }
    	else
        {
            if(j$.inArray(parentAnsForRendering, currentParentAnsValue)>-1)
            {
                renderChild=true;
            }
        }
    }
    else
    {
        renderChild=true;
    }
	
	return renderChild;
}

function hideAllChildren(quesNameList)
{
    var quesNoElements=j$('.quesNo');
    var newQuesNameList=[];
    
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var rowElement=thisElement.closest('tr');
        
        var inputElement=thisElement.find('input');
        var parentName=inputElement.data('parentname');
        
        if(parentName!='' && parentName!=null && parentName!=undefined && j$.inArray(parentName, quesNameList)>-1)
        {
            newQuesNameList.push(inputElement.data('questionname'));
            rowElement.hide();
        }
    });
    
    if(newQuesNameList.length>0)
    {
        hideAllChildren(newQuesNameList);
    }
}

function showChildren(quesNameList)
{
    var quesNoElements=j$('.quesNo');
    var newQuesNameList=[];
    
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var rowElement=thisElement.closest('tr');
        
        var inputElement=thisElement.find('input');
        var parentName=inputElement.data('parentname');
        
        if(j$.inArray(parentName, quesNameList)>-1)
        {
            var parentAnsValue=fetchParentAnsValue(parentName);
            var parentAnsForRendering=inputElement.data('parentansforrendering');
            var parentDatatype=inputElement.data('parentdatatype');
            
            if(parentName!='' && parentName!=null && parentName!=undefined 
               && (parentDatatype!='Picklist' && parentDatatype!='MultiSelect Picklist' 
                   || ((parentDatatype=='Picklist' || parentDatatype=='MultiSelect Picklist') 
                       && compareParentAnsAndChildAns(parentAnsValue, parentAnsForRendering))))
            {
                newQuesNameList.push(inputElement.data('questionname'));
                rowElement.show();
            }
        }
    });
    
    if(newQuesNameList.length>0)
    {
        showChildren(newQuesNameList);
    }
}

function naFieldChangeWithChildren(element)
{
    var naElement=j$(element);
    var naFieldValue=naElement.find('.notApplicableField').prop('checked');
    var rowElement=naElement.closest('.quesTR');
    var ansElement=rowElement.find('.ansColumn');
    
    var quesNameList=[];
    var quesName=rowElement.find('.quesNo').find('input').data('questionname');
    quesNameList.push(quesName);
    
    if(naFieldValue)
    {
        ansElement.find('input').prop('disabled', true);
        ansElement.find('textarea').attr('disabled', true);
        ansElement.find('select').prop('disabled', true);
        ansElement.find('.multiselectClearButton').prop('disabled', true);
        
        checkChildrenNa(quesNameList);
    }
    else
    {
        ansElement.find('input').prop('disabled', false);
        ansElement.find('textarea').attr('disabled', false);
        ansElement.find('select').prop('disabled', false);
        ansElement.find('.multiselectClearButton').prop('disabled', false);
        
        uncheckChildrenNa(quesNameList);
    }
}

function checkChildrenNa(quesNameList)
{
    var newQuesNameList=[];
    
    var quesNoElements=j$('.quesNo');
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var rowElement=thisElement.closest('tr');
        
        var inputElement=thisElement.find('input');
        var parentName=inputElement.data('parentname');
        
        if(parentName!='' && parentName!=null && parentName!=undefined && j$.inArray(parentName, quesNameList)>-1)
        {
            newQuesNameList.push(inputElement.data('questionname'));
            
            var naFieldElement=rowElement.find('.notApplicableField');
            naFieldElement.prop('checked', 'checked');
            naFieldElement.prop('disabled', true);
            
            var ansElement=rowElement.find('.ansColumn');
            ansElement.find('input').prop('disabled', true);
            ansElement.find('textarea').attr('disabled', true);
            ansElement.find('select').prop('disabled', true);
            ansElement.find('.multiselectClearButton').prop('disabled', true);
            
            createHiddenInput(naFieldElement, '.notApplicableColumn');
        }
    });
    
    if(newQuesNameList.length>0)
    {
        checkChildrenNa(newQuesNameList);
    }
}

function uncheckChildrenNa(quesNameList)
{
    var newQuesNameList=[];
    
    var quesNoElements=j$('.quesNo');
    quesNoElements.each(function()
	{
        var thisElement=j$(this);
        var rowElement=thisElement.closest('tr');
        
        var inputElement=thisElement.find('input');
        var parentName=inputElement.data('parentname');
        
        if(parentName!='' && parentName!=null && parentName!=undefined && j$.inArray(parentName, quesNameList)>-1)
        {
            newQuesNameList.push(inputElement.data('questionname'));
            
            var naFieldElement=rowElement.find('.notApplicableField');
            naFieldElement.removeAttr('checked');
            naFieldElement.prop('disabled', false);
            
            var ansElement=rowElement.find('.ansColumn');
            ansElement.find('input').prop('disabled', false);
            ansElement.find('textarea').attr('disabled', false);
            ansElement.find('select').prop('disabled', false);
            ansElement.find('.multiselectClearButton').prop('disabled', false);
            
            createHiddenInput(naFieldElement, '.notApplicableColumn');
        }
    });
    
    if(newQuesNameList.length>0)
    {
        uncheckChildrenNa(newQuesNameList);
    }
}

function naFieldChangeNoChildren(element)
{
    var naElement=j$(element);
    var naFieldValue=naElement.find('.notApplicableField').prop('checked');
    var ansElement=naElement.closest('.quesTR').find('.ansColumn');
    
    if(naFieldValue)
    {
        ansElement.find('input').prop('disabled', true);
        ansElement.find('textarea').attr('disabled', true);
        ansElement.find('select').prop('disabled', true);
        ansElement.find('.multiselectClearButton').prop('disabled', true);
    }
    else
    {
        ansElement.find('input').prop('disabled', false);
        ansElement.find('textarea').attr('disabled', false);
        ansElement.find('select').prop('disabled', false);
        ansElement.find('.multiselectClearButton').prop('disabled', false);
    }
}

function clearMultiselectVales(element)
{
    var multiselectOptions=j$(element).prev().find('option');
    
    j$(multiselectOptions).each(function()
	{
        j$(this).prop('selected', false);
    });
    
    rerenderChildQues(j$(element).closest('.ansColumn'));
}

function saveAnswers(element)
{
    var thisComponent=j$(element).closest('.questionAnswerComponent');
    quesTypeFilter(thisComponent.find('.buttonGroup:first').find('.quesTypeBtn').find('a:first'));
    
    var formValid=thisComponent.find('[Id$="questionAnswerForm"]')[0].checkValidity();
    
    if(formValid)
    {
        ALL_QuestionAnswer_Controller.networkTest(function(result, event)
		{
            if(result=='Network Connected')
            {
                var quesTrElements=thisComponent.find('.quesTR[style*="display: none"]');
                
                var noOfElementsProcessed=0;
                
                quesTrElements.each(function()
                {
                    var thisElement=j$(this);
                    if(!thisElement.hasClass('quesTypeFilterHide'))
                    {
                        var quesNoInput=thisElement.find('.quesNo').find('input');
                        var dataType=quesNoInput.data('datatype');
                        var ansElement=thisElement.find('.ansColumn');
                        
                        noOfElementsProcessed=clearAnswerValues(dataType, ansElement, noOfElementsProcessed);
                    }
                });
                
                if(quesTrElements.length==noOfElementsProcessed)
                {
                    j$('#discQuesAnsErrorDiv').modal('hide');
                    var saveActionFunctionName=thisComponent.find('.saveActionFunctionName').val();
                    window[saveActionFunctionName]();
                }
            }
            else
            {
                j$('#discQuesAnsErrorDiv').modal('show');
            }
        });
    }
}

function clearAnswerValues(dataType, ansElement, noOfElementsProcessed)
{
    if(dataType=='Checkbox')
    {
        ansElement.find('input').removeAttr('checked');
        noOfElementsProcessed++;
    }
    else if(dataType=='Currency' || dataType=='Date' || dataType=='DateTime' || dataType=='Email' || dataType=='Number'
            || dataType=='Phone' || dataType=='Text' || dataType=='URL')
    {
        ansElement.find('input').prop('value', '');
        noOfElementsProcessed++;
    }
	else if(dataType=='Long Text Area')
    {
        ansElement.find('textarea').val('');
        noOfElementsProcessed++;
    }
	else if(dataType=='MultiSelect Picklist' || dataType=='Picklist')
    {
        var optionElements=ansElement.find('select').find('option');
        optionElements.each(function()
		{
            j$(this).prop('selected', false);
        });
        noOfElementsProcessed++;
    }
    
    return noOfElementsProcessed;
}

function quesTypeFilterButton(quesTypeFilterBtnEl)
{
    var quesTypeFilterBtnEl=j$(quesTypeFilterBtnEl);
    var thisQAComp=quesTypeFilterBtnEl.closest('.questionAnswerComponent');
    var quesTypeSelected=quesTypeFilterBtnEl.prop('innerText').trim();
    
    var anchorElements=thisQAComp.find('.quesTypeBtn').find('ul').find('a');
    anchorElements.each(function()
	{
        var thisAnchorEl=j$(this);
        if(thisAnchorEl.prop('innerText')==quesTypeSelected)
        {
            thisAnchorEl.hide();
        }
        else
        {
            thisAnchorEl.show();
        }
    });
}

function quesTypeFilter(quesTypeAnchElement)
{
    var quesTypeAnchElement=j$(quesTypeAnchElement);
    var thisQAComp=quesTypeAnchElement.closest('.questionAnswerComponent');
    var quesTypeSelected=quesTypeAnchElement.prop('innerText').trim();
    
    var spanElement='<span ';
    if(quesTypeSelected=='Pre-Sale')
	{
		spanElement+='class="pre"';
	}
	else if(quesTypeSelected=='Post-Sale')
	{
		spanElement+='class="post"';
	}
	else if(quesTypeSelected=='Talk Track')
	{
		spanElement+='class="talkTrack"';
	}
	else
	{
		spanElement+='class="virtual"';
	}
	
	spanElement+='>'+quesTypeSelected+'</span>';
    
    var quesTypeFilterBtnEl=thisQAComp.find('.quesTypeBtn').find('button');
    quesTypeFilterBtnEl.each(function()
	{
        quesTypeFilterBtnEl.prop('innerHTML', spanElement+' <span class="caret"></span>');
        quesTypeFilterButton(quesTypeFilterBtnEl);
    });
    quesTypeFilterButton(quesTypeFilterBtnEl[0]);
    
    filterQues(thisQAComp, quesTypeSelected);
}

function filterQues(thisQAComp, quesTypeSelected)
{
    var quesTREls=thisQAComp.find('.quesTR');
    var noOfQuesTREls=quesTREls.length;
    var noOfParentQues=0;
    var noOfHiddenQues=0;
    var displayedQuesList=[];
    
    //Reset the elements.
    quesTREls.each(function()
	{
        j$(this).removeClass('quesTypeFilterHide');
    });
    
    //Hide the Questions not matching criteria.
    quesTREls.each(function()
	{
        var quesTREl=j$(this);
        var quesNoInput=quesTREl.find('.quesNo').find('input');
        var quesType=quesNoInput.data('questiontype');
        
        if(quesType!=quesTypeSelected && quesTypeSelected!='All Question Types')
        {
            noOfHiddenQues++;
            quesTREl.addClass('quesTypeFilterHide');
        }
    });
    
    //Hide the Children if Parent is Hidden.
    quesTREls.each(function()
	{
        var quesTREl=j$(this);
        var quesNoInput=quesTREl.find('.quesNo').find('input');
        var quesName=quesNoInput.data('questionname');
        var parentName=quesNoInput.data('parentname');
        
        if(!quesTREl.hasClass('quesTypeFilterHide'))
        {
            if(quesTREl.css('display')=='none')
            {
                noOfHiddenQues++;
            }
            else if(quesTREl.css('display')!='none' && !checkIfParentisDisplayed(quesTREls, parentName))
            {
                noOfHiddenQues++;
                quesTREl.addClass('quesTypeFilterHide');
            }
        }
    });
    
    if(noOfQuesTREls==noOfHiddenQues)
    {
        var buttonGroupEl=thisQAComp.find('.buttonGroup');
        var firstButtonGroupEl=buttonGroupEl[0];
        
        var filterInfoMsgEl=thisQAComp.find('.filterInfoMsg');
        var infoMessage='<span class="filterInfoMsg"><h4>There are no '+quesTypeSelected+' question(s) configured for this section.</h4></span>';
        
        if(filterInfoMsgEl.length>0)
        {
            filterInfoMsgEl.replaceWith(infoMessage);
        }
        else
        {
            j$(infoMessage).insertAfter(firstButtonGroupEl);
        }
    }
    else
    {
        var filterInfoMsgEl=thisQAComp.find('.filterInfoMsg');
        if(filterInfoMsgEl.length>0)
        {
            filterInfoMsgEl.remove();
        }
    }
}

function checkIfParentisDisplayed(quesTREls, parentName)
{
    var parentDisplayed=true;
    quesTREls.each(function()
	{
        var quesTREl=j$(this);
        var quesNoInput=quesTREl.find('.quesNo').find('input');
        var quesName=quesNoInput.data('questionname');
        
        if(parentName==quesName && (quesTREl.css('display')=='none' || quesTREl.hasClass('quesTypeFilterHide')))
        {
            parentDisplayed=false;
            return parentDisplayed;
        }
    });
    
    return parentDisplayed;
}

function confirmReset()
{
    j$('#modalDialogQAReset').modal('toggle');
    reset();
}

function reset()
{
    window.location.reload();
}

function showQASpinner()
{
    j$('#qaSpinnerDiv').modal('show');
}

function hideQASpinner()
{
    j$('#qaSpinnerDiv').modal('hide');
}