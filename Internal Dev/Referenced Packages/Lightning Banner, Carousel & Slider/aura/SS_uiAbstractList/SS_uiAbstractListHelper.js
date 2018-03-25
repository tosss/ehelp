({
    initDataProvider: function(component) {
 		component = component.getConcreteComponent();
        var dataProviders = component.get("v.dataProvider");

        if (dataProviders && dataProviders.length && dataProviders.length > 0) {
            for (var i = 0; i < dataProviders.length; i++) {
                dataProviders[i].addHandler("onchange", component, "c.handleDataChange");
            }
            component._dataProviders = dataProviders;
        }
    },
    handleDataChange: function(component, event, callback) {
        var concrete = component.getConcreteComponent();
        concrete.set("v.items", event.getParam("data"));

        if (callback) {
            callback();
        }
    },
    triggerDataProvider: function(component, index,  refresh, params) {
        var component = component.getConcreteComponent();
        if (!index) {
            index = 0;
        }
        if(params == null){
            params = {};
        }
        var dataProviders = component.get("v.dataProvider");
        if (index >= 0 && dataProviders !=null && index < dataProviders.length) {
            var e = dataProviders[index].get("e.provide");
            if (refresh) {
                e.setParam('refresh',true);
            }
            if(params){
                e.setParam('parameters', params);
            }
            e.fire();
        }
    }
})