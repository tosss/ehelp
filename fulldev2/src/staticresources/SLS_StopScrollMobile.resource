document.addEventListener("click",function(event){
    var element = jQuery(event.target).parents('.slds-dropdown');
    var isSibling = jQuery(event.target).parents('button').prev().hasClass('slds-dropdown');
    isSibling = isSibling || (jQuery(event.target).parents('button').next().hasClass('slds-dropdown'));
    if(element.length == 0 && !isSibling)
    {
        jQuery('.slds-dropdown').each(function(){
            if(!jQuery(this).hasClass("slds-datepicker"))
            {
                jQuery(this).css('display','none');
            }
        });
    }
    console.log(jQuery(event.target).parents(".slds-lookup__menu"));
});
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
function setToday(element)
{
    var d = new Date();
    jQuery(element).parents("#fullComponent").find(".slds-input").val(d.toLocaleDateString()+" "+d.toLocaleTimeString());
    jQuery(element).parents(".slds-dropdown").css("display","none");
}