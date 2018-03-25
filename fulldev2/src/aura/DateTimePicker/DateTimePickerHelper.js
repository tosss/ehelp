({
    daysInMonth : function(month, year)
    {
        return (new Date(year, month, 0).getDate()); 
    },
    getDay : function(date,month,year)
    {
        var day = new Date();
        day.setDate(date);
        day.setMonth(month);
        day.setYear(year);
        return day.getDay();
    },
    setCalender : function(component,event,helper,init)
    {
        var months = ['','January','February','March','April','May','June','July','August','September','October','November','December'];
        var displayMonth  = months.indexOf(component.get("v.displayMonth"));
        var displayYear  = component.get("v.displayYear");
        var maxDaysInPrevMonth = helper.daysInMonth(displayMonth-1,displayYear);
        var firstDayOfSelectMonth = helper.getDay(1,displayMonth-1,displayYear);
        var startDayOfMonth =  maxDaysInPrevMonth +1-firstDayOfSelectMonth;
        var maxDaysCurrentMonth = helper.daysInMonth(displayMonth,displayYear);
        var lastDayOfSelectMonth = helper.getDay(maxDaysCurrentMonth,displayMonth-1,displayYear);
        startDayOfMonth = (firstDayOfSelectMonth==0)?startDayOfMonth-7:startDayOfMonth;
        var crossedPrev = startDayOfMonth==1;
        var crossedCurrent = false;
        var dateNumber = startDayOfMonth;
        var changeNext = false;
        var currentDate = new Date();
        currentDate = ((currentDate.getMonth() == (displayMonth-1))&&(currentDate.getFullYear() == displayYear))?currentDate.getDate():0;
        var currentValue = component.get("v.value");
        currentValue = currentValue == "" ? "" : new Date(currentValue);
        currentValue = (currentValue !="" &&  (displayMonth-1) == currentValue.getMonth() )? currentValue : "";
        currentValue = (currentValue !="" &&  (displayYear == currentValue.getFullYear() ))? currentValue : "";
        var date = (currentValue !="" ? currentValue.getDate() : '');
        var template = '';
        for(var i=0;i<42;i++)
        {
            if(!crossedPrev && (i==firstDayOfSelectMonth) && (firstDayOfSelectMonth != 0 ))
            {
                crossedPrev = true;
                dateNumber = 1;
            }
            else if(firstDayOfSelectMonth == 0)
            {
                changeNext = true;
            }
            if(changeNext && (i==7))
            {
                crossedPrev = true;
                dateNumber = 1;  
            }
            if(!crossedCurrent && ((i%7) == ((lastDayOfSelectMonth+1)%7)) && (i>=28) && (dateNumber>=maxDaysCurrentMonth))
            {
                crossedCurrent = true;
                dateNumber = 1;
            }
            if(i%7 == 0)
            {
                template += '<tr>';
            }
            if(!crossedPrev)
            {
                template += '<td class="slds-disabled-text'+(date==dateNumber ? ' slds-is-selected':'')+'" headers="Sunday" role="gridcell" aria-disabled="true">'
                +'<span class="slds-day">'+dateNumber+'</span>'
                +'</td>';
            }
            else if(crossedCurrent)
            {
                template += '<td class="slds-disabled-text'+(date==dateNumber ? ' slds-is-selected':'')+'" headers="Sunday" role="gridcell" aria-disabled="true">'
                +'<span class="slds-day">'+dateNumber+'</span>'
                +'</td>';
            }
                else if( crossedPrev && !crossedCurrent)
                {
                    template += '<td  role="gridcell" class="'+(date==dateNumber ? ' slds-is-selected': (currentDate==dateNumber ? ' slds-is-today ' : ''))+'" aria-disabled="true" onclick="setDate(this);">'
                    +'<span class="slds-day" >'+dateNumber+'</span>'
                    +'</td>';
                }
            
            if(i%7 == 6)
            {
                template += '</tr>';
            }
            dateNumber++;
        }
        template += '<tr>'
        +'<td colspan="7" role="gridcell">'
        +'<a  class="slds-show--inline-block slds-p-bottom--x-small" style="text-decoration:none;" onclick="setToday(this);">Today</a>'
        +'</td>'
        +'</tr>';
        if(init)
        {
            var elements = document.getElementsByClassName("calenderMonths");
            for(var i=0;i<elements.length;i++)
            {
                elements[i].innerHTML = template;
            }
        }
        else
        {
           var element = component.getElement();
            element.querySelector("#calenderMonths").innerHTML = (template);
        }
    }
})