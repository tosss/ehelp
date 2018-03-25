({
    queryCarouselSlides: function(component) {
        var name = component.get("v.name");
        if (name != null && name != '') {
            var action = component.get('c.getSlidesByCarouselName');
            action.setParams({
                'carouselName': name
            });
            var self = this;
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var slides = response.getReturnValue();
                    this.fireDataChangeEvent(component, slides);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log(errors);
                    if (errors && errors[0] && errors[0].message) {
                        throw new Error('Error executing getSlides Action:' + errors[0].message)
                    } else {
                        throw new Error('Unknown Error fetching Carousel data');
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})