//2016-11-16- anirudh.singh@cdk.com- Created this JS for ALL_QuestionAnswerForPDF Visualforce Component.
var j$=jQuery.noConflict();

//Processing on Ready event of the document.
j$(document).ready(
    function()
    {
        j$('.questionAnswerComponent').each(function()
        {
            processQuesAnsHeadersForPDF(j$(this));
            
            processQuesAnsBodyForPDF(j$(this));
        });
    }
);

function processQuesAnsHeadersForPDF(questionAnswerComponent)
{
    var categoryHeaderElement=questionAnswerComponent.find('.categoryHeader');
    var categoryHeaderInputElement=categoryHeaderElement.find('input');
    
    var categoryNameForRecsVal=categoryHeaderInputElement.data('categorynameforrecs');
    var productNameVal=categoryHeaderInputElement.data('productname');
    var subCategoryNameForRecsVal=categoryHeaderInputElement.data('subcategorynameforrecs');
    
    categoryHeaderElement.empty();
    if(subCategoryNameForRecsVal!=undefined && subCategoryNameForRecsVal!=null && subCategoryNameForRecsVal!='')
    {
        categoryHeaderElement.prop('innerText', subCategoryNameForRecsVal);
    }
    else if(productNameVal!=undefined && productNameVal!=null && productNameVal!='')
    {
        categoryHeaderElement.prop('innerText', productNameVal);
    }
	else
    {
        categoryHeaderElement.prop('innerText', categoryNameForRecsVal);
    }
}

function processQuesAnsBodyForPDF(questionAnswerComponent)
{
    var questionanswerwrapperlist=questionAnswerComponent.find('.questionAnswerWrapperList').val();
    
    if(questionanswerwrapperlist>0)
    {
        processQuesNoForPDF(questionAnswerComponent);
        
        processQuesTextForPDF(questionAnswerComponent);
        
        processAnsFieldsForPDF(questionAnswerComponent);
        
        processNACheckboxesForPDF(questionAnswerComponent);
        
        processOtherAnsForPDF(questionAnswerComponent);
    }
    else
    {
        var h4Element='<h4>There are no question(s) configured for this section.</h4>';
        questionAnswerComponent.append(h4Element);
    }
}

function processQuesNoForPDF(questionAnswerComponent)
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

function processQuesTextForPDF(questionAnswerComponent)
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

function processAnsFieldsForPDF(questionAnswerComponent)
{
    var ansElements=questionAnswerComponent.find('.ansColumn');
    
    ansElements.each(function()
	{
        var thisElement=j$(this);
        var inputElement=thisElement.find('input');
        var questionType=inputElement.data('questiontype');
        
        if(questionType!='Other')
        {
            var questionDatatype=inputElement.data('questiondatatype');
            
            var inputElement=thisElement.find('input');
            var answerValue;
            
            if(questionDatatype=='Checkbox')
            {
                answerValue=inputElement.data('checkboxans');
                processCheckboxesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='Currency')
            {
                answerValue=inputElement.data('currencyans');
                processOtherDataTypesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='Date')
            {
                answerValue=inputElement.data('dateans');
                processDateDataTypesForPDF(thisElement, answerValue, 'Date');
            }
            else if(questionDatatype=='DateTime')
            {
                answerValue=inputElement.data('datetimeans');
                processDateDataTypesForPDF(thisElement, answerValue, 'DateTime');
            }
            else if(questionDatatype=='Email')
            {
                answerValue=inputElement.data('emailans');
                processOtherDataTypesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='Long Text Area')
            {
                answerValue=inputElement.data('textareaans');
                processOtherDataTypesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='Number')
            {
                answerValue=inputElement.data('numberans');
                processOtherDataTypesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='Phone')
            {
                answerValue=inputElement.data('phoneans');
                processOtherDataTypesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='Text')
            {
                answerValue=inputElement.data('textans');
                processOtherDataTypesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='URL')
            {
                answerValue=inputElement.data('urlans');
                processOtherDataTypesForPDF(thisElement, answerValue);
            }
            else if(questionDatatype=='Picklist')
            {
                answerValue=inputElement.data('picklistans');
                var picklistOptions=inputElement.data('picklistoptions');
                processPicklistValuesForPDF(thisElement, answerValue, picklistOptions);
            }
            else if(questionDatatype=='MultiSelect Picklist')
            {
                answerValue=inputElement.data('multiselectpicklistans');
                var picklistOptions=inputElement.data('picklistoptions');
                processPicklistValuesForPDF(thisElement, answerValue, picklistOptions);
            }
            inputElement.remove();
        }
        else
        {
            thisElement.closest('tr').remove();
        }
    });
}

function processCheckboxesForPDF(answerElement, answerValue)
{
    var checkboxIcon;
    if(answerValue==true)
    {
        checkboxIcon='<i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
    }
    else
    {
        checkboxIcon='<i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
    }
    
    answerElement.append(checkboxIcon);
}

function processDateDataTypesForPDF(answerElement, answerValue, dataType)
{
    var modifiedDate=new Date(answerValue);
    var dateValue;
    
    if(!isNaN(modifiedDate.getDate()))
    {
        if(dataType=='DateTime')
        {
            var format="AM";
            var hour=modifiedDate.getHours();
            var min=modifiedDate.getMinutes();
            
            if(hour>11)
            {
                format="PM";
            }
            
            if(hour>12)
            {
                hour=hour-12;
            }
            else if(hour==0)
            {
                hour=12;
            }
            if(min<10)
            {
                min="0"+min;
            }
            dateValue=modifiedDate.getMonth()+"/"+modifiedDate.getDate()+"/"+modifiedDate.getFullYear()+" "+hour+":"+min+" "+format;
        }
        else
        {
            dateValue=modifiedDate.getMonth()+"/"+modifiedDate.getDate()+"/"+modifiedDate.getFullYear();
        }
    }
    else
    {
        if(dataType=='DateTime')
        {
            dateValue='mm/dd/yyyy hh:mm';
        }
        else
        {
            dateValue='mm/dd/yyyy';
        }
    }
    
    var spanElement;
    spanElement='<span class="form-control">'+dateValue+'</span>';
    answerElement.append(spanElement);
}

function processOtherDataTypesForPDF(answerElement, answerValue)
{
    var spanElement='<span class="form-control">'+answerValue+'</span>';
    answerElement.append(spanElement);
}

function processPicklistValuesForPDF(answerElement, answerValue, picklistOptions)
{
    var picklistOptionsValue=[];
    
    if(picklistOptions!=undefined && picklistOptions!=null && picklistOptions!='')
    {
        if(picklistOptions.indexOf(',')>-1)
        {
            picklistOptionsValue=picklistOptions.replace(/\r?\n|\r/g, '').split(',');
        }
        else if(picklistOptions.indexOf(';')>-1)
        {
            picklistOptionsValue=picklistOptions.replace(/\r?\n|\r/g, '').split(';');
        }
    }
    
    if(picklistOptionsValue.length>0)
    {
        var fieldSetElement='<fieldset style="border: none;">'
        +'<table role="presentation" class="picklistCheckbox">'
        +'<tbody><tr>';
        
        for(var i=0; i<picklistOptionsValue.length; i++)
        {
            var picklistOption=picklistOptionsValue[i];
            fieldSetElement+='<td>';
            
            if(answerValue!=undefined && answerValue!='' 
               && answerValue!=null && answerValue.indexOf(picklistOption.trim())>-1)
            {
                fieldSetElement+='<i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
            }
            else
            {
                fieldSetElement+='<i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
            }
            fieldSetElement+='<label>'+picklistOption+'</label>'
            +'</td>';
        }
        fieldSetElement+='</tr></tbody>'
        +'</table>'
        +'</fieldset>';
        
        answerElement.append(fieldSetElement);
    }
}

function processNACheckboxesForPDF(questionAnswerComponent)
{
    var naElements=questionAnswerComponent.find('.notApplicableColumn');
    
    naElements.each(function()
	{
        var thisElement=j$(this);
        var inputElement=thisElement.find('input');
        var naValue=inputElement.data('navalue');
        
        var modifiedNAElement;
        if(naValue==true)
        {
            modifiedNAElement='<i class="fa fa-check-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
        }
        else
        {
            modifiedNAElement='<i class="fa fa-square-o pdfCheckboxIcon" aria-hidden="true"></i>';
        }
        modifiedNAElement+='<label class="notApplicableLabel">N/A</label>';
        
        inputElement.remove();
        thisElement.append(modifiedNAElement);
    });
}

function processOtherAnsForPDF(questionAnswerComponent)
{
    var otherAnswerElements=questionAnswerComponent.find('.otherAnswer');
    
    otherAnswerElements.each(function()
	{
        var thisElement=j$(this);
        var inputElement=thisElement.find('input');
        var questionText=inputElement.data('questiontext');
        var questionType=inputElement.data('questiontype');
        var questionDatatype=inputElement.data('questiondatatype');
        var otherAnsValue=inputElement.data('otherans');
        
        var modifiedOtherElement;
        if(questionType=='Other' && questionDatatype=='Long Text Area')
        {
            modifiedOtherElement='<span class="other">'+questionText+'</span>'
            +'<span class="form-control otherAnsValue">';
            if(otherAnsValue!=undefined && otherAnsValue!=null && otherAnsValue!='')
            {
                modifiedOtherElement+=otherAnsValue;
            }
            modifiedOtherElement+='</span>';
            
            inputElement.remove();
            thisElement.append(modifiedOtherElement);
        }
        else
        {
            thisElement.closest('tr').remove();
        }
    });
}