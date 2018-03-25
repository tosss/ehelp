({
    nextPage: function(component) {
        var startSlideIdx = component.get("v.startSlideIdx");
        var endSlideIdx = component.get("v.endSlideIdx");
        var items = component.get('v.items');
        var slidesPerPage = component.get("v.slidesPerPage");

        startSlideIdx = endSlideIdx;
        endSlideIdx = startSlideIdx + slidesPerPage;

        var currentPage = component.get("v.currentPage");
        if (startSlideIdx >= items.length) {
            startSlideIdx = 0;
            endSlideIdx = slidesPerPage;
            currentPage = 0;
        }

        // Return if carousel reached end of slide definitions.
        if (startSlideIdx >= items.length) {
            return;
        }

        if (endSlideIdx > items.length) {
            endSlideIdx = items.length + 1;
            startSlideIdx = endSlideIdx - slidesPerPage - 1;
        }
        component.set("v.currentPage", currentPage + 1);
        component.set("v.startSlideIdx", startSlideIdx);
        component.set("v.endSlideIdx", endSlideIdx);
    },
    prevPage: function(component) {
        var startSlideIdx = component.get("v.startSlideIdx");
        var endSlideIdx = component.get("v.endSlideIdx");
        var items = component.get('v.items');
        var slidesPerPage = component.get("v.slidesPerPage");
        var currentPage = component.get("v.currentPage");

        // Return if carousel reached start of slide definitions.
        if (startSlideIdx <= 0) {
            endSlideIdx = items.length + 1;
            startSlideIdx = endSlideIdx - slidesPerPage - 1;
            var pages = component.get("v.pages");
            currentPage = pages.length + 1;
        } else {
            endSlideIdx = startSlideIdx;
            startSlideIdx = endSlideIdx - slidesPerPage;
        }

        if (startSlideIdx <= 0) {
            startSlideIdx = 0;
            endSlideIdx = slidesPerPage;
        }

        component.set("v.currentPage", currentPage - 1);
        component.set("v.startSlideIdx", startSlideIdx);
        component.set("v.endSlideIdx", endSlideIdx);
    },
    play: function(component, event, helper) {
        var autoPlayInterval = component.get('v.autoPlayInterval');
        var self = this;
        //this.nextPage.bind(this,component)
        var timer = setInterval($A.getCallback(function() {
            if (component.isValid()) {
                self.nextPage(component);
            } else {
                clearInterval(timer);
            }
        }), autoPlayInterval);
    },
    gotoPage: function(component, gotoPage) {
        var startSlideIdx = component.get("v.startSlideIdx");
        var endSlideIdx = component.get("v.endSlideIdx");
        var items = component.get('v.items');
        var slidesPerPage = component.get("v.slidesPerPage");
        var pages = component.get("v.pages");
        if (gotoPage <= 0) {
            startSlideIdx = 0;
            endSlideIdx = slidesPerPage;
        } else {
            endSlideIdx = (slidesPerPage * gotoPage) + slidesPerPage;
            if (endSlideIdx > items.length) {
                endSlideIdx = items.length;
            }
            startSlideIdx = endSlideIdx - slidesPerPage;
        }

        component.set("v.currentPage", gotoPage + 1);
        component.set("v.startSlideIdx", startSlideIdx);
        component.set("v.endSlideIdx", endSlideIdx);
    }

})