({
	doInit : function(component, event, helper) {
        helper.fetchStockData(component, event, helper);
        var timeInterval = component.get("v.RefreshInterval");
        timeInterval =  (timeInterval == '30sec' ? 30000 :
        				(timeInterval == '1min' ? 60000 :
        				(timeInterval == '3min' ? 180000 :
        				(timeInterval == '5min' ? 300000 :
        				(timeInterval == '10min' ? 600000 :
        				(timeInterval == '30min' ? 1800000 :
        				(timeInterval == '1hr' ? 3600000 : 10800000)))))));
        window.setInterval(
            $A.getCallback(function() {
                helper.fetchStockData(component, event, helper);
            }), timeInterval
        );
	}
})