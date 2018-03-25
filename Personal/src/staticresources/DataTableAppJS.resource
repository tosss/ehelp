var j$= jQuery.noConflict();
j$(document).ready(function(){
    j$('body').on('dblclick','.dataHolder',function(){
        j$(this).find('.viewMode').each(function()
                                        {
                                            if(j$(this).attr('updateable')=='true')
                                            {
                                                j$(this).hide();
                                                j$(this).siblings('.editMode').show();
                                                j$(this).siblings('.editMode').find('#inputValue').focus();
                                            }
                                        });
    });
    j$('body').on('click','#scrollTop',function(){
        window.scrollTo(0,0);
    });
    j$('body').on('click','#scrollBottom',function(){
        window.scrollTo(0,j$(window).height()*1000);
    });
    j$('body').on('blur','.required',function(){
        if(j$(this).val()==null || j$(this).val()==undefined || j$(this).val().trim()=='')
        {
            j$(this).focus();
        }
    });
    j$('body').on('blur','#inputValue',function(){
        var tagName = j$(this).parent().parent().prop('tagName');
        if(tagName == 'LOOK-UP')
        {
            var value = j$(this).val();
            var Id='';
            j$(this).siblings('.lookupMode').find('li').each(function(){
                if(j$(this).html() == value)
                {
                    Id = j$(this).attr('value');
                }
            });
            j$(this).closest('td').find('#outputValue').each(function(){
                j$(this).html(value);
                j$(this).attr('href','/'+Id);
            });
        }
    });
    j$('body').on('click','.lookupMode',function(){
        j$(this).prev().focus();
    });
    
    j$('body').on('blur','.editMode',function(){
        var isRequired = j$(this).find('#inputValue').attr('class');
        isRequired = isRequired.indexOf('required');
        isRequired = (isRequired  >= 0);
        var isEmpty = j$(this).find('#inputValue').val();
        isEmpty = ( isEmpty==undefined || isEmpty==null || isEmpty.trim()=='' );
        if(!isRequired || !(isRequired && isEmpty))
        {
            if(j$('.focussed').html()==undefined)
            {
                j$(this).hide();
                j$(this).siblings('.viewMode').show();
                j$(this).siblings('.viewMode').find('output-field').css('color','orange');
            }
        }
    });
    j$('body').on('click','.collapseIcon',function(){
        var plus_minus =  j$(this).html();
        if(plus_minus.indexOf('+')>0)
        {
            j$(this).closest('table').find('.childBody').hide();
            j$(this).html('[-]&nbsp;&nbsp;');
        }
        else
        {
            j$(this).closest('table').find('.childBody').show();
            j$(this).html('[+]&nbsp;&nbsp;');
        }
    });
    j$('body').on('click','.createRecordButton',function(){
        var valid = true;
        var type= j$(this).attr('type');
        j$(this).closest('table').find('.required').each(function()
                                                         {
                                                             if( j$(this).is(':visible') && (j$(this).val()==null || j$(this).val()==undefined || j$(this).val().trim()==''))
                                                             {
                                                                 valid = false;
                                                                 j$(this).focus();
                                                             }
                                                         });
    });
    
});

function getObjectName()
{
    objectName = location.href;
    var startIndex = objectName.indexOf('?objectName=')+12;
    objectName = objectName.substring(startIndex,objectName.length);
    return objectName;
}