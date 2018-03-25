({
    toggleOverlay: function(component, event, helper) {
        var showOverlay = component.get("v.showOverlay");
        component.set("v.showOverlay", !showOverlay);
    },
    navigate: function(component, event, helper) {
        helper.navigateToURL(component, component.get("v.buttonUrl"));
    },
    doInit: function(component, event, helper) {
        var videoUrl = component.get("v.videoUrl");
        var autoplay = component.get("v.autoplay");
        var loopVideo = component.get("v.loopVideo");
        var showVideoControls = component.get("v.showVideoControls");
        if (videoUrl != null && videoUrl != '') {
            if (videoUrl.includes('?')) {
                videoUrl = videoUrl + '&';

            } else {
                videoUrl = videoUrl + '?';
            }
            var paramArray = [];
            if (autoplay) {
                paramArray.push('autoplay=1');
            }
            if (loopVideo) {
                paramArray.push('loop=1');
            }
            if (showVideoControls) {
                paramArray.push('controls=1');
            } else {
                paramArray.push('controls=0');
            }
            videoUrl = videoUrl + paramArray.join('&');
        }
        component.set("v.videoUrl", videoUrl);
    }
})