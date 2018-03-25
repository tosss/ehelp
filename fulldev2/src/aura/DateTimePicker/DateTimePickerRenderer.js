({
    afterRender : function(cmp, helper) {
        var ret = this.superAfterRender();
        var inputDate = cmp.get("v.value");
        if(inputDate == undefined || inputDate == '')
        {
            helper.setCalender(cmp,null,helper,true);
        }
        else
        {
            var dateTime = new Date(inputDate);
            var element = cmp.getElement();
            var months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
            var  month = months[dateTime.getMonth()];
            cmp.set("v.displayMonth",month);
            cmp.set("v.displayYear",dateTime.getFullYear());
            element.querySelector("#selectedDate").value = (dateTime.toLocaleDateString());
            helper.setCalender(cmp,null,helper,false);
        }
        return ret;
    }
})