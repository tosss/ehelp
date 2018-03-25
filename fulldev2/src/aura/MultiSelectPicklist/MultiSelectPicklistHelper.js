({
    selectOption : function(component, event, helper) {
        var isMulti = component.get('v.multi');
        var selectedOption = jQuery(event.target).parents('li').find('.optionValue').html();
        var totalOptions = component.get('v.options');
        if(isMulti)
        {
            var selectedOptions = component.get('v.selectedOptions');
            if(selectedOption.trim().toLowerCase() == 'select all')
            {
                if(selectedOptions.length == totalOptions.length)
                {
                    jQuery(event.target).parents('div').find('.icon').addClass('invisible');
                    component.set('v.selectedOptions',[]);
                    component.set('v.selectedCount','None Selected');
                }
                else
                {
                    selectedOptions = [];
                    jQuery(event.target).parents('div').find('.icon').removeClass('invisible');
                    selectedOptions= totalOptions.slice(0);
                    component.set('v.selectedOptions',selectedOptions);
                    component.set('v.selectedCount',totalOptions.length+' Selected');
                }
            }
            else
            {
                var selectedIndex = selectedOptions.indexOf(selectedOption);
                jQuery(event.target).parents('li').find('.icon').toggleClass('invisible');
                var cmpTarget = component.find('allOption');
                if(selectedIndex == -1)
                {
                    selectedOptions.push(selectedOption);
                }
                else
                {
                    selectedOptions.splice(selectedIndex,1);
                }
                var updatedLength = selectedOptions.length;
                var count;
                if(updatedLength == 0)
                {
                    count = 'None Selected';
                }
                else 
                {
                    count = updatedLength+' Selected';
                }
                
                if(updatedLength == totalOptions.length)
                {
                    $A.util.removeClass(cmpTarget,'invisible'); 
                    jQuery(event.target).parents('ul').find('#allOption').removeClass('invisible');
                }
                else
                {
                    $A.util.addClass(cmpTarget,'invisible');
                    jQuery(event.target).parents('ul').find('#allOption').addClass('invisible');   
                }
                component.set('v.selectedCount',count);
                component.set('v.selectedOption',selectedOption);
            }
        }
        else
        {
            component.set('v.selectedOption',selectedOption);
            component.set('v.selectedCount',selectedOption);
            helper.hide(component, event, helper);
        }
    },
    hide : function(component, event, helper) {
		jQuery(event.target).parents("#fullComponent").find("#optionsList").css('display','none');
    },
    doInit : function(component, event, helper)
    {
        //make default options
    }
})