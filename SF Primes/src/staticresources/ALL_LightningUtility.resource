//Author :     Vishal Bandari
//Description: Utility to handle some generic events like focusout of popup
//To hide Popups on focus out doesn't work with IE and firefox
document.addEventListener("click",function(event){
    var element = jQuery(event.target).parents('.slds-dropdown');
    var isSibling = jQuery(event.target).parents('button').prev().hasClass('slds-dropdown');
    isSibling = isSibling || (jQuery(event.target).parents('button').next().hasClass('slds-dropdown'));
    jQuery('.slds-dropdown').css('display','none');
    if(element.length != 0)
    {
        jQuery(event.target).parents('.slds-dropdown').css("display","block");
    }
    if(isSibling)
    {
        jQuery(event.target).parents('button').prev().css("display","block");
        jQuery(event.target).parents('button').next().css("display","block");
    }
    
    element = jQuery(event.target).parents('.slds-lookup');
    var style = jQuery(event.target).parents('.slds-lookup').find('.slds-lookup__menu').css("display");
    jQuery('.slds-lookup__menu').css("display","none");
    if(element.length != 0)
    {
        jQuery(event.target).parents('.slds-lookup').find('.slds-lookup__menu').css("display",style);
    }
});

//To set Date in Calender Object
function setDate(element){
    var months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    var date = jQuery(element).find('span').html();
    var month = months.indexOf(jQuery(element).parents("#fullComponent").find("#displayMonth").html());
    var year = jQuery(element).parents("#fullComponent").find("#displayYear").html();
    var d = new Date();
    d.setDate(date);
    d.setMonth(month);
    d.setYear(year);
    jQuery(element).parents("#fullComponent").find(".slds-input").val(d.toLocaleDateString()+" "+d.toLocaleTimeString());
    jQuery(element).parents(".slds-dropdown").css("display","none");
}

//To set Todays Date in Calender Object
function setToday(element)
{
    var d = new Date();
    jQuery(element).parents("#fullComponent").find(".slds-input").val(d.toLocaleDateString()+" "+d.toLocaleTimeString());
    jQuery(element).parents(".slds-dropdown").css("display","none");
}