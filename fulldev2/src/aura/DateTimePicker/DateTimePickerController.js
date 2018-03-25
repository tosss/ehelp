({
    doInit : function(component, event, helper){
        var inputDate = component.get("v.value");
        if(inputDate == undefined || inputDate == '')
        {
            helper.setCalender(component,null,helper,true);
        }
        else
        {
            var dateTime = new Date(inputDate);
            var element = component.getElement();
            var months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
            var  month = months[dateTime.getMonth()];
            component.set("v.displayMonth",month);
            component.set("v.displayYear",dateTime.getFullYear());
            element.querySelector("#selectedDate").value = (dateTime.toLocaleDateString());
            if(component.get('v.datetime'))
            {
                var time = dateTime.toLocaleTimeString();
                console.log(time.indexOf('AM') > 0,dateTime.getHours(),dateTime.getMinutes());
                var hrs = dateTime.getHours();
                var mins = dateTime.getMinutes();
                mins  = mins > 9 ? ' '+mins : ' 0'+mins;
                hrs  = hrs > 9 ? ' '+hrs : ' 0'+hrs;
                component.set('v.selectedTimeHrs',hrs);
                component.set('v.selectedTimeMin',mins);
                component.set("v.selectedTime",dateTime.toLocaleTimeString());
            }
            
            helper.setCalender(component,null,helper,false);
        }
    },
    setTime : function(component, event, helper)
    {
        var hrs = parseInt(component.get("v.selectedTimeHrs"));
        var min = (component.get("v.selectedTimeMin"));
        min =min.trim();
        min += hrs >= 12 ? ' PM':' AM';
        hrs = hrs > 12 ? hrs % 12 : hrs;
        component.set("v.selectedTime",hrs+":"+min);
    },
	initialize : function(component, event, helper) {
        months = ['','January','February','March','April','May','June','July','August','September','October','November','December'];
        var d = new Date();
        var today = d.toLocaleDateString();
        var splittedDate = today.split('/');
        component.set("v.displayMonth",months[splittedDate[0]]);
        component.set("v.displayYear",splittedDate[2]);
	},
    nextMonth : function(component, event, helper) {
        var months = ['','January','February','March','April','May','June','July','August','September','October','November','December'];
        var displayMonth = component.get("v.displayMonth");
        var index = months.indexOf(displayMonth);
        if(index == 12)
        {
            index = 1;
            var displayYear = component.get("v.displayYear");
            displayYear = parseInt(displayYear)+1;
            component.set("v.displayYear",displayYear);
        } 
        else
        {
            index += 1;
        }
        component.set("v.displayMonth",months[index]);
        helper.setCalender(component, event, helper,false);
    },
    prevMonth : function(component, event, helper) {
        var months = ['','January','February','March','April','May','June','July','August','September','October','November','December'];
        var displayMonth = component.get("v.displayMonth");
        var index = months.indexOf(displayMonth);
        if(index == 1)
        {
            index = 12;
            var displayYear = component.get("v.displayYear");
            displayYear = parseInt(displayYear)-1;
            component.set("v.displayYear",displayYear);
        } 
        else{
            index -= 1;
        }
        component.set("v.displayMonth",months[index]);
        helper.setCalender(component, event, helper,false);
    },
    prevYear : function(component,event,helper)
    {
        var displayYear = component.get("v.displayYear");
        component.set("v.displayYear",displayYear-1);
        helper.setCalender(component, event, helper,false);
    },
    nextYear : function(component,event,helper)
    {
        var displayYear = component.get("v.displayYear");
        component.set("v.displayYear",parseInt(displayYear)+1);
        helper.setCalender(component,event,helper,false);
    },
    toggleCalender : function(component,event,helper)
    {
        var displayStyle = jQuery(event.target).parents("#fullComponent").find("#divCalender").css("display");
        displayStyle = displayStyle=="none" ? "block" : "none" ;
        jQuery(event.target).parents("#fullComponent").find("#divCalender").css("display",displayStyle);
    },
    setValue : function(component,event,helper)
    {
        var value = jQuery(event.target).parents("#fullComponent").find("#selectedDate").val();
        component.set("v.selectedDate",value);
        value = new Date(value);
        if(!component.get("v.datetime"))
        {
            value = value.getFullYear()+'-'+(value.getMonth()+1)+'-'+value.getDate();
        }
        component.set("v.value",value);
        console.log(value);
    }
})