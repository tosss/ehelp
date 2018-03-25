({
    doInit: function(component, event, helper) {
        helper.initDataProvider(component);
        helper.triggerDataProvider(component, 0, false);
    },
    handleDataChange: function(component, event, helper) {
        helper.handleDataChange(component, event, function() {
            var itemsList = component.get("v.items");
            var slidesPerPage = component.get("v.slidesPerPage");
            var slidesPerPage = ($A.get("$Browser.formFactor") == 'PHONE' ? (slidesPerPage > 1 ? 1 : slidesPerPage) : slidesPerPage);
            component.set("v.slidesPerPage", slidesPerPage);
            component.set("v.endSlideIdx", slidesPerPage);
            var pages = [];
            for (var i = 1; i <= Math.ceil(itemsList.length / slidesPerPage); i++) {
                pages.push(i);
            }
            component.set("v.pages", pages);
        });
    },
    nextPage: function(component, event, helper) {
        helper.nextPage(component);
    },
    prevPage: function(component, event, helper) {
        helper.prevPage(component);
    },
    gotoPage: function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        helper.gotoPage(component, event.getSource().get("v.value"));
    }
})