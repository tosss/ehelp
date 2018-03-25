({
    doInit : function(component, event, helper) {
        helper.checkIfSupportedObjectName(component)
            .then($A.getCallback(function() {
                helper.hideMessages();
                helper.fill(component);
            }))
            .catch($A.getCallback(function(error) {
                if(error === 'unsupportedEntity') {
                    helper.setMessage(helper.UNSUPPORTED_ENTITY, component, {severity: "warning"});
                } else {
                    helper.setMessage(helper.GENERIC_ERROR, component);
                }
            }));
    },
    pageChange: function(component, event, helper) {
        var page = component.get("v.page") || 1;
        var totalPages = component.get("v.totalPages") || 0;
        var direction = event.getParam("direction");
        if (direction === "previous" && page > 1) {
            page = page - 1;
        } else if (direction === "next" && page < totalPages) {
            page = page + 1;
        } else if (direction === "first") {
            page = 1;
        }
        component.set("v.page", page);
        helper.showActivities(component, page);
    }
});