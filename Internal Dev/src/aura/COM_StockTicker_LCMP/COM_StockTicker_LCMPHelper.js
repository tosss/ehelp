({
    fetchStockData : function(component, event, helper)
    {
        var action = component.get("c.stockTickerServer");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                if(response.getReturnValue() != null){
                    var responseValue = JSON.parse(response.getReturnValue().substr(2,response.getReturnValue().length-1));
                    if(responseValue["c"].indexOf("+")>=0){
                        component.set("v.isStockPriceUp","+ve");
                    }
                    else if(responseValue["c"].indexOf("-")>=0){
                        component.set("v.isStockPriceUp","-ve");
                    }
                    else{
                        component.set("v.isStockPriceUp","zero");
                    }
                    component.set("v.currentStockPrice",responseValue["l_cur"]+" ");
                    component.set("v.updatedTime",responseValue["lt"]+" ");
                    component.set("v.changeInStockPrice",responseValue["c"]+" ");
                    component.set("v.percentageChangeInStockPrice",responseValue["cp"]);
                }
                else
                {
                    component.set("v.isStockPriceUp","null");
                }
            }
        });
        $A.enqueueAction(action);
    }
})