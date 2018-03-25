({
    // Your renderer method overrides go here
    afterRender: function(component, helper) {
        var autoPlay = component.get('v.autoPlay');
        if (autoPlay) {
            helper.play(component);
        }
        var touchstartX = 0;
        var touchstartY = 0;
        var touchendX = 0;
        var touchendY = 0;
        var threshold = 100;

        function handleGesure() {
            var swiped = 'swiped: ';
            var distX = touchendX - touchstartX; // get horizontal dist traveled by finger while in contact with surface
        	var distY = touchendY - touchstartY;
            if (touchendX < touchstartX && Math.abs(distX) >= threshold ) {
                //                console.log(swiped + 'left!');
                helper.nextPage(component);
            } else if (touchendX > touchstartX && Math.abs(distX) >= threshold) {
                //                console.log(swiped + 'right!');
                helper.prevPage(component);
            }

            if (touchendY < touchstartY && Math.abs(distY) >= threshold) {
                //console.log(swiped + 'down!');
            } else if (touchendY > touchstartY && Math.abs(distY) >= threshold) {
                //console.log(swiped + 'up!');
            }

            if (touchendY == touchstartY) {
                //console.log('tap!');
            }
        }


        var gesturedZone = component.getElement();

        gesturedZone.addEventListener('touchstart', $A.getCallback(function(e) {
            touchstartX = e.changedTouches[0].screenX;
            touchstartY = e.changedTouches[0].screenY;
        }, false));

        gesturedZone.addEventListener('touchmove', $A.getCallback(function(e) {
           // e.preventDefault();
        }, false));

        gesturedZone.addEventListener('touchend', $A.getCallback(function(e) {
            touchendX = e.changedTouches[0].screenX;
            touchendY = e.changedTouches[0].screenX;
            handleGesure();

        }, false));

        this.superAfterRender();
    }
})