({
    doInit: function(component, event, helper) {
        var item = component.get("v.item");
        var slideDefMap = component.get("v.slideDefMap");
        var slideOptions = component.get("v.options");
        if (slideDefMap != null && slideDefMap[item["type"]] != null) {
            var slideDef = slideDefMap[item["type"]];
            var componentDef = [];
            var attributes = slideOptions;
            if(attributes ==null){
                attributes={};
            } else {
                attributes = JSON.parse(JSON.stringify(attributes));
            }
            for (var attrname in item){
                attributes[attrname] = item[attrname];
            }
            componentDef.push(new Array(slideDef['component'], attributes));
            $A.createComponents(componentDef,
                function(components, status, errorMessage) {
                    if (status === "SUCCESS") {
                        component.set("v.body", components);
                    }
                }
            );
        }

    }
})